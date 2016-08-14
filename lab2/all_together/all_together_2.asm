; Simple 8 bit adder

org 000H;
led equ P1
	Ljmp main

org 50H
	INIT_zero_out:
		mov R2, 50H		; no. of memory locations to be zeroed
		mov R0, 51H		; start pointer of mem location A	
		RET

	zero_out:
		lcall INIT_zero_out	;initialize
		mov A, R2	;temporarily write the mem location to R3
		mov R3, A
		loop: 			; loop so as to zero_out the corresponding locations
			mov @R0, #00h
			inc R0
			djnz R3, loop
		ret
	init_bin2ascii:
		mov R2, 50H	;no. of numbers to be copied
		mov R0, 51H	;read pointer
		mov R1, 52H	;write pointer
		mov R3, #30H	; for conversion of bin to ascii
		RET

	bin2ascii:
		lcall init_bin2ascii	;initialize
		loop_bin:
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
			djnz R2, loop_bin
		ret

	init_memcpy:
		mov R2, 50H		;no. of mem locations
		mov R0, 51H		;mem location A
		mov R1, 52H		;mem location B
		RET

	copy_a_back:		;copy from back
		mov A, R2
		dec A
		add A, R0
		mov R0, A
		mov A, R2
		dec A
		add A, R1
		mov R1, A
		loop1:
			mov A, @R0
			mov @R1, A
			dec R1
			dec R0
			djnz R2, loop1
		ret

	copy_a_front:	; copy from front
		loop2:
			mov A, @R0
			mov @R1, A
			inc R0
			inc R1
			djnz R2, loop2
		ret

	memcpy:	
		lcall init_memcpy	;initialize
		mov A, R0			
		subb A, R1		; check which is bigger to confirm the order of copy
		JNC a_front		; a > b
		a_back:
			ACALL copy_a_back
			Jmp fin
		a_front:
			acall copy_a_front
		fin:
		ret


	init_display:
		mov R7, 50H	
		mov R0, 51H
		RET

	display:
		lcall init_display	;initialize
		mov A, R7
		mov R2, A
		loop_display: 
			mov A, @R0
			anl A, #0fh;
			swap A
			mov P1, A
			inc R0
			lcall delay	
			djnz R2, loop_display
		ret
	delay:			; give appropriate delay
		mov R1, 4fh
		mov A, R1
		mov R6, A
		back:
			mov R5, #10
			back1:
				mov R3, #200
				back2:
					mov R4, #0FFh
					back3: 
						djnz R4, back3
						djnz R3, back2
						djnz R5, back1
						djnz R6, back
		ret

	main:
		mov sp, #0CFh
		mov 50h, #10
		mov 51h, #60H
		lcall zero_out	; clear array A memory

		mov 50h, #10
		mov 51h, #65h
		lcall zero_out	; clear array B memory

		mov 50h, #5
		mov 51h, #40h
		mov 52h, #60h
		lcall bin2ascii	; write at memory location A

		mov 50h, #10
		mov 51h, #60H
		mov 52h, #65h
		lcall memcpy	; block copy

		mov 50h, #10
		mov 51h, #65h
		mov 4fh, #5		; user defined delay value
		lcall display

		here : sjmp here
		end
	
		
		
		