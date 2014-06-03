Controller controller;
View view;

void setup(){ 
  	size(1024,600);

  /*Model model = new Model();
  JSONArray allData;
  allData = model.getDataObjects(); 
  println(allData.size());
  /*
  HashMap<String, Integer> Locs = new HashMap<String, Integer>();
  Locs = model.getLocationTimes(json.getJSONObject(0));
  for(Map.Entry entry : Locs.entrySet()){
    println(entry.getKey() + " " + entry.getValue());  
  }
  
  LocationFilter Loc1 = new LocationFilter(0, 1300, "home");
  LocationFilter Loc2 = new LocationFilter(10, 1000, "home");
  ArrayList<LocationFilter> lf;
  lf = new ArrayList<LocationFilter>();
  lf.add(Loc1);
  //lf.add(Loc2);
  println(model.getDataObjects(lf).size());
*/
  	PFont font;
  	font = loadFont("UniversLTStd-LightCn-22.vlw");
  	textFont(font);
     
   controller = new Controller(100,165,824,330);
   view = controller.view;
   
} 
 
void draw() {
  view.update();
  if (view.updated()) {
    view.draw();
    fill(0);
    text("Parallele Koordinaten", 100, 100);
  } else {
    noLoop();
  }
}
