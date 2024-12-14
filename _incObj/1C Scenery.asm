; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, SLZ lava thrower)
; ---------------------------------------------------------------------------

Scenery:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Scen_ChkDel
	; Object Routine Optimization End

Scen_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0		; copy object subtype to d0
		add.w	d0,d0					; multiply by 10 ($A)
		move.w	d0,d1					; Optimization from S1 in S.C.E.
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		lea		Scen_Values(pc,d0.w),a1
		move.l	(a1)+,obMap(a0)
		move.w	(a1)+,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.w	(a1)+,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

Scen_ChkDel:	; Routine 2
		offscreen.w	DeleteObject		; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Variables for	object $1C are stored in an array
; ---------------------------------------------------------------------------
Scen_Values:
		dc.l Map_Scen											; mappings address
		dc.w make_art_tile(ArtTile_SLZ_Fireball_Launcher,2,0)	; VRAM setting
		dc.b 0,	8                                   			; frame, width
		dc.w priority2											; priority

		dc.l Map_Scen
		dc.w make_art_tile(ArtTile_SLZ_Fireball_Launcher,2,0)
		dc.b 0,	8
		dc.w priority2

		dc.l Map_Scen
		dc.w make_art_tile(ArtTile_SLZ_Fireball_Launcher,2,0)
		dc.b 0,	8
		dc.w priority2

		dc.l Map_Bri
		dc.w make_art_tile(ArtTile_GHZ_Bridge,2,0)
		dc.b 1,	$10
		dc.w priority1

		even