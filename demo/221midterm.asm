// program config PB 5, PB6 as input
//portC as output , monitor the PB5, PB6 bitcontinously.
//both them is high send 0xAA to PORTC otherwise send $55 to PORTC

LDI R18, 0b01100000
CBI DDRB, 5
CBI DDRB, 6
LDI R16, 0XFF 
LDI DDRC, R16
LDI R16 0XFF
LOOP:
	IN R17, PORTB
	EOR R17, R16 
	CP R18, R17
	BRNE KHAC
	LDI R19, 0xAA
	OUT PORTC, R17
	RJMP LOOP


KHAC:
	LDI R19,0X55
	OUT PORTC, R17
	RJMP LOOP		