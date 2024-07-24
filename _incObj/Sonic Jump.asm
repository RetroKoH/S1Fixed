; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0				; is A, B or C pressed?
		beq.w	locret_1348E			; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1					; does Sonic have enough room to jump?
		blt.w	locret_1348E			; if not, branch
		move.w	#$680,d2
	if SuperMod=1
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	#$800,d2				; set higher jump speed if super
.notSuper:
	endif
		btst	#staWater,obStatus(a0)
		beq.s	loc_1341C
		move.w	#$380,d2

loc_1341C:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		(CalcSine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)				; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)				; make Sonic jump
		bset	#staAir,obStatus(a0)
		bclr	#staPush,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		clr.b	obLRLock(a0)				; Mercury Clear Control Lock When Jump
		move.w	#sfx_Jump,d0
		jsr		(PlaySound_Special).w		; play jumping sound
	; Removed code expanding Sonic's radius -- RetroKoH Rolling Jump Fix
		btst	#staSpin,obStatus(a0)		; Is Sonic already in a ball?
		bne.s	loc_13490
	; If not already in a ball, convert Sonic into a ball
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)		; use "jumping" animation
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)

locret_1348E:
		rts	
; ===========================================================================

loc_13490:
	if RollJumpLockActive<>0	; Mercury Rolling Jump Lock Toggle
		bset	#staRollJump,obStatus(a0)	; set the roll jump lock.
	endif
		rts	
; End of function Sonic_Jump