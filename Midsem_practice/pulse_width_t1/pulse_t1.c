#include "at89c5131.h"
#include "stdio.h"
#define LCD_data P2

void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);

void ext_interrupt1();

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag

int counter;
int cou;
char char_to_show[6];
char ch_th1[2];
char ch_tl1[2];
char ch_ct[2];
int th_1;
int tl_1;
int i;

sbit pin_tog = P1^1;

sfr IP = 0xB8;
sbit px1 = IP^3;
sbit p3_3 = P3^3;


void timer_init();
char check_num(int num);
bit can_write = 0;

void main()
{
	timer_init();
	cou = 0;
	//p3_3 = 0;
	LCD_Init();
	while(p3_3)
	{}
		TR1 = 1;
	while(1)
	{	

		LCD_CmdWrite(0x80);
		LCD_StringWrite("Pulse Width ",12);
		LCD_CmdWrite(0xc0);
		LCD_StringWrite("Count is ",9);
			LCD_StringWrite(ch_ct,2);
			LCD_StringWrite(ch_th1,2);
			LCD_StringWrite(ch_tl1,2);
		can_write = 1;

	}
}

void timer_init()
{
	// set T1 to calculate pulse width and setup External interrupt T1
	TH1 = 0x00; 
	TL1 = 0x00;
	TH0 = 0x3c;
	TL0 = 0xb0;
	counter = 0;
	TMOD = 0x91;
	IT1 = 1;
	EA = 1;
	ET1 = 1;
	ET0 = 1;
	EX1 = 1;
	TR1 = 0;
	TR0 = 1;
	px1 = 1;
}

void it_timer0(void) interrupt 1
{
	pin_tog = ~pin_tog;
	//p3_3 = ~p3_3;
	TH0 = 0x3c;
	TL0 = 0xb0;
}


void it_timer1 (void) interrupt 3
{
	counter++;
	TL1 = 0x00;
	TH1 = 0x00;
}

void it_ext_1 (void) interrupt 2
{
	ext_interrupt1();
}

void ext_interrupt1()
{
	th_1 = TH1;
	tl_1 = TL1;
	for (i = 0; i < 2; i++)
	{
		ch_th1[1-i] =  check_num(th_1%16);
		ch_tl1[1-i] = check_num(tl_1%16);
		ch_ct[1-i] = check_num(counter%16);
		th_1 = th_1/16;
		tl_1 = tl_1/16;
		counter = counter/16;
	}
	//TH1 = 0x00;
	//TL1 = 0x00;
	//counter = 0;
	can_write = 1;
	TR1 = 0;
}

char check_num(int num)
{
	char a;
	if (num >= 10)
	{
		a = num - 10 + 'A';
	}
	else
	{
		a = num + '0';
	}
	return a;
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