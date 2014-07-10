class AveragePath extends Path {
  
  AveragePath(PathGroup pathGroup, JSONObject date) {
    super(pathGroup, date);
  }
  
  void draw() {
    float c = (float)chart.getInnerHeight() / 1440;

    pushMatrix();
    
      dragAndDropManager.saveMatrix();
      String entry_name = date.getString("name");
    
      stroke(pathGroup.pathColorHighlighted.get(entry_name));

      /*if(selected && grayed)
        stroke(pathGroup.pathColorHighlighted.get(entry_name));*/
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
}
