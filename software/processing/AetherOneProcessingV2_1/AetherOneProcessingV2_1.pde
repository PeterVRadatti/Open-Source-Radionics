/** //<>// //<>// //<>//
 * AETHER ONE PROCESSING
 *
 * Copyright by Radionics (user in github)
 *
 * This program is licensed by MIT License, which permits you to copy, edit and redistribute,
 * but you need to distribute this license too, letting people know that this project is
 * open source.
 * 
 * https://github.com/radionics
 * https://radionicsnews.wordpress.com
 * https://www.facebook.com/groups/174120139896076
 * 
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
import java.lang.reflect.*;
import java.security.*;
// Version 3.0
import net.hydrogen2oxygen.*;

RadionicsElements radionicsElements;
ArduinoSerialConnection arduinoConnection;
AetherOneCore core;
Tile tile;

boolean initFinished = false;
int maxEntries = 17;
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
List<ImagePixel> imagePixels = new ArrayList<ImagePixel>();
List<ImagePixel> broadcastedImagePixels = new ArrayList<ImagePixel>();
Map<String, File> selectableFiles = new HashMap<String, File>();
Map<String, Integer> ratesDoubles = new HashMap<String, Integer>();
int gvCounter = 0;
boolean stopBroadcasting = false;

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
  //fullScreen();
  size(1285, 721);
  
  Test test = new Test();
  test.sayHello();
  
  backgroundImage = loadImage ("aetherOneBackground002.jpg"); //("aetherOneBackground001.jpg");
  surface.setTitle("AetherOne V2.2 - Open Source Radionics");
  noStroke();
  //noSmooth();
  core = new AetherOneCore();
  arduinoConnection = new ArduinoSerialConnection(this, 9600, core);
  arduinoConnectionMillis = millis();
  arduinoConnection.getPort();
  initConfiguration();

  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 950;//308;
  radionicsElements.startAtY = 10;//62;
  radionicsElements.usualWidth = 113;//122;
  radionicsElements.usualHeight = 15;//18;
  radionicsElements
    .addButton("grounding")
    .addButton("analyze")    
    .addButton("select data")
    .addButton("general vitality")
    .addButton("autobroadcast")
    .addButton("broadcast")
    .addButton("stop broadcast")
    .addButton("homeopathy")
    .addButton("biological")
    .addButton("symbolism")
    .addButton("essences")  
    .addButton("chemical") 
    .addButton("energy") 
    .addButton("copy")
    .addButton("rife")
    .addButton("check items")
    .addButton("check file")
    .addTextField("Input", 71, 10, 508, 20, true)//80, 10, 515, 20, true)
    .addTextField("Output", 71, 33, 508, 20, false);//80, 40, 515, 20, false);

  //2th buttons row 
  radionicsElements.startAtX = 1067;
  radionicsElements.startAtY = 10;
  radionicsElements
    .addButton("agriculture")
    .addButton("clear screen")
    .addButton("clear")
    .addButton("connect")
    .addButton("disconnect")
    .addButton("TRNG/PRNG"); 

  //PHOTOGRAPHY
  radionicsElements.startAtX = 592;//620;
  radionicsElements.startAtY = 298;//10;
  radionicsElements
    .addButtonHorizontal("photography")
    .addButtonHorizontal("paste image")
    .addButtonHorizontal("clear image");

  radionicsElements.startAtX = 592;//620;
  radionicsElements.startAtY = 316;// 32;
  radionicsElements
    .addButtonHorizontal("broadcast image")
    .addButtonHorizontal("generate md5")
    .addButtonHorizontal("target");  

  radionicsElements.addSlider("progress", 10, 273, 527, 10, 100);//10, 274, 540, 10, 100);
  radionicsElements.addSlider("hotbits", 10, 288, 527, 10, 100);//10, 290, 540, 10, 100);

  // PEGGOTTY 

  radionicsElements.startAtX = 361; //620;
  radionicsElements.startAtY = 107; 
  radionicsElements
    .initPeggotty (370, 57); //(620, 10) // (726, 10); // was 693 

  //PEGGOTTY BUTTONS
  radionicsElements.startAtX = 466; //620;
  radionicsElements.startAtY = 238; 
  radionicsElements
    .addButton("Peggotty rate") // generate a peggotty rate and enbed it in the peggotty You can also just put a rate in the peggotty squairs 
    .addButton("clear peggotty");

  radionicsElements
    .addKnob("Max Hits", 220, 65, 35, 1, 100, 10, null)
    .addKnob("Broadcast Repeats", 220, 175, 35, 1, 360, 72, null)
    .addKnob("Delay", 145, 195, 25, 1, 250, 25, null);

  //BUTTONS FOR 12 DIALS
  radionicsElements.startAtX = 950; //432;
  radionicsElements.startAtY = 633;//62;
  radionicsElements
    .addButton("broadcast rate")
    .addButton("generate rate")
    .addButton("clear dials")
    .addButton("potency");

  //12 DIALS 
  int xx = 963;
  int yy = 321;// 320; //353; //520
  int rCounter = 1;

  for (int y=0; y<4; y++) {
    for (int x=0; x<3; x++) {
      radionicsElements
        .addKnob("R" + rCounter, xx, yy, 27, 0, 100, 0, null); // .addKnob("R" + rCounter, xx, yy, 50, 0, 100, 0, null);
      xx += 77; //xx += 130;
      rCounter += 1;
    }

    xx = 963;
    yy += 78;

    Colors color_gold = new Colors(); //goudkleur dial
    color_gold.bRed = 250;
    color_gold.bGreen = 200;
    color_gold.bBlue = 0;
    color_gold.fRed = 0;
    color_gold.fGreen = 0;
    color_gold.fBlue = 0;

    radionicsElements.startAtX = 1088; //432;
    radionicsElements.startAtY = 633;//62;
    radionicsElements
      .addKnob("amplifier", 1088, 635, 35, 0, 360, 0, color_gold);
  }

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
 * Listen to serialEvents and transmit them to the ArduinoConnection class
 */
void serialEvent(Serial p) { 
  arduinoConnection.serialEvent(p);
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
 * BROADCAST a signature
 */
void broadcast(String broadcastSignature) {
  Float fBroadcastRepeats = cp5.get(Knob.class, "Broadcast Repeats").getValue();
  int broadcastRepeats = fBroadcastRepeats.intValue();
  Float fDelay = cp5.get(Knob.class, "Delay").getValue();
  println(fDelay);
  arduinoConnection.iDelay = fDelay.intValue();
  println(arduinoConnection.iDelay);

  println("broadcastSignature = " + broadcastSignature);
  byte[] data = broadcastSignature.getBytes();
  String b64 = Base64.getEncoder().encodeToString(data);
  println("broadcastSignature encoded = " + b64);
  arduinoConnection.broadCast(b64, broadcastRepeats);
}

/**
 * A rate object for analysis
 */
public class RateObject {
  String rate;
  Integer level = 0;
  Integer gv = 0;
}
