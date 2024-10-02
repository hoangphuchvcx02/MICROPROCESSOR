//Write a delay subroutine of 1 ms using Timer 0. 
//Use this subroutine to generate a 500 Hz pulse on pin PA0.
	LDI R16, 0x01
	OUT DDRA, R16

MAIN:
	LDI R16, 0X01
	OUT PORTA, R16
	RCALL DELAY_1MS
	LDI R16, 0X00
	OUT PORTA, R16
	RCALL DELAY_1MS
	RJMP MAIN


DELAY_1MS:
	LDI R17,-125 ;n?p TCNT0 = 0xA0 = -125
	OUT TCNT0,R17
	LDI R17,0X00 ;TCCR0A= 0000 0000
	OUT TCCR0A,R17
	LDI R17,0X03 ;Timer0 ch?y, ch?n CS02:CS00 = 011, h? s? chia N = 64
	OUT TCCR0B,R17 ;TCCR0B= 0000 0011, MODE NOR
	WAIT:
	SBIS TIFR0,TOV0 ;ch? c? TOV0 = 1 báo Timer0 tràn
	RJMP WAIT ;c? TOV0=0 ti?p t?c ch?
	SBI TIFR0,TOV0 ;TOV0 = 1 xóa c? TOV0
	LDI R17,0x00 ;d?ng Timer0
	OUT TCCR0B,R17
	RET