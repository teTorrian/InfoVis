import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.util.HashSet;

class WeekdayFilter implements Filter {
  DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
  Date date;
  
  boolean weekdays[] = {false, false, false, false, false, false, false};
  
  WeekdayFilter() {
  }
  
  WeekdayFilter(int d) {
    if(d > 0 && d < 8)
      weekdays[d] = true;
  }
  
  WeekdayFilter(boolean[] d) {
    if(d.length == 7)
      for(int i = 0; i < 7; i++)
        weekdays[i] = d[i];
  }
  
  /**
  * Fügt den Wochentag d dem Filter hinzu (Mo = 1, Di = 2, ... So = 7).
  **/
  boolean add(int d) {
    if(d > 0 && d < 8) {
      weekdays[d] = true;
      return true;
    }
    else
      return false;
  }

  /**
  * Entfernt den Wochentag d aus dem Filter hinzu (Mo = 1, Di = 2, ... So = 7).
  **/
  boolean remove(int d) {
    if(d > 0 && d < 8) {
      weekdays[d] = false;
      return true;
    }
    else
      return false;
  }
  
  JSONArray filterObjects(JSONArray dataObjects) {
    println(dataObjects.size() + " Object(s) to filter.");
    
    for (int i = 0; i < dataObjects.size(); ) {
      int idx = getWeekday(((JSONObject)dataObjects.getJSONObject(i)).getString("date"));

      if (weekdays[idx-1])
        dataObjects.remove(i);
      else
        i++;
    }

    println(dataObjects.size() + " Object(s) left.");
    return dataObjects;
  }
  
  int getWeekday(String d) {
    Date date;
    DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
    //DateFormat day = new SimpleDateFormat("EE");
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
  
  void fillFilter() {
    for(int i = 0; i < 7; i++)
      weekdays[i] = true;
  }
}
