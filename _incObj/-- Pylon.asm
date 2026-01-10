; ---------------------------------------------------------------------------
; Object 5C - metal pylons in foreground (SLZ)
; ---------------------------------------------------------------------------

Pylon:
		_move.l	#Pyl_Display,obAddr(a0)
		move.l	#Map_Pylon,obMap(a0)
		move.w	#make_art_tile(ArtTile_SLZ_Pylon,0,1),obGfx(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
; ---------------------------------------------------------------------------

; TO-DO: could I use a modified version of this for MZ UFOs somehow?
Pyl_Display:	; Routine 2
		move.l	(v_screenposx).w,d1			; get camera x pos (in high word)
		add.l	d1,d1						; double it
		swap	d1							; move into low word
		neg.w	d1							; invert
		move.w	d1,obX(a0)					; update x position of pylon
		move.l	(v_screenposy).w,d1
		add.l	d1,d1
		swap	d1
		andi.w	#$3F,d1
		neg.w	d1
		addi.w	#$100,d1
		move.w	d1,obScreenY(a0)
		bra.w	DisplaySprite
; ===========================================================================