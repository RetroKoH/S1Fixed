; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

GM_Continue:
		bsr.w	PaletteFadeOut
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)				; 8 colour mode
		move.w	#$8700,(a6)				; background colour
		bsr.w	ClearScreen
		enable_ints
		clr.b	(f_levelstarted).w		; RetroKoH S3K Rings Manager

		clearRAM v_objspace

	; RetroKoH Optimal Title Cards for VRAM/SpritePiece Reduction
		lea		Art_TitCardContinue,a0											; load text patterns
		move.l	#((Art_TitCardContinue_End-Art_TitCardContinue)/tile_size)-1,d0	; text art length, in tiles
		locVRAM	ArtTile_Title_Card*tile_size,d1									; VRAM location to be set AFTER interrupts disabled
		jsr		(LoadUncArt).w
	; Optimal Title Cards End

		locVRAM	ArtTile_Continue_Sonic*tile_size
		lea		(Nem_ContSonic).l,a0						; load Sonic patterns
		bsr.w	NemDec
		locVRAM	ArtTile_Mini_Sonic*tile_size
		lea		(Nem_MiniSonic).l,a0						; load continue() and Mini Sonic patterns
		bsr.w	NemDec
		moveq	#10,d1
		jsr		(ContScrCounter).l							; run countdown	(start from 10)
		moveq	#palid_Continue,d0
		bsr.w	PalLoad_Fade								; load continue	screen palette

	if ~~AmbienceMode
		move.b	#bgm_Continue,d0
		bsr.w	QueueSound1									; play continue	music
	endif

		move.w	#659,(v_demolength).w						; set time delay to 11 seconds
		clr.l	(v_screenposx).w
		move.l	#$1000000,(v_screenposy).w
		move.b	#id_ContSonic,(v_player).w					; load Sonic object
		move.b	#id_ContScrItem,(v_continuetext).w			; load continue screen objects
		move.b	#id_ContScrItem,(v_continuelight).w
		move.b	#4,(v_continuelight+obFrame).w
		move.b	#id_ContScrItem,(v_continueicon).w
		move.b	#4,(v_continueicon+obRoutine).w
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_4DF2
		disable_ints
		move.w	(v_demolength).w,d1
		divu.w	#$3C,d1
		andi.l	#$F,d1
		jsr		(ContScrCounter).l
		enable_ints

loc_4DF2:
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		cmpi.w	#$180,(v_player+obX).w		; has Sonic run off screen?
		bhs.s	Cont_GotoLevel				; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	Cont_MainLoop
		tst.w	(v_demolength).w
		bne.w	Cont_MainLoop
		move.b	#id_Sega,(v_gamemode).w		; go to Sega screen
		rts	
; ===========================================================================

Cont_GotoLevel:
		move.b	#id_Level,(v_gamemode).w	; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.b	d0,(v_lifecount).w
		move.w	#RingsLivesFactor,(v_ringlife).w
		move.l	d0,(v_time).w				; clear time

	if HUDCentiseconds	; Mercury HUD Centiseconds
		move.b	d0,(v_centstep).w
	endif	; HUD Centiseconds End

		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_lastlamp).w			; clear lamppost count
		subq.b	#1,(v_continues).w			; subtract 1 from continues
		rts	
; ===========================================================================