class BubbleAxis extends DrawableGroup<Drawable> {
  
  Chart chart;
  View view;
  Font font;
  DragAndDropManager dragAndDropManager;
  final float[] spacing = {
    5, 5
  };
  int x;
 
  
  BubbleAxis(Chart chart, int x) {
    this.chart = chart;
    this.font = chart.view.font;
    this.x = x;
    dragAndDropManager = new DragAndDropManager();
  }
  
  void draw() {
    pushMatrix();
      translate(x, 0);
      noFill();
      strokeWeight(1.0);
      stroke(200);
      dashline(0, chart.getInnerHeight(), 0, 0, spacing);
      super.draw();
    popMatrix();
  }
  
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
