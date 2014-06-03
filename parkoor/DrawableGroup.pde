class DrawableGroup<s extends Drawable> extends ArrayList<s> implements Drawable {
  
  boolean updated = false;
  
  DrawableGroup() {
  }

  
  boolean updated() {
    return updated;
  }
  
  void update() {

    for (Drawable drawable: this) {
      drawable.update();
      boolean itemUpdated = drawable.updated();
      if (!updated && itemUpdated) {
        updated = true;
      }
    }
  }
  
  void draw() {
    pushMatrix();
      for (Drawable drawable: this) {
        drawable.draw();
      }
    popMatrix();
  }
}
