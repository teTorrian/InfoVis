class PolyfocalAxis extends DrawableGroup<Drawable> {

  int textOffset = 14;
  int hoverArea = 5;
  float[] spacing = {
    5, 5
  };

  Chart chart;
  Font font;
  DragAndDropManager dragAndDropManager;

  int x;
  String label;

  boolean updated = false;
  boolean initialized = false;
  PVector hoverPoint;
  ArrayList<PVector> polyfocalPoints;

  PolyfocalAxis(Chart chart, int x, String label) {
    this.chart = chart;
    this.font = chart.view.font;
    this.dragAndDropManager = new DragAndDropManager();

    this.x = x;
    this.label = label;
    polyfocalPoints = new ArrayList<PVector>();
  }

  float minutesAxisProjection(float value) {
    return chart.getInnerHeight() - (value/1440) * chart.getInnerHeight();
  }


  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }

  void update() {
  }

  void draw() {
    pushMatrix();
    translate(x, 0);
    dragAndDropManager.saveMatrix();

    strokeWeight(1.2);
    stroke(200, 200, 200);
    dashline(0, chart.getInnerHeight(), 0, 0, spacing);
    textFont(font.light14);
    textAlign(LEFT);
    fill(200, 200, 200);
    noStroke();
    text(label, 0, -14);

    if (hoverPoint != null) {
      ellipse(hoverPoint.x, hoverPoint.y, 2*hoverArea, 2*hoverArea);
    }

    fill(120, 120, 120);
    boolean first = false;
    for (PVector point : polyfocalPoints) {
      if (first) {
        first = false;
        fill(220, 220, 220);
      }  
      ellipse(point.x, point.y, 2*hoverArea, 2*hoverArea);
    }

    popMatrix();

    updated = false;

    if (!initialized) {
      initialized = true;
    }
  }

  boolean mouseOver(PVector m) {
    return (m.x > -hoverArea && m.x < hoverArea && m.y > 0 && m.y < chart.getInnerHeight());
  }

  boolean mousePressed() {
    PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
    if (!dragAndDropManager.dragging && mouseOver(m)) {
      dragAndDropManager.start();
      hoverPoint = null;
      polyfocalPoints.add(0, new PVector(0, m.y));
      updated = true;
      loop();
      return true;
    } 
    return false;
  }


  boolean mouseReleased() {
    if (dragAndDropManager.dragging) {
      dragAndDropManager.stop();

      updated = true;
      loop();
      return true;
    }
    return false;
  }

  boolean mouseDragged() {

    if (dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      polyfocalPoints.get(0).y = m.y;
      updated = true;
      loop();
      return true;
    }
    return false;
  }

  boolean mouseMoved() {
    if (!dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      if (mouseOver(m)) {
        hoverPoint = new PVector(0, m.y);
        updated = true;
        loop();
      } else if (hoverPoint != null) {
        hoverPoint = null;
        updated = true;
        loop();
      }
    }
    return false;
  }

  /* 
   * Draw a dashed line with given set of dashes and gap lengths. 
   * x0 starting x-coordinate of line. 
   * y0 starting y-coordinate of line. 
   * x1 ending x-coordinate of line. 
   * y1 ending y-coordinate of line. 
   * spacing array giving lengths of dashes and gaps in pixels; 
   *  an array with values {5, 3, 9, 4} will draw a line with a 
   *  5-pixel dash, 3-pixel gap, 9-pixel dash, and 4-pixel gap. 
   *  if the array has an odd number of entries, the values are 
   *  recycled, so an array of {5, 3, 2} will draw a line with a 
   *  5-pixel dash, 3-pixel gap, 2-pixel dash, 5-pixel gap, 
   *  3-pixel dash, and 2-pixel gap, then repeat. 
   */
  void dashline(float x0, float y0, float x1, float y1, float[ ] spacing) 
  { 
    float distance = dist(x0, y0, x1, y1); 
    float [ ] xSpacing = new float[spacing.length]; 
    float [ ] ySpacing = new float[spacing.length]; 
    float drawn = 0.0;  // amount of distance drawn 

    if (distance > 0) 
    { 
      int i; 
      boolean drawLine = true; // alternate between dashes and gaps 

      /* 
       Figure out x and y distances for each of the spacing values 
       I decided to trade memory for time; I'd rather allocate 
       a few dozen bytes than have to do a calculation every time 
       I draw. 
       */
      for (i = 0; i < spacing.length; i++) 
      { 
        xSpacing[i] = lerp(0, (x1 - x0), spacing[i] / distance); 
        ySpacing[i] = lerp(0, (y1 - y0), spacing[i] / distance);
      } 

      i = 0; 
      while (drawn < distance) 
      { 
        if (drawLine) 
        { 
          line(x0, y0, x0 + xSpacing[i], y0 + ySpacing[i]);
        } 
        x0 += xSpacing[i]; 
        y0 += ySpacing[i]; 
        /* Add distance "drawn" by this line or gap */
        drawn = drawn + mag(xSpacing[i], ySpacing[i]); 
        i = (i + 1) % spacing.length;  // cycle through array 
        drawLine = !drawLine;  // switch between dash and gap
      }
    }
  }
}

