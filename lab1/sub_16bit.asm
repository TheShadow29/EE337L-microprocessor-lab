; Repeat the previous question, but now perform subtraction of two 16-bit numbers.

org 00H

	Ljmp main
org 50H
	INIT:
		; adding 0xc821 and 0x9228
		
		mov R0, #60H
		mov R1, #70H
		mov @R0, #0FFH
		inc R0
		mov @R0, #0FFH
		mov @R1, #0FCH
		inc R1
		mov @R1, #0DEH
		RET
	
	sub_16bit:
		;function to add two 16 bit numbers
	
		mov A, @R0	;61
		subb A, @R1
		; no idea why the following 4 lines need to be commented
		
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
			subb A, @R1
			
			JNC set_msb 	;jump if no carry

			inc R0;61
			inc R0;62
			inc @R0
			dec R0
			dec R0
		set_msb:
			inc R0	; 61
			inc R0	;62
			inc R0 ;63
			mov @R0, A	; set msb
		ret

	main:
		;MOV SP,#0C0H	;move stack pointer to indirect RAM location
		ACALL INIT
		ACALL sub_16bit
		end
			
		
		
		