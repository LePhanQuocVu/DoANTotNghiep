#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <WiFiClientSecure.h>
#include <ESPAsyncWebServer.h>
#include <esp_sleep.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// MQTT Configuration
const char* mqtt_server = "f69f6416905b4890a65c0d638608cfff.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;
const char* mqtt_username = "test";
const char* mqtt_password = "1";

WiFiClientSecure wifiClient;
PubSubClient client(wifiClient);
AsyncWebServer server(80);

#define FLOW_SENSOR_PIN GPIO_NUM_4  // Pin cảm biến lưu lượng nước
#define WAKE_GPIO_PIN GPIO_NUM_5   // Pin kích hoạt thoát Sleep Mode

volatile int pulseCount = 0;  // Đếm xung từ cảm biến lưu lượng nước
float flowRate = 0.0;         // Lưu tốc độ dòng chảy
bool isWifiConnected = false;
bool apEnabled = false;       // Trạng thái của Access Point

unsigned long lastPublishTime = 0;
const unsigned long publishInterval = 2000; // 2 giây

unsigned long noWaterStartTime = 0;  // Thời gian bắt đầu không có nước
const unsigned long noWaterDuration = 10 * 60 * 1000; // 10 phút (đơn vị: ms)

bool noWaterDetected = false; // Cờ theo dõi trạng thái không có nước
bool bleEnabled = true; // Trạng thái BLE
bool wifiPreviouslyConnected = false; // Trạng thái Wi-Fi trước đó

// BLE callback xử lý cấu hình Wi-Fi
class MyCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        String value = pCharacteristic->getValue().c_str();
        if (value.startsWith("ssid:") && value.indexOf(",psw:") != -1) {
            int ssidStart = value.indexOf("ssid:") + 5;
            int pswStart = value.indexOf(",psw:") + 5;
            String ssid = value.substring(ssidStart, pswStart - 5);
            String password = value.substring(pswStart);

            WiFi.begin(ssid.c_str(), password.c_str());
            int attempts = 0;
            while (WiFi.status() != WL_CONNECTED && attempts < 20) {
                delay(500);
                attempts++;
            }

            isWifiConnected = (WiFi.status() == WL_CONNECTED);
        }
    }
};

// Đếm xung từ cảm biến lưu lượng
void IRAM_ATTR pulseCounter() {
    pulseCount++;
}

// MQTT callback
void mqttCallback(char* topic, byte* message, unsigned int length) {
    String receivedTopic = String(topic);
    String messageValue;

    for (unsigned int i = 0; i < length; i++) {
        messageValue += (char)message[i];
    }

    if (receivedTopic == "enable AC") {
        if (messageValue == "1") {
            enableAccessPoint();
        } else {
            disableAccessPoint();
        }
    }
}

// Kết nối MQTT
void connectToMqtt() {
    client.setServer(mqtt_server, mqtt_port);
    while (!client.connected()) {
        if (client.connect("ESP32Client", mqtt_username, mqtt_password)) {
            client.subscribe("enable AC");
        } else {
            delay(2000);
        }
    }
}

// Bật Access Point
void enableAccessPoint() {
    if (!apEnabled) {
        WiFi.softAP("ESP32-AP", "12345678");
        Serial.println("Access Point enabled.");
        apEnabled = true;
    }
}

// Tắt Access Point
void disableAccessPoint() {
    if (apEnabled) {
        WiFi.softAPdisconnect(true);
        Serial.println("Access Point disabled.");
        apEnabled = false;
    }
}

// Gửi dữ liệu lưu lượng nước qua MQTT
void publishWaterFlow() {
    flowRate = (pulseCount / 450.0) * 60.0;  // Tính lưu lượng
    pulseCount = 0;

    String flowMessage = String(flowRate);
    if (isWifiConnected && client.connected()) {
        client.publish("datawater", flowMessage.c_str());
    }

    // Kiểm tra trạng thái không có nước
    if (flowRate < 0.1) {
        if (!noWaterDetected) {
            noWaterStartTime = millis(); // Ghi lại thời gian bắt đầu không có nước
            noWaterDetected = true;
        } else if (millis() - noWaterStartTime > noWaterDuration) {
            Serial.println("No water detected for 10 minutes, entering Sleep Mode...");
            esp_sleep_enable_ext0_wakeup(WAKE_GPIO_PIN, 1);  // Thức dậy khi có tín hiệu GPIO
            esp_deep_sleep_start();
        }
    } else {
        noWaterDetected = false; // Reset cờ nếu phát hiện có nước
    }
}

void manageBLEandWiFi() {
    // Kiểm tra kết nối Wi-Fi
    bool wifiCurrentlyConnected = (WiFi.status() == WL_CONNECTED);

    if (wifiCurrentlyConnected && !wifiPreviouslyConnected) {
        // Nếu Wi-Fi mới được kết nối, tắt BLE
        if (bleEnabled) {
            BLEDevice::deinit();
            bleEnabled = false;
            Serial.println("Wi-Fi connected. BLE disabled.");
        }
    } else if (!wifiCurrentlyConnected && wifiPreviouslyConnected) {
        // Nếu Wi-Fi bị ngắt, bật lại BLE
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
            Serial.println("Wi-Fi disconnected. BLE enabled.");
        }
    }

    // Cập nhật trạng thái Wi-Fi trước đó
    wifiPreviouslyConnected = wifiCurrentlyConnected;
}

void setup() {
    Serial.begin(115200);

    pinMode(FLOW_SENSOR_PIN, INPUT_PULLUP);
    pinMode(WAKE_GPIO_PIN, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, FALLING);

    // BLE Configuration
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

    // MQTT Configuration
    client.setCallback(mqttCallback);

    // Wi-Fi Auto-Connect
    WiFi.begin();
    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
        delay(500);
        attempts++;
    }

    isWifiConnected = (WiFi.status() == WL_CONNECTED);
    wifiPreviouslyConnected = isWifiConnected;

    if (isWifiConnected) {
        BLEDevice::deinit(); // Tắt BLE khi Wi-Fi hoạt động
        bleEnabled = false;
        Serial.println("Wi-Fi connected during setup. BLE disabled.");
    }
}

void loop() {
    // Quản lý BLE và Wi-Fi
    manageBLEandWiFi();

    // Xử lý MQTT
    if (isWifiConnected) {
        if (!client.connected()) {
            connectToMqtt();
        }
        client.loop();
    }

    // Gửi dữ liệu mỗi 2 giây
    if (millis() - lastPublishTime > publishInterval) {
        lastPublishTime = millis();
        publishWaterFlow();
    }
}
