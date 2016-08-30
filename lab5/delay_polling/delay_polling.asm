
org 00H

	Ljmp main
org 50H
	INIT:
		mov TMOD, #01H
		clr TF0
		mov TH0, #03ch
		mov TL0, #0b0h
		setb TR0
		RET

	delay_polling:
		mov R2, #00H
		lcall INIT
		count:
			jnb TF0, fin
			lcall INIT
			inc R2
			fin:
			cjne R2, #14H, count
		ret
	main:
		
		here:
			lcall delay_polling
			setb P1.0
			lcall delay_polling
			clr P1.0
			sjmp here
		end

			
		
		
		