class View extends DrawableGroup {
  Chart chart;
  Controller controller;
  
  View(Controller controller, int x, int y, int width, int height) {
    this.controller = controller;
    chart = new Chart(this, x, y, width, height);
    add(chart);
  }

}
