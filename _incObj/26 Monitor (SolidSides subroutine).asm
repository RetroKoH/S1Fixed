; ---------------------------------------------------------------------------
; Subroutine to	make the sides of a monitor solid
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Mon_SolidSides:
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_A4E6				; if Sonic moves off the left, branch
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0					; has Sonic moved off the right?
		bhi.s	loc_A4E6				; if yes, branch
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_A4E6				; if Sonic moves above, branch
		add.w	d2,d2
		cmp.w	d2,d3					; has Sonic moved below?
		bhs.s	loc_A4E6				; if yes, branch
		tst.b	obCtrlLock(a1)			; are object interactions disabled?
		bmi.s	loc_A4E6				; if yes, branch
		cmpi.b	#6,obRoutine(a1)		; is Sonic dead?
		bhs.s	loc_A4E6				; if yes, branch
		tst.w	(v_debuguse).w			; is debug mode being used?
		bne.s	loc_A4E6				; if yes, branch
		cmp.w	d0,d1					; is Sonic right of centre of object?
		bhs.s	loc_A4DC				; if yes, branch
		add.w	d1,d1
		sub.w	d1,d0

loc_A4DC:
		cmpi.w	#$10,d3
		blo.s	loc_A4EA

loc_A4E2:
		moveq	#1,d1
		rts	
; ===========================================================================

loc_A4E6:
		moveq	#0,d1
		rts	
; ===========================================================================

loc_A4EA:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addq.w	#4,d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	loc_A4E2				; if Sonic is right of object, branch
		cmp.w	d2,d1					; is Sonic left of object?
		bhs.s	loc_A4E2				; if yes, branch
	; RetroKoH Monitor Top Collision Tweak
		tst.w	obVelY(a1)				; is Sonic moving upwards?
		bmi.s	loc_A4E2				; if yes, branch
		subq.w	#1,obY(a1)
	; Monitor Top Collision Tweak End
		moveq	#-1,d1
		rts	
; End of function Mon_SolidSides
