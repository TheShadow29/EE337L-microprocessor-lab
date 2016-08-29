
org 00H

	Ljmp main
org 50H
	INIT:
		;mov 50H, #02H
		;mov 51H, #01H
	;	mov 52H, #0FBH
	;	mov 53H, #05H
	;	mov 54H, #04H


		mov R2, #5
		mov R0, #50H

		RET

	sign_two_compl:
		mov A, @R0
		rlc A
		JNC n1	; c = 1 if A < 0
		mov R4, #01H			; 1 if negative
		sjmp exit
		n1:
			mov R4, #00H		; 0 if positive
		exit:
			ret

	max_num_signed:
		mov A, @R0
		mov R3, A
		lcall sign_two_compl
		mov 56H, R4

		dec R2

		loop_sfm:
			inc R0
			lcall sign_two_compl

			mov A, R4
			xrl A, 56H
			JZ next1
			n0:			; one of them is positive other is negative
				cjne R4, #00H, fin		; R4 is 1, ie the new no. is neg, and old no. is positive, need not do anything
				mov A, @R0
				mov R3, A
				mov 56H, R4
				sjmp fin

			next1:
				cjne R4, #00H, n2
				mov A, @R0		; both are positive	
				subb A, R3		; C = 1	=> A < R3 ; need not do anything
				JC fin
				mov A, @R0
				mov R3, A
				sjmp fin

			n2:					;both are negative
				mov A, @R0
				subb A, R3		; C = 0 => actually A > R3
				JC fin			; C = 1 => need not change anything
				mov A , @R0
				mov R3, A
			
			fin:
				djnz R2, loop_sfm
		mov 55H, R3
		ret
	main:
		lcall INIT
		lcall max_num_signed
		end

			
		
		
		