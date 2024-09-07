	LDI R16, 0x02     	
	OUT DDRA, R16   //PA0 input	PA1 output
 
	LDI R16, $01  	
	//OUT PORTA, R16	//pull up reg

 
start:
	//IN R16, PINA
	//COM R16  	
	RCALL NHAN_PHIM
	RJMP start


NHAN_PHIM:
WAIT_0: 
	SBIC PINA,0 // push key?
	RJMP WAIT_0 
	LDI R17, 0x02
	OUT PORTA, R17


WAIT_1: 
	SBIS PINA,0 // release key?
	RJMP WAIT_1
	LDI R17, 0x00
	OUT PORTA, R17
RET