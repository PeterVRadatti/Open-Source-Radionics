public class AetherOneCore { //<>//

  List<Integer> hotbits = new ArrayList<Integer>();
  int updateProcessBar = 0;
  Calendar today = Calendar.getInstance();
  Random pseudoRandom = new Random(today.getTimeInMillis());
  boolean simulation = false;
  boolean trngMode = true;

  public AetherOneCore() {
    try {
      String[] lines = loadStrings("hotbits.txt");
      int l = lines.length;
      println("there are " + l + " lines");

      for (int x=0; x<l; x++) {
        String line = lines[x];
        if (line == null) continue;
        addHotBitSeed(Integer.parseInt(line));
      }
    } 
    catch(Exception e) {
      println(e);
    }

    println("We have now " + hotbits.size() + " hot seeds!");
  }

  void persistHotBits() {
    int size = hotbits.size();
    println("Persisting " + size + " hotbits seeds for next session");
    String [] list = new String[size];

    for (int x=0; x<size; x++) {
      list[x] = hotbits.get(x).toString();
    }

    saveStrings("hotbits.txt", list);
  }

  void addHotBitSeed(Integer seed) {
    
    if (hotbits.size() > 4000000) return;
    
    if (seed < 100) return;
    
    hotbits.add(seed);
    updateProcessBar++;

    if (updateProcessBar > 100) {
      updateCp5ProgressBar();
      updateProcessBar = 0;
      simulation = false;
    }
  }

  Integer getHotBitSeed() {
    Integer seed = hotbits.remove(0);
    return seed;
  }
  
  void updateCp5ProgressBar() {
    
    int count = hotbits.size();
    
    if (count > 0) count = count / 100;
    if (count > 100) count = 100;

    if (cp5 != null) {
      cp5.get("hotbits").setValue(count);
    }
  }
  
  void setProgress(Integer progress) {
    cp5.get("progress").setValue(progress);
  }
  
  Integer getRandomNumber(int max) {
    
    Random random;
    
    if (trngMode == false) {
      random = pseudoRandom;
    } else if (hotbits.size() > 0) {
      random = new Random(getHotBitSeed());
      simulation = false;
    } else {
      random = pseudoRandom;
      simulation = true;
    }
    
    return random.nextInt(max);
  }
}
