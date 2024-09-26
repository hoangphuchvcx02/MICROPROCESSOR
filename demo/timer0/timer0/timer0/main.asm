; Adds two 16-bit unsigned numbers
; Input:
;   r18:r19 - first 16-bit number
;   r20:r21 - second 16-bit number
; Output:
;   r22:r23 - 16-bit result (r23:r22)

.macro clr_16bit
    clr r22
    clr r23
.endm

start:
    ; Load values into registers
    ldi r18, 0xff ; high byte of first number
    ldi r19, 0xff ; low byte of first number
    ldi r20, 0xda ; high byte of second number
    ldi r21, 0xde ; low byte of second number

    ; Initialize result registers
    clr_16bit

    ; Add low bytes
    add r19, r21  ; r19 = low byte of first number + low byte of second number
    mov r22, r19  ; store the result in r22

    ; Add high bytes with carry
    adc r18, r20  ; r18 = high byte of first number + high byte of second number + carry
    mov r23, r18  ; store the result in r23

    ; End of program (infinite loop)
    nop
    rjmp start
