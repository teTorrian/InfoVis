import java.util.Map;
import java.util.HashSet;

class Model {

  JSONArray cachedDataObjects;

  Model(String filename) {
    cachedDataObjects = loadJSONArray(filename);
  }

  JSONArray getDataObjects() {
    return cachedDataObjects;
  }

  JSONArray getDataObjects(ArrayList<Filter> filters) {
    // copy original...
    JSONArray dataObjects = JSONArray.parse(cachedDataObjects.toString());
    
    for (Filter f: filters) {
      dataObjects = f.filterObjects(dataObjects);
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
  
  int getLocationCount() {
    return getLocations(cachedDataObjects.getJSONObject(0)).size();
  }
}

