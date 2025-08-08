#include <Wire.h>
#include <MPU6050_6Axis_MotionApps20.h>

MPU6050 mpu;

Quaternion q;
VectorFloat gravity;
float ypr[3];
uint8_t fifoBuffer[64];

float pitchOffset = 0;
float rollOffset = 0;

void setup() {
  Serial.begin(9600);
  Wire.begin();

  mpu.initialize();

  if (mpu.dmpInitialize() == 0) {
    mpu.setDMPEnabled(true);
    Serial.println("✅ MPU6050 ready");
  } else {
    Serial.println("Error in DMP initialization");
  }

  delay(3000);

  if (mpu.dmpGetCurrentFIFOPacket(fifoBuffer)) {
    mpu.dmpGetQuaternion(&q, fifoBuffer);
    mpu.dmpGetGravity(&gravity, &q);
    mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);

    pitchOffset = ypr[1] * 180 / M_PI;
    rollOffset = ypr[2] * 180 / M_PI;

    Serial.println("✅ Initial offset recorded");
  }
}

void loop() {
  // 1) Check if there is a FIFO overflow and, if so, reset it
  int status = mpu.getIntStatus();
  if (status & 0x10) {
    mpu.resetFIFO();  // empty the internal buffer
    Serial.println(F("⚠️ FIFO overflow – buffer resettato"));
    delay(50);
    return;
  }

  while (mpu.dmpGetCurrentFIFOPacket(fifoBuffer)) {
    mpu.dmpGetQuaternion(&q, fifoBuffer);
    mpu.dmpGetGravity(&gravity, &q);
    mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);

    float pitch = (ypr[1] * 180 / M_PI) - pitchOffset;  // Tilt forward/backward
    float roll = (ypr[2] * 180 / M_PI) - rollOffset;    // Tilt left/right

    // Normalizes from [-90°, +90°] to [0, 1]
    float xNorm = constrain((roll + 90.0) / 180.0, 0, 1);
    float yNorm = constrain((pitch + 90.0) / 180.0, 0, 1);

    // Send on serial for Processing
    Serial.print(xNorm, 2);
    Serial.print(",");
    Serial.println(yNorm, 2);

    delay(50);  // Read every 50ms
  }
}
