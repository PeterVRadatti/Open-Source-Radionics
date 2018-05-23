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
import javax.xml.bind.DatatypeConverter;

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

void setup() {
  size(1800, 900);
  noStroke();
  smooth();
  core = new AetherOneCore();
  arduinoConnection = new ArduinoSerialConnection(this, 9600, core);
  arduinoConnectionMillis = millis();
  arduinoConnection.getPort();

  backgroundImage = loadImage("AetherOneBackground.png");

  initConfiguration();

  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 10;
  radionicsElements.startAtY = 250;
  radionicsElements.usualWidth = 200;
  radionicsElements.usualHeight = 21;
  radionicsElements
    .addButton("clear")
    .addButton("grounding")
    .addButton("connect")
    .addButton("disconnect")
    .addButton("select database")
    .addButton("analyse")
    .addButton("check potency")
    .addButton("broadcast")
    .addButton("copy")
    .addButton("invert")

    .initPeggotty(650, 10)
    .addTextField("Input", 10, 10, 600, 20, true)
    .addTextField("Intention", 10, 70, 600, 20, false)
    .addTextField("Manual rate", 10, 130, 600, 20, false)
    .addTextField("Output", 10, 190, 600, 20, false);

  radionicsElements.startAtX = 215;
  radionicsElements.startAtY = 250;
  radionicsElements
    .addButton("select image")
    .addButton("paste image")
    .addButton("save image")
    .addButton("clear image")
    .addButton("hardware test")
    .addButton("load")
    .addButton("save")
    .addButton("search")
    .addTextField("searchProtocol", 215, 441, 200, 21, false);

  radionicsElements.startAtX = 650;
  radionicsElements.startAtY = 250;
  radionicsElements
    .addButton("clear peggotty")
    .addButton("automatic set");

  radionicsElements.addSlider("process", 635, 325, 570, 10, 100);
  radionicsElements.addSlider("hotbits", 635, 340, 570, 10, 100);

  int xx = 10;
  int yy = 520;
  int rCounter = 1;

  for (int y=0; y<3; y++) {
    for (int x=0; x<3; x++) {
      radionicsElements
        .addKnob("R" + rCounter, xx, yy, 50, 0, 100, 0, null);
      xx += 130;
      rCounter += 1;
    }

    xx = 10;
    yy += 130;
  }

  Colors color_gold = new Colors();
  color_gold.bRed = 250;
  color_gold.bGreen = 200;
  color_gold.bBlue = 0;
  color_gold.fRed = 0;
  color_gold.fGreen = 0;
  color_gold.fBlue = 0;

  radionicsElements
    .addKnob("generalVitality", 420, 520, 70, 0, 100, 0, null)
    .addKnob("amplifier", 400, 700, 90, 0, 360, 0, color_gold);

  prepareExitHandler ();
  initFinished = true;
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
  image(backgroundImage, 0, 0);
  stroke(255);
  text("x: "+mouseX+" y: "+mouseY, 320, 495);

  stroke(255);
  strokeWeight(1);
  fill(255, 100);

  // Peggotty
  pushMatrix();
  translate(1050, 160);
  rotate(frameCount*0.001);
  for (int x = 0; x<radionicsElements.nx; x++) {
    for (int y = 0; y<radionicsElements.ny; y++) {
      radionicsElements.d[x][y].display();
    }
  }
  popMatrix();

  // Photo Collage
  int imageCount = 0;
  int alpha = 0;

  for (PImage photo : photos) {

    if (imageCount > 0) {
      alpha = 125 + (imageCount * 3);
    }

    //tint(255, alpha);
    image(photo, 632, 404);
    imageCount ++;
  }

  imageCount = 0;

  drawGreenLED("ARDUINO\nCONNECTED", 450, 250, 20, arduinoConnection.arduinoFound);
  drawBlueLED("CLEARING", 450 + 70, 250, 20, arduinoConnection.clearing);
  drawGreenLED("ANALYSING", 450 + 140, 250, 23, false);
  drawGreenLED("BROADCASTING", 450, 250 + 70, 20, arduinoConnection.broadcasting);
  drawGreenLED("COPY", 450 + 70, 250 + 70, 10, false);
  drawBlueLED("GROUNDING", 450 + 140, 250 + 70, 25, false);
  drawRedLED("HOTBITS", 450, 250 + 130, 20, arduinoConnection.collectingHotbits);

  if (arduinoConnection.arduinoConnectionEstablished() == false) {
    if ((arduinoConnectionMillis + 1500) < millis()) {
      arduinoConnectionMillis = millis();
      arduinoConnection.getPort();
      delay(250);
    }
  }
  
  if (selectedDatabase != null) {
    textSize(14);
    text(selectedDatabase.getName(), 1275, 45);
    stroke(0,0,255);
    text(monitorText, 1275, 71);
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

void peggotty(int theX, int theY) {
  println("got it: "+theX+", "+theY);
  radionicsElements.d[theX][theY].update();
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());

  if (!initFinished) return;

  String command = theEvent.getController().getName();

  if ("select database".equals(command)) {
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
    }
  }

  if ("analyse".equals(command)) {
    if (selectedDatabase == null) return;

    String[] lines = loadStrings(selectedDatabase);
    Map<String, Integer> ratesDoubles = new HashMap<String, Integer>();
    int doubles = 0;

    while (doubles < 5) {
      String rate = lines[core.getRandomNumber(lines.length)];

      if (ratesDoubles.get(rate) != null) {
        Integer count = ratesDoubles.get(rate);
        count++;
        ratesDoubles.put(rate, count);
      } else {
        ratesDoubles.put(rate, 1);
      }

      doubles = 0;

      for (String rateKey : ratesDoubles.keySet()) {
        if (ratesDoubles.get(rateKey) > 4) {
          doubles++;
        }
      }
    }

    monitorText += "---------------------------\n";
    
    for (String rateKey : ratesDoubles.keySet()) {
      if (ratesDoubles.get(rateKey) > 4) {
        println(rateKey + " " + ratesDoubles.get(rateKey));
        monitorText += rateKey + " " + ratesDoubles.get(rateKey) + "\n";
      }
    }

    core.updateCp5ProgressBar();
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
    cp5.get(Textfield.class, "Intention").setText("");
    cp5.get(Textfield.class, "Manual rate").setText("");
    cp5.get(Textfield.class, "Output").setText("");
  }

  if ("broadcast".equals(command)) {
    String manualRate = cp5.get(Textfield.class, "Manual rate").getText();
    String outputRate = cp5.get(Textfield.class, "Output").getText();
    String broadcastSignature = manualRate + outputRate;
    println("broadcastSignature = " + broadcastSignature);
    String b64 = DatatypeConverter.printBase64Binary(broadcastSignature.getBytes());
    arduinoConnection.broadCast(b64, 72);
  }
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
