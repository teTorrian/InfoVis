class View extends DrawableGroup {
  Chart chart;
  Controller controller;
  Font font;
  int left;
  int top;
  int width;
  int height;
  int topicOffset = 120;
  float chartFrac = 0.7;
  float calendarOffset = 0.10;
  String topic = "Wo bin ich?";
  String subTopic = "Stunden pro Zeit und Ort";
  Calendar calendar;
  Faces faces;
  
  View(Controller controller, int left, int top, int width, int height) {
    this.controller = controller;
    this.font = new Font();
    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;
    chart = new Chart(this, 0, 0, round(width-width*(1-chartFrac)), height);
   
    faces = new Faces(round(width-width*(1-chartFrac-calendarOffset)), 0, round(width*(1-chartFrac-calendarOffset)), 80);
    calendar = new Calendar(this, round(width-width*(1-chartFrac-calendarOffset)), 100, round(width*(1-chartFrac-calendarOffset)), height-100);
    add(chart); 
    add(calendar);
    add(faces);
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
    
      super.draw();
    
    popMatrix();
  }

}
