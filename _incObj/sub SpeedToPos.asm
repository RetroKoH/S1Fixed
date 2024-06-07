; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
	; RHS Optimized Object Movement
		move.w	obVelX(a0),d0	; load horizontal speed
		ext.l	d0
		asl.l	#8,d0			; multiply by $100
		add.l	d0,obX(a0)		; add to x-axis	position
		move.w	obVelY(a0),d0	; load vertical	speed
		ext.l	d0
		asl.l	#8,d0			; multiply by $100
		add.l	d0,obY(a0)		; add to y-axis	position
		rts	

; End of function SpeedToPos