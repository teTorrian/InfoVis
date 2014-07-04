class Face implements Drawable {
  
  int left;
  int top;
  
  int x;
  String label;
  String name;
  
  Chart chart;
  Faces faces;
  View view;
  Font font;
  DragAndDropManager dragAndDropManager;
  LocationFilter locationFilter;
  
  Face(Faces faces) {
    this.faces = faces;
    //this.chart = faces.chart;
    //this.view = chart.view;
    //this.font = view.font;
    //this.dragAndDropManager = new DragAndDropManager();
    
    //this.x = x;
    //this.label = label;
    //this.name = name;
    //locationFilter = new LocationFilter(min, max, name);
  }
  
  boolean updated() {
    
    return false;
  }
  
  void update() {
  }
  
  void draw() {
    pushMatrix();
      translate(left,top);
      fill(233,233,233);
      ellipse(0, 0, 55, 55);
    popMatrix();
  }
  
  boolean mousePressed() {
    
    return true;
  }    // return true to stop the event-proagation
  
  boolean mouseMoved() {
    
    return true;
  }    // return true to stop the event-proagation
  
  boolean mouseReleased() {
   
    return true;
  }   // return true to stop the event-proagation
  
  boolean mouseDragged() {
    
    return true;
  }    // return true to stop the event-proagation
      


}
