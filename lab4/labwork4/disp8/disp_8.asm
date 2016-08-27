lcd_data equ P2
lcd_rs  equ P0.0
lcd_rw equ P0.1
lcd_en equ P0.2
org 00h
	ljmp main
org 100h

init:
	mov 60H, #11H
	mov 61H, #12H
	mov 62H, #10H
	mov 63H, #13H
	mov 64H, #14H
	mov 65H, #15H
	mov 66H, #16H
	mov 67H, #17H
	mov 68H, #18H
	mov 69H, #19H
	mov 6AH, #1AH
	mov 6BH, #1BH
	mov 6CH, #1CH
	mov 6DH, #1DH
	mov 6EH, #1EH
	mov 6FH, #1Fh

init_disp:
	mov A, R7
	swap A
	mov R0, A 		; read pointer
	RET

blink_off:
	mov P1, #00h
	lcall delay
	ret
blink_on:
	mov P1, #0ffh
	lcall delay
	ret
blink:
	lcall blink_on
	lcall delay_5
	lcall blink_off
	lcall delay_5
	ret
main:
	lcall init
	lcall lcd_init

	acall delay
	acall delay
	acall delay
	acall delay

	read_again:
		lcall lcd_init
		mov A, #81H		; put cursor on first row, fifth column
		acall lcd_command	;send command to the lcd

		acall delay

		mov dptr, #my_string2 	;Load DPTR with sring1 Addr
		acall lcd_send_string   ;call text strings sending routine

		lcall blink
		lcall readnibble
		mov A, R7
		lcall blink
		lcall readnibble
		clr C
		subb A, R7
		JNZ read_again
		
		lcall lcd_init

		lcall init_disp

		lcall disp_8_byte
		lcall delay_5

		lcall disp_8_byte
		lcall delay_5

		sjmp read_again

		
disp_4:
	loop_disp_4:
		mov A, R2
		lcall lcd_command
		inc R2
		
		lcall bin2ascii_msb
		mov A, R4
		lcall lcd_senddata

		mov A, R2
		lcall lcd_command
		inc R2
		
		lcall bin2ascii_lsb
		mov A, R4
		lcall lcd_senddata
		inc R2

		inc R0

		djnz R3, loop_disp_4
		ret

disp_8_byte:

	mov R2, #80H
	mov R3, #04H

	lcall disp_4

	mov R2, #0c0H
	mov R3, #04H

	lcall disp_4


	ret

bin2ascii_msb:
	push 03H
	mov R3, #30H
	mov A, @R0
	anl A, #0f0h
	swap A
	add A, R3
	cjne A, #3AH, next
	next:
		JC next1 	; if A <  3A
		add A, #07H
	next1:
		mov R4, A
	pop 03H
	ret

bin2ascii_lsb:
	push 03H
	mov R3, #30H
	mov A, @R0
	anl A, #0fh
	add A, R3
	cjne A, #3AH, next2
	next2:
		JC next3	; if A <  3A
		add A, #07H
	next3:
		mov R4, A
	pop 03H
	ret


; bin2ascii:
; 	loop:
; 		mov A, @R0
; 		anl A, #0f0h
; 		swap A
; 		add A, R3
; 		cjne A, #3AH, next
; 	next:
; 		JC next1
; 		add A, #07h
; 	next1:
; 		mov @R1, A
; 		inc R1
; 		mov A, @R0
; 		anl A, #0fH;
; 		add A, R3
; 		cjne A, #3AH, next2
; 	next2:
; 		JC next3
; 		add A, #07h
; 	next3:
; 		mov @R1, A
; 		inc R1
; 		inc R0
; 		djnz R2, loop
; 	ret
; set pins 0-3 for configuring as input pins
; read value on pins
readnibble:
	mov P1, #0fh
	mov A, P1
	anl A, #0fh
	mov R7, A
	ret

delay_5:
	mov R3, #100
	back15:
		mov R4, #200
	back25:
		mov R5, #0FFh
	back35: 
		djnz R5, back35
		djnz R4, back25
		djnz R3, back15
	ret


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
         ret                  ;Return from busy routine

		
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
;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB   "Starting", 00H
my_string2:
		 DB   "New Input", 00H
end
