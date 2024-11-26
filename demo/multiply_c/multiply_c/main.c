#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>

// Define the CPU frequency for delay functions
#define F_CPU 16000000UL

// Define LCD control pins
#define LCD_RS PB0
#define LCD_RW PB1
#define LCD_E  PB2
#define LCD_D4 PB4
#define LCD_D5 PB5
#define LCD_D6 PB6
#define LCD_D7 PB7

// Function prototypes
void LCD_Command(unsigned char cmnd);
void LCD_Char(unsigned char data);
void LCD_Init(void);
void LCD_String(const char *str);
void LCD_String_P(const char *str);
void LCD_Number(unsigned long num);
char* itoa(int value, char* result, int base);

// Declare a string in program memory
const char result_str[] PROGMEM = "Result: ";

int main(void) {
	// Initialize ports
	DDRA = 0x00; // PORTA as input
	DDRB = 0xFF; // PORTB as output
	LCD_Init();  // Initialize LCD
	
	while(1) {
		unsigned int input_value = PINA; // Read input from PORTA
		unsigned long result = input_value * 1000; // Multiply by 1000
		
		LCD_Command(0x80); // Move cursor to the beginning of the first line
		LCD_String_P(result_str); // Display "Result: " from program memory
		LCD_Number(result); // Display the result
		_delay_ms(500); // Delay to avoid too frequent updates
	}
	
	return 0;
}

void LCD_Command(unsigned char cmnd) {
	PORTB = (PORTB & 0x0F) | (cmnd & 0xF0); // Send upper nibble
	PORTB &= ~ (1<<LCD_RS); // RS = 0 for command
	PORTB &= ~ (1<<LCD_RW); // RW = 0 for write
	PORTB |= (1<<LCD_E); // Enable pulse
	_delay_us(1);
	PORTB &= ~ (1<<LCD_E);

	_delay_us(200);

	PORTB = (PORTB & 0x0F) | (cmnd << 4); // Send lower nibble
	PORTB |= (1<<LCD_E);
	_delay_us(1);
	PORTB &= ~ (1<<LCD_E);
	_delay_ms(2);
}

void LCD_Char(unsigned char data) {
	PORTB = (PORTB & 0x0F) | (data & 0xF0); // Send upper nibble
	PORTB |= (1<<LCD_RS); // RS = 1 for data
	PORTB &= ~ (1<<LCD_RW); // RW = 0 for write
	PORTB |= (1<<LCD_E); // Enable pulse
	_delay_us(1);
	PORTB &= ~ (1<<LCD_E);

	_delay_us(200);

	PORTB = (PORTB & 0x0F) | (data << 4); // Send lower nibble
	PORTB |= (1<<LCD_E);
	_delay_us(1);
	PORTB &= ~ (1<<LCD_E);
	_delay_ms(2);
}

void LCD_Init(void) {
	DDRB = 0xFF; // Configure PORTB as output
	_delay_ms(20);
	
	LCD_Command(0x02); // Initialize LCD in 4-bit mode
	LCD_Command(0x28); // 2 lines, 5x7 matrix
	LCD_Command(0x0C); // Display on, cursor off
	LCD_Command(0x06); // Increment cursor (shift cursor to right)
	LCD_Command(0x01); // Clear display screen
	_delay_ms(2);
}

void LCD_String(const char *str) {
	int i;
	for(i=0; str[i]!=0; i++) {
		LCD_Char(str[i]);
	}
}

void LCD_String_P(const char *str) {
	char c;
	while ((c = pgm_read_byte(str++))) {
		LCD_Char(c);
	}
}

void LCD_Number(unsigned long num) {
	char buffer[11];
	itoa(num, buffer, 10);
	LCD_String(buffer);
}

char* itoa(int value, char* result, int base) {
	// Check that the base is valid
	if (base < 2 || base > 36) {
		*result = '\0';
		return result;
	}

	char* ptr = result, *ptr1 = result, tmp_char;
	int tmp_value;

	do {
		tmp_value = value;
		value /= base;
		*ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz"[35 + (tmp_value - value * base)];
	} while (value);

	// Apply negative sign
	if (tmp_value < 0) *ptr++ = '-';
	*ptr-- = '\0';

	while (ptr1 < ptr) {
		tmp_char = *ptr;
		*ptr-- = *ptr1;
		*ptr1++ = tmp_char;
	}
	return result;
}
