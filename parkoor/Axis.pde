class Axis implements Drawable {
  
  int triangleSize = 5;

  Chart chart;
  AxisGroup axisGroup;
  Controller controller;
  MatrixManager matrixManager;
  
  int x;
  String label;
  boolean updated = false;
  boolean initialized = false;
  float min = 0;
  float max = 1;
  boolean draggingMax = false;
  
  Axis(AxisGroup axisGroup, int x, String label) {
    this.axisGroup = axisGroup;
    this.chart = axisGroup.chart;
    this.controller = chart.controller;
    this.matrixManager = new MatrixManager();
    
    this.x = x;
    this.label = label;
  }
  
  boolean updated() {
    return !initialized || updated || matrixManager.dragging;
  }
  
  private void drawSliderMin() {
    pushMatrix();
      translate(0,floor(min*chart.getInnerHeight()));
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, 0, triangleSize, 0, 0, triangleSize);
    popMatrix();
  }
  
  private void drawSliderMax() {
    pushMatrix();
      translate(0,max*chart.getInnerHeight());
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, 0, triangleSize, 0, 0, -triangleSize);
    popMatrix();
  }
  
  void update() {
    pushMatrix();
      translate(x,0);
      matrixManager.saveMatrix();
    popMatrix();
      
    if (matrixManager.dragging) {
      if (draggingMax) {
        println(min);
        max = matrixManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight();
      } else {
        println(min);
        min = matrixManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight();
      }
    }
  }
  
  void draw() {
    pushMatrix();
      translate(x,0);
      stroke(0);
      line(0,0,0,chart.getInnerHeight());
      drawSliderMin();
      drawSliderMax();
    popMatrix();
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  boolean isMouseOverMinMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*min);
    PVector p1 = matrixManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  boolean isMouseOverMaxMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*max);
    PVector p1 = matrixManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  void mousePressed() {
    if (!matrixManager.dragging && isMouseOverMinMark(new PVector(float(mouseX),float(mouseY)))) {
      draggingMax = false;
      matrixManager.start();
      loop();
    } else if (!matrixManager.dragging && isMouseOverMaxMark(new PVector(float(mouseX),float(mouseY)))) {
      draggingMax = true;
      matrixManager.start();
      loop();
    }
    
    
  }
  
  
  void mouseReleased() {
    if (matrixManager.dragging) {
      matrixManager.stop();
    }
  }
  
  void mouseDragged() {
    if (matrixManager.dragging) {
      
    }
  }
}
