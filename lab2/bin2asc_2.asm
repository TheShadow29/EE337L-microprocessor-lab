; Simple 8 bit adder

org 000H;
	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations
		;mov 50H, #3
		;mov 51H, #55H	
		;mov 52H, #65H
		mov R2, 50H
		mov R0, 51H	;read pointer
		mov R1, 52H	;write pointer
		mov R3, #30H
		RET

	bin2ascii:
		loop:
			mov A, @R0
			anl A, #0f0h
			swap A
			add A, R3
			cjne A, #3AH, next
		next:
			JC next1
			add A, #07h
		next1:
			mov @R1, A
			inc R1
			mov A, @R0
			anl A, #0fH;
			add A, R3
			cjne A, #3AH, next2
		next2:
			JC next3
			add A, #07h
		next3:
			mov @R1, A
			inc R1
			inc R0
			djnz R2, loop
		ret




		
	main:
		
		ACALL INIT
		ACALL bin2ascii
		end
			
		
		
		