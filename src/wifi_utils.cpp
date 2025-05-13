#include "wifi_utils.h"
#include "states.h"
#include <PubSubClient.h>
#include <vector>

// Biến extern từ main
extern float total_water_monthly;
extern AsyncWebServer server;
extern bool apEnabled;
extern bool isWifiConnected;
extern String ssid_new, password_new;
extern State currentState;

// MQTT extern
extern PubSubClient client;

// --------------------------------
// Lưu / đọc / xóa WiFi credentials
// --------------------------------
void saveWiFiCredentials(const String &ssid, const String &password)
{
    File file = SPIFFS.open("/wifi.txt", FILE_WRITE);
    if (!file)
    {
        Serial.println("Failed to open file for writing WiFi credentials");
        return;
    }
    file.println(ssid);
    file.println(password);
    file.close();
    Serial.println("WiFi credentials saved to SPIFFS.");
}

bool loadWiFiCredentials(String &ssid, String &password)
{
    File file = SPIFFS.open("/wifi.txt", FILE_READ);
    if (!file)
    {
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

void clearWiFiCredentials()
{
    if (SPIFFS.remove("/wifi.txt"))
    {
        Serial.println("WiFi credentials cleared from SPIFFS.");
    }
    else
    {
        Serial.println("Failed to clear WiFi credentials.");
    }
}

// --------------------------------
// Xử lý state KET_NOI_WIFI
// --------------------------------
void handleStateKET_NOI_WIFI()
{
    static unsigned long startAttemptTime = 0;
    static bool connectingNew = false;
    static bool tryingSaved = false;

    if (!connectingNew && !tryingSaved)
    {
        Serial.println("State: Connecting to WiFi with new credentials...");
        WiFi.disconnect(true);
        WiFi.begin(ssid_new.c_str(), password_new.c_str());
        startAttemptTime = millis();
        connectingNew = true;
    }

    if (connectingNew)
    {
        if (WiFi.status() == WL_CONNECTED)
        {
            Serial.println("\nConnected to WiFi successfully with new credentials.");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
            saveWiFiCredentials(ssid_new, password_new);
            currentState = KET_NOI_WIFI_THANH_CONG;
            connectingNew = false;
        }
        else if (millis() - startAttemptTime > 10000)
        {
            Serial.println("Failed to connect with new credentials. Trying saved credentials...");
            String savedSSID, savedPassword;
            if (loadWiFiCredentials(savedSSID, savedPassword))
            {
                ssid_new = savedSSID;
                password_new = savedPassword;
                WiFi.disconnect(true);
                WiFi.begin(ssid_new.c_str(), password_new.c_str());
                startAttemptTime = millis();
                connectingNew = false;
                tryingSaved = true;
            }
            else
            {
                Serial.println("No saved WiFi credentials found. Returning to BLE mode.");
                currentState = CHUA_CO_KET_NOI;
                connectingNew = false;
            }
        }
    }
    else if (tryingSaved)
    {
        if (WiFi.status() == WL_CONNECTED)
        {
            Serial.println("\nConnected to WiFi using saved credentials.");
            Serial.print("IP Address: ");
            Serial.println(WiFi.localIP());
            currentState = KET_NOI_WIFI_THANH_CONG;
            tryingSaved = false;
        }
        else if (millis() - startAttemptTime > 10000)
        {
            Serial.println("\nFailed to connect to WiFi with saved credentials. Returning to BLE mode.");
            currentState = CHUA_CO_KET_NOI;
            tryingSaved = false;
        }
    }
}

// --------------------------------
// Bật/Tắt Access Point
// --------------------------------
void enableAccessPoint()
{
    if (!apEnabled)
    {
        WiFi.softAP("ESP32-AP", "12345678");
        IPAddress apIP = WiFi.softAPIP();
        Serial.println("Access Point enabled. AP IP: " + apIP.toString());
        apEnabled = true;

        server.on("/", HTTP_GET, [](AsyncWebServerRequest *request)
                  {
            String htmlPage = "<html><head><meta name='viewport' content='width=device-width, initial-scale=1'>";
            htmlPage += "<style>body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; } ";
            htmlPage += "form { display: inline-block; background-color: #f9f9f9; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }";
            htmlPage += "input[type='text'], input[type='password'] { width: 90%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px; }";
            htmlPage += "input[type='submit'] { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }";
            htmlPage += "input[type='submit']:hover { background-color: #45a049; }";
            htmlPage += "</style></head><body>";
            htmlPage += "<h2>Connect to WiFi</h2>";
            // Phần hiển thị tổng lượng nước tháng:
            htmlPage += "<p><b>Total water usage this month:</b> " + String(total_water_monthly) + " liters</p>";
            // Form kết nối WiFi:
            htmlPage += "<form action=\"/connect\" method=\"post\">";
            htmlPage += "SSID: <input type=\"text\" name=\"ssid\"><br>";
            htmlPage += "Password: <input type=\"password\" name=\"password\"><br>";
            htmlPage += "<input type=\"submit\" value=\"Connect\">";
            htmlPage += "</form>";
            htmlPage += "</body></html>";

            request->send(200, "text/html", htmlPage); });

        server.on("/connect", HTTP_POST, [](AsyncWebServerRequest *request)
                  {
            String ssid     = "";
            String password = "";
            if (request->hasParam("ssid", true) && request->hasParam("password", true))
            {
                ssid     = request->getParam("ssid", true)->value();
                password = request->getParam("password", true)->value();
            }

            if (!ssid.isEmpty() && !password.isEmpty())
            {
                ssid_new     = ssid;
                password_new = password;
                disableAccessPoint();
                currentState = KET_NOI_WIFI;
            }
            else
            {
                request->send(200, "text/plain", "Invalid credentials format.");
            } });

        server.begin();
    }
}

void disableAccessPoint()
{
    if (apEnabled && WiFi.softAPgetStationNum() == 0)
    {
        WiFi.softAPdisconnect(true);
        Serial.println("Access Point disabled.");
        apEnabled = false;
    }
}

// --------------------------------
// LAN mode
// --------------------------------
void enableLAN()
{
    // Serial.println("LAN Mode");
    server.on("/", HTTP_GET, [](AsyncWebServerRequest *request)
              { request->send(200, "text/html",
                              "<html><body><h2>Connect to WiFi - LAN Mode</h2>"
                              "<form action=\"/connect\" method=\"post\">"
                              "SSID: <input type=\"text\" name=\"ssid\"><br>"
                              "Password: <input type=\"password\" name=\"password\"><br>"
                              "<input type=\"submit\" value=\"Connect\">"
                              "</form></body></html>"); });

    server.on("/connect", HTTP_POST, [](AsyncWebServerRequest *request)
              {
        String ssid     = "";
        String password = "";
        if (request->hasParam("ssid", true) && request->hasParam("password", true)) {
            ssid     = request->getParam("ssid", true)->value();
            password = request->getParam("password", true)->value();
        }
        if (!ssid.isEmpty() && !password.isEmpty()) {
            ssid_new     = ssid;
            password_new = password;
            currentState = KET_NOI_WIFI;
        } else {
            request->send(200, "text/plain", "Invalid credentials format.");
        } });

    server.begin();
}

// --------------------------------
// Lưu/Gửi Data qua SPIFFS
// --------------------------------
void saveDataToSPIFFS(const String &data)
{
    File file = SPIFFS.open("/data.log", FILE_READ);
    std::vector<String> lines;
    if (file)
    {
        while (file.available())
        {
            lines.push_back(file.readStringUntil('\n'));
        }
        file.close();
    }
    else
    {
        Serial.println("Failed to open file for reading first time.");
    }

    if (lines.size() >= 20)
    {
        lines.erase(lines.begin());
    }
    lines.push_back(data);
    Serial.println("Saved to SPIFFS: " + data);

    file = SPIFFS.open("/data.log", FILE_WRITE);
    if (!file)
    {
        Serial.println("Failed to open file for writing");
        return;
    }
    for (auto &l : lines)
    {
        file.println(l);
    }
    file.close();
}

bool sendSavedDataToMQTT()
{
    static File file = SPIFFS.open("/data.log", FILE_READ);
    if (!file)
    {
        Serial.println("Failed to open file for reading");
        return false;
    }
    if (!file.available())
    {
        Serial.println("No more data in flash to send.");
        file.close();
        SPIFFS.remove("/data.log");
        return false;
    }
    String line = file.readStringUntil('\n');
    if (line.length() > 0)
    {
        if (client.publish("datawater", line.c_str()))
        {
            Serial.println("Sent flash data: " + line);
        }
        else
        {
            Serial.println("Failed to send flash data: " + line);
            file.close();
            return false;
        }
    }
    return true;
}

void publishFlowRate(float flowRate)
{
    if (flowRate >= 1.5)
    {
        String flowMessage = String(flowRate);
        Serial.println("Publishing flow rate: " + flowMessage);
        if (!client.publish("datawater", flowMessage.c_str()))
        {
            Serial.println("Failed to send MQTT. Saving to SPIFFS.");
            saveDataToSPIFFS(flowMessage);
        }
        else
        {
            Serial.println("Sent to topic Datawater: " + flowMessage);
        }
    }
}
