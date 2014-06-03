class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, 0, "Achse 1"));
    add(new Axis(this, 100, "Achse 2"));
    add(new Axis(this, 200, "Achse 3"));
    add(new Axis(this, 300, "Achse 4"));
  }
  
}
