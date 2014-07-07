import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.util.HashSet;

class DateFilter extends HashSet<String> implements Filter {
  DateFormat dateFormat = new SimpleDateFormat ("yyyy-MM-dd");;
  Date date;
  
  DateFilter() {
  }
  
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
  */
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
}
