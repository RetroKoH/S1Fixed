; ---------------------------------------------------------------------------
; Subroutine to fade out to black -- Mode 06: Full (MarkeyJester)
; ---------------------------------------------------------------------------


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeOut:
		move.w	#$3F,(v_pfade_start).w		; start position = 0; size = $40

PalFadeOut_Alt:				; called when start position and size are already set -- Added to enable partial fade-outs (RetroKoH)
		moveq	#7,d4						; MJ: set repeat times
		moveq	#0,d6						; MJ: clear d6

.mainloop:
		bsr.w	RunPLC						; MJ: moved this to the front
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#0,d6						; MJ: change delay counter
		beq		.mainloop					; MJ: if null, delay a frame
		bsr.s	FadeOut_ToBlack
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
		move.w	(a0),d5			; MJ: load colour
		move.w	d5,d1			; MJ: copy to d1
		move.b	d1,d2			; MJ: load green and red
		move.b	d1,d3			; MJ: load red
		andi.w	#$E00,d1		; MJ: get only blue
		beq		.noblue			; MJ: if blue is finished, branch
		subi.w	#$200,d5		; MJ: decrease blue

.noblue:
		andi.w	#$E0,d2			; MJ: get only green (needs to be word)
		beq		.nogreen		; MJ: if green is finished, branch
		subi.b	#$20,d5			; MJ: decrease green

.nogreen:
		andi.b	#$E,d3			; MJ: get only red
		beq		.nored			; MJ: if red is finished, branch
		subq.b	#2,d5			; MJ: decrease red

.nored:
		move.w	d5,(a0)+		; MJ: save new colour
		rts
; End of function FadeOut_DecColour
