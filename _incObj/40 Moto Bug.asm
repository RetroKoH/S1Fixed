; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------

MotoBug:
	; LavaGaming/RetroKoH Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Moto_Action
	; Object Routine Optimization End

Moto_Main:	; Routine 0
		move.l	#Map_Moto,obMap(a0)
		move.w	#make_art_tile(ArtTile_Moto_Bug,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$14,obDispWid(a0)
		move.w	#$E08,obHeight(a0)			; Height and Width
		move.b	#(colEnemy|colSz_20x16),obColType(a0)
		bsr.w	ObjectFall_YOnly
		bsr.w	ObjFloorDist
		tst.w	d1							; has motobug hit the floor?
		bpl.s	.notonfloor					; if not, branch
		add.w	d1,obY(a0)					; match	object's position with the floor
		clr.w	obVelY(a0)					; stop falling
		addq.b	#2,obRoutine(a0)			; -> Moto_Action
		bchg	#staFlipX,obStatus(a0)

	.notonfloor:
		rts
; ===========================================================================

Moto_Action:	; Routine 2
	; LavaGaming/RetroKoH Object Routine Optimization
		tst.b	ob2ndRout(a0)
		bne.s	Moto_FindFloor
	; Object Routine Optimization End

Moto_Move:
		subq.w	#1,obMoto_TurnTime(a0)		; decrement wait timer
		bpl.s	.wait						; if time remains, branch
		addq.b	#2,ob2ndRout(a0)			; -> Moto_FindFloor
		move.w	#-$100,obVelX(a0)			; move object to the left
		move.b	#1,obAnim(a0)
		bchg	#staFlipX,obStatus(a0)		; is Motobug facing right?
		bne.s	.wait						; if not, branch
		neg.w	obVelX(a0)					; change direction to the right

	.wait:
		lea		Ani_Moto(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 40 (sub) - Moto Bug smoke
; ---------------------------------------------------------------------------

MotoSmoke:
	; LavaGaming/RetroKoH Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	DeleteObject
	; Object Routine Optimization End

Moto_Animate:	; Routine 0
		lea		Ani_Moto(pc),a1
		jsr		(AnimateSprite).w
		bra.w	DisplaySprite
; ===========================================================================

Moto_FindFloor:
		bsr.w	SpeedToPos_XOnly
		jsr		(ObjFloorDist).l			; d1 = distance to floor
		cmpi.w	#-8,d1
		blt.s	.pause
		cmpi.w	#$C,d1
		bge.s	.pause						; branch if object is more than 11px above or 8px below floor

		add.w	d1,obY(a0)					; align to floor
		subq.b	#1,obMoto_SmokeDelay(a0)	; decrement time between smoke puffs
		bpl.s	.nosmoke					; branch if time remains
		move.b	#$F,obMoto_SmokeDelay(a0)	; reset timer
		bsr.w	FindFreeObj
		bne.s	.nosmoke					; branch if object slot not found

		_move.l	#MotoSmoke,obAddr(a1)		; load exhaust smoke object (A slight bit more work here, since we will go straight to animating)
		move.l	#Map_Moto,obMap(a1)
		move.w	#make_art_tile(ArtTile_Moto_Bug,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)
		bra.s	.nosmoke

	.pause:
		subq.b	#2,ob2ndRout(a0)			; -> Moto_Move
		move.w	#59,obMoto_TurnTime(a0)		; set pause time to 1 second
		clr.w	obVelX(a0)					; stop the object moving
		clr.b	obAnim(a0)

	.nosmoke:
		lea		Ani_Moto(pc),a1
		jsr		(AnimateSprite).w
; ---------------------------------------------------------------------------

		include	"_incObj/sub RememberState.asm"	; Moto_Action terminates in this file
