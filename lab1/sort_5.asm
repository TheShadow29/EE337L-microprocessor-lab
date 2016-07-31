; N partial sums

org 00H

	Ljmp main
	
	INIT:
		; adding 0x9A90 and 0x1A90
		
		
		
		lcall reset

		mov @R0, #09H	;60
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #01H	;61
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #05H	;62
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #03H	;63
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #07H	;64
		
		lcall ro_to_r1
		lcall reset
		
		RET

	inc_both:
		inc R0
		inc R1
		ret	
	dec_both:
		dec R0
		dec R1
		ret	
	reset:
		mov R0, #60H
		mov R1, #70H 
		ret

	; note that value of A is also flushed out
	ro_to_r1:
		mov A, @R0
		mov @R1, A
		ret
	check_r2_0:
		dec R2
		mov A, R2
		JZ sort_5
		ret
	check_r3_0:
		dec R3
		mov A, R3
		JZ fin
		ret
	; check_r3_0:
	; 	mov A, R3
	; 	JZ end
	; 	ret
	sort_5:
		; function to sort the five no.s
		mov R3, #05H
		mov R2, #05H	; 5 numbers to be sorted
		lcall reset
		loop:
			lcall check_r3_0
			lcall check_r2_0
			mov A, @R1	;60
			inc R1
			subb A, @R1
			JC loop 	; A < @R1
		swap1:
			inc R3
			mov A, @R1
			dec R1
			xch A, @R1
			inc R1
			xch A, @R1
			ljmp loop
		ret
	main:
		;MOV SP,#0C0H	;move stack pointer to indirect RAM location
		ACALL INIT
		ACALL sort_5
		fin:
			mov A, @R0
		end

			
		
		
		