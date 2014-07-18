class PersonBubble extends Bubble {
  String name;
  PathGroup pathGroup;
  
  PersonBubble(PathGroup pathGroup, BubbleAxis bubbelAxis, String label, String name, color highlightColor) {
    super(bubbelAxis, label, highlightColor);
    this.pathGroup = pathGroup;
    this.name = name;
  }
  
  boolean mousePressed() {
    if (mouseOver()) {
      if (!active) {
        active = true;
        PersonFilter pSel = pathGroup.pSel;
        if(pSel.isEmpty()) {
          pSel.fillFilter();
        }
        pSel.remove(name);
        pathGroup.updateSelectors(); 
        for (Path path : pathGroup) {
          if (!path.selected) {
            path.grayed = true;
          }
        }
        updated = true;
        loop();
        return true;
      } else {
        active = false;
        for (Path path : pathGroup) {
          if (path.selected) {
            path.selected = false;
            path.grayed = true;
          }
        }
        PersonFilter pSel = pathGroup.pSel;
        pSel.add(name);
        pathGroup.updateSelectors(); 
        updated = true;
        loop();
        return true;
      }
    } else {
      return false; 
    }
  }
  
}
