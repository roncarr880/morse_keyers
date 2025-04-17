; # include "keyer.h" 
; # asm 

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

YXY1
; # pragma pic 128 
; char IND2 ; 
	;data
IND2	equ 128
; char OPTION_REG ; 
OPTION_REG	equ 129
; char PCL2 ; 
PCL2	equ 130
; char STATUS2 ; 
STATUS2	equ 131
; char FSR2 ; 
FSR2	equ 132
; char TRISA ; 
TRISA	equ 133
; char TRISB ; 
TRISB	equ 134
; char _unused2 ; 
_unused2	equ 135
; char EECON1 ; 
EECON1	equ 136
; char EECON2 ; 
EECON2	equ 137
; char PCLATH2 ; 
PCLATH2	equ 138
; char INTCON2 ; 
INTCON2	equ 139
; # pragma pic 0 
; char INDF ; 
INDF	equ 0
; char TMR0 ; 
TMR0	equ 1
; char PCL ; 
PCL	equ 2
; char STATUS ; 
STATUS	equ 3
; char FSR ; 
FSR	equ 4
; char PORTA ; 
PORTA	equ 5
; char PORTB ; 
PORTB	equ 6
; char _unused ; 
_unused	equ 7
; char EEDATA ; 
EEDATA	equ 8
; char EEADR ; 
EEADR	equ 9
; char PCLATH ; 
PCLATH	equ 10
; char INTCON ; 
INTCON	equ 11
; char _temp ; 
_temp	equ 12
; char _eedata ; 
_eedata	equ 13
; # define DAH 128 
; # define DIT 64 
; # define MODEA 32 
; # define MODEB 0 
; # define SWAP 16 
; # define CHANGE_EN 0x08 
; # define TIMER_EN 0xa0 
; # define TIMEVAL 160 
; extern char EEDITCOUNT = 72 ; 

; ; extern char EEDAHCOUNT = 216 ; 

; ; char cel ; 
cel	equ 14
; char nel ; 
nel	equ 15
; char mask ; 
mask	equ 16
; char toggle ; 
toggle	equ 17
; char counter ; 
counter	equ 18
; char swap ; 
swap	equ 19
; char ditcount ; 
ditcount	equ 20
; char dahcount ; 
dahcount	equ 21
; char elcount ; 
elcount	equ 22
; char ttlel ; 
ttlel	equ 23
; char wtemp ; 
wtemp	equ 24
; char stemp ; 
stemp	equ 25
; # define FIFO_SIZE 8 
; char fifo [ 8  ] ; 
fifo	equ 26
; char f_in , f_out ; 
f_in	equ 34
f_out	equ 35
; char dv ; 
dv	equ 36
; char last_pdl ; 
last_pdl	equ 37
; char diff ; 
diff	equ 38
; char pdl ; 
pdl	equ 39
; init ( ) { 
	;code
init
; cel = nel = mask = toggle = f_in = f_out = last_pdl = 0 ; 
	movlw	0
	movwf	last_pdl
	movwf	f_out
	movwf	f_in
	movwf	toggle
	movwf	mask
	movwf	nel
	movwf	cel
; ditcount = EEDITCOUNT ; 
	movlw	0
	call	_eeadr
	movf	_eedata,W
	movwf	ditcount
; dahcount = EEDAHCOUNT ; 
	movlw	1
	call	_eeadr
	movf	_eedata,W
	movwf	dahcount
; PORTA = 0 ; 
	movlw	0
	BANKSEL	PORTA
	movwf	PORTA
; PORTB = 0 ; 
;movlw	0
	clrf 	PORTB
; TRISA = 0 ; 
	movlw	0
	bsf	STATUS,RP0
	movwf	TRISA
; TRISB = 0xff ; 
	movlw	255
	movwf	TRISB
; OPTION_REG = 0x08 ; 
	movlw	8
	movwf	OPTION_REG
	return
; } 
; _interupt ( ) { 
_interupt
; # asm 
   movwf   wtemp
   swapf   STATUS,W
   movwf   stemp;
YXY2
; INTCON = 0x20 ; 
	movlw	32
	movwf	INTCON
; toggle ^= 1 ; 
	movlw	1
	xorwf	toggle,F
; PORTA = ( toggle + 2 ) & mask ; 
	movf	toggle,W
	addlw	2
	andwf	mask,W
	BANKSEL	PORTA
	movwf	PORTA
; counter = ( counter == 254 ) ? 254 : counter + toggle ; 
	movf	counter,W
	addlw	2
	btfss	STATUS,Z
	goto	YXY3
	movlw	254
	iorlw	0
	goto	YXY4
YXY3
	movf	counter,W
	addwf	toggle,W
YXY4
	movwf	counter
; TMR0 = 160  ; 
	movlw	160
	BANKSEL	TMR0
	movwf	TMR0
; # asm 
   swapf  stemp,W
   movwf  STATUS
   swapf  wtemp,F
   swapf  wtemp,W
YXY5
	retfie
; } main ( ) { 
main
; INTCON = 0xa0  ; 
	movlw	160
	movwf	INTCON
; diff = last_pdl = cel = readpdl ( ) ; 
	call	readpdl
	movwf	cel
	movwf	last_pdl
	movwf	diff
; swap = ( PORTB & 16  ) ? 0 : 64  + 128  ; 
	BANKSEL	PORTB
	movf	PORTB,W
	andlw	16
	btfsc	STATUS,Z
	goto	YXY6
	movlw	0
	iorlw	0
	goto	YXY7
YXY6
	movlw	192
	iorlw	0
YXY7
	movwf	swap
; while ( cel ) { 
YXY8
	movf	cel,W
	btfsc	STATUS,Z
	goto	YXY9
; if ( cel == ( 64  + 128  ) ) cel = 64  ; 
	movf	cel,W
	addlw	64
	btfss	STATUS,Z
	goto	YXY10
	movlw	64
	movwf	cel
; elcount = ( ( cel ^ swap ) == 128  ) ? dahcount : ditcount ; 
YXY10
	movf	cel,W
	xorwf	swap,W
	addlw	128
	btfss	STATUS,Z
	goto	YXY11
	movf	dahcount,W
	goto	YXY12
YXY11
	movf	ditcount,W
YXY12
	movwf	elcount
; mask = 3 ; 
	movlw	3
	movwf	mask
; counter = 0 ; 
;movlw	0
	clrf 	counter
; wait4it ( ) ; 
	call	wait4it
; counter = mask = 0 ; 
	movlw	0
	movwf	mask
	movwf	counter
; elcount = ditcount ; 
	movf	ditcount,W
	movwf	elcount
; wait4it ( ) ; 
	call	wait4it
; if ( nel == 0 ) diff = last_pdl = nel = readpdl ( ) ; 
	movf	nel,W
;addlw	256
	btfss	STATUS,Z
	goto	YXY13
	call	readpdl
	movwf	nel
	movwf	last_pdl
	movwf	diff
; if ( nel == ( 64  + 128  ) ) nel -= cel ; 
YXY13
	movf	nel,W
	addlw	64
	btfss	STATUS,Z
	goto	YXY14
	movf	cel,W
	subwf	nel,F
; if ( cel == nel ) ++ ttlel ; 
YXY14
	movf	cel,W
	movwf	_temp
	movf	nel,W
	subwf	_temp,W
	btfss	STATUS,Z
	goto	YXY15
	incf	ttlel,F
; else ttlel = 0 ; 
	goto	YXY16
YXY15
	movlw	0
	movwf	ttlel
YXY16
; if ( ttlel >= 10 ) speedchange ( cel ) ; 
	movf	ttlel,W
	addlw	246
	btfss	STATUS,C
	goto	YXY17
	movf	cel,W
	call	speedchange
; cel = nel ; nel = 0 ; 
YXY17
	movf	nel,W
	movwf	cel
;movlw	0
	clrf 	nel
; } 
	goto	YXY8
YXY9
; counter = 0 ; 
;movlw	0
	clrf 	counter
; while ( counter < EEDAHCOUNT ) { 
YXY18
	movf	counter,W
	movwf	_temp
	movlw	1
	call	_eeadr
	movf	_eedata,W
	subwf	_temp,W
	btfsc	STATUS,C
	goto	YXY19
; if ( readpdl ( ) ) return ; 
	call	readpdl
	iorlw	0
	btfsc	STATUS,Z
	goto	YXY20
	return
; } 
YXY20
; } INTCON = 0x08  ; 
	goto	YXY18
YXY19
	movlw	8
	movwf	INTCON
; # asm 
   sleep
   nop
   nop
YXY21
	return
; } char next_element ( ) { 
next_element
; if ( f_in != f_out ) { 
	movf	f_in,W
	movwf	_temp
	movf	f_out,W
	subwf	_temp,W
	btfsc	STATUS,Z
	goto	YXY22
; dv = fifo [ f_out ++ ] ; 
	movf	f_out,W
	incf	f_out,F
	addlw	fifo
	movwf	FSR
	movf	INDF,W
	movwf	dv
; f_out &= ( 8  - 1 ) ; 
	movlw	7
	andwf	f_out,F
; return dv ; 
	movf	dv,W
	return
; } 
; return readpdl ( ) ; 
YXY22
	call	readpdl
	iorlw	0
	return
; } 
; char readpdl ( ) { 
readpdl
; return ( PORTB ^ 0xff ) & ( 64  + 128  ) ; 
	BANKSEL	PORTB
	movf	PORTB,W
	xorlw	255
	andlw	192
	return
; } 
; wait4it ( ) { 
wait4it
; while ( counter < elcount ) { 
YXY23
	movf	counter,W
	movwf	_temp
	movf	elcount,W
	subwf	_temp,W
	btfsc	STATUS,C
	goto	YXY24
; if ( diff ) { 
	movf	diff,W
	btfsc	STATUS,Z
	goto	YXY25
; debounce ( ) ; 
	call	debounce
; if ( counter >= elcount ) break ; 
	movf	counter,W
	movwf	_temp
	movf	elcount,W
	subwf	_temp,W
	btfss	STATUS,C
	goto	YXY26
	goto	YXY24
; } 
YXY26
; } pdl = readpdl ( ) ; 
YXY25
	call	readpdl
	movwf	pdl
; diff = pdl ^ last_pdl ; 
	movf	pdl,W
	xorwf	last_pdl,W
	movwf	diff
; last_pdl = pdl ; 
	movf	pdl,W
	movwf	last_pdl
; dv = diff & pdl ; 
	movf	diff,W
	andwf	pdl,W
	movwf	dv
; if ( dv ) { 
	movf	dv,W
	btfsc	STATUS,Z
	goto	YXY27
; fifo [ f_in ++ ] = dv ; 
	movf	f_in,W
	incf	f_in,F
	addlw	fifo
	movwf	FSR
	movf	dv,W
	movwf	INDF
; f_in &= ( 8  - 1 ) ; 
	movlw	7
	andwf	f_in,F
; } 
; } 
YXY27
; } if ( nel == 0 && f_in != f_out ) nel = next_element ( ) ; 
	goto	YXY23
YXY24
	movf	nel,W
;addlw	256
	btfss	STATUS,Z
	goto	YXY28
	movf	f_in,W
	movwf	_temp
	movf	f_out,W
	subwf	_temp,W
	btfsc	STATUS,Z
	goto	YXY28
	call	next_element
	movwf	nel
; } 
YXY28
	return
; } void debounce ( ) { 
debounce
; dv = counter + 9 ; 
	movf	counter,W
	addlw	9
	movwf	dv
; if ( dv < 9 ) dv = 250 ; 
	movf	dv,W
	addlw	247
	btfsc	STATUS,C
	goto	YXY29
	movlw	250
	movwf	dv
; while ( counter < dv ) { 
YXY29
YXY30
	movf	counter,W
	movwf	_temp
	movf	dv,W
	subwf	_temp,W
	btfsc	STATUS,C
	goto	YXY31
; if ( counter >= elcount ) break ; 
	movf	counter,W
	movwf	_temp
	movf	elcount,W
	subwf	_temp,W
	btfss	STATUS,C
	goto	YXY32
	goto	YXY31
; } 
YXY32
; } } 
	goto	YXY30
YXY31
	return
; speedchange ( char updown ) { 
	;data
_speedchange	equ	40
	;code
speedchange
	banksel	_speedchange
	movwf	_speedchange
; if ( updown == 64  ) { 
	movf	_speedchange,W
	addlw	192
	btfss	STATUS,Z
	goto	YXY33
; -- ditcount ; 
	decf	ditcount,F
; dahcount -= 3 ; 
	movlw	3
	subwf	dahcount,F
; } 
; else { 
	goto	YXY34
YXY33
; ++ ditcount ; 
	incf	ditcount,F
; dahcount += 3 ; 
	movlw	3
	addwf	dahcount,F
; } 
YXY34
; if ( dahcount < 30 || dahcount >= 254 ) { 
	movf	dahcount,W
	addlw	226
	btfss	STATUS,C
	goto	YXY35
	movf	dahcount,W
	addlw	2
	btfss	STATUS,C
	goto	YXY36
YXY35
; ditcount = EEDITCOUNT ; 
	movlw	0
	call	_eeadr
	movf	_eedata,W
	movwf	ditcount
; dahcount = EEDAHCOUNT ; 
	movlw	1
	call	_eeadr
	movf	_eedata,W
	movwf	dahcount
; } 
; } 
YXY36
	return
	org	0x2100	;eeprom constant data
	de	72,216
	end
