import controlP5.*;

ControlP5 cp5;

public class RadionicsElements {

  private PApplet p;
  private ControlFont font;
  private CColor c;

  public Integer startAtX;
  public Integer startAtY;
  public Integer usualWidth;
  public Integer usualHeight;

  public RadionicsElements(PApplet p) {
    
    this.p = p;
    cp5 = new ControlP5(p);
    
    PFont pfont = createFont("Arial", 20, true);
    font = new ControlFont(pfont, 20);
    
    c = new CColor();
    c.setBackground(color(43,0,118));
    c.setActive(color(0, 0, 0));
    c.setForeground(color(255, 125, 0));
  }

  public RadionicsElements addButton(String text) {

    addButton(text, 0, startAtX, startAtY, usualWidth, usualHeight);

    startAtY += usualHeight + 3;

    return this;
  }

  public void addButton(String text, int value, int x, int y, int w, int h) {
    cp5.addButton(text)
      .setFont(font)
      .setValue(value)
      .setPosition(x, y)
      .setSize(w, h)
      .setColor(c);
  }
}
