; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage) -- Mode 02: Red (RetroKoH)
; Slight optimization to WhiteIn_DecColour by RetroKoH
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:
		move.w	#$3F,(v_pfade_start).w	; start position = 0; size = $40

PalWhiteIn_Alt:				; called when start position and size are already set
		moveq	#0,d0
		lea		(v_pal_dry).w,a0		; a0 = palette that'll be faded in
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
; End of function PaletteWhiteIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_FromWhite:
	; Fade process for standard palette
		moveq	#0,d0
		lea		(v_pal_dry).w,a0		; a0 = current palette
		lea		(v_pal_dry_dup).w,a1	; a1 = target palette to transition to
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = current palette + start position
		adda.w	d0,a1					; a1 = target palette + start position
		move.b	(v_pfade_size).w,d0		; d0 = (# of colors to fade in) - 1

.decolour:
		bsr.s	WhiteIn_DecColour		; decrease colour currently stored in (a0)
		dbf		d0,.decolour			; repeat for size of palette (v_pfade_size)

		cmpi.b	#id_LZ,(v_zone).w		; is level Labyrinth?
		bne.s	.exit					; if not, branch

	; Identical process for water palette
		moveq	#0,d0
		lea		(v_pal_water).w,a0
		lea		(v_pal_water_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	WhiteIn_DecColour		; decrease colour currently stored in (a0)
		dbf		d0,.decolour2			; repeat for size of palette (v_pfade_size)

.exit:
		rts	
; End of function WhiteIn_FromWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; This modified function increments values to _dry_dup while decrementing _dry.
; if _dry_dup entry == $0EEE, then the fade should be complete for that palette entry.
; if a specific component in _dry_dup's current value == $E, then we don't need to fade that color.

WhiteIn_DecColour:
		cmpi.w	#cWhite,(a1)			; Does this colour entry need to be faded in?
		beq.s	.next					; if not, branch and jump to the next palette entry

.checkcolors:
	; Special thanks to MarkeyJester for this bit of code
		move.b	(a1),d5					; d5 = target blue
		move.b	1(a1),d1				; d1 = GR byte
		move.b	d1,d2					; copy to d2
		lsr.b	#4,d1					; d1 = target green
		andi.b	#$E,d2					; d2 = target red
	; Check components
		cmpi.b	#$E,d2					; Does red need removal (yes if d2 is not $E)
		bne.s	.dered					; if yes, branch and decrement red to current colour
		cmpi.b	#$E,d5					; Does blue need removal (yes if d5 is not $E)
		bne.s	.deblue					; if yes, branch and decrement blue to current colour
		bra.s	.degreen
; ===========================================================================

.deblue:
		subq.b	#2,(a0)					; decrease blue	value
		addq.b	#2,(a1)					; increase target blue value
		bra.s	.next					; advance color values and exit	
; ===========================================================================

.degreen:
		subi.b	#$20,1(a0)				; decrease green value
		addi.b	#$20,1(a1)				; increase target green value
		bra.s	.next					; advance color values and exit	
; ===========================================================================

.dered:
		subq.b	#2,1(a0)				; decrease red value
		addq.b	#2,1(a1)				; increase target red value
; ===========================================================================

.next:
		addq.w	#2,a0					; next colour
		addq.w	#2,a1					; next target colour
		rts
; End of function WhiteIn_DecColour
