/****************************************************
*
* Project Developed by Amanda Hires 2014
*
****************************************************/
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.Map;
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.utils.GeoUtils;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.geo.*;
import processing.core.*;
import processing.core.PGraphics;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.marker.SimplePointMarker;
import java.util.*;
import java.util.HashMap;

/**
 * A point marker for earthquakes that has its size and color set depending on the earthquake's magnitude.
 * When an earthquake marker is hovered over it becomes highlighted and displays the magnitude and location information.
 */
public class EarthquakeMarker extends SimplePointMarker {
  protected String title;
  protected Float  realMagnitude;
  protected Float  displayMagnitude;
  protected Long waitTime;
  protected String magnitude;
  protected int space  = 12;
  private PFont font;
  private float fontSize = 12;

  public EarthquakeMarker(Location location, HashMap properties) {
    this.location = location;
    
    // Use property 'title' as label
    Object titleProp = properties.get("title");
    if (titleProp != null && titleProp instanceof String) {
      title = new String(titleProp.toString());
    }
    
    // Extract the created 'realMagnitude' property of the earthquake
    Object realMagnitudeProp = properties.get("realMagnitude");   
    realMagnitude = Float.valueOf((String)realMagnitudeProp);
    
    // Extract the created 'displayMagnitude' property of the earthquake
    // Display magnitude is the scaled real magnitude
    Object dispMagnitudeProp = properties.get("displayMagnitude");   
    displayMagnitude = Float.valueOf((String)dispMagnitudeProp);
    
    // Use property 'magnitude' for marker color
    // This property is just the whole number part of the real magnitude
    Object magnitudeProp  = properties.get("magnitude");
    magnitude = new String(magnitudeProp.toString());
    
    // Extract the created 'waitTime' property of the earthquake
    Object waitTimeProp = properties.get("waitTime");
    waitTime = Long.valueOf((String)waitTimeProp);

    strokeWeight = 1;
   
   // Set the earthquake marker color based on the earthquake's 'magnitude' property
   // Processing's color(int r, int g, int b) function is not available in java, so use straight ints
   if(magnitude.equals("0.0")){/* BROWN */
      color                = -7650029;
      highlightColor       = -2180985;
      highlightStrokeColor = -2180985;      
    } 
    else if(magnitude.equals("1.0")){/* PURPLE */
      color          = -8388480;
      strokeColor    = -8388480;
      highlightColor = -4565549;
    } 
    else if(magnitude.equals("2.0")){/* BLUE */
     color          = -16777011;
     strokeColor    = -16777011;
     highlightColor = -7876870;
    } 
    else if(magnitude.equals("3.0")){/* TURQUOISE */
      color          = -16744320;
      strokeColor    = -16744320;
      highlightColor = -12004916;
    }
    else if(magnitude.equals("4.0")){/* GREEN */
      color          = -16744448;
      strokeColor    = -16744448;
      highlightColor = -6751336;
    }
    else if(magnitude.equals("5.0")){/* YELLOW */
      color          = -256;
      strokeColor    = -256;
      highlightColor = -1331;
    }
    else if(magnitude.equals("6.0")){/* ORANGE */
      color          = -29696;
      strokeColor    = -29696;
      highlightColor = -744352;
    }
    else if(magnitude.equals("7.0")){/* PINK */
      color          = -60269;
      strokeColor    = -60269;
      highlightColor = -16181;
    }
    else if(magnitude.equals("8.0")){/* RED */
      color          = -52429;
      strokeColor    = -52429;
      highlightColor = -360334;
    }       
    else{/* Magnitude is 9+: BRIGHT RED */
      color          = -65536;
      strokeColor    = -65536;
      highlightColor = -2354116;
    } 
  }


  // Display the Earthquake Marker
  public void draw(PGraphics pg, float x, float y, UnfoldingMap map){
    pg.pushStyle();
    pg.pushMatrix();
    if (selected) {
      pg.translate(0, 0);
    }
    pg.strokeWeight(strokeWeight);
    if (selected) {
      pg.fill(highlightColor);
      pg.stroke(highlightStrokeColor);
    } else {
      pg.fill(color);
      pg.stroke(strokeColor);
    }
    
    // scale marker size by current map zoom
    float mapZoom = map.getZoomLevel();
    float ellipseWidthHeight = displayMagnitude*mapZoom;
    
    pg.ellipse(x, y, ellipseWidthHeight, ellipseWidthHeight);

    if (selected && title != null){
      if (font != null) {
        pg.textFont(font);
      }
      pg.fill(highlightColor);
      pg.stroke(highlightStrokeColor);
      pg.rect(x + ellipseWidthHeight*1.5f + strokeWeight / 2, y - fontSize + strokeWeight / 2 - space, pg.textWidth(title) + space*1.5f, fontSize + space);
      pg.fill(0, 0, 0); // Set text color to be black
      pg.text(title, Math.round(x + ellipseWidthHeight*1.5f + space*0.75f + strokeWeight / 2), Math.round(y + strokeWeight / 2 - space*0.75f));
    }
    
    pg.popMatrix();
    pg.popStyle();
  }

  public String getTitle(){
    String retTitle = new String(title);
    return retTitle;
  }
  public String getMagnitude(){
    String retMagnitude = new String(magnitude);
    return retMagnitude;
  }
  public float getRealMagnitude(){
    return realMagnitude.floatValue();
  }
  public float getDisplayMagnitude(){
    return displayMagnitude.floatValue();
  }  
  public long getWaitTime(){
    return waitTime.longValue();
  }
  
}

