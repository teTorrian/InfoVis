class AxisGroup extends DrawableGroup<Axis> {
  
  Chart chart;
  Controller controller;
  ArrayList<Filter> filters;
  
  AxisGroup(Chart chart) {
    super();
    this.chart = chart;
    controller = chart.controller;
    
    ArrayList<String> locations = chart.model.getLocations();
    for (int i = 0; i < locations.size(); i++)
      add(new Axis(this, int(chart.getSpacing()*i + 2*chart.getSpacing()), chart.model.dictionary.get(locations.get(i)), locations.get(i)));

    filters = new ArrayList<Filter>();
    for (Axis axis:this) {
      filters.add(axis.locationFilter);
    }
  }
}
