class ArduinoSerialConnection { //<>//

  Serial serialPort;
  PApplet app;
  int baud;
  int numberOfPorts;
  String[] portList;

  public ArduinoSerialConnection(PApplet _app, int _baud) {
    app = _app;
    baud = _baud;
    
  }

  public String getPort() {

    numberOfPorts = Serial.list().length;
    portList = new String[numberOfPorts];

    for (int i = 0; i < numberOfPorts; i++) {
      portList[i] = Serial.list()[i];

      println("Trying to connect to " + portList[i] + " ...");

      if (connect(portList[i])) {
        delay(1000);
        serialPort.write("AETHER_PING");
      }
    }

    return "";
  }
  
  public void serialEvent(Serial p) {
    println(p.readString());
  }

  public boolean connect(String detectedPort) {
    
    if (serialPort != null) {
      serialPort.stop();
    }
    
    serialPort = new Serial(app, detectedPort, baud);
    serialPort.bufferUntil(10);
    
    return serialPort.active();
  }
}
