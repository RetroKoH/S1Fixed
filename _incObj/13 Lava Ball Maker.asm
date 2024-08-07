; ---------------------------------------------------------------------------
; Object 13 - lava ball	maker (MZ, SLZ)
; ---------------------------------------------------------------------------

; ===========================================================================
; Lava ball production rates
LavaM_Rates:	dc.b 30, 60, 90, 120, 150, 180
; ===========================================================================

LavaMaker:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	LavaM_MakeLava
	; Object Routine Optimization End

LavaM_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	obSubtype(a0),d0
		lsr.w	#4,d0
		andi.w	#$F,d0
		move.b	LavaM_Rates(pc,d0.w),obDelayAni(a0)
		move.b	obDelayAni(a0),obTimeFrame(a0) ; set time delay for lava balls
		andi.b	#$F,obSubtype(a0)

LavaM_MakeLava:	; Routine 2
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from time delay
		bne.s	LavaM_Wait	; if time still	remains, branch
		move.b	obDelayAni(a0),obTimeFrame(a0) ; reset time delay
		bsr.w	ChkObjectVisible
		bne.s	LavaM_Wait
		bsr.w	FindFreeObj
		bne.s	LavaM_Wait
		_move.b	#id_LavaBall,obID(a1) ; load lava ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)

LavaM_Wait:
	; Clownacy DisplaySprite Fix; See LavaBall.
		offscreen.w	DeleteObject
		rts
