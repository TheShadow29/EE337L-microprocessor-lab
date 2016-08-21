org 00h
	ljmp read_values

org 100h

init_read_values:
	mov 50H, #49H
	mov 51H, #65H
	mov R2, 50H
	mov R0, 51H
	ret


read_values:
	lcall init_read_values
	loop_read:
		lcall pack_nibbles
		mov A, 4fh
		mov @R0, A
		inc R0
		djnz R2, loop_read
	here : sjmp here


pack_nibbles:
	lcall readnibble
	mov A, R7
	mov R6, A
	lcall delay_5
	lcall readnibble
	mov A, R6
	swap A
	orl A, R7
	mov 4fh, A

	ret

; set pins 0-3 for configuring as input pins
; read value on pins
readnibble:
	mov P1, #0fh
	mov A, P1
	anl A, #0fh
	mov R7, A
	ret

delay_5:
	mov R3, #100
	back15:
		mov R4, #200
	back25:
		mov R5, #0FFh
	back35: 
		djnz R5, back35
		djnz R4, back25
		djnz R3, back15
	ret
	
	end