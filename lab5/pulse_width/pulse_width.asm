lcd_data equ P2
lcd_rs  equ P0.0
lcd_rw equ P0.1
lcd_en equ P0.2

ORG 0000H
	LJMP main

ORG 0003H
	lcall ext_interrupt
	reti


ORG 000BH ; Timer 0 overflow interrupt routine
; Keep track of number of overflows here
	lcall timer0_interrupt
	reti

org 001BH
	lcall timer1_interrupt
	reti



org 0100H

;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
		mov lcd_data, #38H	;Function set: 2 Line, 8-bit, 5x7 dots
		acall lcd_init_helper

		mov lcd_data, #0ch	;Display on, Curson off
		acall lcd_init_helper

		mov lcd_data,#01H	;Clear LCD
		acall lcd_init_helper

		mov lcd_data, #06H	;Entry mode, auto increment with no shift
		acall lcd_init_helper

		ret

lcd_init_helper:
		clr lcd_rs			;Selected command register
		clr lcd_rw			;We are writing in instruction register
		setb lcd_en 		;Enable H->L
		acall delay
		clr lcd_en
		acall delay
		ret
;-----------------------command sending routine-------------------------------------
lcd_command:
	mov lcd_data, A 	;move the command to lcd_data
	acall lcd_init_helper
	ret
;-----------------------New text strings sending routine-------------------------------------
lcd_send_string1:
	push 0e0h
	lcd_send_loop1:
		clr A
		mov A, @R1		;load first character in accumulator
		jz exit1					;go to exit if zero
		acall lcd_senddata
		acall delay
		inc R1
		sjmp lcd_send_loop1
	exit1:
		pop 0e0h
		ret
;-----------------------text strings sending routine-------------------------------------
lcd_send_string:
	push 0e0h
	lcd_send_loop:
		clr A
		movc A, @A + dptr		;load first character in accumulator
		jz exit					;go to exit if zero
		acall lcd_senddata
		acall delay
		inc dptr
		sjmp lcd_send_loop
	exit:
		pop 0e0h
		ret
;-----------------------data sending routine-------------------------------------		     
lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
		 ; lcall lcd_init_helper
		 ; acall delay
         ret       

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
	loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
		 djnz r0, loop2
		 pop 1
		 pop 0 
		 ret


;--------------- Specific to this application -------------

disp_lcd:
	MOV A, R7
	LCALL print_lcd
	MOV A, TH0
	LCALL print_lcd
	MOV A, TL0
	LCALL print_lcd
	ret
	 
print_lcd:
	USING 0
	PUSH AR3
	
	MOV R3,A
	ANL A, #0F0H
	SWAP A
	LCALL bin2ascii
	LCALL lcd_senddata
	 
	MOV A, R3
	ANL A, #0FH
	LCALL bin2ascii
	LCALL lcd_senddata
	
	POP AR3
	 
	RET	
bin2ascii:
	USING 0
	PUSH AR1
	
	MOV R1, A
	CLR C
	SUBB A, #0AH
	MOV A, R1
	JNC down
		ADD A, #30H
		JMP further
	down:
		ADD A, #37H
		further:
	POP AR1
	RET

delay_2:
	push 05H
	mov R3, #40
	back12:
		mov R4, #200
	back22:
		mov R5, #0FFh
	back32: 
		djnz R5, back32
		djnz R4, back22
		djnz R3, back12
	pop 05H
	ret


ext_interrupt:
	clr IE.0
	mov A, #81H		; put cursor on first row, fifth column
	acall lcd_command	;send command to the lcd
	acall delay
	mov dptr, #my_string1 	;Load DPTR with sring1 Addr
	acall lcd_send_string   ;call text strings sending routine
	acall delay

	mov A, #0c0H
	acall lcd_command

	mov dptr, #my_string2
	acall lcd_send_string

	acall delay

	lcall disp_lcd
	mov R7, #00H
	lcall delay_2
	setb P1.4
	ret
increment:
	setb TR0
	setb TR1
	loop_here : jnb P1.4, loop_here
	ret

timer0_interrupt:
	inc R7
	ret

timer1_interrupt:
	mov TH1, #3ch
	mov TL1, #0b0h
	djnz R6, fin_t1
	mov R6, #28H
	cpl P3.2
	fin_t1:
	ret
	
initialize:
	mov TH0, #00H
	mov TL0, #00H
	mov TMOD, #19H
	mov IE, #8BH
	clr P1.4


	setb IT0
	
	ret

;--------------- MAIN STARTS HERE --------------------
main:
	mov TH1, #3ch
	mov TL1, #0b0h
	
	mov R6, #28h
	mov R7, #00h
	clr P3.2
	loop_main:
		
		acall lcd_init
		lcall initialize
		WAIT_NEW_PULSE: JB P3.2, WAIT_NEW_PULSE ;
		lcall increment
		

		
		ljmp loop_main

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "PULSE WIDTH", 00H
my_string2:
		 DB   "COUNT IS ", 00H


end