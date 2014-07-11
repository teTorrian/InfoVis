import java.util.Map;
import java.util.HashSet;
import java.util.Calendar;

class Model {

  JSONArray cachedDataObjects;
  StringDict dictionary;

  Model(String filename) {
    cachedDataObjects = loadJSONArray(filename);
    
    compileDictionary();
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

  JSONArray getDataObjects(JSONArray dataObjects, ArrayList<Filter> filters) {
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
  
  /**
  * getLocations() gibt die Orte zurück und legt außerdem über deren
  * Reihenfolge fest, in welcher Ordnung die Achsen angezeigt werden.
  */
  ArrayList<String> getLocations() {
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
    return getLocations().size();
  }
  
  ArrayList<String> getPeople() {
    ArrayList<String> people = new ArrayList<String>();
    people.add("Christian");
    people.add("Jonas");
    people.add("Lukas");
    people.add("Vlad");
    return people;
  }
  
  int getPersonIndex(String name) {
    ArrayList<String> people = getPeople();
    for (int index = 0; index < people.size(); index++)
      if(people.get(index).equals(name))
        return index;
    return -1;
  }
  
  int getWeekday(String d) {
    Date date;
    DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
    DateFormat day = new SimpleDateFormat("EE");
    int i = 0;
    try {
      date = dateFormat.parse(d);
      // day.format(date) gibt den Wochentag zurück.
      // Calendar kann dagegen benutzt werden, um einen Index 
      // zu bekommen. Allerdings: So = 1, Mo = 2, ...
      Calendar c = Calendar.getInstance();
      c.setTime(date);
      i = c.get(Calendar.DAY_OF_WEEK);
    }
    catch (Exception e) {
      println("Unable to parse " + d);
    }
    // Mo = 1, Di = 2, ...
    i = ((i+5)%7)+1;
    return i;
  }
  
  HashSet<String> getDates() {
    HashSet<String> dates = new HashSet<String>();
    for (int i = 0; i < cachedDataObjects.size(); i++)
      dates.add(((JSONObject) cachedDataObjects.getJSONObject(i)).getString("date"));
      
    return dates;
  }
  
  void compileDictionary() {
    dictionary = new StringDict();
    dictionary.set("home", "Zu Hause");
    dictionary.set("transit", "Unterwegs");
    dictionary.set("uni_mensa", "Mensa");
    dictionary.set("uni_fak", "Fakultät");
    dictionary.set("uni_slub", "SLUB");
    dictionary.set("uni_other", "Uni (Sonstige)");
    dictionary.set("outdoor", "Draußen");
    dictionary.set("shopping", "Besorgungen");
    dictionary.set("hobby", "Hobby/Sport");
    dictionary.set("average", "Durchschnitt");
  }
}

String formatMinutes(float min) {
  int hours = int(min / 60);
  int minutes = int(min % 60);
  String minutesStr = "";
  if(minutes < 10)
    minutesStr += "0";
  minutesStr += str(minutes);
  return str(hours)+"h " + minutesStr + "m";
}

String formatHours(float hours) {
  return formatMinutes(hours*60);
}
