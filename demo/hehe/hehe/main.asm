.EQU	DATAP=PORTD
.EQU	CTR=PORTD
.EQU	RS=0	
.EQU	RW=1
.EQU	EN=2
.ORG 0
	LDI	R16,$FF
	OUT	DDRD,R16

	ldi r20, 0xFF
	out DDRB, r20
	
INIT_LCD:
		   LDI	R21,250
		   CALL DELAY		;DELAY 25MS
		   LDI  R20,$30 
		   CALL CMDWRITE
		   LDI	R21,50
		   CALL DELAY		;DELAY 5MS
		   LDI  R20,$30 
		   CALL CMDWRITE
		   LDI	R21,1
		   CALL DELAY		;DELAY 100US
		   LDI  R20,$30 
		   CALL CMDWRITE

		   LDI  R20,$20 
		   CALL CMDWRITE 
           LDI	R20,$28		;2 lines and 5×7 matrix
           CALL CMDWRITE4BIT 
           LDI	R20,$0E		;Display on, cursor blinking
           CALL CMDWRITE4BIT   
           LDI  R20,$06		;Increment cursor (shift cursor to right)
           CALL CMDWRITE4BIT  
		   LDI  R20,$01		;Clears the screen and returns the cursor to the initial position
           CALL CMDWRITE4BIT 
		   LDI  R20,$80		;Force cursor to the beginning ( 1st line)
           CALL CMDWRITE4BIT 

main:
	call keypad_scan
	out PORTB, r23		;display result on barled
	CP R23,R25			;compare pressed key with previous one
	BREQ main			;if pressed key is previous one then jump to main

	CPI r23,0xFF
	BRNE notFF
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$46
	CALL DATAWRITE4BIT 
	LDI R20,$46
	CALL DATAWRITE4BIT	;print FF
	MOV R25,R23			;store pre value
	rjmp main
notFF:

	CPI r23,0x0F
	BRNE notF
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$46
	CALL DATAWRITE4BIT	;print F
	MOV R25,R23			;store pre value
	rjmp main
notF:
	CPI r23,0x0E
	BRNE notE
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$45
	CALL DATAWRITE4BIT	;print E
	MOV R25,R23			;store pre value
	rjmp main
notE:
	CPI r23,0x0D
	BRNE notD
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$44			;print D
	CALL DATAWRITE4BIT 
	MOV R25,R23			;store pre value
	rjmp main
notD:
	CPI r23,0x0C
	BRNE notC
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$43
	CALL DATAWRITE4BIT	;print C
	MOV R25,R23			;store pre value
	rjmp main
notC:
	CPI r23,0x0B
	BRNE notB
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$42
	CALL DATAWRITE4BIT	;print B
	MOV R25,R23			;store pre value
	rjmp main
notB:
	CPI r23,0x0A
	BRNE notA
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$41
	CALL DATAWRITE4BIT	;print A
	MOV R25,R23			;store pre value
	rjmp main
notA:					;if pressed key is a number
	LDI  R20,$01
    CALL CMDWRITE4BIT	;Clears the screen
	LDI R20,$30
	ADD R20,R23			;print pressed number + x30
	CALL DATAWRITE4BIT 
	MOV R25,R23			;store pre value
	rjmp main


keypad_scan:
	ldi r20, 0b00001111 ; set upper 4 bits of PORTD as input with pull-up, lower 4 bits as output
	out DDRA, r20
	ldi r20, 0b11111111 ; enable pull up resistor
	out PORTA, r20

	ldi r22, 0b11110111 ; initial col mask
	ldi r23, 0 ; initial pressed row value
	ldi r24,3 ;scanning col index

keypad_scan_loop:
	out PORTA, r22 ; scan current col
	nop ;need to have 1us delay to stablize
	sbic PINA, 4 ; check row 0
	rjmp keypad_scan_check_col2
	rjmp keypad_scan_found ; row 0 is pressed
keypad_scan_check_col2:
	sbic PINA, 5 ; check row 1
	rjmp keypad_scan_check_col3
	ldi r23, 1 ; row1 is pressed
	rjmp keypad_scan_found
keypad_scan_check_col3:
	sbic PINA, 6 ; check row 2
	rjmp keypad_scan_check_col4
	ldi r23, 2 ; row 2 is pressed
	rjmp keypad_scan_found
keypad_scan_check_col4:
	sbic PINA, 7 ; check row 3
	rjmp keypad_scan_next_row
	ldi r23, 3 ; row 3 is pressed
	rjmp keypad_scan_found

keypad_scan_next_row:
; check if all rows have been scanned
	cpi r24,0
	breq keypad_scan_not_found
; shift row mask to scan next row
	ror r22
	dec r24 ;increase row index
	rjmp keypad_scan_loop

keypad_scan_found:
; combine row and column to get key value (0-15)
;key code = row*4 + col
	lsl r23 ; shift row value 4 bits to the left
	lsl r23
	add r23, r24 ; add row value to column value
	ret
keypad_scan_not_found:
	ldi r23, 0xFF ; no key pressed
	ret

CMDWRITE4BIT:
	PUSH	R20
	ANDI	R20,$F0
	CALL	CMDWRITE
	POP		R20
	ANDI	R20,$0F
	SWAP	R20
	CALL	CMDWRITE  
	RET

CMDWRITE:
    OUT    DATAP,R20 ; PortC <- D
    CBI    CTR,RS     	   ; RS <- 0  
    CBI    CTR,RW      ; R/W <- 0
    SBI    CTR,EN        ; EN <- 1
    NOP
    CBI    CTR,EN         ; EN <- 0
	LDI	   R21,20
	CALL   DELAY		;DELAY2MS
    RET   

DATAWRITE4BIT:
	PUSH	R20
	ANDI	R20,$F0
	CALL	DATAWRITE
	POP		R20
	ANDI	R20,$0F
	SWAP	R20
	CALL	DATAWRITE  
	RET

DATAWRITE:
	OUT	   DATAP,R20 ; PortC <- D
    SBI    CTR,RS       ; RS <- 1  
    CBI    CTR,RW     ; R/W <- 0
    SBI    CTR,EN      ; EN <- 1
    NOP
    CBI    CTR,EN     ; EN <- 0
	LDI	   R21,20
	CALL   DELAY		;DELAY2MS
    RET   

/*R21: n times of 100us*/
DELAY:
L1:		CALL	DELAY100US	
		DEC		R21
		BRNE	L1
		RET

DELAY100US:
		PUSH	R21
		LDI		R21,200
L2:		NOP 		
        DEC		R21 	
		BRNE	L2
		POP		R21
        RET
