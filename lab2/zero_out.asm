; Simple 8 bit adder

org 000H;
	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations
		mov R0, #50H
		mov R1, #51H
		mov 50H, #10
		mov 51H, #52H	
		mov R3, #00H
		RET

	zero_out:
		mov A, @R0
		mov R2, A
		loop: 
			mov @R1, #00h
			inc R1
			djnz R2, loop
		ret
	main:
		
		ACALL INIT
		ACALL zero_out
		end
			
		
		
		