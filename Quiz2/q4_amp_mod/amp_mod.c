/**
 SPI HOMEWORK2 , LABWORK2 (SAME PROGRAM)
 */

/* @section  I N C L U D E S */
#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

int th_0;
int tl_0;
int freq = 50;
int time_period;
int t_val;

void SPI_Init();
void LCD_Init();
void Timer_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);
unsigned char* int_to_string(int val);

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit ONULL = P1^0;
bit transmit_completed= 0;					// To check if spi data transmit is complete
bit offset_null = 0;								// Check if offset nulling is enabled
bit roundoff = 0;
int adcVal=0, avgVal=0, initVal=0, adcValue = 0;
unsigned long out_volt = 0;
int j = 0;
unsigned char serial_data;
unsigned char data_save_high;
unsigned char data_save_low;
unsigned char count=0, i=0;
unsigned char weight[4];
unsigned char voltage[4];
float fweight=0;

sbit pin_tog = P3^3;




/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input  
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */
 
void main(void)
{
	P3 = 0X00;											// Make Port 3 output 
	P2 = 0x00;											// Make Port 2 output 
	P1 &= 0xEF;											// Make P1 Pin4-7 output
	P0 &= 0xF0;											// Make Port 0 Pins 0,1,2 output
	
	SPI_Init();
	LCD_Init();
	Timer_Init();
	
	while(1)												// endless 
	{
		CS_BAR = 0;                 // enable ADC as slave		 
		SPDAT= 0x01;								// Write start bit to start ADC 
		while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 i.e. MSB of SPSTA
		transmit_completed = 0;    	// clear software transfert flag 
		
		SPDAT= 0x80;				// 80H written to start ADC CH0 single ended sampling,refer ADC datasheet
		while(!transmit_completed);	// wait end of transmition 
		data_save_high = serial_data & 0x03 ;  
		transmit_completed = 0;    	// clear software transfer flag 
				
		SPDAT= 0x00;								// 
		while(!transmit_completed);	// wait end of transmition 
		data_save_low = serial_data;
		transmit_completed = 0;    	// clear software transfer flag 
		CS_BAR = 1;                	// disable ADC as slave
		
		adcVal = (data_save_high <<8) + (data_save_low);
		// out_volt = adcVal;
		out_volt = adcVal * 4.883;
		// out_volt = 3000;
		//out_volt = out_volt / 1024;

		if (out_volt >= 3370)
		{
			th_0 = 0xff;
			tl_0 = 0x38;
		}
		else
		{
			if(out_volt >= 1670)
			{
				th_0 = 0xfe;
				tl_0 = 0x0c;
			}
			else
			{
				th_0 = 0xfc;
				tl_0 = 0x18;
			}

		}

		for(j = 0; j < 4; j++)
		{
			voltage[3- j] = out_volt%10 + '0';
			out_volt = out_volt/10;
		}

		LCD_CmdWrite(0x80);
		LCD_StringWrite("Voltage: ",9);
		LCD_StringWrite(voltage,4);
		LCD_StringWrite(" mV",3);

		
		delay_ms(5);
		
  }
}

// void calc_timer_val()
// {
// 	time_period = 1000/freq;
// 	t_val = 256 - time_period;
// 	th_0 = t_val;
// 	// th_0 = t_val/256;
// 	// tl_0 = t_val%256;
// }

void timer_init()
{
	//use timer0 for generating the sq wave signal
	TMOD = 0x01;
	TH0 = th_0;
	TL0 = tl_0;
	EA = 1;
	ET0 = 1;
	TR0 = 1;
}

// unsigned char* int_to_string(int val)
// {
// 	unsigned char str[4];
// 	for(int i = 0; i < 4; i++)
// 	{
// 		str[3- i] = val%10;
// 		val = val/10;
// 	}
// 	return str;
// }

/**
 * FUNCTION_PURPOSE:interrupt
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: transmit_complete is software transfert flag
 */
void it_SPI(void) interrupt 9 /* interrupt address is 0x004B, (Address -3)/8 = interrupt no.*/
{
	switch	( SPSTA )         /* read and clear spi status register */
	{
		case 0x80:	
			serial_data=SPDAT;   /* read receive data */
      transmit_completed=1;/* set software flag */
 		break;

		case 0x10:
         /* put here for mode fault tasking */	
		break;
	
		case 0x40:
         /* put here for overrun tasking */	
		break;
	}
}

void it_timer0(void) interrupt 1
{
	TL0 = tl_0;
	TH0 = th_0;
	pin_tog = ~pin_tog;
}
/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input  
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */ 
void SPI_Init()
{
	CS_BAR = 1;	                  	// DISABLE ADC SLAVE SELECT-CS 
	SPCON |= 0x20;               	 	// P1.1(SSBAR) is available as standard I/O pin 
	SPCON |= 0x01;                	// Fclk Periph/4 AND Fclk Periph=12MHz ,HENCE SCK IE. BAUD RATE=3000KHz 
	SPCON |= 0x10;               	 	// Master mode 
	SPCON &= ~0x08;               	// CPOL=0; transmit mode example|| SCK is 0 at idle state
	SPCON |= 0x04;                	// CPHA=1; transmit mode example 
	IEN1 |= 0x04;                	 	// enable spi interrupt 
	EA=1;                         	// enable interrupts 
	SPCON |= 0x40;                	// run spi;ENABLE SPI INTERFACE SPEN= 1 
}
	/**
 * FUNCTION_PURPOSE:Timer Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */

	/**
 * FUNCTION_PURPOSE:LCD Initialization
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Init()
{
  sdelay(100);
  LCD_CmdWrite(0x38);   	// LCD 2lines, 5*7 matrix
  LCD_CmdWrite(0x0E);			// Display ON cursor ON  Blinking off
  LCD_CmdWrite(0x01);			// Clear the LCD
  LCD_CmdWrite(0x80);			// Cursor to First line First Position
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: cmd- command to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_CmdWrite(char cmd)
{
	LCD_Ready();
	LCD_data=cmd;     			// Send the command to LCD
	LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
  LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
  LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}

/**
 * FUNCTION_PURPOSE: Write Command to LCD
 * FUNCTION_INPUTS: dat- data to be written
 * FUNCTION_OUTPUTS: none
 */
void LCD_DataWrite( char dat)
{
	LCD_Ready();
  LCD_data=dat;	   				// Send the data to LCD
  LCD_rs=1;	   						// Select the Data Register by pulling LCD_rs HIGH
  LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
  LCD_en=1;	   						// Send a High-to-Low Pusle at Enable Pin
  sdelay(5);
  LCD_en=0;
	sdelay(5);
}
/**
 * FUNCTION_PURPOSE: Write a string on the LCD Screen
 * FUNCTION_INPUTS: 1. str - pointer to the string to be written, 
										2. length - length of the array
 * FUNCTION_OUTPUTS: none
 */
void LCD_StringWrite( char * str, unsigned char length)
{
    while(length>0)
    {
        LCD_DataWrite(*str);
        str++;
        length--;
    }
}

/**
 * FUNCTION_PURPOSE: To check if the LCD is ready to communicate
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void LCD_Ready()
{
	LCD_data = 0xFF;
	LCD_rs = 0;
	LCD_rw = 1;
	LCD_en = 0;
	sdelay(5);
	LCD_en = 1;
	while(LCD_busy == 1)
	{
		LCD_en = 0;
		LCD_en = 1;
	}
	LCD_en = 0;
}

/**
 * FUNCTION_PURPOSE: A delay of 15us for a 24 MHz crystal
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

/**
 * FUNCTION_PURPOSE: A delay of around 1000us for a 24MHz crystel
 * FUNCTION_INPUTS: void
 * FUNCTION_OUTPUTS: none
 */
void delay_ms(int delay)
{
	int d=0;
	while(delay>0)
	{
		for(d=0;d<382;d++);
		delay--;
	}
}