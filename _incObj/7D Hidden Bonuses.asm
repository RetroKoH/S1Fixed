; ---------------------------------------------------------------------------
; Object 7D - hidden points at the end of a level
; ---------------------------------------------------------------------------

HiddenBonus:
		moveq	#16,d2						; radius
		move.w	d2,d3
		add.w	d3,d3						; radius*2
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0					; d0 = Sonic's distance from item (negative if Sonic is left, positive if right)
		add.w	d2,d0						; add radius
		cmp.w	d3,d0						; is Sonic within item's width?
		bhs.s	.chkdel						; if not, branch
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1						; is Sonic within item's height?
		bhs.s	.chkdel						; if not, branch

		tst.w	(v_debuguse).w				; is debug in use?
		bne.s	.chkdel						; if yes, branch
		tst.b	(f_bigring).w				; has giant ring been collected?
		bne.s	.chkdel						; if yes, branch

		_move.l	#Bonus_Display,obAddr(a0)
		move.l	#Map_Bonus,obMap(a0)
		move.w	#make_art_tile(ArtTile_Hidden_Points,0,1),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
		move.b	obSubtype(a0),obFrame(a0)
		move.w	#119,obBonus_WaitTime(a0)	; set display time to 2 seconds
		move.w	#sfx_Bonus,d0
		jsr		(QueueSound2).w				; play bonus sound
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	Bonus_Points(pc,d0.w),d0	; load bonus points array
		jsr		(AddPoints).l

	.chkdel:
		offscreen.s	Bonus_Delete
		rts	
; ===========================================================================

Bonus_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

Bonus_Points:
	; Bonus	points array
		dc.w 0			; subtype 0 - 0 points (unused)
		dc.w 1000		; subtype 1 - 10000 points
		dc.w 100		; subtype 2 - 1000 points
		dc.w 10			; subtype 3 - 100 points (1337Rooster points fix)
; ===========================================================================

Bonus_Display:
		subq.w	#1,obBonus_WaitTime(a0)	; decrement display time
		bmi.s	Bonus_Delete			; if time is zero, branch
		out_of_range.s	Bonus_Delete
		jmp		(DisplaySprite).l
; ===========================================================================