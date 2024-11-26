.MACRO INIT_PORTS
    LDI R16, 0x00
    OUT DDRA, R16   ; Set PORTA as input
    LDI R16, 0xFF
    OUT PORTA, R16  ; Enable pull-up resistors on PORTA
    OUT DDRB, R16   ; Set PORTB as output
.ENDMACRO

.MACRO PROCESS_INPUT
    IN R16, PINA         ; Read input from PINA
    COM R16              ; Complement the input
    MOV R17, R16         ; Copy R16 to R17
    ANDI R16, 0x0F       ; Mask to keep low nibble
    ANDI R17, 0xF0       ; Mask to keep high nibble
    SWAP R17             ; Swap nibbles in R17
    MUL R16, R17         ; Multiply nibbles
    OUT PORTB, R0        ; Output result to PORTB
.ENDMACRO

    .DEF temp = R16
    .DEF high_nibble = R17


	//////////main///////////////
    INIT_PORTS
start:
    PROCESS_INPUT
    RJMP start           ; Loop back to start


/*
	LDI R16, 0X00 
	OUT DDRA, R16 	;set portA as input
	LDI R16, 0xFF
	OUT PORTA, R16 	; put-up resistor at portA
	OUT DDRB, R16 	;set portB as output
 
start:	
	IN R16, PINA 	;pinA as switch
	COM R16
	MOV R17, R16 	;copy content in R16 to R17
	ANDI R16, 0x0F 	;take low_nibble
	ANDI R17, 0xF0 	;take high_nibble
	SWAP R17 	;inchange high_nibble and low_nibble
	MUL R16, R17 	;multiply two nibbles
	OUT PORTB, R0 	;out result to LED
	rjmp start	;loop
*/