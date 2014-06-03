class Chart extends DrawableGroup {
  
  int x;
  int y;
  int width;
  int height;
  PFont fontBold22;
  PFont fontLight12;  
  PFont fontLight14;
  PFont fontLight22;
  AxisGroup axisGroup;
  Controller controller;
  PathGroup pathGroup;
  View view;
  
  Chart(View view, int x, int y, int width, int height) {
    this.view = view;
    this.controller = view.controller;
    
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
   
    fontBold22  = loadFont("UniversLTStd-BoldCn-22.vlw");
    fontLight12 = loadFont("UniversLTStd-LightCn-12.vlw");
    fontLight14 = loadFont("UniversLTStd-LightCn-14.vlw");
    fontLight22 = loadFont("UniversLTStd-LightCn-22.vlw");
    
    axisGroup = new AxisGroup(this);
    add(axisGroup);
    
    pathGroup = new PathGroup(this);
    add(pathGroup);
  }
  void update() {
    super.update(); 
  }
  
  void draw() {
    background(255);
    pushMatrix();
      translate(x,y);
      noStroke();
      fill(230, 230, 230);
      rect(0,0,width,height);
      super.draw();
    popMatrix();
  }
  
}
