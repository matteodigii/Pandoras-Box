// Importing necessary libraries
import processing.serial.*;
import oscP5.*;
import netP5.*;

// Declaring their instances
Serial myPort;
OscP5 oscP5;
NetAddress myRemoteLocation;

// --------------------- GLOBAL VARIABLES --------------------- //

// To allow switch between Arduino and Mouse (serves as a Freeze Button)
boolean useArduino = true;
boolean blockMouseUpdate = false;

// -- Coordinate listing -- 
float x = 0.5, y = 0.5;
float x_mouse = 0.5, y_mouse = 0.5;
float x_arduino = 0.5, y_arduino = 0.5;

float dx, dy;

float squareSize;
float squareX, squareY;

float centerX, centerY;
float maxRadius = 280;

// Check the classlist defined in the script called 'particles_class.pde'
ArrayList<Particle> particles = new ArrayList<Particle>();

// Images to load later on
PImage coperchioImage, bordoImage;
PImage logoImage;
PImage distortionImg, chorusImg, reverbImg, delayImg;
PImage optionsImg;

// Reset Button related variables
float btnW = 160;
float btnH = 40;
float btnX, btnY;
float resetBtnW = 120;
float resetBtnH = 40;
float resetBtnX, resetBtnY;

// To enable re-size of the window
int baseSize = 700;  // Default window size for 100%
String[] zoomLevels = {"50%", "75%", "100%", "125%"};
float[] zoomFactors = {0.5, 0.75, 1.0, 1.25};

// Dropdown zoom menù
int dropdownX = 505;
int dropdownY = 20;
int dropdownWidth = 120;
int dropdownHeight = 30;
boolean dropdownOpen = false;
int selectedIndex = 2; // 100%
float currentZoom = 1.0;

// Supplementary knobs menù
boolean showMoreTopLeft = false;
boolean showMoreTopRight = false;
boolean showMoreBottomLeft = false;
boolean showMoreBottomRight = false;
float margin = 80;
float moreBtnSize = 20;
int xOffset = 90;
int yOffset = -55;

// Default values of supplementary knobs (according to our JUCE definition)
float distDrive = 1;
float chorusDepth = 0.4;
float chorusRate = 0.02;
float reverbRoom = 0.5;
float reverbWidth = 0.5;
float delayFeedback = 0.2;
float delayTime = 0.24;

// Maximum radius of supplementary knobs
float knobSensitivity = 40; 

// String that contains the current dragged supplementary knob
String activeKnob = "";  


// --------------------- SETUP ---------------------

void setup() {
  // This is done to avoid the possibility of setting full-screen
  // You have the zoom window to do it manually
  pixelDensity(displayDensity());    
  smooth(8);                        
  surface.setSize(baseSize, baseSize);
  surface.setTitle("Pandora's Box");

  textFont(createFont("Arial", 16, true)); 
  
  // Loading all the image components
  coperchioImage = loadImage("coperchio.png");
  bordoImage = loadImage("bordo.png");
  logoImage = loadImage("logo.png");
  distortionImg = loadImage("distortion.png");
  chorusImg = loadImage("chorus.png");
  reverbImg = loadImage("reverb.png");
  delayImg = loadImage("delay.png");
  optionsImg = loadImage("options.png");

  squareSize = 550;
  squareX = (width - squareSize) / 2;
  squareY = (height - squareSize) / 2;

  centerX = width / 2;
  centerY = height / 2; 
  
  // Needed to setup OSC Messages later on
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);

  // To enable Arduino use 
  String[] ports = Serial.list();
  printArray(ports);
  if (ports.length > 4) {
    myPort = new Serial(this, ports[1], 9600);
    myPort.bufferUntil('\n');
  } else {
    println("Nessuna porta seriale disponibile!");
  }
  
  // For a cool/futuristic effect
  for (int i = 0; i < 20; i++) {
    particles.add(new Particle());
  }
}


// --------------------- DRAW ---------------------

void draw() {
  
  background(210, 180, 140);
  imageMode(CENTER);
  pushMatrix();
  scale(currentZoom);

  updateDirectionVector();
  
  float[] values = computeEffectValues(dx, dy);

  float topLeftVal = values[0];
  float topRightVal = values[1];
  float bottomRightVal = values[2];
  float bottomLeftVal = values[3];

  drawBackground();
  drawEffectImages(dx, dy, topLeftVal, topRightVal, bottomRightVal, bottomLeftVal);
  drawCoperchio(dx, dy);
  drawParticles();

  updateMouseCoordsOnInteraction();

  drawPointer();
  drawMainKnobs(topLeftVal, topRightVal, bottomRightVal, bottomLeftVal);
  drawKnobLabels();
  drawMoreButtons();
  drawConditionalKnobPanels();
  sendOscMessages(topLeftVal, topRightVal, bottomRightVal, bottomLeftVal);
  drawCenterSquare();
  drawModeButtons();
  drawResetButton();
  drawDropdown();
  drawLogo();

  popMatrix();
}

// ----- OSC and Serial --------
void sendOscMessages(float tl, float tr, float br, float bl) {
  OscMessage coord_msg = new OscMessage("/coordinates");
  coord_msg.add(tl);
  coord_msg.add(tr);
  coord_msg.add(br);
  coord_msg.add(bl);
  oscP5.send(coord_msg, myRemoteLocation);

  OscMessage params_msg = new OscMessage("/parameters");
  params_msg.add(distDrive);
  params_msg.add(chorusRate);
  params_msg.add(chorusDepth);
  params_msg.add(reverbRoom);
  params_msg.add(reverbWidth);
  params_msg.add(delayFeedback);
  params_msg.add(delayTime);
  oscP5.send(params_msg, myRemoteLocation);

  // Log of values in the console
  println("OSC /coordinates:", nf(tl,1,2), nf(tr,1,2), nf(br,1,2), nf(bl,1,2));
  println("OSC /parameters:", 
    "Drive", nf(distDrive,1,2), 
    "Rate", nf(chorusRate,1,3), 
    "Depth", nf(chorusDepth,1,2),
    "Room", nf(reverbRoom,1,2), 
    "Width", nf(reverbWidth,1,2),
    "Feedback", nf(delayFeedback,1,2), 
    "Time", nf(delayTime,1,2)
  );
}

// To assess Serial Communication
void serialEvent(Serial p) {
  if (!useArduino) return;

  String inString = trim(p.readStringUntil('\n'));
  if (inString == null) return;
  if (inString.indexOf(',') > 0) {
    String[] parts = split(inString, ',');
    if (parts.length >= 2) {
      x_arduino = constrain(float(parts[0]), 0, 1);
      y_arduino = constrain(1 - float(parts[1]), 0, 1);
      x = x_arduino;
      y = y_arduino;
    }
  }
}
