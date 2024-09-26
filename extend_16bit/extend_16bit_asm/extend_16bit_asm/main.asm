//.include "m8def.inc"    ; Thay th? b?ng file ??nh ngh?a vi ?i?u khi?n c?a b?n

.equ SRAM_ADDR_START = 0x0200


; Ch??ng trình chính
.org 0x0000
rjmp main

main:
    ; Giá tr? hex c?n chuy?n ??i (ví d?: 0xFEDC)
    ldi r24, 0xDC                  ; Giá tr? th?p
    ldi r25, 0xFE                  ; Giá tr? cao

    ; G?i hàm l?u các ch? s? vào SRAM
    rcall store_decimal_digits

    ; Vòng l?p vô h?n
//loop:
  //  rjmp loop                       ; Vòng l?p vô h?n

  ; Hàm l?u các ch? s? th?p phân vào SRAM
store_decimal_digits:
    ; Input: r24:r25 = value (16-bit)
    ; Output: L?u các ch? s? vào SRAM t? SRAM_ADDR_START
    ; S? d?ng r30:r31 làm ??a ch? SRAM

    ; Kh?i t?o các thanh ghi
    ldi r30, low(SRAM_ADDR_START)   ; ??a ch? SRAM th?p
    ldi r31, high(SRAM_ADDR_START)  ; ??a ch? SRAM cao

    ; Kh?i t?o m?ng ch? s? (5 ch? s?)
    ldi r16, 5                      ; S? ch? s? c?n l?u
    mov r18, r24                    ; sao chép giá tr? vào r18:r19

store_digits:
    clr r17                         ; xóa r17 ?? ch?a ch? s? hi?n t?i
    ldi r19, 10                     ; chia cho 10

divide_loop:
    cp r24, r19                     ; So sánh r24 v?i 10
    cpc r25, r18                    ; So sánh r25 v?i 0
    brlo save_digit                 ; N?u < 10, l?u ch? s?

    subi r24, 10                    ; Tr? 10 t? r24
    sbci r25, 0                     ; Tr? 0 t? r25
    inc r17                         ; T?ng ch? s? hi?n t?i

    rjmp divide_loop                ; L?p l?i

save_digit:
    ; L?u ch? s? vào SRAM
    st Z, r17                       ; L?u r17 vào SRAM
    inc r30                         ; T?ng ??a ch? SRAM
    dec r16                         ; Gi?m s? ch? s? còn l?i
    brne store_digits               ; N?u còn ch? s?, ti?p t?c l?u

    ; Quay l?i
    ret
