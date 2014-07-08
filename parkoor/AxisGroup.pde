class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  ArrayList<Filter> filters;
  
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
    
    filters = new ArrayList<Filter>();
    for (Axis axis:this) {
      filters.add(axis.locationFilter);
    }
    
//    DateFilter d = new DateFilter(new String[] {"2014-05-16", "2014-05-17"});
//    filters.add(d);
    
//    PersonFilter p = new PersonFilter(new String[] {"Jonas", "Lukas", "Jonas"});
//    println("PersonFilter: " + p.toString());
//    println("remove Jonas " + p.remove("Jonas"));
//    println("remove Jonas " + p.remove("Jonas"));
//    println("add Jonas " + p.add("Jonas"));
//    filters.add(p);
  }
  
}
