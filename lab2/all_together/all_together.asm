; Simple 8 bit adder

org 000H;
led equ P1
	Ljmp main
org 50H
	INIT_zero_out:
		; store the numbers to be added/subtracted at appropiate locations
		mov R2, 50H
		mov R0, 51H
		; mov R1, #51H	
		RET

	zero_out:
		lcall INIT_zero_out
		mov A, R2
		mov R3, A
		loop: 
			mov @R0, #00h
			inc R0
			djnz R3, loop
		ret
	init_bin2ascii:
		; store the numbers to be added/subtracted at appropiate locations
		mov R2, 50H
		mov R0, 51H	;read pointer
		mov R1, 52H	;write pointer
		mov R3, #30H
		RET

	bin2ascii:
		lcall init_bin2ascii
		loop_bin:
			mov A, @R0
			anl A, #0f0h
			swap A
			cjne A, #0AH, next
		next: 
			JC next2
			inc A
		next2:
			add A, R3
			DA A
			mov @R1, A
			inc R1
			mov A, @R0
			anl A, #0fH;
			cjne A, #0AH, next3
		next3:
			JC next4
			inc A
		next4:
			add A, R3
			DA A
			mov @R1, A
			inc R1
			inc R0
			djnz R2, loop_bin
		ret

	init_memcpy:
		; store the numbers to be added/subtracted at appropiate locations
		mov R2, 50H
		mov R0, 51H
		mov R1, 52H
		
		; mov R1, #51H	
		RET

	memcpy:
		mov R3, #02H
		lcall init_memcpy
		mov R1, #20H
		cp_temp:
			mov A, @R0
			mov @R1, A
			inc R0
			inc R1
			djnz R2, cp_temp
		lcall init_memcpy
		mov R0, #20H
		djnz R3, cp_temp
		ret

	init_display:
		; store the numbers to be added/subtracted at appropiate locations	
		mov R7, 50H
		mov R0, 51H
		RET

	display:
		lcall init_display
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
	delay:
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

		mov 50h, #3
		mov 51h, #40h
		mov 52h, #60h
		lcall bin2ascii	; write at memory location A

		mov 50h, #6
		mov 51h, #60H
		mov 52h, #65h
		lcall memcpy	; block copy

		mov 50h, #6
		mov 51h, #65h
		mov 4fh, #5		; user defined delay value
		lcall display

		here : sjmp here
		end
	
		
		
		