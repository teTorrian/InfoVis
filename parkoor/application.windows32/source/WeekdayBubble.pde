class WeekdayBubble extends Bubble {
  int weekday;
  PathGroup pathGroup;
  
  
  WeekdayBubble(PathGroup pathGroup, BubbleAxis bubbelAxis, String label, int weekday, color highlightColor) {
    super(bubbelAxis, label, highlightColor);
    this.pathGroup = pathGroup;
    this.weekday = weekday;
  }
 
  boolean mousePressed() {
    if (mouseOver()) {
      if (!active) {
        active = true;
        WeekdayFilter wdSel = pathGroup.wdSel;
        //wdSel.fillFilter();
        wdSel.remove(weekday);
        pathGroup.updateWeekdaySelectors(); 
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
        WeekdayFilter wdSel = pathGroup.wdSel;
        //wdSel.fillFilter();
        wdSel.add(weekday);
        pathGroup.updateWeekdaySelectors(); 
        updated = true;
        loop();
        return true;
      }
    } else {
      return false; 
    }
  }
  
//  boolean mouseMoved() {
//    if (super.mouseMoved()) {
//    } else {
//    }
//  }
}
