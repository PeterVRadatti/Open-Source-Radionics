import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.image.BufferedImage;
import java.awt.Graphics2D;
import java.util.*;

RadionicsElements radionicsElements;

boolean initFinished = false;
List<PImage> photos = new ArrayList<PImage>();
JSONObject configuration;

void setup() {
  size(1800, 900);
  noStroke();
  smooth();
  initConfiguration();

  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 10;
  radionicsElements.startAtY = 250;
  radionicsElements.usualWidth = 200;
  radionicsElements.usualHeight = 21;
  radionicsElements
    .addButton("clear")
    .addButton("connect")
    .addButton("analyse")
    .addButton("broadcast")
    .addButton("disconnect")
    .initPeggotty(650, 10)
    .addTextField("Input", 10, 10, 500, 20, true)
    .addTextField("Intention", 10, 70, 500, 20, false)
    .addTextField("Manual rate", 10, 130, 500, 20, false)
    .addTextField("Output", 10, 190, 500, 20, false);

  radionicsElements.startAtX = 215;
  radionicsElements.startAtY = 250;
  radionicsElements
    .addButton("select image")
    .addButton("paste image")
    .addButton("clear image");

  int xx = 10;
  int yy = 450;
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
    .addKnob("generalVitality", 420, 450, 70, 0, 100, 0, null)
    .addKnob("amplifier", 400, 630, 90, 0, 360, 0, color_gold);

  initFinished = true;
}

void stop() {
  saveJSONObject(configuration, "configuration.json");
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
  stroke(255);
  line(0, 400, 1250, 400);
  line(600, 0, 600, 900);
  line(1250, 0, 1250, 900);
  fill(255, 100);
  pushMatrix();
  translate(1050, 150);
  rotate(frameCount*0.001);
  for (int x = 0; x<radionicsElements.nx; x++) {
    for (int y = 0; y<radionicsElements.ny; y++) {
      radionicsElements.d[x][y].display();
    }
  }
  popMatrix();

  int imageCount = 0;
  int alpha = 0;

  for (PImage photo : photos) {
    
    if (imageCount > 0) {
      alpha = 125 + (imageCount * 3);
    }
    
    tint(255, alpha);
    image(photo, 602, 404);
    imageCount ++;
  }
  
  imageCount = 0;
}

void peggotty(int theX, int theY) {
  println("got it: "+theX+", "+theY);
  radionicsElements.d[theX][theY].update();
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());

  if (!initFinished) return;

  String command = theEvent.getController().getName();

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
      photo.resize(645, 490);
      photos.add(photo);
    }
  }

  if ("paste image".equals(command)) {

    PImage photo = getImageFromClipboard();

    if (photo != null) {
      photo.resize(645, 490);
      photos.add(photo);
    }
  }

  if ("clear image".equals(command)) {
    photos.clear();
    tint(255, 0);
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
