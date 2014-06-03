class MatrixManager {
  PMatrix2D invertedMatrix;
  PMatrix2D matrix;
  boolean dragging = false;
  
  MatrixManager() {
    save();
  }
  
  /**
  * Speichert die akktuelle Matrix, um Touch-Eingaben ins Zeichen-Koordinaten-System umrechnen zu können
  */
  void save() {
    this.matrix = new PMatrix2D(getMatrix());
    this.invertedMatrix = new PMatrix2D(getMatrix());
    invertedMatrix.invert();
    invertedMatrix.print();
  }

  /**
  * Rechnet eine Bildschirm-Koordinate ins ggf. transformierte Zeichen-Koordnaten-System um
  */
  PVector transformVector(PVector vector) {
    return invertedMatrix.mult(vector, null);
  }
  
  void start() {
    dragging = true;
  }
  
  void stop() {
    dragging = false;
  }
}
