// MOUSE and COORDINATES Handling 

void updateDirectionVector() {
  dx = x - 0.5;
  dy = y - 0.5;
}

// We followed a radial subdivision to ensure a better and smoother representation
float[] computeEffectValues(float dx, float dy) {
  float[] vals = new float[4];  // topLeft, topRight, bottomRight, bottomLeft
  float dist = sqrt(dx * dx + dy * dy);
  float strength = constrain(dist * 2, 0, 1);
  
  if (strength == 0) return vals;  
  
  float angle = atan2(dy, dx);
  if (angle < 0) angle += TWO_PI;
  
  // Angular sectors of pi/8 to ensure the smoothest behaviour
  float sector = PI / 8;
  
  if (abs(angle - PI/4) < sector) vals[1] = strength;
  else if (abs(angle - 3*PI/4) < sector) vals[0] = strength;
  else if (abs(angle - 5*PI/4) < sector) vals[3] = strength;
  else if (abs(angle - 7*PI/4) < sector) vals[2] = strength;
  else if (angle >= PI/4 && angle <= 3*PI/4) vals[0] = vals[1] = strength;
  else if (angle > 3*PI/4 && angle < 5*PI/4) vals[0] = vals[3] = strength;
  else if (angle >= 5*PI/4 && angle <= 7*PI/4) vals[3] = vals[2] = strength;
  else vals[2] = vals[1] = strength;
  
  return vals;
}

void checkKnobClick(float mx, float my) {
  activeKnob = "";

  checkKnob(mx, my, showMoreTopLeft, squareX + margin - 115, squareY + margin + 5, "distDrive");

  checkKnob(mx, my, showMoreTopRight, squareX + squareSize - margin + 115, squareY + margin + 5, "chorusRate");
  checkKnob(mx, my, showMoreTopRight, squareX + squareSize - margin + 115, squareY + margin + 80, "chorusDepth");

  checkKnob(mx, my, showMoreBottomLeft, squareX + margin - 115, squareY + squareSize - margin - 20, "delayFeedback");
  checkKnob(mx, my, showMoreBottomLeft, squareX + margin - 115, squareY + squareSize - margin - 95, "delayTime");

  checkKnob(mx, my, showMoreBottomRight, squareX + squareSize - margin + 115, squareY + squareSize - margin - 20, "reverbRoom");
  checkKnob(mx, my, showMoreBottomRight, squareX + squareSize - margin + 115, squareY + squareSize - margin - 95, "reverbWidth");
}

void checkKnob(float mx, float my, boolean condition, float cx, float cy, String knobName) {
  if (condition && dist(mx, my, cx, cy) < knobSensitivity) {
    setKnobValue(knobName, angleToValue(mx, my, cx, cy));
    activeKnob = knobName;
  }
}

void setKnobValue(String name, float value) {
  if (name.equals("distDrive")) distDrive = value;
  else if (name.equals("chorusRate")) chorusRate = value;
  else if (name.equals("chorusDepth")) chorusDepth = value;
  else if (name.equals("delayFeedback")) delayFeedback = value;
  else if (name.equals("delayTime")) delayTime = value;
  else if (name.equals("reverbRoom")) reverbRoom = value;
  else if (name.equals("reverbWidth")) reverbWidth = value;
}

boolean checkMoreButtonClick(float mx, float my) {
  float moreRadius = moreBtnSize / 2;

  float[][] positions = {
    {squareX + margin - xOffset - 20 + moreRadius, squareY + margin + yOffset + moreRadius},
    {squareX + squareSize - margin + xOffset + moreRadius, squareY + margin + yOffset + moreRadius},
    {squareX + margin - xOffset - 20 + moreRadius, squareY + squareSize - margin - yOffset - 20 + moreRadius},
    {squareX + squareSize - margin + xOffset + moreRadius, squareY + squareSize - margin - yOffset - 20 + moreRadius}
  };

  if (dist(mx, my, positions[0][0], positions[0][1]) < moreRadius) { showMoreTopLeft = !showMoreTopLeft; return true; }
  if (dist(mx, my, positions[1][0], positions[1][1]) < moreRadius) { showMoreTopRight = !showMoreTopRight; return true; }
  if (dist(mx, my, positions[2][0], positions[2][1]) < moreRadius) { showMoreBottomLeft = !showMoreBottomLeft; return true; }
  if (dist(mx, my, positions[3][0], positions[3][1]) < moreRadius) { showMoreBottomRight = !showMoreBottomRight; return true; }

  return false;
}

boolean checkModeToggleClick(float mx, float my) {
  if (mx >= btnX && mx <= btnX + btnW &&
      my >= btnY && my <= btnY + btnH) {

    useArduino = !useArduino;

    if (useArduino && myPort != null) myPort.clear();

    if (useArduino) {
      x_mouse = x_arduino;
      y_mouse = y_arduino;
      x = x_mouse;
      y = y_mouse;
      blockMouseUpdate = true;
    } else {
      x_arduino = x;
      y_arduino = y;
      x = x_arduino;
      y = y_arduino;
    }

    return true;
  }
  return false;
}

boolean checkResetClick(float mx, float my) {
  if (mx >= resetBtnX && mx <= resetBtnX + resetBtnW &&
      my >= resetBtnY && my <= resetBtnY + resetBtnH) {

    x = y = x_mouse = y_mouse = x_arduino = y_arduino = 0.5;

    distDrive = 1;
    chorusDepth = 0.4;
    chorusRate = 0.02;
    reverbRoom = 0.5;
    reverbWidth = 0.5;
    delayFeedback = 0.2;
    delayTime = 0.24;

    return true;
  }
  return false;
}

boolean checkDropdownClick(float mx, float my) {
  if (mx > dropdownX && mx < dropdownX + dropdownWidth &&
      my > dropdownY && my < dropdownY + dropdownHeight) {
    dropdownOpen = !dropdownOpen;
    return true;
  }

  if (dropdownOpen) {
    for (int i = 0; i < zoomLevels.length; i++) {
      int yStart = dropdownY + (i + 1) * dropdownHeight;
      if (mx > dropdownX && mx < dropdownX + dropdownWidth &&
          my > yStart && my < yStart + dropdownHeight) {
        selectedIndex = i;
        currentZoom = zoomFactors[i];
        int newSize = int(baseSize * currentZoom);
        surface.setSize(newSize, newSize);
        delay(100);
        dropdownOpen = false;
        return true;
      }
    }
    dropdownOpen = false;
  }

  return false;
}

float angleToValue(float mx, float my, float cx, float cy) {
  float angle = atan2(my - cy, mx - cx);
  angle -= PI / 2;
  if (angle < 0) angle += TWO_PI;
  return constrain(angle / TWO_PI, 0, 1);
}

float getKnobCenterX(String knob) {
  if (knob.equals("distDrive")) return squareX + margin - 115;
  else if (knob.equals("chorusRate") || knob.equals("chorusDepth")) return squareX + squareSize - margin + 115;
  else if (knob.equals("delayFeedback") || knob.equals("delayTime")) return squareX + margin - 115;
  else if (knob.equals("reverbRoom") || knob.equals("reverbWidth")) return squareX + squareSize - margin + 115;
  return 0;
}

float getKnobCenterY(String knob) {
  if (knob.equals("distDrive")) return squareY + margin + 5;
  else if (knob.equals("chorusRate")) return squareY + margin + 5;
  else if (knob.equals("chorusDepth")) return squareY + margin + 80;
  else if (knob.equals("delayFeedback")) return squareY + squareSize - margin - 20;
  else if (knob.equals("delayTime")) return squareY + squareSize - margin - 95;
  else if (knob.equals("reverbRoom")) return squareY + squareSize - margin - 20;
  else if (knob.equals("reverbWidth")) return squareY + squareSize - margin - 95;
  return 0;
}

void updateMouseCoordsOnInteraction() {
  float mx = mouseX / currentZoom;
  float my = mouseY / currentZoom;

  if (mousePressed && !useArduino && !blockMouseUpdate) {
    float halfSize = squareSize / 2;
    boolean insideSquare =
      mx >= centerX - halfSize && mx <= centerX + halfSize &&
      my >= centerY - halfSize && my <= centerY + halfSize;

    if (insideSquare) {
      updateMouseCoords();
    }
  }

  blockMouseUpdate = false;
}

void updateMouseCoords() {
  float halfSize = squareSize / 2;
  float mx = mouseX / currentZoom - centerX;
  float my = mouseY / currentZoom - centerY;

  mx = constrain(mx, -halfSize, halfSize);
  my = constrain(my, -halfSize, halfSize);

  x = constrain(0.5 + mx / squareSize, 0, 1);
  y = constrain(0.5 - my / squareSize, 0, 1);

  x_mouse = x;
  y_mouse = y;
}

float getDirectionAngle(float dx, float dy) {
  float angle = atan2(dy, dx);
  if (angle < 0) angle += TWO_PI;
  return angle;
}

void mousePressed() {
  float mx = mouseX / currentZoom;
  float my = mouseY / currentZoom;

  checkKnobClick(mx, my);
  if (!activeKnob.equals("")) return;

  if (checkMoreButtonClick(mx, my)) return;

  if (checkModeToggleClick(mx, my)) return;

  if (checkResetClick(mx, my)) return;

  if (checkDropdownClick(mx, my)) return;

  if (!useArduino) {
    float distFromCenter = dist(mx, my, centerX, centerY);
    if (distFromCenter <= maxRadius) {
      updateMouseCoords();
    }
  }
}

void mouseDragged() {
  float mx = mouseX / currentZoom;
  float my = mouseY / currentZoom;
  if (!activeKnob.equals("")) {
    setKnobValue(activeKnob, angleToValue(mx, my, getKnobCenterX(activeKnob), getKnobCenterY(activeKnob)));
  }
}

void mouseReleased() {
  activeKnob = "";
}
