; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage) -- Mode 06: Full (RetroKoH)
; Based on MarkeyJester's original Full Fade to black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:
		move.w	#$3F,(v_pfade_start).w		; start position = 0; size = $40
		moveq	#7,d4						; KoH: set repeat times
		moveq	#0,d6						; KoH: clear d6

.mainloop:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#0,d6						; KoH: change delay counter
		beq		.mainloop					; KoH: if null, delay a frame
		bsr.s	WhiteOut_ToWhite
		dbf		d4,.mainloop
		rts
; End of function PaletteWhiteOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	WhiteOut_AddColour			; add to colour
		dbf		d0,.addcolour				; repeat for size of palette

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf		d0,.addcolour2
		rts	
; End of function WhiteOut_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:
		move.w	(a0),d5		; KoH: load colour
		move.w	d5,d1		; KoH: copy to d1
		move.b	d1,d2		; KoH: load green and red
		move.b	d1,d3		; KoH: load red
		andi.w	#$E00,d1	; KoH: get only blue
		eori.w  #$E00,d1
		beq.s	.noblue		; KoH: if blue is finished, branch
		addi.w	#$200,d5	; KoH: increase blue

.noblue:
		andi.w	#$E0,d2		; KoH: get only green (needs to be word)
		eori.w  #$E0,d2
		beq.s	.nogreen	; KoH: if green is finished, branch
		addi.b	#$20,d5		; KoH: increase green

.nogreen:
		andi.b	#$E,d3		; KoH: get only red
		eori.b  #$E,d3
		beq.s	.nored		; KoH: if red is finished, branch
		addq.b	#2,d5		; KoH: increase red

.nored:
		move.w	d5,(a0)+	; KoH: save new colour
		rts					; KoH: return
; End of function WhiteOut_AddColour
