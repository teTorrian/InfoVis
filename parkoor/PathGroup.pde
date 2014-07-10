import java.util.Map;

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
  AveragePath averagePath;
  HashMap<String, Float> averageMap;
  
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
    averageMap = new HashMap<String,Float>();
    
    pathColor = new IntDict();
    pathColor.set("Jonas", color(176, 40, 93, 70));
    pathColor.set("Christian", color(232, 74, 56, 70));
    pathColor.set("Vlad", color(7, 217, 98, 70));
    pathColor.set("Lukas", color(14, 123, 221, 70));
    pathColor.set("average", color(110, 110, 110, 180));
    
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
    
    this.clear();
    for(int i = 0; i < cachedData.size(); i++) {
      add(new Path(this, cachedData.getJSONObject(i)));
    }
  }
  
  // Multi-Select
  void updateMultiSelect() {
    JSONObject average = new JSONObject();
    averageMap.clear();
    for (String key : chart.controller.model.getLocations())
      averageMap.put(key, 0.0);
    int c = 0;
    // Werte aller selektierten Pfade aufsummieren
    for (Path path: this) {
      if(path.selected) {
        for(String key: averageMap.keySet()) {
          averageMap.put(key, (averageMap.get(key) + path.date.getFloat(key)));
        }
        c++;
      }
    }
    if(c > 1) {
      // Durchschnitt berechnen
      for(String key: averageMap.keySet()) {
        average.setFloat(key, (averageMap.get(key) / c));
      }
      average.setString("name", "Durchschnitt");
      average.setString("info", "average of " + c + " path(s)");
      println(average.getString("info"));
      remove(averagePath);
      averagePath = new AveragePath(this, average);
      //averagePath.selected = true;
      add(averagePath);
    }
  }
  
  void clearMultiSelect() {
    remove(averagePath);
  }
}


