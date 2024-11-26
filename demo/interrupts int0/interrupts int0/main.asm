.ORG 0
RJMP MAIN

.ORG 0x14       
RJMP TIMER0_OVF_ISR

MAIN: 
    ; Set up stack pointer
    LDI R20, HIGH(RAMEND)
    OUT SPH, R20
    LDI R20, LOW(RAMEND)
    OUT SPL, R20

    ; Set Timer 0 in normal mode, prescaler = 1024
    LDI R20, 0x00        ; Normal mode
    OUT TCCR0A, R20
    LDI R20, 0x05        ; Prescaler = 1024
    OUT TCCR0B, R20

    ; Enable Timer 0 overflow interrupt

	LDI R16, (1<<TOIE0) ;cho phép ng?t Timer0 tràn
STS TIMSK0, R16
    ; Enable global interrupts
    SEI

    SBI DDRC, 0
    CBI PORTC, 0         

    CBI DDRD, 2         
    SBI PORTD, 2         istor on PD2

    LDI R20, 0xFF
    OUT DDRB, R20

    CLR R24              ; Button press counter (store in PORTB)
    LDI R25, 0           ; Previous button state (0: released, 1: pressed)

HERE: 
    ; Check if button on PD2 is pressed 
    SBIC PIND, 2         ; Skip if PD2 is high (not pressed)
    RJMP BUTTON_PRESSED
    LDI R25, 0
    RJMP HERE

BUTTON_PRESSED:
    CPI R25, 0          
    BRNE HERE            

    INC R24            
    OUT PORTB, R24       ; Output the count to PORTB
    LDI R25, 1           ; Mark the button as currently pressed

    RJMP HERE

////////////////////// Interrupt Service Routine ////////////////

TIMER0_OVF_ISR:
    ; Handle Timer 0 overflow interrupt (1 second delay)
    INC R26                ; Increment overflow counter
    CPI R26, 61            ; Check if 61 overflows (~1 second)
    BRNE EXIT_ISR
    CLR R26                ; Reset overflow counter

    ; Toggle PC0 (LED) to blink every 1 second
    IN R20, PINC           ; Read current state of PORTC
    SBI PINC, 0            ; Toggle PC0 (LED)
	call timer0_ovr_isr

EXIT_ISR:
    RETI
