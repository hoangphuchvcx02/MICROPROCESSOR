.equ SRAM_BASE= 0x0200

.org 0x0000
rjmp RESET

RESET:
    ; Initialize the stack pointer (optional, depends on your application)
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    ; Initialize the value to be converted (r17 = 0xFF = 255)
    ldi r17, 0xFF
	ldi r18, 0xEE


    ; Initialize the X register to point to the base address
    ldi r26, low(SRAM_BASE)   ; Load lower byte of SRAM_BASE into X register low byte
    ldi r27, high(SRAM_BASE)  ; Load upper byte of SRAM_BASE into X register high byte
	ldi r28, low(SRAM_BASE+1)   ; Load lower byte of SRAM_BASE into X register low byte
    ldi r29, high(SRAM_BASE+1)  ; Load upper byte of SRAM_BASE into X register high byte

    ; Convert the value in r17 to decimal digits
    ; Step 1: Extract hundreds place
    ldi r18, 100
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

    ; End of the program
end:    rjmp end

; Divide subroutine: divides r17 by r18, result in r19, remainder in r17
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
