class Bubble implements Drawable {
  
  int bubbleRadius = 35;
  boolean active = false;
  
  BubbleAxis bubbelAxis;
  String label;
  boolean initialized;
  boolean updated;
  boolean highlighted;
  color highlightColor;
  DragAndDropManager dragAndDropManager;
  
  Bubble(BubbleAxis bubbelAxis, String label, color highlightColor) {
    this.bubbelAxis = bubbelAxis;
    this.label = label;
    this.highlightColor = highlightColor;
    dragAndDropManager = new DragAndDropManager();
  }
  
  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  void update() {
  }
  
  float getIndex() {
    return bubbelAxis.indexOf(this);
  }
  
  float getSize() {
    return bubbelAxis.size()-1;
  }
  
  float getY(){
    return bubbelAxis.chart.getInnerHeight()*(float)(getIndex()/getSize());
  }
  
  void draw() {
    pushMatrix();
      translate(0,getY());
      dragAndDropManager.saveMatrix();
      stroke(255);
      strokeWeight(2);
      fill(180,180);
      if (highlighted) {
        fill(highlightColor);
      }
      ellipseMode(CENTER);
      ellipse(0,0,bubbleRadius,bubbleRadius);
      
      fill(255,255);
      
      textFont(bubbelAxis.font.bold14);
      textAlign(CENTER, CENTER);
      text(label,0,0);
    popMatrix();
    
    updated = false;
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  boolean mouseOver() {
    PVector p0 = new PVector(0, 0);
    PVector p1 = dragAndDropManager.transformVector(new PVector(mouseX, mouseY));
    return (p0.dist(p1) < bubbleRadius*0.5);
  }
  
  boolean mousePressed() {
    return false;
  }
  
  
  boolean mouseReleased() {
    return false;
  }
  
  boolean mouseDragged() {
    return false;
  }
  
  boolean mouseMoved() {
    if (mouseOver()) {
      highlighted = true;
      updated = true;
      loop();
      return true;
    } else {
      highlighted = false;
      updated = true;
      loop();
      return false;
    }
  }
  
}
