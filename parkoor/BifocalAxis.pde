class BifocalAxis extends DrawableGroup<Drawable> {

  int textOffset = 14;
  int hoverArea = 5;
  int normalDashSize = 5;

  Chart chart;
  Font font;
  DragAndDropManager dragAndDropManager;

  int x;
  boolean secondHalf = false;
  String label;

  boolean updated = false;
  boolean initialized = false;
  PVector hoverPoint;
  BifocalAxis parent;
  BifocalAxis root;
  BifocalAxis topChild;
  BifocalAxis bottomChild;
  BifocalPoint parentPoint;
  BifocalPoint point;
  float blurFactor = 1.0;
  
  PVector startPoint;

  BifocalAxis(Chart chart, int x, String label) {
    this.chart = chart;
    this.font = chart.view.font;
    this.dragAndDropManager = new DragAndDropManager();
    root = this;
    this.x = x;
    this.label = label;
  }
  
  BifocalAxis(BifocalAxis parent, BifocalAxis root, BifocalPoint parentPoint, boolean secondHalf) {
    this.chart = parent.chart;
    this.root = root;
    this.font = chart.view.font;
//    this.dragAndDropManager = parent.dragAndDropManager;
    this.dragAndDropManager = new DragAndDropManager();
    this.parent = parent;
    this.secondHalf = secondHalf;
    this.parentPoint = parentPoint;
  }
  
  String getLabel() {
    if (parent != null) {
      return parent.getLabel();
    } else
      return label;
  }
  
  float getX() {
    if (parent != null) {
      return parent.getX();
    } else
      return x;
  }
  
  float getTop() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getTop();
      } else {
        return parentPoint.y;
      }
    } else
      return 0;
  }
  
  float getBottom() {
    if (parent != null) {
      if (secondHalf) {
        return parent.getBottom();
      } else {
        return parentPoint.y;
      }
    } else
      return chart.getInnerHeight();
  }
  
  float getStretchFactor() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getStretchFactor()*(getBottom()-getTop())/(parent.startPoint.y-getTop());
      } else {
        return parent.getStretchFactor()*(getBottom()-getTop())/(getBottom()-parent.startPoint.y);
      }
    } else
      return 1.0;
  }
  
  float getDashSize() {
     float dash = normalDashSize*getStretchFactor();
     if (dash > (getBottom()-getTop()))
       dash = (getBottom()-getTop());
     return dash;
  }
  
  boolean isLastBranch() {
    return ((topChild == null || topChild.size() == 0) && (bottomChild == null || bottomChild.size() == 0));
  }
  
  int getLayer() {
    if (parent == null) {
      return 1;
    } else {
      return parent.getLayer()+1;
    }
  }
  
  int countDepth(int current) {
    if (topChild != null && bottomChild != null) {
      current++;
      int bottomDepth = bottomChild.countDepth(current);
      int topDepth = topChild.countDepth(current);
      if (topDepth > bottomDepth)
        return topDepth;
      else
        return bottomDepth;
    } else {
      return current;
    }
  }
  
  int getRootDepth() {
    return root.countDepth(1);
  }
  

  float minutesAxisProjection(float value) {
    return chart.getInnerHeight() - (value/1440) * chart.getInnerHeight();
  }


  boolean updated() {
    return super.updated() || !initialized || updated || dragAndDropManager.dragging;
  }

  void update() {
  }

  void draw() {
    pushMatrix();
    
      if (parent == null) {
        translate(getX(), 0);
//        dragAndDropManager.saveMatrix();
        textFont(font.light14);
        textAlign(LEFT);
        fill(200, 200, 200);
        noStroke();
        text(getLabel(), 0, -14);
      } else {
      
//        translate (getStretchFactor()*10,0);
//        dragAndDropManager.saveMatrix();
      }
      dragAndDropManager.saveMatrix();

      if (size() == 0) {
        // leaf
        
        float[] spacing = {
            getDashSize(), getDashSize()
          };
        strokeWeight(1.2);
        stroke(200, 200, 200);
        if (parent == null) {
          dashline(0, getBottom(), 0, getTop(), spacing);
        } else {
          dashline(0, getBottom()-hoverArea, 0, getTop()+hoverArea, spacing);
        }
       
        
        if (hoverPoint != null) {
          
          noStroke();
          ellipseMode(CENTER);
          ellipse(hoverPoint.x, hoverPoint.y, 2*hoverArea, 2*hoverArea);
        }
        
        super.draw();
      } else {
        // branch
        super.draw();
//        if (point.dragAndDropManager.dragging) {
//          stroke(200, 200, 200, 50);
////          noStroke();
//          fill(255,255,255,255);
//          ellipseMode(CENTER);
//          ellipse(startPoint.x, startPoint.y, hoverArea*2, hoverArea*2);
//        }
        
      }
  
    popMatrix();
  
    updated = false;
  
    if (!initialized) {
      initialized = true;
    }
  }

  boolean mouseOver(PVector m) {
    return (m.x > -hoverArea && m.x < hoverArea && m.y > getTop() + hoverArea && m.y < getBottom()-hoverArea);
  }

  boolean mousePressed() {
    if (!super.mousePressed() && isLastBranch()) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      if (mouseOver(m)) {
        startPoint = hoverPoint;
        point = null;
        point = new BifocalPoint(this, 0, m.y);
        add(point);
        point.dragAndDropManager.matrix = dragAndDropManager.matrix;
        point.dragAndDropManager.invertedMatrix = dragAndDropManager.invertedMatrix;
        point.dragAndDropManager.start();
        topChild = new BifocalAxis(this, root, point, false);
        bottomChild = new BifocalAxis(this, root, point, true);
        add(topChild);
        add(bottomChild);
//        updated = true;
//        loop();
        return true;
      } 
    }
    return false;
  }


  boolean mouseMoved() {
    if (!super.mouseMoved() && isLastBranch()) {
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
    } else if (hoverPoint != null) {
      hoverPoint = null;
      updated = true;
      loop();
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

