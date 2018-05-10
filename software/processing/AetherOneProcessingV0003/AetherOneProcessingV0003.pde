RadionicsElements radionicsElements;


void setup() {
  size(1800, 900);
  noStroke();
  smooth();
  radionicsElements = new RadionicsElements(this);
  radionicsElements.startAtX = 10;
  radionicsElements.startAtY = 10;
  radionicsElements.usualWidth = 200;
  radionicsElements.usualHeight = 21;
  radionicsElements
    .addButton("clear")
    .addButton("connect")
    .addButton("analyse")
    .addButton("broadcast")
    .addButton("disconnect")
    .initPeggotty(300,10);
}

void draw() {
  background(0);
  fill(255, 100);
  pushMatrix();
  translate(700,150);
  rotate(frameCount*0.001);
  for (int x = 0;x<radionicsElements.nx;x++) {
    for (int y = 0;y<radionicsElements.ny;y++) {
      radionicsElements.d[x][y].display();
    }
  }
  popMatrix();
}

void peggotty(int theX, int theY) {
  println("got it: "+theX+", "+theY);
  radionicsElements.d[theX][theY].update();
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}
