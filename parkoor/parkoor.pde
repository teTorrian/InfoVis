Controller controller;
View view;

void setup(){ 
  	size(1024,600);

  	PFont font;
  	font = loadFont("UniversLTStd-LightCn-22.vlw");
  	textFont(font);
     
   controller = new Controller(100,165,824,330);
   view = controller.view;
   
} 
 
void draw() {
  view.update();
  if (view.updated()) {
    view.draw();
    fill(0);
    text("Parallele Koordinaten", 100, 100);
  } else {
    noLoop();
  }
}
