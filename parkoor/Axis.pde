class Axis implements Drawable {
  
  int triangleSize = 6;

  Chart chart;
  AxisGroup axisGroup;
  Controller controller;
  DragAndDropManager dragAndDropManager;
  
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
    this.dragAndDropManager = new DragAndDropManager();
    
    this.x = x;
    this.label = label;
  }
  
  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  private void drawSliderMin() {
    pushMatrix();
      translate(0,floor(min*chart.getInnerHeight()));
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, -triangleSize, triangleSize, -triangleSize, 0, 0);
    popMatrix();
  }
  
  private void drawSliderMax() {
    pushMatrix();
      translate(0,max*chart.getInnerHeight());
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, triangleSize, triangleSize, triangleSize, 0, 0);
    popMatrix();
  }
  
  void update() {
  }
  
  void draw() {
    pushMatrix();
      translate(x,0);
      dragAndDropManager.saveMatrix();
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
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*min - triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  boolean isMouseOverMaxMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*max + triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  void mousePressed() {
    if (!dragAndDropManager.dragging && isMouseOverMinMark(new PVector(float(mouseX),float(mouseY)))) {
      draggingMax = false;
      dragAndDropManager.start();
      loop();
    } else if (!dragAndDropManager.dragging && isMouseOverMaxMark(new PVector(float(mouseX),float(mouseY)))) {
      draggingMax = true;
      dragAndDropManager.start();
      loop();
    }

  }
  
  
  void mouseReleased() {
    if (dragAndDropManager.dragging) {
      dragAndDropManager.stop();
    }
  }
  
  void mouseDragged() {
    if (dragAndDropManager.dragging) {
      if (draggingMax) {
        max = dragAndDropManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight();
        if (max < min) {
          max = min;
        } else if (max > 1) {
          max = 1;
        }
      } else {
        min = dragAndDropManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight();
        if (min < 0) {
          min = 0;
        } else if (min > max) {
          min = max;
        }
      }
    }
  }
}
