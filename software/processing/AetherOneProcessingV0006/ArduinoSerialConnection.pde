class ArduinoSerialConnection {

  Serial serialPort;
  PApplet app;
  int baud;
  int numberOfPorts;
  int currentPortNumber = -1;
  boolean arduinoFound;
  boolean collectingHotbits = false;
  boolean clearing = false;
  boolean broadcasting = false;
  String[] portList;
  String arduinoInputString;
  AetherOneCore core;

  public ArduinoSerialConnection(PApplet _app, int _baud, AetherOneCore _core) {
    app = _app;
    baud = _baud;
    core = _core;
  }

  public boolean arduinoConnectionEstablished() {
    return arduinoFound;
  }

  public void broadCast(String signature, int repeat, int iDelay) {
    
    signature = signature.replaceAll(" ","");
    
    String broadCastSignature = "BROADCAST " 
    + repeat + " "  
    + signature
    + " " + iDelay;
    
    println("broadCastSignature = " + broadCastSignature);
    serialPort.write(broadCastSignature);
    broadcasting = true;
  }

  public void clear() {
    serialPort.write("CLEAR#");
    clearing = true;
  }

  public void start_trng() {
    serialPort.write("#TRNG_START#");
  }

  public void stop_trng() {
    serialPort.write("TRNG_STOP");
  }

  public void getPort() {

    if (arduinoFound) return;

    currentPortNumber += 1;
    numberOfPorts = Serial.list().length;

    if (currentPortNumber >= numberOfPorts) {
      currentPortNumber = 1;
    }

    if (currentPortNumber >= numberOfPorts) {
      return;
    }

    println("getPort " + currentPortNumber + " of " + numberOfPorts);

    portList = new String[numberOfPorts];
    portList[currentPortNumber] = Serial.list()[currentPortNumber];
    connect(portList[currentPortNumber]);
  }

  public void serialEvent(Serial p) {
    arduinoInputString = p.readStringUntil('\n');
    arduinoInputString = arduinoInputString.replaceAll("\n", "");
    arduinoInputString = arduinoInputString.replaceAll("\r", "");
    arduinoInputString = arduinoInputString.replaceAll("\t", "");

    if (arduinoInputString.trim().length() == 0) {
      return;
    }
    
    //println("PRE[" + arduinoInputString + "]");

    if ("ARDUINO_PONG".equals(arduinoInputString) && arduinoFound) {
      delay(100);
      return;
    }

    if ("CLEARED".equals(arduinoInputString)) {
      clearing = false;
    }

    if ("BROADCAST FINISHED".equals(arduinoInputString)) {
      broadcasting = false;
    }

    if ("ARDUINO_OK".equals(arduinoInputString)) {
      //start_trng();
    }

    if ("ARDUINO_PONG".equals(arduinoInputString)) {
      arduinoFound = true;
      serialPort.write("#");
      println("Arduino found at port " + portList[currentPortNumber]);
      serialPort.write("AETHER_PING");


      (new Thread() {
        public void run() {
          try {
            Thread.sleep(5000);
          } 
          catch(Exception e) {
          }
          start_trng();
        }
      }
      ).start();
    } else if (!arduinoFound) {
      println("Port " + portList[currentPortNumber] + " is not a arduino.");
    }

    try {
      Integer seed = Integer.parseInt(arduinoInputString);

      // a bugfix, during broadcasting the seed drops under 100, and therefore we discard it
      if (seed < 100) return;

      collectingHotbits = true;
      core.addHotBitSeed(seed);
      return;
    } 
    catch(Exception e) {
      collectingHotbits = false;
    }

    println("[" + arduinoInputString + "]");
  }

  public boolean connect(String detectedPort) {

    if (serialPort != null) {
      serialPort.stop();
    }

    serialPort = new Serial(app, detectedPort, baud);
    serialPort.bufferUntil('\n');
    return serialPort.active();
  }
}
