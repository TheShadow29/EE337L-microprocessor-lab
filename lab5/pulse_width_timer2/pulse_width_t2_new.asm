lcd_data equ P2
lcd_rs  equ P0.0
lcd_rw equ P0.1
lcd_en equ P0.2

; Defining Timer-2 registers
T2CON DATA 0C8H
T2MOD DATA 0C9H
RCAP2L DATA 0CAH
RCAP2H DATA 0CBH
TL2 DATA 0CCH
TH2 DATA 0CDH
; Defining interrupt enable (IE) bit
ET2 BIT 0ADH
; Defining interrupt priority (IP) bit
PT2 BIT 0BDH
; Defining P1
T2EX BIT 91H
T2 BIT 90H
; Defining timer control (T2CON) register bits
TF2 BIT 0CFH
EXF2 BIT 0CEH
RCLK BIT 0CDH
TCLK BIT 0CCH
EXEN2 BIT 0CBH
TR2 BIT 0CAH
C_T2 BIT 0C9H
CP_RL2 BIT 0C8H

org 00H
ljmp main

;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "PULSE WIDTH", 00H
my_string2:
		 DB   "COUNT IS ", 00H

org 0003H	;ext0 interrupt
	lcall isr_ext0
	reti

org 000bH
	inc R7
	reti

org 100H

isr_ext0:
	; clr TR0
	cjne R6, #01h, calc
	mov R6, #00h
	mov TH0, #00h
	mov TL0, #00h
	ret
	calc:
	clr TR0	
	mov A, R7
	mov R5, A
	mov A, #0cAH
	acall lcd_command
	acall delay

	lcall disp_lcd
	
	; mov TH0, #00h
	; mov TL0, #00h
	; mov R7, #00h
	ret

disp_lcd:
	MOV A, R5
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
T2_INIT:
	mov T2MOD,#02H;			t2oe, and dcen set
	mov T2CON, #00H
	MOV TH2,#0E8H;
	MOV TL2,#90H;
	MOV RCAP2H,#0E8H;
	MOV RCAP2L,#90H;
	ret

initialization:
	mov R6, #01h
	mov R7, #00h

	mov TMOD, #09h
	mov TH0, #00h
	mov TL0, #00h

	acall delay
	acall delay

	acall lcd_init

	acall delay
	acall delay
	acall delay

	mov A, #80h
	acall lcd_command
	acall delay

	mov dptr, #my_string1
	acall lcd_send_string
	acall delay

	mov A, #0c0h
	acall lcd_command
	acall delay
	mov dptr, #my_string2
	acall lcd_send_string

	mov IE, #83H
	setb IT0
	setb TR2
	
	WAIT_NEW_PULSE: JB P3.2, WAIT_NEW_PULSE 
	
	setb TR0
	ret



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
delay:	 
	push 0
	 push 1
         mov r0,#1
	loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
		 djnz r0, loop2
		 pop 1
		 pop 0 
		 ret

main:
	lcall T2_INIT
	lcall initialization
	over : 
		
		sjmp over

end
