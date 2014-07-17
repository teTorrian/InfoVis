class LocationFilter implements Filter {
  float min;
  float max;
  String name;
  
  LocationFilter(float min, float max, String name) {
    this.min = min;
    this.max = max;
    this.name = name;
  }
  
  JSONArray filterObjects(JSONArray dataObjects) {
    for (int j = 0; j < dataObjects.size(); ) {
      JSONObject data = dataObjects.getJSONObject(j);
      
      if (data.getInt(name) > max*60 || data.getInt(name) < min*60)
        dataObjects.remove(j);
      else
        j++;
    }
    return dataObjects;
  }
  
  void fillFilter() {
    // TODO
  }
}
