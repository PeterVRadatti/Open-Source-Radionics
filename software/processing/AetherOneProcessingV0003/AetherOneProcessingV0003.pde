RadionicsElements radionicsElements;


void setup() {
  size(1800, 900);
  noStroke();
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
    .addButton("disconnect");
}

void draw() {
  background(0);
}

public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}
