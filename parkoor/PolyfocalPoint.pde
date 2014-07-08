class PolyfocalPoint extends PVector implements Drawable {
  int hoverArea = 5;
  Font font;
  DragAndDropManager dragAndDropManager;
  PolyfocalAxis polyfocalAxis; 
 
  boolean updated = false;
  boolean initialized = false;  
  boolean highlighted = false;
  
  PolyfocalPoint(PolyfocalAxis polyfocalAxis, float x, float y) {
    super(x, y);
    this.dragAndDropManager = new DragAndDropManager();
    this.polyfocalAxis = polyfocalAxis;
  }
  
  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  void update() {
  }
  
  void draw() {
    pushMatrix();
      //translate(x,y);
      dragAndDropManager.saveMatrix();  
      if (highlighted) {   
        fill(200,200,200);
      } else {
        fill(180,180,180);
      }
      ellipseMode(CENTER);
      ellipse(this.x, this.y, 2*hoverArea, 2*hoverArea);
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
      dragAndDropManager.stop();
      updated = true;
      loop();
      return true;
    }
    return false;
  }
  
  boolean mouseDragged() {
    if (dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      this.y = m.y;
      updated = true;
      loop();
      return true;
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
