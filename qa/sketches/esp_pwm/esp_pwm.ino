void setup(){ Serial.begin(115200); ledcAttach(4, 5000, 8); }
void loop(){ for(int d=0; d<=255; d+=5){ ledcWrite(4, d); Serial.println(d); delay(20);} }
