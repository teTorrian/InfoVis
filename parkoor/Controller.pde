class Controller {
  View view;
  Model model;
  JSONArray data;
  
  Controller(int x, int y, int width, int height) {
    model = new Model();
    data = model.getDataObjects();  
    
    view = new View(this, x, y, width, height);
  }
  
  
}
