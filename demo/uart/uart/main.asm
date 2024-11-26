.ORG 0x00
RJMP MAIN
.ORG 0x40

MAIN: 
    LDI R21,HIGH(RAMEND)     ; Initialize high byte of SP
    OUT SPH,R21
    LDI R21,LOW(RAMEND)      ; Initialize low byte of SP
    OUT SPL,R21
    
    LDI R16,0x00             ; Set PD0 as input
    OUT DDRD,R16
    LDI R16,0xFF             ; Set PORTB as output
    OUT DDRB,R16
    
    RCALL USART_INIT
    
AGAIN: 
    RCALL USART_REC

    CPI R16,'a'              ; Compare received data with ASCII 'a'
    BRCS CHECK_UPPERCASE     ; If data < 'a', branch to CHECK_UPPERCASE
    CPI R16,'z'+1            ; Compare received data with ASCII 'z' + 1
    BRCS LOWCASE             ; If data < 'z'+1, branch to LOWCASE
    RJMP AGAIN

CHECK_UPPERCASE:
    CPI R16,'A'              ; Compare received data with ASCII 'A'
    BRCS AGAIN               ; If data < 'A', branch to AGAIN
    CPI R16,'Z'+1            ; Compare received data with ASCII 'Z' + 1
    BRCS UPPERCASE           ; If data <= 'Z', branch to UPPERCASE
    RJMP AGAIN

LOWCASE:
    SUBI R16,0x20            ; Convert lowercase to uppercase: uppercase = lowercase - 0x20

UPPERCASE:
    MOV R18,R16              ; Prepare data to be transmitted
	OUT PORTB, R18
    RCALL USART_TRANS
    RJMP AGAIN

; Subroutine to initialize USART
USART_INIT:
    LDI R16,(1<<TXEN0)|(1<<RXEN0) ; Enable USART0 TX and RX
    STS UCSR0B,R16
    LDI R16,(1<<UCSZ01)|(1<<UCSZ00) ; 8-bit data
    STS UCSR0C, R16           ; No parity, 1 stop bit
    LDI R16,0
    STS UBRR0H,R16
    LDI R16,51                ; baudrate=9600, fosc=8MHz
    STS UBRR0L,R16
    RET

; Subroutine to transmit a character
USART_TRANS:
    LDS R17,UCSR0A
    SBRS R17,UDRE0            ; Wait for UDRE0 flag to set (transmit buffer empty)
    RJMP USART_TRANS
    STS UDR0,R18              ; Transmit character
    RET

; Subroutine to receive a character
USART_REC:
    LDS R17,UCSR0A
    SBRS R17,RXC0             ; Wait for RXC0 flag to set (receive complete)
    RJMP USART_REC
    LDS R16,UDR0              ; Receive character
    RET
