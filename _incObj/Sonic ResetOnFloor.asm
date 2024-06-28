; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:
		andi.b	#~(maskAir+maskRollJump+maskPush),obStatus(a0)	; Should clear Air, RollJump and Push bits ($CD)
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w
		btst	#staSpin,obStatus(a0)			; is Sonic spinning?
		beq.s	.ret							; if not, branch
	; If Sonic is spinning upon landing
		bclr	#staSpin,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Walk,obAnim(a0)			; use running/walking animation
		subq.w	#5,obY(a0)						; move Sonic up 5 pixels so the increased height doesn't push him into the ground 
		tst.b	obDoubleJumpFlag(a0)
		beq.s	.ret
		btst	#sta2ndBShield,obStatus2nd(a0)	; does Sonic have a Bubble Shield?
		beq.s	.nobubble
		bra.s	BubbleShield_Bounce

.nobubble:
	; Add Drop Dash Check here
		clr.b	obDoubleJumpFlag(a0)

.ret:
		rts	
; End of function Sonic_ResetOnFloor

; ---------------------------------------------------------------------------
; Subroutine to	bounce Sonic in the air when he has a bubble shield
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


BubbleShield_Bounce:
		movem.l	d1-d2,-(sp)
		move.w	#$780,d2
		btst	#staWater,obStatus(a0)
		beq.s	.nowater
		move.w	#$400,d2

	.nowater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		CalcSine
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		movem.l	(sp)+,d1-d2
		bset	#staAir,obStatus(a0)
		bclr	#staPush,obStatus(a0)
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)
		move.b	#aniID_BubbleBounceUp,(v_shieldobj+obAnim).w
		clr.b	obDoubleJumpFlag(a0)
		move.w	#sfx_BShieldAtk,d0
		jmp		(PlaySound_Special).l
; End of function BubbleShield_Bounce