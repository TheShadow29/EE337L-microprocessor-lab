; Simple 8 bit adder

org 000H;
led equ P1.7
	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations
		mov R0, #4FH
		mov 4FH, #10;		
		setb led
		RET
	delay:
		mov A, @R0
		mov R1, A
		back:
			mov R2, #10
			back1:
				mov R3, #200
				back2:
					mov R4, #0FFh
					back3: 
						djnz R4, back3
						djnz R3, back2
						djnz R2, back1
						djnz R1, back
		ret
	main:
		;MOV SP,#0C0H	;move stack pointer to indirect RAM location
		ACALL INIT
		loop:
			cpl led
			lcall delay
			ljmp loop
		end
			
		
		
		