; N partial sums

org 00H

	Ljmp main
	
	INIT:
		; adding 0x9A90 and 0x1A90
		
		mov R0, #60H
		mov R1, #70H
		mov R2, #00H
		; mov R2, #00H
		mov @R0, #0FFH
		inc R0
		mov @R0, #90H
		mov @R1, #0FFH
		inc R1
		mov @R1, #80H
		RET
	
	sub_16bit:
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
			JNC set_msb
			inc R0 ;61
			inc R0 ;62
			inc @R0
			dec R0	;61
			dec R0	;60

		set_msb:
			add A, R2
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
			
		
		
		