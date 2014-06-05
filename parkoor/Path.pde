class Path implements Drawable {
  
  float strokeWidth = 1.5;

  boolean updated;

  Chart chart;
  PathGroup pathGroup;
  JSONObject date;
  AxisGroup axes;
  DragAndDropManager dragAndDropManager;
  boolean highlighted = false;
  HashMap<String, Integer> data;
  ArrayList<String> dataKeys;
  

  Path(PathGroup pathGroup, JSONObject date) {
    this.pathGroup = pathGroup;
    this.chart = pathGroup.chart;
    this.date = date;
    axes = chart.axisGroup;
    this.dragAndDropManager = new DragAndDropManager();
    data = chart.controller.model.getLocationTimes(date);
    dataKeys = chart.controller.model.getLocations(date);
  }

  boolean updated() {
    return updated;
  }

  void update() {
  }

  void draw() {
    float c = (float)chart.getInnerHeight() / 1440;

    pushMatrix();
    
      dragAndDropManager.saveMatrix();
    
      if (highlighted) {
        stroke(pathGroup.pathColorHighlighted.get(date.getString("name")));
      } else {
        stroke(pathGroup.pathColor.get(date.getString("name")));
      }
      strokeWeight(strokeWidth);
      noFill();
  
      beginShape();
        int i = 0;
        vertex(-chart.offsetX, chart.getInnerHeight() - ((float)data.get(dataKeys.get(0))/1440) * chart.getInnerHeight());
        for (String key : dataKeys) {
          // x muss ersetzt werden durch axes.get(i++).x
          vertex(i++ * chart.getSpacing(), chart.getInnerHeight() - ((float)data.get(key)/1440) * chart.getInnerHeight());
        }
        vertex(chart.getInnerWidth()+chart.offsetX2, chart.getInnerHeight() - ((float)data.get(dataKeys.get(dataKeys.size()-1))/1440) * chart.getInnerHeight());
      endShape();

    popMatrix();
    
    updated = false;
  }

  boolean pointInsideLine(PVector thePoint,
                          PVector theLineEndPoint1, 
                          PVector theLineEndPoint2, 
                          float theTolerance) {
                            
    PVector dir = new PVector(theLineEndPoint2.x,
                              theLineEndPoint2.y,
                              theLineEndPoint2.z);
    dir.sub(theLineEndPoint1);
    PVector diff = new PVector(thePoint.x, thePoint.y, 0);
    diff.sub(theLineEndPoint1);
  
    // inside distance determines the weighting 
    // between linePoint1 and linePoint2 
    float insideDistance = diff.dot(dir) / dir.dot(dir);
  
    if(insideDistance>0 && insideDistance<1) {
              
      PVector closest = new PVector(theLineEndPoint1.x,
                                    theLineEndPoint1.y,
                                    theLineEndPoint1.z);
      dir.mult(insideDistance);
      closest.add(dir);
      PVector d = new PVector(thePoint.x, thePoint.y, 0);
      d.sub(closest);
      float distsqr = d.dot(d);
      return (distsqr < pow(theTolerance,2)); 
    }
    return false;
  }

  boolean mousePressed() {
    return false;
  }


  boolean mouseReleased() {
    return false;
  }

  boolean mouseDragged() {
    return false;
  }

  boolean mouseOver(PVector mouse) {
    PVector point0 = null;
    PVector point1 = null;
    PVector pointM = dragAndDropManager.transformVector(mouse);
    float c = (float)chart.getInnerHeight() / 1440;
    int i = 0;
    for (String key : dataKeys) {
      if (point0 == null) {
        point0 = new PVector(float(i) * chart.getSpacing(), chart.getInnerHeight() - data.get(key) * c);
      } else {
        point1 = new PVector(i * chart.getSpacing(), (float)chart.getInnerHeight() - data.get(key) * c);
        if (pointInsideLine(pointM, point0, point1, strokeWidth)) {
          return true;
        }
        
        point0 = point1;
      }
      i++;
    }
    
    return false;
  }

  boolean mouseMoved() {
    boolean cachedMouseOverCached = mouseOver(new PVector(float(mouseX),float(mouseY)));
    if (!highlighted && cachedMouseOverCached) {
      highlighted = true;
      updated = true;
      loop();
      return true;
    } else if (highlighted && !cachedMouseOverCached) {
      highlighted = false;
      updated = true;
      loop();
      return false;
    }
    return false;
  }
}

