; Simple 8 bit adder

org 000H;

led equ P1

	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations
		mov 50H, #9
		mov 51H, #60H	
		mov R7, 50H
		mov R0, 51H
		RET

	display:
		mov A, R7
		mov R2, A
		loop: 
			mov A, @R0
			anl A, #0fh;
			swap A
			mov led, A
			inc R0
			acall delay	
			djnz R2, loop
		ret
	delay:
		mov R3, #20
		back1:
			mov R4, #200
		back2:
			mov R5, #0FFh
		back3: 
			djnz R5, back3
			djnz R4, back2
			djnz R3, back1
		ret

	main:
		
		ACALL INIT
		ACALL display
		end
			
		
		
