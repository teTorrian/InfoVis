class BifocalPoint extends PVector implements Drawable {
  int hoverArea = 5;
  Font font;
  DragAndDropManager dragAndDropManager;
  BifocalAxis bifocalAxis; 
 
  boolean updated = false;
  boolean initialized = false;  
  boolean highlighted = false;
  
  BifocalPoint(BifocalAxis bifocalAxis, float x, float y) {
    super(x, y);
    this.dragAndDropManager = new DragAndDropManager();
    this.bifocalAxis = bifocalAxis;
  }
  
  float blurFactor() {
     return (float)bifocalAxis.getLayer()/(float)bifocalAxis.getRootDepth();
  }
  
  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  void update() {
  }
  
  void draw() {
    pushMatrix();
//      translate(bifocalAxis.getX(),0);
      float originY = bifocalAxis.demagnifyRecursively(bifocalAxis.originalPoint.y);
      dragAndDropManager.saveMatrix();  
      if (highlighted) {   
        fill(220,220,220,255*blurFactor());
      } else {
        fill(180,180,180,255*blurFactor());
      }
      noStroke();
      ellipseMode(CENTER);
      ellipse(this.x, this.y, 2*hoverArea, 2*hoverArea);
      fill(0,0);
      stroke(240,240,240);
      strokeWeight(1.0);
      bezier(hoverArea, this.y, 20, this.y, 10, originY, 30, originY);
      int minutes = (int) ((1- originY / bifocalAxis.chart.getInnerHeight())*1440);
      int hours = floor((float) minutes/ (float) (60));
      fill(200,255);
      minutes = minutes - 60*hours;
      text(hours+"h "+minutes+"m", 40, originY+5);
      float[] spacing = {
        3, 3
      };
      stroke(0,0,0,64);
      strokeWeight(1.0);
      bifocalAxis.dashline(0, this.y, -bifocalAxis.chart.width, this.y, spacing);
    popMatrix();
    
    updated = false;
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  boolean mouseOver(PVector m) {
    return (this.dist(m) < hoverArea);
  }
  
  boolean mousePressed() {
    PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
    if (!dragAndDropManager.dragging && mouseOver(m)) {
      dragAndDropManager.start();
      updated = true;
      loop();
      return true;
    } 
    return false;
  }
  
  
  boolean mouseReleased() {
    if (dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      dragAndDropManager.stop();
      if (abs(m.x) > 10) {
        bifocalAxis.clear();
      }
      bifocalAxis.updated = true;
      loop();
      return true;
    }
    return false;
  }
  
  boolean mouseDragged() {
    if (dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      if (m.y >= bifocalAxis.getMagnificationTop()+2*bifocalAxis.hoverArea && m.y <= bifocalAxis.getMagnificationBottom()-2*bifocalAxis.hoverArea) {
        this.y = m.y;
        if (abs(m.x) > 10) {
          this.x = m.x;
        } else {
          this.x = 0;
        }
        updated = true;
        loop();
        return true;
      }
    }
    return false;
  }
  
  boolean mouseMoved() {
    PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
    if (!dragAndDropManager.dragging && initialized) {
      if(mouseOver(m)) {
        highlighted = true;
        return true;
      } else {
        highlighted = false;
      }
    }
    return false;
  }
}
