; ---------------------------------------------------------------------------
; Subroutine to	fade in from black -- Mode 06: Full (MarkeyJester)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteFadeIn:
		move.w	#$3F,(v_pfade_start).w	; set start position = 0; size = $40

PalFadeIn_Alt:							; start position and size are already set
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(v_pfade_size).w,d0

.fill:
		move.w	d1,(a0)+
		dbf		d0,.fill 				; fill palette with black

		move.w	#$E,d4					; MJ: 14 frames instead of the standard 21
		moveq	#0,d6					; MJ: clear d6

.mainloop:
		bsr.w	RunPLC					; MJ: moved this to the front
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bchg	#0,d6					; MJ: change delay counter
		beq.s	.mainloop				; MJ: if null, delay a frame (add colour every other frame)
		bsr.s	FadeIn_FromBlack
		subq.b	#2,d4					; MJ: decrease color check
		bne.s	.mainloop				; MJ: if it has not reached null, branch
		move.b	#$12,(v_vbla_routine).w	; MJ: wait for V-blank again (so colors transfer)
		bra		WaitForVBla				; MJ: ''	
; End of function PaletteFadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FadeIn_FromBlack:
		moveq	#0,d0
		lea		(v_pal_dry).w,a0
		lea		(v_pal_dry_dup).w,a1
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	FadeIn_AddColour	; increase colour
		dbf		d0,.addcolour		; repeat for size of palette

		cmpi.b	#id_LZ,(v_zone).w	; is level Labyrinth?
		bne.s	.exit				; if not, branch

		moveq	#0,d0
		lea		(v_pal_water).w,a0
		lea		(v_pal_water_dup).w,a1
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

FadeIn_AddColour:
		move.b	(a1),d5			; MJ: load blue
		move.w	(a1)+,d1		; MJ: load green and red
		move.b	d1,d2			; MJ: load red
		lsr.b	#4,d1			; MJ: get only green
		andi.b	#$E,d2			; MJ: get only red
		move.w	(a0),d3			; MJ: load current colour in buffer
		cmp.b	d5,d4			; MJ: is it time for blue to fade?
		bhi		.noblue			; MJ: if not, branch
		addi.w	#$200,d3		; MJ: increase blue

.noblue:
		cmp.b	d1,d4			; MJ: is it time for green to fade?
		bhi		.nogreen		; MJ: if not, branch
		addi.b	#$20,d3			; MJ: increase green

.nogreen:
		cmp.b	d2,d4			; MJ: is it time for red to fade?
		bhi		.nored			; MJ: if not, branch
		addq.b	#2,d3			; MJ: increase red

.nored:
		move.w	d3,(a0)+		; MJ: save colour
		rts						; MJ: return
; End of function FadeIn_AddColour

