.EQU LCD=PORTB ;PORTC giao ti?p bus LCD 16 x 2
.EQU LCD_DR=DDRB
.EQU LCD_IN=PINB

.EQU RS=0 ;bit RS
.EQU RW=1 ;bit RW
.EQU E=2 ;bit E
.EQU CR=$0D ;m� xu?ng d�ng
.EQU END_CHAR = $20
.EQU NULL=$00 ;m� k?t th�c
.DEF COUNT = R24
.EQU SRAM_BASE =0X0200

.ORG 0
 RJMP MAIN
.ORG 0X40

MAIN: 
LDI R16,HIGH(RAMEND) ;??a stack l�n v�ng ??a ch? cao
OUT SPH,R16
LDI R16,LOW(RAMEND)
OUT SPL,R16
LDI R16,0XFF
OUT LCD_DR,R16 ;khai b�o PORTC l� output
CBI LCD,RS ;RS=PC0=0
CBI LCD,RW ;RW=PC1=0 truy xu?t ghi
CBI LCD,E ;E=PC2=0 c?m LCD


;-------------------------------- ;kh?i t?o LCD g?m:
;reset c?p ngu?n ;c?u h�nh LCD ho?t ??ng ch? ?? 4 bit 
;--------------------------------
RCALL POWER_RESET_LCD4 ;reset c?p ngu?n LCD 4 bit
RCALL INIT_LCD4 ;ctc kh?i ??ng LCD 4 bit
;--------------------------------
LOOP:
CBI LCD,RS;RS=0 ghi l?nh
LDI R17,$80 ;con tr? b?t ??u ? d�ng 1 v? tr� th?4
RCALL OUT_LCD4_2
LDI R16,1;ch? 100?s
RCALL DELAY_US

LDI ZH,HIGH(TAB1<<1);Z tr? ??u b?ng tra k� t?
LDI ZL,LOW(TAB1<<1)
RCALL LINE1
//CBI LCD, RS
	LDI R16, 1
	RCALL DELAY_US
	MOV r17, COUNT
	RCALL STORE_BUFFER
	RCALL GET_BUFFER
	INC COUNT
	RCALL DELAY_US
	RCALL DELAY_US
	RCALL DELAY_US
	RCALL DELAY_US
	RCALL DELAY_US
	RCALL DELAY_US

RJMP HERE



GET_BUFFER:
	LDI XH, HIGH(SRAM_BASE)
	LDI XL, LOW(SRAM_BASE)
	LD R17, X+
	LDI R18, 0X30
	ADD R17, R18
	RCALL OUT_LCD4_2
		LD R17, X+
	LDI R18, 0X30
	ADD R17, R18
	RCALL OUT_LCD4_2
		LD R17, X+
	LDI R18, 0X30
	ADD R17, R18
	RCALL OUT_LCD4_2
RET


STORE_BUFFER:
	LDI XH, HIGH(SRAM_BASE)
	LDI XL, LOW(SRAM_BASE)
	Ldi r18, 100
    mov r19, r17
    rcall DIVIDE            ; r19 = r17 / 100
    st X+, r19              ; Store hundreds place
    ; Step 2: Extract tens place
    ldi r18, 10
    mov r17, r17            ; r17 = r17 - (hundreds place * 100)
    rcall DIVIDE            ; r19 = r17 / 10
    st X+, r19              ; Store tens place
    ; Step 3: Extract units place
    st X, r17               ; Store units place directly

	DIVIDE:
    clr r19
	DIV_LOOP:
		cp r17, r18
		brlo DIV_DONE
		sub r17, r18
		inc r19
		rjmp DIV_LOOP
	DIV_DONE:
ret

LINE1: 
	LPM R17,Z+ ;l?y m� ASCII k� t? t? Flash ROM
	CPI R17, NULL
	BREQ EXIT_LINE1
	SBI LCD,RS;RS=1 ghi data hi?n th? LCD
	RCALL OUT_LCD4_2;ghi m� ASCII k� t? ra LCD
	LDI R16,1;ch? 100?s
	RCALL DELAY_US
	RJMP LINE1;ti?p t?c hi?n th? d�ng1
	EXIT_LINE1: RET

BR_NEWCHAR:
	LDI R17, $C2
	RCALL OUT_LCD4_2
	LDI R17, 0X14
	RCALL OUT_LCD4_2
	LDI R17, 255
	RCALL OUT_LCD4_2
	LDI R16,1
	RCALL DELAY_US
	LDI R16,1
	RCALL DELAY_US
	RET

DOWN: 
	CBI LCD,RS ;RS=0 ghi l?nh
	LDI R17,$C2 ;con tr? b?t ??u ? d�ng 2 v? tr� th? 3
	RCALL OUT_LCD4_2
	LDI R16,1 ;ch? 100?s
	RCALL DELAY_US
LINE2: 
	LPM R17,Z+ ;l?y m� ASCII k� t? t? Flash ROM
	CPI R17,NULL ;ki?m tra k� t? k?t th�c
	BREQ HERE ;k� t? NULL tho�t
	SBI LCD,RS ;RS=1 ghi data hi?n th? LCD
	RCALL OUT_LCD4_2 ;ghi m� ASCII k� t? ra LCD
	LDI R16,1 ;ch? 100?s
	RCALL DELAY_US
	RJMP LINE2 ;ti?p t?c hi?n th? d�ng 2

HERE: RJMP LOOP


;-----------------------------------------------------------------
;C�c l?nh reset c?p ngu?n LCD4 bit
;Ch? h?n 15ms
;Ghi 4 bit m� l?nh 30H l?n 1, ch? �t nh?t 4.1ms
;Ghi 4 bit m� l?nh 30H l?n 2, ch? �t nh?t 100
;Ghi byte m� l?nh
;-----------------------------------------------------------------
POWER_RESET_LCD4:
	LDI R16,200 ;delay 20ms
	RCALL DELAY_US ;ctc delay 100 ?sxR16
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
INIT_LCD4: 
	CBI LCD,RS ;RS=0 ghi l?nh
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
DELAY_US: 
MOV R15,R16 ;1MC n?p data cho R15
LDI R16,200 ;1MC s? d?ng R16
	L1: 
		MOV R14,R16 ;1MC n?p data cho R14
		L2: 
			DEC R14 ;1MC
			NOP ;1MC
			BRNE L2 ;2/1MC
			DEC R15 ;1MC
		BRNE L1 ;2/1MC
RET ;4MC


//.ORG 0X0200
;-------------------------------------------------------------
TAB: .DB "NUM: ",$0D," KHAM   PHUC",$00
TAB1: .DB "NUM: ",$00
TAB2: .DB "NUM: ",$00