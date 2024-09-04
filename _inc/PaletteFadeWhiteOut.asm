; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage) -- Refactored by RetroKoH
; Mode 06 Fade in by RetroKoH, based on original work by MarkeyJester
; ---------------------------------------------------------------------------

	if PaletteFadeSetting=6
		include "_inc/Fade Effects/PaletteFadeWhiteOut 06 - Full.asm"
	else

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:
		move.w	#$3F,(v_pfade_start).w		; set start position = 0; size = $40

PalWhiteOut_Alt:				; called when start position and size are already set -- Added to enable partial fade-outs (RetroKoH)
		move.w	#$15,d4

.mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteOut_ToWhite			; run the white-out process
		bsr.w	RunPLC
		dbf		d4,.mainloop				; iterate through 21 times
		rts	
; ===========================================================================

WhiteOut_ToWhite:
	; Fade process for standard palette
		moveq	#0,d0
		lea		(v_palette).w,a0		; a0 = current palette
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = current palette + start position
		move.b	(v_pfade_size).w,d0		; d0 = (# of colors to fade out) - 1

.addcolour:
		bsr.s	WhiteOut_AddColour		; increase colour currently stored in (a0)
		dbf		d0,.addcolour			; repeat for size of palette (v_pfade_size)

		cmpi.b	#id_LZ,(v_zone).w		; is level Labyrinth?
		bne.s	.exit					; if not, branch

	; Identical process for water palette
		moveq	#0,d0
		lea		(v_palette_water).w,a0	; a0 = current palette
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = current palette + start position
		move.b	(v_pfade_size).w,d0		; d0 = (# of colors to fade out) - 1

.addcolour2:
		bsr.s	WhiteOut_AddColour		; increase colour currently stored in (a0)
		dbf		d0,.addcolour2			; repeat for size of palette (v_pfade_size)

.exit:
		rts	
; ===========================================================================

; Variations of WhiteOut_AddColour
	if PaletteFadeSetting=0
		include "_inc/Fade Effects/PaletteFadeWhiteOut 00 - Blue.asm"
	elseif PaletteFadeSetting=1
		include "_inc/Fade Effects/PaletteFadeWhiteOut 01 - Green.asm"
	elseif PaletteFadeSetting=2
		include "_inc/Fade Effects/PaletteFadeWhiteOut 02 - Red.asm"
	elseif PaletteFadeSetting=3
		include "_inc/Fade Effects/PaletteFadeWhiteOut 03 - BlueGreen.asm"
	elseif PaletteFadeSetting=4
		include "_inc/Fade Effects/PaletteFadeWhiteOut 04 - BlueRed.asm"
	elseif PaletteFadeSetting=5
		include "_inc/Fade Effects/PaletteFadeWhiteOut 05 - GreenRed.asm"
	endif
	
	endif