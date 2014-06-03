class DrawableGroup implements Drawable {
  
  ArrayList<Drawable> drawables;
  boolean updated = false;
  
  DrawableGroup() {
    drawables = new ArrayList<Drawable>();
    
  }
  
  void add(Drawable drawable) {
    drawables.add(drawable);
  }
  
  boolean updated() {
    return updated;
  }
  
  void update() {

    for (Drawable drawable: drawables) {
      drawable.update();
      boolean itemUpdated = drawable.updated();
      if (!updated && itemUpdated) {
        updated = true;
      }
    }
  }
  
  void draw() {
    pushMatrix();
      for (Drawable drawable: drawables) {
        drawable.draw();
      }
    popMatrix();
  }
}
