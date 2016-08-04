; Simple 8 bit adder

org 000H;

led equ P1

	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations
		mov R0, #50H
		mov R1, #51H
		mov 50H, #10
		mov 51H, #55H	
		
		RET

	display:
		mov A, @R0
		setb psw.3
		mov R2, A
		clr psw.3
		mov A, @R1
		setb psw.3
		mov R1, A
		loop: 
			; mov @R1, #00h
			mov A, @R1
			anl A, #0fh;
			swap A
			mov led, A
			inc R1
			acall delay	
			djnz R2, loop
		ret
	delay:
		mov R3, #200
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
			
		
		
