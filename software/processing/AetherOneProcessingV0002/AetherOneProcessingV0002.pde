// Need G4P library
import g4p_controls.*;
import processing.net.*;
import processing.serial.*;

Server aetherServer;
ArduinoSerialConnection arduinoConnection;
int arduinoConnectionMillis;

public void setup() {
  size(480, 320, JAVA2D);
  createGUI();
  customGUI();
  // Place your setup code here
  aetherServer = new Server(this, 5204);
  arduinoConnection = new ArduinoSerialConnection(this, 9600);
  arduinoConnectionMillis = millis();
  arduinoConnection.getPort();
}

public void draw() {
  background(0);

  if (arduinoConnection.arduinoConnectionEstablished() == false) {
    if ((arduinoConnectionMillis + 1500) < millis()) {
      arduinoConnectionMillis = millis();
      arduinoConnection.getPort();
      delay(1000);
    }
  }

  //handleServer();
}

public void handleServer() {

  // REST CLIENT
  // Get the next available client
  Client thisClient = aetherServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    String whatClientSaid = thisClient.readString();
    if (whatClientSaid != null) {
      //println(thisClient.ip() + "t" + whatClientSaid);
      println(whatClientSaid);
      String jsonData = whatClientSaid.substring(whatClientSaid.indexOf("{"));
      JSONObject json = parseJSONObject(jsonData);

      if (json == null) {
        println("JSONObject could not be parsed");
      } else {
        println(json.getString("data"));
        println(json.getString("more"));
      }

      aetherServer.write("OK");
      thisClient.stop();
      thisClient.dispose();
    }
  }
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI() {
}
