class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, 0, "Achse 1"));
  }
  
}
