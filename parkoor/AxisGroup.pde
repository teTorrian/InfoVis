class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  ArrayList<LocationFilter> locationFilters;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    add(new Axis(this, int(chart.getSpacing()*0), "Zu Hause", "home"));
    add(new Axis(this, int(chart.getSpacing()*1), "Unterwegs", "transit"));
    add(new Axis(this, int(chart.getSpacing()*2), "Mensa", "uni_mensa"));
    add(new Axis(this, int(chart.getSpacing()*3), "Fakultät", "uni_fak"));
    add(new Axis(this, int(chart.getSpacing()*4), "Slub", "uni_slub"));
    add(new Axis(this, int(chart.getSpacing()*5), "Uni (Sonstige)", "uni_other"));
    add(new Axis(this, int(chart.getSpacing()*6), "Draußen", "outdoor"));
    add(new Axis(this, int(chart.getSpacing()*7), "Besorgungen", "shopping"));
    add(new Axis(this, int(chart.getSpacing()*8), "Hobby/Sport", "hobby"));
    
    locationFilters = new ArrayList<LocationFilter>();
    for (Axis axis:this) {
      locationFilters.add(axis.locationFilter);
    }
  }
  
}
