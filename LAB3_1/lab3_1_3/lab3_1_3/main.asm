.EQU OUTPORT=PORTB
.EQU INPORT=PIND
.EQU SR_ADR=0X100
.ORG 0
RJMP MAIN
.ORG 0X40

MAIN: LDI R16,HIGH(RAMEND)

OUT SPH,R16
LDI R16,LOW(RAMEND)
OUT SPL,R16
LDI R16,0X03
OUT DDRC,R16 ;khai báo PC0,PC1 là output
CBI PORTC,0 ;khóa ngõ ra U2
CBI PORTC,1 ;khóa ngõ ra U3

LDI R16,0XFF
OUT DDRB,R16
LDI R16,0X00
OUT DDRD,R16
LDI R20,0X00
LDI R21,0X00
RCALL SCAN_4LA

START: 
	IN R17,INPORT;??c data
	;ctc chuy?n sang s? BCD
	RCALL BIN8_BCD
	;ctc quét 4 LED
	RCALL SCAN_4LA
	RJMP START
;--------------------------------------------
;SCAN_4LA hi?n th? 4 LED AC b?ng ph??ng pháp quét
;Input: R21,R20=s? BCD nén(ngàn-tr?m),(ch?c-??n v?)
;S? d?ng ctc BCD_UNP tách s? BCD nén thành không nén
;S? d?ng ctc DELAY_US,GET_7SEG
;S? d?ng R17,R18,R19,X
;---------------------------------------------
SCAN_4LA:
	RCALL BCD_UNP ;ctc chuy?n s? BCD nén thành không nén
	LDI R18,4 ;R18 ??m s? l?n quét LED
	LDI R19,0XFE ;mã quét anode b?t ??u LED0 (LED ??n v?)
	LDI XH,HIGH(SR_ADR) ;X tr? ??a ch? ??u SRAM (ví d?: SR_ADR = 0x100)
	LDI XL,LOW(SR_ADR)
	
	LOOP:
		LDI R17,0XFF ;t?t t?t c? các ?èn LED
		OUT OUTPORT,R17
		SBI PORTC,1 ;m? U3 (IC ch?t ?i?u khi?n khóa BJT)
		CBI PORTC,1 ;khóa U3 (IC ch?t ?i?u khi?n khóa BJT)
		LD R17,X+ ;n?p s? BCD t? SRAM
		RCALL GET_7SEG ;l?y mã 7 ?o?n
		OUT OUTPORT,R17 ;xu?t mã 7 ?o?n
		SBI PORTC,0 ;m? U2 (IC ch?t data xu?t ra LED 7 ?o?n)
		CBI PORTC,0 ;khóa U2 (IC ch?t data xu?t ra LED 7 ?o?n)
		OUT OUTPORT,R19 ;xu?t mã quét anode LED
		SBI PORTC,1 ;m? U3 (IC ch?t ?i?u khi?n khóa BJT)
		CBI PORTC,1 ;khóa U3 (IC ch?t ?i?u khi?n khóa BJT)
		RCALL DELAY_US ;t?o tr? 1ms sáng ?èn (th?i gian quét LED)
		SEC ;C=1 chu?n b? quay trái
		ROL R19 ;mã quét anode k? ti?p
		DEC R18 ;??m s? l?n quét
		BRNE LOOP ;thoát khi quét ?? 4 l?n
	RET

BCD_UNP:
	LDI XH,HIGH(SR_ADR) ;X tr? ??a ch? ??u SRAM
	LDI XL,LOW(SR_ADR)
	MOV R17,R20 ;l?y s? BCD nén tr?ng s? th?p
	ANDI R17,0X0F ;l?y s? BCD th?p
	ST X+,R17 ;c?t vào SRAM, t?ng ??a ch? SRAM
	MOV R17,R20 ;l?y l?i s? BCD
	SWAP R17 ;hoán v? 2 s? BCD
	ANDI R17,0X0F ;l?y s? BCD cao
	ST X+,R17 ;c?t vào SRAM, t?ng ??a ch? SRAM
	MOV R17,R21 ;th?c hi?n t??ng t? v?i s? BCD nén c?t trong R21
	ANDI R17,0X0F
	ST X+,R17
	MOV R17,R21
	SWAP R17
	ANDI R17,0X0F
	ST X+,R17
	RET

;------------------------------------------
;GET_7SEG tra mã 7 ?o?n t? data ??c vào
;Input R17=mã Hex,Output R17=mã 7 ?o?n
;------------------------------------------
GET_7SEG:
	LDI ZH,HIGH(TAB_7SA<<1) ;Z tr? ??a ch? ??u b?ng tra mã 7 ?o?n
	LDI ZL,LOW(TAB_7SA<<1) ;trong flash ROM
	ADD R30,R17 ;c?ng offset vào ZL
	LDI R17,0
	ADC R31,R17 ;c?ng carry vào ZH
	LPM R17,Z ;l?y mã 7 ?o?n
	RET

;-------------------------------------------
;BIN8_BCD chuy?n s? nh? phân 8 bit sang s? BCD 3 digit
;Input R17=s? nh? phân 8 bit
;Output R21,R20=s? BCD nén,R21 tr?ng s? cao
;S? d?ng ctc DIV8_8,R16=10 s? chia ;-------------------------------------------
BIN8_BCD:
	CLR R20 ;xóa các thanh ghi k?t qu?
	CLR R21
	LDI R16,10 ;R16=s? chia
	RCALL DIV8_8 ;ctc chia 2 s? nh? phân 8 bit
	MOV R20,R16 ;R20=d? s? phép chia ??u
	LDI R16,10
	RCALL DIV8_8
	SWAP R16 ;chuy?n d? s? phép chia ??u lên cao
	OR R20,R16 ;dán d? s? phép chia l?n 2 vào 4 bit th?p
	MOV R21,R17 ;R21=d? s? sau cùng
	RET

;------------------------------------------- ;DIV8_8 chia 2 s? Hex 8 bit
;Input R17= s? b? chia,R16=s? chia
;Output R17=th??ng s?,R16=d? s?
;S? d?ng R15 ;------------------------------------------
DIV8_8:
	CLR R15 ;R15=th??ng s?
	GT_DV: 
		SUB R17,R16;tr? s? b? chi cho s? chia
		BRCS LT_DV;C=1 không chia ???c
		INC R15;t?ng th??ng s? thêm 1
		RJMP GT_DV;th?c hi?n ti?p
	LT_DV: 
		ADD R17,R16 ;l?y l?i d? s?
		MOV R16,R17 ;R16=d? s?
		MOV R17,R15;R17=th??ng s?
	RET

;-------------------------------------------------------
;DELAY_US t?o th?i gian tr? Td = R16 x 100 (?s) (Fosc=8MHz, CKDIV8 = 1)
;Input:R16 h? s? nhân th?i gian tr? 1 ??n 255
;-------------------------------------------------------
DELAY_US:
	LDI R16,10 ;t?o tr? 1ms
	MOV R15,R16 ;1MC n?p data cho R15
	LDI R16,200 ;1MC s? d?ng R16
	L1: MOV R14,R16 ;1MC n?p data cho R14
	L2: DEC R14 ;1MC
	NOP ;1MC
	BRNE L2 ;2/1MC
	DEC R15 ;1MC
	BRNE L1 ;2/1MC
	RET ;4MC
;----------------------------------------------------
TAB_7SA: .DB 0XC0,0XF9,0XA4,0XB0,0X99,0X92,0X82,0XF8,0X80,0X90,0X88,0X83

.DB 0XC6,0XA1,0X86,0X8E