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
			bra.w	DropDash

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
					bra.w	DropDash

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
		jmp		(PlaySound_Special).l
; End of function BubbleShield_Bounce
	endif

	if DropDashEnabled=1
; ---------------------------------------------------------------------------
; Subroutine to	allow Sonic to perform the Drop Dash
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


DropDash:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
		move.w	#$800,d1
		move.w	#$C00,d2
		btst	#staFacing,obStatus(a0)
		bne.s	.facingleft
		move.w	obInertia(a0),d0
		asr.w	#2,d0
		add.w	d1,d0
		move.w  d0,obInertia(a0)            ; move d0 (new dashspeed) to Sonic's inertia
		cmp.w	d2,d0
		blt.s	.skipcap
		move.w	d2,obInertia(a0)
		bra.s	.skipcap

	.facingleft:
		neg.w	d1
		neg.w	d2
		move.w	obInertia(a0),d0
		asr.w	#2,d0
		add.w	d1,d0
		move.w  d0,obInertia(a0)            ; move d0 (new dashspeed) to Sonic's inertia
		cmp.w	d2,d0
		bgt.s	.skipcap
		move.w	d2,obInertia(a0)

	.skipcap:
		cmpi.w  #$FC0,obVelY(a0)		; is Sonic's vertical velocity $FC0?
        ble.s   .notOnSlope				; if less or equal, charge like not on a slope
        move.w  #$FC0,obVelY(a0)		; set Sonic's vertical velocity to $FC0
        lsr.w   #1,obInertia(a0)		; divide Sonic's inertia by 2 (2^1)
	.notOnSlope:
		bset	#staSpin,obStatus(a0)
		clr.b	obDoubleJumpFlag(a0)
		clr.b	obDoubleJumpProp(a0)
		rts
	endif