class Path implements Drawable {
  
  boolean updated;
  
  Chart chart;
  JSONObject date;
  AxisGroup axes;
  
  Path(Chart chart, JSONObject date) {
    this.chart = chart;
    this.date = date;
    axes = chart.axisGroup;
  }
  
  boolean updated() {
    return updated;
  }
  
  void update() {
    updated = true;
  }
  
  void draw() {
    HashMap<String, Integer> data = chart.controller.model.getLocationTimes(date);
    float c = (float)chart.height / 1440;
    
    pushMatrix();
    stroke(chart.pathColor.get(date.getString("name")));
    //strokeWeight(2);
    noFill();
    
    beginShape();
    int i = 0;
    for (String key: data.keySet()) {
      // x muss ersetzt werden durch axes.get(i++).x
      vertex(i++ * 100, chart.height - data.get(key) * c);
    }
    endShape();
    
    popMatrix();
  }

  
}
