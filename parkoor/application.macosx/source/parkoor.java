import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.text.DateFormat; 
import java.text.SimpleDateFormat; 
import java.util.Date; 
import java.util.HashSet; 
import java.util.Map; 
import java.util.HashSet; 
import java.util.Calendar; 
import java.util.Map; 
import java.util.HashSet; 
import java.text.DateFormat; 
import java.text.SimpleDateFormat; 
import java.util.Date; 
import java.util.HashSet; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class parkoor extends PApplet {

Controller controller;
View view;
public void setup(){ 
  size(1024,650);
  
  controller = new Controller(100,165,824,330);
  view = controller.view;
} 
 
public void draw() {
  view.update();
  if (view.updated()) {
    view.draw();
  } else {
    noLoop();
  }
}

public void mousePressed() {
  view.mousePressed();
}


public void mouseReleased() {
  view.mouseReleased();
}

public void mouseDragged() {
  view.mouseDragged();
}

public void mouseMoved() {
  view.mouseMoved();
}
class AveragePath extends Path {

  ArrayList<PVector> pathVertices;

  AveragePath(PathGroup pathGroup, JSONObject date) {
    super(pathGroup, date);
  }

  public void draw() {
    String entry_name = date.getString("name");

    // Pfadeckpunkte holen
    pathVertices = new ArrayList<PVector>();
    pathVertices.add(new PVector(-chart.offsetX, minutesToY(data.get(dataKeys.get(0)))));
    int i = 0;
    for (String key : dataKeys) {
      pathVertices.add(new PVector(i++ * chart.getSpacing() + 2*chart.getSpacing(), minutesToY(data.get(key))));
    }
    pathVertices.add(new PVector(chart.getInnerWidth()+chart.offsetX2, minutesToY(data.get(dataKeys.get(dataKeys.size()-1)))));

    pushMatrix();

    dragAndDropManager.saveMatrix();

    if (!highlighted)
      fill(pathGroup.pathColor.get("average"));
    else
      fill(pathGroup.pathColorHighlighted.get("average"));
    noStroke();

    fill(0, 0, 0);
    pushMatrix();
    textFont(font.light14);
    translate(-chart.offsetX - textWidth(chart.model.dictionary.get(entry_name))*1.1f, (minutesToY(data.get(dataKeys.get(0)))) + textAscent()/2);
    text(chart.model.dictionary.get(entry_name), 0, 0);
    popMatrix();

    float DOT_SPACING = 5;
    PVector v1, v2;
    float x, y, m, alpha, c;
    for (i = 0; i < pathVertices.size ()-1; i++) {
      v1 = pathVertices.get(i);
      v2 = pathVertices.get(i+1);
      alpha = atan((v2.y-v1.y) / (v2.x-v1.x));
      x = cos(alpha) * DOT_SPACING;
      y = sin(alpha) * DOT_SPACING;
      c = 0;
      while (v1.x+ (c*x) < (v2.x)) {
        ellipse(v1.x + c*x, v1.y + c*y, 2, 2);
        c++;
      }
    }

    popMatrix();

    updated = false;
  }

  public boolean mousePressed() {
    if (mouseOver(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY))))
      return true;
    return false;
  }

  public boolean mouseOver(PVector mouse) {
    PVector point0 = null;
    PVector point1 = null;
    PVector pointM = dragAndDropManager.transformVector(mouse);
    float c = (float)chart.getInnerHeight() / 1440;
    int i = 0;

    point0 = new PVector(-chart.offsetX, minutesToY(data.get(dataKeys.get(0))));
    for (String key : dataKeys) {
      point1 = new PVector(chart.getSpacing()*2 + (i * chart.getSpacing()), minutesToY(data.get(key)));
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

    boolean mouseOverText = false;

    float x = -chart.offsetX - textWidth(chart.model.dictionary.get(date.getString("name")))*1.1f;
    float y = (minutesToY(data.get(dataKeys.get(0)))) + textAscent()/2;

    textFont(font.light14);
    mouseOverText = (pointM.x > x && pointM.x < x+textWidth(chart.model.dictionary.get(date.getString("name")))) && (pointM.y < y && pointM.y > y-textAscent());

    return mouseOverText;
  }
}

class Axis implements Drawable {
  
  int triangleSize = 6;
  int textOffset = 14;
  int minMin = 0;
  int maxMax = 24;
  int lineColor = color(80,80,80); 
  int lineColorGrayed = color(200,200,200); 
  int markColor = color(0,0,0); 
  int markColorHighlighted = color(110,110,110); 

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
  int selectionColor = color(0,0,0);
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
  
  public float hoursFromAxis(float value) {
    return - (value / chart.getInnerHeight() - 1 ) * (maxMax - minMin) + minMin;
//    return -(value/  chart.getInnerHeight() - 1)*1440/60;
  }
  

  public float axisFromHour(float hour) {
    return (1-((hour-minMin)/(maxMax-minMin)))*chart.getInnerHeight();
  }
  
  public void updateLocationFilter() {
//    locationFilter.min = hoursFromAxis(chart.bifocalAxis.magnifyRecursively(axisFromHour(min)));
    locationFilter.min = min;
//    locationFilter.max = hoursFromAxis(chart.bifocalAxis.magnifyRecursively(axisFromHour(max)));
    locationFilter.max = max;
  }
  
  public boolean updated() {
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
        // vorher int()
        text(formatHours(min), 0, 0);
      } else {
        textFont(font.bold14);
        fill(selectionColor);
        // vorher int()
        text(formatMinutes(selection), 0, 0);
      }
      textFont(font.light14);
      fill(0,0,0);
      textAlign(LEFT);
      translate(-5,textAscent()*1.5f);
      rotate(0.3f*PI);
      // LABEL
//      if(mouseOverLabel(new PVector(mouseX, mouseY)))
//        fill(0, 102, 255);
      text(label, 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,chart.bifocalAxis.magnifyRecursively(axisFromHour(min)));
      if (minHighlighted)
        fill(markColorHighlighted);
      else
        fill(markColor);
      noStroke();
      triangle(-triangleSize, triangleSize, triangleSize, triangleSize, 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,axisFromHour(min));
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
      translate(0,chart.bifocalAxis.magnifyRecursively(axisFromHour(max)));
      if (maxHighlighted)
        fill(markColorHighlighted);
      else
        fill(markColor);
      noStroke();
      triangle(-triangleSize, -triangleSize, triangleSize, -triangleSize, 0, 0);
    popMatrix();
  
    pushMatrix();
      translate(0,axisFromHour(max));
      fill(0,0,0,64);
      triangle(-triangleSize, -triangleSize, triangleSize, -triangleSize, 0, 0);
    popMatrix();
  }
  
  public void update() {
  }
  
  public void draw() {
    pushMatrix();
      translate(x,0);
      dragAndDropManager.saveMatrix();
      
      stroke(lineColorGrayed);
      strokeWeight(1.2f);
      line(0,0,0,chart.bifocalAxis.magnifyRecursively(axisFromHour(max)));
      
      stroke(lineColor);
      strokeWeight(1.2f);
      line(0,chart.bifocalAxis.magnifyRecursively(axisFromHour(max)),0,chart.bifocalAxis.magnifyRecursively(axisFromHour(min)));
      
      stroke(lineColorGrayed);
      strokeWeight(1.2f);
      line(0,chart.bifocalAxis.magnifyRecursively(axisFromHour(min)),0,chart.getInnerHeight());
      
      drawSliderMin();
      drawSliderMax();
    popMatrix();
    
    updated = false;
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  public boolean mouseOverMinMark(PVector mouse) {
    PVector p0 = new PVector(0.0f, chart.bifocalAxis.magnifyRecursively(axisFromHour(min)) + triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  public boolean mouseOverMaxMark(PVector mouse) {
    PVector p0 = new PVector(0.0f, chart.bifocalAxis.magnifyRecursively(axisFromHour(max)) - triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  public boolean mousePressed() {
    if (!dragAndDropManager.dragging && mouseOverMinMark(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      draggingMax = false;
      dragAndDropManager.start();
      loop();
      return true;
    } else if (!dragAndDropManager.dragging && mouseOverMaxMark(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      draggingMax = true;
      dragAndDropManager.start();
      loop();
      return true;
    }
    if (mouseOverLabel(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
    }
    return false;
  }
  
  
  public boolean mouseReleased() {
    if (dragAndDropManager.dragging) {
      dragAndDropManager.stop();
      return true;
    }
    return false;
  }
  
  public boolean mouseDragged() {
    if (dragAndDropManager.dragging) {
      if (draggingMax) {
        max = hoursFromAxis(chart.bifocalAxis.demagnifyRecursively(dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY))).y));
        if (max < min) {
          max = min;
        } else if (max > maxMax) {
          max = maxMax;
        }
        updateLocationFilter();
        chart.pathGroup.updateFilters();
      } else {
        min = hoursFromAxis(chart.bifocalAxis.demagnifyRecursively(dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY))).y));
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
  
  public boolean mouseMoved() {
    if (!dragAndDropManager.dragging && mouseOverMinMark(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      minHighlighted = true;
      updated = true;
      loop();
      return true;
    } else if (!dragAndDropManager.dragging && mouseOverMaxMark(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      maxHighlighted = true;
      updated = true;
      loop();
      return true;
    } else if (minHighlighted && !mouseOverMinMark(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      minHighlighted = false;
      updated = true;
      loop();
    } else if (maxHighlighted && !mouseOverMaxMark(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      maxHighlighted = false;
      updated = true;
      loop();
    }
    return false;
  }
  
  public boolean mouseOverLabel(PVector mouse) {
    PVector m = dragAndDropManager.transformVector(mouse);
    textFont(font.light14);
    // x = 0
    float y = textOffset + chart.getInnerHeight() + textAscent()*3;
    // textAlign(CENTER)
    float xt = textWidth(label)/2;
    float yt = textAscent();

    // y+3 ... kleine Korrektur bez\u00fcglich der y-Position

    return ((m.x > -xt && m.x < +xt) && (m.y < (y+3) && m.y > (y-yt)));
  }
}
class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  ArrayList<Filter> filters;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    
    ArrayList<String> locations = chart.model.getLocations();
    for (int i = 0; i < locations.size(); i++)
      add(new Axis(this, PApplet.parseInt(chart.getSpacing()*i + 2*chart.getSpacing()), chart.model.dictionary.get(locations.get(i)), locations.get(i)));

    filters = new ArrayList<Filter>();
    for (Axis axis:this) {
      filters.add(axis.locationFilter);
    }
  }
}
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
  float blurFactor = 1.0f;

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

  public String getLabel() {
    if (parent != null) {
      return parent.getLabel();
    } else
      return label;
  }

  public int getX() {
    //    if (parent != null) {
    //      return parent.getX();
    //    } else
    return x;
  }

  public float getOriginalTop() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getMagnificationTop();
      } else {
        return parent.originalPoint.y;
      }
    } else
      return 0;
  }

  public float getOriginalBottom() {
    if (parent != null) {
      if (secondHalf) {
        return parent.getMagnificationBottom();
      } else {
        return parent.originalPoint.y;
      }
    } else
      return chart.getInnerHeight();
  }

  public float getOriginalHeight() {
    return getOriginalBottom() - getOriginalTop();
  }
  


  public float getMagnificationTop() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getMagnificationTop();
      } else {
        return parent.magnificationPoint.y;
      }
    } else
      return 0;
  }

  public float getMagnificationBottom() {
    if (parent != null) {
      if (secondHalf) {
        return parent.getMagnificationBottom();
      } else {
        return parent.magnificationPoint.y;
      }
    } else
      return chart.getInnerHeight();
  }

  public float getMagnificationHeight() {
    return getMagnificationBottom() - getMagnificationTop();
  }

  public float getStretchFactor() {
    if (parent != null) {
      if (!secondHalf) {
        return parent.getStretchFactor()*(getMagnificationBottom()-getMagnificationTop())/(parent.originalPoint.y-getMagnificationTop());

      } else {
        return parent.getStretchFactor()*(getMagnificationBottom()-getMagnificationTop())/(getMagnificationBottom()-parent.originalPoint.y);

      }
    } else
      return 1.0f;
  }
  
  public float getMaxStretchFactor() {
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
  
  public float rootMaxStretchFactor() {
    return root.getMaxStretchFactor();
  }

  public float getDashSize() {
    float dash = normalDashSize*getStretchFactor();
    if (dash > (getMagnificationBottom()-getMagnificationTop()))
      dash = (getMagnificationBottom()-getMagnificationTop());
    return dash;
  }


  public boolean isLastBranch() {
    return ((topChild == null || topChild.size() == 0) && (bottomChild == null || bottomChild.size() == 0));
  }

  public int getLayer() {
    if (parent == null) {
      return 1;
    } else {
      return parent.getLayer()+1;
    }
  }

  public int depth(int current) {
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

  public int getRootDepth() {
    return root.depth(1);
  }
  
  public float highlightingDimension() {
    float rootDepth = (float) getRootDepth();
     return (rootDepth - (float) getLayer()/rootDepth);
  }


  public float magnify(float value) {
    return getMagnificationTop() +
      getMagnificationHeight() * (   ( value - getOriginalTop() ) / getOriginalHeight()   );
  }
  
  public float demagnify(float value) {
    return getOriginalTop() +
      getOriginalHeight() * (   ( value - getMagnificationTop() ) / getMagnificationHeight()   );
  }

  public float magnifyRecursively(float value) {
    
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
  
  public BifocalAxis findMagAxisRecursively(float value) {
    if (topChild != null && bottomChild != null) {
      if (value < magnificationPoint.y) {
        return topChild.findMagAxisRecursively(value);
      } else {
        return bottomChild.findMagAxisRecursively(value);
      }
    } else {
      return this;
    }
  }
  
  public BifocalAxis findMagAxis(float value) {
    return root.findMagAxisRecursively(value);
  }
  
  public float demagnifyRecursivelyForChild(float value) {
    float demag = demagnify(value);
    
    if (parent != null) {
        return parent.demagnifyRecursivelyForChild(demag);
    } else
      return demag;
  }
  
  public float demagnifyRecursively(float value) {
    BifocalAxis axis = findMagAxis(value);
    return axis.demagnifyRecursivelyForChild(value);
  }
  
  public void clear() {
    
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



  public boolean updated() {
    return super.updated() || !initialized || updated || dragAndDropManager.dragging;
  }

  public void update() {
  }
  
  public void drawHighlighting(float width) {
    if (topChild != null && bottomChild != null) {
      topChild.drawHighlighting(width);
      bottomChild.drawHighlighting(width);
    } else {
      fill(255,255,255,128-getStretchFactor()/rootMaxStretchFactor()*128);
      rect(0,getMagnificationTop(), width, getMagnificationBottom()-getMagnificationTop());
    }
  }

  public void draw() {
    pushMatrix();
    
    if (parent == null) {
      translate(getX(), 0);
      float[] spacing = {
        getDashSize(), getDashSize()
      };
      if (topChild != null) {
         textFont(font.light14);
        textAlign(LEFT);
        fill(200,255);
        text("0", 40, getMagnificationBottom()+5);
        text("24h 0m", 40, getMagnificationTop()+5);
        fill(0,0);
//        stroke(240,240,240);
//        strokeWeight(1.0);
//        line(0,0,30,0);
//        line(0,getMagnificationBottom(),30,getMagnificationBottom());
//        dashline(30, getMagnificationBottom(), 30, getMagnificationTop(), spacing);
      }
      
      stroke(0, 0, 0, 80);
      strokeWeight(1.0f);
      dashline(0, getMagnificationBottom(), 0, getMagnificationTop(), spacing);
      
      //      dragAndDropManager.saveMatrix();
      textFont(font.light14);
      textAlign(LEFT);
      fill(0, 0, 0, 80);
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

//      if (parent == null) {
//        dashline(0, getMagnificationBottom(), 0, getMagnificationTop(), spacing);
//      } else {
//        dashline(0, getMagnificationBottom()-hoverArea, 0, getMagnificationTop()+hoverArea, spacing);
//        //        line(-13, getOriginalBottom()-hoverArea, 0, getMagnificationBottom()-hoverArea);
//        //        line(-13, getOriginalTop()+hoverArea, 0, getMagnificationTop()+hoverArea);
//      }



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
        ellipse(originalPoint.x, originalPoint.y, hoverArea*2.1f, hoverArea*2.1f);
      }
      
      
    }




    popMatrix();


    updated = false;

    if (!initialized) {
      initialized = true;
    }
  }

  public boolean mouseOver(PVector m) {
    return (m.x > -hoverArea && m.x < hoverArea && m.y > getMagnificationTop() + hoverArea && m.y < getMagnificationBottom()-hoverArea);
  }

  public boolean mousePressed() {
    if (!super.mousePressed() && isLastBranch()) {
      PVector m = dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY)));
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


  public boolean mouseMoved() {
    if (!super.mouseMoved() && isLastBranch()) {
      PVector m = dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY)));
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
  public void dashline(float x0, float y0, float x1, float y1, float[ ] spacing) 
  { 
    float distance = dist(x0, y0, x1, y1); 
    float [ ] xSpacing = new float[spacing.length]; 
    float [ ] ySpacing = new float[spacing.length]; 
    float drawn = 0.0f;  // amount of distance drawn 

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
class BifocalPoint extends PVector implements Drawable {
  int hoverArea = 5;
  Font font;
  DragAndDropManager dragAndDropManager;
  BifocalAxis bifocalAxis; 
 
  boolean updated = false;
  boolean initialized = false;  
  boolean highlighted = false;
  
  BifocalPoint(BifocalAxis bifocalAxis, float x, float y) {
    super(x, y);
    this.dragAndDropManager = new DragAndDropManager();
    this.bifocalAxis = bifocalAxis;
  }
  
  public float blurFactor() {
     return (float)bifocalAxis.getLayer()/(float)bifocalAxis.getRootDepth();
  }
  
  public boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  public void update() {
  }
  
  public void draw() {
    pushMatrix();
//      translate(bifocalAxis.getX(),0);
      float originY = bifocalAxis.demagnifyRecursivelyForChild(bifocalAxis.originalPoint.y);
      dragAndDropManager.saveMatrix();  
      if (highlighted) {   
        fill(220,220,220,255*blurFactor());
      } else {
        fill(180,180,180,255*blurFactor());
      }
      noStroke();
      ellipseMode(CENTER);
      ellipse(this.x, this.y, 2*hoverArea, 2*hoverArea);
      fill(0,0);
      stroke(0,0,0,64);
      strokeWeight(0.9f);
      bezier(hoverArea, this.y, 20, this.y, 10, originY, 30, originY);
      int minutes = (int) ((1- originY / bifocalAxis.chart.getInnerHeight())*1440);
      int hours = floor((float) minutes/ (float) (60));
      fill(0,64);
      minutes = minutes - 60*hours;
      text(hours+"h "+minutes+"m", 40, originY+5);
      float[] spacing = {
        3, 3
      };
      stroke(100,64);
      strokeWeight(1.5f);
      //bifocalAxis.dashline(0, this.y, -bifocalAxis.chart.width, this.y, spacing);
      line(0, this.y, -bifocalAxis.chart.width, this.y);
    popMatrix();
    
    updated = false;
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  public boolean mouseOver(PVector m) {
    return (this.dist(m) < hoverArea);
  }
  
  public boolean mousePressed() {
    PVector m = dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY)));
    if (!dragAndDropManager.dragging && mouseOver(m)) {
      dragAndDropManager.start();
      updated = true;
      loop();
      return true;
    } 
    return false;
  }
  
  
  public boolean mouseReleased() {
    if (dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY)));
      dragAndDropManager.stop();
      if (abs(m.x) > 10) {
        bifocalAxis.clear();
      }
      bifocalAxis.updated = true;
      loop();
      return true;
    }
    return false;
  }
  
  public boolean mouseDragged() {
    if (dragAndDropManager.dragging) {
      PVector m = dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY)));
      if (m.y >= bifocalAxis.getMagnificationTop()+2*bifocalAxis.hoverArea && m.y <= bifocalAxis.getMagnificationBottom()-2*bifocalAxis.hoverArea) {
        this.y = m.y;
        if (abs(m.x) > 10) {
          this.x = m.x;
        } else {
          this.x = 0;
        }
        updated = true;
        loop();
        return true;
      }
    }
    return false;
  }
  
  public boolean mouseMoved() {
    PVector m = dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY)));
    if (!dragAndDropManager.dragging && initialized) {
      if(mouseOver(m)) {
        highlighted = true;
        return true;
      } else {
        highlighted = false;
      }
    }
    return false;
  }
}
class Bubble implements Drawable {
  
  int bubbleRadius = 35;
  boolean active = false;
  
  BubbleAxis bubbelAxis;
  String label;
  boolean initialized;
  boolean updated;
  boolean highlighted;
  int highlightColor;
  DragAndDropManager dragAndDropManager;
  
  Bubble(BubbleAxis bubbelAxis, String label, int highlightColor) {
    this.bubbelAxis = bubbelAxis;
    this.label = label;
    this.highlightColor = highlightColor;
    dragAndDropManager = new DragAndDropManager();
  }
  
  public boolean updated() {
    return !initialized || updated || dragAndDropManager.dragging;
  }
  
  public void update() {
  }
  
  public float getIndex() {
    return bubbelAxis.indexOf(this);
  }
  
  public float getSize() {
    return bubbelAxis.size()-1;
  }
  
  public float getY(){
    return bubbelAxis.chart.getInnerHeight()*(float)(getIndex()/getSize());
  }
  
  public void draw() {
    pushMatrix();
      translate(0,getY());
      dragAndDropManager.saveMatrix();
      stroke(255);
      strokeWeight(2);
      fill(180,180);
      if (highlighted) {
        fill(highlightColor);
      }
      ellipseMode(CENTER);
      ellipse(0,0,bubbleRadius,bubbleRadius);
      
      fill(255,255);
      
      textFont(bubbelAxis.font.bold14);
      textAlign(CENTER, CENTER);
      text(label,0,0);
    popMatrix();
    
    updated = false;
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  public boolean mouseOver() {
    PVector p0 = new PVector(0, 0);
    PVector p1 = dragAndDropManager.transformVector(new PVector(mouseX, mouseY));
    return (p0.dist(p1) < bubbleRadius*0.5f);
  }
  
  public boolean mousePressed() {
    return false;
  }
  
  
  public boolean mouseReleased() {
    return false;
  }
  
  public boolean mouseDragged() {
    return false;
  }
  
  public boolean mouseMoved() {
    if (mouseOver()) {
      highlighted = true;
      updated = true;
      loop();
      return true;
    } else {
      highlighted = false;
      updated = true;
      loop();
      return false;
    }
  }
  
}
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
  
  public void draw() {
    pushMatrix();
      translate(x, 0);
      noFill();
      strokeWeight(1.0f);
      stroke(200);
      dashline(0, chart.getInnerHeight(), 0, 0, spacing);
      super.draw();
    popMatrix();
  }
  
  public void dashline(float x0, float y0, float x1, float y1, float[ ] spacing) 
  { 
    float distance = dist(x0, y0, x1, y1); 
    float [ ] xSpacing = new float[spacing.length]; 
    float [ ] ySpacing = new float[spacing.length]; 
    float drawn = 0.0f;  // amount of distance drawn 

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
class Chart extends DrawableGroup {

  int left;
  int top;
  int width;
  int height;

  int offsetX = 30;    // Abstand der Achsen zur linken Seite des Diagramms 
  int offsetY = 0;    // Abstand der Achsen zur oberen Seite des Diagramms 
  int offsetX2 = offsetX;   // Abstand der Achsen zur rechten Seite des Diagramms 
  int offsetY2 = offsetY;    // Abstand der Achsen zur unteren Seite des Diagramms 

  int topicOffset = 100;
  String topic = "Wo bin ich?";
  String subTopic = "Stunden pro Tag und Ort";
  Model model;

  AxisGroup axisGroup;
  Controller controller;
  PathGroup pathGroup;
  BifocalAxis bifocalAxis;
  View view;
  Font font;
  BubbleAxis nameAxis;
  BubbleAxis dateAxis;
  

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
    bifocalAxis = new BifocalAxis(this, width-offsetX, "Zoom");
    nameAxis = new BubbleAxis(this, 0);
    for (String name:model.getPeople()) {
      nameAxis.add(new PersonBubble(pathGroup, nameAxis, name.charAt(0)+"", name, pathGroup.pathColorHighlighted.get(name)));
    }
    dateAxis = new BubbleAxis(this, floor(getSpacing()));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Mo", 1, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Di", 2, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Mi", 3, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Do", 4, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Fr", 5, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "Sa", 6, color(230)));
    dateAxis.add(new WeekdayBubble(pathGroup, dateAxis, "So", 7, color(230)));
    
    add(pathGroup);
    add(bifocalAxis);
    add(nameAxis);
    add(dateAxis);
    add(axisGroup);
//    add(new BifocalAxis(this, 0-offsetX, ""));
  }

  public int getInnerWidth() {
    return width - offsetX - offsetX2;
  }

  public int getInnerHeight() {
    return height - offsetY - offsetY2;
  }

  public void update() {
    super.update();
  }

  public void draw() {
    background(255);
    pushMatrix();
    translate(left, top);
    fill(0);

    pushMatrix();
    textAlign(LEFT);
    translate(0, -topicOffset);
    textFont(view.font.bold22);
    text(topic, 0, 0);
    translate(0, textAscent()*1.8f);
    textFont(view.font.light20);
    text(subTopic, 0, 0);
    popMatrix();

    translate(offsetX, offsetY);
    super.draw();
    popMatrix();
  }

  public float getSpacing() {
    return getInnerWidth() / (model.getLocationCount() + 1);
  }
  
  public float getPeopleSpacing() {
    return getInnerHeight() / (model.getPeople().size()-1);
  }
  
  public float getDaySpacing() {
    return getInnerHeight() / 6;
  }
}

class Controller {
  View view;
  Model model;
  JSONArray data;
  
  Controller(int left, int top, int width, int height) {
    model = new Model("data.json");
    view = new View(this, left, top, width, height);
  }
  
  
}






class DateFilter extends HashSet<String> implements Filter {
  DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
  Date date;
  
  DateFilter() {
  }
  
  DateFilter(String toAdd) {
    add(toAdd);
  }
  
  DateFilter(String[] toAdd) {
    for(int i = 0; i < toAdd.length; i++)
      add(toAdd[i]);
  }
  
  public boolean add(String toAdd) {
    if(validateDate(toAdd))
      return super.add(toAdd);
    else return false;
  }
  
  public JSONArray filterObjects(JSONArray dataObjects) {
    
    for (int i = 0; i < dataObjects.size(); ) {
      JSONObject data = dataObjects.getJSONObject(i);

      if (contains(data.getString("date")))
        dataObjects.remove(i);
      else
        i++;
    }
    
    return dataObjects;
  }
  
  /**
  * Validierung des Datums (als String). dateFormat.parse() akzeptiert auch "14-5-20".
  * Validierung bei remove() ist nicht notwendig, da nur valide Daten in das Set aufgenommen werden.
  * Es wird angenommen, dass die Daten im JSONArray valide sind (nach dem Format "yyyy-mm-dd").
  */
  public boolean validateDate(String d) {
    if((d.length() != 10) || (d.indexOf('-', 0) != 4) || (d.indexOf('-', 5) != 7))
      return false;
    try {
      date = dateFormat.parse(d);
    }
    catch (Exception e) {
      println("Unable to parse " + d);
      return false;
    }
    return true;
  }
  
  public void fillFilter(HashSet<String> allDates) {
    clear();
    for(String date: allDates)
      add(date);
  }
  
  public void fillFilter() {
    // TODO
  }
}
class DragAndDropManager {
  PMatrix2D invertedMatrix;
  PMatrix2D matrix;
  boolean dragging = false;
  
  DragAndDropManager() {
  }
  
  /**
  * Speichert die akktuelle Matrix, um Touch-Eingaben ins Zeichen-Koordinaten-System umrechnen zu k\u00f6nnen
  */
  public void saveMatrix() {
    this.matrix = new PMatrix2D(getMatrix());
    this.invertedMatrix = new PMatrix2D(getMatrix());
    invertedMatrix.invert();
  }

  /**
  * Rechnet eine Bildschirm-Koordinate ins ggf. transformierte Zeichen-Koordnaten-System um
  */
  public PVector transformVector(PVector vector) {
    if (invertedMatrix != null) {
      return invertedMatrix.mult(vector, null);
    } else
      return vector;
  }
  
  public void start() {
    dragging = true;
  }
  
  public void stop() {
    dragging = false;
  }
}
interface Drawable {
  public boolean updated();
  public void update();
  public void draw();
  public boolean mousePressed();    // return true to stop the event-proagation
  public boolean mouseMoved();      // return true to stop the event-proagation
  public boolean mouseReleased();   // return true to stop the event-proagation
  public boolean mouseDragged();    // return true to stop the event-proagation
}
class DrawableGroup<s extends Drawable> extends ArrayList<s> implements Drawable {
  boolean updated = false;
  
  DrawableGroup() {
  }
  
  public boolean updated() {
    for (Drawable drawable: this) {
      if (drawable.updated()) {
        return true;
      }
    }
    return updated;
  }
  
  public void update() {
    updated = false;
    for (Drawable drawable: this) {
      drawable.update();
      boolean itemUpdated = drawable.updated();
      if (!updated && itemUpdated) {
        updated = true;
      }
    }
  }
  
  public void draw() {
    for (Drawable drawable: this) {
      drawable.draw();
    }
    updated = false;
  }
  
  public boolean mousePressed() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mousePressed()) {
        return true;
      }
    }
    return false;
  }
  
  
  public boolean mouseReleased() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mouseReleased()) {
        return true;
      }
    }
    return false;
  }
  
  public boolean mouseDragged() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mouseDragged()) {
        return true;
      }
    }
    return false;
  }
  
  public boolean mouseMoved() {
    for(int i = this.size()-1; i >= 0; i--) {
      Drawable drawable = get(i);
      if (drawable.mouseMoved()) {
        return true;
      }
    }
    return false;
  }
}
interface Filter {
  
  public JSONArray filterObjects(JSONArray dataObjects);
  public void fillFilter();
}
class Font {
  PFont bold22;
  PFont bold14;
  PFont light22;
  PFont light20;
  PFont light12;
  PFont light14;
  
  Font() {
    bold22  = loadFont("UniversLTStd-BoldCn-22.vlw");
    bold14  = loadFont("UniversLTStd-BoldCn-14.vlw");
    light12 = loadFont("UniversLTStd-LightCn-12.vlw");
    light14 = loadFont("UniversLTStd-LightCn-14.vlw");
    light22 = loadFont("UniversLTStd-LightCn-22.vlw");
    light20 = loadFont("UniversLTStd-LightCn-20.vlw");
  }
}
class LocationFilter implements Filter {
  float min;
  float max;
  String name;
  
  LocationFilter(float min, float max, String name) {
    this.min = min;
    this.max = max;
    this.name = name;
  }
  
  public JSONArray filterObjects(JSONArray dataObjects) {
    for (int j = 0; j < dataObjects.size(); ) {
      JSONObject data = dataObjects.getJSONObject(j);
      
      if (data.getInt(name) > max*60 || data.getInt(name) < min*60)
        dataObjects.remove(j);
      else
        j++;
    }
    return dataObjects;
  }
  
  public void fillFilter() {
    // TODO
  }
}




class Model {

  JSONArray cachedDataObjects;
  StringDict dictionary;

  Model(String filename) {
    cachedDataObjects = loadJSONArray(filename);
    
    for (int j = 0; j < cachedDataObjects.size(); j++) {
      JSONObject data = cachedDataObjects.getJSONObject(j);
      data.setInt("id", j);
    }
    
    compileDictionary();
  }

  public JSONArray getDataObjects() {
    return cachedDataObjects;
  }

  public JSONArray getDataObjects(ArrayList<Filter> filters) {
    // copy original...
    JSONArray dataObjects = JSONArray.parse(cachedDataObjects.toString());
    
    for (Filter f: filters) {
      dataObjects = f.filterObjects(dataObjects);
    }
   
    return dataObjects;
  }  

  public JSONArray getDataObjects(JSONArray dataObjects, ArrayList<Filter> filters) {
    for (Filter f: filters) {
      dataObjects = f.filterObjects(dataObjects);
    }
   
    return dataObjects;
  }
  
  public HashMap getLocationTimes(JSONObject dataObject) {
    HashMap<String, Integer> LocationTimes = new HashMap<String, Integer>();
    LocationTimes.put("home", dataObject.getInt("home"));
    LocationTimes.put("transit", dataObject.getInt("transit"));
    LocationTimes.put("uni_mensa", dataObject.getInt("uni_mensa"));
    LocationTimes.put("uni_fak", dataObject.getInt("uni_fak"));
    LocationTimes.put("uni_slub", dataObject.getInt("uni_slub"));
    LocationTimes.put("uni_other", dataObject.getInt("uni_other"));
    LocationTimes.put("outdoor", dataObject.getInt("outdoor"));
    LocationTimes.put("shopping", dataObject.getInt("shopping"));
    LocationTimes.put("hobby", dataObject.getInt("hobby"));
    return LocationTimes;
  }
  
  /**
  * getLocations() gibt die Orte zur\u00fcck und legt au\u00dferdem \u00fcber deren
  * Reihenfolge fest, in welcher Ordnung die Achsen angezeigt werden.
  */
  public ArrayList<String> getLocations() {
    ArrayList<String> locations = new ArrayList<String>();
    locations.add("home");
    locations.add("transit");
    locations.add("uni_mensa");
    locations.add("uni_fak");
    locations.add("uni_slub");
    locations.add("uni_other");
    locations.add("outdoor");
    locations.add("shopping");
    locations.add("hobby");
    return locations;
  }
  
  public int getLocationCount() {
    return getLocations().size();
  }
  
  /**
  * getPeople() gibt die Personen zur\u00fcck und bestimmt wie
  * getLocations() deren Reihenfolge.
  */
  public ArrayList<String> getPeople() {
    ArrayList<String> people = new ArrayList<String>();
    people.add("Christian");
    people.add("Jonas");
    people.add("Lukas");
    people.add("Vlad");
    return people;
  }
  
  public int getPersonIndex(String name) {
    ArrayList<String> people = getPeople();
    for (int index = 0; index < people.size(); index++)
      if(people.get(index).equals(name))
        return index;
    return -1;
  }

  public HashSet<String> getDates() {
    HashSet<String> dates = new HashSet<String>();
    for (int i = 0; i < cachedDataObjects.size(); i++)
      dates.add(((JSONObject) cachedDataObjects.getJSONObject(i)).getString("date"));
      
    return dates;
  }
  
  public void compileDictionary() {
    dictionary = new StringDict();
    dictionary.set("home", "Zu Hause");
    dictionary.set("transit", "Unterwegs");
    dictionary.set("uni_mensa", "Mensa");
    dictionary.set("uni_fak", "Fakult\u00e4t");
    dictionary.set("uni_slub", "SLUB");
    dictionary.set("uni_other", "Uni (Sonstige)");
    dictionary.set("outdoor", "Drau\u00dfen");
    dictionary.set("shopping", "Besorgungen");
    dictionary.set("hobby", "Hobby/Sport");
    dictionary.set("average", "Durchschnitt");
  }
}

public String formatMinutes(float min) {
  if (min == 0) {
    return "0h";
  } else if (min == 24*60) {
    return "24h";
  } else {
    int hours = PApplet.parseInt(min / 60);
    int minutes = PApplet.parseInt(min % 60);
    String minutesStr = "";
    if(minutes < 10)
      minutesStr += "0";
    minutesStr += str(minutes);
    return str(hours)+"h " + minutesStr + "m";
  }
}

public String formatHours(float hours) {
  return formatMinutes(hours*60);
}

/**
* jetzt global
*/
public int getWeekday(String d) {
  Date date;
  DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
  DateFormat day = new SimpleDateFormat("EE");
  int i = 0;
  try {
    date = dateFormat.parse(d);
    // day.format(date) gibt den Wochentag zur\u00fcck.
    // Calendar kann dagegen benutzt werden, um einen Index 
    // zu bekommen. Allerdings: So = 1, Mo = 2, ...
    Calendar c = Calendar.getInstance();
    c.setTime(date);
    i = c.get(Calendar.DAY_OF_WEEK);
  }
  catch (Exception e) {
    println("Unable to parse " + d);
  }
  // Mo = 1, Di = 2, ...
  i = ((i+5)%7)+1;
  return i;
}
class Path implements Drawable {
  
  float strokeWidth = 1.9f;

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
    hidden = false;
  }

  public boolean updated() {
    return updated;
  }

  public void update() {
  }
  
  public float minutesToY(float minutes) {
    return chart.bifocalAxis.magnifyRecursively(chart.getInnerHeight() - ((float) minutes/1440) * chart.getInnerHeight());
  }
 

  public void draw() {

    if(!hidden) {
      
      float c = (float)chart.getInnerHeight() / 1440;
      
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
//          pushMatrix();
//            fill(pathGroup.pathColorHighlighted.get(entry_name));
//            noStroke();
//            textFont(font.light22);
//            translate(-chart.offsetX-4-textWidth(entry_name), minutesToY((float)data.get(dataKeys.get(0))) - textAscent()/2-4);
//            rect(0, 0, textWidth(entry_name)+8, textAscent()+8);
//            textFont(font.light14);
//            fill(255,255,255);
//            text(entry_name, 8, textAscent()+7);
            // Linienfarbe highlighted
            stroke(pathGroup.pathColorHighlighted.get(entry_name));
//          popMatrix();
        }
        if (selected)
          stroke(pathGroup.pathColorHighlighted.get(entry_name));
  
        /*if(selected && grayed)
          stroke(pathGroup.pathColorHighlighted.get(entry_name));*/
        strokeWeight(strokeWidth);
        noFill();
    
        beginShape();
          int i = 0;
          vertex(-chart.offsetX, chart.model.getPersonIndex(entry_name) * chart.getPeopleSpacing());
          vertex(0, chart.model.getPersonIndex(entry_name) * chart.getPeopleSpacing());
          vertex(chart.getSpacing(), (getWeekday(date.getString("date"))-1) * chart.getDaySpacing());
          for (String key : dataKeys) {
            vertex(i++ * chart.getSpacing() + 2*chart.getSpacing(), minutesToY((float)data.get(key)) );
          }
          vertex(chart.getInnerWidth()+chart.offsetX2, minutesToY((float)data.get(dataKeys.get(dataKeys.size()-1))));
        endShape();
  
      popMatrix();
    
    
      updated = false;
    
    }
    else {
//      selected = false;
    }
  }

  public boolean pointInsideLine(PVector thePoint,
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

  public boolean mousePressed() {
    if(!hidden) {
      boolean mouseIsOver = mouseOver(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)));
      // mouseEvent variable contains the current event information
      if (mouseEvent.getClickCount()==1) {
        // Multi-Select
        if (mouseIsOver) {
          // single click auf eine Linie
          // -> Linie ausw\u00e4hlen (Auswahl erstellen, Durchschnitt anzeigen)
          // Alle weiteren Linie werden dauerhaft, also solange die Auswahl
          // besteht, grayed dargestellt, beim mouse over highlighted.
          // Allerdings ist das auch schlecht, da man so nicht mehr erkennt
          // welcher Datensatz von wem ist.
          if (!selected) {
            selected = true;
            pathGroup.selections++;
            pathGroup.updateMultiSelect();
            updated = true;
            loop();
          }
          
          return true;
        }
        else {
          // single click in leere Fl\u00e4che
          // -> Auswahl l\u00f6schen
          if (selected) {
            selected = false;
            pathGroup.selections--;
            updated = true;
            // Jeder Pfad behandelt selbst dieses Ereignis.
          }
          
         
          
          return false;

          // ACHTUNG: Das funktioniert, weil die PathGroup dieser Ereignis
          // noch zus\u00e4tzlich behandelt! (insbesondere loop() aufruft)
        }
      }
      if (mouseEvent.getClickCount()==2) {
        if(mouseIsOver) {
          // double click auf eine Linie
          // -> alle Datens\u00e4tze einer Person ausw\u00e4hlen
          String name = date.getString("name");
          PersonFilter pSel = pathGroup.pSel;
          if(pSel.isEmpty()) {
            pSel.fillFilter();
          }
          pSel.remove(name);

          chart.pathGroup.updateSelectors();
          updated = true;
          loop();
          
          /* BEISPIEL F\u00dcR WEEKDAY */
//          WeekdayFilter wdSel = pathGroup.wdSel;
//          wdSel.remove(2);
//          
//          chart.pathGroup.updateSelectors();
          
          return true;
        }
      }
    }
    // Beim Klick in eine leere Fl\u00e4che sollen dennoch ALLE Pfade abgew\u00e4hlt werden.
    if (hidden && mouseEvent.getClickCount()>0)
      selected = false;
      
    return false;
  }


  public boolean mouseReleased() {
    return false;
  }

  public boolean mouseDragged() {
    return false;
  }

  public boolean mouseOver(PVector mouse) {
    PVector point0 = null;
    PVector point1 = null;
    PVector pointM = dragAndDropManager.transformVector(mouse);
    float c = (float)chart.getInnerHeight() / 1440;
    int i = 0;
    
    if (pointInsideLine(
          pointM,
          new PVector(0, chart.model.getPersonIndex(date.getString("name")) * chart.getPeopleSpacing()),
          new PVector(chart.getSpacing(), (getWeekday(date.getString("date"))-1) * chart.getDaySpacing()),
          strokeWidth)
          )
      return true;

    point0 = new PVector(chart.getSpacing(), (getWeekday(date.getString("date"))-1) * chart.getDaySpacing());
    for (String key : dataKeys) {
      point1 = new PVector(chart.getSpacing()*2 + (i * chart.getSpacing()), minutesToY(data.get(key)));
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

  public boolean mouseMoved() {
    if (!hidden) {
      boolean mouseIsOver = mouseOver(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)));
      if (!highlighted && mouseIsOver) {
        
        pathGroup.highlightes++;
        
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
        
        pathGroup.highlightes--;
        
        highlighted = false;
        grayed = true;
        
        updated = true;
        loop();
        return true;
      } else if (highlighted && mouseIsOver) {
        return true;
      } 
    }
    return false;
  }
}



class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  IntDict pathColor; // ein verr\u00fcckter Processing-Datentyp, wie Map<String, int>
  IntDict pathColorHighlighted; // ein verr\u00fcckter Processing-Datentyp, wie Map<String, int>
  JSONArray cachedData;
  Model model;
  int selections;
  int highlightes;

  ArrayList<Filter> selectors;
  ArrayList<Filter> weekdaySelectors;
  
  PersonFilter pSel;
  DateFilter dSel;
  WeekdayFilter wdSel;
  /**
   * Da die Filter hier allerdings als Selektoren "missbraucht"
   * werden, muss auf die umgekehrte Logik geachtet werden. Daher
   * m\u00fcssen die Filter immer zuerst gef\u00fcllt werden (fillFilter),
   * um danach wieder einzelne Elemente zu entfernen (remove).
   */

  // Multi-Select
  AveragePath averagePath;
  HashMap<String, Float> averageMap;
  ArrayList<Path> ordered;

  PathGroup(Chart chart) {
    this.chart = chart;
    model = chart.controller.model;
    cachedData = model.getDataObjects();
    ordered = new ArrayList<Path>();
    for (int i = 0; i < cachedData.size (); i++) {
      Path path = new Path(this, cachedData.getJSONObject(i));
      ordered.add(path);
      add(path);
    }

    // Initialisieren der Selektoren
    resetSelectors();

    // Multi-Select
    averageMap = new HashMap<String, Float>();

    pathColor = new IntDict();
    pathColor.set("Jonas", color(176, 40, 93, 70));
    pathColor.set("Christian", color(232, 74, 56, 70));
    pathColor.set("Vlad", color(7, 217, 98, 70));
    pathColor.set("Lukas", color(14, 123, 221, 70));
    pathColor.set("average", color(110, 110, 110, 180));

    pathColorHighlighted = new IntDict();
    pathColorHighlighted.set("Jonas", color(176, 40, 93, 180));
    pathColorHighlighted.set("Christian", color(232, 74, 56, 180));
    pathColorHighlighted.set("Vlad", color(7, 217, 98, 180));
    pathColorHighlighted.set("Lukas", color(14, 123, 221, 180));
    pathColorHighlighted.set("average", color(80, 80, 80, 180));

    updateFilters();
  }

  public void updateWeekdaySelectors() {
//    println("Updating Selectors...");
    cachedData = chart.controller.model.getDataObjects(weekdaySelectors);

    for (int i = 0; i < cachedData.size (); i++) {
      JSONObject personDay = cachedData.getJSONObject(i);
      ordered.get(personDay.getInt("id")).selected = true;
    }
    selections += cachedData.size();
    updateMultiSelect();
  }

  // eigentlich PersonSelectors
  public void updateSelectors() {
//    println("Updating Selectors...");
    cachedData = chart.controller.model.getDataObjects(selectors);

    for (int i = 0; i < cachedData.size (); i++) {
      JSONObject personDay = cachedData.getJSONObject(i);
      ordered.get(personDay.getInt("id")).selected = true;
    }
    selections += cachedData.size();
    updateMultiSelect();
  }
  
  public void updateFilters() {
    cachedData = chart.controller.model.getDataObjects(chart.axisGroup.filters);

    for (Path path : ordered) {
      path.hidden = true;
    }

    for (int i = 0; i < cachedData.size (); i++) {
      JSONObject personDay = cachedData.getJSONObject(i);
      ordered.get(personDay.getInt("id")).hidden = false;
    }
    updateMultiSelect();
  }

  // Multi-Select
  public void updateMultiSelect() {
    JSONObject average = new JSONObject();
    averageMap.clear();
    for (String key : chart.controller.model.getLocations ())
      averageMap.put(key, 0.0f);
    int c = 0;
    // Werte aller selektierten Pfade aufsummieren
    for (Path path : this) {
      if (path.selected && !path.hidden) {
        for (String key : averageMap.keySet ()) {
          averageMap.put(key, (averageMap.get(key) + path.date.getFloat(key)));
        }
        c++;
      }
    }
    remove(averagePath);
    if (c > 1) {
      // Durchschnitt berechnen
      float sum = 0;
      for (String key : averageMap.keySet ()) {
        average.setFloat(key, (averageMap.get(key) / c));
        sum += (averageMap.get(key) / c);
      }
      sum /= c;
      average.setString("name", "average");
      average.setString("info", "average of " + c + " path(s)");
      average.setFloat("av", sum);
      averagePath = new AveragePath(this, average);
      //averagePath.selected = true;
      add(averagePath);
    }
  }

  public void clearMultiSelect() {
    remove(averagePath);
  }

  public boolean mousePressed() {
    if (!super.mousePressed()) {
      clearMultiSelect();
      resetSelectors();
      updated = true;
      selections = 0;
      for (Path path : this) {
          path.grayed = false;
      }
      for(Drawable bubble : chart.dateAxis) {
        ((Bubble) bubble).active = false;
      }
      for(Drawable bubble : chart.nameAxis) {
        ((Bubble) bubble).active = false;
      }
      loop();
      return true;
    }
    return false;
  }

  public boolean mouseMoved() {
    if (!super.mouseMoved()) {
      if (selections == 0) {
        for (Path path : this) {
          path.grayed = false;
        }
      }

      for (Axis axis : chart.axisGroup) {
        axis.selectionMode = false;
      }
      
      return false;
    }
      return true;
  }

  public void resetSelectors() {
    // Feeding the Garbage Collector...
    selectors = new ArrayList<Filter>();
    weekdaySelectors = new ArrayList<Filter>();

    // Person-Selector
    pSel = new PersonFilter();
    selectors.add(pSel);

    // Date-Selector  \u2013\u2013 NOT USED
    /* Dieser Filter k\u00f6nnte genutzt werden, um alle Personen 
     an einem Tag auszuw\u00e4hlen. */
    /*dSel = new DateFilter();
     selectors.add(dSel);*/

    // Weekday-Selector
    wdSel = new WeekdayFilter();
    weekdaySelectors.add(wdSel);
  }
}

class PersonBubble extends Bubble {
  String name;
  PathGroup pathGroup;
  
  PersonBubble(PathGroup pathGroup, BubbleAxis bubbelAxis, String label, String name, int highlightColor) {
    super(bubbelAxis, label, highlightColor);
    this.pathGroup = pathGroup;
    this.name = name;
  }
  
  public boolean mousePressed() {
    if (mouseOver()) {
      if (!active) {
        active = true;
        PersonFilter pSel = pathGroup.pSel;
        if(pSel.isEmpty()) {
          pSel.fillFilter();
        }
        pSel.remove(name);
        pathGroup.updateSelectors(); 
        for (Path path : pathGroup) {
          if (!path.selected) {
            path.grayed = true;
          }
        }
        updated = true;
        loop();
        return true;
      } else {
        active = false;
        for (Path path : pathGroup) {
          if (path.selected) {
            path.selected = false;
            path.grayed = true;
          }
        }
        PersonFilter pSel = pathGroup.pSel;
        pSel.add(name);
        pathGroup.updateSelectors(); 
        updated = true;
        loop();
        return true;
      }
    } else {
      return false; 
    }
  }
  
}


class PersonFilter extends HashSet<String> implements Filter {

  PersonFilter() {
  }
  
  PersonFilter(String toAdd) {
    add(toAdd);
  }
  
  PersonFilter(String[] toAdd) {
    for(int i = 0; i < toAdd.length; i++)
      add(toAdd[i]);
  }

  public JSONArray filterObjects(JSONArray dataObjects) {
    
    for (int i = 0; i < dataObjects.size(); ) {
      JSONObject data = dataObjects.getJSONObject(i);

      if (contains(data.getString("name")))
        dataObjects.remove(i);
      else
        i++;
    }
    
    return dataObjects;
  }
  
  public void fillFilter() {
    clear();
    // TODO dynamischer?
    add("Jonas");
    add("Vlad");
    add("Lukas");
    add("Christian");
  }
}
class View extends DrawableGroup {
  Chart chart;
  Controller controller;
  Font font;
  
  View(Controller controller, int left, int top, int width, int height) {
    this.controller = controller;
    this.font = new Font();
   
    chart = new Chart(this, left, top, width, height);
    add(chart); 
  }

}
class WeekdayBubble extends Bubble {
  int weekday;
  PathGroup pathGroup;
  
  
  WeekdayBubble(PathGroup pathGroup, BubbleAxis bubbelAxis, String label, int weekday, int highlightColor) {
    super(bubbelAxis, label, highlightColor);
    this.pathGroup = pathGroup;
    this.weekday = weekday;
  }
 
  public boolean mousePressed() {
    if (mouseOver()) {
      if (!active) {
        active = true;
        WeekdayFilter wdSel = pathGroup.wdSel;
        //wdSel.fillFilter();
        wdSel.remove(weekday);
        pathGroup.updateWeekdaySelectors(); 
        for (Path path : pathGroup) {
          if (!path.selected) {
            path.grayed = true;
          }
        }
        updated = true;
        loop();
        return true;
      } else {
        active = false;
        for (Path path : pathGroup) {
          if (path.selected) {
            path.selected = false;
            path.grayed = true;
          }
        }
        WeekdayFilter wdSel = pathGroup.wdSel;
        //wdSel.fillFilter();
        wdSel.add(weekday);
        pathGroup.updateWeekdaySelectors(); 
        updated = true;
        loop();
        return true;
      }
    } else {
      return false; 
    }
  }
  
//  boolean mouseMoved() {
//    if (super.mouseMoved()) {
//    } else {
//    }
//  }
}






class WeekdayFilter implements Filter {
  DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
  Date date;
  
  boolean weekdays[] = {true, true, true, true, true, true, true};
  
  WeekdayFilter() {
  }
  
  WeekdayFilter(int d) {
    if(d > 0 && d < 8)
      weekdays[d] = true;
  }
  
  WeekdayFilter(boolean[] d) {
    if(d.length == 7)
      for(int i = 0; i < 7; i++)
        weekdays[i] = d[i];
  }
  
  /**
  * F\u00fcgt den Wochentag d dem Filter hinzu (Mo = 1, Di = 2, ... So = 7).
  **/
  public boolean add(int d) {
    if(d > 0 && d < 8) {
      weekdays[d-1] = true;
      return true;
    }
    else
      return false;
  }

  /**
  * Entfernt den Wochentag d aus dem Filter hinzu (Mo = 1, Di = 2, ... So = 7).
  **/
  public boolean remove(int d) {
    if(d > 0 && d < 8) {
      weekdays[d-1] = false;
      return true;
    }
    else
      return false;
  }
  
  public JSONArray filterObjects(JSONArray dataObjects) {
//    println(dataObjects.size() + " Object(s) to filter.");
    
    for (int i = 0; i < dataObjects.size(); ) {
      int idx = getWeekday(((JSONObject)dataObjects.getJSONObject(i)).getString("date"));

      if (weekdays[idx-1])
        dataObjects.remove(i);
      else
        i++;
    }

//    println(dataObjects.size() + " Object(s) left.");
    return dataObjects;
  }
  
  public void fillFilter() {
    for(int i = 0; i < 7; i++)
      weekdays[i] = true;
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "parkoor" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
