Controller controller;
View view;

void setup(){ 
  size(1400,700);
  
  controller = new Controller(100,200,width-200,height-350);
  view = controller.view;
} 
 
void draw() {
  view.update();
  if (view.updated()) {
    view.draw();
  } else {
    noLoop();
  }
}

void mousePressed() {
  view.mousePressed();
}


void mouseReleased() {
  view.mouseReleased();
}

void mouseDragged() {
  view.mouseDragged();
}

void mouseMoved() {
  view.mouseMoved();
}
