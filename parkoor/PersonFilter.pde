import java.util.HashSet;

class PersonFilter extends HashSet<String> implements Filter {

  PersonFilter() {
  }
  
  PersonFilter(String toAdd) {
    add(toAdd);
  }
  
  PersonFilter(String[] toAdd) {
    for(int i = 0; i < toAdd.length; i++)
      add(toAdd[i]);
  }

  JSONArray filterObjects(JSONArray dataObjects) {
    
    for (int i = 0; i < dataObjects.size(); ) {
      JSONObject data = dataObjects.getJSONObject(i);

      if (contains(data.getString("name")))
        dataObjects.remove(i);
      else
        i++;
    }
    
    return dataObjects;
  }
  
  void resetFilter() {
    clear();
    add("Jonas");
    add("Vlad");
    add("Lukas");
    add("Christian");
  }
}
