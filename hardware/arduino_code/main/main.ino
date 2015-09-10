#include <pgmspace.h>
#include <EEPROM.h>

static const String DEVICE_ID = "8dc36053-d69e-4813-8f8c-afe9c7557071";

enum class BootMode
{
  Configuration = 0,
  Sensor = 1
};
void setBootMode(BootMode mode);
void (*loopFunction)();

void setBootMode(BootMode mode)
{
  EEPROM.begin(1);
  EEPROM.write(0, (int)mode);
  EEPROM.end();
}

void setup() {
  EEPROM.begin(1);
  int bootMode = EEPROM.read(0);
  EEPROM.end();

  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();

  if (bootMode == (int)BootMode::Sensor)
  {
    Serial.println("Sensor boot");
    loopFunction = &sensorLoop;
    sensorSetup();
  } else {
    Serial.println("Configuration boot");
    loopFunction = &configurationLoop;
    configurationSetup();
  }
}

void loop() {
  loopFunction();
}
