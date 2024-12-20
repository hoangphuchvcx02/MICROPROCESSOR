//Fosc = 0.125uS
// 10ms => 200 STEP => 50us = 400 MC
//	NOP: 1 cycle
//	DEC R20: 1 cycle
//	BRNE DELAY_LOOP: 2 cycles when branching, 1 cycle when not 
// Number�of�iterations= 400/4 = 100
.EQU DELAY_CONST = 100 ; Number of iterations for the delay loop to achieve 50 �s

.ORG 0
RJMP MAIN
.ORG 0x40

MAIN:
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16

    ; Set PB4 (OC0B) as output
    LDI R16, 0x10
    OUT DDRB, R16

    ; Configure Timer0 for Fast PWM mode, non-inverting, prescaler 64
    LDI R16, 0b00100011
    OUT TCCR0A, R16
    LDI R16, 0b00000011
    OUT TCCR0B, R16

    ; Initial duty cycle 0%
    LDI R16, 0x00
    OUT OCR0B, R16

INCREASE_DUTY:
    ; Increase duty cycle from 0% to 100%
    LDI R18, 0
    LDI R19, 255

INCREASE_LOOP:
    OUT OCR0B, R18
    RCALL DELAY
    INC R18
    CP R18, R19
    BRNE INCREASE_LOOP

DECREASE_DUTY:
    ; Decrease duty cycle from 100% to 0%
    LDI R18, 255
    LDI R19, 0

DECREASE_LOOP:
    OUT OCR0B, R18
    RCALL DELAY
    DEC R18
    CP R18, R19
    BRNE DECREASE_LOOP

    RJMP INCREASE_DUTY

DELAY:
    ; Simple delay loop to achieve the correct timing
    LDI R20, DELAY_CONST
DELAY_LOOP:
    NOP
    DEC R20
    BRNE DELAY_LOOP
    RET
