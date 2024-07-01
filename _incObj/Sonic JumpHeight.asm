; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:
		tst.b	obJumping(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#staWater,obStatus(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	obVelY(a0),d1
		ble.s	Sonic_DoubleJump
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		bne.s	locret_134C2		; if yes, branch
		move.w	d1,obVelY(a0)

locret_134C2:
		rts	
; ===========================================================================

loc_134C4:
	if SpinDashEnabled=1
		tst.b	obSpinDashFlag(a0)	; is Sonic charging his spin dash?
		bne.w	locret_134D2		; if yes, branch
	endif
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,obVelY(a0)

locret_134D2:
		rts	
; End of function Sonic_JumpHeight
; ===========================================================================

; Shield Moves and/or Drop Dash
Sonic_DoubleJump:

	if ShieldsMode=0

		if DropDashEnabled=1
			tst.b	obDoubleJumpFlag(a0)			; is double jump flag set?
			bne.w	Sonic_ChkDropDash				; if yes, check for Drop Dash
			move.b	(v_jpadpress2).w,d0
			andi.b	#btnABC,d0						; are buttons A, B, or C being pressed?
			beq.s	Sonic_ShieldDoNothing			; if not, branch
			bclr	#staRollJump,obStatus(a0)
			addq.b	#1,obDoubleJumpFlag(a0)			; Set flag so we can check for Drop Dash.

		Sonic_ShieldDoNothing:
		endif
			rts		; No double jump

	else

			tst.b	obDoubleJumpFlag(a0)			; is double jump flag set?

		if DropDashEnabled=1
			bne.w	Sonic_ChkDropDash				; if yes, check for Drop Dash
		else
			bne.s	Sonic_ShieldDoNothing			; if yes, branch and exit
		endif

			move.b	(v_jpadpress2).w,d0
			andi.b	#btnABC,d0						; are buttons A, B, or C being pressed?
			beq.s	Sonic_ShieldDoNothing			; if not, branch
			bclr	#staRollJump,obStatus(a0)

	; Here we check for Shield status to determine which ability to use.
	; Unlike w/ S3K, we will only branch IF we meet the conditions.
			moveq	#0,d0
			move.b	(v_player+obStatus2nd).w,d0
			btst	#sta2ndInvinc,d0				; first, does Sonic have invincibility?
			bne.s	Sonic_ShieldDoNothing			; if so, no shield ability is uaable.
			btst	#sta2ndShield,d0				; does Sonic have any Shield?
			beq.s	Sonic_InstaShieldAttack			; if not, branch to the Insta-Shield.

		if ShieldsMode>1
				btst	#sta2ndFShield,d0				; does Sonic have a Flame Shield?
				bne.s	Sonic_FlameShieldAttack			; if yes, branch
				btst	#sta2ndBShield,d0				; does Sonic have a Bubble Shield?
				bne.s	Sonic_BubbleShieldAttack		; if yes, branch
				btst	#sta2ndLShield,d0				; does Sonic have a Lightning Shield?
				bne.s	Sonic_LightningShieldAttack		; if yes, branch
		endif

	; at this point, we must have a Blue shield. Fall through to do nothing.

			addq.b	#1,obDoubleJumpFlag(a0)			; Set flag. If Drop Dash is enabled, we can check for that.

	Sonic_ShieldDoNothing:
			rts
	; ===========================================================================

	Sonic_InstaShieldAttack:
			addq.b	#1,(v_shieldobj+obAnim).w				; Set animation
			move.b	#1,obDoubleJumpFlag(a0)					; Set to 1. Will be set to 2 when finished.
			move.w	#sfx_InstaAtk,d0
			jmp		(PlaySound_Special).l
	; ===========================================================================

		if ShieldsMode>1
		Sonic_FlameShieldAttack:
				addq.b	#1,(v_shieldobj+obAnim).w				; Set animation
				move.b	#1,obDoubleJumpFlag(a0)					; Set double jump flag
				move.b	#$20,(v_cameralag).w					; hard-coded camera lag
				bsr.s	Reset_Sonic_Position_Array
				move.w	#$800,d0								; Set horizontal speed to 8
				btst	#staFacing,obStatus(a0)					; is Sonic facing left?
				beq.s	.noflip									; if not, branch
				neg.w	d0										; if yes, negate x speed value to move Sonic left

		.noflip:
				move.w	d0,obVelX(a0)							; apply speeds
				move.w	d0,obInertia(a0)
				clr.w	obVelY(a0)
				move.w	#sfx_FShieldAtk,d0
				jmp		(PlaySound_Special).l
		; ===========================================================================

		Sonic_BubbleShieldAttack:
				addq.b	#1,(v_shieldobj+obAnim).w				; Set animation
				move.b	#1,obDoubleJumpFlag(a0)
				clr.w	obVelX(a0)
				clr.w	obInertia(a0)
				move.w	#$800,obVelY(a0)						; send Sonic straight down, to bounce himself up
				move.w	#sfx_BShieldAtk,d0
				jmp		(PlaySound_Special).l
		; ===========================================================================

		Sonic_LightningShieldAttack:
				addq.b	#1,(v_shieldobj+obAnim).w				; Set animation to aniID_LightningSpark
				move.b	#1,obDoubleJumpFlag(a0)
				move.w	#-$580,obVelY(a0)						; y speed set to -5.5, to spring him further upward
				clr.b	obJumping(a0)
				move.w	#sfx_LShieldAtk,d0
				jmp		(PlaySound_Special).l
		; ===========================================================================

		Reset_Sonic_Position_Array:
				lea		(v_tracksonic).w,a1
				move.w	#$3F,d0

		loc_10DEC:
				move.w	obX(a0),(a1)+
				move.w	obY(a0),(a1)+
				dbf		d0,loc_10DEC
				move.w	#0,(v_trackpos).w
				rts
		; End of function Reset_Sonic_Position_Array
		; ===========================================================================
		endif

	endif


	if DropDashEnabled=1
Sonic_ChkDropDash:
		cmpi.b	#3,obDoubleJumpFlag(a0)		; was the Drop Dash cancelled?
		beq.s	.ret						; if yes, branch
		move.b	obStatus2nd(a0),d0
		andi.b	#mask2ndChkElement,d0		; does Sonic have any elemental shields?
		bne.s	.ret						; if yes, exit
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0					; is A, B or C held down?
		beq.s	.reset						; if no, branch
		addq.b	#1,obDoubleJumpProp(a0)		; increment charge timer
		cmpi.b	#$14,obDoubleJumpProp(a0)	; is the Drop Dash fully charged? (20 frames)
		blt.s	.ret						; if not yet, exit
		bgt.s	.skipsound					; if yes, and sound has played, skip ahead
		move.w	#sfx_SpinDash,d0
		jsr		(PlaySound_Special).l		; play charge sound

.skipsound:
		move.b	#$15,obDoubleJumpProp(a0)	; set to cap + 1 so we only play the sound once
		rts

.reset:
		move.b	#3,obDoubleJumpFlag(a0)		; disable attempting the Drop Dash
		clr.b	obDoubleJumpProp(a0)

.ret:
		rts
; ===========================================================================
	endif
