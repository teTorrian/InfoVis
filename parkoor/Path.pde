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
    //TreeMap<String, Integer> Locs = chart.controller.getLocationTimes(json.getJSONObject(0));
    pushMatrix();
    fill(0);
    beginShape();
    for(int i = 3; i < date.size(); i++) {
      //vertex(date.get(
    }
    endShape(CLOSE);
    popMatrix();
  }
  
}
