int x = 0;
int xx = 0;
int trngNumber = 0;
int bitNumber = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  
  if (analogRead(0) > analogRead(0)) {
    bitNumber |= 1UL << x;
  } else {
    bitNumber &= ~(1UL << x);
  }

  x++;
  
  if (x >= 32) {
    x = 0;
    xx++;
    trngNumber += bitNumber;
    bitNumber = 0;
  }

  if (xx >= 10) {
    if (trngNumber < 0) {
      trngNumber = trngNumber * -1;
    }
    Serial.println(trngNumber);
    trngNumber = 0;
    xx = 0;
  }
}
