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
const char* mqtt_server = "f69f6416905b4890a65c0d638608cfff.s1.eu.hivemq.cloud";
const int   mqtt_port = 8883;
const char* mqtt_username = "test";
const char* mqtt_password = "1";

WiFiClientSecure   wifiClient;
PubSubClient       client(wifiClient);
AsyncWebServer     server(80);

//-----------------------------------
// Cấu hình cảm biến lưu lượng nước
//-----------------------------------
#define FLOW_SENSOR_PIN GPIO_NUM_4  // Chân GPIO 4 vừa đọc xung, vừa đánh thức thiết bị
#define WAKE_GPIO_PIN   GPIO_NUM_5

volatile int   pulseCount = 0;
float          flowRate = 0.0;

unsigned long  lastPublishTime = 0;
const unsigned long publishInterval = 2000; // 2 giây

unsigned long noWaterStartTime = 0;
const unsigned long noWaterDuration = 10 * 60 * 1000;
bool noWaterDetected = false;

const float NO_WATER_THRESHOLD = 0.1; 

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
    NHAN_THONG_TIN_WIFI,
    KET_NOI_WIFI_THANH_CONG,
    GUI_DU_LIEU_MQTT,
    CHE_DO_BLE,
    CHE_DO_LAN,
    CHE_DO_AP
};

State currentState = CHUA_CO_KET_NOI;

//-----------------------------------
// Lớp callback BLE để nhận thông tin WiFi
//-----------------------------------
class MyCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue().c_str();
        if (value.startsWith("ssid:") && value.indexOf(",psw:") != -1) {
            int ssidStart = value.indexOf("ssid:") + 5;
            int pswStart = value.indexOf(",psw:") + 5;
            if (ssidStart < pswStart - 5 && pswStart < value.length()) {
                String ssid = value.substring(ssidStart, pswStart - 5);
                String password = value.substring(pswStart);

                WiFi.begin(ssid.c_str(), password.c_str());
                currentState = NHAN_THONG_TIN_WIFI;
            }
        }
    }
};

//-----------------------------------
// Ngắt đếm xung lưu lượng nước
//-----------------------------------
void IRAM_ATTR pulseCounter() {
    pulseCount++;
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
    client.setServer(mqtt_server, mqtt_port);
    client.setCallback(mqttCallback);

    int retries = 0;
    const int maxRetries = 10;
    while (!client.connected() && retries < maxRetries) {
        if (client.connect("ESP32Client", mqtt_username, mqtt_password)) {
            client.subscribe("command");
        } else {
            retries++;
            delay(2000);
        }
    }

    if (retries >= maxRetries) {
        Serial.println("MQTT connection failed. Rebooting...");
        ESP.restart();
    }
}

//-----------------------------------
// Bật Access Point
//-----------------------------------
void enableAccessPoint() {
    if (!apEnabled) {
        WiFi.softAP("ESP32-AP", "12345678");
        Serial.println("Access Point enabled.");
        apEnabled = true;
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
// Lưu dữ liệu vào SPIFFS khi mất kết nối
//-----------------------------------
void saveDataToSPIFFS(const String& data) {
    File file = SPIFFS.open("/data.log", FILE_APPEND);
    if (!file) {
        Serial.println("Failed to open file for appending");
        return;
    }
    file.println(data);
    file.close();
}

//-----------------------------------
// Đọc và gửi dữ liệu SPIFFS khi WiFi trở lại
//-----------------------------------
void sendDataFromSPIFFS() {
    File file = SPIFFS.open("/data.log", FILE_READ);
    if (!file) {
        Serial.println("Failed to open file for reading");
        return;
    }

    while (file.available()) {
        String line = file.readStringUntil('\n');
        if (client.publish("datawater", line.c_str())) {
            Serial.println("Sent data: " + line);
        } else {
            Serial.println("Failed to send data");
            break;
        }
    }
    file.close();
    SPIFFS.remove("/data.log");
}

//-----------------------------------
// Gửi dữ liệu lưu lượng nước qua MQTT
//-----------------------------------
void publishWaterFlow() {
    flowRate = (pulseCount / 450.0) * 30.0;  
    pulseCount = 0;

    String flowMessage = String(flowRate);
    if (isWifiConnected && client.connected()) {
        if (!client.publish("datawater", flowMessage.c_str())) {
            Serial.println("Failed to send MQTT message. Saving to SPIFFS.");
            saveDataToSPIFFS(flowMessage);
        }
    } else {
        saveDataToSPIFFS(flowMessage);
    }

    if (flowRate < NO_WATER_THRESHOLD) {
        if (!noWaterDetected) {
            noWaterStartTime = millis();
            noWaterDetected = true;
        } else if (millis() - noWaterStartTime > noWaterDuration) {
            Serial.println("No water detected for 10 minutes, entering Sleep Mode...");
            esp_sleep_enable_ext0_wakeup(FLOW_SENSOR_PIN, 1);
            esp_deep_sleep_start();
        }
    } else {
        noWaterDetected = false; 
    }
}

//-----------------------------------
// Khởi tạo BLE
//-----------------------------------
void initBLE() {
    if (!BLEDevice::getInitialized()) {
        BLEDevice::init("XIAO_ESP32S3");
    }
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
    initBLE();
    currentState = KET_NOI_BLE;
}

//-----------------------------------
// Setup
//-----------------------------------
void setup() {
    Serial.begin(115200);
    pinMode(FLOW_SENSOR_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, FALLING);

    if (!SPIFFS.begin(true)) {
        Serial.println("An Error has occurred while mounting SPIFFS");
        return;
    }

    currentState = CHUA_CO_KET_NOI;
}

//-----------------------------------
// Loop
//-----------------------------------
void loop() {
    switch (currentState) {
        case CHUA_CO_KET_NOI:
            handleStateCHUA_CO_KET_NOI();
            break;
        case KET_NOI_BLE:
            delay(100);
            break;
        case NHAN_THONG_TIN_WIFI: {
            int attempts = 0;
            while (WiFi.status() != WL_CONNECTED && attempts < 20) {
                delay(500);
                attempts++;
            }
            isWifiConnected = (WiFi.status() == WL_CONNECTED);

            if (isWifiConnected) {
                stopBLE();
                wifiPreviouslyConnected = true;
                sendDataFromSPIFFS();
                currentState = KET_NOI_WIFI_THANH_CONG;
            } else {
                currentState = KET_NOI_BLE; 
            }
            break;
        }
        case KET_NOI_WIFI_THANH_CONG:
            if (!client.connected()) {
                connectToMqtt();
            }
            currentState = GUI_DU_LIEU_MQTT;
            break;
        case GUI_DU_LIEU_MQTT:
            if (millis() - lastPublishTime > publishInterval) {
                lastPublishTime = millis();
                publishWaterFlow();
            }
            client.loop();
            delay(100);
            break;
        case CHE_DO_BLE:
            if (isWifiConnected) {
                WiFi.disconnect();
                isWifiConnected = false;
            }
            initBLE();
            currentState = KET_NOI_BLE;
            break;
        case CHE_DO_LAN:
            if (!isWifiConnected) {
                WiFi.begin("MyLAN_SSID", "MyLAN_PWD");
                int attempts = 0;
                while (WiFi.status() != WL_CONNECTED && attempts < 20) {
                    delay(500);
                    attempts++;
                }
                isWifiConnected = (WiFi.status() == WL_CONNECTED);
            }

            if (isWifiConnected) {
                stopBLE();
                sendDataFromSPIFFS();
                currentState = GUI_DU_LIEU_MQTT;
            } else {
                currentState = KET_NOI_BLE;
            }
            break;
        case CHE_DO_AP:
            enableAccessPoint();
            delay(5000); 
            disableAccessPoint();
            currentState = GUI_DU_LIEU_MQTT;
            break;
        default:
            currentState = CHUA_CO_KET_NOI;
            break;
    }
}
