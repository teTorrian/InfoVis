class Axis implements Drawable {
  
  int triangleSize = 6;
  int textOffset = 14;
  int minMin = 0;
  int maxMax = 24;
  color lineColor = color(80,80,80); 
  color lineColorGrayed = color(200,200,200); 
  color markColor = color(0,0,0); 

  Chart chart;
  AxisGroup axisGroup;
  View view;
  Font font;
  DragAndDropManager dragAndDropManager;
  
  int x;
  String label;
  boolean updated = false;
  boolean initialized = false;
  float min = 0;
  float max = 24;
  boolean draggingMax = false;
  
  Axis(AxisGroup axisGroup, int x, String label) {
    this.axisGroup = axisGroup;
    this.chart = axisGroup.chart;
    this.view = chart.view;
    this.font = view.font;
    this.dragAndDropManager = new DragAndDropManager();
    
    this.x = x;
    this.label = label;
  }
  
  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  private void drawSliderMin() {
    pushMatrix();
      textFont(font.light14);
      textAlign(CENTER);
      translate(0,textOffset+chart.getInnerHeight()+textAscent());
      fill(0,0,0);
      noStroke();
      text(int(min), 0, 0);
      translate(0,textAscent()*2);
      text(label, 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,(1-((min-minMin)/(maxMax-minMin)))*chart.getInnerHeight());
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, triangleSize, triangleSize, triangleSize, 0, 0);
    popMatrix();
  }
  
  private void drawSliderMax() {
    pushMatrix();
      textFont(font.light14);
      textAlign(CENTER);
      translate(0,-textOffset);
      fill(markColor);
      noStroke();
      text(int(max), 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,(1-((max-minMin)/(maxMax-minMin)))*chart.getInnerHeight());
      fill(markColor);
      noStroke();
      triangle(-triangleSize, -triangleSize, triangleSize, -triangleSize, 0, 0);
    popMatrix();
  }
  
  void update() {
    updated = false;
  }
  
  void draw() {
    pushMatrix();
      translate(x,0);
      dragAndDropManager.saveMatrix();
      
      stroke(lineColorGrayed);
      strokeWeight(1.2);
      line(0,0,0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))));
      
      stroke(lineColor);
      strokeWeight(1.2);
      line(0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))),0,chart.getInnerHeight()*(1-((max-minMin)/(maxMax-minMin))));
      
      stroke(lineColorGrayed);
      strokeWeight(1.2);
      line(0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))),0,chart.getInnerHeight());
      
      drawSliderMin();
      drawSliderMax();
    popMatrix();
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  boolean isMouseOverMinMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))) + triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  boolean isMouseOverMaxMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*(1-((max-minMin)/(maxMax-minMin))) - triangleSize);
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
        max = minMin + (1-dragAndDropManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight())*(maxMax-minMin);
        if (max < min) {
          max = min;
        } else if (max > maxMax) {
          max = maxMax;
        }
      } else {
        min = minMin + (1-dragAndDropManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight())*(maxMax-minMin);
        if (min < minMin) {
          min = minMin;
        } else if (min > max) {
          min = max;
        }
      }
    }
  }
}
