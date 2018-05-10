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

  Dong[][] d;
  int nx = 10;
  int ny = 10;

  public RadionicsElements(PApplet p) {

    this.p = p;
    cp5 = new ControlP5(p);

    PFont pfont = createFont("Arial", 18, true);
    font = new ControlFont(pfont, 18);

    c = new CColor();
    c.setBackground(color(43, 0, 118));
    c.setActive(color(0, 0, 0));
    c.setForeground(color(255, 125, 0));
  }

  public RadionicsElements initPeggotty(int xx, int yy) {
    //cp5.printPublicMethodsFor(Matrix.class);

    cp5.addMatrix("peggotty")
      .setPosition(xx, yy)
      .setSize(200, 200)
      .setGrid(nx, ny)
      .setGap(2, 2)
      .setInterval(144)
      .setMode(ControlP5.MULTIPLES)
      .setColorBackground(color(20))
      .setBackground(color(200));

    cp5.getController("peggotty").getCaptionLabel().setFont(font).alignX(CENTER);

    // use setMode to change the cell-activation which by 
    // default is ControlP5.SINGLE_ROW, 1 active cell per row, 
    // but can be changed to ControlP5.SINGLE_COLUMN or 
    // ControlP5.MULTIPLES

    d = new Dong[nx][ny];
    for (int x = 0; x<nx; x++) {
      for (int y = 0; y<ny; y++) {
        d[x][y] = new Dong();
      }
    }  
    noStroke();
    smooth();
    
    return this;
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
