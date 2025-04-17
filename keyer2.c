/*

   pic keyer
   (C) 2003 Ron Carr

   B port all inputs with pullups enabled
      dah    bit 7
      dit    bit 6

      swap   bit 4
      mode   bit 5

   A port all outputs
      tx enable bit 1
      sidetone  bit 0

   2025 changes - fifo keyer, mode A only
     Any key closures are put in a fifo, held key levels are only read if fifo is empty. 
     8 element memory with correct sequencing of paddle closures.

*/
  /*
     clock speed and timer count determin sidetone freq and
     keying speed.  Aiming for 800 hz sidetone.
     Think want 400 khz clock and timer value of 64.
     may need to reduce timer value by amount of instructions in interupt
     routine.

     R/C values  R= 29k   C=  47p    or 28k looks like these are the values that were used
  */

/*
simple commands 
  speed change -
    10  or more dits in a row - increase speed
    10  or more dahs in a row - decrease speed

*/


#include "keyer.h"

#define DAH 128    /* bit 7 on B port */
#define DIT  64    /* bit 6 on B port */
#define MODEA 32   /* bit RB5, default mode A, wire pin to ground for mode B */
#define MODEB 0    /* mode A only this version */
#define SWAP  16   /* bit RB4, wire pin to ground to swap, default is high == normal */

/* intcon values */
#define CHANGE_EN 0x08
#define TIMER_EN  0xa0

/* timer value to load 256 - 64 */
#define TIMEVAL 160

/* eeprom values */
extern char EEDITCOUNT = 72;     /* about 13 wpm */
extern char EEDAHCOUNT = 216;

/* globals */
char cel;    /* current element */
char nel;    /* next element */
char mask;   /* mask for A port, enables tx and sidetone */
char toggle; /* interupt half count, for generating a tone */
char counter; 
/* char mode; */
char swap;      /* swap DIT and DAH port definitions */
/* char fmask; */    /* 1st half el time mask */
/* char lmask; */    /* 2nd half el time mask */

char ditcount;   /* terminal values for counter */
char dahcount;
/* char halfcount; */ /* sample time */
char elcount;

char ttlel;  /* for speed change routine */

/* for interupt temp storage */
char wtemp;
char stemp;

#define FIFO_SIZE 8
char fifo[FIFO_SIZE];
char f_in, f_out;
char dv;
char last_pdl;
char diff;
char pdl;


/* set up ports, init key variables */
init(){

   cel= nel= mask= toggle= f_in= f_out= last_pdl= 0;
   ditcount= EEDITCOUNT;
   dahcount= EEDAHCOUNT;
   PORTA= 0;
   PORTB= 0;
   TRISA= 0;
   TRISB= 0xff;
   OPTION_REG= 0x08;   /* ?may need prescaler 0, maybe not 8 ? */
                       /* pullups are enabled */

}

/* gen side tone and increment a counter */
_interupt(){

/* check generated code does not use _temp, indirect register,
   shift, or EEPROM reads.  If so then will need to save other data */

   /* save W register, clear interupt status */
#asm
   movwf   wtemp
   swapf   STATUS,W
   movwf   stemp;
#endasm

   INTCON= 0x20;  /* timer enable only, clear int status */

   /* generate the side tone, A port bit 0, key the radio */
   toggle ^= 1;
   PORTA= ( toggle + 2 ) & mask;

   /* count at half interupt rate, avoid overflow */
   counter= ( counter == 254 ) ? 254 : counter + toggle;

   TMR0= TIMEVAL;   /* value to count from */

   /* restore W register */
#asm
   swapf  stemp,W
   movwf  STATUS
   swapf  wtemp,F
   swapf  wtemp,W
#endasm


}    /* return enables interupts */



/* loops via the .h code */
main(){

/*
 code needs to handle
    bounces on the contacts
    nothing to do ( on powerup probably no paddle is closed )
*/
   /* start up counter interupts */
   INTCON= TIMER_EN;

   diff = last_pdl = cel= readpdl();               /* we wokeup, get which paddle, diff for debounce */

   /* swap- xor of zero gives normal operation, xor 192 swaps.
      ie   128 ^ 192 == 64.   64 ^ 192 == 128  ( dit+dah = 192 ) */
   swap= ( PORTB & SWAP ) ? 0 : DIT + DAH;  /* swap dit and dah, hi port bit SWAP normal */
                                            /* speed change reversed if swap is used */
   while( cel ){

      if( cel == (DIT + DAH) ) cel= DIT;  /* dit wins if ever a tie */

      elcount = ((cel ^ swap) == DAH) ? dahcount: ditcount;
      mask= 3;            /* enable tx and sidetone */
      counter= 0;
      wait4it();   

      counter= mask= 0;                     /* send space */
      elcount= ditcount;
    /*  elcount -= ( ditcount >> 3 );    */     /* weight, space slightly shorter */
      wait4it();                            /* element space time */

      /* last sample , read any held paddles */
      if( nel == 0 ) diff = last_pdl = nel= readpdl();
      /* toggle may be needed for mode A iambic */
      if( nel == ( DIT + DAH ) ) nel-= cel;

      /* speed change routine */
      if( cel == nel ) ++ttlel;
      else ttlel= 0;
      if( ttlel >= 10 ) speedchange(cel);

      cel= nel;  nel= 0;   /* send whatever in queue */

      }   /* end something to send */

   /* wait short time for more contacts on paddles */

   counter= 0;
   while( counter < EEDAHCOUNT ){
      if( readpdl() ) return;           /* re-enters main(), skips sleep */
      }

   /*
   nothing happening so power down
   sleep with just port b change enabled, global interupt disabled
   just wakes up, no branch to interupt code
   */
   INTCON= CHANGE_EN;
#asm
   sleep
   nop
   nop
#endasm

/*   INTCON= 0; */    /*(redundant) disable ints,clear change bit */

}  /* loops via .h code back to main() */


char next_element(){

   if( f_in != f_out ){
      dv = fifo[f_out++];
      f_out &= ( FIFO_SIZE - 1 );
      return dv;
   }
   return readpdl();

}

char readpdl(){

   return ( PORTB ^ 0xff ) & ( DIT + DAH );
}

/*
 wait for element to be sent

*/

wait4it(){

   while( counter < elcount ){      /* put any key closures into the fifo */
      
      if( diff ){                   /* delay sampling for any key bounce */
                                    /* this is at the beginning of the function to debounce the first paddle read out of sleep state */
         debounce();
         if( counter >= elcount ) break;   /* debounce maybe not finished, will debounce next call as diff still not zero */
      }

      pdl = readpdl();
      diff = pdl ^ last_pdl;
      last_pdl = pdl;

      dv = diff & pdl;
      if( dv ){
         fifo[f_in++] = dv;
         f_in &= (FIFO_SIZE-1);
      }
      
   }   /* end while */

   if( nel == 0 && f_in != f_out ) nel = next_element();      /* read fifo */

}


void debounce(){ 
      
  /* had some dah paddle bounce with a count of 4 delay */

  dv = counter + 9;         /* 10 is a complete element time for the fastest this will key, too long debounce? */
  if( dv < 9 ) dv = 250;    /* overflow, must be set to a very slow keying speed */
  while( counter < dv ){
    if( counter >= elcount ) break;      /* time to return */
  }

}


speedchange( char updown ){

   if( updown == DIT ){
      --ditcount;
      dahcount-= 3;
      }
   else{
      ++ditcount;
      dahcount+= 3;
      }
   /* overflow ? */
   if( dahcount < 30 || dahcount >= 254 ){
       ditcount= EEDITCOUNT;
       dahcount= EEDAHCOUNT;
       }

}

