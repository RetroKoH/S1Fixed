; ---------------------------------------------------------------------------
; Object 5C - metal pylons in foreground (SLZ)
; ---------------------------------------------------------------------------

Pylon:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Pyl_Display
	; Object Routine Optimization End

Pyl_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Pylon,obMap(a0)
		move.w	#make_art_tile(ArtTile_SLZ_Pylon,0,1),obGfx(a0)
		move.b	#$10,obActWid(a0)

Pyl_Display:	; Routine 2
		move.l	(v_screenposx).w,d1
		add.l	d1,d1
		swap	d1
		neg.w	d1
		move.w	d1,obX(a0)
		move.l	(v_screenposy).w,d1
		add.l	d1,d1
		swap	d1
		andi.w	#$3F,d1
		neg.w	d1
		addi.w	#$100,d1
		move.w	d1,obScreenY(a0)
		bra.w	DisplaySprite