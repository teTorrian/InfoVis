class AveragePath extends Path {
  
  ArrayList<PVector> pathVertices;
  
  AveragePath(PathGroup pathGroup, JSONObject date) {
    super(pathGroup, date);
  }
  
  void draw() {
    String entry_name = date.getString("name");
    
    // Pfadeckpunkte holen
    pathVertices = new ArrayList<PVector>();
    //pathVertices.add(new PVector(-chart.offsetX, chart.model.getPersonIndex(entry_name)*100 - 50));
    //pathVertices.add(new PVector(0, chart.model.getPersonIndex(entry_name)*100 - 50));
    //pathVertices.add(new PVector(chart.getSpacing(), chart.model.getWeekday(date.getString("date"))*50 - 50));
    pathVertices.add(new PVector(-chart.offsetX, minutesToY(data.get(dataKeys.get(0)))));
    int i = 0;
    for (String key : dataKeys) {
      pathVertices.add(new PVector(i++ * chart.getSpacing() + 2*chart.getSpacing(), minutesToY(data.get(key))));
    }
    pathVertices.add(new PVector(chart.getInnerWidth()+chart.offsetX2, minutesToY(data.get(dataKeys.get(dataKeys.size()-1)))));
        
    pushMatrix();
    
      dragAndDropManager.saveMatrix();
      
      if(!highlighted)
        fill(pathGroup.pathColor.get("average"));
      else
        fill(pathGroup.pathColorHighlighted.get("average"));
      noStroke();
      
      pushMatrix();
        textFont(font.light14);
        translate(-chart.offsetX - textWidth(chart.model.dictionary.get(entry_name))*1.1, (minutesToY(data.get(dataKeys.get(0)))) + textAscent()/2);
        text(chart.model.dictionary.get(entry_name), 0, 0);
      popMatrix();

      float DOT_SPACING = 5;
      PVector v1, v2;
      float x, y, m, alpha, c;
      for (i = 0; i < pathVertices.size()-1; i++) {
        v1 = pathVertices.get(i);
        v2 = pathVertices.get(i+1);
        alpha = atan((v2.y-v1.y) / (v2.x-v1.x));
        x = cos(alpha) * DOT_SPACING;
        y = sin(alpha) * DOT_SPACING;
        c = 0;
        while(v1.x+(c*x) < (v2.x)) {
          ellipse(v1.x + c*x, v1.y + c*y, 2, 2);
          c++;
        }
        
      }

    popMatrix();
    
    updated = false;
  }
  
  boolean mousePressed() {
    if(mouseOver(new PVector(float(mouseX),float(mouseY))))
      return true;
    return false;
  }

  boolean mouseOver(PVector mouse) {
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
    
    float x = -chart.offsetX - textWidth(chart.model.dictionary.get(date.getString("name")))*1.1;
    float y = (minutesToY(data.get(dataKeys.get(0)))) + textAscent()/2;
    
    textFont(font.light14);
    mouseOverText = (pointM.x > x && pointM.x < x+textWidth(chart.model.dictionary.get(date.getString("name")))) && (pointM.y < y && pointM.y > y-textAscent());
    
    return mouseOverText;
  }
}
