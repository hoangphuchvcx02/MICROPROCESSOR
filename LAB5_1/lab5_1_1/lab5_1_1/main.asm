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


.ORG 0
RJMP MAIN
.ORG 0X40

MAIN:
LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16

LDI R16, 0xFF ;PortD, C output
OUT DDRB, R16
OUT DDRC, R16
LDI R16, 0x00 ;PortA input
OUT ADC_DR, R16
OUT PORTD, R16 ;output=0x0000
OUT PORTB, R16


LDI R16, 0b01000000 ;Vref=AVcc=5V, SE ADC0 ||mux[4:0]
STS ADMUX, R16 ; x1,shift right
//LDI R16, 0b10000110 ;allow ADC,mode 1 l?n.
LDI R16, 0b11000110 ;allow ADC,mode 1 l?n.
STS ADCSRA, R16 ;f(ADC)=fosc/64=125Khz
	LDI R16, 0b00000000 ;allow ADC,mode 1 l?n.
	STS ADCSRB, R16 ;f(ADC)=fosc/64=125Khz
RCALL SETUART

LDI R16,0X07
OUT CONT_DR,R16 ; PB0,PB1,PB2 là output
CBI CONT,RS ;RS=PB0=0
CBI CONT,RW ;RW=PB1=0  ghi
CBI CONT,E ;E=PB2=0 connect LCD
LDI R16,0XFF
OUT LCD_DR,R16 ;outport

RCALL RESET_LCD ;ctc reset LCD
RCALL INIT_LCD4 ;ctc retset LCD 4 bit

START:
	LDS R16, ADCSRA
	ORI R16, (1<<ADSC) ;start to convert
	STS ADCSRA, R16
WAIT:
	LDS R16, ADCSRA ;read status ADIF
	SBRS R16, ADIF ; ADIF=1 done
	RJMP WAIT ;wait ADIF=1
	STS ADCSRA, R16 ;clear  ADIF
	LDS R1, ADCL ;byte low ADC
	OUT PORTC, R1
	LDS R0, ADCH ;byte high ADC
	OUT PORTD, R0
	LDI R17,'A'
	RCALL PHAT
	LDI R17,'D'
	RCALL PHAT
	LDI R17,'C'
	RCALL PHAT
	LDI R17,':'
	RCALL PHAT
	MOV R17,R0
	RCALL TACHKITU
	MOV R17,R1
	RCALL TACHKITU
	LDI R17,' '
	RCALL PHAT
	LDS R1, ADCL 
	LDS R0, ADCH 
	MOV R17,R0
	MOV R16,R1
	RCALL MUL_MATCH
	RCALL SHIFT_R
	RCALL BIN16_BCD5DG

XUAT_LCD:
	CBI CONT,RS ;RS=0 ghi lenh
	LDI R17,$84 ;pointer start at line 1 
	RCALL OUT_LCD4
	LDI R17,'A'
	SBI CONT,RS
	RCALL OUT_LCD4
	LDI R17,'D'
	SBI CONT,RS
	RCALL OUT_LCD4
	SBI CONT,RS
	LDI R17,'C'
	SBI CONT,RS
	RCALL OUT_LCD4
	LDI R17,':'
	RCALL OUT_LCD4
	LDS R17,0X202 ; XUAT HANG TRAM
	RCALL HEX_ASC
	MOV R17,R18
	SBI CONT,RS
	RCALL OUT_LCD4
	LDI R17,44 ;xuat ','
	SBI CONT,RS
	RCALL OUT_LCD4
	LDS R17,0X203 ; XUAT HANG CHUC
	RCALL HEX_ASC
	MOV R17,R18
	SBI CONT,RS
	RCALL OUT_LCD4
	LDS R17,0X204 ; XUAT HANG DON VI
	RCALL HEX_ASC
	MOV R17,R18
	SBI CONT,RS
	RCALL OUT_LCD4
	LDI R17,'V'
	SBI CONT,RS
	RCALL OUT_LCD4
	LDI R17,10
	SBI CONT,RS
	RCALL OUT_LCD4
	RCALL DELAY1S
	RJMP START 


SETUART:
	LDI R16, (1<<TXEN0) ;phat
	STS UCSR0B, R16
	LDI R16, (1<<UCSZ01)|(1<<UCSZ00)
	;8-bit data, no parity, 1 stop bit
	STS UCSR0C, R16
	LDI R16, 0x00
	STS UBRR0H, R16
	LDI R16, 51 ;9600 baud rate
	STS UBRR0L, R16
	RET


PHAT:
	LDS R16,UCSR0A
	SBRS R16,UDRE0 
	RJMP PHAT 
	STS UDR0,R17 
	RET


DELAY1S:
	LDI R16,200
	LP_1: LDI R17,160
	LP_2: LDI R18,50
	LP_3: DEC R18
	NOP
	BRNE LP_3
	DEC R17
	BRNE LP_2
	DEC R16
	BRNE LP_1
RET

;HEX_ASC converts Hex code to ASCII code
;Input R17=Hex code,Output R18=ASCII code
;------------------------------------------
HEX_ASC:
	CPI R17,0X0A
	BRCS NUM
	LDI R18,0X37
	RJMP CHAR
	NUM: LDI R18,0X30
	CHAR: ADD R18,R17
	RET

TACHKITU :
	MOV R15,R17
	LDI R16,0XF0
	AND R17,R16 ;keep bit high
	SWAP R17
	RCALL HEX_ASC
	MOV R17,R18
	RCALL PHAT
	MOV R17,R15
	ANDI R17,0X0F
	RCALL HEX_ASC
	MOV R17,R18
	RCALL PHAT
	RET

MUL_MATCH:
	LDI R20,250
	MUL R16,R20
	MOV R10,R0
	MOV R11,R1
	MUL R17,R20
	MOV R12,R0
	MOV R13,R1
	ADD R12,R11
	CLR R0
	ADC R13,R0 ;R13:R12:R10
	RET

SHIFT_R:
	LSR R12
	BST R13,0
	BLD R12,7
	LSR R13
	MOV R24,R12
	MOV R25,R13
	RET
;BIN16_BCD5DG converts a 16-bit binary number to a 5-digit BCD number
;Inputs: OPD1_H=R25:OPD1_L=R24 contains a 16-bit binary number
;Outputs: BCD_BUF:BCD_BUF+4: SRAM address contains 5 BCD digits from high to low
;Use R17,COUNT,X,ctc DIV16_8
;---------------------------------------------------------
BIN16_BCD5DG:
	LDI XH,HIGH(BCD_BUF);X points to the address of the beginning of the BCD buffer
	LDI XL,LOW(BCD_BUF)
	LDI COUNT,5 ;count bytes of memory
	LDI R17,0X00 
	LOOP_CL:
		ST X+,R17 ;clear memory buffer
		DEC COUNT ;count 5 byte
		BRNE LOOP_CL
		LDI OPD2,10 ;Load divisor (SC)
	DIV_NXT:
		RCALL DIV16_8 ;Divide a 16-bit binary number by an 8-bit binary number
		ST -X,OPD3 ;Store the balance in buffer
		CPI OPD1_L,0 ;quotient=0?
		BRNE DIV_NXT ;other than 0, divide further
RET
;---------------------------------------
;DIV16_8 divides the 16-bit binary number OPD1 by the 8-bit OPD2 (See division algorithm in Chapter 0)
;Input: OPD1_H,OPD1_L= SBC(GPR16-31)
; OPD2=SC(GPR0-31)
;Output:OPD1_H,OPD1_L=quotient
; OPD3=DS(GPR0-31)
;Use COUNT(GPR16-31)
;---------------------------------------
DIV16_8: 
	LDI COUNT,16 ;COUNT=16
	CLR OPD3 ;delete balance
	SH_NXT: CLC ;C=0=quotient bit
		LSL OPD1_L 
		ROL OPD1_H ;shift left SBC H,bit0=C=quotient
		ROL OPD3 ;Shift bit7 SBC H into the remainder
		BRCS OV_C ;Bit overflow C=1, divisible
		SUB OPD3,OPD2 ;Subtract the remainder from the divisor
		BRCC GT_TH ;C=0 divisible
		ADD OPD3,OPD2 ;C=1 Cannot be divided or subtracted
		RJMP NEXT

	OV_C: SUB OPD3,OPD2 ;Subtract the remainder from the divisor
	GT_TH: SBR OPD1_L,1 ;divisible, quotient=1
	NEXT: DEC COUNT ;count the number of SBC translations
	BRNE SH_NXT ;Not enough to continue shifting bits
RET

OUT_LCD4:
	LDI R16,1
	RCALL DELAY_US
	IN R16,CONT
	ANDI R16,(1<<RS)
	PUSH R16
	PUSH R17
	ANDI R17,$F0
	OR R17,R16
	RCALL OUT_LCD
	LDI R16,1
	RCALL DELAY_US
	POP R17
	POP R16
	SWAP R17
	ANDI R17,$F0
	OR R17,R16
	RCALL OUT_LCD
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
