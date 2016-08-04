; Simple 8 bit adder

org 000H;
	Ljmp main
	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations
		mov R0, #50H
		mov R1, #60H
		mov 50H, #0FFH;
		mov 60H, #0FFH;
		RET
	
	Add_8bit:
		;function to add two 8 bit numbers
		mov A, @R0
		add A, @R1
		mov 70H, A
		RET
		
	main:
		;MOV SP,#0C0H	;move stack pointer to indirect RAM location
		ACALL INIT
		ACALL Add_8bit
		
		end
			
		
		
		