class View extends DrawableGroup {
  Chart chart;
  Controller controller;
  Font font;
  
  View(Controller controller, int left, int top, int width, int height) {
    this.controller = controller;
    this.font = new Font();
   
    chart = new Chart(this, left, top, width, height);
    add(chart); 
  }

}
