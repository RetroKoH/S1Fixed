; ---------------------------------------------------------------------------
; Subroutine to	display	a sprite/object, when a0 is the	object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite:
		movea.w	obPriority(a0),a1	; get sprite priority -- RetroKoH/Devon S3K+ Priority Manager
		cmpi.w	#$7E,(a1)			; is this part of the queue full?
		bcc.s	DSpr_Full			; if yes, branch
		addq.w	#2,(a1)				; increment sprite count
		adda.w	(a1),a1				; jump to empty position
		move.w	a0,(a1)				; insert RAM address for object

DSpr_Full:
		rts
; End of function DisplaySprite


; ---------------------------------------------------------------------------
; Subroutine to	display	a 2nd sprite/object, when a1 is	the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite1:
		movea.w	obPriority(a1),a2	; get sprite priority -- RetroKoH/Devon S3K+ Priority Manager
		cmpi.w	#$7E,(a2)			; is this part of the queue full?
		bcc.s	DSpr1_Full			; if yes, branch
		addq.w	#2,(a2)				; increment sprite count
		adda.w	(a2),a2				; jump to empty position
		move.w	a1,(a2)				; insert RAM address for object

DSpr1_Full:
		rts
; End of function DisplaySprite1

; ---------------------------------------------------------------------------
; Devon Subsprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite2:
		movea.w	d0,a1				; get sprite priority -- RetroKoH/Devon S3K+ Priority Manager
		cmpi.w	#$7E,(a1)			; is this part of the queue full?
		bcc.s	DSpr2_Full			; if yes, branch
		addq.w	#2,(a1)				; increment sprite count
		adda.w	(a1),a1				; jump to empty position
		move.w	a0,(a1)				; insert RAM address for object

DSpr2_Full:
		rts
; End of function DisplaySprite2