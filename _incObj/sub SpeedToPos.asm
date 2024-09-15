; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
	; RHS/DeltaW Optimized Object Movement
		movem.w	obVelX(a0),d0/d2
		lsl.l	#8,d0
		add.l	d0,obX(a0)
		lsl.l	#8,d2
		add.l	d2,obY(a0)
		rts

; End of function SpeedToPos