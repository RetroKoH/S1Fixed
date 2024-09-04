; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage) -- Refactored by RetroKoH
; Mode 06 Fade in by RetroKoH, based on original work by MarkeyJester
; ---------------------------------------------------------------------------

	if PaletteFadeSetting=6
		include "_inc/Fade Effects/PaletteFadeWhiteIn 06 - Full.asm"
	else
	
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:
		move.w	#$3F,(v_pfade_start).w	; set start position = 0; size = $40

PalWhiteIn_Alt:				; called when start position and size are already set
		moveq	#0,d0
		lea		(v_palette).w,a0		; a0 = palette that'll be faded in
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = palette + start position
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0		; d0 = (# of colours to fade in) - 1

.fill:
		move.w	d1,(a0)+				; set colour to white
		dbf		d0,.fill 				; fill palette with white

		move.w	#$15,d4					; fade-in will occur over 22 frames

.mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteIn_FromWhite		; run the fade-in process
		bsr.w	RunPLC
		dbf		d4,.mainloop			; iterate through 21 times
		rts	
; ===========================================================================

WhiteIn_FromWhite:
	; Fade process for standard palette
		moveq	#0,d0
		lea		(v_palette).w,a0				; a0 = current palette
		lea		(v_palette_fading).w,a1			; a1 = target palette to transition to
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0							; a0 = current palette + start position
		adda.w	d0,a1							; a1 = target palette + start position
		move.b	(v_pfade_size).w,d0				; d0 = (# of colors to fade in) - 1

.decolour:
		bsr.s	WhiteIn_DecColour				; decrease colour currently stored in (a0)
		dbf		d0,.decolour					; repeat for size of palette (v_pfade_size)

		cmpi.b	#id_LZ,(v_zone).w				; is level Labyrinth?
		bne.s	.exit							; if not, branch

	; Identical process for water palette
		moveq	#0,d0
		lea		(v_palette_water).w,a0			; a0 = current palette
		lea		(v_palette_water_fading).w,a1	; a1 = target palette to transition to
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0							; a0 = current palette + start position
		adda.w	d0,a1							; a1 = target palette + start position
		move.b	(v_pfade_size).w,d0				; d0 = (# of colors to fade in) - 1

.decolour2:
		bsr.s	WhiteIn_DecColour				; decrease colour currently stored in (a0)
		dbf		d0,.decolour2					; repeat for size of palette (v_pfade_size)

.exit:
		rts	
; ===========================================================================

; Variations of WhiteIn_DecColour
	if PaletteFadeSetting=0
		include "_inc/Fade Effects/PaletteFadeWhiteIn 00 - Blue.asm"
	elseif PaletteFadeSetting=1
		include "_inc/Fade Effects/PaletteFadeWhiteIn 01 - Green.asm"
	elseif PaletteFadeSetting=2
		include "_inc/Fade Effects/PaletteFadeWhiteIn 02 - Red.asm"
	elseif PaletteFadeSetting=3
		include "_inc/Fade Effects/PaletteFadeWhiteIn 03 - BlueGreen.asm"
	elseif PaletteFadeSetting=4
		include "_inc/Fade Effects/PaletteFadeWhiteIn 04 - BlueRed.asm"
	elseif PaletteFadeSetting=5
		include "_inc/Fade Effects/PaletteFadeWhiteIn 05 - GreenRed.asm"
	endif
	
	endif