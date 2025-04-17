
// Keyer2  Morse keyer using a FIFO for more than one dit/dah memory
// elements can be keyed to be sent without any make or release timing requirements other than be a little quicker than the
// set wpm.  Paddles can be held closed without a release requirement if the fifo has data pending.

// example:  You could key a B by closing the dah paddle and holding, tap in 3 dits, and release the dah.
//     That would require 4 keystrokes instead of the normal two keystrokes.  It would work best for slower code speeds.
//     Or you could key normally, close the dah, close the dit, release dah before the dit ends ( or before the dah ends if mode B ),
//     wait for 3 dits, release the dit paddle before you get 4 dits.  This way has timing requirements for paddle close and open.
//     This code will work either way.

#define DIT 1
#define DAH 2
#define ELEMENT_SPACE 4
#define FIFO_SIZE 16          // must be power of two size
#define MODE_A 1 
#define MODE_B 2
#define ULTIMATIC 4
#define ON 128
#define OFF 0

#define MODE_PIN 2
#define SIDE_TONE_PIN 3       // needs pwm pin
#define DIT_PIN 4
#define DAH_PIN 5
#define OUT_PIN 6

char cw_fifo[FIFO_SIZE];
char cw_in, cw_out;
int wpm = 14;
char last_sent = ELEMENT_SPACE;              // last iambic sent and sample 
char last_sample = DIT; 
char mode = MODE_A;

void setup() {

  pinMode( DIT_PIN, INPUT_PULLUP );
  pinMode( DAH_PIN, INPUT_PULLUP );
  pinMode( OUT_PIN, OUTPUT );
  pinMode( MODE_PIN, INPUT_PULLUP );
  delay(100);
  if( digitalRead( MODE_PIN ) == LOW ) mode = MODE_B;

}

void loop() {
static uint32_t ms;
uint32_t t;

   t = millis();
   if( t != ms ){     // functions are called once per ms
       ms = t;
       cw_keyer();
       cw_player();
   }
  

}

// return paddle state as positive logic
char read_paddle(){
char val;

   val = 0;
   if( digitalRead( DIT_PIN ) == LOW ) val = DIT;
   if( digitalRead( DAH_PIN ) == LOW ) val += DAH;

   return val;
}


// read key and put results in the fifo
void cw_keyer(){
static char dit_holdoff, dah_holdoff;     // debounce
static char old_pdl;
char pdl;
char diff;


   // detect paddle edges with some debounce
   pdl = read_paddle();
   diff = pdl ^ old_pdl;      // any changes?
   old_pdl = pdl;

   if( dit_holdoff ) --dit_holdoff;
   if( dah_holdoff ) --dah_holdoff;
   
   if( diff & DIT ){
      if( dit_holdoff == 0 ){
         if( pdl & DIT ) cw_fifo[cw_in++] = DIT;     // paddle contact make edge, else it is a break to ignore
         cw_in &= (FIFO_SIZE-1);                     // modulus power of 2 buffer size
      }    
      dit_holdoff = 5;                               // 5 ms to long or short for debounce?
   }

   if( diff & DAH ){
      if( dah_holdoff == 0 ){
         if( pdl & DAH ) cw_fifo[cw_in++] = DAH;     // paddle contact make edge, else it is a break to ignore
         cw_in &= (FIFO_SIZE-1);
      }        
      dah_holdoff = 5;                               // keep holding off if still bouncing
   }
   
   if( cw_in != cw_out ) return;                     // only looking at held paddles when nothing in the fifo

   // iambic, sample alternately
   // last sample = last sent, sample alternate paddle first when previous code element completes.
   if( last_sent != ELEMENT_SPACE ){
      last_sample = last_sent;
      if( mode == ULTIMATIC ) last_sample ^= ( DIT + DAH );   // sample same
   }
   
   if( last_sample == DAH ){
      if( pdl & DIT ) cw_fifo[cw_in++] = DIT;
   }
   else{
      if( pdl & DAH ) cw_fifo[cw_in++] = DAH;
   }
   last_sample = ( last_sample == DIT ) ? DAH : DIT;     // alternate, may be overridden by above code next loop

   cw_in &= (FIFO_SIZE-1);
  
}


#define WEIGHT 200

// play any items in the fifo. This function also would be useful for playing stored messages.
void cw_player(){
static int count;
static char eL;

   if( count ){
       --count;
       if( count == 0 ){
           if( eL != ELEMENT_SPACE ){
               eL = ELEMENT_SPACE;
               side_tone( OFF );
               count = 1200/wpm;
           }
           else{
               if( mode == MODE_A || mode == ULTIMATIC ) ++cw_out;     // done element and following space, mode A
               cw_out &= ( FIFO_SIZE-1 );
           }
       }
       return;
   }


   // late setting of last_sent as ELEMENT_SPACE allows 1st iambic sample to be of the alternate paddle. 
   if( cw_in == cw_out ){
       last_sent = ELEMENT_SPACE;
       return;
   }
   
  // begin sending next item in the fifo 
   eL = cw_fifo[cw_out];
   count = (1200 + WEIGHT) / wpm;
   if( eL == DAH ) count *= 3;
   side_tone( ON );
   last_sent = eL;

   if( mode == MODE_B ){    // allow early iambic sampling of paddle levels, at beginning of element
      ++cw_out;
      cw_out &= ( FIFO_SIZE-1 );      
   }
  
}

void side_tone( char val ){

   analogWrite( SIDE_TONE_PIN, val );
   digitalWrite( OUT_PIN, (val)? HIGH : LOW );
  
}
