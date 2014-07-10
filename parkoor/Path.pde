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
  boolean selected = false;
  boolean hidden = false;
  HashMap<String, Integer> data;
  ArrayList<String> dataKeys;

  Path(PathGroup pathGroup, JSONObject date) {
    this.pathGroup = pathGroup;
    this.chart = pathGroup.chart;
    this.font = chart.view.font;
    this.date = date;
    axes = chart.axisGroup;
    this.dragAndDropManager = new DragAndDropManager();
    data = chart.controller.model.getLocationTimes(date);
    dataKeys = chart.controller.model.getLocations(/*date*/);
  }

  boolean updated() {
    return updated;
  }

  void update() {
  }
  
  float minutesToY(float minutes) {
    return chart.bifocalAxis.magnifyRecursively(chart.getInnerHeight() - ((float) minutes/1440) * chart.getInnerHeight());
  }

  void draw() {
    float c = (float)chart.getInnerHeight() / 1440;

    if(hidden)
      println("hidden");
      
    pushMatrix();
    
      dragAndDropManager.saveMatrix();
      String entry_name = date.getString("name");
    
      stroke(pathGroup.pathColor.get(entry_name));
      if (grayed) {
        // Linienfarbe ausgegraut
        stroke(color(200,200,200,100));
      }
      if (highlighted) {
        // Name anzeigen
        pushMatrix();
          fill(pathGroup.pathColorHighlighted.get(entry_name));
          noStroke();
          textFont(font.light22);
          translate(-chart.offsetX-4-textWidth(entry_name), minutesToY((float)data.get(dataKeys.get(0))) - textAscent()/2-4);
          rect(0, 0, textWidth(entry_name)+8, textAscent()+8);
          textFont(font.light14);
          fill(255,255,255);
          text(entry_name, 8, textAscent()+7);
          // Linienfarbe highlighted
          stroke(pathGroup.pathColorHighlighted.get(entry_name));
        popMatrix();
      }
      if (selected)
        stroke(pathGroup.pathColorHighlighted.get(entry_name));

      /*if(selected && grayed)
        stroke(pathGroup.pathColorHighlighted.get(entry_name));*/
      strokeWeight(strokeWidth);
      noFill();
  
      beginShape();
        int i = 0;
        vertex(-chart.offsetX, minutesToY((float)data.get(dataKeys.get(0))));
        for (String key : dataKeys) {
          // x muss ersetzt werden durch axes.get(i++).x
          vertex(i++ * chart.getSpacing(), minutesToY((float)data.get(key)) );
        }
        vertex(chart.getInnerWidth()+chart.offsetX2, minutesToY((float)data.get(dataKeys.get(dataKeys.size()-1))));
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
    boolean mouseIsOver = mouseOver(new PVector(float(mouseX),float(mouseY)));
    // mouseEvent variable contains the current event information
    if (mouseEvent.getClickCount()==1) {
      // Multi-Select
      if (mouseIsOver) {
        // single click auf eine Linie
        // -> Linie auswählen (Auswahl erstellen, Durchschnitt anzeigen)
        // Alle weiteren Linie werden dauerhaft, also solange die Auswahl
        // besteht, grayed dargestellt, beim mouse over highlighted.
        // Allerdings ist das auch schlecht, da man so nicht mehr erkennt
        // welcher Datensatz von wem ist.
        println("single click");
        selected = true;
        pathGroup.updateMultiSelect();
        updated = true;
        loop();
        return true;
      }
      else {
        // single click in leere Fläche
        // -> Auswahl löschen
        /**
        *
        */
        pathGroup.clearMultiSelect();
        selected = false;
        updated = true;
        loop();
        // Jeder Pfad behandelt selbst dieses Ereignis.
        return false;
      }
    }
    if (mouseEvent.getClickCount()==2) {
      if(mouseIsOver) {
        // double click auf eine Linie
        // -> alle Datensätze einer Person auswählen
        String name = date.getString("name");
        println("double click on " + name);
        int c = 0;
        
        for (Path path: pathGroup) {
          if ((path.date.getString("name")).equals(name)) {
            path.selected = true;
          }
        }
        pathGroup.updateMultiSelect();
        updated = true;
        loop();
        
        return true;
      }
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
    point0 = new PVector(-chart.offsetX, minutesToY((float)data.get(dataKeys.get(0))));
    for (String key : dataKeys) {
      point1 = new PVector(i * chart.getSpacing(), (float)chart.getInnerHeight() - data.get(key) * c);
      if (pointInsideLine(pointM, point0, point1, strokeWidth)) {
        return true;
      }
      
      point0 = point1;
      i++;
    }
    point1 = new PVector(chart.getInnerWidth()+chart.offsetX2, minutesToY((float)data.get(dataKeys.get(dataKeys.size()-1))));
    if (pointInsideLine(pointM, point0, point1, strokeWidth)) {
        return true;
      }
    
    return false;
  }

  boolean mouseMoved() {
    boolean mouseIsOver = mouseOver(new PVector(float(mouseX),float(mouseY)));
    if (!highlighted && mouseIsOver) {
      for(Path path:pathGroup) {
        path.highlighted = false;
        path.grayed = true;
      }
      // Durch add/remove wird dieser Pfad der 'oberste' in der Reihenfolge.
      int myIndex = pathGroup.indexOf(this);
      pathGroup.add(this);
      pathGroup.remove(myIndex);
      
      highlighted = true;
      grayed = false;
      for(Axis axis:chart.axisGroup) {
        axis.selectionMode = true;
        axis.selectionColor = pathGroup.pathColorHighlighted.get(date.getString("name"));
        // TODO 
        axis.selection = data.get(axis.name);
      }
      updated = true;
      loop();
      return true;
    } else if (highlighted && !mouseIsOver) {
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
    } else if (highlighted && mouseIsOver) {
      return true;
    }
    return false;
  }
}

