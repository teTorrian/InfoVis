import processing.core.*; 
import processing.xml.*; 

import java.util.Map; 
import org.json.*; 
import org.json.JSONArray; 

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
  
  int triangleSize = 5;

  Chart chart;
  AxisGroup axisGroup;
  Controller controller;
  MatrixManager matrixManager;
  
  int x;
  String label;
  boolean updated = false;
  boolean initialized = false;
  float min = 0;
  float max = 1;
  
  Axis(AxisGroup axisGroup, int x, String label) {
    this.axisGroup = axisGroup;
    this.chart = axisGroup.chart;
    this.controller = chart.controller;
    this.matrixManager = new MatrixManager();
    
    this.x = x;
    this.label = label;
  }
  
  public boolean updated() {
    return !initialized || updated || matrixManager.dragging;
  }
  
  private void drawSliderMin() {
    pushMatrix();
      translate(0,floor(min*chart.getInnerHeight()));
      matrixManager.save();
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, 0, triangleSize, 0, 0, triangleSize);
    popMatrix();
  }
  
  private void drawSliderMax() {
    pushMatrix();
      translate(0,max*chart.getInnerHeight());
      fill(0,0,0);
      noStroke();
      triangle(-triangleSize, 0, triangleSize, 0, 0, -triangleSize);
    popMatrix();
  }
  
  public void update() {
  }
  
  public void draw() {
    pushMatrix();
      translate(x,0);
      stroke(0);
      line(0,0,0,chart.getInnerHeight());
      drawSliderMin();
      drawSliderMax();
    popMatrix();
    
    if (!initialized) {
      initialized = true;
    }
  }
  
  public boolean isMouseOver(PVector mouse) {
    PVector p0 = new PVector(0.0f, 0.0f);
    PVector p1 = matrixManager.transformVector(mouse);
    return (p0.dist(p1) < 8);
  }
  
  public void mousePressed() {
    if (!matrixManager.dragging && isMouseOver(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY)))) {
      matrixManager.start();
      loop();
    }
  }
  
  
  public void mouseReleased() {
    if (matrixManager.dragging) {
      matrixManager.stop();
    }
  }
  
  public void mouseDragged() {
    if (matrixManager.dragging) {
      println("update "+matrixManager.transformVector(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY))).y);
      min = matrixManager.transformVector(new PVector(PApplet.parseFloat(mouseX),PApplet.parseFloat(mouseY))).y/chart.getInnerHeight();
    }
  }
}

class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, 0, "Achse 1"));
    add(new Axis(this, 100, "Achse 2"));
    add(new Axis(this, 200, "Achse 3"));
    add(new Axis(this, 300, "Achse 4"));
  }
  
}

class Chart extends DrawableGroup {
  
  int x;
  int y;
  int width;
  int height;
  
  int offsetX = 40;    // Abstand der Achsen zur linken Seite des Diagramms 
  int offsetY = 0;    // Abstand der Achsen zur oberen Seite des Diagramms 
  int offsetX2 = 40;   // Abstand der Achsen zur rechten Seite des Diagramms 
  int offsetY2 = 0;    // Abstand der Achsen zur unteren Seite des Diagramms 

  AxisGroup axisGroup;
  Controller controller;
  View view;
  
  Chart(View view, int x, int y, int width, int height) {
    super();
    this.view = view;
    this.controller = view.controller;
    
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    
    axisGroup = new AxisGroup(this);
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
      translate(x,y);
      noStroke();
      fill(230, 230, 230);
      rect(0,0,width,height);
      pushMatrix();
        translate(offsetX, offsetY);
        super.draw();
      popMatrix();
    popMatrix();
  }
  
}

class Controller {
  View view;
  Controller(int x, int y, int width, int height) {
    view = new View(this, x, y, width, height);
  }
}

interface Drawable {
  public boolean updated();
  public void update();
  public void draw();
  public void mousePressed();
  public void mouseReleased();
  public void mouseDragged();
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
  
  public void mousePressed() {
    for (Drawable drawable: this) {
      drawable.mousePressed();
    }
  }
  
  
  public void mouseReleased() {
    for (Drawable drawable: this) {
      drawable.mouseReleased();
    }
  }
  
  public void mouseDragged() {
    for (Drawable drawable: this) {
      drawable.mouseDragged();
    }
  }
}

class Font {
  PFont bold22;
  PFont light12;  
  PFont light14;
  PFont light22;
  
  Font() {
    bold22  = loadFont("UniversLTStd-BoldCn-22.vlw");
    light12 = loadFont("UniversLTStd-LightCn-12.vlw");
    light14 = loadFont("UniversLTStd-LightCn-14.vlw");
    light22 = loadFont("UniversLTStd-LightCn-22.vlw");
  }
}

class LocationFilter {
  int min;
  int max;
  String name;
  
  LocationFilter(int min, int max, String name) {
    this.min = min;
    this.max = max;
    this.name = name;
  }
  
}

class MatrixManager {
  protected PMatrix2D invertedMatrix;
  protected PMatrix2D matrix;
  boolean dragging = false;
  
  MatrixManager() {
  }
  
  /**
  * Speichert die akktuelle Matrix, um Touch-Eingaben ins Zeichen-Koordinaten-System umrechnen zu können
  */
  public void save() {
    this.matrix = new PMatrix2D(getMatrix());
    invertedMatrix = new PMatrix2D(getMatrix());
    invertedMatrix.invert();
  }

  /**
  * Rechnet eine Bildschirm-Koordinate ins ggf. transformierte Zeichen-Koordnaten-System um
  */
  public PVector transformVector(PVector vector) {
    return invertedMatrix.mult(vector, null);
  }
  
  public void start() {
    dragging = true;
  }
  
  public void stop() {
    dragging = false;
  }
}




class Model {
   Model(){
     
   }
   
   public JSONArray getDataObjects(){
     return loadJSONArray("data.json");
   }
   
   public JSONArray getDataObjects(ArrayList<LocationFilter> filters){
     JSONArray DataObjects = loadJSONArray("data.json");
     JSONArray json = loadJSONArray("data.json");
     for(int i = 0; i < filters.size(); i++){
       LocationFilter filter = filters.get(i);       
       String name = filter.name;
       int min = filter.min;
       int max = filter.max;       
       
       for(int j = 0; j < DataObjects.size(); j++){
         JSONObject data = json.getJSONObject(j);
         if(data.getInt(name) > max || data.getInt(name) < min){
           DataObjects.remove(j);
         }         
       }       
     }  
     return DataObjects;
   }  
   
  public HashMap getLocationTimes(JSONObject DataObject){
    HashMap<String,Integer> LocationTimes = new HashMap<String,Integer>();
    LocationTimes.put("home",       DataObject.getInt("home"));
    LocationTimes.put("transit",    DataObject.getInt("transit"));
    LocationTimes.put("uni_mensa",  DataObject.getInt("uni_mensa"));
    LocationTimes.put("uni_fak",    DataObject.getInt("uni_fak"));
    LocationTimes.put("uni_slub",   DataObject.getInt("uni_slub"));
    LocationTimes.put("uni_other",  DataObject.getInt("uni_other"));
    LocationTimes.put("outdoor",    DataObject.getInt("outdoor"));
    LocationTimes.put("shopping",   DataObject.getInt("shopping"));
    LocationTimes.put("hobby",      DataObject.getInt("hobby"));
    return LocationTimes;
  }
}

class View extends DrawableGroup {
  Chart chart;
  Controller controller;
  Font font;
  
  View(Controller controller, int x, int y, int width, int height) {
    this.controller = controller;
    this.font = new Font();

    textFont(font.bold22);
    
    
    chart = new Chart(this, x, y, width, height);
    add(chart); 
  }
}



Controller controller;
View view;

public void setup(){ 
  size(1024,600);

  JSONArray json = loadJSONArray("data.json");
  Model model = new Model();
  JSONArray allData = new JSONArray();
  allData = model.getDataObjects(); 
  println(allData.size());
  
  HashMap<String, Integer> Locs = new HashMap<String, Integer>();
  Locs = model.getLocationTimes(json.getJSONObject(0));
  for(Map.Entry entry : Locs.entrySet()){
    println(entry.getKey() + " " + entry.getValue());  
  }
  
  LocationFilter Loc1 = new LocationFilter(0, 1300, "home");
  LocationFilter Loc2 = new LocationFilter(10, 1000, "home");
  ArrayList<LocationFilter> lf;
  lf = new ArrayList<LocationFilter>();
  lf.add(Loc1);
  //lf.add(Loc2);
  println(model.getDataObjects(lf).size());
     
   controller = new Controller(100,165,824,330);
   view = controller.view;
   
} 
 
public void draw() {
  view.update();
  if (view.updated()) {
    view.draw();
    fill(0);
    text("Parallele Koordinaten", 100, 100);
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

    static public void main(String args[]) {
        PApplet.main(new String[] { "--bgcolor=#ECE9D8", "parkoor" });
    }
}
