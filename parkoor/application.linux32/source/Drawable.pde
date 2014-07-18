interface Drawable {
  boolean updated();
  void update();
  void draw();
  boolean mousePressed();    // return true to stop the event-proagation
  boolean mouseMoved();      // return true to stop the event-proagation
  boolean mouseReleased();   // return true to stop the event-proagation
  boolean mouseDragged();    // return true to stop the event-proagation
}
