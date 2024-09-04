; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage) -- Mode 01: Green (RetroKoH)
; Slight optimization to WhiteOut_AddColour by RetroKoH
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:
		cmpi.w	#cWhite,(a0)	; Does this colour entry need to be faded out?
		beq.s	.next			; if not, branch and jump to the next palette entry

.addblue:
		move.b	(a0),d1		; d1 = 0B byte
		andi.b	#$E,d1		; d1 = blue (done for error-proofing)
		cmpi.b	#$E,d1
		beq.s	.addred		; if blue is already whited out, check red
		addq.b	#2,(a0)		; increase blue value
		addq.w	#2,a0		; next colour
		rts	
; ===========================================================================

.addred:
		move.b	1(a0),d1	; d1 = GR byte
		andi.b	#$E,d1		; d1 = current red
		cmpi.b	#$E,d1
		beq.s	.addgreen	; if red is already whited out, that means only green remains
		addq.b	#2,1(a0)	; increase red value
		addq.w	#2,a0		; next colour
		rts
; ===========================================================================

.addgreen:
		addi.b	#$20,1(a0)	; increase green value	

.next:
		addq.w	#2,a0		; next colour
		rts
; End of function WhiteOut_AddColour
