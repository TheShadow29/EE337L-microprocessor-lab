; Simple 8 bit adder

org 000H;
	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations

		;mov 50H, #10
		;mov 51H, #55H	
		mov R2, 50H
		mov R0, 51H
		; mov R1, #51H	
		RET

	zero_out:
		mov A, R2
		mov R3, A
		loop: 
			mov @R0, #00h
			inc R0
			djnz R3, loop
		ret
	main:
		
		ACALL INIT
		ACALL zero_out
		end
			
		
		
		