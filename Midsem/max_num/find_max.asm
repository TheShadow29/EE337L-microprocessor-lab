
org 00H

	Ljmp main
org 50H
	INIT:
		;mov 50H, #61H
		;mov 51H, #85H
		;mov 52H, #23H
		;mov 53H, #92H
		;mov 54H, #11H

		mov R2, #5
		mov R0, #50H

		RET

	find_max:
		mov A, @R0
		mov R3, A
		dec R2
		loop_fm:
			inc R0
			mov A, @R0
			subb A, R3		; C = 1 if A < R3
			JC next1
			mov A, @R0
			mov R3, A
		next1:
			djnz R2, loop_fm
		mov 55H, R3
		ret
	main:
		lcall INIT
		lcall find_max
		end

			
		
		
		