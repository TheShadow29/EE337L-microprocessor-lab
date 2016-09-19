#include "at89c5131.h"
#define lcd_data P2

void lcd_init();
void lcd_write_data(char dat);
void lcd_cmd_write(char cmd);
void lcd_write_string(char* str, unsigned char len);
void lcd_ready();
void s_delay(int delay);
void delay_ms(int delay);

sbit cs_bar = P1^4;     //chip select for adc
sbit lcd_rs = P0^0;     //lcd register select
sbit lcd_rw = P0^1;     //lcd read/write
sbit lcd_en = P0^2;     //lcd enable
sbit lcd_busy = P2^7;   //lcd busy flag

bit transmit_completed = 0;       //check if spi data transmit is complete
char serial_data, data_save_high, data_save_low;
	char* hello = "hello";
	char* world = "world";
void main (void)
{
    P2 = 0x00;      //make port 2 output
    lcd_init();
	
    while(1)
    {
				lcd_cmd_write(0x80);
        lcd_write_string(hello,5);
				lcd_cmd_write(0xc5);
				lcd_write_string(world,5);
        delay_ms(5000);
    }
}

void lcd_init()
{
    s_delay(100);
    lcd_cmd_write(0x38);    //lcd 2 lines, 5*7 matrix
    lcd_cmd_write(0x0e);    //display on cursor on blink off
    lcd_cmd_write(0x01);    //clear the lcd
    lcd_cmd_write(0x80);    //cursor to the first line first position
}

void lcd_cmd_write(char cmd)
{
    lcd_ready();
    lcd_data = cmd;     //send the command to lcd
    lcd_rs = 0;         //select command register by lcd_rs = low
    lcd_rw = 0;         //select write operation
    lcd_en = 1;         //send high low pulse at enable pin
    s_delay(5);
    lcd_en = 0;
    s_delay(5);
    return;
}

void lcd_write_data(char dat)
{
    lcd_ready();
    lcd_data = dat;     //send the data to lcd
    lcd_rs = 1;         //select register select by pulling lcd_rs high
    lcd_rw = 0;         //select write operation
    lcd_en = 1;         // high low pulse at enable pin
    s_delay(5);
    lcd_en = 0;
    s_delay(5);
    return;
}

void lcd_write_string(char* str, unsigned char len)
{
    while(len > 0)
    {
        lcd_write_data(*str);
        str++;
        len--;
    }
    return;
}

void lcd_ready()
{
    lcd_data = 0xFF;
    lcd_rs = 0;
    lcd_rw = 1;
    lcd_en = 0;
    s_delay(5);
    lcd_en = 1;
    while (lcd_busy == 1)
    {
        lcd_en = 0;
        lcd_en = 1;
    }
    lcd_en = 0;
    return;
}

void s_delay(int delay)
{
    char d = 0;
    while(delay > 0)
    {
        for(d = 0; d < 5; d++)
        {
            delay--;
        }
    }
    return;
}

void delay_ms(int delay)
{
    int d = 0;
    while (delay > 0)
    {
        for(d = 0; d < 382; d++){}
        delay--;
    }
}



