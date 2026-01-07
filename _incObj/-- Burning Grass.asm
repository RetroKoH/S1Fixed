; ---------------------------------------------------------------------------
; Object 35 - fireball that sits on the	floor (MZ)
; (appears when	you walk on sinking platforms)
; ---------------------------------------------------------------------------

GrassFire:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GFire_Index(pc,d0.w),d1
		jmp		GFire_Index(pc,d1.w)
; ===========================================================================
GFire_Index:	offsetTable
		offsetTableEntry.w GFire_Main
		offsetTableEntry.w GFire_Spread
		offsetTableEntry.w GFire_Move
; ===========================================================================

GFire_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> GFire_Spread
		move.l	#Map_Fire,obMap(a0)
		move.w	#make_art_tile(ArtTile_Fireball,0,0),obGfx(a0)
		move.w	obX(a0),obGFire_StartX(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_8x8),obColType(a0)

		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield

		move.b	#8,obDispWid(a0)
		move.w	#sfx_Burning,d0
		jsr		(QueueSound2).w	 				; play burning sound
		tst.b	obSubtype(a0)					; is this the first fireball?
		beq.s	GFire_Spread					; if yes, branch
		addq.b	#2,obRoutine(a0)				; if not, -> GFire_Move
		bra.w	GFire_Move
; ===========================================================================

GFire_Spread:	; Routine 2
		movea.l	obGFire_ColPtr(a0),a1			; a1 = pointer to platform heightmap
		move.w	obX(a0),d1
		sub.w	obGFire_StartX(a0),d1			; d1 = relative x position on platform
		addi.w	#$C,d1
		move.w	d1,d0
		lsr.w	#1,d0
		move.b	(a1,d0.w),d0					; get value from heightmap
		neg.w	d0
		add.w	obGFire_StartY(a0),d0			; get initial y position
		move.w	d0,d2
		add.w	obGFire_SinkPixels(a0),d0		; add difference when platform sinks
		move.w	d0,obY(a0)						; update y position
		cmpi.w	#$84,d1
		bhs.s	.no_fire						; branch if beyond right edge of platform
		addi.l	#$10000,obX(a0)					; move 1px right
		cmpi.w	#$80,d1
		bhs.s	.no_fire
		move.l	obX(a0),d0
		addi.l	#$80000,d0
		andi.l	#$FFFFF,d0
		bne.s	.no_fire

		bsr.w	FindNextFreeObj					; find free object RAM slot
		bne.s	.no_fire						; branch if not found
		_move.l	#GrassFire,obAddr(a1)			; create another fire
		move.w	obX(a0),obX(a1)
		move.w	d2,obGFire_StartY(a1)			; initial y pos (ignores platform sinking)
		move.w	obGFire_SinkPixels(a0),obGFire_SinkPixels(a1)
		move.b	#1,obSubtype(a1)				; child type, doesn't spawn more fire
		movea.w	obGFire_Parent(a0),a2
		bsr.w	LGrass_AddChildToList			; add to list in parent's object RAM

	.no_fire:
		bra.s	GFire_Animate
; ===========================================================================

GFire_Move:	; Routine 4
		move.w	obGFire_StartY(a0),d0
		add.w	obGFire_SinkPixels(a0),d0
		move.w	d0,obY(a0)						; update position

GFire_Animate:
		lea		Ani_GFire(pc),a1
		bsr.w	AnimateSprite
		jmp		(DisplayAndCollision).l
; ===========================================================================