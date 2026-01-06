; ---------------------------------------------------------------------------
; Object - buzz bomber missile vanishing (unused)
; ---------------------------------------------------------------------------

MissileDissolve:
		_move.l	#MDis_Animate,obAddr(a0)
		move.l	#Map_MisDissolve,obMap(a0)
		move.w	#make_art_tile(ArtTile_Missile_Disolve,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obColType(a0)
		move.b	#$C,obDispWid(a0)
		move.b	#9,obTimeFrame(a0)
		clr.b	obFrame(a0)
		move.w	#sfx_A5,d0
		jsr		(QueueSound2).w				; play sound
; ---------------------------------------------------------------------------

MDis_Animate:
		subq.b	#1,obTimeFrame(a0)			; subtract 1 from frame duration
		bpl.w	DisplaySprite
		move.b	#9,obTimeFrame(a0)			; set frame duration to 9 frames
		addq.b	#1,obFrame(a0)				; next frame
		cmpi.b	#4,obFrame(a0)				; has animation completed?
		beq.w	DeleteObject				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

; ---------------------------------------------------------------------------
; Object - explosion from a destroyed enemy or monitor
; ---------------------------------------------------------------------------

ExplosionItem:
		_move.l	#ExItem_Main,obAddr(a0)
		bsr.w	FindFreeObj
		bne.s	ExItem_Main					; branch if no free object slot is found

	; RetroKoH/DeltaW Enemies Drop Rings Mod
	if EnemiesDropRings
		_move.l	#RingLoss,obAddr(a1)		; load ring object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#1,obRLoss_BadnikFlag(a1)	; set flag to tell the game we don't want mass spawning of rings here
		move.w	obEnemy_Combo(a0),obEnemy_Combo(a1)
	else
		_move.l	#Animals,obAddr(a1)		; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obEnemy_Combo(a0),obEnemy_Combo(a1)
	endif
	; Enemies Drop Rings Mod End
; ---------------------------------------------------------------------------

ExItem_Main:
		_move.l	#ExItem_Animate,obAddr(a0)
		move.l	#Map_ExplodeItem,obMap(a0)
		move.w	#make_art_tile(ArtTile_Explosion,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obColType(a0)
		move.b	#$C,obDispWid(a0)
		move.b	#7,obTimeFrame(a0)			; set frame duration to 7 frames
		clr.b	obFrame(a0)
		move.w	#sfx_BreakItem,d0
		jsr		(QueueSound2).w				; play breaking enemy sound
; ---------------------------------------------------------------------------

ExItem_Animate:
		subq.b	#1,obTimeFrame(a0)			; subtract 1 from frame duration
		bpl.w	DisplaySprite
		move.b	#7,obTimeFrame(a0)			; set frame duration to 7 frames
		addq.b	#1,obFrame(a0)				; next frame
		cmpi.b	#5,obFrame(a0)				; is the final frame (05) displayed?
		beq.w	DeleteObject				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

; ---------------------------------------------------------------------------
; Object - explosion from a destroyed boss, bomb or cannonball
; ---------------------------------------------------------------------------

ExplosionBomb:
		_move.l	#ExItem_Animate,obAddr(a0)
		move.l	#Map_ExplodeBomb,obMap(a0)
		move.w	#make_art_tile(ArtTile_Explosion,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obColType(a0)
		move.b	#$C,obDispWid(a0)
		move.b	#7,obTimeFrame(a0)
		clr.b	obFrame(a0)
		move.w	#sfx_Bomb,d0
		jmp		(QueueSound2).w				; play exploding bomb sound
; ===========================================================================
