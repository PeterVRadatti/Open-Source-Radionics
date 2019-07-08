#define PIN_LED_RXL          (25u)
#define PIN_LED_TXL          (26u)

class AetherOneForArduino {

  private:
    const int COIL_1 = 9;
    const int COIL_2 = 8;
    const int UV_LED = 7;
    const int WHITE_LED = 6;
    const int IR_LED = 5;
    const int RED_LED = 4;
    const int GREEN_LED = 3;
    const int BLUE_LED = 2;
    const int CONTROL_LED = 12;
    int trngNumber = 0;
    int bitNumber = 0;
    int trng_bitmask_x = 0;
    int trng_seed_rounds = 0;
    int trng_seed = 0;
    boolean connectionEstablished = false;
    boolean trng_generation = false;
    int wait_millis = 250;
    int delay_millis = 25;

  public:

    void init() {

      // --> TEST MODE <--
      boolean testmode = false;

      pinMode(COIL_1, OUTPUT);
      pinMode(COIL_2, OUTPUT);
      pinMode(UV_LED, OUTPUT);
      pinMode(RED_LED, OUTPUT);
      pinMode(GREEN_LED, OUTPUT);
      pinMode(BLUE_LED, OUTPUT);
      pinMode(WHITE_LED, OUTPUT);
      pinMode(IR_LED, OUTPUT);
      pinMode(CONTROL_LED, OUTPUT);
      pinMode(LED_BUILTIN, OUTPUT);
      pinMode(PIN_LED_RXL,OUTPUT);
      pinMode(PIN_LED_TXL,OUTPUT);

      if (testmode) {
        for (int x = 0; x < 100; x++) {
          testLED(UV_LED);
          testLED(RED_LED);
          testLED(GREEN_LED);
          testLED(BLUE_LED);
          testLED(WHITE_LED);
          testLED(IR_LED);
          testLED(CONTROL_LED);
        }
      }
    }

    void testLED(int ledPin) {
      digitalWrite(ledPin, HIGH);
      delay(500);
      digitalWrite(ledPin, LOW);
    }

    void clear(int repeat) {

      digitalWrite(CONTROL_LED, LOW);

      for (int x = 0; x < repeat; x++) {
        digitalWrite(UV_LED, HIGH);
        delay(delay_millis);
        digitalWrite(UV_LED, LOW);
        delay(delay_millis);
      }

      digitalWrite(CONTROL_LED, HIGH);

      Serial.println("CLEARED");
    }

    void copy() {

      digitalWrite(CONTROL_LED, LOW);

      for (int x = 0; x < 40; x++) {
        
        digitalWrite(COIL_1, HIGH);
        delay(25);
        digitalWrite(COIL_2, LOW);
        delay(25);
        digitalWrite(COIL_2, HIGH);
        delay(25);
        digitalWrite(COIL_2, LOW);
        delay(25);
        digitalWrite(RED_LED, HIGH);
        delay(400);
        digitalWrite(RED_LED, LOW);
        delay(400);
      }

      digitalWrite(CONTROL_LED, HIGH);
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

      if (trng_seed_rounds >= 12) {
        if (trng_seed < 0) {
          trng_seed = trng_seed * -1;
        }
        Serial.println(trng_seed);
        trng_seed = 0;
        trng_seed_rounds = 0;
      }
    }

    void executeCommand(String command) {

      if (command.length() > 0) {
        Serial.println(" ARDUINO COMMAND = [" + command + "]");
        interpretCommand(command);
      } else if (connectionEstablished == false) {
        Serial.println("ARDUINO_PONG");
        digitalWrite(CONTROL_LED, HIGH);
        delay(20);
        digitalWrite(CONTROL_LED, LOW); 
      }
    }

    void interpretCommand(String command) {
      if (command == "AETHER_PING") {
        connectionEstablished = true;
        digitalWrite(RED_LED, HIGH);
        Serial.println("ARDUINO_OK");
        delay(1500);
        digitalWrite(RED_LED, LOW);
        digitalWrite(CONTROL_LED, HIGH);
      } else if (command == "TRNG_START") {
        connectionEstablished = true;
        trng_generation = true;
        digitalWrite(RED_LED, HIGH);
        delay(100);
        digitalWrite(RED_LED, LOW);
        return;
      } else if (command == "TRNG_STOP") {
        wait_millis = 250;
        Serial.println("TRNG_STOP");
        trng_generation = false;
      } else if (command == "CLEAR") {
        delay_millis = 20;
        clear(500);
        Serial.println("BROADCAST FINISHED");
      } else if (command == "COPY") {
        copy();
        Serial.println("BROADCAST FINISHED");
      } else if (getValue(command, ' ', 0) == "C") {
        // CLEAR WITH VARIABLE LENGTH
        int repeat = getValue(command, ' ', 1).toInt();
        delay_millis = getValue(command, ' ', 2).toInt();
        clear(repeat);
        Serial.println("BROADCAST FINISHED");
      } else if (getValue(command, ' ', 0) == "B") {
        // BROADCAST JUST ONCE FOR BIGGER STREAMS
        wait_millis = 0;
        String stringData = getValue(command, ' ', 1);
        if (getValue(command, ' ', 2) != NULL) {
          delay_millis = getValue(command, ' ', 2).toInt();
        } else {
          delay_millis = 20;
        }
        
        broadcastData(stringData);
        Serial.println("BROADCAST FINISHED");
      } else if (getValue(command, ' ', 0) == "BROADCAST") {
        // BROADCAST 2 a2b2ZGFzamb2a3NkavZm 25
        digitalWrite(CONTROL_LED, LOW);
        allBroadCastLEDs(LOW);
        delay(250);
        allBroadCastLEDs(HIGH);
        delay(500);
        allBroadCastLEDs(LOW);

        String stringData = getValue(command, ' ', 2);

        int repeat = getValue(command, ' ', 1).toInt();

        if (getValue(command, ' ', 3) != NULL) {
          delay_millis = getValue(command, ' ', 3).toInt();
        } else {
          delay_millis = 20;
        }

        for (int z = 0; z < repeat; z++) {
          broadcastData(stringData);
        }

        Serial.println("BROADCAST FINISHED");
      } else {
        
        switchLED(command, "RED", RED_LED);
        switchLED(command, "GREEN", GREEN_LED);
        switchLED(command, "BLUE", BLUE_LED);
        switchLED(command, "WHITE", WHITE_LED);
        switchLED(command, "IR", IR_LED);
        digitalWrite(CONTROL_LED, HIGH);
        
        if (trng_generation == true) {
          // No command was identificable, so stop TRNG production
          Serial.println("TRNG_STOP BECAUSE COMMAND NOT RECOGNIZED");
          trng_generation = false;
        }
      }
    }

    /**
     * Broadcast just one string of data
     */
    void broadcastData(String stringData) {
      for (int x = 0; x < stringData.length(); x++) {
        char c = stringData[x];
        int i = c - '0';
        String stringPart = String(i);
        //writeString(stringPart + "\n");

        for (int y = 0; y < stringPart.length(); y++) {
          char reds[2] = {'2', '5'};
          char greens[2] = {'3', '7'};
          char blues[2] = {'4', '8'};
          char whites[2] = {'0', '9'};
          char infrared[2] = {'1', '6'};
          char internal13[4] = {'1', '2', '3', '5'};
          //char internalTX[2] = {'4', '8'};
          //char internalRX[2] = {'0', '9'};

          blinkLED(RED_LED, reds, stringPart[y]);
          blinkLED(COIL_1, whites, stringPart[y]);
          blinkLED(GREEN_LED, greens, stringPart[y]);
          blinkLED(LED_BUILTIN, internal13, stringPart[y]);
          blinkLED(BLUE_LED, blues, stringPart[y]);
          //blinkLED(PIN_LED_TXL, internalTX, stringPart[y]);
          blinkLED(COIL_2, infrared, stringPart[y]);
          blinkLED(WHITE_LED, whites, stringPart[y]);
          //blinkLED(PIN_LED_RXL, internalRX, stringPart[y]);
          blinkLED(IR_LED, infrared, stringPart[y]);
        }
      }
    }

    void blinkLED(int pin, char *arr, char value) {

      for (int i = 0; i < sizeof(arr); i++) {
        if (arr[i] == value) {
          digitalWrite(pin, HIGH);
          delay(delay_millis);
          digitalWrite(pin, LOW);
          delay(delay_millis);
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


