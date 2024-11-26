; Initialize registers
ldi r16, 0x07        ; Load 0x07 into r16 (the multiplier)
mov r2, r16
ldi r18, 0x00        ; Clear r18 (used to store the low byte of the result)
ldi r19, 0x00        ; Clear r19 (used to store the high byte of the result)
ldi ZL, 0xE8         ; Load 0xE8 into ZL (low byte of 1000 in decimal)
ldi ZH, 0x03         ; Load 0x03 into ZH (high byte of 1000 in decimal, 1000 = 0x03E8)
//ldi r20, 0x03        ; Load 0x03 into r20 (for comparing loop count with ZH)
andi r17, 0x00
mov r1, r17

loop_mul:
    add r18, r2     ; Add r16 to r18 (accumulator low byte)
    adc r19, r1      ; Add the carry to r19 (accumulator high byte)
    sbiw ZL, 1       ; Subtract 1 from Z (16-bit decrement of Z register pair)
    cpi ZH, 0x00     ; Compare ZH with 0
    cpc ZL, r0       ; Compare ZL with 0 with carry (check if Z is 0x0000)
    brne loop_mul    ; If Z is not zero, repeat the loop
end:
    rjmp end         ; Infinite loop to end the program

