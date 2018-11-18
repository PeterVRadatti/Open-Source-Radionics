AetherOneForArduino *aetherOne;

void setup() {
  aetherOne = new AetherOneForArduino();
  aetherOne->init();
  Serial.begin(9600);
}

void loop() {

  String input = "";

  aetherOne->generateTRNG();

  if (Serial.available() > 0 ) {
    delay(aetherOne->getWaitMillis());
    char inChar = Serial.read();

    while (inChar != '#') {
      input += inChar;

      if (Serial.available() > 0 ) {
        inChar = Serial.read();
      } else {
        break;
      }
    }
  }
  
  aetherOne->executeCommand(input);
  delay(aetherOne->getWaitMillis());
}
