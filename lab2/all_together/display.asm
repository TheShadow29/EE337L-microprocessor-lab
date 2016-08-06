; Simple 8 bit adder
	
	init_display:
		; store the numbers to be added/subtracted at appropiate locations	
		mov R7, 50H
		mov R0, 51H
		RET

	display:
		lcall init_display
		mov A, R7
		mov R2, A
		loop: 
			mov A, @R0
			anl A, #0fh;
			swap A
			mov led, A
			inc R0
			lcall delay	
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

			
		
		
