
/*#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint8_t button_count = 0;  
volatile uint8_t button_pressed = 0; 

void init_ports() {
	DDRA &= ~(1 << PA0);   
	PORTA |= (1 << PA0);   
	
	DDRC = 0xFF;          
	PORTC = 0x00;          
}

void init_interrupts() {
	// pin change interrupt for PA0
	PCICR |= (1 << PCIE0);  // pin change interrupt for PCINT[7:0]
	PCMSK0 |= (1 << PCINT0); // Enabl pin change interrupt for PA0 (PCINT0)
	
	sei(); // Enable global interrupts
}

ISR(PCINT0_vect) {
	if (!(PINA & (1 << PA0))) { // Check if button is pressed (active low)
		_delay_ms(50); // Simple debouncing (delay)
		if (!(PINA & (1 << PA0))) { // Check again after debouncing
			if (!button_pressed) { // Check if button was previously released
				button_pressed = 1; // Mark button as pressed
				button_count++; // Increment button count
				PORTC = button_count; // Output count to PORTC
			}
		}
		} else {
		button_pressed = 0; // Reset button state when released
	}
}

int main(void) {
	init_ports();
	init_interrupts();

	while (1) {
		// Main loop does nothing, all work done in ISR
	}
	
	return 0;
}
*/

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint8_t button_count = 0;
volatile uint8_t button_pressed = 0;

void init_ports() {
	DDRB &= ~(1 << PB0);
	PORTB |= (1 << PB0);
	
	DDRC = 0xFF;
	PORTC = 0x00;
}

void init_interrupts() {
	// pin change interrupt for PA0
	PCICR |= (1 << PCIE0) | (1<<PCIE1) ;  // pin change interrupt for PCINT[7:0]
	PCMSK1 |= (1 << PCINT8); // Enabl pin change interrupt for PA0 (PCINT0)
	
	sei(); // Enable global interrupts
}

ISR(PCINT1_vect) {
	if (!(PINB & (1 << PB0))) { // Check if button is pressed (active low)
		_delay_ms(50); // Simple debouncing (delay)
		if (!(PINB & (1 << PB0))) { // Check again after debouncing
			if (!button_pressed) { // Check if button was previously released
				button_pressed = 1; // Mark button as pressed
				button_count++; // Increment button count
				PORTC = button_count; // Output count to PORTC
			}
		}
		} else {
		button_pressed = 0; // Reset button state when released
	}
}

int main(void) {
	init_ports();
	init_interrupts();

	while (1) {
		// Main loop does nothing, all work done in ISR
	}
	
	return 0;
}