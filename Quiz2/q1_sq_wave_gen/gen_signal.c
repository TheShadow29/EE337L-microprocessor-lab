#include "at89c5131.h"
#include "stdio.h"

sbit pin_tog = P3^3;

int th_0;
int tl_0;
int freq = 20;
int time_period;
int t_val;

void calc_timer_val();
void timer_init();

void main(void)
{
	P1 = 0x0F;
	pin_tog = 1;
	calc_timer_val();
	timer_init();
	while(1)
	{

	}

}

void calc_timer_val()
{
	time_period = 1000/freq;
	t_val = 256 - time_period;
	th_0 = t_val;
	// th_0 = t_val/256;
	// tl_0 = t_val%256;
}

void timer_init()
{
	//use timer0 for generating the sq wave signal
	TMOD = 0x02;
	TH0 = th_0;
	TL0 = tl_0;
	EA = 1;
	ET0 = 1;
	TR0 = 1;
}

void it_timer0(void) interrupt 1
{
	// TL0 = tl_0;
	// TH0 = th_0;
	pin_tog = ~pin_tog;
}