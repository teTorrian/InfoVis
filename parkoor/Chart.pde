class Chart extends DrawableGroup {
  
  int x;
  int y;
  int width;
  int height;
  
  int offsetX = 40;    // Abstand der Achsen zur linken Seite des Diagramms 
  int offsetY = 0;    // Abstand der Achsen zur oberen Seite des Diagramms 
  int offsetX2 = 40;   // Abstand der Achsen zur rechten Seite des Diagramms 
  int offsetY2 = 0;    // Abstand der Achsen zur unteren Seite des Diagramms 

  AxisGroup axisGroup;
  Controller controller;
  PathGroup pathGroup;
  IntDict pathColor; // ein verrückter Processing-Datentyp, wie Map<String, int>
  View view;
  
  Chart(View view, int x, int y, int width, int height) {
    super();
    this.view = view;
    this.controller = view.controller;
    
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    
    axisGroup = new AxisGroup(this);
    add(axisGroup);
    
    pathColor = new IntDict();
    pathColor.set("Jonas", color(#B0285D));
    pathColor.set("Christian", color(#E84A38));
    pathColor.set("Vlad", color(#07D962));
    pathColor.set("Lukas", color(#0E7BDD));
    
    pathGroup = new PathGroup(this);
    add(pathGroup);
  }
  
  int getInnerWidth() {
    return width - offsetX - offsetX2;
  }
  
  int getInnerHeight() {
    return height - offsetY - offsetY2;
  }
  
  void update() {
    super.update();
  }
  
  void draw() {
    background(255);
    pushMatrix();
      translate(x,y);
      noStroke();
      fill(255);
      rect(0,0,width,height);
      translate(offsetX, offsetY);
      super.draw();
    popMatrix();
  }
  
  
}
