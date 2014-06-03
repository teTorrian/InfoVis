class Controller {
  View view;
  Controller(int x, int y, int width, int height) {
    view = new View(this, x, y, width, height);
  }
}
