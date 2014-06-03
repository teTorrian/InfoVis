class View extends DrawableGroup {
  Chart chart;
  Controller controller;
  Font font;
  
  View(Controller controller, int x, int y, int width, int height) {
    this.controller = controller;
    this.font = new Font();

    textFont(font.bold22);
    
    
    chart = new Chart(this, x, y, width, height);
    add(chart); 
  }
}
