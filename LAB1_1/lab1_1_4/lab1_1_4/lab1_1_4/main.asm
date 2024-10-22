//Connect and implement a program to calculate the product of two nibbles (high and low) of PORT A and send it to PORT B. Consider these two nibbles as signed numbers.
//Example: PORT A = 0b0111_1111, then PORT B = 3 * (-1).
.MACRO INIT_PORTS
    LDI R16, $00
    OUT DDRA, R16
    LDI R16, $FF
    OUT PORTA, R16
    LDI R16, $FF
    OUT DDRB, R16
    LDI R16, $00
    OUT PORTB, R16
.ENDMACRO

.MACRO EXTEND_ROUTINE
    SBRS R18, 3
    RET
    ORI R18, 0xF0
    RET
.ENDMACRO

    .DEF temp = R16
    .DEF high_nibble = R17
    .DEF low_nibble = R18

	///////////////////main///////////////////
    INIT_PORTS

LOOP:
    IN temp, PINA
    COM temp
    MOV high_nibble, temp
    ANDI temp, $F0            ; Mask to keep 4 high bits
    SWAP temp

    MOV low_nibble, temp
    RCALL EXTEND
    MOV temp, low_nibble

    ANDI high_nibble, $0F     ; Mask to keep 4 low bits
    MOV low_nibble, high_nibble
    RCALL EXTEND
    MULS temp, high_nibble
    OUT PORTB, R0
    RJMP LOOP

EXTEND:
    EXTEND_ROUTINE


/*
LDI R16, $00
OUT DDRA, R16
LDI R16, $FF
OUT PORTA, R16
LDI R16, 0xFF
OUT DDRB, R16
LDI R16, $00
OUT PORTB, R16


; STATUS INPUT
LOOP:
	IN R16, PINA
	COM R16
	MOV R17, R16
	ANDI R16, $F0		     ;4 BIT HIGH
	SWAP R16

	MOV R18, R16
	RCALL EXTEND
	MOV R16, R18

	ANDI R17, $0F                ;4 BIT LOW
	MOV R18, R17
	RCALL EXTEND
	MULS R16, R17
	OUT PORTB, R0
	RJMP LOOP

EXTEND:
	SBRS R18, 3
	RET
	ORI R18, 0xF0
	RET
	*/