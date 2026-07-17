int sensor = 0;
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(A0, INPUT);
  Serial.begin(9600);
}
void loop() {
  sensor = analogRead(A0);
  Serial.print("sensor="); Serial.println(sensor);
  if (sensor > 512) { digitalWrite(LED_BUILTIN, HIGH); }
  else { digitalWrite(LED_BUILTIN, LOW); }
  for (int i = 0; i < 3; i++) { digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN)); delay(150); }
  delay(500);
}
