; ---------------------------------------------------------------------------
; Object 3B - purple rock (GHZ)
; ---------------------------------------------------------------------------

PurpleRock:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Rock_Solid
	; Object Routine Optimization End

Rock_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_PRock,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Purple_Rock,3,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$13,obActWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

Rock_Solid:	; Routine 2
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
