; ---------------------------------------------------------------------------
; Subroutine enabling double jump techniques for Sonic
; This version only enables an optional drop dash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_DoubleJump:
	if DropDashEnabled=1
			tst.b	obDoubleJumpFlag(a0)			; is double jump flag set?
			bne.s	Sonic_ChkDropDash				; if yes, check for Drop Dash
			move.b	(v_jpadpress2).w,d0
			andi.b	#btnABC,d0						; are buttons A, B, or C being pressed?
			beq.s	Sonic_ShieldDoNothing			; if not, branch
			bclr	#staRollJump,obStatus(a0)

		if SuperMod=1
			btst	#sta2ndSuper,d0					; is Sonic currently in his Super form?
			bne.s	Sonic_SetDoubleJumpFlag			; if yes, branch towards the exit
			;cmpi.b	#emldCount,(v_emeralds).w		; does Sonic have all Chaos Emeralds?
			;bcs.s	Sonic_NoSuper					; if not, branch
			cmpi.w	#10,(v_rings).w					; does Sonic have 50 rings or more?
			bcs.s	Sonic_NoSuper					; if not, branch
			tst.b	(f_timecount).w					; is the timer currently running? (Prevent the S2 bug)
			bne.s	Sonic_TurnSuper					; if yes, branch

Sonic_SetDoubleJumpFlag:
Sonic_NoSuper:
		endif

			addq.b	#1,obDoubleJumpFlag(a0)			; Set flag so we can check for Drop Dash.

	else

		if SuperMod=1
			move.b	(v_jpadpress2).w,d0
			andi.b	#btnABC,d0						; are buttons A, B, or C being pressed?
			beq.s	Sonic_ShieldDoNothing			; if not, branch
			btst	#sta2ndSuper,d0					; is Sonic currently in his Super form?
			bne.s	Sonic_NoSuper					; if yes, branch towards the exit
			;cmpi.b	#emldCount,(v_emeralds).w		; does Sonic have all Chaos Emeralds?
			;bcs.s	Sonic_NoSuper					; if not, branch
			cmpi.w	#10,(v_rings).w					; does Sonic have 50 rings or more?
			bcs.s	Sonic_NoSuper					; if not, branch
			tst.b	(f_timecount).w					; is the timer currently running? (Prevent the S2 bug)
			bne.s	Sonic_TurnSuper					; if yes, branch

Sonic_NoSuper:
		endif

	endif
Sonic_ShieldDoNothing:
		rts		; No double jump
; ===========================================================================
