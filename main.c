#include <stdint.h>
extern int lab7(void);
extern int Timer0Handler(void);
extern int Timer1Handler(void);
extern int Uart0Handler(void);
extern int PortAHandler(void);

unsigned short lfsr = 0xACE1u;
  unsigned bit;

 unsigned rand()
 {
    bit  = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
    lfsr =  (lfsr >> 1) | (bit << 15);
    return lfsr >> 8;
 }

int main(void)
{
    lab7();
}
