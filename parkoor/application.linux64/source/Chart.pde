class Chart extends DrawableGroup {

  int left;
  int top;
  int width;
  int height;

  int offsetX = 30;    // Abstand der Achsen zur linken Seite des Diagramms 
  int offsetY = 0;    // Abstand der Achsen zur oberen Seite des Diagramms 
  int offsetX2 = offsetX;   // Abstand der Achsen zur rechten Seite des Diagramms 
  int offsetY2 = offsetY;    // Abstand der Achsen zur unteren Seite des Diagramms 

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
  BubbleAxis nameAxis;
  BubbleAxis dateAxis;
  

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
    nameAxis = new BubbleAxis(this, 0);
    for (String name:model.getPeople()) {
      nameAxis.add(new PersonBubble(pathGroup, nameAxis, name.charAt(0)+"", name, pathGroup.pathColorHighlighted.get(name)));
    }
    dateAxis = new BubbleAxis(this, floor(getSpacing()));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Mo", 1, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Di", 2, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Mi", 3, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Do", 4, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Fr", 5, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Sa", 6, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "So", 7, color(230)));
    
    add(pathGroup);
    add(bifocalAxis);
    add(nameAxis);
    add(dateAxis);
    add(axisGroup);
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
    return getInnerWidth() / (model.getLocationCount() + 1);
  }
  
  float getPeopleSpacing() {
    return getInnerHeight() / (model.getPeople().size()-1);
  }
  
  float getDaySpacing() {
    return getInnerHeight() / 6;
  }
}

