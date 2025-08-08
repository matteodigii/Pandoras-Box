// ----- For a cool graphical effect ----- 

class Particle {
  float angle, radius, speed, size;
  color col;

  Particle() {
    angle = random(TWO_PI);
    radius = random(150, squareSize * 0.4);
    speed = random(0.005, 0.02);
    size = random(5, 12);
    float brightness = random(60, 160);
    col = color(brightness + 50, brightness, brightness - 40, 150);
  }

  void update() {
    angle += speed;
  }

  void render() {
    float px = centerX + cos(angle) * radius;
    float py = centerY + sin(angle) * radius;
    noStroke();
    fill(col);
    ellipse(px, py, size, size);
  }
}
