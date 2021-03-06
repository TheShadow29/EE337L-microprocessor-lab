#include "at89c5131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void serial_init();
void timer1_init();
void transmit_data();
void rec_data(int j);
void check_switch();

int rec_counter = 0;

void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag

bit switch_prev;
bit switch_curr;

unsigned char recieved_data;
unsigned char trans_data;

char recieved_string[16];
char tranmitted_string[16] = "Silver Shadow 29";

unsigned char psw_serial;
unsigned parity_bit;
unsigned char regA;
unsigned char regB;

sbit led_pin = P1^4;
sbit p1_0 = P1^0;
sbit p1_1 = P1^1;
sbit p1_2 = P1^2;
sbit p1_3 = P1^3;
sbit p1_4 = P1^4;
sbit p1_5 = P1^5;
sbit p1_6 = P1^6;
sbit p1_7 = P1^7;

void main(void)
{
	P1 = 0x00;
	p1_4 = 0;
	p1_5 = 0;
	p1_6 = 0;
	p1_7 = 0;
	led_pin = 0;
	serial_init();
	timer1_init();
	LCD_Init();
	trans_data = 0x43;
	recieved_data = 0x41;
	switch_prev = 1;
	switch_curr = 0;
	REN = 1;
	while(1)
	{
		LCD_CmdWrite(0x80);
		//LCD_DataWrite(recieved_data);
		LCD_StringWri	te(recieved_string,16);
		check_switch();
		LCD_CmdWrite(0xc0);
		//LCD_DataWrite(trans_data);
		LCD_StringWrite(tranmitted_string,16);
		delay_ms(500);
	}
}

void check_switch()
{
	switch_prev = switch_curr;
	p1_3 = 1;
	switch_curr = p1_3;
	if (switch_curr != switch_prev)
	{
		transmit_data();	
	}
}

void transmit_data()
{
	int i = 0;
	while (i < 16)
	{
		trans_data = tranmitted_string[i];
		regA = trans_data + 0x01;
		regB = regA - 0x01;
		if(PSW^0 == 1)	
		{
			parity_bit = 0x31;
			TB8 = 1;
		}
		else
		{
			parity_bit = 0x32;
			TB8 = 0;
		}
		SBUF = trans_data;
		delay_ms(10);
		i++;
	}
}

void rec_data(int j)
{
	recieved_data = SBUF;
	recieved_string[j] = recieved_data;
	RI = 0;
}

void it_serial(void) interrupt 4
{
	if (RI == 1)
	{
		rec_data(rec_counter);
		rec_counter++;
		if (rec_counter == 16)
		{
			rec_counter = 0;
		}
	}
	if (TI == 1)
	{
		TI = 0;
		led_pin = ~led_pin;
	}
}

void timer1_init()
{
	TH1 = 0xcc;
	TMOD = 0x20;
	TR1 = 1;
}

void serial_init()
{
	SCON = 0xc0;
	// SM0 = 1;
	// SM1 = 1;
	// SM2 = 0;
	EA = 1;
	ES = 1;
	ET1 = 0;
	// RI = 0;
	// TI = 0;
	// REN = 0;
}


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