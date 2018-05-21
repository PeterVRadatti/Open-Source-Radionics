class ArduinoSerialConnection {

  Serial serialPort;
  PApplet app;
  int baud;
  int numberOfPorts;
  int currentPortNumber = -1;
  boolean arduinoFound;
  boolean collectingHotbits = false;
  boolean clearing = false;
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

  public void broadCast(String signature, int repeat) {
    serialPort.write("BROADCAST " + repeat + " "  + signature);
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
    println("getPort " + currentPortNumber);
    numberOfPorts = Serial.list().length;

    if (currentPortNumber >= numberOfPorts) return;
    println(numberOfPorts + " " + currentPortNumber);

    portList = new String[numberOfPorts];
    portList[currentPortNumber] = Serial.list()[currentPortNumber];
    connect(portList[currentPortNumber]);
  }

  public void serialEvent(Serial p) {
    arduinoInputString = p.readStringUntil('\n');

    if (arduinoInputString.length() == 0) {
      return;
    }

    arduinoInputString = arduinoInputString.replaceAll("\n", "");
    arduinoInputString = arduinoInputString.replaceAll("\r", "");
    arduinoInputString = arduinoInputString.replaceAll("\t", "");

    println("[" + arduinoInputString + "]");

    if ("CLEARED".equals(arduinoInputString)) {
      clearing = false;
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
          } catch(Exception e){}
          start_trng();
        }
      }
      ).start();
    } else if (!arduinoFound) {
      println("Port " + portList[currentPortNumber] + " is not a arduino.");
    }

    try {
      Integer seed = Integer.parseInt(arduinoInputString);
      collectingHotbits = true;
      core.hotbits.add(seed);
      println("Hotbits archive size " + core.hotbits.size());
      return;
    } 
    catch(Exception e) {
      collectingHotbits = false;
    }
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
