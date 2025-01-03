#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <ESPAsyncWebServer.h>
#include <esp_sleep.h>
#include <FS.h>
#include <SPIFFS.h>

//-----------------------------------
// Cấu hình dịch vụ BLE
//-----------------------------------
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

//-----------------------------------
// Cấu hình MQTT
//-----------------------------------
const char* mqtt_server = "c9348ccdaf08484f84328bd7ffcd9471.s1.eu.hivemq.cloud";
const int   mqtt_port = 8883;
const char* mqtt_username = "esp32s3";
const char* mqtt_password = "App123456@";

WiFiClientSecure   wifiClient;
PubSubClient       client(wifiClient);
AsyncWebServer     server(80);

//-----------------------------------
// Cấu hình cảm biến lưu lượng nước
//-----------------------------------
#define FLOW_SENSOR_PIN GPIO_NUM_2  // Chân GPIO 4 vừa đọc xung, vừa đánh thức thiết bị
#define WAKE_GPIO_PIN   GPIO_NUM_5

volatile int   pulseCount = 0;
float          flowRate = 0.0;
volatile unsigned long lastPulseTime = 0;

const float calibrationFactor = 450.0;
unsigned long lastTime = 0 ;

unsigned long  lastPublishTime = 0;
const unsigned long publishInterval = 1000; // 2 giây

unsigned long noWaterStartTime = 0;
const unsigned long noWaterDuration = 2 * 60 * 1000;
bool noWaterDetected = false;

const float NO_WATER_THRESHOLD = 0.1; 

String ssid_new = "";
String password_new = "";

//-----------------------------------
// Cờ trạng thái
//-----------------------------------
bool bleEnabled = false;
bool isWifiConnected = false;
bool apEnabled = false; 
bool wifiPreviouslyConnected = false;

//-----------------------------------
// Định nghĩa trạng thái
//-----------------------------------
enum State {
    CHUA_CO_KET_NOI,
    KET_NOI_BLE,
    CHO_THONG_TIN_WIFI,
    KET_NOI_WIFI,
    NHAN_THONG_TIN_WIFI,
    KET_NOI_WIFI_THANH_CONG,
    GUI_DU_LIEU_MQTT,
    CHE_DO_BLE,
    CHE_DO_LAN,
    CHE_DO_AP, 
    SEND_FLASH_DATA
};

State currentState = KET_NOI_WIFI;


//-----------------------------------
// Lưu thông tin WiFi vào SPIFFS
//-----------------------------------
void saveWiFiCredentials(const String& ssid, const String& password) {
    File file = SPIFFS.open("/wifi.txt", FILE_WRITE);
    if (!file) {
        Serial.println("Failed to open file for writing WiFi credentials");
        return;
    }
    file.println(ssid);
    file.println(password);
    file.close();
    Serial.println("WiFi credentials saved to SPIFFS.");
}

// Đọc thông tin WiFi từ SPIFFS
bool loadWiFiCredentials(String& ssid, String& password) {
    File file = SPIFFS.open("/wifi.txt", FILE_READ);
    if (!file) {
        Serial.println("Failed to open file for reading WiFi credentials");
        return false;
    }
    ssid = file.readStringUntil('\n');
    password = file.readStringUntil('\n');
    ssid.trim();
    password.trim();
    file.close();
    return !ssid.isEmpty() && !password.isEmpty();
}

// Xóa thông tin WiFi khỏi SPIFFS
void clearWiFiCredentials() {
    if (SPIFFS.remove("/wifi.txt")) {
        Serial.println("WiFi credentials cleared from SPIFFS.");
    } else {
        Serial.println("Failed to clear WiFi credentials.");
    }
}


//-----------------------------------
// Lớp callback BLE để nhận thông tin WiFi
//-----------------------------------
class MyCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue().c_str();
        Serial.println("Value received: " + value);

        if (value.startsWith("ssid:") && value.indexOf(",psw:") != -1) {
            int ssidStart = value.indexOf("ssid:") + 5;
            int pswStart = value.indexOf(",psw:") + 5;

            if (ssidStart < pswStart - 5 && pswStart < value.length()) {
                String ssid = value.substring(ssidStart, pswStart - 5);
                String password = value.substring(pswStart);

                Serial.println("Received WiFi credentials:");
                Serial.println("SSID: " + ssid);
                Serial.println("Password: " + password);

                ssid_new = ssid;
                password_new = password;
                currentState = KET_NOI_WIFI; // Chuyển sang trạng thái kết nối WiFi
            } else {
                Serial.println("Invalid WiFi credentials format");
            }
        }
    }
};
void handleStateKET_NOI_WIFI() {
    static unsigned long startAttemptTime = 0;
    static bool connectingNew = false;
    static bool tryingSaved = false;

    if (!connectingNew && !tryingSaved) {
        Serial.println("State: Connecting to WiFi with new credentials...");
        WiFi.disconnect(true);
        WiFi.begin(ssid_new.c_str(), password_new.c_str());
        startAttemptTime = millis();
        connectingNew = true;
    }

    if (connectingNew) {
        if (WiFi.status() == WL_CONNECTED) {
            Serial.println("\nConnected to WiFi successfully with new credentials.");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
            saveWiFiCredentials(ssid_new, password_new); // Lưu thông tin WiFi
            currentState = KET_NOI_WIFI_THANH_CONG;
            connectingNew = false;
        } else if (millis() - startAttemptTime > 10000) { // Timeout sau 10 giây
            Serial.println("Failed to connect with new credentials. Trying saved credentials...");
            String savedSSID, savedPassword;
            if (loadWiFiCredentials(savedSSID, savedPassword)) {
                ssid_new = savedSSID;
                password_new = savedPassword;
                WiFi.disconnect(true);
                WiFi.begin(ssid_new.c_str(), password_new.c_str());
                startAttemptTime = millis();
                connectingNew = false;
                tryingSaved = true;
            } else {
                Serial.println("No saved WiFi credentials found. Returning to BLE mode.");
                currentState = CHUA_CO_KET_NOI;
                connectingNew = false;
            }
        }
    } else if (tryingSaved) {
        if (WiFi.status() == WL_CONNECTED) {
            Serial.println("\nConnected to WiFi using saved credentials.");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
            currentState = KET_NOI_WIFI_THANH_CONG;
            tryingSaved = false;
        } else if (millis() - startAttemptTime > 10000) { // Timeout sau 10 giây
            Serial.println("\nFailed to connect to WiFi with saved credentials. Returning to BLE mode.");
            currentState = CHUA_CO_KET_NOI;
            tryingSaved = false;
        }
    }
}

//-----------------------------------
// Ngắt đếm xung lưu lượng nước
//-----------------------------------
void IRAM_ATTR pulseCounter() {
    unsigned long currentTime = millis();
    if (currentTime - lastPulseTime > 1) {
        pulseCount++;
        lastPulseTime = currentTime;
    }
}

//-----------------------------------
// MQTT callback
//-----------------------------------
void mqttCallback(char* topic, byte* message, unsigned int length) {
    String receivedTopic = String(topic);
    String messageValue;
    for (unsigned int i = 0; i < length; i++) {
        messageValue += (char)message[i];
    }
    Serial.print("Message Received: ");
    Serial.println(messageValue);

    if (receivedTopic == "command") {
        if (messageValue == "AC") {
            currentState = CHE_DO_AP;
        } else if (messageValue == "BLE") {
            currentState = CHE_DO_BLE;
        } else if (messageValue == "LAN") {
            currentState = CHE_DO_LAN;
        }
    }
}

//-----------------------------------
// Kết nối MQTT
//-----------------------------------
void connectToMqtt() {
    static unsigned long lastAttemptTime = 0;

    // Đặt máy chủ MQTT
    client.setServer(mqtt_server, mqtt_port);

    // Kiểm tra nếu đã kết nối
    if (client.connected()) {
        Serial.println("MQTT connected.");
        client.subscribe("command"); // Đăng ký topic
        return;
    }

    // Nếu chưa kết nối, kiểm tra thời gian thử lại
    if (millis() - lastAttemptTime >= 2000) { // Mỗi 2 giây thử lại
        Serial.println("Attempting to connect to MQTT...");
        if (client.connect("ESP32Client", mqtt_username, mqtt_password)) {
            Serial.println("MQTT connected.");
            client.subscribe("command"); // Đăng ký topic sau khi kết nối thành công
        } else {
            Serial.print("Failed to connect to MQTT, state: ");
            Serial.println(client.state()); // Ghi lại trạng thái lỗi nếu có
        }
        lastAttemptTime = millis(); // Cập nhật thời gian lần thử tiếp theo
    }
}
//-----------------------------------
void enableLAN() {
        Serial.println("LAN Mode");

         server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
            request->send(200, "text/html",
                          "<!DOCTYPE html>"
                          "<html>"
                          "<head>"
                          "<title>ESP32 Access Point</title>"
                          "<style>"
                          "body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }"
                          "form { display: inline-block; background-color: #f9f9f9; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }"
                          "input[type='text'], input[type='password'] { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; }"
                          "input[type='submit'] { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }"
                          "input[type='submit']:hover { background-color: #45a049; }"
                          "</style>"
                          "</head>"
                          "<body>"
                          "<h2>Connect to WiFi</h2>"
                          "<form action=\"/connect\" method=\"post\">"
                          "SSID: <input type=\"text\" name=\"ssid\"><br>"
                          "Password: <input type=\"password\" name=\"password\"><br>"
                          "<input type=\"submit\" value=\"Connect\">"
                          "</form>"
                          "</body>"
                          "</html>");
        });


        server.on("/connect", HTTP_POST, [](AsyncWebServerRequest *request) {
            String ssid = "";
            String password = "";

            if (request->hasParam("ssid", true) && request->hasParam("password", true)) {
                ssid = request->getParam("ssid", true)->value();
                password = request->getParam("password", true)->value();
            }

            if (!ssid.isEmpty() && !password.isEmpty()) {
                ssid_new = ssid;
                password_new = password;
                currentState = KET_NOI_WIFI;
            } else {
                request->send(200, "text/plain", "Invalid credentials format.");
            }
        });

        server.begin();
}


//-----------------------------------
// Bật Access Point và giao diện HTML
//-----------------------------------
void enableAccessPoint() {
    if (!apEnabled) {
        WiFi.softAP("ESP32-AP", "12345678");
        IPAddress apIP = WiFi.softAPIP();
        Serial.println("Access Point enabled.");
        Serial.println("AP IP Address: " + apIP.toString());
        apEnabled = true;

         server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
            request->send(200, "text/html",
                          "<!DOCTYPE html>"
                          "<html>"
                          "<head>"
                          "<title>ESP32 Access Point</title>"
                          "<style>"
                          "body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }"
                          "form { display: inline-block; background-color: #f9f9f9; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }"
                          "input[type='text'], input[type='password'] { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; }"
                          "input[type='submit'] { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }"
                          "input[type='submit']:hover { background-color: #45a049; }"
                          "</style>"
                          "</head>"
                          "<body>"
                          "<h2>Connect to WiFi</h2>"
                          "<form action=\"/connect\" method=\"post\">"
                          "SSID: <input type=\"text\" name=\"ssid\"><br>"
                          "Password: <input type=\"password\" name=\"password\"><br>"
                          "<input type=\"submit\" value=\"Connect\">"
                          "</form>"
                          "</body>"
                          "</html>");
        });


        server.on("/connect", HTTP_POST, [](AsyncWebServerRequest *request) {
            String ssid = "";
            String password = "";

            if (request->hasParam("ssid", true) && request->hasParam("password", true)) {
                ssid = request->getParam("ssid", true)->value();
                password = request->getParam("password", true)->value();
            }

            if (!ssid.isEmpty() && !password.isEmpty()) {
                ssid_new = ssid;
                password_new = password;
                disableAccessPoint();
                currentState = KET_NOI_WIFI;
            } else {
                request->send(200, "text/plain", "Invalid credentials format.");
            }
        });

        server.begin();
    }
}


//-----------------------------------
// Tắt Access Point
//-----------------------------------
void disableAccessPoint() {
    if (apEnabled && WiFi.softAPgetStationNum() == 0) {
        WiFi.softAPdisconnect(true);
        Serial.println("Access Point disabled.");
        apEnabled = false;
    }
}


//-----------------------------------
// Lưu dữ liệu và thời gian vào SPIFFS, chỉ giữ 20 giá trị
//-----------------------------------
void saveDataToSPIFFS(const String& data) {
    // Đọc toàn bộ dữ liệu hiện có
    File file = SPIFFS.open("/data.log", FILE_READ);
    if (!file) {
        Serial.println("Failed to open file for reading");
        return;
    }

    // Đọc các dòng dữ liệu hiện tại
    std::vector<String> lines;
    while (file.available()) {
        lines.push_back(file.readStringUntil('\n'));
    }
    file.close();

    // Nếu đã đủ 20 giá trị, xóa giá trị cũ nhất
    if (lines.size() >= 20) {
        lines.erase(lines.begin()); // Xóa dòng đầu tiên
    }

    // Thêm giá trị mới kèm thời gian
//    String timestamp = String(millis()); // Thời gian từ khi khởi động (ms)
    String newData = data;
    lines.push_back(newData);

    // In giá trị vừa lưu vào Serial Monitor
    Serial.println("Saved to SPIFFS: " + newData);

    // Ghi lại toàn bộ dữ liệu vào tệp
    file = SPIFFS.open("/data.log", FILE_WRITE);
    if (!file) {
        Serial.println("Failed to open file for writing");
        return;
    }
    for (const String& line : lines) {
        file.println(line);
    }
    file.close();
}

//-----------------------------------
// Gửi dữ liệu từ SPIFFS lên MQTT khi reconnect WiFi
//-----------------------------------
bool sendSavedDataToMQTT() {
    static File file = SPIFFS.open("/data.log", FILE_READ); // File tĩnh để giữ trạng thái giữa các lần gọi
    if (!file) {
        Serial.println("Failed to open file for reading");
        return false;
    }

    if (!file.available()) {
        Serial.println("No more data in flash to send.");
        file.close();                  // Đóng file khi đã gửi hết dữ liệu
        SPIFFS.remove("/data.log");    // Xóa file sau khi gửi xong
        return false;                  // Báo rằng không còn dữ liệu
    }

    // Đọc và gửi một dòng
    String line = file.readStringUntil('\n');
    if (line.length() > 0) {
        if (client.publish("datawater", line.c_str())) {
            Serial.println("Sent flash data: " + line);
        } else {
            Serial.println("Failed to send flash data: " + line);
            file.close();
            return false; // Nếu gửi thất bại, giữ lại file để gửi lần sau
        }
    }

    return true; // Còn dữ liệu để gửi
}

float readFlowRate() {
    // Tính toán lưu lượng nước
    float calculatedFlowRate = (pulseCount / 450.0) * 60.0;
    pulseCount = 0; // Reset bộ đếm
    return calculatedFlowRate;
}

//-----------------------------------
// Gửi dữ liệu lưu lượng nước qua MQTT
//-----------------------------------

void publishFlowRate(float flowRate) {
    // Tạo tin nhắn MQTT
    if (flowRate >= 1.5) {
        String flowMessage = String(flowRate);
        Serial.println("Publishing flow rate: " + flowMessage);
        if (!client.publish("datawater", flowMessage.c_str())) {
            Serial.println("Failed to send MQTT. Saving to SPIFFS.");
            saveDataToSPIFFS(flowMessage); // Lưu giá trị vào SPIFFS nếu gửi thất bại
        } else {
            Serial.println("Sent to topic Datawater: " + flowMessage);
        }
    }
}



void handleNoWaterSleepMode(float flowRate) {
    if (flowRate < 1) {
        if (!noWaterDetected) {
            noWaterStartTime = millis();
            noWaterDetected = true;
            Serial.println("No water detected. Starting 2 countdown to sleep mode.");
        } else if (millis() - noWaterStartTime > noWaterDuration) {
            Serial.println("No water for 2 minutes. Entering Sleep Mode...");

            // Cấu hình wake-up từ GPIO_NUM_2
//            esp_sleep_enable_ext1_wakeup(1ULL << FLOW_SENSOR_PIN, ESP_EXT1_WAKEUP_ANY_HIGH);

            // Vào chế độ ngủ sâu
            esp_deep_sleep_start();
        }
    } else {
        noWaterDetected = false; // Reset nếu có nước
    }
}



//-----------------------------------
// Khởi tạo BLE
//-----------------------------------
void initBLE() {
    

    if (!bleEnabled) {
        BLEDevice::init("XIAO_ESP32S3");
        BLEServer *pServer = BLEDevice::createServer();
        BLEService *pService = pServer->createService(SERVICE_UUID);

        BLECharacteristic *pCharacteristic = pService->createCharacteristic(
            CHARACTERISTIC_UUID,
            BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE
        );
        pCharacteristic->setCallbacks(new MyCallbacks());
        pService->start();

        BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
        pAdvertising->addServiceUUID(SERVICE_UUID);
        pAdvertising->setScanResponse(true);
        BLEDevice::startAdvertising();

        
        bleEnabled = true;
        Serial.println("BLE enabled and advertising");
    }
}

//-----------------------------------
// Tắt BLE
//-----------------------------------
void stopBLE() {
    if (bleEnabled) {
        BLEDevice::deinit();
        bleEnabled = false;
        Serial.println("BLE disabled");
    }
}

//-----------------------------------
// Trạng thái CHUA_CO_KET_NOI
//-----------------------------------
void handleStateCHUA_CO_KET_NOI() {
    static unsigned long lastAttemptTime = 0;

    if (millis() - lastAttemptTime > 500) {
        Serial.println("State: No have connection");
        initBLE();
        currentState = KET_NOI_BLE;
        lastAttemptTime = millis();
    }
}


void printWakeUpReason() {
    esp_sleep_wakeup_cause_t wakeup_reason = esp_sleep_get_wakeup_cause();

    switch (wakeup_reason) {
        case ESP_SLEEP_WAKEUP_EXT0: Serial.println("Wakeup caused by external signal using RTC_IO"); break;
        case ESP_SLEEP_WAKEUP_EXT1: Serial.println("Wakeup caused by external signal using RTC_CNTL"); break;
        default: Serial.println("Wakeup not caused by external signal."); break;
    }
}

//-----------------------------------
// Setup
//-----------------------------------
void setup() {
    Serial.begin(115200);
    printWakeUpReason();
    
// GPIO_SEL_2 tương ứng với GPIO_NUM_2

    pinMode(FLOW_SENSOR_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, RISING);

    if (!SPIFFS.begin(true)) {
        Serial.println("Failed to format and mount SPIFFS");
        return;
    }
    currentState = KET_NOI_WIFI;
    wifiClient.setInsecure();  // Set up insecure connection for testing
    client.setCallback(mqttCallback);  // Set the MQTT callback function
}
static unsigned long lastReadTime = 0;


//-----------------------------------
// Loop
//-----------------------------------
void loop() {
    static unsigned long lastUpdateTime = 0;

    // Đọc mỗi 1 giây
    if (millis() - lastReadTime > 1000) {
        lastReadTime = millis();
        float flowRate = readFlowRate();
      

        // Kiểm tra trạng thái WiFi và xử lý lưu/gửi dữ liệu
        if (flowRate > 1.5) {
            if (!isWifiConnected) {
                saveDataToSPIFFS(String(flowRate)); // Lưu vào SPIFFS nếu không có WiFi
            } else if (client.connected()) {
                publishFlowRate(flowRate); // Gửi qua MQTT nếu WiFi và MQTT đã kết nối
            } else {
                Serial.println("Client not connected. Saving to SPIFFS.");
                saveDataToSPIFFS(String(flowRate)); // Lưu nếu không kết nối được MQTT
            }
        } 
            
        handleNoWaterSleepMode(flowRate); // Countdown sleep mode
    }

    // Kiểm tra trạng thái hệ thống mỗi 100ms
    if (millis() - lastUpdateTime >= 100) {
        switch (currentState) {
            case CHUA_CO_KET_NOI:
                handleStateCHUA_CO_KET_NOI();
                break;

            case KET_NOI_BLE:
                initBLE();
                currentState = KET_NOI_BLE;
                break;

            case KET_NOI_WIFI:
                handleStateKET_NOI_WIFI();
                break;

            case KET_NOI_WIFI_THANH_CONG:
                if (!isWifiConnected) isWifiConnected = true;
                if (!client.connected()) {
                    connectToMqtt();
                }
                if (WiFi.status() != WL_CONNECTED) {
                    Serial.println("WiFi lost. Returning to BLE mode.");
                    currentState = CHUA_CO_KET_NOI;
                } else if (SPIFFS.exists("/data.log")) {
                    Serial.println("Data found in flash. Switching to SEND_FLASH_DATA state.");
                    currentState = SEND_FLASH_DATA;
                } else {
                    Serial.println("No have data in flash. Switching to GUI_DU_LIEU_MQTT state.");
                    currentState = GUI_DU_LIEU_MQTT;
                }
                break;

            case SEND_FLASH_DATA:
                static unsigned long lastFlashSendTime = 0;
                if (millis() - lastFlashSendTime > 1000) { // Gửi dữ liệu từ SPIFFS mỗi 500ms
                    lastFlashSendTime = millis();
                    if (!sendSavedDataToMQTT()) {
                        currentState = GUI_DU_LIEU_MQTT;
                    }
                }
                break;

            case GUI_DU_LIEU_MQTT:
                if (isWifiConnected) {
                    client.loop();
                }
                break;

            case CHE_DO_BLE:
                if (isWifiConnected) {
                    WiFi.disconnect();
                    isWifiConnected = false;
                }
                initBLE();
                currentState = KET_NOI_BLE;
                break;

            case CHE_DO_AP:
                stopBLE();
                enableAccessPoint();
                break;

            case CHE_DO_LAN:
                stopBLE();
                enableLAN();
                break;

            default:
                currentState = CHUA_CO_KET_NOI;
                break;
        }
        lastUpdateTime = millis();
    }
}
