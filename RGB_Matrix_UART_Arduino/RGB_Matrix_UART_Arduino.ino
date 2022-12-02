#include "Panel.h"

//create an instance of the panel
#define GAMES 4
Panel panel(32, 64);
//uint16_t G[GAMES][10][20];

void setup() {
  panel.fillScreenColor(panel.BLACK);
  panel.drawRect(0,0,63,31,panel.BLACK,true);
  for(int i = 0;i<GAMES;i++)
    panel.drawRect(2+i*16, 5, 13+i*16, 26, panel.WHITE, false); //4 white squares for the play area

  Serial.begin(115200);

}
  

void loop() {
  int game,j,k,color;
  //input format = 4 bytes followed by newline. each byte is treated as an integer
  //input 0 == game (0-3)
  //input 1 == j, or X value
  //input 2 == k, or Y value
  if (Serial.available() > 4) {
    game = ((int)Serial.read()-48)%4;
    j = ((int)Serial.read()-48)%10;
    k = ((int)Serial.read()-48)%20;
    color=((int)Serial.read()-48)%26;
    Serial.read();
    Serial.write('0'+game);
    Serial.write('0'+j);
    Serial.write('0'+k);
    Serial.write('0'+color);
    Serial.write("\n");
    panel.drawRect(3+game*16+j,5+(20-k),3+game*16+j,5+(20-k),color,false);
  }
  
  panel.displayBuffer(); //makes the buffer visible and the leds all blinky blinky
  
}
