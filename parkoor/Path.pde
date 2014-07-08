class Path implements Drawable {
  
  float strokeWidth = 1.9;

  boolean updated;

  Chart chart;
  PathGroup pathGroup;
  Font font;
  JSONObject date;
  AxisGroup axes;
  DragAndDropManager dragAndDropManager;
  boolean highlighted = false;
  boolean grayed = false;
  HashMap<String, Integer> data;
  ArrayList<String> dataKeys;
  
  PersonFilter personFilter;

  Path(PathGroup pathGroup, JSONObject date) {
    this.pathGroup = pathGroup;
    this.chart = pathGroup.chart;
    this.font = chart.view.font;
    this.date = date;
    axes = chart.axisGroup;
    this.dragAndDropManager = new DragAndDropManager();
    data = chart.controller.model.getLocationTimes(date);
    dataKeys = chart.controller.model.getLocations(date);
    
    personFilter = new PersonFilter();
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
      String entry_name = date.getString("name");
    
      if (grayed) {
        stroke(color(200,200,200,100));
      } else if (highlighted) {
        pushMatrix();
          fill(pathGroup.pathColorHighlighted.get(entry_name));
          noStroke();
          translate(-chart.offsetX-4-textWidth(entry_name), chart.getInnerHeight() - ((float)data.get(dataKeys.get(0))/1440) * chart.getInnerHeight() - textAscent()/2-4);
          rect(0, 0, textWidth(entry_name)+8, textAscent()+8);
          textFont(font.light14);
          fill(255,255,255);
          text(entry_name, 4,textAscent()+6);
          stroke(pathGroup.pathColorHighlighted.get(entry_name));
        popMatrix();
      } else {
        stroke(pathGroup.pathColor.get(entry_name));
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
    // mouseEvent variable contains the current event information
    if (mouseEvent.getClickCount()==2) {
      println("<double click>");
      if(mouseOver(new PVector(mouseX, mouseY))) {
        println("mouse over");
        println(date.getString("name"));
        
        personFilter.resetFilter();
        personFilter.remove(date.getString("name"));
        
        //pathGroup.filters.add(personFilter);
        //println(pathGroup.filters.toString());
        //pathGroup.updateFilters();
        
        return true;
      }
      else {
        // Filter löschen
      }
    }
    else {
      // Multi-Select
    }
  
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
    point0 = new PVector(-chart.offsetX, chart.getInnerHeight() - ((float)data.get(dataKeys.get(0))/1440) * chart.getInnerHeight());
    for (String key : dataKeys) {
      point1 = new PVector(i * chart.getSpacing(), (float)chart.getInnerHeight() - data.get(key) * c);
      if (pointInsideLine(pointM, point0, point1, strokeWidth)) {
        return true;
      }
      
      point0 = point1;
      i++;
    }
    point1 = new PVector(chart.getInnerWidth()+chart.offsetX2, chart.getInnerHeight() - ((float)data.get(dataKeys.get(dataKeys.size()-1))/1440) * chart.getInnerHeight());
    if (pointInsideLine(pointM, point0, point1, strokeWidth)) {
        return true;
      }
    
    return false;
  }

  boolean mouseMoved() {
    boolean cachedMouseOverCached = mouseOver(new PVector(float(mouseX),float(mouseY)));
    if (!highlighted && cachedMouseOverCached) {
      for(Path path:pathGroup) {
        path.highlighted = false;
        path.grayed = true;
      }
      int myIndex = pathGroup.indexOf(this);
      pathGroup.add(this);
      pathGroup.remove(myIndex);
      highlighted = true;
      grayed = false;
      for(Axis axis:chart.axisGroup) {
        axis.selectionMode = true;
        axis.selectionColor = pathGroup.pathColorHighlighted.get(date.getString("name"));
        axis.selection = (data.get(axis.name)/60);
      }
      updated = true;
      loop();
      return true;
    } else if (highlighted && !cachedMouseOverCached) {
      for(Path path:pathGroup) {
        path.grayed = false;
      }
      for(Axis axis:chart.axisGroup) {
        axis.selectionMode = false;
      }
      highlighted = false;
      updated = true;
      loop();
      return false;
    }
    return false;
  }
}

