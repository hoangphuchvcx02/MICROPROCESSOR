ldi r16, 0x01
ldi r16,high(ramend)
out sph, r16
ldi r16, low(ramend)
out spl, r16
//out sph,r16

ldi r20, 0x20
push r20
ldi r17, 0x12
push r17
pop r29
pop r30