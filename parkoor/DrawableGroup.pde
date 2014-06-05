class DrawableGroup<s extends Drawable> extends ArrayList<s> implements Drawable {
  boolean updated = false;
  
  DrawableGroup() {
  }
  
  boolean updated() {
    return updated;
  }
  
  void update() {
    updated = false;
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
  
  boolean mousePressed() {
    for (Drawable drawable: this) {
      if (drawable.mousePressed()) {
        return true;
      }
    }
    return false;
  }
  
  
  boolean mouseReleased() {
    for (Drawable drawable: this) {
      if (drawable.mouseReleased()) {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseDragged() {
    for (Drawable drawable: this) {
      if (drawable.mouseDragged()) {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseMoved() {
    for (Drawable drawable: this) {
      if (drawable.mouseMoved()) {
        return true;
      }
    }
    return false;
  }
}
