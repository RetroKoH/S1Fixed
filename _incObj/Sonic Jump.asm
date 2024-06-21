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
		cmpi.w	#6,d1
		blt.w	locret_1348E
		move.w	#$680,d2
		btst	#6,obStatus(a0)
		beq.s	loc_1341C
		move.w	#$380,d2

loc_1341C:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)			; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)			; make Sonic jump
		bset	#1,obStatus(a0)
		bclr	#5,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		clr.w	obLRLock(a0)			; Mercury Clear Control Lock When Jump
		move.w	#sfx_Jump,d0
		jsr		(PlaySound_Special).l	; play jumping sound
	; Removed code expanding Sonic's radius -- RetroKoH Rolling Jump Fix
		btst	#2,obStatus(a0)			; Is Sonic already in a ball?
		bne.s	loc_13490
	; If not already in a ball, convert Sonic into a ball
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0)		; use "jumping" animation
		bset	#2,obStatus(a0)
		addq.w	#5,obY(a0)

locret_1348E:
		rts	
; ===========================================================================

loc_13490:
	if RollJumpLockActive<>0	; Mercury Rolling Jump Lock Toggle
		bset	#4,obStatus(a0)			; set the roll jump lock.
	endif
		rts	
; End of function Sonic_Jump