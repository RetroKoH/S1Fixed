; ---------------------------------------------------------------------------
; Object 70 - large girder block (SBZ)
; ---------------------------------------------------------------------------

Girder:
		_move.l	#Gird_Action,obAddr(a0)
		move.l	#Map_Gird,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Girder,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$60,obDispWid(a0)
		move.b	#$18,obHeight(a0)
		move.w	obX(a0),obGird_StartX(a0)
		move.w	obY(a0),obGird_StartY(a0)
		bsr.w	Gird_ChgDir					; set initial speed & direction
; ---------------------------------------------------------------------------

Gird_Action:
		move.w	obX(a0),obGird_PrevX(a0)
		tst.b	obGird_MoveDelay(a0)		; has time delay hit 0?
		beq.s	.begin_move					; if yes, branch
		subq.b	#1,obGird_MoveDelay(a0)		; decrement delay timer
		bne.s	.skip_movement				; skip movement update

	.begin_move:
		jsr		(SpeedToPos).l
		subq.w	#1,obGird_MoveTime(a0)		; decrement movement duration
		bne.s	.skip_movement				; if time remains, branch
		bsr.w	Gird_ChgDir					; if time is zero, branch

	.skip_movement:
		move.w	obGird_PrevX(a0),d4
		tst.b	obRender(a0)				; is object on-screen?
		bpl.s	.chkdel						; if not, branch
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	obHeight(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		jsr		(SolidObject).l

	.chkdel:
		offscreen.s	.delete,obGird_StartX(a0)	; ProjectFM
		jmp	(DisplaySprite).l

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to change the speed/direction the girder is moving
; ---------------------------------------------------------------------------

Gird_ChgDir:
		moveq	#$18,d0
		and.b	obGird_MoveSetting(a0),d0		; get current setting (SCE Optimization)
		lea		(.settings).l,a1
		adda.w	d0,a1							; jump to relevant settings (HAME: Replace lea instruction)
		move.l	(a1)+,obVelX(a0)				; move the data contained in the array to obVelX and obVelY, and increment the address in a1
		move.w	(a1)+,obGird_MoveTime(a0)		; how long to move in that direction
		addq.b	#8,obGird_MoveSetting(a0)		; use next settings
		move.b	#7,obGird_MoveDelay(a0)			; set time until it starts moving again
		rts	
; ===========================================================================

	.settings:
			;   x vel,   y vel, duration
		dc.w   $100,	 0,   $60,     0		; right
		dc.w	  0,  $100,   $30,     0		; down
		dc.w  -$100,  -$40,   $60,     0		; up/left
		dc.w	  0, -$100,   $18,     0		; up
; ===========================================================================