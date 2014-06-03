class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, 0, "Zu Hause"));
    add(new Axis(this, 100, "Unterwegs"));
    add(new Axis(this, 200, "Mensa"));
    add(new Axis(this, 300, "Fakultät"));
    add(new Axis(this, 400, "Slub"));
    add(new Axis(this, 500, "Uni (Sonstige)"));
    add(new Axis(this, 600, "Draußen"));
    add(new Axis(this, 700, "Besorgungen"));
    add(new Axis(this, 800, "Hobby/Sport"));
  }
  
}
