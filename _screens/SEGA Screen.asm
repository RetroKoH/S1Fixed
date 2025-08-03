; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

GM_Sega:
		move.b	#bgm_Stop,d0
		bsr.w	PlaySound_Special			; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)					; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#$8700,(a6)					; set background colour (palette entry 0)
		move.w	#$8B00,(a6)					; full-screen vertical scrolling
		clr.b	(f_wtr_state).w
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		locVRAM	ArtTile_Sega_Tiles*tile_size
		lea		(Nem_SegaLogo).l,a0			; load Sega	logo patterns
		bsr.w	NemDec
		lea		(v_128x128&$FFFFFF).l,a1
		lea		(Eni_SegaLogo).l,a0			; load Sega	logo mappings
		move.w	#make_art_tile(ArtTile_Sega_Tiles,0,FALSE),d0
		bsr.w	EniDec

		copyTilemap	v_128x128&$FFFFFF,vram_bg+$510,24,8
		copyTilemap	(v_128x128+24*8*2)&$FFFFFF,vram_fg,40,28

		tst.b   (v_megadrive).w									; is console Japanese?
		bmi.s   .loadpal
		copyTilemap	(v_128x128+$A40)&$FFFFFF,vram_fg+$53A,3,2	; hide "TM" with a white rectangle

.loadpal:
	; RetroKoH Fade In SEGA background
	if FadeInSEGA=1
		lea		(v_palette_fading).l,a3
		moveq	#$3F,d7

.loop:
		move.w	#cWhite,(a3)+	; move data to RAM
		dbf		d7,.loop

		bsr.w	PaletteFadeIn
	else
		moveq	#palid_SegaBG,d0
		bsr.w	PalLoad						; load Sega logo palette
	endif
	; Fade In SEGA Background End

		move.w	#-$A,(v_pcyc_num).w
		moveq	#0,d0
		move.w	d0,(v_pcyc_time).w
		move.w	d0,(v_pal_buffer+$12).w
		move.w	d0,(v_pal_buffer+$10).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l

Sega_WaitPal:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPal

		move.b	#sfx_Sega,d0
		bsr.w	PlaySound_Special				; play "SEGA" sound
		move.b	#$14,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	#3*60,(v_demolength).w			; 3 seconds

Sega_WaitEnd:
		move.b	#2,(v_vbla_routine).w
		bsr.w	WaitForVBla
		tst.w	(v_demolength).w
		beq.s	Sega_GotoTitle
		andi.b	#btnStart,(v_jpadpress1).w		; is Start button pressed?
		beq.s	Sega_WaitEnd					; if not, branch

	if SaveProgressMod
Sega_GotoTitle:
		tst.b	(v_sram_errorcode).w
		bne.s	.nosram
		move.b	#id_Title,(v_gamemode).w		; go to title screen
		rts

.nosram:
		move.b	#id_SRAMError,(v_gamemode).w	; go to error screen
		rts
; ===========================================================================

		include "_inc/SRAM Error Screen.asm"
	else
Sega_GotoTitle:
		move.b	#id_Title,(v_gamemode).w		; go to title screen
		rts
; ===========================================================================
	endif