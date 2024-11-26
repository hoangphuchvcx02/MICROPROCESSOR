#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>

#define F_CPU 1000000UL // Clock Frequency
#define BAUD 9600
#define UBRR_VALUE ((F_CPU / (16UL * BAUD)) - 1)

// LCD Pins and Ports
#define LCD_PORT PORTB
#define LCD_DDR DDRB
#define RS 0
#define RW 1
#define E 2

// Function Prototypes
void init_adc();
void init_uart();
void uart_transmit(char data);
void uart_transmit_string(const char* str);
void init_lcd();
void send_command_lcd(uint8_t cmd);
void send_data_lcd(uint8_t data);
void display_voltage_on_lcd(float voltage);
uint16_t read_adc();

int main() {
	// Initialize ADC, UART, and LCD
	init_adc();
	init_uart();
	init_lcd();

	char uart_buffer[16]; // Buffer for UART transmission

	while (1) {
		// Read ADC value
		uint16_t adc_value = read_adc();

		// Convert ADC value to voltage (assuming Vref = 5V)
		float voltage = (adc_value * 5.0) / 1023.0;

		// Transmit ADC value (hex) via UART
		snprintf(uart_buffer, sizeof(uart_buffer), "ADC HEX: %04X\r\n", adc_value);
		uart_transmit_string(uart_buffer);

		// Display voltage on LCD
		send_command_lcd(0x01); // Clear LCD
		_delay_ms(2);
		display_voltage_on_lcd(voltage);

		_delay_ms(1000); // Wait for 1 second
	}
}

void init_adc() {
	// Configure ADC: Vref = AVcc, ADC0 as input
	ADMUX = (1 << REFS0); // AVcc as reference voltage
	ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1); // Enable ADC, prescaler = 64
}

void init_uart() {
	// Configure UART: Baud rate = 9600, 8-bit data, no parity
	UBRR0H = (uint8_t)(UBRR_VALUE >> 8);
	UBRR0L = (uint8_t)(UBRR_VALUE);
	UCSR0B = (1 << TXEN0); // Enable UART transmitter
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00); // 8-bit data
}

void uart_transmit(char data) {
	while (!(UCSR0A & (1 << UDRE0))); // Wait until buffer is empty
	UDR0 = data; // Transmit data
}

void uart_transmit_string(const char* str) {
	while (*str) {
		uart_transmit(*str++);
	}
}

void init_lcd() {
	LCD_DDR = 0xFF; // Configure LCD port as output
	_delay_ms(20);  // Wait for LCD to initialize
	send_command_lcd(0x02); // 4-bit mode
	send_command_lcd(0x28); // 2-line, 5x8 font
	send_command_lcd(0x0C); // Display on, cursor off
	send_command_lcd(0x06); // Increment address, no shift
	send_command_lcd(0x01); // Clear display
	_delay_ms(2);
}

void send_command_lcd(uint8_t cmd) {
	LCD_PORT = (cmd & 0xF0); // Send higher nibble
	LCD_PORT &= ~(1 << RS);  // RS = 0 (command)
	LCD_PORT |= (1 << E);    // Enable pulse
	_delay_us(1);
	LCD_PORT &= ~(1 << E);

	LCD_PORT = (cmd << 4);   // Send lower nibble
	LCD_PORT |= (1 << E);
	_delay_us(1);
	LCD_PORT &= ~(1 << E);

	_delay_ms(2);
}

void send_data_lcd(uint8_t data) {
	LCD_PORT = (data & 0xF0); // Send higher nibble
	LCD_PORT |= (1 << RS);    // RS = 1 (data)
	LCD_PORT |= (1 << E);
	_delay_us(1);
	LCD_PORT &= ~(1 << E);

	LCD_PORT = (data << 4);   // Send lower nibble
	LCD_PORT |= (1 << E);
	_delay_us(1);
	LCD_PORT &= ~(1 << E);

	_delay_ms(2);
}

void display_voltage_on_lcd(float voltage) {
	char buffer[16]; // Buffer for LCD display
	snprintf(buffer, sizeof(buffer), "ADC=%.2f V", voltage);
	for (char* p = buffer; *p; p++) {
		send_data_lcd(*p);
	}
}

uint16_t read_adc() {
	ADCSRA |= (1 << ADSC); // Start ADC conversion
	while (ADCSRA & (1 << ADSC)); // Wait for conversion to complete
	return ADC; // Return ADC result (ADCL + ADCH)
}
