class DragAndDropManager {
  PMatrix2D invertedMatrix;
  PMatrix2D matrix;
  boolean dragging = false;
  
  DragAndDropManager() {
  }
  
  /**
  * Speichert die akktuelle Matrix, um Touch-Eingaben ins Zeichen-Koordinaten-System umrechnen zu können
  */
  void saveMatrix() {
    this.matrix = new PMatrix2D(getMatrix());
    this.invertedMatrix = new PMatrix2D(getMatrix());
    invertedMatrix.invert();
  }

  /**
  * Rechnet eine Bildschirm-Koordinate ins ggf. transformierte Zeichen-Koordnaten-System um
  */
  PVector transformVector(PVector vector) {
    if (invertedMatrix != null) {
      return invertedMatrix.mult(vector, null);
    } else
      return vector;
  }
  
  void start() {
    dragging = true;
  }
  
  void stop() {
    dragging = false;
  }
}
