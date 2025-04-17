/*  pic16f84.h    for pic16f84a micro  */

/*
    mcpic include file
    (c) 1/14/2002   Ron Carr

    set up proper global registers and definitions
*/
#asm

; definitions

F      equ  1           ; declare destination options
W      equ  0

;----- STATUS Bits --------------------------------------------------------

IRP                          EQU     H'0007'
RP1                          EQU     H'0006'
RP0                          EQU     H'0005'
NOT_TO                       EQU     H'0004'
NOT_PD                       EQU     H'0003'
Z                            EQU     H'0002'
DC                           EQU     H'0001'
C                            EQU     H'0000'

;----- INTCON Bits --------------------------------------------------------

GIE                          EQU     H'0007'
EEIE                         EQU     H'0006'
T0IE                         EQU     H'0005'
INTE                         EQU     H'0004'
RBIE                         EQU     H'0003'
T0IF                         EQU     H'0002'
INTF                         EQU     H'0001'
RBIF                         EQU     H'0000'

;----- OPTION_REG Bits ----------------------------------------------------

NOT_RBPU                     EQU     H'0007'
INTEDG                       EQU     H'0006'
T0CS                         EQU     H'0005'
T0SE                         EQU     H'0004'
PSA                          EQU     H'0003'
PS2                          EQU     H'0002'
PS1                          EQU     H'0001'
PS0                          EQU     H'0000'

;----- EECON1 Bits --------------------------------------------------------

EEIF                         EQU     H'0004'
WRERR                        EQU     H'0003'
WREN                         EQU     H'0002'
WR                           EQU     H'0001'
RD                           EQU     H'0000'

;==========================================================================
;
;       RAM Definition
;
;==========================================================================

        __MAXRAM H'CF'
        __BADRAM H'07', H'50'-H'7F', H'87'

;==========================================================================
;
;       Configuration Bits
;
;==========================================================================

_CP_ON                       EQU     H'000F'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FF7'
_PWRTE_OFF                   EQU     H'3FFF'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'


       ;declare constants used by the compiler
       list p = 16F84a
       radix  decimal

       ; change config if needed
       __config  _RC_OSC & _WDT_OFF & _PWRTE_ON


       ;set up vectors
       org   0          ; reset vector
       call  init
_ml    call  main       ; loop
       goto  _ml
       org   4
       goto  _interupt  ; comment this out if you don't want interupts
                        ; otherwise supply a _interupt() C function

 ; -------------------- run time library  -------------------- */

        ; shifting, shift _temp with count in W
_rshift
        btfsc   STATUS,Z    
        return             ; ret if shift amount is zero
        bcf     STATUS,C   ; unsigned shift, mask bits
        rrf     _temp,F
        addlw   255        ; sub one
        goto    _rshift

_lshift
        btfsc   STATUS,Z    
        return             ; ret if shift amount is zero
        bcf     STATUS,C   ; arithmetic shift
        rlf     _temp,F
        addlw   255        ; sub one
        goto    _lshift

_eeadr                     ; set up EEDATA to contain desired data
        bcf     STATUS,RP0
        movwf   EEADR      ; correct address in W
        bsf     STATUS,RP0
        bsf     EECON1,RD
        bcf     STATUS,RP0
        movf    EEDATA,W
        movwf   _eedata
        return

#endasm
                     /* set up page two registers */
#pragma pic 128   
char IND2;
char OPTION_REG;
char PCL2;
char STATUS2;
char FSR2;
char TRISA;
char TRISB;
char _unused2;
char EECON1;
char EECON2;
char PCLATH2;
char INTCON2;

                   /* declare page one registers */
#pragma pic 0

char INDF;
char TMR0;
char PCL;
char STATUS;
char FSR;
char PORTA;
char PORTB;
char _unused;
char EEDATA;
char EEADR;
char PCLATH;
char INTCON;
char _temp;     /* temp location for subtracts and shifts */
char _eedata;

/* ------------------- end of shell set up ------------------- */
