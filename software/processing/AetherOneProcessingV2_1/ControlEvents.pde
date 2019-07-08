/**
 * ControlP5 event listener
 */
public void controlEvent(ControlEvent theEvent) {

  String command = theEvent.getController().getName().toLowerCase();
   
  if (!initFinished) return;
  if ("hotbits".equals(command)) return;
  if ("peggotty".equals(command)) return;
  
  println("controlEvent " + theEvent.getController().getName()); 

  if ("photography".equals(command)) {
    tile = new  Tile(590, 321, 360, 438, 0);//Tile(630, 50, 400, 400, 0);
    return;
  }
  
  if ("stop broadcast".equals(command)) {
    stopBroadcasting = true;
    imagePixels.clear();
    broadcastedImagePixels.clear();
    return;
  }

  if ("copy".equals(command)) {
    arduinoConnection.copy();
    return;
  }
  if ("clear screen".equals(command)) {
    monitorText = "";
    generalVitality = null;
    gvCounter = 0;
    rateList.clear();
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

    for (int i=0; i<17; i++) {//for (int i=0; i<3; i++) {
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

    checkGeneralVitality();
    return;
  }

  if ("analyze".equals(command)) {
    if (selectedDatabase == null) return;

    String[] lines = loadStrings(selectedDatabase);
    analyseList(lines);
    return;
  }

  if ("homeopathy".equals(command)) {

    String[] lines = getRatesFromListsWhichBeginsWithName("HOMEOPATHY");
    analyseList(lines);
    return;
  }

  if ("biological".equals(command)) {

    String[] lines = getRatesFromListsWhichBeginsWithName("BIOLOGICAL");
    analyseList(lines);
    return;
  }

  if ("symbolism".equals(command)) {

    String[] lines = getRatesFromListsWhichBeginsWithName("SYMBOLISM");
    analyseList(lines);
    return;
  }

  if ("essences".equals(command)) {

    String[] lines = getRatesFromListsWhichBeginsWithName("ESSENCES");
    analyseList(lines);
    return;
  }

  if ("chemical".equals(command)) {

    String[] lines = getRatesFromListsWhichBeginsWithName("CHEMICAL");
    analyseList(lines);
    return;
  }

  if ("energy".equals(command)) {

    String[] lines = getRatesFromListsWhichBeginsWithName("ENERGY");
    analyseList(lines);
    return;
  }
  
   if ("rife".equals(command)) {
    
    String[] lines = getRatesFromListsWhichBeginsWithName("RIFE");
    analyseList(lines);
    return;
  }

  if ("check items".equals(command)) {
    File databaseDir = new File(dataPath(""));
    List<String> items = getDatabaseItems(databaseDir);
    String[] array = items.toArray(new String[0]);
    analyseList(array);
    selectedDatabase = null;
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
      photo.resize(590, 321);
      photos.add(photo);
    }
    return;
  }

  if ("paste image".equals(command)) {

    PImage photo = getImageFromClipboard();

    if (photo != null) {
      photo.resize(348, 418);
      photos.add(photo);
    }
    return;
  }
  
  if ("clear peggotty".equals(command)) {
    cp5.get(Matrix.class, "peggotty").clear();
    return;
  }
  
  if ("peggotty rate".equals(command)) {
    
    cp5.get(Matrix.class, "peggotty").clear();
    
    String peggottyRate = "";
    Integer [] valuesFirstRow = {100,90,80,70,60,50,50,40,30,20,10,0};
    Integer [] valuesOtherRows = {10,9,8,7,6,5,5,4,3,2,1,0};
    // Peggotty
    Matrix matrix = cp5.get(Matrix.class, "peggotty");
    
    for (int x=0; x<12; x++) {
      for (int y=0; y<10; y++) {
        if (core.getRandomNumber(1000) > 980) {
          matrix.set(x,y,true);
        }
      }
    }
    
    for (int x=0; x<12; x++) {
      for (int y=0; y<10; y++) {
        if (matrix.get(x,y) && y == 0) {
          peggottyRate += valuesFirstRow[x] + ".";
          continue;
        }
        
        if (matrix.get(x,y) && y > 0) {
          peggottyRate += valuesOtherRows[x] + ".";
          continue;
        }
      }
    }
    
    if (peggottyRate.length() > 0) {
      peggottyRate = peggottyRate.substring(0,peggottyRate.length() - 1);
    }
    
    cp5.get(Textfield.class, "Output").setText(peggottyRate);
    return;
  }

  if ("generate md5".equals(command)) {
    // The entire screen including the image is used to generate the signature in md5 format
    loadPixels();

    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      String data = "";

      // add image data
      for (int i = 0; i < (width*height/2)-width/2; i++) {
        data += pixels[i];
        md.update(data.getBytes());
        data = new String(md.digest());
      }

      // add hotbits for encoding intention
      for (int i = 0; i < 144; i++) {
        data += core.getRandomNumber(1000);
        md.update(data.getBytes());
        data = new String(md.digest());
      }

      println(data);

      cp5.get(Textfield.class, "Output").setText(data);
    } 
    catch(Exception e) {
    }

    return;
  }

  if ("clear image".equals(command)) {
    photos.clear();
    imagePixels.clear();
    broadcastedImagePixels.clear();
    tile = null;
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
    imagePixels.clear();
    tile = null;
    return;
  }

  if ("clear dials".equals(command)) {
    radionicsElements.clearDials();
    return;
  }
  
   
  if ("broadcast rate".equals(command)) {
    cp5.get(Textfield.class, "Output").setText(radionicsElements.getRatesFromDials());
    return;
  }

  if ("broadcast".equals(command)) {
    arduinoConnection.broadcasting = true;
    String manualRate = cp5.get(Textfield.class, "Input").getText();
    String outputRate = cp5.get(Textfield.class, "Output").getText();
    String broadcastSignature = manualRate  + " " + outputRate;
    broadcast(broadcastSignature.trim());
    return;
  }

  if ("broadcast image".equals(command)) {

    imagePixels.clear();
    broadcastedImagePixels.clear();

    for (int y=316; y<716; y++) {
      for (int x=590; x<939; x++) {
        color c = get(x, y);
        ImagePixel img = new ImagePixel();
        img.x = x;
        img.y = y;
        img.r = red(c);
        img.g = green(c);
        img.b = blue(c);
        imagePixels.add(img);
      }
    }

    broadcastOneLineOfImage();
    return;
  }

  //==============================================
  // add Stella tot event if connect
  if ("autobroadcast".equals(command)) {

    String [] signatures = loadStrings(sketchPath() + "/data/LLOYD/LLOYD_MEAR.txt");
    selectedDatabase = new File(sketchPath() + "/data/LLOYD/LLOYD_MEAR.txt");
    println(signatures.length);
    println(core.getRandomNumber(signatures.length));
    // de volgende lijnen zijn vervangen door de code verderop //for (int i=0; i<17; i++) { 
    // String autobroadcastSignature = signatures[core.getRandomNumber(signatures.length)]
    // + " " + signatures[core.getRandomNumber(signatures.length)]
    //+ " " + signatures[core.getRandomNumber(signatures.length)];

    // monitorText = "AUTOBROADCASTING signature:\n" + autobroadcastSignature;
    rateList.clear();
    String autobroadcastSignature = "";

    for (int i=0; i<17; i++) {
      RateObject rate = new RateObject();
      rate.rate = signatures[core.getRandomNumber(signatures.length)];
      rateList.add(rate);
      autobroadcastSignature += rate.rate;
    }

    cp5.get(Textfield.class, "Output").setText(autobroadcastSignature);
    arduinoConnection.broadcasting = true;
    broadcast(autobroadcastSignature);
    return;
  }

  //=====================================

  if ("rates".equals(command)) {

    String [] signatures = loadStrings(sketchPath() + "/data/RATES/RATES_CLYSTALS_BASE_44_KöRBLER_LIST.txt.txt");
    selectedDatabase = new File(sketchPath() + "/data/RATES/RATES_CLYSTALS_BASE_44_KöRBLER_LIST.txt.txt");
    println(signatures.length);
    println(core.getRandomNumber(signatures.length));
    rateList.clear();

    String ratesSignature = "";

    for (int i=0; i<17; i++) {
      RateObject rate = new RateObject();
      rate.rate = signatures[core.getRandomNumber(signatures.length)];
      rateList.add(rate);
      ratesSignature += rate.rate;
    }

    cp5.get(Textfield.class, "Output").setText(ratesSignature);
    arduinoConnection.broadcasting = true;
    broadcast(ratesSignature);
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

void checkGeneralVitality() {
  if (gvCounter > maxEntries) {
      gvCounter = 0;

      for (int iRate=0; iRate<rateList.size(); iRate++) {

        RateObject rateObject = rateList.get(iRate);
        rateObject.gv = 0;
      }

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

      while (randomDice >= 50) {
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
}

/**
 * Get recursively all ITEM names in the database directory and subfolders
 */
List<String> getDatabaseItems(File databaseDir) {

  List<String> items = new ArrayList<String>();

  for (File file : databaseDir.listFiles()) {
    if (file.isDirectory()) {
      items.addAll(getDatabaseItems(file));
    } else {
      if (file.getName().startsWith("BROADCASTING")) continue;
      if (file.getName().startsWith("FUNCTION")) continue;
      if (file.getName().startsWith("POTENCY")) continue;
      items.add(file.getName());
      selectableFiles.put(file.getName(),file);
    }
  }

  return items;
}

/**
 * Get recursively all Files in the database directory and subfolders
 */
List<File> getDatabaseFiles(File dir) {

  List<File> files = new ArrayList<File>();

  for (File file : dir.listFiles()) {
    if (file.isDirectory()) {
      files.addAll(getDatabaseFiles(file));
    } else {
      if (file.getName().startsWith("BROADCASTING")) continue;
      if (file.getName().startsWith("FUNCTION")) continue;
      if (file.getName().startsWith("POTENCY")) continue;
      files.add(file);
    }
  }

  return files;
}

/**
 * Get all files which begins with a specified string
 */
List<File> getDatabaseFiles(String beginsWith) {

  File databaseDir = new File(dataPath(""));
  List<File> allFiles = getDatabaseFiles(databaseDir);
  List<File> files = new ArrayList<File>();

  for (File file : allFiles) {
    if (file.getName().startsWith(beginsWith)) {
      println(file.getName());
      files.add(file);
    }
  }

  return files;
}

/**
 * Get all rates / lines from all files which begins a specific name / string
 */
String [] getRatesFromListsWhichBeginsWithName(String beginsWith) {

  List<File> files = getDatabaseFiles(beginsWith);
  String [] rates = {};

  for (File file : files) {
    String[] lines = loadStrings(file);
    rates = concatenate(rates, lines);
  }

  return rates;
}

/**
 * Concatenates 2 arrays
 */
public <T> T[] concatenate(T[] a, T[] b) {
  int aLen = a.length;
  int bLen = b.length;

  @SuppressWarnings("unchecked")
    T[] c = (T[]) Array.newInstance(a.getClass().getComponentType(), aLen + bLen);
  System.arraycopy(a, 0, c, 0, aLen);
  System.arraycopy(b, 0, c, aLen, bLen);

  return c;
}

void analyseList(String[] lines) {
  rateList.clear();
  generalVitality = null;
  gvCounter = 0;
  ratesDoubles.clear();

  Float maxHits = cp5.get(Knob.class, "Max Hits").getValue();
  int expectedDoubles = maxHits.intValue();
  int rounds = 0;

  if (lines.length <= 17) {
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

  if (selectedDatabase != null) {
    monitorText = selectedDatabase.getName() + "\n";
  }

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
}

/**
 * Take one line of the image and broadcast it
 */
synchronized void broadcastOneLineOfImage() {

  if (imagePixels.size() == 0) {
    return;
  }

  if (arduinoConnection.stream.length() > 0) {
    return;
  }

  String signature = "";

  for (int x=0; x<400; x++) {
    ImagePixel img = imagePixels.remove(0);
    float multiplied = img.r * img.g * img.b;
    println(multiplied);
    // digit sum
    int num = (int) multiplied;
    int sum = 0;
    while (num > 0) {
      sum = sum + num % 10;
      num = num / 10;
    }
    signature += String.valueOf(sum);
    broadcastedImagePixels.add(invertPixel(img));
  }

  println(imagePixels.size());

  broadcast(signature);
}

ImagePixel invertPixel(ImagePixel p) {

  p.r = invertColor(p.r);
  p.g = invertColor(p.g);
  p.b = invertColor(p.b);

  return p;
}

float invertColor(float v) {
  if (v >= 255) {
    v = 0;
  } else {
    v = 255 - v;
  }

  return v;
}

void mouseClicked() {
  int yRate = 350;

  for (int iRate=0; iRate<rateList.size(); iRate++) {

    RateObject rateObject = rateList.get(iRate);

    if (mouseY >= yRate - 20 && mouseY < yRate && mouseX < 600) {
      println(rateObject.rate);
      if (selectableFiles.get(rateObject.rate) != null) {
        selectedDatabase = selectableFiles.get(rateObject.rate);
        rateList.clear();
        ratesDoubles.clear();
      } else {
        cp5.get(Textfield.class, "Output").setText(rateObject.rate);
      }
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
