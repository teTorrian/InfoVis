//class ZoomPoint implements Drawable {
//  Font font;
//  DragAndDropManager dragAndDropManager; 
// 
//  boolean updated = false;
//  boolean initialized = false;  
//  int left;
//  int top;
//  int width;
//  int height;
//  
//  ZoomPoint(View view, int left, int top, int width, int height) {
//    this.font = view.font;
//    this.dragAndDropManager = new DragAndDropManager();
//    
//    this.left = left;   
//    this.top = top;
//    this.width = width;
//    this.height = height;
//  }
//   boolean updated() {
//    return !initialized || updated || dragAndDropManager.dragging;
//  }
//  void update() {
//  }
//  
//  void draw() {
//    pushMatrix();
//      translate(left,top);
//      dragAndDropManager.saveMatrix();     
//      fill(200,0,0);
//      if (dragAndDropManager.dragging) {
//         fill(250,0,0);
//      }
//      rect(0,0,width,height);
//    popMatrix();
//    
//    updated = false;
//    
//    if (!initialized) {
//      initialized = true;
//    }
//  }
//  
//  boolean mouseOver(PVector mouse) {
//    PVector m = dragAndDropManager.transformVector(mouse);
//    return (m.x > left && m.x < width-left && m.y > top && m.y < height-top);
//  }
//  
//  boolean mousePressed() {
//    if (!dragAndDropManager.dragging && mouseOver(new PVector(float(mouseX),float(mouseY)))) {
//      dragAndDropManager.start();
//      updated = true;
//      loop();
//      return true;
//    }
//    return false;
//  }
//  
//  
//  boolean mouseReleased() {
//    if (dragAndDropManager.dragging) {
//      dragAndDropManager.stop();
//      updated = true;
//      loop();
//      return true;
//    }
//    return false;
//  }
//  
//  boolean mouseDragged() {
//    return false;
//  }
//  
//  boolean mouseMoved() {
//    return false;
//  }
//}
