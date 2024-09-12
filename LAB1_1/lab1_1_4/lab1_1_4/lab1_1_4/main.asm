	LDI R16, 0x00  	
	OUT DDRA, R16   //set input	
 
	LDI R16, $FF  	
	OUT PORTA, R16	//pull up reg
	OUT DDRB, R16 	//set up
 
start:
	IN R16, PINA
	COM R16  	
	MOV	R17,R16
	ANDI R17, 0xF0
	LSR R17
	LSR R17	
	LSR R17
	LSR R17

	ANDI R16, 0x0F
	MULS R16, R17Z
	OUT PORTB, R0
	rjmp start    	
