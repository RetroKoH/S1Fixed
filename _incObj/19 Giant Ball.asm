; ---------------------------------------------------------------------------
; Object 19 - Giant Rolling Ball (GHZ)
; ---------------------------------------------------------------------------

GiantBall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GHZBall_Index(pc,d0.w),d1
		jmp		GHZBall_Index(pc,d1.w)
; ===========================================================================
GHZBall_Index:	offsetTable
		offsetTableEntry.w	GHZBall_Main
		offsetTableEntry.w	GHZBall_Idle
		offsetTableEntry.w	GHZBall_Rolling
		offsetTableEntry.w	GHZBall_InAir
		offsetTableEntry.w	GHZBall_Delete
; ===========================================================================

GHZBall_Main:
		move.b	#$18,obHeight(a0)
		move.b	#$C,obWidth(a0)
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_5CEC
		add.w	d1,obY(a0)					; latch to the floor upon init
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)
		move.l	#Map_GBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Giant_Ball,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#1,obDelayAni(a0)
		bsr.w	GHZBall_SetFrame
		bra.w	RememberState

locret_5CEC:
		rts
; ===========================================================================

GHZBall_Idle:		; Routine 2
		move.w	#$23,d1						; width
		move.w	#$18,d2						; height (jumping)
		move.w	#$18,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; make the ball solid
		btst	#staSonicPush,obStatus(a0)	; is Sonic pushing the ball?
		beq.s	.animate					; if not, branch

	; is pushing
		addq.b	#2,obRoutine(a0)			; the ball is now moving
		move.w	#$C0,obInertia(a0)			; nudge the ball to the right
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0					; is Sonic pushing the ball to the left?
		bcs.s	.animate					; if not, branch
		neg.w	obInertia(a0)				; nudge the ball to the left

	.animate:
		bsr.w	GHZBall_SetFrame
		bsr.w	RememberState
		bra.w	GHZBall_ChkDelete
; ===========================================================================

GHZBall_Rolling:	; Routine 4
		bsr.w	GHZBall_ReactToItem			; check to destroy objects while rolling
		bsr.w	GHZBall_SetRollSpeeds		; apply momentum to rolling
		bsr.w	SpeedToPos
		move.w	#$23,d1						; width
		move.w	#$18,d2						; height (jumping)
		move.w	#$18,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; make the ball solid
		btst	#staSonicPush,obStatus(a0)	; is Sonic pushing the ball?
		beq.s	.notpushing					; if not, branch

	.ispushing:
		move.w	#$80,d1						; nudge the ball to the right
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0					; is Sonic pushing the ball to the left?
		bcs.s	.applymovement				; if not, branch
		neg.w	d1							; nudge the ball to the left

	.applymovement:
		add.w	d1,obInertia(a0)			; apply push force to current momentum
	
	.notpushing:
		jsr		(GHZBall_AnglePos).l		; move along the ground (and test if in mid-air)

	; scrapped the rudimentary left boundary check
		btst	#staAir,obStatus(a0)		; is the ball in the air?
		beq.s	.onground					; if not, branch
		addq.b	#2,obRoutine(a0)			; enter air routine
		move.w	#$FC00,obVelY(a0)			; bounce the ball into the air

	.onground:
		tst.w	obInertia(a0)				; is the ball rolling?
		bne.s	.ismoving					; if yes, branch ahead
		subq.b	#2,obRoutine(a0)			; set to idle routine

	.ismoving:
	;	bsr.w	MvSonicOnPtfm2
		bsr.s	GHZBall_SetFrame
		bsr.w	RememberState
		bra.w	GHZBall_ChkDelete
; ===========================================================================

GHZBall_InAir:		; Routine 6
		bsr.w	GHZBall_ReactToItem
		bsr.w	GHZBall_SetFrame
		bsr.w	SpeedToPos
		move.w	#$23,d1						; width
		move.w	#$18,d2						; height (jumping)
		move.w	#$18,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; make the ball solid
		jsr		(ObjFloorDist).l
		tst.w	d1							; is the ball STILL in the air?
		bpl.s	.inair						; if yes, branch
		add.w	d1,obY(a0)					; latch to the floor
		move.b	d3,obAngle(a0)				; set angle
		bclr	#staAir,obStatus(a0)		; no longer in air
		subq.b	#2,obRoutine(a0)			; enter roll routine

	.inair:
		move.w	obVelY(a0),d0
		addi.w	#$28,d0
		move.w	d0,obVelY(a0)				; apply gravity (slightly less than ObjectFall)
	;	bsr.w	MvSonicOnPtfm2
		bsr.s	GHZBall_SetFrame
		bsr.w	RememberState
		bra.w	GHZBall_ChkDelete
; ===========================================================================

GHZBall_SetFrame:
		tst.b	obFrame(a0)			; Is the ball displaying frame 0? (shiny solid color frame)
		beq.s	.isframe0			; if yes, branch
		clr.b	obFrame(a0)			; if not, set to shiny solid color frame
		rts
; ===========================================================================

.isframe0:
		move.b	obInertia(a0),d0	; d0 = floor(inertia)
		beq.s	.setframe			; if not moving, branch
		bmi.s	.movingleft			; if moving left, branch

;.movingright:
		subq.b	#1,obTimeFrame(a0)	; decrement frame timer
		bpl.s	.setframe			; if time remains, branch
		neg.b	d0					; make stored inertia negative
		addq.b	#6,d0				; d0 = -(inertia) + 6
		bcs.s	.ispositive			; if positive, branch (I need to check this)
		moveq	#0,d0

.ispositive:
		move.b	d0,obTimeFrame(a0)	; set frame timer
		move.b	obDelayAni(a0),d0
		addq.b	#1,d0
		cmpi.b	#4,d0
		bne.s	.under4
		moveq	#1,d0

.under4:
		move.b	d0,obDelayAni(a0)

.setframe:
		move.b	obDelayAni(a0),obFrame(a0)
		rts
; ===========================================================================

.movingleft:
		subq.b	#1,obTimeFrame(a0)	; decrement frame timer
		bpl.s	.setframe			; if time remains, branch
		addq.b	#6,d0				; d0 = -(inertia) + 6
		bcs.s	.ispositive2		; if positive, branch (I need to check this)
		moveq	#0,d0

.ispositive2:
		move.b	d0,obTimeFrame(a0)	; set frame timer
		move.b	obDelayAni(a0),d0
		subq.b	#1,d0
		bne.s	.setframe2
		moveq	#3,d0

.setframe2:
		move.b	d0,obDelayAni(a0)
		move.b	obDelayAni(a0),obFrame(a0)
		rts
; ===========================================================================

GHZBall_ChkDelete:
		offscreen.w	DeleteObject
		rts
; ===========================================================================

GHZBall_Delete:
		bra.w	DeleteObject
; ===========================================================================

GHZBall_SetRollSpeeds:
		move.b	obAngle(a0),d0
		bsr.w	CalcSine
		move.w	d0,d2
		muls.w	#$38,d2
		asr.l	#8,d2
		add.w	d2,obInertia(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		rts
; ===========================================================================

	include "_incObj/sub ReactToItem - GHZBall.asm"