#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <DNSServer.h>
#include "FlashStream.h"
#include <EEPROM.h>

extern "C" {
#include <user_interface.h>
}

const byte DNS_PORT = 53;
IPAddress apIP(192, 168, 144, 1);
DNSServer dnsServer;
ESP8266WebServer webServer(80);
String domainName = "going-postal.config";
long shouldRestart = 0;

void handleNotFound()
{
  if (webServer.uri() == "/favicon.ico" || webServer.method() != HTTP_GET)
  {
    webServer.send(418, "text/plain", "No coffee for you!");
  } else {
    webServer.sendHeader("Location", "http://" + domainName, true);
    webServer.send(301, "", "");
  }
}

void handleIndex()
{
  FlashStream htmlStream((PGM_P)html);
  webServer.streamFile(htmlStream, "text/html");
}

void validateWiFiConfig()
{
  String ssid = webServer.arg("ssid");
  ssid.trim();
  if (ssid == "")
  {
    webServer.send(422, "text/plain", "SSID can not be empty!");
  }
  String password = webServer.arg("password");

  if (password == "")
  {
    WiFi.begin(ssid.c_str());
  } else {
    WiFi.begin(ssid.c_str(), password.c_str());
  }
  webServer.send(200, "text/plain", "");
  Serial.println("config done");
}

void getWiFiStatus()
{
  int status = WiFi.status();
  Serial.println("got status");
  Serial.println(status);
  switch(status)
  {
    case WL_DISCONNECTED:
      webServer.send(202, "text/plain", "");
      return;
    case WL_CONNECTED:
    {
      saveConfigAndRestart();
      shouldRestart = millis();
      Serial.println("Count start");
      webServer.send(200, "text/plain", "Success.");
      return;
    }
    case WL_NO_SSID_AVAIL:
    {
      String ssid = webServer.arg("ssid");
      ssid.trim();
      webServer.send(503, "text/plain", "Could not find a WiFi network named \""
      + ssid + "\". Please check your input and try agian.");
      break;
    }
    case WL_CONNECT_FAILED:
    case WL_CONNECTION_LOST:
      webServer.send(503, "text/plain", "Unable to connect to WiFi. Please make"
      " sure that provided name and password are correct and try again.");
      break;
    default:
      webServer.send(503, "text/plain", "Unknown error has happened. Please try"
      " again later.");
      break;
  }
  // if error has happened, remove SSID and password from config memory
  WiFi.disconnect();
}

void saveConfigAndRestart()
{
  EEPROM.begin(1);
  EEPROM.write(0, (int)BootMode::Sensor);
  EEPROM.end();
}

void configurationSetup() {
  Serial.begin(115200);
  Serial.println();

  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();

  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));
  WiFi.softAP("GoingPostal configuration");

  dnsServer.setErrorReplyCode(DNSReplyCode::ServerFailure);
  dnsServer.start(DNS_PORT, domainName, apIP);

  webServer.onNotFound(handleNotFound);
  webServer.on("/", HTTP_GET, handleIndex);
  webServer.on("/wifi/config", HTTP_POST, validateWiFiConfig);
  webServer.on("/wifi/status", HTTP_POST, getWiFiStatus);
  webServer.begin();

  Serial.println("Configuration setup done.");
}

void configurationLoop() {
  if (shouldRestart && (millis() - shouldRestart) > 5000)
  {
    Serial.println("Restarting");
    shouldRestart = 0;
    ESP.reset();
  }
  measure("DNS", []() { dnsServer.processNextRequest(); });
  measure("Web", []() { webServer.handleClient(); });
}
