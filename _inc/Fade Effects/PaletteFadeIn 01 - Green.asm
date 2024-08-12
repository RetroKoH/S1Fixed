; ---------------------------------------------------------------------------
; Subroutine to	fade in from black -- Mode 01: Green (RetroKoH)
; Slight optimization to FadeIn_AddColour by RetroKoH
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$3F,(v_pfade_start).w	; set start position = 0; size = $40

PalFadeIn_Alt:				; start position and size are already set
		moveq	#0,d0
		lea		(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf		d0,.fill 	; fill palette with black

		move.w	#$15,d4		; fade-in will occur over 22 frames

.mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeIn_FromBlack
		bsr.w	RunPLC
		dbf		d4,.mainloop
		rts	
; End of function PaletteFadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_FromBlack:
	; Fade process for standard palette
		moveq	#0,d0
		lea		(v_palette).w,a0		; a0 = current palette
		lea		(v_palette_fading).w,a1	; a1 = target palette to transition to
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0					; a0 = current palette + start position
		adda.w	d0,a1					; a1 = target palette + start position
		move.b	(v_pfade_size).w,d0		; d0 = (# of colors to fade in) - 1

.addcolour:
		bsr.s	FadeIn_AddColour	; increase colour
		dbf		d0,.addcolour		; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	.exit				; if not, branch

	; Identical process for water palette
		moveq	#0,d0
		lea		(v_palette_water).w,a0
		lea		(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	FadeIn_AddColour	; increase colour again
		dbf		d0,.addcolour2		; repeat

.exit:
		rts	
; End of function FadeIn_FromBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; This modified function decrements values from _dry_dup while adding to _dry.
; if _dry_dup entry == $0000, then the fade should be complete for that palette entry.
; if a specific component in _dry_dup's current value == $0, then we don't need to fade that color.

FadeIn_AddColour:
		tst.w	(a1)					; Does this colour entry need to be faded in?
		beq.s	.next					; if not, branch and jump to the next palette entry

.checkcolors:
	; Special thanks to MarkeyJester for this bit of code
		move.b	(a1),d5					; d5 = target blue
		move.b	1(a1),d1				; d1 = GR byte
		move.b	d1,d2					; copy to d2
		lsr.b	#4,d1					; d1 = target green
		andi.b	#$E,d2					; d2 = target red
	; Check components
		tst.b	d1						; Does green need adding (yes if d5 is non-zero)
		bne.s	.addgreen				; if yes, branch and add green to current colour
		tst.b	d5						; Does blue need adding (yes if d5 is non-zero)
		bne.s	.addblue				; if yes, branch and add blue to current colour
		bra.s	.addred
; ===========================================================================

.addblue:
		addq.b	#2,(a0)					; increase blue	value
		subq.b	#2,(a1)					; decrease target blue value
		bra.s	.next					; advance color values and exit	
; ===========================================================================

.addgreen:
		addi.b	#$20,1(a0)				; increase green value
		subi.b	#$20,1(a1)				; decrease target green value
		bra.s	.next					; advance color values and exit	
; ===========================================================================

.addred:
		addq.b	#2,1(a0)				; increase red value
		subq.b	#2,1(a1)				; decrease target red value
; ===========================================================================

.next:
		addq.w	#2,a0					; next colour
		addq.w	#2,a1					; next target colour
		rts
; End of function FadeIn_AddColour
