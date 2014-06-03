class Controller {
  View view;
  Model model;
  JSONArray data;
  
  Controller(int left, int top, int width, int height) {
    model = new Model();
    data = model.getDataObjects();  
    
    view = new View(this, left, top, width, height);
  }
  
  
}
