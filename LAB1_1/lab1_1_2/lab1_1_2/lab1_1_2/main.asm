.MACRO INIT_PORTS
    LDI R16, 0x00
    OUT DDRA, R16
    LDI R16, 0xFF
    OUT PORTA, R16
    OUT DDRB, R16
.ENDMACRO

.MACRO DELAY_ROUTINE
    LDI        R21,250     ;1MC
L1: LDI        R20,250     ;1MC
L2: DEC        R20         ;1MC
    NOP                    ;1MC
    BRNE       L2          ; 2/1MC
    DEC         R21        ;1MC
    BRNE      L1           ;2/1MC
    RET                    ;4MC
.ENDMACRO

.MACRO HANDLE_OVERFLOW
    LDI R16,0x00
    OUT PORTB, R16
    RCALL DELAY
    LDI R16, 0xFF
    OUT PORTB, R16
    RCALL DELAY
.ENDMACRO

    .DEF temp = R16
    .DEF add_value = R17

/////////////////////main///////////////////////////////
    INIT_PORTS

start:    
    LDI add_value, 0x05  ; Load the value 0x05 into add_value for addition
    IN temp, PINA        ; Read the input from PORTA and store it in temp
    COM temp             ; Complement the input value
    ADD temp, add_value  ; Add the value in add_value (0x05) to temp
    BRCS OVERFLOW

    OUT PORTB, temp      ; Output the result in temp to PORTB
    RJMP start           ; Jump back to the start of the loop

OVERFLOW:
    HANDLE_OVERFLOW
    RJMP start

DELAY:
    DELAY_ROUTINE



/*
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
*/