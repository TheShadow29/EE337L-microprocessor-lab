	; Defining Timer-2 registers
	T2CON DATA 0C8H
	T2MOD DATA 0C9H
	RCAP2L DATA 0CAH
	RCAP2H DATA 0CBH
	TL2 DATA 0CCH
	TH2 DATA 0CDH
	; Defining interrupt enable (IE) bit
	ET2 BIT 0ADH
	; Defining interrupt priority (IP) bit
	PT2 BIT 0BDH
	; Defining P1
	T2EX BIT 91H
	T2 BIT 90H
	; Defining timer control (T2CON) register bits
	TF2 BIT 0CFH
	EXF2 BIT 0CEH
	RCLK BIT 0CDH
	TCLK BIT 0CCH
	EXEN2 BIT 0CBH
	TR2 BIT 0CAH
	C_T2 BIT 0C9H
	CP_RL2 BIT 0C8H

;start of code
org 0000H
	ljmp main
; org 002Bh
; 	cpl P1.4
; 	clr TF2
; 	reti

org 0100H
;Timer-2 initialization
	T2_INIT:
		mov T2MOD,#03H;			t2oe, and dcen set
		; CLR EXF2;
		; ;Next, disable baud rate generator*/
		; clr RCLK
		; clr TCLK
		; ;Next. ignore events on T2EX*/
		; clr EXEN2
		mov T2CON, #00H
		
		;Initialize values in TH2, TL2 depending on required frequency
		MOV TH2,#15H;
		;Init msb_value */
		MOV TL2,#0A0H; /* Init lsb_value */
		;Reload values in RCAP
		MOV RCAP2H,#15H;
		;reload msb_value */
		MOV RCAP2L,#0A0H;
		;reload lsb_value */
		; CLR C_T2;
		; ;timer mode */
		; CLR CP_RL2;
		; ;reload mode */
		clr IE.7
		clr IE.5;
		;clear timer2 interrupt */
		ret
;--------------- MAIN STARTS HERE --------------------
	main:
		;Port initialization
		
		lcall T2_INIT
		setb TR2
		over: SJMP over
end