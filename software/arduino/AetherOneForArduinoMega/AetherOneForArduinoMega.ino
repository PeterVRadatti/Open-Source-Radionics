
class AetherOneForArduino {

  private:
    const int UV_LED = 12;
    const int RED_LED = 48;
    const int GREEN_LED = 50;
    const int BLUE_LED = 52;
    const int WHITE_LED = 51;
    int trngNumber = 0;
    int bitNumber = 0;
    int trng_bitmask_x = 0;
    int trng_seed_rounds = 0;
    int trng_seed = 0;
    boolean connectionEstablished = false;
    boolean trng_generation = false;
    int wait_millis = 250;

  public:

    void init() {
      pinMode(UV_LED, OUTPUT);
      pinMode(RED_LED, OUTPUT);
      pinMode(GREEN_LED, OUTPUT);
      pinMode(BLUE_LED, OUTPUT);
      pinMode(WHITE_LED, OUTPUT);
    }

    void clear() {

      for (int x = 0; x < 100; x++) {
        digitalWrite(UV_LED, HIGH);
        delay(25);
        digitalWrite(UV_LED, LOW);
        delay(25);
      }

      Serial.println("CLEARED");
    }

    int getWaitMillis() {
      return wait_millis;
    }

    void generateTRNG() {
      if (trng_generation == false) {
        wait_millis = 250;
        return;
      }

      wait_millis = 0;
      
      if (analogRead(0) > analogRead(0)) {
        bitNumber |= 1UL << trng_bitmask_x;
      } else {
        bitNumber &= ~(1UL << trng_bitmask_x);
      }

      trng_bitmask_x++;

      if (trng_bitmask_x >= 16) {
        trng_bitmask_x = 0;
        trng_seed_rounds++;
        trng_seed += bitNumber;
        bitNumber = 0;
      }

      if (trng_seed_rounds >= 10) {
        if (trng_seed < 0) {
          trng_seed = trng_seed * -1;
        }
        Serial.println(trng_seed);
        trng_seed = 0;
        trng_seed_rounds = 0;
      }
    }

    void executeCommand(String command) {

      if (command.length() > 0)
        Serial.println(command);

      if (connectionEstablished == false) {
        Serial.println("ARDUINO_PONG");
        digitalWrite(GREEN_LED, HIGH);
        delay(20);
        digitalWrite(GREEN_LED, LOW);
      } else {
        digitalWrite(GREEN_LED, HIGH);
      }

      if (command == "AETHER_PING") {
        connectionEstablished = true;
        digitalWrite(RED_LED, HIGH);
        Serial.println("ARDUINO_OK");
        delay(1500);
        digitalWrite(RED_LED, LOW);
      }

      if (command == "TRNG_START") {
        connectionEstablished = true;
        trng_generation = true;
        digitalWrite(RED_LED, HIGH);
        delay(1500);
        digitalWrite(RED_LED, LOW);
      }

      if (command == "TRNG_STOP") {
        wait_millis = 250;
        Serial.println("TRNG_STOP");
        trng_generation = false;
      }

      if (command == "CLEAR") {
        clear();
        return;
      }

      if (getValue(command, ' ', 0) == "BROADCAST") {

        allBroadCastLEDs(LOW);
        delay(250);
        allBroadCastLEDs(HIGH);
        delay(500);
        allBroadCastLEDs(LOW);

        String stringData = getValue(command, ' ', 2);

        int repeat = getValue(command, ' ', 1).toInt();

        for (int z = 0; z < repeat; z++) {
          for (int x = 0; x < stringData.length(); x++) {
            char c = stringData[x];
            int i = c - '0';
            String stringPart = String(i);
            writeString(stringPart + "\n");

            for (int y = 0; y < stringPart.length(); y++) {
              char reds[3] = {'2', '5', '1'};
              char greens[3] = {'3', '7', '6'};
              char blues[2] = {'4', '8'};
              char whites[2] = {'0', '9'};
              blinkLED(RED_LED, reds, stringPart[y]);
              blinkLED(GREEN_LED, greens, stringPart[y]);
              blinkLED(BLUE_LED, blues, stringPart[y]);
              blinkLED(WHITE_LED, whites, stringPart[y]);
            }
          }
        }

        Serial.println("BROADCAST FINISHED");
      }

      switchLED(command, "RED", RED_LED);
      switchLED(command, "GREEN", GREEN_LED);
      switchLED(command, "BLUE", BLUE_LED);
      switchLED(command, "WHITE", WHITE_LED);
    }

    void blinkLED(int pin, char *arr, char value) {

      for (int i = 0; i < sizeof(arr); i++) {

        if (arr[i] == value) {
          digitalWrite(pin, HIGH);
          delay(25);
          digitalWrite(pin, LOW);
          delay(25);
        }
      }
    }

    void allBroadCastLEDs(int level) {
      digitalWrite(RED_LED, level);
      digitalWrite(GREEN_LED, level);
      digitalWrite(BLUE_LED, level);
      digitalWrite(WHITE_LED, level);
    }

    void switchLED(String command, String color, int pin) {
      if (getValue(command, ' ', 0) == color) {
        if (getValue(command, ' ', 1) == "ON") {
          digitalWrite(pin, HIGH);
        } else {
          digitalWrite(pin, LOW);
        }
      }
    }

    void writeString(String stringData) { // Used to serially push out a String with Serial.write()

      stringData += "\n";

      for (int i = 0; i < stringData.length(); i++)
      {
        Serial.write(stringData[i]);   // Push each char 1 by 1 on each loop pass
      }

    }

    String getValue(String data, char separator, int index) {
      int found = 0;
      int strIndex[] = {0, -1};
      int maxIndex = data.length() - 1;

      for (int i = 0; i <= maxIndex && found <= index; i++) {
        if (data.charAt(i) == separator || i == maxIndex) {
          found++;
          strIndex[0] = strIndex[1] + 1;
          strIndex[1] = (i == maxIndex) ? i + 1 : i;
        }
      }

      return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
    }
};


