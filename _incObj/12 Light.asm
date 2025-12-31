; ---------------------------------------------------------------------------
; Object 12 - lamp (SYZ)
; ---------------------------------------------------------------------------

SpinningLight:
		_move.l	#Light_Animate,obAddr(a0)
		move.l	#Map_Light,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority6,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

Light_Animate:	; Animation now uses global anim sync)
		move.b	(v_ani2_frame).w,d0
		move.b	d0,obFrame(a0)		; change current frame

	.chkdel:
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================