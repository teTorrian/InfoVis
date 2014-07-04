class Calendar extends DrawableGroup<Drawable> {
  
  int left;
  int top;
  int width;
  int height;
  CalendarElement calendarElement;
  
  Calendar(View view, int left, int top, int width, int height) {
    super();
    this.width = width;
    this.height = height;
    this.left = left;
    this.top = top;
    calendarElement = new CalendarElement(view, 0,0,50,50);
    add(calendarElement);
  }
  
  void draw() {
    pushMatrix();
      translate(left,top);
      fill(200,200,200);
      rect(0,0,width,height);
      super.draw();
    popMatrix();
  }
  
}