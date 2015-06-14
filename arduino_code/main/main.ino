#include <pgmspace.h>
void (*loopFunction)();

void setup() {
  loopFunction = &configurationLoop;
  configurationSetup();
}

void loop() {
  loopFunction();
}
