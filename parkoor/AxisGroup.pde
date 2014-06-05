class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  ArrayList<LocationFilter> locationFilters;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, 0, "Zu Hause", "home"));
    add(new Axis(this, 100, "Unterwegs", "transit"));
    add(new Axis(this, 200, "Mensa", "uni_mensa"));
    add(new Axis(this, 300, "Fakultät", "uni_fak"));
    add(new Axis(this, 400, "Slub", "uni_slub"));
    add(new Axis(this, 500, "Uni (Sonstige)", "uni_other"));
    add(new Axis(this, 600, "Draußen", "outdoor"));
    add(new Axis(this, 700, "Besorgungen", "outdoor"));
    add(new Axis(this, 800, "Hobby/Sport", "hobby"));
    
    locationFilters = new ArrayList<LocationFilter>();
    for (Axis axis:this) {
      println("adding "+axis.label+" "+(axis.locationFilter == null));
      locationFilters.add(axis.locationFilter);
    }
  }
  
}
