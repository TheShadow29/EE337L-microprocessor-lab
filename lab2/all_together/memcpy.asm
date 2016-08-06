; Simple 8 bit adder

	
	init_memcpy:
		; store the numbers to be added/subtracted at appropiate locations
		mov R2, 50H
		mov R0, 51H
		mov R1, 52H
		mov R3, #02H
		; mov R1, #51H	
		RET

	copy_temp:
		lcall init_memcpy
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

		
		
		