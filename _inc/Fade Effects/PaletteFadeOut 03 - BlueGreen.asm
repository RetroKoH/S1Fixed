; ---------------------------------------------------------------------------
; Subroutine to fade out to black -- Mode 03: Blue+Green (RetroKoH)
; Slight optimization to FadeOut_DecColour by RetroKoH
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeOut_DecColour:
		tst.w	(a0)			; Does this colour entry need to be faded out?
		beq.s	.next			; if not, branch and jump to the next palette entry

.dered:
		move.b	1(a0),d1		; d1 = GR byte
		andi.b	#$E,d1			; d1 = current red
		beq.s	.deblueandgreen	; if red is already faded out, check blue/green
		subq.b	#2,1(a0)		; decrease red value
		addq.w	#2,a0			; next colour
		rts
; ===========================================================================
; fade out blue and green together, so we MUST check both!
.deblueandgreen:
		move.b	(a0),d1		; d1 = 0B byte
		andi.b	#$E,d1		; d1 = blue (done for condition check and error-proofing)
		beq.s	.degreen	; if blue is already faded out, check green
		subq.b	#2,(a0)		; decrease blue	value

.degreen:
		move.b	1(a0),d1	; d1 = GR byte
		andi.b	#$E0,d1		; d1 = current green
		beq.s	.next		; if green is already faded out, branch and exit
		subi.b	#$20,1(a0)	; decrease green value

.next:
		addq.w	#2,a0		; next colour
		rts
; End of function FadeOut_DecColour
