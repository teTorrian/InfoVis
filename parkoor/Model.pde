import java.util.Map;
import java.util.Set;

class Model {
   Model(){
     
   }
   
   JSONArray getDataObjects(){
     return loadJSONArray("data.json");
   }
   
   JSONArray getDataObjects(ArrayList<LocationFilter> filters){
     JSONArray DataObjects = loadJSONArray("data.json");
     JSONArray json = loadJSONArray("data.json");
     for(int i = 0; i < filters.size(); i++){
       LocationFilter filter = filters.get(i);       
       String name = filter.name;
       int min = filter.min;
       int max = filter.max;       
       
       for(int j = 0; j < DataObjects.size(); j++){
         JSONObject data = json.getJSONObject(j);
         if(data.getInt(name) > max || data.getInt(name) < min){
           DataObjects.remove(j);
         }         
       }       
     }  
     return DataObjects;
   }  
   
  HashMap getLocationTimes(JSONObject DataObject){
    HashMap<String,Integer> LocationTimes = new HashMap<String,Integer>();
    LocationTimes.put("home",       DataObject.getInt("home"));
    LocationTimes.put("transit",    DataObject.getInt("transit"));
    LocationTimes.put("uni_mensa",  DataObject.getInt("uni_mensa"));
    LocationTimes.put("uni_fak",    DataObject.getInt("uni_fak"));
    LocationTimes.put("uni_slub",   DataObject.getInt("uni_slub"));
    LocationTimes.put("uni_other",  DataObject.getInt("uni_other"));
    LocationTimes.put("outdoor",    DataObject.getInt("outdoor"));
    LocationTimes.put("shopping",   DataObject.getInt("shopping"));
    LocationTimes.put("hobby",      DataObject.getInt("hobby"));
    return LocationTimes;
  }
}
