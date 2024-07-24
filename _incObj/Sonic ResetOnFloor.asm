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

	if ShieldsMode=0

		if DropDashEnabled=1
			tst.b	obDoubleJumpFlag(a0)
			beq.s	.ret
			cmpi.b	#$14,obDoubleJumpProp(a0)	; is it fully revved up?
			blt.s	.noability					; if not, exit
			bra.w	DropDash_Release

		.noability:
			clr.b	obDoubleJumpFlag(a0)
			clr.b	obDoubleJumpProp(a0)
		endif

		.ret:
			rts	
; End of function Sonic_ResetOnFloor
	else				; Mode 1+
	
		if ShieldsMode>1			; Mode 2+
				tst.b	obDoubleJumpFlag(a0)
				beq.s	.ret
				btst	#sta2ndBShield,obStatus2nd(a0)	; does Sonic have a Bubble Shield?
				beq.s	.nobubble
				bra.s	BubbleShield_Bounce

			.nobubble:
			if DropDashEnabled=1
					move.b	obStatus2nd(a0),d0
					andi.b	#mask2ndChkElement,d0		; Check for any elemental shields
					bne.s	.noability					; if he has, we will exit
					cmpi.b	#$14,obDoubleJumpProp(a0)	; is it fully revved up?
					blt.s	.noability					; if not, exit
					bra.w	DropDash_Release

				.noability:
			endif
		
		endif						; Mode 2+

		clr.b	obDoubleJumpFlag(a0)
		clr.b	obDoubleJumpProp(a0)

		.ret:
			rts	
	; End of function Sonic_ResetOnFloor
	endif				; Mode 1+


	if ShieldsMode>1
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
		jmp		(PlaySound_Special).w
; End of function BubbleShield_Bounce
	endif

	if DropDashEnabled=1
; ---------------------------------------------------------------------------
; Subroutine to	allow Sonic to perform the Drop Dash
; Modified (possibly fixed) thanks to Hitaxas
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


DropDash_Release:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)

		move.w	#$800,d1				; base dash speed
		move.w	#$C00,d2				; max dash speed

		move.w	obInertia(a0),d3
		bgt.s	.checkangle 			; if inertia>0, branch
		asr.w	#2,d3					; divide ground speed by 4
		add.w	d1,d3					; add speed base to ground speed
		cmp.w	d2,d3					; check if current speed is lower than speed cap
		blt.s	.noangle				; if not, branch
		move.w	d2,d3					; if yes, cap speed
		bra.s	.checkdir
		
.checkangle:
		tst.b	obAngle(a0)				; test if Sonic is on an angle
		beq.s	.noangle 				; if yes, branch
		asr.w	#1,d3					; divide ground speed by 2
		add.w	d1,d3					; add speed base to ground speed
		bra.s	.checkdir				; set result as actual ground speed

.noangle:
		move.w	d1,d3 					; move base dash speed to inertia

.checkdir:	
		btst	#staFacing,obStatus(a0)	; is sonic facing left?
		beq.s	.setspeed				; if no, branch
		neg.w	d3

.setspeed:
		move.w	d3,obInertia(a0)		; move dash speed into inertia	
		move.w	#sfx_Teleport,d0
		jsr		(PlaySound_Special).w	; play spindash release sfx

.finish:
		bset	#staSpin,obStatus(a0)
		clr.b	obDoubleJumpFlag(a0)
		clr.b	obDoubleJumpProp(a0)
		rts
	endif