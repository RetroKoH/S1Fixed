; ---------------------------------------------------------------------------
; Object 3B - purple rock (GHZ)
; ---------------------------------------------------------------------------

PurpleRock:
		_move.l	#Rock_Solid,obAddr(a0)
		move.l	#Map_PRock,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Purple_Rock,3,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$13,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

Rock_Solid:
		moveq	#27,d1						; width; save 4 cycles - Filter
		moveq	#16,d2						; height (jumping); save 4 cycles - Filter
		moveq	#16,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		offscreen.w	DeleteObject			; ProjectFM S3K Object Manager
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix
; ===========================================================================