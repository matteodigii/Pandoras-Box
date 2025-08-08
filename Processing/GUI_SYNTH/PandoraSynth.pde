import controlP5.*;
import oscP5.*;
import netP5.*;

ControlP5   cp5;
OscP5       oscP5;
NetAddress  scAddr;

PImage logo;

// —————————————————————————————————————————————————————
// GUI CONTROLS
// —————————————————————————————————————————————————————
// Carrier
Knob         carrierFreqKnob, carrierVibRateKnob, carrierVibDepthKnob;
Knob         carrierAttackKnob, carrierSustainKnob, carrierReleaseKnob;
DropdownList carrierWaveform;

// Modulators
Knob         [] modFreqKnob     = new Knob[4];
Knob         [] modIndexKnob    = new Knob[4];
Knob         [] modAttackKnob   = new Knob[4];
Knob         [] modSustainKnob  = new Knob[4];
Knob         [] modReleaseKnob  = new Knob[4];
DropdownList [] modWaveform     = new DropdownList[4];
DropdownList [] modTarget       = new DropdownList[5];
Button       [] modAddBtn       = new Button[4];
Button       [] modRemBtn       = new Button[4];

// —————————————————————————————————————————————————————
// Layout parameters (globali, per disegno e centri)
// —————————————————————————————————————————————————————
int cx, cy, dy;         // carrier origin & step
int mx0, my0, dx, sdy;  // modulator origin & steps
int knobR, smallR;      // raggi dei knob
int menuW, carrierMenuH, waveH, targetH;
int fgColor;            // colore comune a foreground e linea

void setup() {
  size(850, 700, P2D);
  pixelDensity(displayDensity());
  smooth(8);
  textFont(createFont("Arial", 16, true));
  
  // — parametri di layout —
  cx = 40;   cy = 50;  dy = 110;
  mx0 = 200; my0 = 50; dx = 150; sdy = 20;
  knobR = 30; smallR = 20;
  menuW = 100; carrierMenuH = 100; waveH = 80; targetH = 80;
  
  // — colori e CP5 —
  fgColor = color(230, 200, 160);
  cp5 = new ControlP5(this);
  cp5.setColorBackground(color(230, 200, 160));
  cp5.setColorForeground(color(80, 50, 30));
  cp5.setColorActive(color(200, 160, 120));
  
  oscP5  = new OscP5(this, 12000);
  scAddr = new NetAddress("127.0.0.1", 57120);
  
  // — Carrier knobs —
  int ty = cy;
  carrierVibRateKnob = cp5.addKnob("carrierVibRate")
    .setPosition(cx, ty)
    .setRadius(knobR)
    .setRange(0, 20)
    .setValue(5)
    .setCaptionLabel("Vib Rate")
    .setNumberOfTickMarks(11)
    .snapToTickMarks(false);
  
  carrierVibDepthKnob = cp5.addKnob("carrierVibDepth")
    .setPosition(cx, ty += dy)
    .setRadius(knobR)
    .setRange(0, 20)
    .setValue(5)
    .setCaptionLabel("Vib Depth")
    .setNumberOfTickMarks(11)
    .snapToTickMarks(false);
  
  carrierAttackKnob = cp5.addKnob("carrierAttack")
    .setPosition(cx, ty += dy)
    .setRadius(knobR)
    .setRange(0, 2)
    .setValue(0.5)
    .setCaptionLabel("Attack")
    .setNumberOfTickMarks(9)
    .snapToTickMarks(false);
  
  carrierSustainKnob = cp5.addKnob("carrierSustain")
    .setPosition(cx, ty += dy)
    .setRadius(knobR)
    .setRange(0, 2)
    .setValue(1.5)
    .setCaptionLabel("Sustain")
    .setNumberOfTickMarks(9)
    .snapToTickMarks(false);
  
  carrierReleaseKnob = cp5.addKnob("carrierRelease")
    .setPosition(cx, ty += dy)
    .setRadius(knobR)
    .setRange(0, 5)
    .setValue(1.5)
    .setCaptionLabel("Release")
    .setNumberOfTickMarks(11)
    .snapToTickMarks(false);
  
  // — Carrier dropdown centrato —
  float carrierMenuX = cx + knobR - menuW/2.0;
  carrierWaveform = cp5.addDropdownList("carrierWaveform")
    .setPosition(carrierMenuX, ty += dy + 10)
    .setSize(menuW, carrierMenuH)
    .addItem("Sine", 0)
    .addItem("Pulse", 1)
    .addItem("Triangle", 2)
    .addItem("Saw", 3)
    .setValue(2)
    .setCaptionLabel("Waveform");
  
  // — Modulator slots —
  for (int i = 0; i < 4; i++) {
    int ix = mx0 + i * dx;
    int iy = my0;
    
    modFreqKnob[i] = cp5.addKnob("mod" + i + "_freq")
      .setPosition(ix, iy)
      .setRadius(knobR)
      .setRange(50, 2000)
      .setValue(220)
      .setCaptionLabel("M" + (i+1) + " Freq")
      .setNumberOfTickMarks(10)
      .snapToTickMarks(false);
    
    modIndexKnob[i] = cp5.addKnob("mod" + i + "_index")
      .setPosition(ix, iy += sdy + 60)
      .setRadius(knobR)
      .setRange(0, 1)
      .setValue(0.2)
      .setCaptionLabel("Index")
      .setNumberOfTickMarks(11)
      .snapToTickMarks(false);
    
    // Waveform dropdown centrato sotto il knob
    iy += dy;
    float waveX = ix + knobR - menuW/2.0;
    modWaveform[i] = cp5.addDropdownList("modWave" + i)
      .setPosition(waveX, iy)
      .setSize(menuW, waveH)
      .addItem("Sine", 0)
      .addItem("Pulse", 1)
      .addItem("Tri",   2)
      .addItem("Saw",   3)
      .setValue(0)
      .setCaptionLabel("Wave");
    
    modAttackKnob[i] = cp5.addKnob("mod" + i + "_attack")
      .setPosition(ix + 10, iy += sdy + 60)
      .setRadius(smallR)
      .setRange(0, 1)
      .setValue(0.01)
      .setCaptionLabel("Atk")
      .setNumberOfTickMarks(11)
      .snapToTickMarks(false);
    
    modSustainKnob[i] = cp5.addKnob("mod" + i + "_sustain")
      .setPosition(ix + 10, iy += sdy + 50)
      .setRadius(smallR)
      .setRange(0, 1)
      .setValue(0.8)
      .setCaptionLabel("Sus")
      .setNumberOfTickMarks(11)
      .snapToTickMarks(false);
    
    modReleaseKnob[i] = cp5.addKnob("mod" + i + "_release")
      .setPosition(ix + 10, iy += sdy + 50)
      .setRadius(smallR)
      .setRange(0, 2)
      .setValue(0.5)
      .setCaptionLabel("Rel")
      .setNumberOfTickMarks(11)
      .snapToTickMarks(false);
    
    // Target dropdown centrato
    iy += sdy + 50;
    float targetX = ix + knobR - menuW/2.0;
    modTarget[i] = cp5.addDropdownList("mod" + i + "_target")
      .setPosition(targetX, iy)
      .setSize(menuW, targetH)
      .addItem("None", -1)
      .addItem("Mod1", 0)
      .addItem("Mod2", 1)
      .addItem("Mod3", 2)
      .addItem("Mod4", 3)
      .addItem("Carrier", 4)
      .setValue(-1)
      .setCaptionLabel("In→");
    
    // Add / Remove buttons
    iy += sdy + 70;
    modAddBtn[i] = cp5.addButton("mod" + i + "_add")
      .setPosition(ix - 30, iy)
      .setSize(60, 20)
      .setCaptionLabel("Add Mod" + (i+1));
    modRemBtn[i] = cp5.addButton("mod" + i + "_rem")
      .setPosition(ix + 35, iy)
      .setSize(60, 20)
      .setCaptionLabel("Rem Mod" + (i+1));
  }
  
  logo = loadImage("logo.png");

}

void draw() {
  background(50, 40, 5); ;
  
  // linea di separazione verticale
  stroke(fgColor);
  strokeWeight(2);
  int sepX = (cx + mx0 + 20) / 2;
  line(sepX + 10, 0, sepX + 10, height);
  
  // titoli
  fill(200);
  textSize(16);
  text("Carrier", cx + 5, 25);
  text("Modulator Slots", mx0 + 200, 25);
  

  float marginy = 10;
  float logoSize = 80;     // larghezza/altezza desiderata del logo

  // in basso a destra:
  float x = width  - logoSize;
  float y = height - logoSize - marginy;
  blendMode(BLEND);
  image(logo, x, y, logoSize, logoSize);
  
  // Disegno in ADD per aumentare la luminosità
  blendMode(ADD);
  image(logo, x, y, logoSize, logoSize);
  
  // Torno al blending standard
  blendMode(BLEND);
}


//OSC

// Send one modulator parameter over OSC
/*void sendModParam(int modIndex, String paramName, float value) {
  OscMessage msg = new OscMessage("/mod");
  msg.add(modIndex);      
  msg.add(paramName);     
  msg.add(value);         
  oscP5.send(msg, scAddr);
  println("→ Sent OSC", msg.address(), msg.arguments());
}*/


void controlEvent(ControlEvent ev) {
  String name = ev.getName();
  float val = ev.getValue();
  
  //CARRIER
  if (name.equals("carrierVibRate")) {
    OscMessage msg = new OscMessage("/carrier");
    msg.add("vibRate");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("carrierVibDepth")) {
    OscMessage msg = new OscMessage("/carrier");
    msg.add("vibDepth");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("carrierAttack")) {
    OscMessage msg = new OscMessage("/carrier");
    msg.add("attack");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("carrierSustain")) {
    OscMessage msg = new OscMessage("/carrier");
    msg.add("sustain");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("carrierRelease")) {
    OscMessage msg = new OscMessage("/carrier");
    msg.add("release");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("carrierWaveform")) {
    OscMessage msg = new OscMessage("/carrier");
    msg.add("waveformType");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  //MODULATORS
  
  if (name.equals("mod0_freq")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("freq0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_index")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("index0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("modWave0")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("waveformType0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_attack")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("attack0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_sustain")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("sustain0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_release")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("release0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_target")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("target0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_add")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("add0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod0_rem")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("rem0");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  
  
  
  if (name.equals("mod1_freq")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("freq1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_index")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("index1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("modWave1")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("waveformType1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_attack")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("attack1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_sustain")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("sustain1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_release")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("release1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_target")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("target1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_add")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("add1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod1_rem")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("rem1");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  
  
  
  
  if (name.equals("mod2_freq")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("freq2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_index")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("index2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("modWave2")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("waveformType2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_attack")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("attack2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_sustain")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("sustain2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_release")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("release2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_target")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("target2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_add")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("add2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod2_rem")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("rem2");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  
  
  
  if (name.equals("mod3_freq")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("freq3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_index")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("index3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("modWave3")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("waveformType3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_attack")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("attack3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_sustain")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("sustain3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_release")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("release3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_target")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("target3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_add")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("add3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  if (name.equals("mod3_rem")) {
    OscMessage msg = new OscMessage("/mod");
    msg.add("rem3");
    msg.add(val);
    oscP5.send(msg, scAddr);
    println("→ Sent OSC", msg.address(), msg.arguments());
  }
  
  
  
  /*
  for (int i = 0; i < 4; i++) {
    if (name.equals("mod" + i + "_freq")) {
      sendModParam(i, "freq", val);
    }
    else if (name.equals("mod" + i + "_index")) {
      sendModParam(i, "index", val);
    }
    else if (name.equals("mod" + i + "_attack")) {
      sendModParam(i, "attack", val);
    }
    else if (name.equals("mod" + i + "_sustain")) {
      sendModParam(i, "sustain", val);
    }
    else if (name.equals("mod" + i + "_release")) {
      sendModParam(i, "release", val);
    }
    else if (name.equals("modWave" + i)) {
      sendModParam(i, "waveformType", val);
    }
    else if (name.equals("modTarget" + i)) {
      sendModParam(i, "inBus", val);
    }
    else if (name.equals("mod" + i + "_add")) {
      OscMessage msg = new OscMessage("/mod");
      msg.add(i);
      msg.add("add");
      oscP5.send(msg, scAddr);
      println("→ Sent OSC", msg.address(), msg.arguments());
    }
    else if (name.equals("mod" + i + "_rem")) {
      OscMessage msg = new OscMessage("/mod");
      msg.add(i);
      msg.add("remove");
      oscP5.send(msg, scAddr);
      println("→ Sent OSC", msg.address(), msg.arguments());
    }
  }*/
}
