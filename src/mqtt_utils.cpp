#include "mqtt_utils.h"
#include <PubSubClient.h>
#include "ota_utils.h"    
#include "states.h"

// Biến, enum từ main.cpp
extern State        currentState;
extern PubSubClient client;
extern const char*  mqtt_server;
extern int          mqtt_port;
extern const char*  mqtt_username;
extern const char*  mqtt_password;
extern String       id_new;

// URL firmware OTA
static const char* OTA_URL = "http://192.168.43.171:3000/firmwares/firmware-v0.bin";

// Đăng ký subscribe cho các sub‑topic của /data/<id_new>/
static void subscribeDeviceTopics() {
    if (id_new.length() == 0) return;
    String base = "data/" + id_new + "/";

    String cmdTopic = base + "command";
    client.subscribe(cmdTopic.c_str());
    Serial.printf("Subscribed to %s\n", cmdTopic.c_str());

    String otaTopic = base + "ota";
    client.subscribe(otaTopic.c_str());
    Serial.printf("Subscribed to %s\n", otaTopic.c_str());
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
    String receivedTopic = String(topic);
    String messageValue;
    for (unsigned int i = 0; i < length; i++) {
        messageValue += (char)payload[i];
    }
    Serial.printf("MQTT >> topic: %s, payload: %s\n",
                  receivedTopic.c_str(), messageValue.c_str());

    const String prefix = "data/" + id_new + "/";
    if (receivedTopic.startsWith(prefix)) {
        String sub = receivedTopic.substring(prefix.length());

        if (sub == "command") {
            if (messageValue == "AC") {
                currentState = CHE_DO_AP;
            } else if (messageValue == "BLE") {
                currentState = CHE_DO_BLE;
            } else if (messageValue == "LAN") {
                currentState = CHE_DO_LAN;
            }
        }
        else if (sub == "ota") {
            // Chỉ thực thi OTA khi payload đúng "1"
            if (messageValue == "1") {
                Serial.println(">>> OTA trigger received with payload=1, starting HTTP OTA update");
                performHttpOtaUpdate(OTA_URL);
            } else {
                Serial.println(">>> OTA payload != 1, skipping update");
            }
        }
    }
}

void connectToMqtt() {
    static unsigned long lastAttemptTime = 0;

    client.setServer(mqtt_server, mqtt_port);
    client.setCallback(mqttCallback);

    if (client.connected()) {
        subscribeDeviceTopics();
        return;
    }

    if (millis() - lastAttemptTime < 2000) {
        return;
    }
    lastAttemptTime = millis();

    Serial.println("Attempting to connect to MQTT...");
    if (client.connect("ESP32Client", mqtt_username, mqtt_password)) {
        Serial.println("MQTT connected.");
        subscribeDeviceTopics();
    } else {
        Serial.printf("Failed to connect to MQTT, rc=%d\n", client.state());
    }
}
