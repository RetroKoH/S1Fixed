; ---------------------------------------------------------------------------
; Subroutine to	check if an object is off screen

; output:
;	d0 = flag set if object is off screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChkObjectVisible:
		move.w	obX(a0),d0	; get object x-position
		sub.w	(v_screenposx).w,d0 ; subtract screen x-position
		bmi.s	.offscreen
		cmpi.w	#320,d0		; is object on the screen?
		bge.s	.offscreen	; if not, branch

		move.w	obY(a0),d1	; get object y-position
		sub.w	(v_screenposy).w,d1 ; subtract screen y-position
		cmpi.w	#LevelYWrapTop,(v_limittop).w
		bne.s	.checkY
		andi.w	#LevelYWrapMask,d1

	.checkY:
		cmpi.w	#224,d1		; is object on the screen?
		bhs.s	.offscreen	; if not, branch (changed from bge)

		moveq	#0,d0		; object is on screen
		rts	

	.offscreen:
		moveq	#1,d0		; object is off screen
		rts	
; End of function ChkObjectVisible

; ---------------------------------------------------------------------------
; Subroutine to	check if an object is off screen
; More precise than above subroutine, taking width into account

; output:
;	d0 = flag set if object is off screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChkPartiallyVisible:
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		move.w	obX(a0),d0	; get object x-position
		sub.w	(v_screenposx).w,d0 ; subtract screen x-position
		add.w	d1,d0		; add object width
		bmi.s	.offscreen
		add.w	d1,d1
		sub.w	d1,d0
		cmpi.w	#320,d0
		bge.s	.offscreen

		move.w	obY(a0),d1
		sub.w	(v_screenposy).w,d1
		cmpi.w	#LevelYWrapTop,(v_limittop).w
		bne.s	.checkY
		andi.w	#LevelYWrapMask,d1

	.checkY:
		cmpi.w	#224,d1
		bhs.s	.offscreen

		moveq	#0,d0
		rts	

	.offscreen:
		moveq	#1,d0
		rts	
; End of function ChkPartiallyVisible

; ---------------------------------------------------------------------------
; Subroutine to check if an object is off screen
; Takes both width and height into account
 
; output:
;    d0 = flag set if object is off screen
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
 
 
ChkSizedObjVisible:
	; Devon Checking For Solids Fix
		moveq	#0,d1				; Get object's width
		move.b	obDispWid(a0),d1
		move.w	obX(a0),d0			; Get object's X position
		sub.w	(v_screenposx).w,d0	; Get object's X position on screen
		add.w	d1,d0				; Is the right side of the object on screen?
		bmi.s	.offscreen			; If not, branch
		add.w	d1,d1				; Is the left side of the object on screen?
		sub.w	d1,d0
		cmpi.w	#320,d0
		bge.s	.offscreen			; If not, branch

		moveq	#0,d1				; Get object's height
		move.b	obHeight(a0),d1
		move.w	obY(a0),d0			; Get object's Y position
		sub.w	(v_screenposy).w,d0	; Get object's Y position on screen
		add.w	d1,d0				; Is the bottom side of the object on screen?
		cmpi.w	#LevelYWrapTop,(v_limittop).w
		bne.s	.boundedY
		andi.w	#LevelYWrapMask,d0
		add.w	d1,d1                   ; full object height
		addi.w	#224,d1
		cmp.w	d1,d0
		bhs.s	.offscreen
		bra.s	.visible

	.boundedY:
		tst.w	d0
		bmi.s	.offscreen			; If not, branch
		add.w	d1,d1				; Is the top side of the object on screen?
		sub.w	d1,d0
		cmpi.w	#224,d1
		bge.s	.offscreen			; If not, branch

	.visible:
		moveq	#0,d0				; Visible
		rts

	.offscreen:
		moveq	#1,d0				; Not visible
		rts 
; End of function ChkSizedObjVisible
