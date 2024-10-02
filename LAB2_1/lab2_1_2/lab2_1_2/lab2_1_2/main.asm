//Write a program to generate a 64 us square wave using Timer 1 in CTC mode. 
//Use pin OC0 as the output.

//TH=TL= 32us
.ORG 0
RJMP MAIN .ORG 0X40
MAIN: 
	LDI R16,HIGH(RAMEND);??a stack lên ??nh SRAM
	OUT SPH,R16
	LDI R16,LOW(RAMEND)
	OUT SPL,R16
	LDI R16,0x08
	OUT DDRB,R16
	CBI PORTB,3


	LDI R17,32
	STS OCR1AL,R17;ghi byte th?p kênh A sau
	LDI R17,0X00 ;Timer1 mode CTC4
	STS TCCR1A,R17  
	LDI R17,0X0A ;Timer1 b?t ??u ch?y, h? s? chia N=8
	STS TCCR1B,R17
 
WAIT: 
	SBIS TIFR1,OCF1A ;ch? c? OCF1A=1 báo k?t qu? so sánh kênh A
	RJMP WAIT ;c? OCF1A=0 ti?p t?c ch?
	SBI TIFR1,OCF1A ;OCF1A=1 ? xóa c? OCF1A
	IN R17,PORTB ;??c Port
	LDI R16,0x08
	EOR R17,R16 ;??o bit 
	OUT PORTB,R17 ;xu?t ra PortB
	RJMP WAIT ;l?p vòng l?i
	