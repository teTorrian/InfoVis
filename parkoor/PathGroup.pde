class PathGroup extends DrawableGroup<Path> {

  Chart chart;
  JSONArray objects;
  
  PathGroup(Chart chart) {
    this.chart = chart;
    JSONArray data = chart.controller.data;

    // Es gibt scheinbar keinen Iterator?
    for(int i = 0; i < data.size(); i++) {
      add(new Path(chart, data.getJSONObject(i)));
    }
  }
}
