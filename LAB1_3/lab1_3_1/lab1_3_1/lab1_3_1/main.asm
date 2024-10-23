.org 0x0000 ; interrupt vector table
rjmp reset_handler ; reset
;******************************* Program ID *********************************
.org INT_VECTORS_SIZE
course_name:
.db "MICROPROCESSOR - 241",0
course_time:
.db "GROUP 3 - TT01 ",0

reset_handler:
	call LCD_Init
	; display the first line of information
	ldi ZH, high(course_name) 	; point to the information that is to be
	ldi ZL, low(course_name)
	call LCD_Send_String
	ldi r16,1
	ldi r17,0
	call LCD_Move_Cursor
	ldi ZH, high(course_time) 	; point to the information that is to be
	ldi ZL, low(course_time)
	call LCD_Send_String

	/////////////////MAIN /////////////////
start:
rjmp start
 


 ////////////////////SMALL FUNCTION///////////////
	LCD_Init:
	; Set up data direction register for Port A
	ldi r16, 0b11110111       	; set PA7-PA4 as outputs, PA2-PA0 as output
	out LCDPORTDIR, r16
	; Wait for LCD to power up
	call DELAY_10MS
	call DELAY_10MS
	; Send initialization sequence
	ldi r16, 0x02 ; Function Set: 4-bit interface
	call LCD_Send_Command
	ldi r16, 0x28 ; Function Set: enable 5x7 mode for chars
	call LCD_Send_Command
	ldi r16, 0x0E ; Display Control: Display OFF, Cursor ON
	call LCD_Send_Command
	ldi r16, 0x01 ; Clear Display
	call LCD_Send_Command
	ldi r16, 0x80 ; Clear Display
	call LCD_Send_Command
	ret
 
.def LCDData = r16

LCD_Send_String:
	push ZH ; preserve pointer registers
	push ZL
	push LCDData
	; fix up the pointers for use with the 'lpm' instruction
	lsl ZL        	; shift the pointer one bit left for the
	rol ZH
	; write the string of characters
	LCD_Send_String_01:
	lpm LCDData, Z+     	; get a character
	cpi LCDData, 0      	; check for end of string
	breq LCD_Send_String_02 ; done
	; arrive here if this is a valid character
	call LCD_Send_Data        	; display the character
	rjmp LCD_Send_String_01   	; not done, send another character
	; arrive here when all characters in the message have been sent to the LCD module
	LCD_Send_String_02:
	pop LCDData
	pop ZL ; restore pointer registers
	pop ZH
ret
 
LCD_Move_Cursor:
	cpi r16,0 ;check if first row
	brne LCD_Move_Cursor_Second
	andi r17, 0x0F
	ori r17,0x80
	mov r16,r17
	; Send command to LCD
	call LCD_Send_Command
ret

LCD_Move_Cursor_Second:
	cpi r16,1 ;check if second row
	brne LCD_Move_Cursor_Exit ;else exit
	andi r17, 0x0F
	ori r17,0xC0
	mov r16,r17
	; Send command to LCD
	call LCD_Send_Command
	LCD_Move_Cursor_Exit:
	; Return from function
ret
 
.equ LCDPORT = PORTA      	; Set signal port reg to PORTA
.equ LCDPORTDIR = DDRA    	; Set signal port dir reg to PORTA
.equ LCDPORTPIN = PINA   	; Set clear signal port pin reg to PORTA
.equ LCD_RS = PINA0
.equ LCD_RW = PINA1
.equ LCD_EN = PINA2
.equ LCD_D7 = PINA7
.equ LCD_D6 = PINA6
.equ LCD_D5 = PINA5
.equ LCD_D4 = PINA4
 
DELAY_10MS:
 	LDI R21,80 ;1MC
	L1: LDI R20,250 ;1MC
	L2: DEC R20 ;1MC
	NOP ;1MC
	BRNE L2 ;2/1MC
	DEC R21 ;1MC
	BRNE L1 ;2/1MC
	RET ;4MC
 
LCD_Send_Command:
	push r17
	call LCD_wait_busy  	; check if LCD is busy
	mov r17,r16         	;save the command
	; Set RS low to select command register
	; Set RW low to write to LCD
	andi r17,0xF0
	; Send command to LCD
	out LCDPORT, r17
	nop
	nop
	; Pulse enable pin
	sbi LCDPORT, LCD_EN
	nop
	nop
	cbi LCDPORT, LCD_EN
	swap r16
	andi r16,0xF0
	; Send command to LCD
	out LCDPORT, r16
	; Pulse enable pin
	sbi LCDPORT, LCD_EN
	nop
	nop
	cbi LCDPORT, LCD_EN
	pop r17
ret
 
LCD_Send_Data:
	push r17
	call LCD_wait_busy        	;check if LCD is busy
	mov r17,r16 ;save the command
	; Set RS high to select data register
	; Set RW low to write to LCD
	andi r17,0xF0
	ori r17,0x01
	; Send data to LCD
	out LCDPORT, r17
	nop
	; Pulse enable pin
	sbi LCDPORT, LCD_EN
	nop
	cbi LCDPORT, LCD_EN
	; Delay for command execution
	;send the lower nibble
	nop
	swap r16
	andi r16,0xF0
	; Set RS high to select data register
	; Set RW low to write to LCD
	andi r16,0xF0
	ori r16,0x01
	; Send command to LCD
	out LCDPORT, r16
	nop
	; Pulse enable pin
	sbi LCDPORT, LCD_EN
	nop
	cbi LCDPORT, LCD_EN
	pop r17
ret
 
LCD_wait_busy:
	push r16
	ldi r16, 0b00000111       	; set PA7-PA4 as input, PA2-PA0 as output
	out LCDPORTDIR, r16
	ldi r16,0b11110010        	; set RS=0, RW=1 for read the busy flag
	out LCDPORT, r16
	nop
	LCD_wait_busy_loop:
	sbi LCDPORT, LCD_EN
	nop
	nop
	in r16, LCDPORTPIN
	cbi LCDPORT, LCD_EN
	nop
	sbi LCDPORT, LCD_EN
	nop
	nop
	cbi LCDPORT, LCD_EN
	nop
	andi r16,0x80
	cpi r16,0x80
	breq LCD_wait_busy_loop
	ldi r16, 0b11110111       	; set PA7-PA4 as output, PA2-PA0 as output
	out LCDPORTDIR, r16
	ldi r16,0b00000000        	; set RS=0, RW=1 for read the busy flag
	out LCDPORT, r16
	pop r16
ret
