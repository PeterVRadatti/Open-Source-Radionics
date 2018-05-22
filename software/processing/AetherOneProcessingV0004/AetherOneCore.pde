public class AetherOneCore { //<>// //<>//

  List<Integer> hotbits = new ArrayList<Integer>();
  int updateProcessBar = 0;

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
    hotbits.add(seed);
    updateProcessBar++;

    int count = hotbits.size();

    if (count > 0) count = count / 100;
    if (count > 100) count = 100;

    if (cp5 != null && updateProcessBar > 100) {
      cp5.get("hotbits").setValue(count);
      updateProcessBar = 0;
    }
  }

  Integer getHotBitSeed() {
    return hotbits.remove(0);
  }
}
