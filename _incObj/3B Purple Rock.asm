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
		move.b	#$13,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

Rock_Solid:	; Routine 2
		moveq	#27,d1						; width; save 4 cycles - Filter
		moveq	#16,d2						; height (jumping); save 4 cycles - Filter
		moveq	#16,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		offscreen.w	DeleteObject			; ProjectFM S3K Object Manager
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix
; ===========================================================================