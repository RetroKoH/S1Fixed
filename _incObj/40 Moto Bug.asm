; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------

motoTime = objoff_30
motoSmokedelay = objoff_33

MotoBug:
	; RetroKoH Object Routine Optimization
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		Moto_Index(pc,d0.w)
; ===========================================================================
Moto_Index:
		bra.s	Moto_Main
		bra.s	Moto_Action
		bra.s	Moto_Animate
		bra.s	Moto_Delete
	; Object Routine Optimization End
; ===========================================================================

Moto_Main:	; Routine 0
		move.l	#Map_Moto,obMap(a0)
		move.w	#make_art_tile(ArtTile_Moto_Bug,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$14,obActWid(a0)
		tst.b	obAnim(a0)					; is object a smoke trail?
		bne.s	.smoke						; if yes, branch
		move.b	#$E,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.b	#$C,obColType(a0)
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	.notonfloor
		add.w	d1,obY(a0)					; match	object's position with the floor
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)			; goto Moto_Action next
		bchg	#staFlipX,obStatus(a0)

.notonfloor:
		rts	
; ===========================================================================

.smoke:
		addq.b	#4,obRoutine(a0) ; goto Moto_Animate below

Moto_Animate:	; Routine 4
		lea		(Ani_Moto).l,a1
		jsr		(AnimateSprite).w
		bra.w	DisplaySprite
; ===========================================================================

Moto_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================

Moto_Action:	; Routine 2
	; LavaGaming/RetroKoH Object Routine Optimization
		tst.b	ob2ndRout(a0)
		bne.s	.findfloor
	; Object Routine Optimization End

.move:
		subq.w	#1,motoTime(a0)	; subtract 1 from pause	time
		bpl.s	.wait		; if time remains, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$100,obVelX(a0) ; move object to the left
		move.b	#1,obAnim(a0)
		bchg	#staFlipX,obStatus(a0)
		bne.s	.wait
		neg.w	obVelX(a0)	; change direction

.wait:
		lea		(Ani_Moto).l,a1
		jsr		(AnimateSprite).w
		bra.s	RememberState
; ===========================================================================

.findfloor:
		bsr.w	SpeedToPos
		jsr		(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	.pause
		cmpi.w	#$C,d1
		bge.s	.pause
		add.w	d1,obY(a0)	; match	object's position with the floor
		subq.b	#1,motoSmokedelay(a0)
		bpl.s	.nosmoke
		move.b	#$F,motoSmokedelay(a0)
		bsr.w	FindFreeObj
		bne.s	.nosmoke
		_move.b	#id_MotoBug,obID(a1) ; load exhaust smoke object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#2,obAnim(a1)
		bra.s	.nosmoke

.pause:
		subq.b	#2,ob2ndRout(a0)
		move.w	#59,motoTime(a0)	; set pause time to 1 second
		clr.w	obVelX(a0)			; stop the object moving
		clr.b	obAnim(a0)

.nosmoke:
		lea		(Ani_Moto).l,a1
		jsr		(AnimateSprite).w

		include	"_incObj/sub RememberState.asm"	; Moto_Action terminates in this file
