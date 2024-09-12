.def shiftData = r20 ; Define the shift data register
.equ clearSignalPort = PORTB ; Set clear signal port to PORTB
.equ clearSignalPin = 3 ; Set clear signal pin to pin 0 of PORTB
.equ shiftClockPort = PORTB ; Set shift clock port to PORTB
.equ shiftClockPin = 2 ; Set shift clock pin to pin 1 of PORTB
.equ latchPort = PORTB ; Set latch port to PORTB
.equ latchPin = 1 ; Set latch pin to pin 0 of PORTB
.equ shiftDataPort = PORTB ; Set shift data port to PORTB
.equ shiftDataPin = 0 ; Set shift data pin to pin 3 of PORTB
.def temp = r21
main:
call initport
call cleardata

ldi temp, 0x01
LOOP:
    call DELAY_US
    mov shiftData, temp
    call shiftoutdata
    lsl temp
	inc temp
    cpi temp, 0xFF
    brne LOOP

LOOP2:
	call DELAY_US
    mov shiftData, temp
    call shiftoutdata
    lsl temp
	//inc temp
	cpi temp, 0x00
	brne LOOP2


jmp main

; Initialize ports as outputs
initport:
	ldi r24,(1<<clearSignalPin)|(1<<shiftClockPin)|(1<<latchPin)|(1<<shiftDataPin)
	out DDRB, r24 ; Set DDRB to output
	ret
	ldi shiftData,0x55
cleardata:
	cbi clearSignalPort, clearSignalPin ; Set clear signal pin to low
	; Wait for a short time
	sbi clearSignalPort, clearSignalPin ; Set clear signal pin to high
	ret
	; Shift out data
	shiftoutdata:
	cbi shiftClockPort, shiftClockPin ;
	ldi r18, 8 ; Shift 8 bits

shiftloop:
	sbrc shiftData, 7 ; Check if the MSB of shiftData is 1
	sbi shiftDataPort, shiftDataPin ; Set shift data pin to high
	sbi shiftClockPort, shiftClockPin ; Set shift clock pin to high
	lsl shiftData ; Shift left
	call delay_us
	cbi shiftClockPort, shiftClockPin ; Set shift clock pin to low
	cbi shiftDataPort, shiftDataPin ; Set shift data pin to low
	dec r18
	brne shiftloop
	; Latch data
	sbi latchPort, latchPin ; Set latch pin to high
	cbi latchPort, latchPin ; Set latch pin to low
	ret

DELAY_US: MOV R15,R16 ;1MC n?p data cho R15
LDI R16,200 ;1MC s? d?ng R16
L1: MOV R14,R16 ;1MC n?p data cho R14
L2: DEC R14 ;1MC
NOP ;1MC
BRNE L2 ;2/1MC
DEC R15 ;1MC
BRNE L1 ;2/1MC
RET ;4MC