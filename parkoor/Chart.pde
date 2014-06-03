class Chart extends DrawableGroup {
  
  int x;
  int y;
  int width;
  int height;
  AxisManager axisManager;
  PFont fontBold22;
  PFont fontLight12;  
  PFont fontLight14;
  PFont fontLight22;
  
  Chart(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
   
    fontBold22  = loadFont("UniversLTStd-BoldCn-22.vlw");
    fontLight12 = loadFont("UniversLTStd-LightCn-12.vlw");
    fontLight14 = loadFont("UniversLTStd-LightCn-14.vlw");
    fontLight22 = loadFont("UniversLTStd-LightCn-22.vlw");
    
    axisManager = new AxisManager(this);
    add(axisManager);
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
