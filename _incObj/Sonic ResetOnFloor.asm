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
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Walk,obAnim(a0)			; use running/walking animation
		bclr	#staSpin,obStatus(a0)
		subq.w	#5,obY(a0)						; move Sonic up 5 pixels so the increased height doesn't push him into the ground

	if ShieldsMode<2

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
	else				; Mode 2+

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
				; This should fix a bug w/ unusual looking Flame Shield Animating (RetroKoH)
				btst	#sta2ndFShield,obStatus2nd(a0)	; does Sonic have a Flame Shield?
				beq.s	.noflame
				move.b	#aniID_FlameShield,(v_shieldobj+obAnim).w	; reset animation upon landing

			.noflame:
		endif

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
; Modified (possibly fixed) thanks to Giovanni
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


DropDash_Release:
		move.w	#$800,d2						; minimum speed
		move.w	#$C00,d3						; maximum speed
		btst	#sta2ndSuper,obStatus2nd(a0)	; is player super?
		beq.s	.notSuper						; if not, branch
		move.w	#$C00,d2						; else, use alt values
		move.w	#$D00,d3

.notSuper:
		move.w	obInertia(a0),d4
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		bne.s	.dropLeft				; if yes, branch	
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		bne.s	.dropRight				; if yes, branch		
		btst	#staFacing,obStatus(a0)	; if neither are being pressed, check orientation
		beq.s	.dropRight

.dropLeft:
		neg.w	d2						; negate base value
		neg.w	d3						; negate base value

		bset	#staFacing,obStatus(a0)	; force orientation to correct one
		tst.w	obVelX(a0)				; check if speed is greater than 0
		bgt.s	.dropSlopeLeft			; if yes, branch
		asr.w	#2,d4           		; divide ground speed by 4
		add.w	d2,d4           		; add speed base to ground speed
		cmp.w	d3,d4           		; check if current speed is lower than speed cap
		bgt.s	.setspeed				; if not, branch
		move.w	d3,d4					; if yes, cap speed
		bra.s	.setspeed

.dropSlopeLeft:
		tst.b	obAngle(a0)				; check if Sonic is on a flat surface
		beq.s	.dropBackLeft			; if yes, branch
		asr.w	#1,d4					; divide ground speed by 2
		add.w	d2,d4					; add speed base to ground speed
		bra.s	.setspeed

.dropBackLeft:
		move.w	d2,d4					; move speed base to ground speed
		bra.s	.setspeed
		
.dropMaxLeft:
		move.w	d3,d4					; grant sonic the highest possible speed
		bra.s	.setspeed

.dropRight:
		bclr	#staFacing,obStatus(a0)	; force orientation to correct one			
		tst.w	obVelX(a0)				; check if speed is lower than 0
		blt.s	.dropSlopeRight			; if yes, branch
		asr.w	#2,d4           		; divide ground speed by 4
		add.w	d2,d4           		; add speed base to ground speed
		cmp.w	d3,d4           		; check if current speed is lower than speed cap
		blt.s	.setspeed				; if not, branch
		move.w	d3,d4			  		; if yes, cap speed
		bra.s	.setspeed
		
.dropSlopeRight:
		tst.b	obAngle(a0)				; check if Sonic is on a flat surface
		beq.s	.dropBackRight			; if yes, branch
		asr.w	#1,d4					; divide ground speed by 2
		add.w	d2,d4					; add speed base to ground speed
		bra.s	.setspeed
	
.dropBackRight:
		move.w	d2,d4					; move speed base to ground speed 
		bra.s	.setspeed
	
.dropMaxRight:
		move.w	d3,d4
		
.setspeed:	
		move.w	d4,obInertia(a0)			; move dash speed into inertia	

		move.b	#$10,(v_cameralag).w
		bsr.w	Reset_Sonic_Position_Array
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)					; add the difference between Sonic's rolling and standing heights
		clr.b	obDoubleJumpFlag(a0)
		clr.b	obDoubleJumpProp(a0)

	; Create drop dash dust
		jsr		(FindFreeObj).l
		bne.s	.noDust
		_move.b	#id_Effects,obID(a1)		; load obj07
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)	; match Player's x orientation
		andi.b	#maskFacing,obStatus(a1)	; only retain staFacing (staFlipX)
		move.b	#3,obAnim(a1)
		move.b	#2,obRoutine(a1)
		move.l	#Map_Effects,obMap(a1)
		ori.b	#4,obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obActWid(a1)
		move.w	#ArtTile_Dust,obGfx(a1)
		movea.l	a0,a1

		move.w	#sfx_Teleport,d0
		jmp		(PlaySound_Special).w		; play spindash release sfx

.noDust:
		movea.l	a0,a1
		rts
	endif