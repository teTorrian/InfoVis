class View implements Drawable {
  Chart chart;
  AxisManager axisManager;
  
  View(int x, int y, int width, int height) {
    chart = new Chart(x, y, width, height);
    axisManager = new AxisManager(chart);
    chart.add(axisManager);
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
