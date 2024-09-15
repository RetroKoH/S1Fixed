; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
	; RHS/DeltaW Optimized Object Movement
		movem.w	obVelX(a0),d0/d2	; load horizontal speed (d0) and vertical speed (d2)
		lsl.l	#8,d0				; multiply by $100 (combine ext and asl to become lsl)
		add.l	d0,obX(a0)			; apply to x-axis position
		lsl.l	#8,d2				; multiply by $100 (combine ext and asl to become lsl)
		add.l	d2,obY(a0)			; apply to y-axis position
		rts

; End of function SpeedToPos