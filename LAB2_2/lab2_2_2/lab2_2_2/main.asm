.ORG 00
.DEF ANSL = R2            ;To hold low-byte of answer
.DEF ANSH = R3            ;To hold high-byte of answer     
.DEF REML = R4            ;To hold low-byte of remainder
.DEF REMH = R5            ;To hold high-byte of remainder
.DEF   AL = R20           ;To hold low-byte of dividend // SO BI CHIA
.DEF   AH = R21           ;To hold high-byte of dividend
.DEF   BL = R22           ;To hold low-byte of divisor // SO CHIA
.DEF   BH = R23           ;To hold high-byte of divisor   
.DEF    C = R24           ;Bit Counter
;----------------SET UP OUTPUT/INPUT----------------------
	LDI R16,0XFF
	OUT DDRB,R16; SET PORTB IS OUTPUT TO LED
	OUT PORTB,R16
	OUT PORTA,R16

	LDI R16,0X00
	OUT DDRA,R16; SET PORTA IS INPUT FROM SWITCH
	

	LDI R16,0X03
	OUT DDRD,R16; SET PD0,1 IS OUTPUT (nLE)
	CBI PORTD,0
	CBI PORTD,1
;-------------------PROGRAM------------------------------
A:	IN R18,PINA
	COM R18
	LDI R19,$09
	MUL R18,R19

B:	
MOV AL,R0   ;Load low-byte of dividend into AL
MOV AH,R1  ;Load HIGH-byte of dividend into AH
LDI BL,LOW(10)    ;Load low-byte of divisor into BL
LDI BH,HIGH(10)   ;Load high-byte of divisor into BH
RCALL DIV1616
MOV R29,REML
	MOV AL,ANSL   ;Load low-byte of dividend into AL
	MOV AH,ANSH  ;Load HIGH-byte of dividend into AH
	LDI BL,LOW(10)    ;Load low-byte of divisor into BL
	LDI BH,HIGH(10)   ;Load high-byte of divisor into BH
	RCALL DIV1616
	MOV R28,REML
		MOV AL,ANSL   ;Load low-byte of dividend into AL
		MOV AH,ANSH  ;Load HIGH-byte of dividend into AH
		LDI BL,LOW(10)    ;Load low-byte of divisor into BL
		LDI BH,HIGH(10)   ;Load high-byte of divisor into BH
		RCALL DIV1616
		MOV R27,REML
			MOV AL,ANSL   ;Load low-byte of dividend into AL
			MOV AH,ANSH  ;Load HIGH-byte of dividend into AH
			LDI BL,LOW(10)    ;Load low-byte of divisor into BL
			LDI BH,HIGH(10)   ;Load high-byte of divisor into BH
			RCALL DIV1616
			MOV R26,REML
	RJMP MAIN_PROGRAM
			
MAIN_PROGRAM:
LED3:		
		MOV R16,R26
		RCALL WRITEDATA
		LDI R16,0XF7; CHOOSE LED, 0: CHOOSE, 1: NOT
		OUT PORTB,R16
		RCALL nLE1
		RCALL DELAY5MS
		RCALL RESET_LED

LED2:
		MOV R16,R27
		RCALL WRITEDATA
		LDI R16,0XFB; CHOOSE LED, 0: CHOOSE, 1: NOT
		OUT PORTB,R16
		RCALL nLE1
		RCALL DELAY5MS
		RCALL RESET_LED

LED1:
		MOV R16,R28
		RCALL WRITEDATA
		LDI R16,0XFD; CHOOSE LED, 0: CHOOSE, 1: NOT
		OUT PORTB,R16
		RCALL nLE1
		RCALL DELAY5MS
		RCALL RESET_LED

LED0:	
		MOV R16,R29
		RCALL WRITEDATA
		LDI R16,0XFE; CHOOSE LED, 0: CHOOSE, 1: NOT
		OUT PORTB,R16
		RCALL nLE1
		RCALL DELAY5MS
		RCALL RESET_LED
	
	RJMP A
;-----------------DATA---------------------------------
TABLE_DATA: .DB 0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83,0XC6,0XA1,0X86,0X8E
;----------------SUBROUTINE---------------------------
WRITEDATA:
		LDI	ZH,HIGH(TABLE_DATA<<1)
		LDI ZL,LOW(TABLE_DATA<<1)
		ADD ZL,R16
		LPM R17,Z
		OUT	PORTB,R17
		RCALL nLE0
	RET

nLE0:
		SBI PORTD,0
		NOP
		CBI PORTD,0
	RET

nLE1:
		SBI PORTD,1
		NOP
		CBI PORTD,1
	RET

RESET_LED:		
		LDI R16,0X0F
		OUT PORTB,R16
		RCALL nLE1
	RET

DELAY5MS:
		LDI R18,-39 ; TCNT0 = -39
		OUT TCNT0,R18
		LDI R18,0X00; NORMAL MODE TIMER0
		OUT TCCR0A,R18
		LDI R18,0X05; N = 1024
		OUT TCCR0B,R18
WAIT:	SBIS TIFR0,TOV0 ; check TOV0 = 1 
		RJMP WAIT ;wait if TOV0=0 
		SBI TIFR0,TOV0 ;if TOV0=1 
		LDI R18,0x00 ;stop Timer0
		OUT TCCR0B,R18
	RET

DIV1616:
		MOVW ANSH:ANSL,AH:AL ;Copy dividend into answer
		LDI C,17          ;Load bit counter
		SUB REML,REML     ;Clear Remainder and Carry
		CLR REMH          ;
	LOOP:   ROL ANSL          ;Shift the answer to the left
		ROL ANSH          ;
		DEC C             ;Decrement Counter
		BREQ DONE        ;Exit if sixteen bits done
		ROL REML          ;Shift remainder to the left
		ROL REMH          ;
		SUB REML,BL       ;Try to subtract divisor from remainder
		SBC REMH,BH
		BRCC SKIP        ;If the result was negative then
		ADD REML,BL       ;reverse the subtraction to try again
		ADC REMH,BH       ;
		CLC               ;Clear Carry Flag so zero shifted into A
		RJMP LOOP        ;Loop Back
	SKIP:   SEC               ;Set Carry Flag to be shifted into A
		RJMP LOOP
	DONE: RET
