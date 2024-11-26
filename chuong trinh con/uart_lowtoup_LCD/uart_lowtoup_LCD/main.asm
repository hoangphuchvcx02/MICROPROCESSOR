.EQU LCD=PORTB ;PORTC giao ti?p bus LCD 16 x 2
.EQU LCD_DR=DDRB
.EQU LCD_IN=PINB
.EQU CONT=PORTB

.EQU RS=0 ;bit RS
.EQU RW=1 ;bit RW
.EQU E=2 ;bit E
.EQU CR=$0D ;m� xu?ng d�ng
.EQU NULL=$00 ;m� k?t th�c
.EQU ENTER=$0D ;m� xu?ng d�ng
.EQU CHR_ROW=16
.DEF CNT_ROW=R20 ;??m s? k� t? m?i h�ng
	LDI R16,0xff
	out ddra,r16


; Replace with your application code
    LDI R16,HIGH(RAMEND) ;??a stack l�n v�ng ??a ch? cao
	OUT SPH,R16
	LDI R16,LOW(RAMEND)
	OUT SPL,R16
	LDI R16,0XFF
	
	OUT LCD_DR,R16 ;khai b�o PORTC l� output
	CBI LCD,RS ;RS=PC0=0
	CBI LCD,RW ;RW=PC1=0 truy xu?t ghi
	CBI LCD,E ;E=PC2=0 c?m LCD
	
	RCALL POWER_RESET_LCD4 ;reset c?p ngu?n LCD 4 bit
	RCALL INIT_LCD4
	rcall	USART_Init
	


	;ctc kh?i ??ng LCD 4 bit
	CBI LCD,RS
	;RS=0 ghi l?nh
	LDI R17,0x80 ;con tr? b?t ??u ? ??u d�ng 2
	RCALL OUT_LCD4_2
	LDI R16,1	;ch? 100?s
	RCALL DELAY_US

LOOP: LDI CNT_ROW,CHR_ROW ;s? k� t? tr�n m?i h�ng
AGAIN1: 
	RCALL USART_ReceiveChar ;b?t ??u thu k� t?
	CPI R16,'a'              ; Compare received data with ASCII 'a'
    BRCS CHECK_UPPERCASE     ; If data < 'a', branch to CHECK_UPPERCASE
    CPI R16,'z'+1            ; Compare received data with ASCII 'z' + 1
    BRCS LOWCASE             ; If data < 'z'+1, branch to LOWCASE
	RJMP AGAIN1

	
CHECK_UPPERCASE:
    CPI R16,'A'              ; Compare received data with ASCII 'A'
    BRCS NUMBER               ; If data < 'A', branch to AGAIN
    CPI R16,'Z'+1            ; Compare received data with ASCII 'Z' + 1
    BRCS UPPERCASE           ; If data <= 'Z', branch to UPPERCASE
    RJMP AGAIN1
LOWCASE:
    SUBI R16,0x20            ; Convert lowercase to uppercase: uppercase = lowercase - 0x20

UPPERCASE:
    MOV R18,R16              ; Prepare data to be transmitted
	rcall USART_SendChar
	SBI CONT,RS ;RS=1 ghi data hi?n th? LCD
	MOV R17,R18 ;copy d? li?u xu?t ra LCD
	RCALL OUT_LCD4_2 ;ghi m� ASCII k� t? ra LCD
	LDI R16,1 ;ch? 100?s
	RCALL DELAY_US
	DEC CNT_ROW
	BRNE AGAIN1
	rcall init_lcd4
		RJMP LOOP

NUMBER:
	CPI R16, '0'
	BRCS AGAIN1
	CPI R16, '9' +1
	BRCS DISPLAY_NUM
	RJMP AGAIN1
	DISPLAY_NUM: 
		MOV R3,R16

	rcall init_lcd4
		SBI CONT,RS ;RS=1 ghi data hi?n th? LCD
		LDI R17,0x80 ;con tr? b?t ??u ? ??u d�ng 2
	RCALL OUT_LCD4_2
			MOV R17,R3
	RCALL OUT_LCD4_2 ;ghi m� ASCII k� t? ra LCD
	LDI R16,1 ;ch? 100?s
	RCALL DELAY_US
	RJMP AGAIN1



///////////////////////////////////////////////////
;init UART 0
;CPU clock is 1Mhz
USART_Init:
    ; Set baud rate to 9600 bps with 1 MHz clock
    ldi r16, 51
    sts UBRR0L, r16
   
    ; Set frame format: 8 data bits, no parity, 1 stop bit
    ldi r16, (1 << UCSZ01) | (1 << UCSZ00)
    sts UCSR0C, r16
    ; Enable transmitter and receiver
    ldi r16, (1 << RXEN0) | (1 << TXEN0)
    sts UCSR0B, r16

    ret

;send out 1 byte in r16
USART_SendChar:
	push	r17
    ; Wait for the transmitter to be ready
    USART_SendChar_Wait:
	 lds	r17,	UCSR0A
        sbrs r17, UDRE0	;check USART Data Register Empty bit
        rjmp USART_SendChar_Wait
       sts UDR0, r16		;send out
	pop	r17
    ret


;receive 1 byte in r16
USART_ReceiveChar:
	push	r17
    ; Wait for the transmitter to be ready
    USART_ReceiveChar_Wait:
	 lds	r17,	UCSR0A
        sbrs r17, RXC0	;check USART Receive Complete bit
        rjmp USART_ReceiveChar_Wait

        lds r16, UDR0		;get data
		mov r17, r16 ;THEM VAO LCD
	 pop	r17
 ret


  USART_SendChart_hehe:
	 lds	r17,	UCSR0A
        sbrs r17, UDRE0	;check USART Data Register Empty bit
        rjmp USART_SendChart_hehe
       sts UDR0, r16		;send out
	ret

	;-----------------------------------------------------------------
;C�c l?nh reset c?p ngu?n LCD4 bit
;Ch? h?n 15ms
;Ghi 4 bit m� l?nh 30H l?n 1, ch? �t nh?t 4.1ms
;Ghi 4 bit m� l?nh 30H l?n 2, ch? �t nh?t 100?s

;Ghi byte m� l?nh32H, ch? �t nh?t 100?s sau m?i l?n ghi 4 bit

;-----------------------------------------------------------------
POWER_RESET_LCD4:
LDI R16,200 ;delay 20ms
RCALL DELAY_US ;ctc delay 100?sxR16
;Ghi 4 bit cao m� l?nh 30H l?n 1, ch? 4.2ms
CBI LCD,RS ;RS=0 ghi l?nh
LDI R17,$30 ;m� l?nh=$30 l?n 1,RS=RW=E=0
RCALL OUT_LCD4 ;ctc ghi ra LCD 4 bit cao
LDI R16,42 ;delay 4.2ms
RCALL DELAY_US
;Ghi 4 bit cao m� l?nh 30H l?n 2, ch? 200?s
CBI LCD,RS ;RS=0 ghi l?nh
LDI R17,$30 ;m� l?nh=$30 l?n 2
RCALL OUT_LCD4 ;ctc ghi ra LCD 4 bit cao
LDI R16,2 ;delay 200?s
RCALL DELAY_US
;Ghi byte m� l?nh 32H
CBI LCD,RS ;RS=0 ghi l?nh
LDI R17,$32
RCALL OUT_LCD4_2; ctc ghi 1 byte, m?i l?n 4 bit
RET

;-----------------------------------------------------------------
;INIT_LCD4 kh?i ??ng LCD ghi 4 byte m� l?nh
;Function set: 0x28: 4 bit, 2 d�ng font 5x8
;Clear display: 0x01: x�a m�n h�nh
;Display on/off control: 0x0C: m�n h�nh on, con tr? off
;Entry mode set: 0x06: d?ch ph?i con tr?, ??a ch? DDRAM t?ng 1 khi ghi data
;----------------------------------------------------------------
INIT_LCD4: CBI LCD,RS ;RS=0 ghi l?nh

LDI R17,0x28 ;ch? ?? giao ti?p 4 bit, 2 d�ng font 5x8
RCALL OUT_LCD4_2
;----------------------------------------------------------------
CBI LCD,RS ;RS=0 ghi l?nh
LDI R17,0x01 ;x�a m�n h�nh
RCALL OUT_LCD4_2
LDI R16,20 ;ch? 2ms sau l?nh Clear display
RCALL DELAY_US
;----------------------------------------------------------------
CBI LCD,RS ;RS=0 ghi l?nh
LDI R17,0x0C ;m�n h�nh on, con tr? off
RCALL OUT_LCD4_2
;----------------------------------------------------------------
CBI LCD,RS ;RS=0 ghi l?nh
LDI R17,0x06 ;d?ch ph?i con tr?, ??a ch? DDRAM t?ng 1 khi ghi data
RCALL OUT_LCD4_2
;----------------------------------------------------------------
RET


;--------------------------------------------------
;OUT_LCD4_2 ghi 1 byte m� l?nh/data ra LCD
;chia l�m 2 l?n ghi 4bit: 4 bit cao tr??c, 4 bit th?p sau
;Input: R17 ch?a m� l?nh/data,R16
;bit RS=0/1:l?nh/data,bit RW=0:ghi
;S? d?ng ctc OUT_LCD4
;--------------------------------------------------
OUT_LCD4_2:

IN R16,LCD ;??c PORT LCD
ANDI R16,(1<<RS) ;l?c bit RS
PUSH R16 ;c?t R16
PUSH R17 ;c?t R17
ANDI R17,$F0 ;l?y 4 bit cao
OR R17,R16 ;gh�p bit RS
RCALL OUT_LCD4 ;ghi ra LCD
LDI R16,1 ;ch? 100us
RCALL DELAY_US
POP R17 ;ph?c h?i R17
POP R16 ;ph?c h?i R16
SWAP R17 ;??o 4 bit
;l?y 4 bit th?p chuy?n th�nh cao
ANDI R17,$F0
OR R17,R16 ;gh�p bit RS
RCALL OUT_LCD4;ghi ra LCD
LDI R16,1 ;ch? 100us
RCALL DELAY_US
RET

;--------------------------------------------------
;OUT_LCD4 ghi m� l?nh/data ra LCD
;Input: R17 ch?a m� l?nh/data 4 bit cao ;--------------------------------------------------
OUT_LCD4: 
OUT LCD,R17
SBI LCD,E
CBI LCD,E
RET

;-------------------------------------------------------
;DELAY_US t?o th?i gian tr? =R16x100?s(Fosc=8MHz, CKDIV8 = 1)
;Input:R16 h? s? nh�n th?i gian tr? 1 ??n 255 ;-------------------------------------------------------
DELAY_US: MOV R15,R16 ;1MC n?p data cho R15
LDI R16,200 ;1MC s? d?ng R16
L1: MOV R14,R16 ;1MC n?p data cho R14
L2: DEC R14 ;1MC
NOP ;1MC
BRNE L2 ;2/1MC
DEC R15 ;1MC
BRNE L1 ;2/1MC
RET ;4MC