class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  IntDict pathColor; // ein verrückter Processing-Datentyp, wie Map<String, int>
  IntDict pathColorHighlighted; // ein verrückter Processing-Datentyp, wie Map<String, int>
  JSONArray cachedData;
  Model model;
  
  // Double Click
  ArrayList<Filter> filters;
  PersonFilter personFilter;
  DateFilter dateFilter;
  
  // Multi-Select
  JSONArray selection;
  Path averagePath;
  ArrayList<String> dataKeys;
  
  PathGroup(Chart chart) {
    this.chart = chart;
    model = chart.controller.model;
    cachedData = model.getDataObjects();
    
    // Double Click
    filters = new ArrayList<Filter>();
    personFilter = new PersonFilter();
    filters.add(personFilter);
    dateFilter = new DateFilter();
    filters.add(dateFilter);
    
    // Multi-Select
    selection = new JSONArray();
    dataKeys = chart.controller.model.getLocations();
    
    pathColor = new IntDict();
    pathColor.set("Jonas", color(176, 40, 93, 70));
    pathColor.set("Christian", color(232, 74, 56, 70));
    pathColor.set("Vlad", color(7, 217, 98, 70));
    pathColor.set("Lukas", color(14, 123, 221, 70));
    pathColor.set("average", color(80, 80, 80, 180));
    
    pathColorHighlighted = new IntDict();
    pathColorHighlighted.set("Jonas", color(176, 40, 93, 180));
    pathColorHighlighted.set("Christian", color(232, 74, 56, 180));
    pathColorHighlighted.set("Vlad", color(7, 217, 98, 180));
    pathColorHighlighted.set("Lukas", color(14, 123, 221, 180));
    pathColorHighlighted.set("average", color(80, 80, 80, 180));
    
    updateFilters();
  }
  
  void updateFilters() {
    cachedData = chart.controller.model.getDataObjects(chart.axisGroup.filters);
    
    // Double Click
    cachedData = chart.controller.model.getDataObjects(cachedData, filters);
    
    this.clear();
    for(int i = 0; i < cachedData.size(); i++) {
      add(new Path(this, cachedData.getJSONObject(i)));
    }
  }
  
  // Multi-Select
  void extendSelection(JSONObject data) {
    selection.setJSONObject(selection.size(), data);
    JSONObject average = new JSONObject();
    average.setString("info", "average of " + selection.size() + " path(s)");
    average.setString("name", "average");
    for (String key : dataKeys) {
      float a = 0;
      for (int d = 0; d < selection.size(); d++) {
        a += (selection.getJSONObject(d).getFloat(key));
      }
      a /= selection.size();
      average.setFloat(key, a);
    }
    println(average);
    remove(averagePath);
    averagePath = new Path(this, average);
    add(averagePath);
  }
  
  void clearSelection() {
    remove(averagePath);
    // ... feeding the garbage collector
    selection = new JSONArray();
  }
}


