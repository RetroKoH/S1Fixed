; ---------------------------------------------------------------------------
; Object 13 - fire ball	maker (MZ, SLZ)
;
; spawned by:
;	ObjPosLoad
; ---------------------------------------------------------------------------

; ===========================================================================
; Delay between launching fireballs
FireM_Rates:
		dc.b 30										; 0x - 0.5 seconds (unused)
		dc.b 60										; 1x - 1 seconds (SLZ2)
		dc.b 90										; 2x - 1.5 seconds (MZ3)
		dc.b 120									; 3x - 2 seconds (MZ1/2/3, SLZ1/3)
		dc.b 150									; 4x - 2.5 seconds (MZ1/2/3)
		dc.b 180									; 5x - 3 seconds (MZ3)
	; additional values to prevent errors with erroneous subtypes
		dc.b 210									; 6x - 3.5 seconds
		dc.b 240									; 7x - 4 seconds
; ===========================================================================

FireMaker:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	FireM_MakeFire
	; Object Routine Optimization End

FireM_Main:		; Routine 0
		addq.b	#2,obRoutine(a0)					; -> FireM_MakeFire
		moveq	#$70,d0
		and.b	obSubtype(a0),d0					; get high nybble of subtype (spawn rate)
		lsr.w	#4,d0
		move.b	FireM_Rates(pc,d0.w),d0
		move.b	d0,obDelayAni(a0)
		move.b	d0,obTimeFrame(a0)					; set time delay for lava balls
		andi.b	#$F,obSubtype(a0)					; isolate low nybble of subtype (speed/direction)

FireM_MakeFire:	; Routine 2
		subq.b	#1,obTimeFrame(a0)					; decrement timer
		bne.s	.wait								; if time still	remains, branch
		move.b	obDelayAni(a0),obTimeFrame(a0)		; reset time delay
		bsr.w	ChkObjectVisible					; is object on-screen?
		bne.s	.wait								; if not, branch
		bsr.w	FindFreeObj							; find free object RAM slot
		bne.s	.wait								; branch if not found

		_move.b	#id_FireBall,obID(a1)				; load lava ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)			; copy subtype (speed/direction)

	.wait:
		offscreen.w	DeleteObject
		rts
; ===========================================================================