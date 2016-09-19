#include "at89c131.h"
#include "stdio.h"
#define LCD_data  P2	    					// LCD Data port

void spi_init();
void timer_init();
void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(char * str, unsigned char len);
void LCD_Ready();
void sdelay(int delay);
void delay_ms(int delay);
char int_to_string(int val);

sbit CS_BAR = P1^4;									// Chip Select for the ADC
sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable
sbit LCD_busy = P2^7;								// LCD Busy Flag

sbit on_null = P1^0;
bit transmitted_complete = 0;   //to check if spi data transmission is complete
bit offset_null = 0;            //check if the offset null connection is made
bit round_off = 0;
int adc_val = 0, avg_val = 0, init_val = 0, adc_val = 0;

unsigned char serial_data;
unsigned char data_save_high;
unsigned char data_save_low;
unsigned char count = 0, i = 0;
unsigned char weight[4];
unsigned char voltage[4];
float float_weight = 0;

/**

 * FUNCTION_INPUTS:  P1.5(MISO) serial input
 * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
 *                   P1.4(SSbar)
                     P1.6(SCK)
 */

void main(void)
{
    P3 = 0x00;          //make P3 the output port
    P2 = 0x00;          //make P2 the output port
    P1 &= 0xEF;         //make P1 P1.4 to P1.7 output;
    P0 &= 0xF0;         //make P0 pins 0,1,2 output
    spi_init();
    LCD_Init();
    timer_init();
    while(1)
    {
        CS_BAR = 0;         //enable adc as slave
        SPDAT = 0x01;       //write start bit to start ADC
        while (!transmitted_complete);  // wait end of transmition;TILL SPIF = 1 i.e. MSB of SPSTA
        transmitted_complete = 0;   //clear software flag

        SPDAT = 0x80;       //80H written to start of ADC CH0 single ended sampling
        while(!transmitted_complete);   //wait till end of transmission
        transmitted_complete = 0;
        data_save_high = serial_data & 0x03 ;
        transmit_completed = 0;    	// clear software transfer flag

        SPDAT = 0x00;
        while(!transmitted_complete);   //wait till end of transmission
        data_save_low = serial_data;
        transmitted_complete = 0;
        CS_BAR = 1;

        adc_val = (data_save_high << 8) + data_save_low;
    }
}

void it_SPI(void) interrupt 9
{
    switch (SPSTA)
    {
        case 0x80:      //data transmitted
            serial_data = SPDATA;
            transmitted_complete = 0;
            break;
        case 0x10:      //mode fault
            break;
        case 0x40:      //write collision flag
            break;
    }
    return;
}

void timer0_ISR (void) interrupt 1
{
    TH0 = 0x3C;
    TL0 = 0xB0;
		P1^4 = ~P1^4;
}

void spi_init()
{
    CS_BAR = 1;        //disable adc slave select chip select
    SPCON |= 0x20;     //P1.1 is available for std IO pin (ssdis)
    //spr1 and spr2
    SPCON |= 0x01;     //Fclk Periph/4 AND Fclk Periph=12MHz ,HENCE SCK IE. BAUD RATE=3000KHz
    SPCON |= 0x10;      //master mode
    SPCON &= ~0x08;     //CPOL=0; transmit mode example|| SCK is 0 at idle state
    SPCON |= 0x04;      //CPHA=1; transmit mode example
    IEN1 |= 0x04;       //enable SP1 interrupt pin
    EA = 1;             //enable interrupts
    SPCON |= 0x40;      //run spi; enable spi interface spen = 1
    return;
}

void timer_init()
{
    // Set Timer0 to work in up counting 16 bit mode. Counts upto
    // 65536 depending upon the calues of TH0 and TL0
    // The timer counts 65536 processor cycles. A processor cycle is
    // 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
    //Initialize TH0
    //Initialize TL0
    //Configure TMOD
    TH0 = 0x3C;
    TL0 = 0xB0;
    TMOD = 0x02;
    //Set ET0
    //Set TR0
    ET0 = 1;
    TR0 = 1;
}
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