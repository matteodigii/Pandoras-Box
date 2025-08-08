// --------- AUXILIARY FUNCTIONS (Listed in order of encounter and grouped for functionality) ---------

// Drawing of the Background and Coperchio
void drawBackground() {
  image(bordoImage, centerX, centerY, 350, 350);
}

void drawCoperchio(float dx, float dy) {
  float offsetX = -dx * 50;
  float offsetY = dy * 50;
  image(coperchioImage, centerX + offsetX, centerY + offsetY, 350, 350);
}

// Just to add a simple glowing effect to the images
void drawEffectImages(float dx, float dy, float tl, float tr, float br, float bl) {
  float r = 350 / 8;

  drawEffect(distortionImg, centerX - r, centerY - r, dx, dy, tl);
  drawEffect(chorusImg, centerX + r, centerY - r, dx, dy, tr);
  drawEffect(delayImg, centerX - r, centerY + r, dx, dy, bl);
  drawEffect(reverbImg, centerX + r, centerY + r, dx, dy, br);
}

void drawEffect(PImage img, float cx, float cy, float dx, float dy, float value) {
  float x = cx + dx * 80;
  float y = cy - dy * 80;
  float s = 90 * (1 + 0.5 * value);
  drawGlowBehindImage(x, y, value, 1 + 0.5 * value);
  tint(255, map(value, 0, 1, 80, 255));
  image(img, x, y, s, s);
  noTint();
}

void drawGlowBehindImage(float x, float y, float value, float scaleFactor) {
  int layers = 4;
  float maxSize = 100 * scaleFactor;
  for (int i = layers; i > 0; i--) {
    float alpha = map(value, 0, 1, 0, 80) / i;
    float size = map(value, 0, 1, 30, maxSize) * (float)i / layers;
    noStroke();
    fill(255, 200, 100, alpha);  
    ellipse(x, y, size, size);
  }
}

// Drawing the Particles Effect
void drawParticles() {
  for (Particle p : particles) {
    p.update();
    p.render();
  }
}

// To have the red cursor 
void drawPointer() {
  float px = centerX + (x - 0.5) * squareSize;
  float py = centerY - (y - 0.5) * squareSize;
  noStroke();
  fill(255, 50, 50);
  ellipse(px, py, 12, 12);
}

// Knobs/Buttons/Menu drawing functions

void drawMainKnobs(float tl, float tr, float br, float bl) {
  float r = 40;
  drawArcKnob(squareX + margin, squareY + margin, r, tl); // top-left
  drawArcKnob(squareX + squareSize - margin, squareY + margin, r, tr); // top-right
  drawArcKnob(squareX + squareSize - margin, squareY + squareSize - margin, r, br); // bottom-right
  drawArcKnob(squareX + margin, squareY + squareSize - margin, r, bl); // bottom-left
}

void drawKnobLabels() {
  fill(60, 40, 20);
  textAlign(CENTER, CENTER);
  textSize(14);

  text("Distortion", squareX + margin, squareY + margin - 45);
  text("Chorus", squareX + squareSize - margin, squareY + margin - 45);
  text("Delay", squareX + margin, squareY + squareSize - margin + 45);
  text("Reverb", squareX + squareSize - margin, squareY + squareSize - margin + 45);
}

void drawAdditionalKnobs() {
  float r = 40;
  float topLeftX = squareX + margin;
  float topLeftY = squareY + margin;
  float topRightX = squareX + squareSize - margin;
  float topRightY = squareY + margin;
  float bottomRightX = squareX + squareSize - margin;
  float bottomRightY = squareY + squareSize - margin;
  float bottomLeftX = squareX + margin;
  float bottomLeftY = squareY + squareSize - margin;

  drawArcKnob(topLeftX, topLeftY, r, distDrive);
  drawArcKnob(topRightX, topRightY, r, chorusRate);
  drawArcKnob(bottomRightX, bottomRightY, r, reverbRoom);
  drawArcKnob(bottomLeftX, bottomLeftY, r, delayFeedback);
}

void drawMoreButtons() {
  float topLeftX = squareX + margin;
  float topLeftY = squareY + margin;
  float topRightX = squareX + squareSize - margin;
  float topRightY = squareY + margin;
  float bottomRightX = squareX + squareSize - margin;
  float bottomRightY = squareY + squareSize - margin;
  float bottomLeftX = squareX + margin;
  float bottomLeftY = squareY + squareSize - margin;

  drawMoreButton(topLeftX - xOffset - 20, topLeftY + yOffset);
  drawMoreButton(topRightX + xOffset, topRightY + yOffset);
  drawMoreButton(bottomLeftX - xOffset - 20, bottomLeftY - yOffset - 20);
  drawMoreButton(bottomRightX + xOffset, bottomRightY - yOffset - 20);
}

void drawMoreButton(float x, float y) {
  fill(200, 180, 160);
  stroke(100, 60, 40);
  strokeWeight(2);
  rect(x, y, moreBtnSize, moreBtnSize, 6);
  fill(50);
  float iconSize = 16; 
  float centerX = x + moreBtnSize / 2;
  float centerY = y + moreBtnSize / 2;

  imageMode(CENTER);
  image(optionsImg, centerX, centerY, iconSize, iconSize);
  //textAlign(CENTER, CENTER);
  //textSize(14);
  //text("+", x + moreBtnSize / 2, y + moreBtnSize / 2);
}

void drawToggleButton(float x, float y, float w, float h, String label, boolean active) {
  stroke(120, 80, 40);
  strokeWeight(2);
  fill(active ? color(200, 160, 120) : color(230, 200, 160));
  rect(x, y, w, h, 12);
  fill(80, 50, 30);
  textAlign(CENTER, CENTER);
  textSize(16);
  text(label, x + w / 2, y + h / 2);
}

void drawConditionalKnobPanels() {
  textAlign(CENTER, CENTER);
  textSize(12);

  if (showMoreTopLeft) {
    drawArcKnob(squareX + margin - 115, squareY + margin + 5, 25, distDrive);
    fill(0);
    text("Drive", squareX + margin - 115, squareY + margin + 40);
  }

  if (showMoreTopRight) {
    drawArcKnob(squareX + squareSize - margin + 115, squareY + margin + 5, 25, chorusRate);
    drawArcKnob(squareX + squareSize - margin + 115, squareY + margin + 80, 25, chorusDepth);
    fill(0);
    text("Rate", squareX + squareSize - margin + 115, squareY + margin + 40);
    text("Depth", squareX + squareSize - margin + 115, squareY + margin + 115);
  }

  if (showMoreBottomLeft) {
    drawArcKnob(squareX + margin - 115, squareY + squareSize - margin - 20, 25, delayFeedback);
    drawArcKnob(squareX + margin - 115, squareY + squareSize - margin - 95, 25, delayTime);
    fill(0);
    text("Feedback", squareX + margin - 115, squareY + squareSize - margin + 15);
    text("Time", squareX + margin - 115, squareY + squareSize - margin - 60);
  }

  if (showMoreBottomRight) {
    drawArcKnob(squareX + squareSize - margin + 115, squareY + squareSize - margin - 20, 25, reverbRoom);
    drawArcKnob(squareX + squareSize - margin + 115, squareY + squareSize - margin - 95, 25, reverbWidth);
    fill(0);
    text("Room", squareX + squareSize - margin + 115, squareY + squareSize - margin + 15);
    text("Width", squareX + squareSize - margin + 115, squareY + squareSize - margin - 60);
  }
}

void drawDropdown() {
  // Label
  fill(0);
  textAlign(RIGHT, CENTER);
  textSize(12);
  text("Zoom", dropdownX - 10, dropdownY + dropdownHeight / 2); // Draw label to the left

  // Dropdown box
  fill(220, 200, 180);
  stroke(0);
  rect(dropdownX, dropdownY, dropdownWidth, dropdownHeight);
  
  fill(0);
  textAlign(LEFT, CENTER);
  text(zoomLevels[selectedIndex], dropdownX + 10, dropdownY + dropdownHeight / 2);
  
  // Dropdown options
  if (dropdownOpen) {
    for (int i = 0; i < zoomLevels.length; i++) {
      fill(240, 230, 220);
      stroke(0);
      rect(dropdownX, dropdownY + (i+1)*dropdownHeight, dropdownWidth, dropdownHeight);
      
      fill(0);
      text(zoomLevels[i], dropdownX + 10, dropdownY + (i+1)*dropdownHeight + dropdownHeight / 2);
    }
  }
}

void drawCenterSquare() {
  noFill();
  stroke(120, 80, 40);
  strokeWeight(1.8);
  rectMode(CENTER);
  rect(centerX, centerY, squareSize, squareSize);
  rectMode(CORNER); 
}


void drawModeButtons() {
  float totalBtnWidth = btnW + resetBtnW + 20;
  btnX = centerX - totalBtnWidth / 2;
  btnY = squareY + squareSize + 20;

  drawToggleButton(btnX, btnY, btnW, btnH, useArduino ? "Arduino" : "Mouse", useArduino);
}

void drawResetButton() {
  float mx = mouseX / currentZoom;
  float my = mouseY / currentZoom;

  resetBtnX = btnX + btnW + 20;
  resetBtnY = btnY;

  boolean overReset = mx >= resetBtnX && mx <= resetBtnX + resetBtnW &&
                      my >= resetBtnY && my <= resetBtnY + resetBtnH;

  drawToggleButton(resetBtnX, resetBtnY, resetBtnW, resetBtnH, "Reset", overReset);
}

void drawLogo() {
  imageMode(CORNER);
  int logoSize = 80;
  image(logoImage, width / currentZoom - logoSize + 20, height / currentZoom - logoSize, logoSize, logoSize);
}

void drawGlowRing(float cx, float cy, float dia) {
  for (int i = 2; i > 0; i--) {
    stroke(150, 100, 60, map(i, 0, 8, 0, 100));
    strokeWeight(i * 2);
    noFill();
    ellipse(cx, cy, dia + i * 2, dia + i * 2);
  }
}

void drawArcKnob(float cx, float cy, float r, float value) {
  drawGlowRing(cx, cy, r * 1.5);
  noStroke();
  fill(230, 200, 160);
  ellipse(cx, cy, r * 1.2, r * 1.2);
  stroke(120, 80, 40);
  strokeWeight(6);
  noFill();
  arc(cx, cy, r * 1.4, r * 1.4, PI / 2, PI / 2 + TWO_PI * value);
}
