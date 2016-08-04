; You are given 5 positive numbers starting at location 60H. Write a subroutine Sort to sort the
; numbers in increasing order using any sorting algorithm. Store the sorted numbers starting
; from location 70H. Contents of the original array should not be destroyed or re-ordered.
org 00H

	Ljmp main
org 50H
	INIT:
		; adding 0x9A90 and 0x1A90

		lcall reset	; function to reset R0, R1 to 60H, 70H

		mov @R0, #0FAH	;unsorted number
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #06H	;61
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #00H	;62
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #05H	;63
		
		lcall ro_to_r1
		lcall inc_both
		
		mov @R0, #03H	;64
		
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
	; the function moves the value of r0 to r1
	ro_to_r1:
		mov A, @R0
		mov @R1, A
		ret
	; checks if r2 has become 0
	; r2 = 0 for the end of loop
	check_r2_0:
		dec R2
		mov A, R2
		JZ sort_5
		ret
	; checks if r3 has become 0
	; r3 for the termination case
	check_r3_0:
		dec R3
		mov A, R3
		JZ fin
		ret
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
		swap1:			; swaps the adjacent Contents for performing bubble sort
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
		fin:	; termination
			mov A, @R0
		end

			
		
		
		