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
			addq.b	#1,obDoubleJumpFlag(a0)			; Set flag so we can check for Drop Dash.

Sonic_ShieldDoNothing:
		endif
			rts		; No double jump
; ===========================================================================
