; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; Going to apply a rewrite from DeltaWooloo, Hitaxas, and Sonic 1 Complete
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:
		btst	#staRollJump,obStatus(a0)
		beq.s	loc_137AE
		nop

loc_137AE:
		andi.b	#~(maskAir+maskRollJump+maskPush),obStatus(a0)	; Should clear Air, RollJump and Push bits ($CD)
		btst	#staSpin,obStatus(a0)
		beq.s	loc_137E4
		bclr	#staSpin,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Walk,obAnim(a0)	; use running/walking animation
		subq.w	#5,obY(a0)				; move Sonic up 5 pixels so the increased height doesn't push him into the ground  

loc_137E4:
		clr.b	obDoubleJumpFlag(a0)
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w
		rts	
; End of function Sonic_ResetOnFloor