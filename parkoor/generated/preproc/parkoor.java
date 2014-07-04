import processing.core.*; 
import processing.xml.*; 

import java.util.Map; 
import java.util.Set; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class parkoor extends PApplet {

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
  
  public void updateLocationFilter() {
    locationFilter.min = min;
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
        text(PApplet.parseInt(min), 0, 0);
      } else {
        textFont(font.bold14);
        fill(selectionColor);
        text(PApplet.parseInt(selection), 0, 0);
      }
      textFont(font.light14);
      fill(0,0,0);
      translate(0,textAscent()*2);
      text(label, 0, 0);
    popMatrix();
    
    pushMatrix();
      translate(0,(1-((min-minMin)/(maxMax-minMin)))*chart.getInnerHeight());
      if (minHighlighted)
        fill(markColorHighlighted);
      else
        fill(markColor);
      noStroke();
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
      text(PApplet.parseInt(max), 0, 0);
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
  
  public void update() {
  }
  
  public void draw() {
    pushMatrix();
      translate(x,0);
      dragAndDropManager.saveMatrix();
      
      stroke(lineColorGrayed);
      strokeWeight(1.2f);
      line(0,0,0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))));
      
      stroke(lineColor);
      strokeWeight(1.2f);
      line(0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))),0,chart.getInnerHeight()*(1-((max-minMin)/(maxMax-minMin))));
      
      stroke(lineColorGrayed);
      strokeWeight(1.2f);
      line(0,chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))),0,chart.getInnerHeight());
      
      drawSliderMin();
      drawSliderMax();
    popMatrix();
    
    updated = false;
    
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  public boolean mouseOverMinMark(PVector mouse) {
    PVector p0 = new PVector(0.0f, chart.getInnerHeight()*(1-((min-minMin)/(maxMax-minMin))) + triangleSize);
    PVector p1 = dragAndDropManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  public boolean mouseOverMaxMark(PVector mouse) {
    PVector p0 = new PVector(0.0f, chart.getInnerHeight()*(1-((max-minMin)/(maxMax-minMin))) - triangleSize);
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
        max = minMin + (1-dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY))).y/chart.getInnerHeight())*(maxMax-minMin);
        if (max < min) {
          max = min;
        } else if (max > maxMax) {
          max = maxMax;
        }
        updateLocationFilter();
        chart.pathGroup.updateLocationFilters();
      } else {
        min = minMin + (1-dragAndDropManager.transformVector(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY))).y/chart.getInnerHeight())*(maxMax-minMin);
        if (min < minMin) {
          min = minMin;
        } else if (min > max) {
          min = max;
        }
        updateLocationFilter();
        chart.pathGroup.updateLocationFilters();
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
}

class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  ArrayList<LocationFilter> locationFilters;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*0), "Zu Hause", "home"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*1), "Unterwegs", "transit"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*2), "Mensa", "uni_mensa"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*3), "Fakultät", "uni_fak"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*4), "Slub", "uni_slub"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*5), "Uni (Sonstige)", "uni_other"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*6), "Draußen", "outdoor"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*7), "Besorgungen", "shopping"));
    add(new Axis(this, PApplet.parseInt(chart.getSpacing()*8), "Hobby/Sport", "hobby"));
    
    locationFilters = new ArrayList<LocationFilter>();
    for (Axis axis:this) {
      locationFilters.add(axis.locationFilter);
    }
  }
  
}

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
    

    float[] spacing = {
      5, 5
    };
    strokeWeight(1.2f);
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
  
  public float getSpacing() {
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


class Controller {
  View view;
  Model model;
  JSONArray data;
  
  Controller(int left, int top, int width, int height) {
    model = new Model("data.json");
    view = new View(this, left, top, width, height);
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
    pushMatrix();
      for (Drawable drawable: this) {
        drawable.draw();
      }
    popMatrix();
  }
  
  public boolean mousePressed() {
    for (Drawable drawable: this) {
      if (drawable.mousePressed()) {
        return true;
      }
    }
    return false;
  }
  
  
  public boolean mouseReleased() {
    for (Drawable drawable: this) {
      if (drawable.mouseReleased()) {
        return true;
      }
    }
    return false;
  }
  
  public boolean mouseDragged() {
    for (Drawable drawable: this) {
      if (drawable.mouseDragged()) {
        return true;
      }
    }
    return false;
  }
  
  public boolean mouseMoved() {
    for (Drawable drawable: this) {
      if (drawable.mouseMoved()) {
        return true;
      }
    }
    return false;
  }
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

class LocationFilter {
  float min;
  float max;
  String name;
  
  LocationFilter(float min, float max, String name) {
    this.min = min;
    this.max = max;
    this.name = name;
  }
  
}

class DragAndDropManager {
  PMatrix2D invertedMatrix;
  PMatrix2D matrix;
  boolean dragging = false;
  
  DragAndDropManager() {
  }
  
  /**
  * Speichert die akktuelle Matrix, um Touch-Eingaben ins Zeichen-Koordinaten-System umrechnen zu können
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




class Model {

  JSONArray cachedDataObjects;

  Model(String filename) {
    cachedDataObjects = loadJSONArray(filename);
  }

  public JSONArray getDataObjects() {
    return cachedDataObjects;
  }

  public JSONArray getDataObjects(ArrayList<LocationFilter> filters) {
    // copy original...
    JSONArray dataObjects = JSONArray.parse(cachedDataObjects.toString());

    for (int i = 0; i < filters.size(); i++) {
      LocationFilter filter = filters.get(i);
      String name = filter.name;
      float min = filter.min;
      float max = filter.max;  
      
      for (int j = 0; j < dataObjects.size();) {
        JSONObject data = dataObjects.getJSONObject(j);
       
        if (data.getInt(name) > max*60 || data.getInt(name) < min*60) {
          dataObjects.remove(j); 
        } else {      
          j++;
        }
      }   
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
  
  public ArrayList<String> getLocations(JSONObject dataObject) {
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
    return getLocations(cachedDataObjects.getJSONObject(0)).size();
  }
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
    dataKeys = chart.controller.model.getLocations(date);
  }

  public boolean updated() {
    return updated;
  }

  public void update() {
  }

  public void draw() {
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

  public boolean mouseMoved() {
    boolean cachedMouseOverCached = mouseOver(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)));
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


class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  IntDict pathColor; // ein verrückter Processing-Datentyp, wie Map<String, int>
  IntDict pathColorHighlighted; // ein verrückter Processing-Datentyp, wie Map<String, int>
  JSONArray cachedData;
  Model model;
  
  PathGroup(Chart chart) {
    this.chart = chart;
    model = chart.controller.model;
    cachedData = model.getDataObjects();
    
    pathColor = new IntDict();
    pathColor.set("Jonas", color(176, 40, 93, 70));
    pathColor.set("Christian", color(232, 74, 56, 70));
    pathColor.set("Vlad", color(7, 217, 98, 70));
    pathColor.set("Lukas", color(14, 123, 221, 70));
    
    pathColorHighlighted = new IntDict();
    pathColorHighlighted.set("Jonas", color(176, 40, 93, 180));
    pathColorHighlighted.set("Christian", color(232, 74, 56, 180));
    pathColorHighlighted.set("Vlad", color(7, 217, 98, 180));
    pathColorHighlighted.set("Lukas", color(14, 123, 221, 180));

    updateLocationFilters();
  }
  
  public void updateLocationFilters() {
    cachedData = chart.controller.model.getDataObjects(chart.axisGroup.locationFilters);
    this.clear();
    for(int i = 0; i < cachedData.size(); i++) {
      add(new Path(this, cachedData.getJSONObject(i)));
    }
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

Controller controller;
View view;

public void setup(){ 
  size(1024,600);
  
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

    static public void main(String args[]) {
        PApplet.main(new String[] { "--bgcolor=#ECE9D8", "parkoor" });
    }
}
