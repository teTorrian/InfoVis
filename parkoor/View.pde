class View implements Drawable {
  Chart chart;
  
  View(int x, int y, int width, int height) {
    chart = new Chart(x, y, width, height);
  }
  
  boolean updated() {
    return chart.updated();
  }
  
  void update() {
    chart.update();
  }
  
  void draw() {
    chart.draw();
  }
}
