class ArduinoSerialConnection { //<>//

  Serial serialPort;
  PApplet app;
  int baud;
  int numberOfPorts;
  int currentPortNumber = -1;
  boolean arduinoFound;
  String[] portList;
  String arduinoInputString;    

  public ArduinoSerialConnection(PApplet _app, int _baud) {
    app = _app;
    baud = _baud;
  }
  
  public boolean arduinoConnectionEstablished() {
    return arduinoFound;
  }
  
  public void broadCast(String signature, int repeat) {
    serialPort.write("BROADCAST " + repeat + " "  + signature);
  }
  
  public void clear() {
    serialPort.write("CLEAR");
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
    //println(arduinoInputString);

    if (arduinoFound) {
      return;
    }
    
    if ("ARDUINO_PONG\n" == arduinoInputString || arduinoInputString.length() > 0) {
      arduinoFound = true;
      serialPort.write("AETHER_PING");
      println("Arduino found at port " + portList[currentPortNumber]);
    } else {
      println("Port " + portList[currentPortNumber] + " is not a arduino.");
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
