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

QUR1
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
; char mode ; 
mode	equ 19
; char swap ; 
swap	equ 20
; char fmask ; 
fmask	equ 21
; char lmask ; 
lmask	equ 22
; char ditcount ; 
ditcount	equ 23
; char dahcount ; 
dahcount	equ 24
; char halfcount ; 
halfcount	equ 25
; char elcount ; 
elcount	equ 26
; char ttlel ; 
ttlel	equ 27
; char wtemp ; 
wtemp	equ 28
; char stemp ; 
stemp	equ 29
; init ( ) { 
	;code
init
; cel = nel = mask = toggle = 0 ; 
	movlw	0
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
QUR2
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
	goto	QUR3
	movlw	254
	iorlw	0
	goto	QUR4
QUR3
	movf	counter,W
	addwf	toggle,W
QUR4
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
QUR5
	retfie
; } main ( ) { 
main
; INTCON = 0xa0  ; 
	movlw	160
	movwf	INTCON
; cel = readpdl ( ) ; 
	call	readpdl
	movwf	cel
; mode = PORTB & 32  ; 
	BANKSEL	PORTB
	movf	PORTB,W
	andlw	32
	movwf	mode
; swap = ( PORTB & 16  ) ? 0 : 64  + 128  ; 
	movf	PORTB,W
	andlw	16
	btfsc	STATUS,Z
	goto	QUR6
	movlw	0
	iorlw	0
	goto	QUR7
QUR6
	movlw	192
	iorlw	0
QUR7
	movwf	swap
; while ( cel ) { 
QUR8
	movf	cel,W
	btfsc	STATUS,Z
	goto	QUR9
; if ( cel == ( 64  + 128  ) ) cel = 64  ; 
	movf	cel,W
	addlw	64
	btfss	STATUS,Z
	goto	QUR10
	movlw	64
	movwf	cel
; elcount = ( ( cel ^ swap ) == 128  ) ? dahcount : ditcount ; 
QUR10
	movf	cel,W
	xorwf	swap,W
	addlw	128
	btfss	STATUS,Z
	goto	QUR11
	movf	dahcount,W
	goto	QUR12
QUR11
	movf	ditcount,W
QUR12
	movwf	elcount
; mask = 3 ; 
	movlw	3
	movwf	mask
; fmask = counter = 0 ; 
	movlw	0
	movwf	counter
	movwf	fmask
; lmask = ( 64  + 128  ) - cel ; 
	movlw	192
	movwf	_temp
	movf	cel,W
	subwf	_temp,W
	movwf	lmask
; if ( mode == 32  && readpdl ( ) == ( 64  + 128  ) ) lmask = 0 ; 
	movf	mode,W
	addlw	224
	btfss	STATUS,Z
	goto	QUR13
	call	readpdl
	addlw	64
	btfss	STATUS,Z
	goto	QUR13
;movlw	0
	clrf 	lmask
; wait4it ( ) ; 
QUR13
	call	wait4it
; counter = mask = 0 ; 
	movlw	0
	movwf	mask
	movwf	counter
; elcount = ditcount ; 
	movf	ditcount,W
	movwf	elcount
; fmask = lmask ; 
	movf	lmask,W
	movwf	fmask
; wait4it ( ) ; 
	call	wait4it
; if ( nel == 0 ) nel = readpdl ( ) ; 
	movf	nel,W
;addlw	256
	btfss	STATUS,Z
	goto	QUR14
	call	readpdl
	movwf	nel
; if ( nel == ( 64  + 128  ) ) nel -= cel ; 
QUR14
	movf	nel,W
	addlw	64
	btfss	STATUS,Z
	goto	QUR15
	movf	cel,W
	subwf	nel,F
; if ( cel == nel ) ++ ttlel ; 
QUR15
	movf	cel,W
	movwf	_temp
	movf	nel,W
	subwf	_temp,W
	btfss	STATUS,Z
	goto	QUR16
	incf	ttlel,F
; else ttlel = 0 ; 
	goto	QUR17
QUR16
	movlw	0
	movwf	ttlel
QUR17
; if ( ttlel >= 10 ) speedchange ( cel ) ; 
	movf	ttlel,W
	addlw	246
	btfss	STATUS,C
	goto	QUR18
	movf	cel,W
	call	speedchange
; cel = nel ; nel = 0 ; 
QUR18
	movf	nel,W
	movwf	cel
;movlw	0
	clrf 	nel
; } 
	goto	QUR8
QUR9
; counter = 0 ; 
;movlw	0
	clrf 	counter
; while ( counter < EEDAHCOUNT ) { 
QUR19
	movf	counter,W
	movwf	_temp
	movlw	1
	call	_eeadr
	movf	_eedata,W
	subwf	_temp,W
	btfsc	STATUS,C
	goto	QUR20
; if ( readpdl ( ) ) return ; 
	call	readpdl
	iorlw	0
	btfsc	STATUS,Z
	goto	QUR21
	return
; } 
QUR21
; } INTCON = 0x08  ; 
	goto	QUR19
QUR20
	movlw	8
	movwf	INTCON
; # asm 
   sleep
   nop
   nop
QUR22
	return
; } char readpdl ( ) { 
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
; halfcount = ditcount >> 1 ; 
	movf	ditcount,W
	movwf	_temp
	movlw	1
	iorlw	0
	call	_rshift
	movf	_temp,W
	movwf	halfcount
; while ( counter < elcount ) { 
QUR23
	movf	counter,W
	movwf	_temp
	movf	elcount,W
	subwf	_temp,W
	btfsc	STATUS,C
	goto	QUR24
; if ( nel == 0 ) { 
	movf	nel,W
;addlw	256
	btfss	STATUS,Z
	goto	QUR25
; nel = readpdl ( ) ; 
	call	readpdl
	movwf	nel
; if ( counter >= halfcount ) nel &= lmask ; 
	movf	counter,W
	movwf	_temp
	movf	halfcount,W
	subwf	_temp,W
	btfss	STATUS,C
	goto	QUR26
	movf	lmask,W
	andwf	nel,F
; else nel &= fmask ; 
	goto	QUR27
QUR26
	movf	fmask,W
	andwf	nel,F
QUR27
; } 
; } 
QUR25
; } } 
	goto	QUR23
QUR24
	return
; speedchange ( char updown ) { 
	;data
_speedchange	equ	30
	;code
speedchange
	banksel	_speedchange
	movwf	_speedchange
; if ( updown == 64  ) { 
	movf	_speedchange,W
	addlw	192
	btfss	STATUS,Z
	goto	QUR28
; -- ditcount ; 
	decf	ditcount,F
; dahcount -= 3 ; 
	movlw	3
	subwf	dahcount,F
; } 
; else { 
	goto	QUR29
QUR28
; ++ ditcount ; 
	incf	ditcount,F
; dahcount += 3 ; 
	movlw	3
	addwf	dahcount,F
; } 
QUR29
; if ( dahcount < 30 || dahcount >= 254 ) { 
	movf	dahcount,W
	addlw	226
	btfss	STATUS,C
	goto	QUR30
	movf	dahcount,W
	addlw	2
	btfss	STATUS,C
	goto	QUR31
QUR30
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
QUR31
	return
	org	0x2100	;eeprom constant data
	de	72,216
	end
