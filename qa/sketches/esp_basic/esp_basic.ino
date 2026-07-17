int v = 0;
void setup(){ Serial.begin(115200); pinMode(2, OUTPUT); pinMode(34, INPUT); }
void loop(){
  v = analogRead(34);
  Serial.print("adc="); Serial.println(v);
  if (v > 2000) digitalWrite(2, HIGH); else digitalWrite(2, LOW);
  for (int i=0;i<3;i++){ digitalWrite(2, !digitalRead(2)); delay(120); }
  delay(400);
}
