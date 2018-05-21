public void buttonClick(GButton source, GEvent event) { //_CODE_:button1:685804:
  println("button1 - GButton >> " + source.getText() + " @ " + millis());
  
  if (source.getText() == "BROADCAST") {
    arduinoConnection.broadCast(signatureTextField.getText(),72);
  }
  
  if (source.getText() == "GREEN") {
    arduinoConnection.clear();
  }
  
  if (source.getText() == "RED") {
    arduinoConnection.start_trng();
  }
  
  if (source.getText() == "BLUE") {
    arduinoConnection.stop_trng();
  }
}

GButton buttonBroadcast;
GButton buttonRed;
GButton buttonGreen;
GButton buttonBlue;
GButton buttonWhite;

GTextField signatureTextField;

public void createGUI() {
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("AetherOne Processing");
  int y = 20;
  signatureTextField = new GTextField(this, 28, y, 300, 20);
  y = addButton(buttonBroadcast, "BROADCAST", 28, y, 200, 46, "buttonClick");
  y = addButton(buttonRed, "RED", 28, y, 136, 46, "buttonClick");
  y = addButton(buttonGreen, "GREEN", 28, y, 136, 46, "buttonClick");
  y = addButton(buttonBlue, "BLUE", 28, y, 136, 46, "buttonClick");
  y = addButton(buttonWhite, "WHITE", 28, y, 136, 46, "buttonClick");
  
}

private int addButton(GButton button, String text, int x, int y, int w, int h, String callback) {
  y += 50;
  button = new GButton(this, x, y, w, h);
  button.setFont(g4p_controls.FontManager.getFont("Arial", 2, 20));
  button.setText(text);
  button.setTextBold();
  button.addEventHandler(this, callback);
  return y;
}

void serialEvent(Serial p) { 
  arduinoConnection.serialEvent(p);
} 
