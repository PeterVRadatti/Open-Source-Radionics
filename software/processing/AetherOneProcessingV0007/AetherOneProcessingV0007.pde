/** //<>//
* AETHER ONE PROCESSING
*
* Copyright by Radionics (user in github)
*
* This program is licensed by MIT License, which permits you to copy, edit and redistribute,
* but you need to distribute this license too, letting people know that this project is
* open source.
* 
* https://github.com/radionics
*/
import javax.swing.JFileChooser;
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
int maxEntries = 10;
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
boolean trngMode = true;
List<RateObject> rateList = new ArrayList<RateObject>();
int gvCounter = 0;


//PWindow win;

/**
* Get current time in milliseconds
*/
long getTimeMillis() {
  Calendar cal = Calendar.getInstance();
  timeNow = cal.getTimeInMillis();
  return timeNow;
}

/**
* SETUP the processing environment
*/
void setup() {
  size(540, 700);
  surface.setTitle("AetherOne - Open Source Radionics");
  noStroke();
  smooth();
  core = new AetherOneCore();
  arduinoConnection = new ArduinoSerialConnection(this, 9600, core);
  arduinoConnectionMillis = millis();
  arduinoConnection.getPort();

  backgroundImage = loadImage("AetherOneBackground.png");

  initConfiguration();
  
  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 408;
  radionicsElements.startAtY = 62;
  radionicsElements.usualWidth = 120;
  radionicsElements.usualHeight = 18;
  radionicsElements
    .addButton("clear")
    .addButton("grounding")
    .addButton("connect")
    .addButton("select data")
    .addButton("analyze")
    .addButton("general vitality")
    .addButton("broadcast")
    .addButton("disconnect")
    .addButton("TRNG / PRNG")
    .addTextField("Input", 80, 10, 445, 20, true)
    .addTextField("Output", 80, 40, 445, 20, false);
  
  radionicsElements.addSlider("progress", 10, 274, 480, 10, 100);
  radionicsElements.addSlider("hotbits", 10, 290, 480, 10, 100);

  radionicsElements
    .addKnob("Max Hits", 230, 70, 35, 1, 100, 10, null)
    .addKnob("Broadcast Repeats", 230, 180, 35, 1, 360, 72, null)
    .addKnob("Delay", 145, 200, 25, 1, 250, 25, null);

  prepareExitHandler ();
  initFinished = true;
  core.updateCp5ProgressBar();
}

/**
* Before leaving the program save hotbits and other stuff
*/
private void prepareExitHandler () {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

    public void run () {

      saveJSONObject(configuration, "configuration.json");
      core.persistHotBits();
    }
  }
  ));
}

/**
* Initialize a JSON configuration
*/
void initConfiguration() {
  try {
    configuration = loadJSONObject("configuration.json");
  } 
  catch(Exception e) {
    //do nothing
  }

  if (configuration == null) {
    configuration = new JSONObject();
  }
}

/**
* The draw loop of processing
*/
void draw() {
  
  //if (win == null) {
     //win = new PWindow();
     //win.evokedFromPrimary(100, 100);
  //}
  
  background(0);
  fill(255);
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
  drawBlueLED("GROUNDING", x + 140, y + 70, 25, arduinoConnection.grounding);
  drawRedLED("HOTBITS", x, y + 130, 20, arduinoConnection.collectingHotbits);
  drawBlueLED("SIMULATION", x + 70, y + 130, 26, !arduinoConnection.arduinoFound);

  if (arduinoConnection.arduinoConnectionEstablished() == false) {
    if ((arduinoConnectionMillis + 2500) < millis()) {
      arduinoConnectionMillis = millis();
      arduinoConnection.getPort();
      delay(250);
    }
  }

  textSize(11);
  String trngModeText = "  TRNG Mode";
  if (trngMode == false) {
    fill(255,50,10);
    trngModeText = "  PRNG Simulation Mode";
  }
  text("Hotbits " + core.hotbits.size() + trngModeText, 10, 315);
  fill(255);
  
  textSize(16);
  stroke(0, 0, 255);
  
  fill(164, 197, 249);
  if (selectedDatabase != null) {
    text(selectedDatabase.getName(), 10, 330);
  }
  
  int yRate = 350;
 
  for (int iRate=0; iRate<rateList.size(); iRate++) {
    
      RateObject rateObject = rateList.get(iRate);
      
      if (mouseY >= yRate - 20 && mouseY < yRate) {
        fill(51, 10, 10);
        noStroke();
        rect(0, yRate - 16, 540, 20);
      }
      
      fill(rateObject.level * 25);
      text(rateObject.level, 60,yRate);

      if (rateObject.gv == 0) {
        fill(150);
      } else if (rateObject.gv > generalVitality && rateObject.gv > 1000) {
        fill(32, 255, 24);
      } else if (rateObject.gv > generalVitality) { //<>//
        fill(28, 204, 22);
      } else if (rateObject.gv < generalVitality) {
        fill(255, 105, 30);
      } else {
        fill(12, 134, 178);
      }
      
      text(rateObject.rate, 85, yRate);
      
      if (rateObject.gv != 0) {
        fill(208, 147, 255);
        text(rateObject.gv, 10, yRate);
      }
      
      yRate += 20;
  }
  
  if (generalVitality == null && rateList.size() > 0) {
    fill(135, 223, 255);
    text("Check General Vitality as next step!", 10, yRate);
  } else if (generalVitality != null) {
    fill(150, 227, 255);
    text("General Vitality is " + generalVitality, 10, yRate);
  } else if (selectedDatabase != null && rateList.size() == 0) {
    fill(66, 214, 47);
    text("Focus and then click on ANALYZE", 10, yRate);
  }
  
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

/**
* Listen to serialEvents and transmit them to the ArduinoConnection class
*/
void serialEvent(Serial p) { 
  arduinoConnection.serialEvent(p);
}

/**
* Draw LEDs on the gui ...
*/
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

/**
* Subroutine checking if at least one rate was choosen by TRNG max times
*/
public boolean reachedSpecifiedHits(Map<String, Integer> ratesDoubles, int max) {

  for (String rateKey : ratesDoubles.keySet()) {
    if (ratesDoubles.get(rateKey) >= max) {
      return true;
    }
  }

  return false;
}

/**
* ControlP5 event listener
*/
public void controlEvent(ControlEvent theEvent) {
  println("controlEvent " + theEvent.getController().getName());

  if (!initFinished) return;

  String command = theEvent.getController().getName();
  
  if ("hotbits".equals(command)) return;
  
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
      monitorText = selectedDatabase.getName() + "\n";
      core.updateCp5ProgressBar();
      generalVitality = null;
      rateList.clear();
    }
    return;
  }
  
  if ("grounding".equals(command)) {
        
    String [] signatures = loadStrings(sketchPath() + "/data/FUNCTION_GROUNDING.txt");
    selectedDatabase = new File(sketchPath() + "/data/FUNCTION_GROUNDING.txt");
    println(signatures.length);
    println(core.getRandomNumber(signatures.length));
    
    rateList.clear();
    
    String groundingSignature = "";
    
    for (int i=0; i<3; i++) {
      RateObject rate = new RateObject();
      rate.rate = signatures[core.getRandomNumber(signatures.length)];
      rateList.add(rate);
      groundingSignature += rate.rate;
    }
    
    cp5.get(Textfield.class, "Output").setText(groundingSignature);
    arduinoConnection.grounding = true;
    broadcast(groundingSignature);
    return;
  }
  
  if ("connect".equals(command)) {
    connectMode = true;
    progress = 0;
    return;
  }
  
  if ("disconnect".equals(command)) {
    disconnectMode = true;
    progress = 0;
    return;
  }
  
  if ("general vitality".equals(command)) {
    
    if (gvCounter > maxEntries) {
      return;
    }
    
    List<Integer> list = new ArrayList<Integer>();
    
    for (int x=0; x<3; x++) {
      list.add(core.getRandomNumber(1000));
    }
    
    Collections.sort(list, Collections.reverseOrder());
    
    Integer gv = list.get(0);
    
    if (gv > 950) {
      int randomDice = core.getRandomNumber(100);
       //<>//
      while(randomDice >= 50) {
        gv += randomDice;
        randomDice = core.getRandomNumber(100);
      }
    }
    
    if (gvCounter == 0) {
      monitorText += "\nGeneral vitality = " + gv;
      generalVitality = gv;
    } else {
      RateObject rateObject = rateList.get(gvCounter - 1);
      rateObject.gv = gv;
    }
    
    gvCounter += 1;
    
    return;
  }

  if ("analyze".equals(command)) {
    if (selectedDatabase == null) return;
    
    rateList.clear();
    generalVitality = null;
    gvCounter = 0;

    String[] lines = loadStrings(selectedDatabase);
    Map<String, Integer> ratesDoubles = new HashMap<String, Integer>();

    Float maxHits = cp5.get(Knob.class, "Max Hits").getValue();
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
      
      rateList.add(rateObject);
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
    
    if (selectedDatabase != null) {
      protocol.setString("database", selectedDatabase.getName());
    }
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

    println("[" + inputText + "]");
    
    if (inputText != null && inputText.trim().length() > 0) {
      saveJSONObject(protocol, filePath);
    }

    core.updateCp5ProgressBar();
    core.persistHotBits();
    return;
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
    return;
  }

  if ("paste image".equals(command)) {

    PImage photo = getImageFromClipboard();

    if (photo != null) {
      photo.resize(615, 490);
      photos.add(photo);
    }
    return;
  }

  if ("clear image".equals(command)) {
    photos.clear();
    return;
  }

  if ("clear".equals(command)) {
    arduinoConnection.clear();
    cp5.get(Textfield.class, "Input").setText("");
    cp5.get(Textfield.class, "Output").setText("");
    monitorText = "";
    generalVitality = null;
    gvCounter = 0;
    rateList.clear();
  }

  if ("broadcast".equals(command)) {
    String manualRate = cp5.get(Textfield.class, "Input").getText();
    String outputRate = cp5.get(Textfield.class, "Output").getText();
    String broadcastSignature = manualRate  + " " + outputRate;
    broadcast(broadcastSignature);
    return;
  }
  
  // Switch Simulation Mode
  if ("TRNG / PRNG".equals(command)) {
    if (trngMode) {
      trngMode = false;
    } else {
      trngMode = true;
    }
    
    core.trngMode = trngMode;
    return;
  }
  
  println("NO EVENT FOUND FOR " + command);
}

/**
* BROADCAST a signature
*/
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

void mouseClicked() {
  println("CLICK");
  int yRate = 350;
 
  for (int iRate=0; iRate<rateList.size(); iRate++) {
    
      RateObject rateObject = rateList.get(iRate);
      
      if (mouseY >= yRate - 20 && mouseY < yRate) {
        println(rateObject.rate);
        cp5.get(Textfield.class, "Output").setText(rateObject.rate);
      }
      
      yRate += 20;
  }
}

/**
* Get a image from your clipboard
*/
PImage getImageFromClipboard() {

  java.awt.Image image = (java.awt.Image) getFromClipboard(DataFlavor.imageFlavor);

  if (image != null)
  {      
    BufferedImage bufferedImage = toBufferedImage(image);
    return new PImage(bufferedImage);
  }

  return null;
}

/**
* Subroutine which gets a object from clipboard
*/
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

/**
* Transforms a Image into a BufferedImage for displaying on screen
*/
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

/**
* A rate object for analysis
*/
public class RateObject {
  String rate;
  Integer level = 0;
  Integer gv = 0;
}
