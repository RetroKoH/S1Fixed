; ---------------------------------------------------------------------------
; Object 47 - pinball bumper (SYZ)
; ---------------------------------------------------------------------------

Bumper:
		_move.l	#Bump_Hit,obAddr(a0)
		move.l	#Map_Bump,obMap(a0)
		move.w	#make_art_tile(ArtTile_SYZ_Bumper,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colSpecial|colSz_8x8_2),obColType(a0)
; ---------------------------------------------------------------------------

Bump_Hit:
		tst.b	obColProp(a0)				; has Sonic touched the	bumper?
		beq.w	.display					; if not, branch
		clr.b	obColProp(a0)
		lea		(v_player).w,a1
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1					; get distance betwen Sonic & bumper
		sub.w	obY(a1),d2
		jsr		(CalcAngle).w				; convert to angle
		jsr		(CalcSine).w				; convert to sine/cosine
		muls.w	#-$700,d1					; multiply by bumper's power
		asr.l	#8,d1
		move.w	d1,obVelX(a1)				; bounce Sonic away
		muls.w	#-$700,d0					; multiply by bumper's power
		asr.l	#8,d0
		move.w	d0,obVelY(a1)				; bounce Sonic away
		bset	#staAir,obStatus(a1)
		andi.b	#~(maskRollJump+maskPush),obStatus(a1)	; clear RollJump and Push flags ($CF)
		clr.b	obJumping(a1)

	if WallJumpEnabled	; Mercury Wall Jump
		clr.w	obWallJump(a1)				; clear Wall Jump data
	endif

		move.b	#1,obAnim(a0)				; use "hit" animation
		move.w	#sfx_Bumper,d0
		jsr		(QueueSound2).w				; play bumper sound
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.addscore					; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		cmpi.b	#$8A,(a2)					; has bumper been hit 10 times?
		bhs.s	.display					; if yes, Sonic	gets no	points
		addq.b	#1,(a2)

	.addscore:
		moveq	#1,d0
		jsr		(AddPoints).l				; add 10 to score
		bsr.w	FindFreeObj
		bne.s	.display
		_move.l	#Points,obAddr(a1) 		; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#4,obFrame(a1)

	.display:
		lea		Ani_Bump(pc),a1
		jsr		(AnimateSprite).w
		out_of_range.s	.resetcount
		bra.w	DisplayAndCollision			; S3K TouchResponse
; ===========================================================================

	.resetcount:
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.w	DeleteObject				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject
; ===========================================================================