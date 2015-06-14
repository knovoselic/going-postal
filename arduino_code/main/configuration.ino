#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <DNSServer.h>
#include "FlashStream.h"

extern "C" {
#include <user_interface.h>
}

const byte DNS_PORT = 53;
IPAddress apIP(192, 168, 144, 1);
DNSServer dnsServer;
ESP8266WebServer webServer(80);
String domainName = "going-postal.config";

void handleNotFound()
{
  Serial.println(webServer.uri());
  if (webServer.uri() == "/favicon.ico")
  {
    webServer.send(404, "text/plain", "<h1>Not found.</h1>");
  } else {
    webServer.sendHeader("Location", "http://" + domainName, true);
    webServer.send(301, "", "");
  }
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
  webServer.on ( "/", []() {
    FlashStream htmlStream((PGM_P)html);
    webServer.streamFile(htmlStream, "text/html");
  } );

  webServer.begin();
  Serial.println("Done.");
}
int start, duration;
void configurationLoop() {
  start = millis();
  dnsServer.processNextRequest();
  duration = millis() - start;
  if (duration > 2)
  {
    Serial.print("DNS took: ");
    Serial.print(duration);
    Serial.println("ms.");
  }
  start = millis();
  webServer.handleClient();
  duration = millis() - start;
  if (duration > 2)
  {
    Serial.print("Web took: ");
    Serial.print(duration);
    Serial.println("ms.");
  }
}
