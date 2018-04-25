public void buttonClick(GButton source, GEvent event) { //_CODE_:button1:685804:
  println("button1 - GButton >> " + source.getText() + " @ " + millis());
  arduinoConnection.getPort();
}

GButton buttonRed;
GButton buttonGreen;
GButton buttonBlue;
GButton buttonWhite;

String arduinoInputString = "";

public void createGUI() {
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("AetherOne Processing");
  addButton(buttonRed, "RED", 28, 20, 136, 46, "buttonClick");
  addButton(buttonGreen, "GREEN", 28, 70, 136, 46, "buttonClick");
  addButton(buttonBlue, "BLUE", 28, 120, 136, 46, "buttonClick");
  addButton(buttonWhite, "WHITE", 28, 170, 136, 46, "buttonClick");
}

private void addButton(GButton button, String text, int x, int y, int w, int h, String callback) {
  button = new GButton(this, x, y, w, h);
  button.setFont(g4p_controls.FontManager.getFont("Arial", 2, 20));
  button.setText(text);
  button.setTextBold();
  button.addEventHandler(this, "buttonClick");
}

void serialEvent(Serial p) { 
  arduinoConnection.serialEvent(p);
} 
