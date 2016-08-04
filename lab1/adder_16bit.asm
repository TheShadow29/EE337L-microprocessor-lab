; Use the subroutine developed as homework in this exercise. Write an assembly language
; program to perform addition of two 16-bit numbers given in 2’s complement form. The
; two numbers are stored in memory locations 60H and 70H. Storage is big-endian i.e., most
; significant byte is in the smallest address. The result can be 17 bits long, so it needs three
; bytes for storage. The result is to be stored in memory locations starting from 62H.

org 00H

	Ljmp main
org 50H
	INIT:
		; adding 0x9A90 and 0x1A90
		
		mov R0, #60H
		mov R1, #70H
		mov R2, #00H
		mov @R0, #0FFH
		inc R0
		mov @R0, #0F9H
		mov @R1, #7FH
		inc R1
		mov @R1, #0FFH
		RET
	
	Add_16bit:
		;function to add two 16 bit numbers
	
		mov A, @R0	;R0 + 1
		add A, @R1
		JNC set_lsb
		inc R2
		set_lsb:
			inc R0	; 62
			inc R0	; 63
			inc R0	; 64
			mov @R0, A	; set lsb
			dec R0	;63
			dec R0	;62
			dec R0	;61
			dec R0	;60
			mov A, @R0
			dec R1
			add A, @R1
			mov R3, A
			
			JNC set_msb ;jump if no carry
			;RLC A
			;JNC set_msb
			;JZ set_msb
		set_carry:
			
			inc R0 ;61
			inc R0 ;62
			inc @R0
			dec R0	;61
			dec R0	;60

		set_msb:
			mov A, R3
			add A, R2
			inc R0	; 61
			inc R0	;62
			inc R0 ;63
			mov @R0, A	; set msb
		ret

	main:
		;MOV SP,#0C0H	;move stack pointer to indirect RAM location
		ACALL INIT
		ACALL Add_16bit
		loop:
			sjmp loop
		end
			
		
		
		