// program config PB 5, PB6 as input
//portC as output , monitor the PB5, PB6 bitcontinously.
//both them is high send 0xAA to PORTC otherwise send $55 to PORTC

CBI DDRB, 5
CBI DDRB, 6
SBI PORTB, 5				// pb5=1
SBI PORTB, 6
LDI R16, 0XFF 
OUT DDRC, R16
LDI R16, 0XFF



LOOP:
	SBIC PINB,5				//b? l?nh rjmp n?u pb5=0 (nút nh?n)
	RJMP SEND_55
	SBIC PINB, 6			//b? l?nh rjmp n?u pb6=0 (nút nh?n)
	RJMP SEND_55
	LDI R17, 0xFF
	OUT PORTC, R17
	RJMP LOOP

SEND_55:
	LDI R17,0X55
	OUT PORTC, R17
	RJMP LOOP		