class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  IntDict pathColor; // ein verrückter Processing-Datentyp, wie Map<String, int>
  IntDict pathColorHighlighted; // ein verrückter Processing-Datentyp, wie Map<String, int>
  JSONArray cachedData;
  Model model;
  
  ArrayList<Filter> filters;
  
  PathGroup(Chart chart) {
    this.chart = chart;
    model = chart.controller.model;
    cachedData = model.getDataObjects();
    
    filters = new ArrayList<Filter>();
    
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

    updateFilters();
  }
  
  void updateFilters() {
    cachedData = chart.controller.model.getDataObjects(chart.axisGroup.filters);
    cachedData = chart.controller.model.getDataObjects(cachedData, filters);
    this.clear();
    for(int i = 0; i < cachedData.size(); i++) {
      add(new Path(this, cachedData.getJSONObject(i)));
    }
  }
}


