int level = 0;
void setup() {
  Serial.begin(115200);
  pinMode(2, OUTPUT);
  ledcSetup(0, 5000, 8);
  ledcAttachPin(4, 0);
}
void loop() {
  for (level = 0; level <= 255; level += 5) {
    ledcWrite(0, level);
    digitalWrite(2, level > 128 ? HIGH : LOW);
    Serial.printf("pwm=%d\n", level);
    delay(20);
  }
}
