class AxisGroup extends DrawableGroup<Axis> {
  Chart chart;
  Controller controller;
  
  AxisGroup(Chart chart) {
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(chart, 0, "Achse 1"));
    add(new Axis(chart, 100, "Achse 2"));
    add(new Axis(chart, 200, "Achse 3"));
    add(new Axis(chart, 300, "Achse 4"));
  }
  
}
