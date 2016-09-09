/****************************************************
*
* Project Developed by Amanda Hires 2014
*
****************************************************/
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.providers.Google;
import de.fhpotsdam.unfolding.*;
import java.util.List;
import java.util.Date;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;

UnfoldingMap mapTerr;
UnfoldingMap mapStdG;
Location[] locations;
List<Marker> markersTerr;
List<Marker> markersStdG;

int zoomlevelTerr     = 5;
int zoomlevelStdG     = 10;
int currentLocation   = 0;
int markerGrowth      = 4;
int frameCountWait    = 100;
long lastTime         = 1000;
float markerScale     = 4.00;

// Note RSS and CSV files list earthquakes from most recent to oldest
String earthquakesRSSURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.atom";
String earthquakesCSVURL = "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.csv";

Table csvTable = loadTable(earthquakesCSVURL, "header");

public void setup(){
  size(800, 600, P2D);
  smooth();

  // Use google maps tile provider
  mapTerr = new UnfoldingMap(this, 0, 0, 395, 600, new Google.GoogleTerrainProvider());
  mapStdG = new UnfoldingMap(this, 405, 0, 395, 600, new Google.GoogleMapProvider());
  
  mapTerr.setTweening(true);
  mapStdG.setTweening(true);
  
  MapUtils.createDefaultEventDispatcher(this, mapTerr, mapStdG);
  
  List<Feature> earthquakes   = GeoRSSReader.loadDataGeoRSS(this, earthquakesRSSURL);
  List<Feature> animateQuakes = new ArrayList<Feature>();
  
  long previousEpoch = 0;
  int csvRowCount = csvTable.getRowCount();
  
  // Create Features for animated earthquake map
  int e_index = 0;
  for(Feature quakeFeature : earthquakes){
    String title = "Not Available";
    String magnitude = "0.00";
    String realMagnitude = "0.00";
    String displayMagnitude = "0.00";
    float  scaleMagnitude = 0.00;
    String waitTimeStr = "";
    
    // To avoid error in rare case where RSS file was updated and CSV has not been updated yet so RSS has more entries
    if(e_index < csvRowCount){
       String time = csvTable.getString(e_index++, "time");
       SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
       ParsePosition pos = new ParsePosition(0);
       Date date = df.parse(time, pos);
       long currentEpoch = date.getTime();
       waitTimeStr = Long.toString(previousEpoch - currentEpoch);
       previousEpoch = currentEpoch;
    }
    magnitude = Float.toString((Float)(quakeFeature.getProperty("magnitude")));
    title = (String)(quakeFeature.getProperty("title"));
    realMagnitude  = title.substring(2,5); 
    scaleMagnitude = markerScale * (Float.valueOf(realMagnitude));

    // Add properties to new Feature and its clone
    int f_index = markerGrowth;  
    for(f_index = markerGrowth; f_index > 0; f_index--){    
       PointFeature quakePointFeature = (PointFeature)quakeFeature;
       PointFeature quakeFeatureClone = new PointFeature(quakePointFeature.getLocation());   
       float growScale  = ((float)f_index * scaleMagnitude)/(float)markerGrowth;
       displayMagnitude = Float.toString(growScale);
       quakeFeatureClone.putProperty("realMagnitude", realMagnitude);
       quakeFeatureClone.putProperty("displayMagnitude", displayMagnitude);
       quakeFeatureClone.putProperty("title", title);
       quakeFeatureClone.putProperty("magnitude", magnitude);
       quakeFeatureClone.putProperty("waitTime", waitTimeStr);
       animateQuakes.add((Feature)quakeFeatureClone);
       
       quakeFeature.putProperty("realMagnitude", realMagnitude);
       quakeFeature.putProperty("displayMagnitude", realMagnitude);
       quakeFeature.putProperty("waitTime", "0");
    }
  }
  MarkerFactory markerFactoryStdG = new MarkerFactory();
  markerFactoryStdG.setPointClass(EarthquakeMarker.class);
  markersStdG = markerFactoryStdG.createMarkers(earthquakes);
  mapStdG.addMarkers(markersStdG);
  
  MarkerFactory markerFactoryTerr = new MarkerFactory();
  markerFactoryTerr.setPointClass(EarthquakeMarker.class);
  markersTerr = markerFactoryTerr.createMarkers(animateQuakes);
  int numMarkers = markersTerr.size();
  locations = new Location[numMarkers];
  currentLocation = locations.length-1;
  
  int m_index = 0;
  for(Marker quakeMarker : markersTerr){
    locations[m_index++] = quakeMarker.getLocation();
    System.out.println("PROCESSED MARKER: "+quakeMarker.getProperty("title"));
   }
   // start the timer for displaying earthquakes
   lastTime = millis();
}


public void draw(){
  background(0); // set map background to black
  mapTerr.draw();
  mapStdG.draw();
  
  if(frameCount % frameCountWait == 0){
    // Render the current marker in the list on the map and pan to it with default zoom level
    // Cast Marker to type it really is (EarthquakeMarker) in order to use accessor methods
    EarthquakeMarker currentQuake = (EarthquakeMarker)markersTerr.get(currentLocation);
    mapTerr.addMarker(currentQuake);
    
    // if not at the end of the list, check whether it's a new location
    if(currentLocation < locations.length-1){
       String currLoc = locations[currentLocation].toString();
       String prevLoc = locations[currentLocation+1].toString();
      
       // Only Pan to location if it is a new location
       if(!currLoc.equals(prevLoc)){
          long millisecs = (millis()-lastTime)*100;
          while(millisecs < currentQuake.getWaitTime()){
             // do nothing until it is time
             millisecs = (millis()-lastTime)*100;
          }
          mapTerr.zoomAndPanTo(locations[currentLocation], zoomlevelTerr);
          mapStdG.zoomAndPanTo(locations[currentLocation], zoomlevelStdG);
       }
    }
    else{ // at the end of the earthquakes, so new
       long millisecs = (millis()-lastTime)*100;
       while(millisecs < currentQuake.getWaitTime()){
          // do nothing until it is time
          millisecs = (millis()-lastTime)*100;
       }
       mapTerr.zoomAndPanTo(locations[currentLocation], zoomlevelTerr);
       mapStdG.zoomAndPanTo(locations[currentLocation], zoomlevelStdG);
    }
    // Go to the next location
    currentLocation--;
    
    // If all locations have been gone through then loop to the end again
    if (currentLocation < 0) {
      currentLocation = locations.length-1;
    }
    
    // reset timer for earthquake display
    lastTime = millis();
  }
  
}

void mouseMoved(){
  // Deselect all markers
  for(Marker markerT : mapTerr.getMarkers()){
    markerT.setSelected(false);
  }
  for(Marker markerS : mapStdG.getMarkers()){
    markerS.setSelected(false);
  }
  // Select hit marker
  Marker markerT = mapTerr.getFirstHitMarker(mouseX, mouseY);
  Marker markerS = mapStdG.getFirstHitMarker(mouseX, mouseY);
  if(markerT != null) {
    markerT.setSelected(true);
  }
  if(markerS != null) {
    markerS.setSelected(true);
  }
}

