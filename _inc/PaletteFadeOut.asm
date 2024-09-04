; ---------------------------------------------------------------------------
; Subroutine to	fade out to black -- Refactored by RetroKoH
; Mode 06 Fade out by MarkeyJester
; ---------------------------------------------------------------------------

	if PaletteFadeSetting=6
		include "_inc/Fade Effects/PaletteFadeOut 06 - Full.asm"
	else

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$3F,(v_pfade_start).w	; set start position = 0; size = $40

PalFadeOut_Alt:				; called when start position and size are already set -- Added to enable partial fade-outs (RetroKoH)
		move.w	#$15,d4

.mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeOut_ToBlack			; run the fade-out process
		bsr.w	RunPLC
		dbf		d4,.mainloop			; iterate through 21 times
		rts	
; ===========================================================================

FadeOut_ToBlack:
	; Fade process for standard palette
		moveq	#0,d0
		lea		(v_palette).w,a0		; a0 = current palette
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = current palette + start position
		move.b	(v_pfade_size).w,d0		; d0 = (# of colors to fade out) - 1

.decolour:
		bsr.s	FadeOut_DecColour		; decrease colour currently stored in (a0)
		dbf		d0,.decolour			; repeat for size of palette (v_pfade_size)

		cmpi.b	#id_LZ,(v_zone).w		; is level Labyrinth?
		bne.s	.exit					; if not, branch

	; Identical process for water palette
		moveq	#0,d0
		lea		(v_palette_water).w,a0	; a0 = current palette
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = current palette + start position
		move.b	(v_pfade_size).w,d0		; d0 = (# of colors to fade out) - 1

.decolour2:
		bsr.s	FadeOut_DecColour		; decrease colour currently stored in (a0)
		dbf		d0,.decolour2			; repeat for size of palette (v_pfade_size)

.exit:
		rts	
; ===========================================================================

; Variations of FadeOut_DecColour
	if PaletteFadeSetting=0
		include "_inc/Fade Effects/PaletteFadeOut 00 - Blue.asm"
	elseif PaletteFadeSetting=1
		include "_inc/Fade Effects/PaletteFadeOut 01 - Green.asm"
	elseif PaletteFadeSetting=2
		include "_inc/Fade Effects/PaletteFadeOut 02 - Red.asm"
	elseif PaletteFadeSetting=3
		include "_inc/Fade Effects/PaletteFadeOut 03 - BlueGreen.asm"
	elseif PaletteFadeSetting=4
		include "_inc/Fade Effects/PaletteFadeOut 04 - BlueRed.asm"
	elseif PaletteFadeSetting=5
		include "_inc/Fade Effects/PaletteFadeOut 05 - GreenRed.asm"
	endif

	endif