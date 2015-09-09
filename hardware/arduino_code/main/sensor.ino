unsigned long restartPressed = 0;
const short RESTART_DURATION = 5000;
short threshold = 0;
byte hasMailPrevious = 0;
WiFiClient client;

void sensorSetup() {
  pinMode(13, INPUT);

  WiFi.mode(WIFI_STA);
  Serial.println("Calibrating...");
  short value;
  for(int i = 0; i < 20; i++)
  {
    value = system_adc_read();
    if (value > threshold)
    {
      threshold = value;
    }
    delay(50);
  }
  threshold += 5;
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
  if (value > threshold)
  {
    if (!hasMailPrevious)
    {
      Serial.println("You've got mail!");
      //sendEmail();
    }
    hasMailPrevious = 5;
  }
  else if (hasMailPrevious > 0)
  {
    --hasMailPrevious;
  }
  Serial.print(value);
  Serial.print("|");
  Serial.print(hasMailPrevious);
  Serial.println();
  resetButtonLoop();
  delay(100);
}

void sendEmail()
{
  long start = millis();
  if (client.connect("going-postal.me", 80)) {
    client.print("POST /api/test/email HTTP/1.1\r\n");
    client.print("Host: going-postal.me\r\n");
    client.print("Connection: close\r\n");
    client.print("Content-Type: application/json\r\n");
    client.print("Content-Length: 0\r\n\r\n");

    Serial.println("JSON request sent successfully.");
    client.setTimeout(1);
    while(client.connected()) {
      String line = client.readStringUntil('\r');
      Serial.print(line);
    }

  }
  client.stop();
  Serial.println(millis() - start);
}
