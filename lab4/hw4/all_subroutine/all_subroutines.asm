lcd_data equ P2
lcd_rs  equ P0.0
lcd_rw equ P0.1
lcd_en equ P0.2
org 00h
	ljmp main
org 100h

init:
	mov 50H, #5
	mov 51H, #60H
	mov R2, 50H
	mov R0, 51H
	ret

main:
	acall init
			lcall lcd_init
			acall delay
	acall delay
	acall delay

	mov A, #81H		; put cursor on first row, fifth column
	acall lcd_command	;send command to the lcd

	acall delay

	mov dptr, #my_string1 	;Load DPTR with sring1 Addr
	acall lcd_send_string   ;call text strings sending routine
	acall delay
	lcall read_values
	lcall init
	ljmp display_values


read_values:
	
	loop_read:
		mov P1,#00h
		lcall pack_nibbles
		mov A, 4fh
		mov @R0, A
		inc R0
		mov P1, #0f0h
		djnz R2, loop_read
	ret

blink_off:
	mov P1, #00h
	lcall delay
	ret
blink_on:
	mov P1, #0ffh
	lcall delay
	ret
pack_nibbles:
	lcall blink_on
	lcall readnibble
	mov A, R7
	mov R6, A
	lcall delay_5
	lcall blink_off
	lcall readnibble
	mov A, R6
	swap A
	orl A, R7
	mov 4fh, A
	ret

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
	
display_values:


	loop_disp:
		lcall delay_2
		lcall init
		lcall readnibble
		mov R5, A
		subb A, R2
		jnc disp_null 		;if A > R2
		mov A, R0
		add A, R5
		mov R0, A
		
		mov A, #85h		;cursor pointer
		lcall lcd_command
		mov A, @R0
		lcall lcd_senddata
		sjmp loop_disp
	disp_null:
		mov lcd_data,#01H	;Clear LCD
		acall lcd_init_helper
		lcall delay_2
		sjmp loop_disp
		


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
; my_string2:
; 		 DB   "Arka Sadhu", 00H
end
