; ---------------------------------------------------------------------------
; Object 19 - Giant Rolling Ball (GHZ)
; ---------------------------------------------------------------------------

GiantBall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GHZBall_Index(pc,d0.w),d1
		jmp		GHZBall_Index(pc,d1.w)
; ---------------------------------------------------------------------------
GHZBall_Index:	offsetTable
		offsetTableEntry.w	GHZBall_Main
		offsetTableEntry.w	GHZBall_Rout1
		offsetTableEntry.w	GHZBall_Rout2
		offsetTableEntry.w	GHZBall_Rout3
		offsetTableEntry.w	GHZBall_Rout4
; ---------------------------------------------------------------------------

GHZBall_Main:
		move.b	#$18,obHeight(a0)
		move.b	#$C,obWidth(a0)
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_5CEC
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)
		move.l	#Map_GBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Giant_Ball,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#1,obDelayAni(a0)
		bra.w	GHZBall_SetFrame

locret_5CEC:
		rts
; ---------------------------------------------------------------------------

GHZBall_Rout1:
		move.w	#$23,d1						; width
		move.w	#$18,d2						; height (jumping)
		move.w	#$18,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; make the ball solid
		btst	#staSonicPush,obStatus(a0)	; is Sonic pushing the ball?
		bne.s	loc_5D14					; if yes, branch
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	loc_5D20

loc_5D14:
		addq.b	#2,obRoutine(a0)
		;move.w	#$80,obInertia(a0)

loc_5D20:
		bsr.w	GHZBall_SetFrame
		bsr.w	DisplaySprite
		bra.w	GHZBall_ChkDelete
; ---------------------------------------------------------------------------

GHZBall_Rout2:
		btst	#staFlipY,obStatus(a0)
		bne.w	GHZBall_Rout3
		bsr.w	GHZBall_SetFrame
		bsr.w	GHZBall_SetSpeeds
		bsr.w	SpeedToPos
		move.w	#$23,d1						; width
		move.w	#$18,d2						; height (jumping)
		move.w	#$18,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; make the ball solid
		jsr		(Sonic_AnglePos).l
		cmpi.w	#$20,obX(a0)
		bcc.s	loc_5D70
		move.w	#$20,obX(a0)
		move.w	#$400,obInertia(a0)

loc_5D70:
		btst	#staFlipY,obStatus(a0)
		beq.s	loc_5D7E
		move.w	#$FC00,obVelY(a0)

loc_5D7E:
		bsr.w	DisplaySprite
		bra.w	GHZBall_ChkDelete
; ---------------------------------------------------------------------------

GHZBall_Rout3:
		bsr.w	GHZBall_SetFrame
		bsr.w	SpeedToPos
		move.w	#$23,d1						; width
		move.w	#$18,d2						; height (jumping)
		move.w	#$18,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; make the ball solid
		jsr		(Sonic_Floor).l
		btst	#staFlipY,obStatus(a0)
		beq.s	loc_5DBE
		move.w	obVelY(a0),d0
		addi.w	#$28,d0
		move.w	d0,obVelY(a0)
		bra.s	loc_5DC0
; ---------------------------------------------------------------------------

loc_5DBE:
		nop

loc_5DC0:
		bsr.w	DisplaySprite
		bra.w	GHZBall_ChkDelete
; ---------------------------------------------------------------------------

GHZBall_SetFrame:
		tst.b	obFrame(a0)		; Is the ball displaying frame 0? (shiny solid color frame)
		beq.s	.isframe0		; if yes, branch
		clr.b	obFrame(a0)		; if not, set to shiny solid color frame
		rts
; ---------------------------------------------------------------------------

.isframe0:
		move.b	obInertia(a0),d0	; d0 = floor(inertia)
		beq.s	.setframe			; if not moving, branch
		bmi.s	.movingleft			; if moving left, branch

;.movingright:
		subq.b	#1,obTimeFrame(a0)	; decrement frame timer
		bpl.s	.setframe			; if time remains, branch
		neg.b	d0					; make stored inertia negative
		addq.b	#8,d0				; d0 = -(inertia) + 8
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
; ---------------------------------------------------------------------------

.movingleft:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	.setframe
		addq.b	#8,d0
		bcs.s	.ispositive2
		moveq	#0,d0

.ispositive2:
		move.b	d0,obTimeFrame(a0)
		move.b	obDelayAni(a0),d0
		subq.b	#1,d0
		bne.s	.setframe2
		moveq	#3,d0

.setframe2:
		move.b	d0,obDelayAni(a0)
		move.b	obDelayAni(a0),obFrame(a0)
		rts
; ---------------------------------------------------------------------------

GHZBall_ChkDelete:
		offscreen.w	DeleteObject
		rts
; ---------------------------------------------------------------------------

GHZBall_Rout4:
		bra.w	DeleteObject
; ---------------------------------------------------------------------------

GHZBall_SetSpeeds:
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
