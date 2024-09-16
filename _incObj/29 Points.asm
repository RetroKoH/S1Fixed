; ---------------------------------------------------------------------------
; Object 29 - points that appear when you destroy something
; ---------------------------------------------------------------------------

Points:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Poi_Slower
	; Object Routine Optimization End

Poi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Poi,obMap(a0)
		move.w	#make_art_tile(ArtTile_Points,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)			; move object upwards

Poi_Slower:	; Routine 2
		tst.w	obVelY(a0)			; is object moving?
		bpl.w	DeleteObject		; if not, delete
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)		; reduce object	speed
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
; ===========================================================================
