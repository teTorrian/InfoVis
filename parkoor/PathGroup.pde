import java.util.Map;

class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  IntDict pathColor; // ein verrückter Processing-Datentyp, wie Map<String, int>
  IntDict pathColorHighlighted; // ein verrückter Processing-Datentyp, wie Map<String, int>
  JSONArray cachedData;
  Model model;
  
  ArrayList<Filter> selectors;
  PersonFilter pSel;
  DateFilter dSel;
  WeekdayFilter wdSel;
  /**
    * Da die Filter hier allerdings als Selektoren "missbraucht"
    * werden, muss auf die umgekehrte Logik geachtet werden. Daher
    * müssen die Filter immer zuerst gefüllt werden (fillFilter),
    * um danach wieder einzelne Elemente zu entfernen (remove).
    */
  
  // Multi-Select
  AveragePath averagePath;
  HashMap<String, Float> averageMap;
  ArrayList<Path> ordered;
  
  PathGroup(Chart chart) {
    this.chart = chart;
    model = chart.controller.model;
    cachedData = model.getDataObjects();
    ordered = new ArrayList<Path>();
    for(int i = 0; i < cachedData.size(); i++) {
      Path path = new Path(this, cachedData.getJSONObject(i));
      ordered.add(path);
      add(path);
    }

    // Initialisieren der Selektoren
    resetSelectors();
    
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
  
  void updateSelectors() {
    println("Updating Selectors...");
    cachedData = chart.controller.model.getDataObjects(selectors);
    
    for (int i = 0; i < cachedData.size(); i++) {
      JSONObject personDay = cachedData.getJSONObject(i);
      ordered.get(personDay.getInt("id")).selected = true;
    }
    updateMultiSelect();
  }
  
  void updateFilters() {
    cachedData = chart.controller.model.getDataObjects(chart.axisGroup.filters);
    
    for (Path path : ordered) {
      path.hidden = true;
    }
    
    for (int i = 0; i < cachedData.size(); i++) {
      JSONObject personDay = cachedData.getJSONObject(i);
      ordered.get(personDay.getInt("id")).hidden = false;
    }
    updateMultiSelect();
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
      if(path.selected && !path.hidden) {
        for(String key: averageMap.keySet()) {
          averageMap.put(key, (averageMap.get(key) + path.date.getFloat(key)));
        }
        c++;
      }
    }
    remove(averagePath);
    if (c > 1) {
      // Durchschnitt berechnen
      for(String key: averageMap.keySet()) {
        average.setFloat(key, (averageMap.get(key) / c));
      }
      average.setString("name", "average");
      average.setString("info", "average of " + c + " path(s)");
      println(average.getString("info"));
      averagePath = new AveragePath(this, average);
      //averagePath.selected = true;
      add(averagePath);
    }
  }
  
  void clearMultiSelect() {
    remove(averagePath);
  }
  
  boolean mousePressed() {
    if (!super.mousePressed()) {
      clearMultiSelect();
      resetSelectors();
      updated = true;
      loop();
      return true;
    }
    return false;
  }
  
  void resetSelectors() {
    // Feeding the Garbage Collector...
    selectors = new ArrayList<Filter>();
    
    // Person-Selector
    pSel = new PersonFilter();
    pSel.fillFilter();
    selectors.add(pSel);
    
    // Date-Selector  –– NOT USED
    /* Dieser Filter könnte genutzt werden, um alle Personen 
       an einem Tag auszuwählen. */
    /*dSel = new DateFilter();
    selectors.add(dSel);*/
    
    // Weekday-Selector
    wdSel = new WeekdayFilter();
    //wdSel.fillFilter();
    selectors.add(wdSel);
  }
}
