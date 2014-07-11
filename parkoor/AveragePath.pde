class AveragePath extends Path {
  
  ArrayList<PVector> pathVertices;
  
  AveragePath(PathGroup pathGroup, JSONObject date) {
    super(pathGroup, date);
  }
  
  void draw() {
    String entry_name = date.getString("name");
    
    // Pfadeckpunkte holen
    pathVertices = new ArrayList<PVector>();
    pathVertices.add(new PVector(-chart.offsetX, chart.getInnerHeight() - ((float)data.get(dataKeys.get(0))/1440) * chart.getInnerHeight()));
    int i = 0;
    for (String key : dataKeys) {
      pathVertices.add(new PVector(i++ * chart.getSpacing(), chart.getInnerHeight() - ((float)data.get(key)/1440) * chart.getInnerHeight()));
    }
    pathVertices.add(new PVector(chart.getInnerWidth()+chart.offsetX2, chart.getInnerHeight() - ((float)data.get(dataKeys.get(dataKeys.size()-1))/1440) * chart.getInnerHeight()));
        
    pushMatrix();
    
      dragAndDropManager.saveMatrix();
      
      if(!highlighted)
        fill(pathGroup.pathColor.get("average"));
      else
        fill(pathGroup.pathColorHighlighted.get("average"));
      noStroke();
      
      pushMatrix();
        textFont(font.light14);
        translate(-chart.offsetX - textWidth(chart.model.dictionary.get(entry_name))*1.1, (1 - (float)data.get(dataKeys.get(0))/1440) * chart.getInnerHeight() + textAscent()/2);
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
    boolean mouseOverPath = super.mouseOver(mouse);
    // TODO: Hover über Schrift abfangen
    
    PVector m = dragAndDropManager.transformVector(mouse);
    
    float x = -chart.offsetX - textWidth(chart.model.dictionary.get(date.getString("name")))*1.1;
    float y = (1 - (float)data.get(dataKeys.get(0))/1440) * chart.getInnerHeight() + textAscent()/2;
    
    textFont(font.light14);
    boolean mouseOverText = (m.x > x && m.x < x+textWidth(chart.model.dictionary.get(date.getString("name")))) && (m.y < y && m.y > y-textAscent());
    
    return mouseOverPath || mouseOverText;
  }
}
