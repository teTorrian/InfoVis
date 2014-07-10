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
  PVector originalPoint;
  BifocalPoint magnificationPoint;
  float blurFactor = 1.0;

  BifocalAxis(Chart chart, int x, String label) {
    this.chart = chart;
    this.font = chart.view.font;
    this.dragAndDropManager = new DragAndDropManager();
    root = this;
    this.x = x;
    this.label = label;
  }

  BifocalAxis(BifocalAxis parent, BifocalAxis root, boolean secondHalf) {
    this.chart = parent.chart;
    this.root = root;
    this.font = chart.view.font;
    //    this.dragAndDropManager = parent.dragAndDropManager;
    this.dragAndDropManager = new DragAndDropManager();
    this.parent = parent;
    this.secondHalf = secondHalf;
    this.x = parent.x;
  }

  String getLabel() {
    if (parent != null) {
      return parent.getLabel();
    } else
      return label;
  }

  int getX() {
    //    if (parent != null) {
    //      return parent.getX();
    //    } else
    return x;
  }

  float getOriginalTop() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getOriginalTop();
      } else {
        return parent.originalPoint.y;
      }
    } else
      return 0;
  }

  float getOriginalBottom() {
    if (parent != null) {
      if (secondHalf) {
        return parent.getOriginalBottom();
      } else {
        return parent.originalPoint.y;
      }
    } else
      return chart.getInnerHeight();
  }

  float getOriginalHeight() {
    return abs(getOriginalBottom() - getOriginalTop());
  }

  float getMagnificationTop() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getMagnificationTop();
      } else {
        return parent.magnificationPoint.y;
      }
    } else
      return 0;
  }

  float getMagnificationBottom() {
    if (parent != null) {
      if (secondHalf) {
        return parent.getMagnificationBottom();
      } else {
        return parent.magnificationPoint.y;
      }
    } else
      return chart.getInnerHeight();
  }

  float getMagnificationHeight() {
    return abs(getMagnificationBottom() - getMagnificationTop());
  }

  float getStretchFactor() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getStretchFactor()*(getMagnificationBottom()-getMagnificationTop())/(parent.originalPoint.y-getMagnificationTop());
      } else {
        return parent.getStretchFactor()*(getMagnificationBottom()-getMagnificationTop())/(getMagnificationBottom()-parent.originalPoint.y);
      }
    } else
      return 1.0;
  }

  float getDashSize() {
    float dash = normalDashSize*getStretchFactor();
    if (dash > (getMagnificationBottom()-getMagnificationTop()))
      dash = (getMagnificationBottom()-getMagnificationTop());
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
  
  
  float magnify(float value) {
    return getMagnificationTop() +
          getMagnificationHeight() * (   ( value - getOriginalTop() ) / getOriginalHeight()   );
  }

  float magnifyRecursively(float value) {
    
    float magY = magnify(value);
    
    if (topChild != null && bottomChild != null) {
      
      // magnitude + recurse into responsable child 
      
      if (magY < originalPoint.y) {
        return topChild.magnifyRecursively(magY);
        
      } else {
        return bottomChild.magnifyRecursively(magY);
      }
        
    } else {
      return magY;
    }
    
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
      //      dragAndDropManager.saveMatrix();
      textFont(font.light14);
      textAlign(LEFT);
      fill(200, 200, 200);
      noStroke();
      text(getLabel(), 0, -14);
    } else {

      //      translate (8,0);
      //      dragAndDropManager.saveMatrix();
    }
    dragAndDropManager.saveMatrix();

    if (size() == 0) {
      // leaf

      float[] spacing = {
        getDashSize(), getDashSize()
        };

      float[] normalSpacing = {
        3, 3
      };


      strokeWeight(1.2);
      stroke(200, 200, 200);
      
      if (parent == null) {
        dashline(0, getMagnificationBottom(), 0, getMagnificationTop(), spacing);
      } else {
        dashline(0, getMagnificationBottom()-hoverArea, 0, getMagnificationTop()+hoverArea, spacing);
//        line(-13, getOriginalBottom()-hoverArea, 0, getMagnificationBottom()-hoverArea);
//        line(-13, getOriginalTop()+hoverArea, 0, getMagnificationTop()+hoverArea);
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
      if (magnificationPoint.dragAndDropManager.dragging) {
        stroke(180, 180, 180, 255*magnificationPoint.blurFactor());
        //          noStroke();
        fill(255, 255, 255, 255);
        ellipseMode(CENTER);
        ellipse(originalPoint.x, originalPoint.y, hoverArea*2, hoverArea*2);
      }
    }




    popMatrix();
   

    updated = false;

    if (!initialized) {
      initialized = true;
    }
  }

  boolean mouseOver(PVector m) {
    return (m.x > -hoverArea && m.x < hoverArea && m.y > getMagnificationTop() + hoverArea && m.y < getMagnificationBottom()-hoverArea);
  }

  boolean mousePressed() {
    if (!super.mousePressed() && isLastBranch()) {
      PVector m = dragAndDropManager.transformVector(new PVector(float(mouseX), float(mouseY)));
      if (mouseOver(m)) {
        originalPoint = hoverPoint;
        magnificationPoint = null;
        magnificationPoint = new BifocalPoint(this, 0, m.y);
        add(magnificationPoint);
        magnificationPoint.dragAndDropManager.matrix = dragAndDropManager.matrix;
        magnificationPoint.dragAndDropManager.invertedMatrix = dragAndDropManager.invertedMatrix;
        magnificationPoint.dragAndDropManager.start();
        topChild = new BifocalAxis(this, root, false);
        bottomChild = new BifocalAxis(this, root, true);
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

