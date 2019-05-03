#include <stdint.h>
extern int lab7(void);
extern int Timer0Handler(void);
extern int Timer1Handler(void);
extern int Uart0Handler(void);
extern int PortAHandler(void);

unsigned short lfsr = 0xAFAD; //91A1 and AFAF are nice
  unsigned bit;

 unsigned rand(){
    bit  = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
    lfsr =  (lfsr >> 1) | (bit << 15);
    return lfsr >> 8;
 }

 unsigned short lfsr2 = 0xDEAD; //91A1 and AFAF are nice
   unsigned bit2;

  unsigned randspawn(){
     bit2  = ((lfsr2 >> 0) ^ (lfsr2 >> 2) ^ (lfsr2 >> 3) ^ (lfsr2 >> 5) ) & 1;
     lfsr2 =  (lfsr2 >> 1) | (bit2 << 15);
     return lfsr2 >> 11;
  }

int main(void){
    lab7();
}
