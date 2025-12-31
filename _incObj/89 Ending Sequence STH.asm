; ---------------------------------------------------------------------------
; Object 89 - "SONIC THE HEDGEHOG" text	on the ending sequence
; ---------------------------------------------------------------------------

EndSTH:
		_move.l	#ESth_Move,obAddr(a0)
		move.w	#-$20,obX(a0)				; object starts	outside	the level boundary
		move.w	#$D8,obScreenY(a0)
		move.l	#Map_ESth,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ending_STH,0,0),obGfx(a0)
		clr.b	obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

ESth_Move:	; Routine 2
		cmpi.w	#$C0,obX(a0)				; has object reached $C0?
		beq.s	.delay						; if yes, branch
		addi.w	#$10,obX(a0)				; move object to the right
		jmp		(DisplaySprite).l
; ===========================================================================

	.delay:
		_move.l	#ESth_GotoCredits,obAddr(a0)
		move.w	#300,obESTH_WaitTime(a0)	; set duration for delay (5 seconds)

ESth_GotoCredits:	; Routine 4
		subq.w	#1,obESTH_WaitTime(a0)		; subtract 1 from duration
		bpl.s	.wait
		move.b	#id_Credits,(v_gamemode).w	; exit to credits

	.wait:
		jmp		(DisplaySprite).l
; ===========================================================================