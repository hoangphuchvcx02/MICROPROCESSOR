	LDI R16, 0x00  	; Initialize R16 with 0
	OUT DDRA, R16 	; Set all bits in DDRA (PORTA data direction register) to 0 (input)
	LDI R16, 0xFF  	; Initialize R16 with 0xFF (binary 11111111)
	OUT PORTA, R16	; Set all bits in PORTA to high (enable pull-up resistors for input)
	OUT DDRB, R16 	; Set all bits in DDRB (PORTB data direction register) to 0 (output)
	


 
start:	
	LDI R17, 0x05 	; Load the value 0x05 into R17 for addition
	IN R16, PINA  	; Read the input from PORTA and store it in R16
    COM R16
	ADD R16, R17  	; Add the value in R17 (0x05) to R16
	BRCS OVERFLOW

	OUT PORTB, R16	; Output the result in R16 to PORTB 
	RJMP START    	; Jump back to the start of the loop

OVERFLOW:
	LDI R16,0X00
	OUT PORTB, R16
	RCALL DELAY
	LDI R16, 0XFF
	OUT PORTB, R16
	RCALL DELAY
	RJMP START


DELAY:
                LDI        R21,250     ;1MC
        L1:     LDI        R20,250     ;1MC
        L2:     DEC        R20         ;1MC
                NOP                    ;1MC
                BRNE       L2          ; 2/1MC
                DEC         R21        ;1MC
                BRNE      L1           ;2/1MC
                RET                    ;4MC
