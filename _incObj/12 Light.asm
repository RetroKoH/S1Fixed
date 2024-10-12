; ---------------------------------------------------------------------------
; Object 12 - lamp (SYZ)
; ---------------------------------------------------------------------------

SpinningLight:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Light_Animate
	; Object Routine Optimization End

Light_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Light,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#priority6,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

Light_Animate:	; Routine 2 (Replaced with global sync animation)
		move.b	(v_ani2_frame).w,d0
		move.b	d0,obFrame(a0)	; change current frame

.chkdel:
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite