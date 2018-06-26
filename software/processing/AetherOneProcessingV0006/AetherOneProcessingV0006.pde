import javax.swing.JFileChooser; //<>//
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.image.BufferedImage;
import java.awt.Graphics2D;
import processing.net.*;
import processing.serial.*;
import java.util.*;

RadionicsElements radionicsElements;
ArduinoSerialConnection arduinoConnection;
AetherOneCore core;

boolean initFinished = false;
List<PImage> photos = new ArrayList<PImage>();
JSONObject configuration;
PImage backgroundImage;
int arduinoConnectionMillis;
File selectedDatabase;
String monitorText = "";
long timeNow;
Integer generalVitality = null;
Integer progress = 0;
boolean connectMode = false;
boolean disconnectMode = false;

long getTimeMillis() {
  Calendar cal = Calendar.getInstance();
  timeNow = cal.getTimeInMillis();
  return timeNow;
}

void setup() {
  size(540, 700);
  noStroke();
  smooth();
  core = new AetherOneCore();
  arduinoConnection = new ArduinoSerialConnection(this, 9600, core);
  arduinoConnectionMillis = millis();
  arduinoConnection.getPort();

  backgroundImage = loadImage("AetherOneBackground.png");

  initConfiguration();

  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 348;
  radionicsElements.startAtY = 70;
  radionicsElements.usualWidth = 180;
  radionicsElements.usualHeight = 21;
  radionicsElements
    .addButton("clear")
    .addButton("grounding")
    .addButton("connect")
    .addButton("select data")
    .addButton("analyze")
    .addButton("general vitality")
    .addButton("broadcast")
    .addButton("disconnect")
    .addTextField("Input", 80, 10, 445, 20, true)
    .addTextField("Output", 80, 40, 445, 20, false);

  radionicsElements.addSlider("progress", 10, 270, 480, 10, 100);
  radionicsElements.addSlider("hotbits", 10, 290, 480, 10, 100);

  radionicsElements
    .addKnob("Max Hits", 230, 70, 35, 1, 100, 10, null)
    .addKnob("Broadcast Repeats", 230, 180, 35, 1, 360, 72, null)
    .addKnob("Delay", 145, 200, 25, 1, 250, 25, null);

  prepareExitHandler ();
  initFinished = true;
  core.updateCp5ProgressBar();
}



private void prepareExitHandler () {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

    public void run () {

      saveJSONObject(configuration, "configuration.json");
      core.persistHotBits();
    }
  }
  ));
}

void initConfiguration() {
  try {
    configuration = loadJSONObject("configuration.json");
  } 
  catch(Exception e) {
    configuration = new JSONObject();
  }

  if (configuration == null) {
    configuration = new JSONObject();
  }
}

void draw() {
  background(0);
  //image(backgroundImage, 0, 0);
  stroke(255);
  text("INPUT", 10, 25);
  text("OUTPUT", 10, 55);
  //text("x: "+mouseX+" y: "+mouseY, 320, 495);

  int x = 30;
  int y = 90;
  drawGreenLED("ARDUINO\nCONNECTED", x, y, 20, arduinoConnection.arduinoFound);
  drawBlueLED("CLEARING", x + 70, y, 20, arduinoConnection.clearing);
  drawGreenLED("ANALYSING", x + 140, y, 23, false);
  drawGreenLED("BROADCASTING", x, y + 70, 20, arduinoConnection.broadcasting);
  drawGreenLED("COPY", x + 70, y + 70, 10, false);
  drawBlueLED("GROUNDING", x + 140, y + 70, 25, false);
  drawRedLED("HOTBITS", x, y + 130, 20, arduinoConnection.collectingHotbits);
  drawBlueLED("SIMULATION", x + 70, y + 130, 26, core.simulation);

  if (arduinoConnection.arduinoConnectionEstablished() == false) {
    if ((arduinoConnectionMillis + 2500) < millis()) {
      arduinoConnectionMillis = millis();
      arduinoConnection.getPort();
      delay(250);
    }
  }

  textSize(11);
  text("Hotbits " + core.hotbits.size(), 10, 315);
  
  if (selectedDatabase != null) {
    text("Selected database " + selectedDatabase.getName(), 144, 315);
  }
  
  textSize(16);
  stroke(0, 0, 255);
  text(monitorText, 10, 330);
  
  if (connectMode || disconnectMode) {
    if (core.getRandomNumber(1000) > 950) {
      progress += 1;
      core.setProgress(progress);
    }
    
    if (progress >= 100) {
      
      if (connectMode) {
        monitorText = "CONNECTED!";
      }
      
      if (disconnectMode) {
        monitorText = "DISCONNECTED!";
      }
      
      connectMode = false;
      disconnectMode = false;
      core.persistHotBits();
    }
  }
}

void serialEvent(Serial p) { 
  arduinoConnection.serialEvent(p);
}

void drawRedLED(String text, int x, int y, int textOffset, boolean on) {
  drawLED(text, x, y, textOffset, on, 255, 0, 0);
}

void drawGreenLED(String text, int x, int y, int textOffset, boolean on) {
  drawLED(text, x, y, textOffset, on, 0, 255, 0);
}

void drawBlueLED(String text, int x, int y, int textOffset, boolean on) {
  drawLED(text, x, y, textOffset, on, 0, 0, 255);
}

void drawLED(String text, int x, int y, int textOffset, boolean on, int r, int g, int b) {
  fill(50, 0, 0);
  if (on) {
    fill(r, g, b);
  }
  stroke(200);
  strokeWeight(3);
  ellipse(x, y, 30, 30);
  strokeWeight(1);

  fill(255);
  textSize(9);
  text(text, x - textOffset, y + 30);
}



public boolean reachedSpecifiedHits(Map<String, Integer> ratesDoubles, int max) {

  for (String rateKey : ratesDoubles.keySet()) {
    if (ratesDoubles.get(rateKey) >= max) {
      return true;
    }
  }

  return false;
}

public void controlEvent(ControlEvent theEvent) {
  println("controlEvent " + theEvent.getController().getName());

  if (!initFinished) return;

  String command = theEvent.getController().getName();

  if ("select data".equals(command)) {
    println(dataPath(""));
    JFileChooser chooser = new JFileChooser(dataPath(""));
    chooser.setCurrentDirectory(new File(dataPath("")));
    FileNameExtensionFilter filter = new FileNameExtensionFilter(
      "Database", "txt", "csv", "json");
    chooser.setFileFilter(filter);
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      println("You chose to open this file: " +
        chooser.getSelectedFile().getName());
      selectedDatabase = chooser.getSelectedFile();
      core.updateCp5ProgressBar();
    }
  }
  
  if ("grounding".equals(command)) {
        
    String [] signatures = loadStrings(sketchPath() + "/data/FUNCTION_GROUNDING.txt");
    println(signatures.length);
    println(core.getRandomNumber(signatures.length));
    String groundingSignature = signatures[core.getRandomNumber(signatures.length)]
    + " " + signatures[core.getRandomNumber(signatures.length)]
    + " " + signatures[core.getRandomNumber(signatures.length)];
    
    monitorText = "GROUNDING signature:\n" + groundingSignature;
    
    broadcast(groundingSignature);
  }
  
  if ("connect".equals(command)) {
    connectMode = true;
    progress = 0;
  }
  
  if ("disconnect".equals(command)) {
    disconnectMode = true;
    progress = 0;
  }
  
  if ("general vitality".equals(command)) {
    
    List<Integer> list = new ArrayList<Integer>();
    
    for (int x=0; x<3; x++) {
      list.add(core.getRandomNumber(1000));
    }
    
    Collections.sort(list, Collections.reverseOrder());
    
    monitorText += "\nGeneral vitality = " + list.get(0);
  }

  if ("analyze".equals(command)) {
    if (selectedDatabase == null) return; //<>//

    String[] lines = loadStrings(selectedDatabase);
    Map<String, Integer> ratesDoubles = new HashMap<String, Integer>();

    Float maxHits = cp5.get(Knob.class, "Max Hits").getValue();
    int maxEntries = 10;
    int expectedDoubles = maxHits.intValue();
    int rounds = 0;

    if (lines.length <= 10) {
      maxEntries = lines.length / 2;
    }

    while (!reachedSpecifiedHits(ratesDoubles, expectedDoubles)) {
      String rate = lines[core.getRandomNumber(lines.length)];

      rounds++;

      if (ratesDoubles.get(rate) != null) {
        Integer count = ratesDoubles.get(rate);
        count++;
        ratesDoubles.put(rate, count);
      } else {
        ratesDoubles.put(rate, 1);
      }
    }

    monitorText = selectedDatabase.getName() + "\n";

    List<RateObject> rateObjects = new ArrayList<RateObject>();

    for (String rateKey : ratesDoubles.keySet()) {
      RateObject rateObject = new RateObject();
      rateObject.level = ratesDoubles.get(rateKey);
      rateObject.rate = rateKey;
      rateObjects.add(rateObject);
    }

    Collections.sort(rateObjects, new Comparator<RateObject>() {
      public int compare(RateObject o1, RateObject o2) {
        Integer i1 = o1.level;
        Integer i2 = o2.level;
        return i2.compareTo(i1);
      }
    }    
    );

    int level = 0;

    JSONArray protocolArray = new JSONArray();

    for (int x=0; x<maxEntries; x++) {
      RateObject rateObject = rateObjects.get(x);

      JSONObject protocolEntry = new JSONObject();
      protocolEntry.setInt(rateObject.rate, rateObject.level);
      protocolArray.setJSONObject(x, protocolEntry);

      monitorText += rateObject.level + "  | " + rateObject.rate + "\n";

      level += (10 - rateObject.level);
    }

    int ratio = rounds / lines.length;
    String synopsis = "Analysis end reached after " +  rounds + " rounds (rounds / rates ratio = " + ratio + ")\n" ;
    synopsis += "Level " + level;
    monitorText += synopsis;

    String inputText = cp5.get(Textfield.class, "Input").getText();
    String outputText = cp5.get(Textfield.class, "Output").getText();

    JSONObject protocol = new JSONObject();
    protocol.setJSONArray("result", protocolArray);
    protocol.setString("synopsis", synopsis);
    protocol.setString("input", inputText);
    protocol.setString("output", outputText);
    protocol.setInt("level", level);
    protocol.setInt("ratio", ratio);
    String filePath = System.getProperty("user.home");

    if (inputText != null && inputText.length() > 0) {
      filePath += "/AetherOne/protocol_" + getTimeMillis() + "_" + inputText.replaceAll(" ", "") + ".txt";
    } else {
      filePath += "/AetherOne/protocol_" + getTimeMillis() + ".txt";
    }

    saveJSONObject(protocol, filePath);

    core.updateCp5ProgressBar();
    core.persistHotBits();
  }

  if ("select image".equals(command)) {
    JFileChooser chooser = new JFileChooser();
    FileNameExtensionFilter filter = new FileNameExtensionFilter(
      "JPG & GIF Images", "jpg", "gif");
    chooser.setFileFilter(filter);
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      System.out.println("You chose to open this file: " +
        chooser.getSelectedFile().getName());
      PImage photo = loadImage(chooser.getSelectedFile().getAbsolutePath());
      photo.resize(615, 490);
      photos.add(photo);
    }
  }

  if ("paste image".equals(command)) {

    PImage photo = getImageFromClipboard();

    if (photo != null) {
      photo.resize(615, 490);
      photos.add(photo);
    }
  }

  if ("clear image".equals(command)) {
    photos.clear();
  }

  if ("clear".equals(command)) {
    arduinoConnection.clear();
    cp5.get(Textfield.class, "Input").setText("");
    cp5.get(Textfield.class, "Output").setText("");
    monitorText = "";
    generalVitality = null;
  }

  if ("broadcast".equals(command)) {
    String manualRate = cp5.get(Textfield.class, "Input").getText();
    String outputRate = cp5.get(Textfield.class, "Output").getText();
    String broadcastSignature = manualRate  + " " + outputRate;
    broadcast(broadcastSignature);
  }
}

void broadcast(String broadcastSignature) {
  Float fBroadcastRepeats = cp5.get(Knob.class, "Broadcast Repeats").getValue();
  int broadcastRepeats = fBroadcastRepeats.intValue();
  Float fDelay = cp5.get(Knob.class, "Delay").getValue();
  println(fDelay);
  int iDelay = fDelay.intValue();
  println(iDelay);

  println("broadcastSignature = " + broadcastSignature);
  byte[] data = broadcastSignature.getBytes();
  String b64 = Base64.getEncoder().encodeToString(data);
  println("broadcastSignature encoded = " + b64);
  arduinoConnection.broadCast(b64, broadcastRepeats, iDelay);
}

PImage getImageFromClipboard() {

  java.awt.Image image = (java.awt.Image) getFromClipboard(DataFlavor.imageFlavor);

  if (image != null)
  {      
    BufferedImage bufferedImage = toBufferedImage(image);
    return new PImage(bufferedImage);
  }

  return null;
}

Object getFromClipboard (DataFlavor flavor) {

  java.awt.Component component = new java.awt.Canvas();
  Clipboard clipboard = component.getToolkit().getSystemClipboard();
  Transferable contents = clipboard.getContents(null);
  Object object = null;

  if (contents != null && contents.isDataFlavorSupported(flavor))
  {
    try
    {
      object = contents.getTransferData(flavor);
      println("Clipboard.GetFromClipboard() >> Object transferred from clipboard.");
    }

    catch (UnsupportedFlavorException e1) // Unlikely but we must catch it
    {
      println("Clipboard.GetFromClipboard() >> Unsupported flavor: " + e1);
    }

    catch (java.io.IOException e2)
    {
      println("Clipboard.GetFromClipboard() >> Unavailable data: " + e2);
    }
  }

  return object;
} 

BufferedImage toBufferedImage(java.awt.Image src) {

  int w = src.getWidth(null);
  int h = src.getHeight(null);

  int type = BufferedImage.TYPE_INT_RGB;  // other options

  BufferedImage dest = new BufferedImage(w, h, type);

  Graphics2D g2 = dest.createGraphics();

  g2.drawImage(src, 0, 0, null);
  g2.dispose();

  return dest;
}

public class RateObject {
  String rate;
  Integer level = 0;
}
