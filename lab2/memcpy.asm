; Simple 8 bit adder

org 000H;
	Ljmp main

org 050H	
	
	INIT:
		; store the numbers to be added/subtracted at appropiate locations

		mov 50H, #10
		mov 51H, #65H	
		mov 52H, #60H
		mov R2, 50H
		mov R0, 51H
		mov R1, 52H
		mov R3, #02H
		; mov R1, #51H	
		RET

	copy_temp:
		mov R1, #20H
		cp_temp:
			mov A, @R0
			mov @R1, A
			inc R0
			inc R1
			djnz R2, cp_temp
		lcall init
		mov R0, #20H
		djnz R3, cp_temp
		ret

	main:
		
		ACALL INIT
		ACALL copy_temp
		end
			
		
		
		