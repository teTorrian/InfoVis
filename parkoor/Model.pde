import java.util.Map;
import java.util.Set;

class Model {

  JSONArray cachedDataObjects;

  Model(String filename) {
    cachedDataObjects = loadJSONArray(filename);
  }

  JSONArray getDataObjects() {
    return cachedDataObjects;
  }

  JSONArray getDataObjects(ArrayList<LocationFilter> filters) {
    // copy original...
    JSONArray dataObjects = JSONArray.parse(cachedDataObjects.toString());

    for (int i = 0; i < filters.size(); i++) {
      LocationFilter filter = filters.get(i);
      String name = filter.name;
      float min = filter.min;
      float max = filter.max;  
      
      for (int j = 0; j < dataObjects.size();) {
        JSONObject data = dataObjects.getJSONObject(j);
       
        if (data.getInt(name) > max*60 || data.getInt(name) < min*60) {
          dataObjects.remove(j); 
        } else {      
          j++;
        }
      }   
    }
   
    return dataObjects;
  }  

  HashMap getLocationTimes(JSONObject dataObject) {
    HashMap<String, Integer> LocationTimes = new HashMap<String, Integer>();
    LocationTimes.put("home", dataObject.getInt("home"));
    LocationTimes.put("transit", dataObject.getInt("transit"));
    LocationTimes.put("uni_mensa", dataObject.getInt("uni_mensa"));
    LocationTimes.put("uni_fak", dataObject.getInt("uni_fak"));
    LocationTimes.put("uni_slub", dataObject.getInt("uni_slub"));
    LocationTimes.put("uni_other", dataObject.getInt("uni_other"));
    LocationTimes.put("outdoor", dataObject.getInt("outdoor"));
    LocationTimes.put("shopping", dataObject.getInt("shopping"));
    LocationTimes.put("hobby", dataObject.getInt("hobby"));
    return LocationTimes;
  }
  
  ArrayList<String> getLocations(JSONObject dataObject) {
    ArrayList<String> locations = new ArrayList<String>();
    locations.add("home");
    locations.add("transit");
    locations.add("uni_mensa");
    locations.add("uni_fak");
    locations.add("uni_slub");
    locations.add("uni_other");
    locations.add("outdoor");
    locations.add("shopping");
    locations.add("hobby");
    return locations;
  }
}

