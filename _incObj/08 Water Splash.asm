; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)
; ---------------------------------------------------------------------------

Splash:
	; LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		cmpi.b	#2,d0
		beq.s	Spla_Display
		
		tst.b	d0
		bne.w	Spla_Delete
	; Object Routine Optimization End

Spla_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Splash,obMap(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Splash,2,0),obGfx(a0)
		move.w	(v_player+obX).w,obX(a0)	; copy x-position from Sonic

Spla_Display:	; Routine 2
		move.w	(v_waterpos1).w,obY(a0)		; copy y-position from water height
		lea		(Ani_Splash).l,a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

Spla_Delete:	; Routine 4
		jmp		(DeleteObject).l			; delete when animation	is complete
