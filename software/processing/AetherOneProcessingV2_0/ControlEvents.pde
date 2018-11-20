/**
* ControlP5 event listener
*/
public void controlEvent(ControlEvent theEvent) {
  println("controlEvent " + theEvent.getController().getName());

  if (!initFinished) return;

  String command = theEvent.getController().getName();
  
  if ("hotbits".equals(command)) return;
  
  if ("photography".equals(command)) {
    tile = new Tile(630,50,400,400,0);
    return;
  }
  
  if ("stop broadcast".equals(command)) {
    stopBroadcasting = true;
    return;
  }
  
  if ("copy".equals(command)) {
    arduinoConnection.copy();
    return;
  }
  
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
    ratesDoubles.clear();

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
    ratesDoubles.clear();
  }

  if ("broadcast".equals(command)) {
    arduinoConnection.broadcasting = true;
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

void mouseClicked() {
  println("CLICK");
  int yRate = 350;
 
  for (int iRate=0; iRate<rateList.size(); iRate++) {
    
      RateObject rateObject = rateList.get(iRate);
      
      if (mouseY >= yRate - 20 && mouseY < yRate && mouseX < 600) {
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
