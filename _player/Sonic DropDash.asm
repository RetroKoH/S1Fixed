; ---------------------------------------------------------------------------
; Subroutine enabling Sonic's Drop Dash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_ChkDropDash:
		cmpi.b	#3,obDoubleJumpFlag(a0)		; was the Drop Dash cancelled?
		beq.s	.ret						; if yes, branch
		move.b	obStatus2nd(a0),d0
		btst	#sta2ndInvinc,d0			; is Sonic invincible OR Super?
		bne.s	.skipshieldcheck			; if yes, enable Drop Dash
		andi.b	#mask2ndChkElement,d0		; does Sonic have any elemental shields?
		bne.s	.ret						; if yes, exit

.skipshieldcheck:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0					; is A, B or C held down?
		beq.s	.reset						; if no, branch
		addq.b	#1,obDoubleJumpProp(a0)		; increment charge timer
		cmpi.b	#$14,obDoubleJumpProp(a0)	; is the Drop Dash fully charged? (20 frames)
		blt.s	.ret						; if not yet, exit
		bgt.s	.skipsound					; if yes, and sound has played, skip ahead
		move.b	#aniID_DropDash,obAnim(a0)	; Set new animation
		move.w	#sfx_DropDash,d0
		jsr		(PlaySound_Special).w		; play charge sound

.skipsound:
		move.b	#$15,obDoubleJumpProp(a0)	; set to cap + 1 so we only play the sound once
		rts

.reset:
		move.b	#3,obDoubleJumpFlag(a0)		; disable attempting the Drop Dash (Remove this to allow repeated attempts (toggle?)
		clr.b	obDoubleJumpProp(a0)
		move.b	#aniID_Roll,obAnim(a0)		; reset to rolling animation

.ret:
		rts
; ===========================================================================
