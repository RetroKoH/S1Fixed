; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Roll:
		tst.b	(f_slidemode).w
		bne.s	.noroll
; Rewritten to match S3K
	; Check controls first
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0			; is left/right	being pressed?
		bne.s	.noroll					; if yes, branch
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s	Sonic_ChkWalk			; if not, branch and exit

	; Check speeds and roll if fast enough
		move.w	obInertia(a0),d0
		bpl.s	.ispositive
		neg.w	d0

.ispositive:
		cmpi.w	#$80,d0					; is Sonic moving at $80 speed or faster?
		bhs.s	Sonic_ChkRoll			; if so, branch
		move.b	#aniID_Duck,obAnim(a0) 	; use "ducking" animation

.noroll:
		rts	
; ===========================================================================

Sonic_ChkWalk:
		cmpi.b	#aniID_Duck,obAnim(a0)	; is Sonic ducking?
		bne.s	.ret
		move.b	#aniID_Walk,obAnim(a0)	; if so, enter walking animation
.ret
		rts
; ===========================================================================
; S3K Rewrite End

Sonic_ChkRoll:
		btst	#2,obStatus(a0)			; is Sonic already rolling?
		beq.s	.roll					; if not, branch
		rts	
; ===========================================================================

.roll:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)		; use "rolling" animation
		move.b	#fr_SonRoll1,obFrame(a0)	; hard sets frame so no flicker when roll in tunnels - Mercury Roll Frame Fix
		addq.w	#5,obY(a0)
		move.w	#sfx_Roll,d0
		jsr		(PlaySound_Special).l	; play rolling sound
		tst.w	obInertia(a0)
		bne.s	.ismoving
		move.w	#$200,obInertia(a0) 	; set inertia if 0

.ismoving:
		rts	
; End of function Sonic_Roll