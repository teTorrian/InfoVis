class DrawableGroup<s extends Drawable> extends ArrayList<s> implements Drawable {
  boolean updated = false;
  
  DrawableGroup() {
  }
  
  boolean updated() {
    for (Drawable drawable: this) {
      if (drawable.updated()) {
        return true;
      }
    }
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
    for (Drawable drawable: this) {
      drawable.draw();
    }
  }
  
  boolean mousePressed() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mousePressed()) {
        return true;
      }
    }
    return false;
  }
  
  
  boolean mouseReleased() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mouseReleased()) {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseDragged() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mouseDragged()) {
        return true;
      }
    }
    return false;
  }
  
  boolean mouseMoved() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mouseMoved()) {
        return true;
      }
    }
    return false;
  }
}
