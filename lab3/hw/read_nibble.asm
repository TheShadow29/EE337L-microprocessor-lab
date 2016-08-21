org 00h
	ljmp main

org 100h
main:
	lcall first_init
	sjmp loop

;display data from 4eh
;read the input on P1.0-P1.3 (nibble)
;if read value != 0Fh go to loop
;else return to caller with previously read nibble in location 4EH (lower 4 bits).
old_data:	
	mov A, 4eH
	swap A
	mov P1, A
	sjmp loop
	
;turn on all 4 leds (routine is ready to accept input)
;wait for 5 sec during which user can give input 
;clear pins P1.4 to P1.7
;read the input on P1.0-P1.3 (nibble)
;wait for one sec
;show the read value on pins P1.4-P1.7
;wait for 5 sec 
;clear leds
;read the input from switches
;if read value != 0Fh go to loop
;else return to caller with previously read nibble in location 4EH (lower 4 bits).
first_init:
	lcall delay_5
	lcall readnibble
	mov A, P1
	anl A, #0Fh
	mov P1, A	;;clearing out the bits
	lcall display
	ret

display:
	lcall delay_1
	mov A, R7
	swap A
	mov P1, A
	lcall delay_5
	mov A, P1
	anl A, #0fH
	mov P1, A
	ret

loop:
	lcall readnibble
	mov A, R7
	xrl A, #0Fh
	JZ old_data
	mov 4eH, R7
	lcall display
	sjmp loop


						
stop:
	sjmp stop
	
; set pins 0-3 for configuring as input pins
; read value on pins
readnibble:
	; mov A, #0ffh	;set all pins as high to configure port 1 as input
	; mov P1, A
	mov P1, #0ffh
	mov A, P1
	anl A, #0fh
	mov R7, A
	ret

delay_1:
	mov R3, #20
	back1:
		mov R4, #200
	back2:
		mov R5, #0FFh
	back3: 
		djnz R5, back3
		djnz R4, back2
		djnz R3, back1
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