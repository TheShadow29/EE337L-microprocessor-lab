; Simple 8 bit adder

org 000H;
	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations

		;mov 50H, #5
		;mov 51H, #62H	
		;mov 52H, #60H
		mov R2, 50H
		mov R0, 51H	; pointer A
		mov R1, 52H	; pointer B
		mov R3, #02H
		; mov R1, #51H	
		RET


	copy_a_back:
		mov A, R2
		dec A
		add A, R0
		mov R0, A
		mov A, R2
		dec A
		add A, R1
		mov R1, A
		loop1:
			mov A, @R0
			mov @R1, A
			dec R1
			dec R0
			djnz R2, loop1
		ret

	copy_a_front:	
		loop2:
			mov A, @R0
			mov @R1, A
			inc R0
			inc R1
			djnz R2, loop2
		ret


	main:
		
		ACALL INIT
		mov A, R0
		subb A, R1
		JNC a_front		; a > b
		; if a > b then start from front 
		; else start from back
		a_back:
			ACALL copy_a_back
			Jmp fin
		a_front:
			acall copy_a_front
		fin:
			end
			
		
		
		