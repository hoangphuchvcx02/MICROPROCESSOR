#include <avr/io.h>

#define SRAM_ADDR_START 0x0200

void store_decimal_digits(uint16_t value) {
	uint8_t digits[5];
	
	// Chia giá tr? thành t?ng ch? s?
	for (int i = 4; i >= 0; i--) {
		digits[i] = value % 10;  // L?y ch? s? cu?i cùng
		value /= 10;             // Chia cho 10 ?? l?y ch? s? ti?p theo
	}
	
	// L?u các ch? s? vào SRAM
	for (int i = 0; i < 5; i++) {
		*(volatile uint8_t *)(SRAM_ADDR_START + i) = digits[i];
	}
}

int main(void) {
	uint16_t value = 0xFEDC;
	
	store_decimal_digits(value);
	while (1) {
	}
	
	return 0;
}
