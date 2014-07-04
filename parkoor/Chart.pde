class Chart extends DrawableGroup {

  int left;
  int top;
  int width;
  int height;

  int offsetX = 50;    // Abstand der Achsen zur linken Seite des Diagramms 
  int offsetY = 0;    // Abstand der Achsen zur oberen Seite des Diagramms 
  int offsetX2 = 50;   // Abstand der Achsen zur rechten Seite des Diagramms 
  int offsetY2 = 0;    // Abstand der Achsen zur unteren Seite des Diagramms 

  int topicOffset = 100;
  String topic = "Wo bin ich?";
  String subTopic = "Stunden pro Zeit und Ort";
  Model model;

  AxisGroup axisGroup;
  Controller controller;
  PathGroup pathGroup;
  View view;
  Font font;

  Chart(View view, int left, int top, int width, int height) {
    super();
    this.view = view;
    this.controller = view.controller;
    this.model = controller.model;
    this.font = view.font;

    this.left = left;
    this.top = top;
    this.width = width;
    this.height = height;

    axisGroup = new AxisGroup(this);
    

    pathGroup = new PathGroup(this);
    add(pathGroup);
    add(axisGroup);
  }

  int getInnerWidth() {
    return width - offsetX - offsetX2;
  }

  int getInnerHeight() {
    return height - offsetY - offsetY2;
  }

  void update() {
    super.update();
  }

  void draw() {
    background(255);
    pushMatrix();
    translate(left, top);
    fill(0);

    pushMatrix();
    textAlign(LEFT);
    translate(0, -topicOffset);
    textFont(view.font.bold22);
    text(topic, 0, 0);
    translate(0, textAscent()*1.8);
    textFont(view.font.light20);
    text(subTopic, 0, 0);
    popMatrix();
    

    float[] spacing = {
      5, 5
    };
    strokeWeight(1.2);
    stroke(200, 200, 200);
    dashline(0, offsetY, 0, getInnerHeight(), spacing);
    dashline(width, offsetY, width, getInnerHeight(), spacing);
    textFont(font.light14);
    textAlign(LEFT);
    fill(200,200,200);
    noStroke();
    text("Stunden", width, -14);

    translate(offsetX, offsetY);
    super.draw();
    popMatrix();
  }
  
  float getSpacing() {
    return getInnerWidth()/(model.getLocationCount()-1);
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

