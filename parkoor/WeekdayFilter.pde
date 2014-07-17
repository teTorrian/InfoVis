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
      weekdays[d] = true;
      return true;
    }
    else
      return false;
  }
  
  JSONArray filterObjects(JSONArray dataObjects) {
    
    for (int i = 0; i < dataObjects.size(); ) {
      String data = ((JSONObject)dataObjects.getJSONObject(i)).getString("date");
      /*

      if (
      contains(data.getString("date")))
        dataObjects.remove(i);
      else
        i++;*/
    }
    
    return dataObjects;
  }
}
/*
  DateFilter(String toAdd) {
    add(toAdd);
  }
  
  DateFilter(String[] toAdd) {
    for(int i = 0; i < toAdd.length; i++)
      add(toAdd[i]);
  }
  
  boolean add(String toAdd) {
    if(validateDate(toAdd))
      return super.add(toAdd);
    else return false;
  }
  
  JSONArray filterObjects(JSONArray dataObjects) {
    
    for (int i = 0; i < dataObjects.size(); ) {
      JSONObject data = dataObjects.getJSONObject(i);

      if (contains(data.getString("date")))
        dataObjects.remove(i);
      else
        i++;
    }
    
    return dataObjects;
  }
  
  /**
  * Validierung des Datums (als String). dateFormat.parse() akzeptiert auch "14-5-20".
  * Validierung bei remove() ist nicht notwendig, da nur valide Daten in das Set aufgenommen werden.
  * Es wird angenommen, dass die Daten im JSONArray valide sind (nach dem Format "yyyy-mm-dd").
  *
  boolean validateDate(String d) {
    if((d.length() != 10) || (d.indexOf('-', 0) != 4) || (d.indexOf('-', 5) != 7))
      return false;
    try {
      date = dateFormat.parse(d);
    }
    catch (Exception e) {
      println("Unable to parse " + d);
      return false;
    }
    return true;
  }
  
  void fillFilter(HashSet<String> allDates) {
    clear();
    for(String date: allDates)
      add(date);
  }
}
*/
