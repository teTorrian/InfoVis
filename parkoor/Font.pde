class Font {
  PFont bold22;
  PFont light12;  
  PFont light14;
  PFont light22;
  
  Font() {
    bold22  = loadFont("UniversLTStd-BoldCn-22.vlw");
    light12 = loadFont("UniversLTStd-LightCn-12.vlw");
    light14 = loadFont("UniversLTStd-LightCn-14.vlw");
    light22 = loadFont("UniversLTStd-LightCn-22.vlw");
  }
}
