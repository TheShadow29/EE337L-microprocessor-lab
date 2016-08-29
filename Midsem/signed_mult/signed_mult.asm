
org 00H

	Ljmp main
org 50H
	INIT:
		mov A, #00H
		mov B, #00H
		mov R2, #00H
		mov R3, #00H
		mov R4, #00H
		mov R0, #70H
		mov R1, #71H
		RET

	signed_mult:
		mov A, @R0
		rlc A
		JNC next1
		mov R2, #80H	;if the first number is negative, store 80 in R2
		next1:
		clr C
		mov A, @R1
		rlc A
		JNC next2
		mov R3, #80H	;if the second number is negative, store 80 in R3
		next2:
		clr C
		mov A, R2
		xrl A, R3
		mov R4, A		;R4 contains the sign of the final multiplication
						;if the final sign is negative, R4 contains 80, else 00

		mov A, @R0
		anl A, #7Fh
		mov B, A

		mov A, @R1
		anl A, #7Fh

		mul AB		
		mov 73H, A
		mov A, B		;B contains the msb, A contains lsb
		add A, R4		;add A and R4, to correct the sign of the final answer
		mov 72H, A		

		ret
	main:
		lcall INIT
		lcall signed_mult
		end

			
		
		
		