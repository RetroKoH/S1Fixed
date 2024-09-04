; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage) -- Mode 04: Blue+Red (RetroKoH)
; Slight optimization to WhiteIn_DecColour by RetroKoH
; ---------------------------------------------------------------------------

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
		cmpi.b	#$E,d5					; Does blue need removal (yes if d5 is not $E)
		bne.s	.debluered				; if yes, branch and decrement blue to current colour
		cmpi.b	#$E,d2					; Does red need removal (yes if d2 is not $E)
		bne.s	.dered					; if yes, branch and decrement red to current colour
	; ---------------------------------------------------------------------------
	; This time, blue and red will be added together on each frame, instead of separately
	; ---------------------------------------------------------------------------
; fallthrough

.degreen:
		subi.b	#$20,1(a0)				; decrease green value
		addi.b	#$20,1(a1)				; increase target green value

.next:
		addq.w	#2,a0					; next colour
		addq.w	#2,a1					; next target colour
		rts
; ===========================================================================

.debluered:
		subq.b	#2,(a0)					; decrease blue	value
		addq.b	#2,(a1)					; increase target blue value
		cmpi.b	#$E,d2					; Does red need removal (yes if d2 is not $E)
		beq.s	.next					; advance color values and exit	
; ===========================================================================

.dered:
		subq.b	#2,1(a0)				; decrease red value
		addq.b	#2,1(a1)				; increase target red value
		bra.s	.next					; advance color values and exit
; ===========================================================================
