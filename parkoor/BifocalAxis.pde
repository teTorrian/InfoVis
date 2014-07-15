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
        return parent.getMagnificationTop();
      } else {
        return parent.originalPoint.y;
      }
    } else
      return 0;
  }

  float getOriginalBottom() {
    if (parent != null) {
      if (secondHalf) {
        return parent.getMagnificationBottom();
      } else {
        return parent.originalPoint.y;
      }
    } else
      return chart.getInnerHeight();
  }

  float getOriginalHeight() {
    return getOriginalBottom() - getOriginalTop();
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
    return getMagnificationBottom() - getMagnificationTop();
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
  
  float getMaxStretchFactor() {
    if (topChild != null && bottomChild != null) {
      float topFactor = topChild.getMaxStretchFactor();
      float bottomFactor = bottomChild.getMaxStretchFactor();
      if (topFactor > bottomFactor) {
        return topFactor;
      } else {
        return bottomFactor;
      }
    } else {
      return getStretchFactor();
    }
  }
  
  float rootMaxStretchFactor() {
    return root.getMaxStretchFactor();
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

  int depth(int current) {
    if (topChild != null && bottomChild != null) {
      current++;
      int topDepth = topChild.depth(current);
      int bottomDepth = bottomChild.depth(current);
      if (topDepth > bottomDepth) {
        return topDepth;
      } else {
        return bottomDepth;
      }
    } else {
      return current;
    }
  }

  int getRootDepth() {
    return root.depth(1);
  }
  
  float highlightingDimension() {
    float rootDepth = (float) getRootDepth();
     return (rootDepth - (float) getLayer()/rootDepth);
  }


  float magnify(float value) {
    return getMagnificationTop() +
      getMagnificationHeight() * (   ( value - getOriginalTop() ) / getOriginalHeight()   );
  }
  
  float demagnify(float value) {
    return getOriginalTop() +
      getOriginalHeight() * (   ( value - getMagnificationTop() ) / getMagnificationHeight()   );
  }

  float magnifyRecursively(float value) {
    
    float mag = magnify(value);
   
    if (topChild != null && bottomChild != null) {
      if (mag < originalPoint.y) {
        return topChild.magnifyRecursively(mag);
      } else {
        return bottomChild.magnifyRecursively(mag);
      }
    } else
      return mag;

  }
  
  float demagnifyRecursively(float value) {
    
    float demag = demagnify(value);
    
    if (parent != null) {
        return parent.demagnifyRecursively(demag);
    } else
      return demag;

  }
  
  void clear() {
    
    if (topChild != null) {
      topChild.parent = null;
      topChild.root = null;
      if (topChild.magnificationPoint != null)
        topChild.magnificationPoint.bifocalAxis = null;
      topChild.clear();
    }
    if (bottomChild != null) {
      bottomChild.parent = null;
      bottomChild.root = null;
      if (bottomChild.magnificationPoint != null)
        bottomChild.magnificationPoint.bifocalAxis = null;
      bottomChild.clear();
    }
    topChild = null;
    bottomChild = null;
    super.clear();
  }



  boolean updated() {
    return super.updated() || !initialized || updated || dragAndDropManager.dragging;
  }

  void update() {
  }
  
  void drawHighlighting(float width) {
    if (topChild != null && bottomChild != null) {
      topChild.drawHighlighting(width);
      bottomChild.drawHighlighting(width);
    } else {
      fill(255,255,255,128-getStretchFactor()/rootMaxStretchFactor()*128);
      rect(0,getMagnificationTop(), width, getMagnificationBottom()-getMagnificationTop());
    }
  }

  void draw() {
    pushMatrix();
    
    if (parent == null) {
      translate(getX(), 0);
      float[] spacing = {
        getDashSize(), getDashSize()
      };
//      if (topChild != null) {
//        stroke(230, 230, 230,255);
//        strokeWeight(1.0);
//        dashline(30, getMagnificationBottom(), 30, getMagnificationTop(), spacing);
//      }
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


      strokeWeight(1);
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
      
      super.draw();
      
      // branch
      if (magnificationPoint.dragAndDropManager.dragging) {
        stroke(120, 120, 120, 255*magnificationPoint.blurFactor());
        strokeWeight(1);
        //          noStroke();
        fill(255, 255, 255, 0);
        ellipseMode(CENTER);
        ellipse(originalPoint.x, originalPoint.y, hoverArea*2.1, hoverArea*2.1);
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
