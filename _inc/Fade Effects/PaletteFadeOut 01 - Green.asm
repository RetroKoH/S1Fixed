; ---------------------------------------------------------------------------
; Subroutine to fade out to black -- Mode 01: Green (RetroKoH)
; Slight optimization to FadeOut_DecColour by RetroKoH
; ---------------------------------------------------------------------------


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$3F,(v_pfade_start).w	; start position = 0; size = $40

PalFadeOut_Alt:				; called when start position and size are already set -- Added to enable partial fade-outs (RetroKoH)
		move.w	#$15,d4

.mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	FadeOut_ToBlack
		bsr.w	RunPLC
		dbf		d4,.mainloop
		rts	
; End of function PaletteFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_ToBlack:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.decolour:
		bsr.s	FadeOut_DecColour			; decrease colour
		dbf		d0,.decolour				; repeat for size of palette

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	FadeOut_DecColour
		dbf		d0,.decolour2
		rts	
; End of function FadeOut_ToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_DecColour:
		tst.w	(a0)		; Does this colour entry need to be faded out?
		beq.s	.next		; if not, branch and jump to the next palette entry

.dered:
		move.b	1(a0),d1	; d1 = GR byte
		andi.b	#$E,d1		; d1 = current red
		beq.s	.deblue		; if red is already faded out, check green
		subq.b	#2,1(a0)	; decrease red value
		bra.s	.next		; branch and exit
; ===========================================================================

.deblue:
		move.b	(a0),d1		; d1 = 0B byte
		andi.b	#$E,d1		; d1 = blue (done for condition check and error-proofing)
		beq.s	.degreen	; if blue is already faded out, that means only green remains
		subq.b	#2,(a0)		; decrease blue	value
		bra.s	.next		; branch and exit
; ===========================================================================

.degreen:
		subi.b	#$20,1(a0)	; decrease green value
; ===========================================================================

.next:
		addq.w	#2,a0		; next colour
		rts	
; End of function FadeOut_DecColour
