class Calendar extends DrawableGroup<Drawable> {
  
  int left;
  int top;
  int width;
  int height;
  
  Calendar(int left, int top, int width, int height) {
    super();
    this.width = width;
    this.height = height;
    this.left = left;
    this.top = top;
  }
  
  void draw() {
    pushMatrix();
      translate(left,top);
      fill(200,200,200);
      rect(0,0,width,height);
    popMatrix();
  }
  
}
