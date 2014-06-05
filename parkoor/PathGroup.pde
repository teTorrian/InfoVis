class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  IntDict pathColor; // ein verrückter Processing-Datentyp, wie Map<String, int>
  IntDict pathColorHighlighted; // ein verrückter Processing-Datentyp, wie Map<String, int>
  
  PathGroup(Chart chart) {
    this.chart = chart;
    JSONArray data = chart.controller.data;
    
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

    // Es gibt scheinbar keinen Iterator?
    for(int i = 0; i < data.size(); i++) {
      add(new Path(this, data.getJSONObject(i)));
    }
  }
}
