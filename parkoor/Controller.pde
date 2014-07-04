class Controller {
  View view;
  Model model;
  JSONArray data;
  
  Controller(int left, int top, int width, int height) {
    model = new Model("data.json");
    //view = new View(this, 100,165,824,330);
    view = new View(this, left,top,width,height);
  }
  
  
}
