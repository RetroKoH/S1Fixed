; ---------------------------------------------------------------------------
; Object 68 - conveyor belts (SBZ)
; ---------------------------------------------------------------------------

conv_speed = objoff_36
conv_width = objoff_38

Conveyor:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Conv_Action
	; Object Routine Optimization End

Conv_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#128,conv_width(a0) ; set width to 128 pixels
		move.b	obSubtype(a0),d1 ; get object type
		andi.b	#$F,d1		; read only the	2nd digit
		beq.s	.typeis0	; if zero, branch
		move.b	#56,conv_width(a0) ; set width to 56 pixels

.typeis0:
		move.b	obSubtype(a0),d1 ; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asr.w	#4,d1
		move.w	d1,conv_speed(a0) ; set belt speed

Conv_Action:	; Routine 2
		bsr.s	.movesonic
		offscreen.s	.delete	; PFM S3K OBJ
		rts	

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

.movesonic:
		moveq	#0,d2
		move.b	conv_width(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bhs.s	.notonconveyor
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		addi.w	#$30,d1
		cmpi.w	#$30,d1
		bhs.s	.notonconveyor
		btst	#staAir,obStatus(a1)
		bne.s	.notonconveyor
		move.w	conv_speed(a0),d0
		add.w	d0,obX(a1)

.notonconveyor:
		rts	
