	LDI R16, 0x00  	
	OUT DDRA, R16  //set input	
 
	LDI R16, $FF  	
	OUT PORTA, R16	//pull up reg
	OUT DDRB, R16 	//set up
 
start:
	IN R16, PINA  	
	COM R16
	OUT PORTB, R16
	rjmp start    	
