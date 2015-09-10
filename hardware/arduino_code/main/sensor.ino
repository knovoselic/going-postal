#include <algorithm>

unsigned long restartPressed = 0;
const short RESTART_DURATION = 5000;
const byte TOLERANCE = 12;
short threshold = 0;
byte hasMailPrevious = 0;
WiFiClient client;
const byte MAX_SAMPLES = 21;
short values[MAX_SAMPLES] = {0};
byte _currentIndex = 0;

byte currentIndex()
{
  return (_currentIndex = (_currentIndex + 1) % MAX_SAMPLES);
}

short medianValue()
{
  short copy[MAX_SAMPLES] = {0};
  memcpy(copy, values, sizeof(values));
  std::sort(std::begin(copy), std::end(copy));
  return copy[MAX_SAMPLES / 2];
}

void sensorSetup() {
  pinMode(13, INPUT);

  WiFi.mode(WIFI_STA);
  wifi_station_disconnect();

  Serial.println("Calibrating...");
  short value;
  for(int i = 0; i < MAX_SAMPLES; i++)
  {
    value = system_adc_read();
    Serial.print(value);
    Serial.print(' ');
    values[currentIndex()] = value;
    delay(100);
  }
  threshold = medianValue() + TOLERANCE;

  Serial.println();
  Serial.print("Threshold is ");
  Serial.print(threshold);
  Serial.println(".");
  Serial.println("Sensor setup done.");
}

void resetButtonLoop()
{
  if (digitalRead(13) == LOW)
  {
    if (!restartPressed)
    {
      restartPressed = millis();
    }
    else if (millis() - restartPressed > RESTART_DURATION)
    {
      setBootMode(BootMode::Configuration);
      ESP.restart();
    }
  } else {
    restartPressed = 0;
  }
}

void sensorLoop() {
  short value = system_adc_read();
  values[currentIndex()] = value;
  if (medianValue() > threshold)
  {
    if (!hasMailPrevious)
    {
      Serial.println("You've got mail!");
      sendEmail();
    }
    hasMailPrevious = 5;
  }
  else if (hasMailPrevious > 0)
  {
    --hasMailPrevious;
  }
  Serial.print(value);
  Serial.print(' ');
  Serial.print(medianValue());
  Serial.print("|");
  Serial.print(hasMailPrevious);
  Serial.println();
  resetButtonLoop();
  delay(100);
}

void sendEmail()
{
  wifi_station_connect();
  Serial.println("Waiting for WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(250);
  };
  Serial.println("\nWiFi successfully connected.");

  long start = millis();
  if (client.connect("going-postal.me", 80)) {
    String data = "{\"device_key\": \"8dc36053-d69e-4813-8f8c-afe9c7557071\",\"event\": {\"type\": \"item_received\"}}";
    client.print("POST /api/v1/events HTTP/1.1\r\n");
    client.print("Host: going-postal.me\r\n");
    client.print("Connection: close\r\n");
    client.print("Content-Type: application/json\r\n");
    client.print("Content-Length: ");
    client.print(data.length());
    client.print("\r\n\r\n");
    client.print(data);
    client.print("\r\n");

    Serial.println("JSON request sent successfully.");
    while(client.connected()) {
      String line = client.readStringUntil('\r');
      Serial.print(line);
    }
  }
  client.stop();
  delay(1000);
  wifi_station_disconnect();
  Serial.println(millis() - start);
  delay(4000);
}
