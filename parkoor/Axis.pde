class Axis implements Drawable {
  
  int triangleSize = 6;
  int textOffset = 14;
  int minMin = 0;
  int maxMax = 24;
  color lineColor = color(80,80,80); 
  color lineColorGrayed = color(200,200,200); 
  color markColor = color(0,0,0); 
  color markColorHighlighted = color(110,110,110); 

  Chart chart;
  AxisGroup axisGroup;
  View view;
  Font font;
  DragAndDropManager dragAndDropManager;
  
  int x;
  String label;
  String name;
  boolean updated = false;
  boolean initialized = false;
  float min = 0;
  float max = 24;
  boolean draggingMax = false;
  boolean minHighlighted = false;
  boolean maxHighlighted = false;
  boolean selectionMode = false;
  color selectionColor = color(0,0,0);
  float selection = 0;
  LocationFilter locationFilter;
  
  Axis(AxisGroup axisGroup, int x, String label, String name) {
    this.axisGroup = axisGroup;
    this.chart = axisGroup.chart;
    this.view = chart.view;
    this.font = view.font;
    this.dragAndDropManager = new DragAndDropManager();
    
    this.x = x;
    this.label = label;
    this.name = name;
    locationFilter = new LocationFilter(min, max, name);
  }
  
  float hoursFromAxis(float value) {
    return -(value/  chart.getInnerHeight() - 1)*1440/60;
  }
  

  float axisFromHour(float hour) {
    return (1-((hour*60)/1440)) * chart.getInnerHeight();
  }
  
  void updateLocationFilter() {
//    locationFilter.min = hoursFromAxis(chart.bifocalAxis.magnifyRecursively(axisFromHour(min)));
    locationFilter.min = min;
    println("locationFilter.min "+locationFilter.min+" - min: "+min);
//    locationFilter.max = hoursFromAxis(chart.bifocalAxis.magnifyRecursively(axisFromHour(max)));
    locationFilter.max = max;
  }
  
  boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  private void drawSliderMin() {
    pushMatrix();
      textFont(font.light14);
      textAlign(CENTER);
      translate(0,textOffset+chart.getInnerHeight()+textAscent());
      noStroke();
      if (!selectionMode) {
        fill(0,0,0);
        // TODO vorher int()
        text(formatHours(min), 0, 0);
      } else {
        textFont(font.bold14);
        fill(selectionColor);
        // TODO vorher int()
        text(formatMinutes(selection), 0, 0);
      }
      textFont(font.light14);
      fill(0,0,0);
      translate(0,textAscent()*2);
      text(label, 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,(1-((hoursFromAxis(chart.bifocalAxis.demagnifyRecursively(axisFromHour(min)))-minMin)/(maxMax-minMin)))*chart.getInnerHeight());
      if (minHighlighted)
        fill(markColorHighlighted);
      else
        fill(markColor);
      noStroke();
      triangle(-triangleSize, triangleSize, triangleSize, triangleSize, 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,(1-((min-minMin)/(maxMax-minMin)))*chart.getInnerHeight());
      fill(0,0,0,64);
      triangle(-triangleSize, triangleSize, triangleSize, triangleSize, 0, 0);
    popMatrix();
  }
  
  private void drawSliderMax() {
    pushMatrix();
      textFont(font.light14);
      textAlign(CENTER);
      translate(0,-textOffset);
      fill(markColor);
      noStroke();
      // TODO vorher int()
      text(formatHours(max), 0, 0);
//      if (!selectionMode) {
//        text(int(max), 0, 0);
//      } else {
//        
//      }
    popMatrix();
    
    pushMatrix();
      translate(0,(1-((max-minMin)/(maxMax-minMin)))*chart.getInnerHeight());
      if (maxHighlighted)
        fill(markColorHighlighted);
      else
        fill(markColor);
      noStroke();
      triangle(-triangleSize, -triangleSize, triangleSize, -triangleSize, 0, 0);
    popMatrix();
  }
  
  void update() {
  }
  
  void draw() {
    pushMatrix();
      translate(x,0);
      dragAndDropManager.saveMatrix();
      
      stroke(lineColorGrayed);
      strokeWeight(1.2);
      line(0,0,0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))));
      
      stroke(lineColor);
      strokeWeight(1.2);
      line(0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))),0,chart.getInnerHeight()*(1-((max-minMin)/(maxMax-minMin))));
      
      stroke(lineColorGrayed);
      strokeWeight(1.2);
      line(0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))),0,chart.getInnerHeight());
      
      drawSliderMin();
      drawSliderMax();
    popMatrix();
    
    updated = false;
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  boolean mouseOverMinMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))) + triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  boolean mouseOverMaxMark(PVector mouse) {
    PVector p0 = new PVector(0.0, chart.getInnerHeight()*(1-((max-minMin)/(maxMax-minMin))) - triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  boolean mousePressed() {
    if (!dragAndDropManager.dragging && mouseOverMinMark(new PVector(float(mouseX),float(mouseY)))) {
      draggingMax = false;
      dragAndDropManager.start();
      loop();
      return true;
    } else if (!dragAndDropManager.dragging && mouseOverMaxMark(new PVector(float(mouseX),float(mouseY)))) {
      draggingMax = true;
      dragAndDropManager.start();
      loop();
      return true;
    }
    return false;
  }
  
  
  boolean mouseReleased() {
    if (dragAndDropManager.dragging) {
      dragAndDropManager.stop();
      return true;
    }
    return false;
  }
  
  boolean mouseDragged() {
    if (dragAndDropManager.dragging) {
      if (draggingMax) {
        max = minMin + (1-dragAndDropManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight())*(maxMax-minMin);
        if (max < min) {
          max = min;
        } else if (max > maxMax) {
          max = maxMax;
        }
        updateLocationFilter();
        chart.pathGroup.updateFilters();
      } else {
        min = minMin + (1-dragAndDropManager.transformVector(new PVector(float(mouseX),float(mouseY))).y/chart.getInnerHeight())*(maxMax-minMin);
        if (min < minMin) {
          min = minMin;
        } else if (min > max) {
          min = max;
        }
        updateLocationFilter();
        chart.pathGroup.updateFilters();
      }
      return true;
    }
    return false;
  }
  
  boolean mouseMoved() {
    if (!dragAndDropManager.dragging && mouseOverMinMark(new PVector(float(mouseX),float(mouseY)))) {
      minHighlighted = true;
      updated = true;
      loop();
      return true;
    } else if (!dragAndDropManager.dragging && mouseOverMaxMark(new PVector(float(mouseX),float(mouseY)))) {
      maxHighlighted = true;
      updated = true;
      loop();
      return true;
    } else if (minHighlighted && !mouseOverMinMark(new PVector(float(mouseX),float(mouseY)))) {
      minHighlighted = false;
      updated = true;
      loop();
    } else if (maxHighlighted && !mouseOverMaxMark(new PVector(float(mouseX),float(mouseY)))) {
      maxHighlighted = false;
      updated = true;
      loop();
    }
    return false;
  }
}
