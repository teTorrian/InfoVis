import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class parkoor extends PApplet {



ControlP5 cp5;

public void setup(){ 
	size(1024,600);
	background(255); 
	PFont font;
	font = loadFont("UniversLTStd-LightCn-22.vlw");
	textFont(font);
	fill(0,0,0);
	text("Parallele Koordinaten", 50, 80);
	
	noStroke();
	cp5 = new ControlP5(this);
  
	// create a new button with name 'buttonA'
	cp5.addButton("test")
		.setValue(0)
		.setPosition(50,100)
		.setSize(200,60);

     
     cp5.addSlider("sliderTicks2")
     .setPosition(100,370)
     .setWidth(400)
     .setRange(255,0) // values can range from big to small as well
     .setValue(128)
     .setNumberOfTickMarks(7)
     .setSliderMode(Slider.FLEXIBLE)
     .setNumberOfTickMarks(2)
     ;

} 
 
public void draw() {
}

    static public void main(String args[]) {
        PApplet.main(new String[] { "--bgcolor=#ECE9D8", "parkoor" });
    }
}
