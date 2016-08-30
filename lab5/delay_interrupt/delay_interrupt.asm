ORG 0000H
LJMP MAIN
ORG 000BH
;Subroutine of Timer0 overflow
	lcall INITIALIZATION
	djnz R7, fin
	mov R7, #28H
	cpl P1.0
	fin:
		retI

ORG 0100H
INITIALIZATION:
	; Timer0 initialization
	MOV TMOD, #01H;; Timer0 as 16 bit counter
	MOV TH0, #3cH;
	MOV TL0, #0b0H;
	; Enable Timer0 overflow interrupt
	; MOV R7, #14H ; Count to keep track of number of interrupt calls of overflow
	mov IE, #82H
	setb TR0
	RET


;--------------- MAIN STARTS HERE --------------------
MAIN:
LCALL INITIALIZATION
mov R7, #28H
clr P1.0
; Configure the Timer0 to run
OVER: SJMP OVER
END