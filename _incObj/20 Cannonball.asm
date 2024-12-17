; ---------------------------------------------------------------------------
; Object 20 - cannonball that Ball Hog throws (SBZ)
; ---------------------------------------------------------------------------

cbal_time = objoff_30		; time until the cannonball explodes (2 bytes)

Cannonball:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Cbal_Bounce
	; Object Routine Optimization End

Cbal_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#7,obHeight(a0)
		move.l	#Map_Hog,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ball_Hog,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|$7),obColType(a0)
		move.b	#8,obActWid(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0	; move subtype to d0
		add.w	d0,d0				; multiply by 60 (1 second)
		add.w	d0,d0				; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,cbal_time(a0)	; set explosion time
		move.b	#4,obFrame(a0)

Cbal_Bounce:	; Routine 2
		jsr		(ObjectFall).l
		tst.w	obVelY(a0)
		bmi.s	Cbal_ChkExplode
		jsr		(ObjFloorDist).l
		tst.w	d1					; has ball hit the floor?
		bpl.s	Cbal_ChkExplode		; if not, branch

		add.w	d1,obY(a0)
		move.w	#-$300,obVelY(a0)	; bounce
		tst.b	d3
		beq.s	Cbal_ChkExplode
		bmi.s	loc_8CA4
		tst.w	obVelX(a0)
		bpl.s	Cbal_ChkExplode
		neg.w	obVelX(a0)
		bra.s	Cbal_ChkExplode
; ===========================================================================

loc_8CA4:
		tst.w	obVelX(a0)
		bmi.s	Cbal_ChkExplode
		neg.w	obVelX(a0)

Cbal_ChkExplode:
		subq.w	#1,cbal_time(a0)			; subtract 1 from explosion time
		bpl.s	Cbal_Animate				; if time is > 0, branch

Cbal_Explode:
		_move.b	#id_MissileDissolve,obID(a0)
		_move.b	#id_ExplosionBomb,obID(a0)	; change object	to an explosion	($3F)
		clr.b	obRoutine(a0)				; reset routine counter
		bra.w	ExplosionBomb				; jump to explosion code
; ===========================================================================

Cbal_Animate:
		subq.b	#1,obTimeFrame(a0)	; subtract 1 from frame duration
		bpl.s	Cbal_Display
		move.b	#5,obTimeFrame(a0)	; set frame duration to 5 frames
		bchg	#0,obFrame(a0)		; change frame

Cbal_Display:
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0			; has object fallen off	the level?
		blo.w	DeleteObject		; if yes, branch
		bra.w	DisplayAndCollision	; Clownacy DisplaySprite Fix
