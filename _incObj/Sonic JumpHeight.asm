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
		rts		; No double jump
	else
		tst.b	obDoubleJumpFlag(a0)					; is Sonic currently performing a double jump?
		bne.s	Sonic_ShieldDoNothing					; if yes, branch
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0								; are buttons A, B, or C being pressed?
		beq.s	Sonic_ShieldDoNothing					; if not, branch
		bclr	#staRollJump,obStatus(a0)

; Here we check for Shield status to determine which ability to use.
; Unlike w/ S3K, we will only branch IF we meet the conditions.
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; first, does Sonic have invincibility?
		bne.s	Sonic_ShieldDoNothing					; if so, no shield ability is uaable.
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have any Shield?
		beq.s	Sonic_InstaShieldAttack					; if not, branch to the Insta-Shield.
	if ShieldsMode>1
		btst	#sta2ndFShield,(v_player+obStatus2nd).w	; does Sonic have a Flame Shield?
		bne.s	Sonic_FlameShieldAttack					; if yes, branch
		btst	#sta2ndBShield,(v_player+obStatus2nd).w	; does Sonic have a Bubble Shield?
		bne.s	Sonic_BubbleShieldAttack				; if yes, branch
		btst	#sta2ndLShield,(v_player+obStatus2nd).w	; does Sonic have a Lightning Shield?
		bne.s	Sonic_LightningShieldAttack				; if yes, branch
	endif
; at this point, we must have a Blue shield. Fall through to do nothing.

Sonic_ShieldDoNothing:
		rts
; ===========================================================================

Sonic_InstaShieldAttack:
		addq.b	#1,(v_shieldobj+obAnim).w				; Set animation
		move.b	#1,obDoubleJumpFlag(a0)
		move.w	#sfx_InstaAtk,d0
		jmp		(PlaySound_Special).l
; ===========================================================================
	if ShieldsMode>1
Sonic_FlameShieldAttack:
		addq.b	#1,(v_shieldobj+obAnim).w				; Set animation
		move.b	#1,obDoubleJumpFlag(a0)					; Set double jump flag
		move.w	#$800,d0								; Set horizontal speed to 8
		move.b	#$10,(v_cameralag).w					; hard-coded camera lag
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
	endif

	endif
