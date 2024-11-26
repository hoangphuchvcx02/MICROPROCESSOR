#define F_CPU 8000000UL  // T?n s? xung nh?p là 8 MHz
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

#define VREF 5.0           // Vref = 5V
#define ADC_MAX 1023       // Giá tr? t?i ?a c?a ADC 10 bit (2^10 - 1)

void ADC_init() {
	// Ch?n Vref = AVcc và kênh ADC0
	ADMUX = (1 << REFS0);
	// Enable ADC và cho phép ng?t ADC
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1);  // Prescaler = 64
}

uint16_t ADC_read(uint8_t channel) {
	// kênh ADC ( ADC0-ADC7)
	ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);
	// bat dau chuyen
	ADCSRA |= (1 << ADSC);
	// chuyen doi hoàn thành
	while (ADCSRA & (1 << ADSC));
	return ADC;
}

float ADC_to_voltage(uint16_t adc_value) {
	return (adc_value / (float)ADC_MAX) * VREF;
}

void UART_init(unsigned int baud) {
	unsigned int ubrr = F_CPU / 16 / baud - 1;
	UBRR0H = (unsigned char)(ubrr >> 8);
	UBRR0L = (unsigned char)ubrr;
	UCSR0B = (1 << RXEN0) | (1 << TXEN0);
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}

void UART_transmit(unsigned char data) {
	while (!(UCSR0A & (1 << UDRE0)));
	UDR0 = data;
}

void UART_print(const char* str) {
	while (*str) {
		UART_transmit(*str++);
	}
}

void UART_print_hex(uint16_t value) {
	char hex_string[5];
	sprintf(hex_string, "%04X", value);
	UART_print(hex_string);
}

void LCD_send_nibble(uint8_t data) {
	// send dta LCD
	if (data & 0x10) PORTB |= (1 << PB4); else PORTB &= ~(1 << PB4);  // D4
	if (data & 0x20) PORTB |= (1 << PB5); else PORTB &= ~(1 << PB5);  // D5
	if (data & 0x40) PORTB |= (1 << PB6); else PORTB &= ~(1 << PB6);  // D6
	if (data & 0x80) PORTB |= (1 << PB7); else PORTB &= ~(1 << PB7);  // D7

	// (Enable)
	PORTB |= (1 << PB2);  // E = 1 (PB2)
	_delay_us(10);         // Delay nh? ?? LCD nh?n
	PORTB &= ~(1 << PB2); // E = 0 (PB2)
	_delay_us(10);         // Delay nh? ?? LCD nh?n
}

void LCD_send_byte(uint8_t data) {
	// 8bit data to send
	LCD_send_nibble(data & 0xF0);   // G?i nibble cao
	LCD_send_nibble(data << 4);     // G?i nibble th?p
}

void LCD_command(uint8_t cmd) {
	PORTB &= ~(1 << PB0);  // RS = 0 (ch? ?? l?nh)
	PORTB &= ~(1 << PB1);  // RW = 0 (ch? ?? ghi)
	LCD_send_byte(cmd);    // G?i l?nh
}

void LCD_data(uint8_t data) {
	PORTB |= (1 << PB0);   // RS = 1 (ch? ?? d? li?u)
	PORTB &= ~(1 << PB1);  // RW = 0 (ch? ?? ghi)
	LCD_send_byte(data);   // G?i d? li?u
}

void LCD_init() {
	// Set các chân c?a LCD là output
	DDRB |= (1 << PB0) | (1 << PB1) | (1 << PB2) | (1 << PB4) | (1 << PB5) | (1 << PB6) | (1 << PB7);

	_delay_ms(15);  // Delay ban ??u cho LCD

	// LCD 4 bit
	LCD_command(0x02);  //  4 bit
	LCD_command(0x28);  //  2 line, 5x8 font
	LCD_command(0x0C);  //no pointer
	LCD_command(0x06);  // inc pointer
	LCD_command(0x01);  // clear scr
	_delay_ms(2);       
}

void LCD_clear() {
	LCD_command(0x01);  // L?nh xóa màn hình
	_delay_ms(2);       // Delay sau l?nh xóa màn hình
}

void LCD_print(const char* str) {
	while (*str) {
		LCD_data(*str++);
	}
}

int main(void) {
	char buffer[16];
	uint16_t adc_value;
	float voltage;

	// Kh?i t?o ADC, LCD và UART
	ADC_init();
	LCD_init();
	UART_init(9600);  // Baudrate 9600
	
	while(1) {
		//kênh 0 (ADC0)
		adc_value = ADC_read(0);
		
		// Chuy?n giá tr? ADC sang ?i?n áp
		voltage = ADC_to_voltage(adc_value);
		
		// Xóa màn hình LCD và hi?n th? k?t qu?
		LCD_clear();
		snprintf(buffer, 16, "ADC=%.2fV", voltage);
		LCD_print(buffer);
		
		// G?i giá tr? ADC qua UART hex formula
		UART_print("ADC Value (Hex): ");
		UART_print_hex(adc_value);
		UART_print("\r\n");
		
		_delay_ms(1000);
	}
}
