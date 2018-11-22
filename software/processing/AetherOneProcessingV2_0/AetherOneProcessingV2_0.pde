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
Tile tile;

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
List<ImagePixel> imagePixels = new ArrayList<ImagePixel>();
List<ImagePixel> broadcastedImagePixels = new ArrayList<ImagePixel>();
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
  fullScreen();
  //size(1920, 1000);
  backgroundImage = loadImage("aetherOneBackground001.jpg");
  surface.setTitle("AetherOne V2.0 - Open Source Radionics");
  noStroke();
  noSmooth();
  core = new AetherOneCore();
  arduinoConnection = new ArduinoSerialConnection(this, 9600, core);
  arduinoConnectionMillis = millis();
  arduinoConnection.getPort();
  initConfiguration();
  
  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 308;
  radionicsElements.startAtY = 62;
  radionicsElements.usualWidth = 122;
  radionicsElements.usualHeight = 18;
  radionicsElements
    .addButton("clear")
    .addButton("grounding")
    .addButton("connect")
    .addButton("select data")
    .addButton("analyze")
    .addButton("general vitality")
    .addButton("broadcast")
    .addButton("stop broadcast")
    .addButton("disconnect")
    .addButton("TRNG / PRNG")
    .addTextField("Input", 80, 10, 515, 20, true)
    .addTextField("Output", 80, 40, 515, 20, false);
    
  radionicsElements.startAtX = 432;
  radionicsElements.startAtY = 62;
  radionicsElements
    .addButton("copy");
    
  radionicsElements.startAtX = 620;
  radionicsElements.startAtY = 10;
  radionicsElements
    .addButtonHorizontal("photography")
    .addButtonHorizontal("paste image")
    .addButtonHorizontal("clear image");
    
  radionicsElements.startAtX = 620;
  radionicsElements.startAtY = 32;
  radionicsElements
    .addButtonHorizontal("broadcast image");  
  
  radionicsElements.addSlider("progress", 10, 274, 540, 10, 100);
  radionicsElements.addSlider("hotbits", 10, 290, 540, 10, 100);

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
 //<>//
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
 //<>//
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
