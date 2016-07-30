; N partial sums

org 00H

	Ljmp main
	
	INIT:
		; store N 
		mov R0, #50H
		mov 50H, #10H
		mov R3, 50H
		mov R1, #00H
		mov A, R1
		RET
	
	n_sum:
		;function to output partial sums
		;;how to put 10H as a variable?
		inc R1
		add A, R1
		inc R0
		mov @R0, A
		cjne R1, #10H , n_sum
		ret
		
	main:
		;MOV SP,#0C0H	;move stack pointer to indirect RAM location
		ACALL INIT
		ACALL n_sum
		end
			
		
		
		