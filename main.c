#define F_CPU 10000000UL		//constant - frequency of MCU, used for calc of delay time in function _delay_ms
#include <avr/io.h>			//header with input-output registers names (like PORTB)
#include <avr/interrupt.h>	//header with iterrupt functions (ISR), which are avr-gcc specific
typedef unsigned char byte;

ISR ( TIMER0_COMPA_vect ) { // _VECTOR(14)  /* TimerCounter0 Compare Match A */

}

ISR ( SPI_STC_vect ) { //      _VECTOR(17)  /* SPI Serial Transfer Complete */
}

int idle(){//empty loop for interrupts catching
	while(1)
	{asm("nop");}//assembler's one empty instruction
}

int main(){ // program entry point 
	//PORTB SETUP
	//PORTB02 should be HIGH in order to power up SlaveSelect (SS) pin of SPI
	DDRB = 0xFF;
	PORTB = 0xFF;

	//SPI SETUP
	SPCR = 0<<SPIE | 1<<SPE | 1<<DORD | 1<<MSTR | 0<<SPR1 | 0<<SPR0 ; //SPI control register
		//SPIE - enable SPI interrupt
		//SPE - enable SPI
		//DORD -- least significant bit first
		//MSTR -- use this chip as master
		//SPR1 -SPR0 --- master's clock generator rate ( 00 = f_osc /2 );
	SPSR = 1<<SPI2X ;
		//SPI Status register
		//SPI2X -- double SPI speed in SPR1 and SPR2 bytes, making it f_osc/2
	SPDR = 0xFF;//data register

	//CLOCK SETUP. HERE USED TIMER #0
	TCCR0B = 0<<CS02 | 0<<CS01 | 1<<CS00 ;// timer's clock rate
	//TCCR0B - timer's control register B
	//001 - no prescaling
	//010 - clk/8 
	//011 - clk/64
	//100 - clk/256
	//101 - clk/1024
	TIMSK0 = 1<<OCIE0A ;
	//timer interrupt mask register
	//OCIE0A -- enable interrupt A
	OCR0A = 0x01;//value to match timer A

	sei();//enable general interrupt
	idle();//idle loop for interrupts await
}
