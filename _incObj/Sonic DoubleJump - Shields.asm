; ---------------------------------------------------------------------------
; Subroutine enabling double jump techniques for Sonic
; This version has S3K Shields included, along with optional Drop Dash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_DoubleJump:
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
