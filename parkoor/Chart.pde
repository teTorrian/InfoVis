class Chart extends DrawableGroup {

  int left;
  int top;
  int width;
  int height;

  int offsetX = 50;    // Abstand der Achsen zur linken Seite des Diagramms 
  int offsetY = 0;    // Abstand der Achsen zur oberen Seite des Diagramms 
  int offsetX2 = 50;   // Abstand der Achsen zur rechten Seite des Diagramms 
  int offsetY2 = 0;    // Abstand der Achsen zur unteren Seite des Diagramms 

  int topicOffset = 100;
  String topic = "Wo bin ich?";
  String subTopic = "Stunden pro Tag und Ort";
  Model model;

  AxisGroup axisGroup;
  Controller controller;
  PathGroup pathGroup;
  BifocalAxis bifocalAxis;
  View view;
  Font font;

  Chart(View view, int left, int top, int width, int height) {
    super();
    this.view = view;
    this.controller = view.controller;
    this.model = controller.model;
    this.font = view.font;

    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;

    axisGroup = new AxisGroup(this);
    pathGroup = new PathGroup(this);
    bifocalAxis = new BifocalAxis(this, width-offsetX, "Zoom");
    
    add(pathGroup);
    add(axisGroup);
    add(bifocalAxis);
//    add(new BifocalAxis(this, 0-offsetX, ""));
  }

  int getInnerWidth() {
    return width - offsetX - offsetX2;
  }

  int getInnerHeight() {
    return height - offsetY - offsetY2;
  }

  void update() {
    super.update();
  }

  void draw() {
    background(255);
    pushMatrix();
    translate(left, top);
    fill(0);

    pushMatrix();
    textAlign(LEFT);
    translate(0, -topicOffset);
    textFont(view.font.bold22);
    text(topic, 0, 0);
    translate(0, textAscent()*1.8);
    textFont(view.font.light20);
    text(subTopic, 0, 0);
    popMatrix();

    translate(offsetX, offsetY);
    super.draw();
    popMatrix();
  }

  float getSpacing() {
    return getInnerWidth()/(model.getLocationCount()-1);
  }
}

