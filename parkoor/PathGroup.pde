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
    pathColor.set("Jonas", color(176, 40, 93, 100));
    pathColor.set("Christian", color(232, 74, 56, 100));
    pathColor.set("Vlad", color(7, 217, 98, 100));
    pathColor.set("Lukas", color(14, 123, 221, 100));
    
    pathColorHighlighted = new IntDict();
    pathColorHighlighted.set("Jonas", color(176, 40, 93, 200));
    pathColorHighlighted.set("Christian", color(232, 74, 56, 200));
    pathColorHighlighted.set("Vlad", color(7, 217, 98, 200));
    pathColorHighlighted.set("Lukas", color(14, 123, 221, 200));

    updateLocationFilters();
  }
  
  void updateLocationFilters() {
    cachedData = chart.controller.model.getDataObjects(chart.axisGroup.locationFilters);
    this.clear();
    for(int i = 0; i < cachedData.size(); i++) {
      add(new Path(this, cachedData.getJSONObject(i)));
    }
  }
}


