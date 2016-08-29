
org 00H

	Ljmp main
org 50H
	INIT:

		;mov 50H, #0FBH
		mov R0, #50H

		RET

	sign_two_compl:
		mov A, @R0
		rlc A
		JNC n1	; c = 1 if A < 0
		mov 56H, #02H
		sjmp exit
		n1:
			mov 56H, #01H
		exit:
			ret
	main:
		lcall INIT
		lcall sign_two_compl
		end

			
		
		
		