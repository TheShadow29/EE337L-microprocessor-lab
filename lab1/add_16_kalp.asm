ORG 0000H
LJMP MAIN

;R0 and R1 should contain the address of two no.s
;location given by R0:- 	MSB of 1st no.
;location given by R0+1:-	LSB of 1st no.
;location given by R1:- 	MSB of 1st no.
;location given by R1+1:-	LSB of 1st no.
;location given by R0+2:- 	CARRY	
;location given by R0+3:-	MSB OF ANS	
;location given by R0+4:- 	LSB OF ANS

;---------------------------------------------------------;
;this function adds and stores result in appropriate location
ADDER_16BIT:
	;-- push the registers which will be affected by this subroutine 
	;	but will be needed later 	
	
	;-- perform the addition/subtraction of 2 16-bit no.s
	;-- you may use subroutine wrtten for addition of 2 8-bit no.s
	;-- remember the no.s are given in 2's complement form
	
	;-- take care when you set carry/borrow.
	
	;-- store the result at appropriate locations.
	MOV A, 60h
	RLC A
	JNC next1
	MOV R2,#01h
	next1:
	RRC A
	MOV R3,A
	MOV A, 70h
	RLC A
	JNC next2
	MOV R4,#01h
	next2: 
	RRC A
	MOV R5,A
	
	MOV A, 61h
	ADD A, 71h
	MOV 64h, A
	MOV A, R3
	ADDC A, R5
	MOV 63h, A
	
	MOV A,R2
	ADDC A,R4
	ANL A,#01h
	MOV 62h, A
	RETURN:
	RET

INIT:
	;-- store the numbers to be added/subtracted at appropriate location
	MOV 60h,#0FFh
	MOV 61h,#00h
	MOV 70h,#001h
	MOV 71h,#00h
	RET


ORG 0100H
MAIN:
	MOV SP,#0C0H	;move stack pointer to indirect RAM location
	;ACALL INIT
	ACALL ADDER_16BIT
A1:  
	SJMP A1
