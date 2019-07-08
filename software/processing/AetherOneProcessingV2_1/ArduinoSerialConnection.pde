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
  boolean grounding = false;
  boolean copy = false;
  String[] portList;
  String arduinoInputString;
  AetherOneCore core;
  String stream = "";
  int iDelay = 20;

  public ArduinoSerialConnection(PApplet _app, int _baud, AetherOneCore _core) {
    app = _app;
    baud = _baud;
    core = _core;
  }

  public boolean arduinoConnectionEstablished() {
    return arduinoFound;
  }

  public void broadCast(String signature, int repeat) {
    
    signature = signature.replaceAll(" ","");
    signature = signature.replaceAll("-","");
    signature = signature.replaceAll(";","");
    signature = signature.replaceAll(". ","");
    
    broadcasting = true;
    
    for (int i=0; i<repeat; i++) {
      stream += signature;
    }
   
    serialPort.write("#1#");
    continueBroadcast();
    
    broadcasting = false;
  }
  
  synchronized public void continueBroadcast() {
    if (stopBroadcasting) {
      stream = "";
      stopBroadcasting = false;
      broadcasting = false;
      start_trng();
    } else if (stream.length() > 0) {
        println("stream length " + stream.length());
        String broadCastSignature = "B ";
        int pos = 60 - String.valueOf(iDelay).length();
        if (pos > stream.length()) {
          broadCastSignature += stream;
          stream = "";
        } else {
          broadCastSignature += stream.substring(0,pos);
          stream = stream.substring(pos);
        }
        
        broadCastSignature += " " + iDelay;
        
        println("broadCastSignature = " + broadCastSignature);
        broadcasting = true;
        serialPort.write(broadCastSignature);
     } else {
       start_trng();
     }
  }
  
  public void copy() {
    copy = true;
    serialPort.write("#1#");
    serialPort.write("COPY#");
  }

  public void clear() {
    serialPort.write("#1#");
    int maxTime = 13000;
    int repeat = 1 + core.getRandomNumber(1000);
    int delay = 1 + core.getRandomNumber(500);
    
    if (2 * repeat * delay > maxTime) {
      if (core.getRandomNumber(1000) >= 500) {
        repeat = maxTime / (delay * 2);
      } else {
        delay = maxTime / (repeat * 2);
      }
    }
    
    serialPort.write("C " + repeat + " " + delay + "#");
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
      grounding = false;
      copy = false;
      clearing = false;
      continueBroadcast();
      broadcastOneLineOfImage();
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
      
      broadcasting = false;
      grounding = false;
      copy = false;
      
      return;
    } 
    catch(Exception e) {
      collectingHotbits = false;
    }

    
    if (arduinoInputString.contains("1B ")) {
      continueBroadcast();
      broadcastOneLineOfImage();
    } else {
      println("[" + arduinoInputString + "]");
    }
  }

  public boolean connect(String detectedPort) {

    if (serialPort != null) {
      serialPort.stop();
    }
    
    try {
      serialPort = new Serial(app, detectedPort, baud);
      serialPort.bufferUntil('\n');
      return serialPort.active();
    } catch (Exception e) {
      println("Port " + detectedPort + " is not active!");
      return false;
    }
  }
}
