class Axis implements Drawable {
  
  int offset;

  Chart chart;
  int x;
  String label;
  boolean updated;
  int min;
  int max;
  
  Axis(Chart chart, int x, String label) {
    this.chart = chart;
    this.x = x;
    this.label = label;
  }
  
  boolean updated() {
    return updated;
  }
  
  void update() {
    updated = true;
  }
  
  void draw() {
    pushMatrix();
    translate(x,0);
    stroke(0);
    line(0,0,0,chart.height);
    popMatrix();
  }
}
