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
		move.w	#$300,obPriority(a0)	; RetroKoH S2 Priority Manager

Light_Animate:	; Routine 2 (Replace with global sync animation)
		subq.b	#1,obTimeFrame(a0)
		bpl.s	.chkdel
		move.b	#7,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#6,obFrame(a0)
		blo.s	.chkdel
		clr.b	obFrame(a0)

.chkdel:
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite