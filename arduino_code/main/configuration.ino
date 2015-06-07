#include <ESP8266WiFi.h>
#include <DNSServer.h>
extern "C" {
#include <user_interface.h>
}

const byte DNS_PORT = 53;
IPAddress apIP(192, 168, 144, 1);
DNSServer dnsServer;

void configurationSetup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP_STA);
  WiFi.disconnect();

  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0));
  WiFi.softAP("GoingPostal configuration");

  dnsServer.setErrorReplyCode(DNSReplyCode::ServerFailure);
  dnsServer.start(DNS_PORT, "going-postal.config", apIP);
}

void configurationLoop() {
  dnsServer.processNextRequest();
}
