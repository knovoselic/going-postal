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
IPAddress apIP(172, 20, 251, 1);
IPAddress apNetmask(255, 255, 255, 248);
DNSServer dnsServer;
ESP8266WebServer webServer(80);
String domainName = "going-postal.config";
long shouldRestart = 0;
short wifiStatus;

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
  ETS_UART_INTR_DISABLE();
  FlashStream htmlStream((PGM_P)html, "index.html");
  webServer.streamFile(htmlStream, "text/html");
  ETS_UART_INTR_ENABLE();
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

  wifiStatus = -1;
  webServer.send(200, "text/plain", "");
  delay(1000);
  if (password == "")
  {
    WiFi.begin(ssid.c_str());
  } else {
    WiFi.begin(ssid.c_str(), password.c_str());
  }
}

void getWiFiStatus()
{
  if (wifiStatus == -1)
  {
    wifiStatus = WiFi.waitForConnectResult();
  }
  IPAddress result;
  switch(wifiStatus)
  {
    case WL_CONNECTED:
      webServer.send(200, "text/plain", "");
      setBootMode(BootMode::Sensor);
      return;
    case WL_NO_SSID_AVAIL:
      webServer.send(503, "text/plain", "Could not find specified WiFi network."
      " Please check your input and try again.");
      break;
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

void configurationSetup() {
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();

  WiFi.softAPConfig(apIP, apIP, apNetmask);
  WiFi.softAP("GoingPostal configuration");

  dnsServer.setTTL(60 * 60);
  dnsServer.setErrorReplyCode(DNSReplyCode::ServerFailure);
  dnsServer.start(DNS_PORT, domainName, apIP);

  webServer.onNotFound(handleNotFound);
  webServer.on("/", HTTP_GET, handleIndex);
  webServer.on("/wifi/config", HTTP_POST, validateWiFiConfig);
  webServer.on("/wifi/status", HTTP_POST, getWiFiStatus);
  webServer.on("/restart", HTTP_POST, [](){
    webServer.send(200, "text/plain", "OK.");
    delay(1000);
    ESP.restart();
  });
  webServer.begin();

  Serial.println("Configuration setup done.");
}

void configurationLoop() {
  dnsServer.processNextRequest();
  webServer.handleClient();
}
