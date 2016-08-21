org 00h
lcd_data equ P2
lcd_rs  equ P0.0
lcd_rw equ P0.1
lcd_en equ P0.2

	ljmp display_values

org 100h


init_display_values:
	mov 50H, #3H	;value of K
	mov 51H, #65H	;start of the stored array
	mov 65H, #49H
	mov 66H, #41H
	mov 67H, #42H
	mov 68H, #43H
	mov 69H, #44H
	mov 6AH, #45H
	mov 6BH, #46H
	mov R2, 50H
	mov R0, 51H
	ret

display_values:

		lcall lcd_init
	loop_disp:
		lcall delay_2
		lcall init_display_values
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
		

; set pins 0-3 for configuring as input pins
; read value on pins
readnibble:
	mov P1, #0fh
	mov A, P1
	anl A, #0fh
	mov R7, A
	ret

delay_2:
	push 05H
	mov R3, #40
	back15:
		mov R4, #200
	back25:
		mov R5, #0FFh
	back35: 
		djnz R5, back35
		djnz R4, back25
		djnz R3, back15
	pop 05H
	ret
; start:
; 	mov P2, #00h
; 	mov P1, #00h

; 	acall delay
; 	acall delay

; 	acall lcd_init 	; initialize lcd

; 	acall delay
; 	acall delay
; 	acall delay

; 	mov A, #85H		; put cursor on first row, fifth column
; 	acall lcd_command	;send command to the lcd

; 	acall delay

; 	mov dptr, #my_string1 	;Load DPTR with sring1 Addr
; 	acall lcd_send_string   ;call text strings sending routine
; 	acall delay

; 	mov a, #0c3h	;Put cursor on second row,3 column
; 	acall lcd_command
; 	acall delay
; 	mov dptr, #my_string2
; 	acall lcd_send_string





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
         DB   "Arka123", 00H
my_string2:
		 DB   "Sadhu", 00H
end

