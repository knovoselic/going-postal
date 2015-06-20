#include <pgmspace.h>
#include <EEPROM.h>

enum class BootMode
{
  Configuration = 0,
  Sensor = 1
};

void (*loopFunction)();

void setup() {
  loopFunction = &configurationLoop;
  configurationSetup();
  EEPROM.begin(1);
  int x = EEPROM.read(0);
  switch(x)
  {
    case (int)BootMode::Configuration:
      Serial.println("Configuration");
      break;
    case (int)BootMode::Sensor:
      Serial.println("Sensor");
      break;
    default:
      Serial.println(x);
  }
  EEPROM.end();
}

void loop() {
  loopFunction();
}

void measure(String name, std::function<void(void)> function)
{
  int start = millis();
  function();
  int duration = millis() - start;
  if (duration > 2)
  {
    Serial.println(name + " took: " + duration + "ms.");
  }
}
