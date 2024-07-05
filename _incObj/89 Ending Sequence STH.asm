; ---------------------------------------------------------------------------
; Object 89 - "SONIC THE HEDGEHOG" text	on the ending sequence
; ---------------------------------------------------------------------------

EndSTH:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
	; RetroKoH Object Routine Optimization
		jmp		ESth_Index(pc,d0.w)
; ===========================================================================
ESth_Index:
		bra.s ESth_Main
		bra.s ESth_Move
		bra.s ESth_GotoCredits

esth_time = objoff_30		; time until exit
; ===========================================================================

ESth_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#-$20,obX(a0)	; object starts	outside	the level boundary
		move.w	#$D8,obScreenY(a0)
		move.l	#Map_ESth,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ending_STH,0,0),obGfx(a0)
		clr.b	obRender(a0)
		clr.w	obPriority(a0)		; RetroKoH S2 Priority Manager

ESth_Move:	; Routine 2
		cmpi.w	#$C0,obX(a0)	; has object reached $C0?
		beq.s	ESth_Delay		; if yes, branch
		addi.w	#$10,obX(a0)	; move object to the right
		jmp		(DisplaySprite).l

ESth_Delay:
		addq.b	#2,obRoutine(a0)
		move.w	#300,esth_time(a0) ; set duration for delay (5 seconds)

ESth_GotoCredits:
		; Routine 4
		subq.w	#1,esth_time(a0) ; subtract 1 from duration
		bpl.s	ESth_Wait
		move.b	#id_Credits,(v_gamemode).w ; exit to credits

ESth_Wait:
		jmp		(DisplaySprite).l
