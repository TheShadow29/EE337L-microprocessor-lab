org 00h
	ljmp bin2excess3

org 100h

bin2excess3:
	lcall readnibble
	mov A, R7
	cjne A, #0Ah, next ; carry if A < 10
	next:
		JNC display_all
		add A, #03H
		swap A
		mov P1, A
		ljmp bin2excess3
	display_all:
		mov A, #0ffh
		mov P1, A
		lcall delay_5
		ljmp bin2excess3


	
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