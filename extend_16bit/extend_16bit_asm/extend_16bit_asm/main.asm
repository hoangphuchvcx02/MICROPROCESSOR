//.include "m8def.inc"    ; Thay th? b?ng file ??nh ngh?a vi ?i?u khi?n c?a b?n

.equ SRAM_ADDR_START = 0x0200


; Ch??ng tr�nh ch�nh
.org 0x0000
rjmp main

main:
    ; Gi� tr? hex c?n chuy?n ??i (v� d?: 0xFEDC)
    ldi r24, 0xDC                  ; Gi� tr? th?p
    ldi r25, 0xFE                  ; Gi� tr? cao

    ; G?i h�m l?u c�c ch? s? v�o SRAM
    rcall store_decimal_digits

    ; V�ng l?p v� h?n
//loop:
  //  rjmp loop                       ; V�ng l?p v� h?n

  ; H�m l?u c�c ch? s? th?p ph�n v�o SRAM
store_decimal_digits:
    ; Input: r24:r25 = value (16-bit)
    ; Output: L?u c�c ch? s? v�o SRAM t? SRAM_ADDR_START
    ; S? d?ng r30:r31 l�m ??a ch? SRAM

    ; Kh?i t?o c�c thanh ghi
    ldi r30, low(SRAM_ADDR_START)   ; ??a ch? SRAM th?p
    ldi r31, high(SRAM_ADDR_START)  ; ??a ch? SRAM cao

    ; Kh?i t?o m?ng ch? s? (5 ch? s?)
    ldi r16, 5                      ; S? ch? s? c?n l?u
    mov r18, r24                    ; sao ch�p gi� tr? v�o r18:r19

store_digits:
    clr r17                         ; x�a r17 ?? ch?a ch? s? hi?n t?i
    ldi r19, 10                     ; chia cho 10

divide_loop:
    cp r24, r19                     ; So s�nh r24 v?i 10
    cpc r25, r18                    ; So s�nh r25 v?i 0
    brlo save_digit                 ; N?u < 10, l?u ch? s?

    subi r24, 10                    ; Tr? 10 t? r24
    sbci r25, 0                     ; Tr? 0 t? r25
    inc r17                         ; T?ng ch? s? hi?n t?i

    rjmp divide_loop                ; L?p l?i

save_digit:
    ; L?u ch? s? v�o SRAM
    st Z, r17                       ; L?u r17 v�o SRAM
    inc r30                         ; T?ng ??a ch? SRAM
    dec r16                         ; Gi?m s? ch? s? c�n l?i
    brne store_digits               ; N?u c�n ch? s?, ti?p t?c l?u

    ; Quay l?i
    ret
