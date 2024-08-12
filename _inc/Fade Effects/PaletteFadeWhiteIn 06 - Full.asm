; ---------------------------------------------------------------------------
; Subroutine to	fade in from white (Special Stage) -- Mode 06: Full (RetroKoH)
; Based on MarkeyJester's original Full Fade in from black
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteIn:
		move.w	#$3F,(v_pfade_start).w	; start position = 0; size = $40
		moveq	#0,d0
		lea		(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf		d0,.fill 				; fill palette with white

		moveq	#$E,d4					; KoH: set maximum color check
		moveq	#0,d6					; KoH: clear d6

.mainloop:
		bsr.w	RunPLC
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#0,d6					; KoH: change delay counter
		beq		.mainloop				; KoH: if null, delay a frame
		bsr.s	WhiteIn_FromWhite
		subq.b	#2,d4					; KoH: decrease color check
		bne.s	.mainloop				; KoH: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w	; KoH: wait for V-blank again (so colors transfer)
		bra		WaitForVBla				; KoH: ''
; End of function PaletteWhiteIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_FromWhite:
		moveq	#0,d0
		lea		(v_palette).w,a0
		lea		(v_palette_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour:
		bsr.s	WhiteIn_DecColour		; decrease colour
		dbf		d0,.decolour			; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w		; is level Labyrinth?
		bne.s	.exit					; if not, branch
		moveq	#0,d0
		lea		(v_palette_water).w,a0
		lea		(v_palette_water_fading).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.decolour2:
		bsr.s	WhiteIn_DecColour
		dbf		d0,.decolour2

.exit:
		rts	
; End of function WhiteIn_FromWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteIn_DecColour:
		move.b	(a1),d5		; KoH: load target blue (d5 = 0B)
		move.w	(a1)+,d1	; KoH: load target green and target red (d1 = GR)
		move.b	d1,d2		; KoH: copy over. d2 will carry red
		lsr.b	#4,d1		; KoH: get only green
		andi.b	#$E,d2		; KoH: get only red
		move.w	(a0),d3		; KoH: load current colour in buffer
		cmp.b	d5,d4		; KoH: is it time for blue to fade?
		bls.s	.noblue		; KoH: if not, branch
		subi.w	#$200,d3	; KoH: decrease blue

.noblue:
		cmp.b	d1,d4		; KoH: is it time for green to fade?
		bls.s	.nogreen	; KoH: if not, branch
		subi.b	#$20,d3		; KoH: decrease green

.nogreen:
		cmp.b	d2,d4		; KoH: is it time for red to fade?
		bls.s	.nored		; KoH: if not, branch
		subq.b	#2,d3		; KoH: decrease red

.nored:
		move.w	d3,(a0)+	; KoH: save new colour
		rts					; KoH: return	
; End of function WhiteIn_DecColour
