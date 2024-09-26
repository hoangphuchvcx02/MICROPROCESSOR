.org 0x0000 ; interrupt vector table
rjmp start
.org INT_VECTORS_SIZE
 
.equ LCDPORT = PORTA ; Set signal port reg to PORTA
.equ LCDPORTDIR = DDRA ; Set signal port dir reg to PORTA
.equ LCDPORTPIN = PINA ; Set clear signal port pin reg to PORTA
.equ LCD_RS = PINA0
.equ LCD_RW = PINA1
.equ LCD_EN = PINA2
.equ LCD_D7 = PINA7
.equ LCD_D6 = PINA6
.equ LCD_D5 = PINA5
.equ LCD_D4 = PINA4
.def LCDData = r16
message: .db "0xff nopressed",0
 
; Replace with your application code
; ATmega324PA keypad scan function
; Scans a 4x4 keypad connected to PORTB
;C3-C0 connect to PB3-PB0
;R3-R0 connect to PB7-PB4
; Returns the key value (0-15) or 0xFF if no key is pressed
 
start:
            	ldi r16, 0xff
            	out ddrc, r16
				out ddrd, r16
                call LCD_Init
 
    	
loop:       	
            	call keypad_scan
            	out portc, r23
            	cp r23, r25
            	breq loop
            	mov r25, r23
            	ldi r16, 0x01 ; Clear Display
            	call LCD_Send_Command
            	ldi r16, 0x80 ; Clear Display
            	call LCD_Send_Command
            	cpi r23, 0xff
            	brne key_pressed
            	ldi ZH, high(message) ; point to the information that is to be displayed
            	ldi ZL, low(message)
            	call LCD_Send_String
            	rjmp loop
 
key_pressed:            	
            	cpi r23, 10
            	brlo less_than_A
            	ldi r24, 7
                add r23, r24
less_than_A:
            	ldi r24, 48
            	add r23, r24
            	mov r16, r23
				call send_barled
            	call LCD_Send_Data
            	rjmp loop
 


 send_barled:
	out portd, r16
	ret

; Replace with your application code
; ATmega324PA keypad scan function
; Scans a 4x4 keypad connected to PORTB
;C3-C0 connect to PB3-PB0
;R3-R0 connect to PB4-PB7
; Returns the key value (0-15) or 0xFF if no key is pressed
 
keypad_scan:
            	ldi r20, 0b00001111 ; set upper 4 bits of PORTB as input with pull-up, lower 4 bits as output
            	out DDRB, r20
            	ldi r20, 0b11111111 ; enable pull up resistor
            	out PORTB, r20
            	ldi r22, 0b11110111 ; initial col mask
            	ldi r23, 0 ; initial pressed row value
            	ldi r24,3 ;scanning col index
keypad_scan_loop:
            	out PORTB, r22 ; scan current col
            	nop ;need to have 1us delay to stablize
                sbic PINB, 4 ; check row 0
            	rjmp keypad_scan_check_col2
            	rjmp keypad_scan_found ; row 0 is pressed
keypad_scan_check_col2:
            	sbic PINB, 5 ; check row 1
            	rjmp keypad_scan_check_col3
                ldi r23, 1 ; row1 is pressed
            	rjmp keypad_scan_found
keypad_scan_check_col3:
            	sbic PINB, 6 ; check row 2
            	rjmp keypad_scan_check_col4
            	ldi r23, 2 ; row 2 is pressed
            	rjmp keypad_scan_found
keypad_scan_check_col4:
            	sbic PINB, 7 ; check row 3
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
 
LCD_Init:
; Set up data direction register for Port A
ldi r16, 0b11110111 ; set PA7-PA4 as outputs, PA2-PA0 as output
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
 
LCD_Send_Command:
push r17
call LCD_wait_busy ; check if LCD is busy
mov r17,r16 ;save the command
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
;nop
;nop
cbi LCDPORT, LCD_EN
pop r17
ret
 
LCD_wait_busy:
push r16
ldi r16, 0b00000111 ; set PA7-PA4 as input, PA2-PA0 as output
out LCDPORTDIR, r16
ldi r16,0b11110010 ; set RS=0, RW=1 for read the busy flag
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
ldi r16, 0b11110111 ; set PA7-PA4 as output, PA2-PA0 as output
out LCDPORTDIR, r16
ldi r16,0b00000000 ; set RS=0, RW=1 for read the busy flag
out LCDPORT, r16
pop r16
ret
 
DELAY_10MS:
            	ldi r21,80 ;1MC
L1:
            	ldi r20,250 ;1MC
L2:
            	dec r20 ;1MC
            	nop ;1MC
            	brne L2 ;2/1MC
            	dec r21 ;1MC
            	brne L1 ;2/1MC
   	         ret ;4MC
 
LCD_Send_Data:
push r17
call LCD_wait_busy ;check if LCD is busy
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
 
 
LCD_Send_String:
push ZH ; preserve pointer registers
push ZL
push LCDData
; fix up the pointers for use with the 'lpm' instruction
lsl ZL ; shift the pointer one bit left for the lpm instruction
rol ZH
; write the string of characters
LCD_Send_String_01:
lpm LCDData, Z+ ; get a character
cpi LCDData, 0 ; check for end of string
breq LCD_Send_String_02 ; done
; arrive here if this is a valid character
call LCD_Send_Data ; display the character
rjmp LCD_Send_String_01 ; not done, send another character
; arrive here when all characters in the message have been sent to the LCD module
LCD_Send_String_02:
pop LCDData
pop ZL ; restore pointer registers
pop ZH
ret
 
