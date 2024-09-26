//make delay 20ms = 20 000 us 
//fosc = 8MHz -> 1mc = 1/8Mhz = 125 ns

.equ set_output = ddrd
.equ output = portd



setup:
	ldi r16, 0xff
	out set_output, r16

loop:
	ldi r16, 0x00
	out output, r16
	rcall delay
	ldi r16, 0xff
	out output, r16
	rcall delay

rjmp loop



delay:
	ldi r18, 160
	time_loop2:
	ldi r17, 250
	time_loop:	 
	nop
	dec r17
	brne time_loop
	dec r18
	brne time_loop2
	ret