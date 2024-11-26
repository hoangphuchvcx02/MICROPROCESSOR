; C?u hình ADC v?i ch? ?? Free Running và Auto Trigger
.EQU ADC_PORT=PORTA
.EQU ADC_DR=DDRA
.EQU ADC_IN=PINA
.EQU LCD=PORTB ;PORTB data
.EQU LCD_IN=PINB
.EQU LCD_DR=DDRB
.EQU CONT=PORTB 
.EQU CONT_DR=DDRB
.EQU CONT_OUT=PORTB ;
.EQU CONT_IN=PINB ;
.EQU RS=0 ;bit RS
.EQU RW=1 ;bit RW
.EQU E=2 ;bit E
.EQU BCD_BUF=0X200 ;SRAM head address stores BCD number (result converted from 16 bit number)
.DEF OPD1_L=R24 ;byte low of binary number 16bit 
.DEF OPD1_H=R25 ;byte high of binary number 16bit 
.DEF OPD2=R22
.DEF OPD3=R23
.DEF COUNT=R18
.DEF TEMP_L=R16 ; l?u giá tr? ADC c?a LM35
.DEF TEMP_H=R17 ; l?u giá tr? ADC c?a LM35

.ORG 0
RJMP MAIN
.ORG 0X40

MAIN:
LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16

LDI R16, 0xFF ; PortB, C output
OUT DDRB, R16
OUT DDRC, R16
LDI R16, 0x00 ; PortA input
OUT ADC_DR, R16
OUT PORTD, R16 ; output = 0x00
OUT PORTB, R16

; C?u hình ADC trong ch? ?? Free Running và Auto Trigger
LDI R16, 0b01000000 ; Vref=AVcc=5V, SE ADC0
STS ADMUX, R16 ; ADC0, m?c ??nh là chuy?n t? 0
LDI R16, 0b11100111 ; ADC Enable, Start Conversion, Auto Trigger, Free Running Mode
STS ADCSRA, R16 ; C?u hình ADC Control & Status Register A

LDI R16, 0b00000000 ; ADC prescaler 64, t?c ?? m?u ADC
STS ADCSRB, R16 ; Không s? d?ng Trigger

; G?i hàm kh?i t?o UART và LCD
RCALL SETUART
RCALL INIT_LCD4

START:
; Ch? quá trình chuy?n ??i ADC hoàn t?t
LDS R16, ADCSRA
SBRS R16, ADIF ; N?u ch?a hoàn t?t chuy?n ??i, ch?
RJMP START ; Ch?a hoàn t?t, quay l?i

; ??c giá tr? t? ADC
LDS R0, ADCL ; ??c byte th?p ADC
LDS R1, ADCH ; ??c byte cao ADC
MOV TEMP_L, R0
MOV TEMP_H, R1

; Ki?m tra n?u nhi?t ?? > 10 ?? (??n gi?n b?ng so sánh giá tr? ADC)
LDI R16, 0x20 ; N?u ADC tr? v? giá tr? t??ng ?ng v?i nhi?t ?? > 10°C (giá tr? tham chi?u)
CP TEMP_L, R16 ; So sánh byte th?p c?a ADC v?i giá tr? tham chi?u
BRGE TEMPERATURE_OK ; N?u > 10°C, ?i?u ki?n th?a mãn

; N?u < 10°C, PB0 = 0
CBI PORTB, 0 ; T?t PB0 (Set PB0 = 0)

RJMP DISPLAY_TEMP

TEMPERATURE_OK:
; N?u > 10°C, PB0 = 1
SBI PORTB, 0 ; B?t PB0 (Set PB0 = 1)

DISPLAY_TEMP:
; Hi?n th? nhi?t ?? lên LCD
LDI R17, 'T' ; T?i v? trí ??u hi?n th? ch? 'T'
RCALL OUT_LCD4

LDI R17, 'E' ; Ch? 'E'
RCALL OUT_LCD4

LDI R17, 'M' ; Ch? 'M'
RCALL OUT_LCD4

LDI R17, 'P' ; Ch? 'P'
RCALL OUT_LCD4

; Chuy?n ??i giá tr? ADC thành nhi?t ?? và hi?n th?
; Chuy?n ??i giá tr? ADC t? LM35 (gi? s? m?i ?? C t??ng ?ng v?i 10mV, và ADC cho phép ?o giá tr? t? 0-1023)
; ADC0 cho phép ??c t? 0-5V, n?u LM35 có ?? phân gi?i 10mV/°C

RCALL HEX_ASC ; Chuy?n ??i giá tr? t? ADC (TEMP_L) sang ASCII
MOV R17, R18
RCALL OUT_LCD4

RCALL HEX_ASC ; Chuy?n ??i ph?n th?p phân (n?u c?n thi?t)
MOV R17, R18
RCALL OUT_LCD4

LDI R17, 10 ; Chuy?n sang dòng m?i
RCALL OUT_LCD4

; Ch? 1s r?i ??c l?i giá tr? ADC
RCALL DELAY1S
RJMP START

; Hàm xu?t LCD
OUT_LCD4:
    LDI R16, 1
    RCALL DELAY_US
    IN R16, CONT
    ANDI R16, (1 << RS)
    PUSH R16
    PUSH R17
    ANDI R17, $F0
    OR R17, R16
    RCALL OUT_LCD
    LDI R16, 1
    RCALL DELAY_US
    POP R17
    POP R16
    SWAP R17
    ANDI R17, $F0
    OR R17, R16
    RCALL OUT_LCD
    RET

; Hàm chuy?n ??i hex sang ASCII
HEX_ASC:
    CPI R17, 0X0A
    BRCS NUM
    LDI R18, 0X37
    RJMP CHAR
NUM:
    LDI R18, 0X30
CHAR:
    ADD R18, R17
    RET

; Hàm ch? 1s
DELAY1S:
    LDI R16, 200
    LP_1: LDI R17, 160
    LP_2: LDI R18, 50
    LP_3: DEC R18
    NOP
    BRNE LP_3
    DEC R17
    BRNE LP_2
    DEC R16
    BRNE LP_1
    RET

SETUART:
    LDI R16, (1 << TXEN0) ; Phát
    STS UCSR0B, R16
    LDI R16, (1 << UCSZ01) | (1 << UCSZ00) ; 8-bit data, no parity, 1 stop bit
    STS UCSR0C, R16
    LDI R16, 0x00
    STS UBRR0H, R16
    LDI R16, 51 ; Baud rate 9600
    STS UBRR0L, R16
    RET


OUT_LCD:
	OUT LCD,R17 ;
	SBI CONT,E ;
	CBI CONT,E ;2MC,PWEH=2MC=250ns,tDSW=3MC=375ns
	RET
RESET_LCD:
	LDI R16,250 ;delay 25ms
	RCALL DELAY_US ;ctc delay 100?sxR16
	LDI R16,250 ;delay 25ms
	RCALL DELAY_US ;ctc delay 100?sxR16
	CBI CONT,RS ;RS=0 write command
	LDI R17,$30 ;command =$30  1st
	RCALL OUT_LCD
	LDI R16,42 ;delay 4.2ms
	RCALL DELAY_US
	CBI CONT,RS
	LDI R17,$30 ;command=$30 2nd
	RCALL OUT_LCD
	LDI R16,2 ;delay 200ms
	RCALL DELAY_US
	CBI CONT,RS
	LDI R17,$32 ;command=$32
	RCALL OUT_LCD4
	RET


INIT_LCD4:
	CBI CONT,RS ;RS=0 
	LDI R17,$24 ;Function set - communicate  4 bit, 1 line, font 5x8
	RCALL OUT_LCD4
	CBI CONT,RS ;RS=0 ghi 
	LDI R17,$01 ;Clear display
	RCALL OUT_LCD4
	LDI R16,20 ;ch? 2ms after Clear display
	RCALL DELAY_US
	CBI CONT,RS ;RS=0 
	LDI R17,$0C ;Display on/off control
	RCALL OUT_LCD4
	CBI CONT,RS ;RS=0 
	LDI R17,$06 ;Entry mode set
	RCALL OUT_LCD4
	RET	

DELAY_US:
	PUSH R15
	PUSH R14
	MOV R15,R16 ;1MC input data cho R15
	LDI R16,200 
	L1:
	MOV R14,R16 ;1MC set data cho R14
	L2:
	DEC R14 ;1MC
	NOP ;1MC
	BRNE L2 ;2/1MC
	DEC R15 ;1MC
	BRNE L1 ;2/1MC
	POP R14
	POP R15
	RET ;4MC
DELAY: ;1s=32*250*250
	LDI R25,32
	LP3: LDI R26,250
	LP2: LDI R27,250
	LP1: NOP
	DEC R27
	BRNE LP1
	DEC R26
	BRNE LP2
	DEC R25
	BRNE LP3
	RET
