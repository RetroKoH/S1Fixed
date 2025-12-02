; ---------------------------------------------------------------------------
; Object 5F - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------

Bomb:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Bom_Index(pc,d0.w),d1
		jmp		Bom_Index(pc,d1.w)
		; Slightly altered to prevent display-and-delete bug -- Clownacy DisplaySprite Fix
; ===========================================================================
Bom_Index:	offsetTable
		offsetTableEntry.w Bom_Main
		offsetTableEntry.w Bom_Action
		offsetTableEntry.w Bom_Fuse
		offsetTableEntry.w Bom_Shrapnel
; ===========================================================================

Bom_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bomb,obMap(a0)
		move.w	#make_art_tile(ArtTile_Bomb,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$C,obDispWid(a0)
		move.b	obSubtype(a0),d0
		beq.s	.type00						; branch if subtype = 0
		move.b	d0,obRoutine(a0)			; copy subtype to routine (4 = Bom_Fuse; 6 = Bom_Shrapnel)
		jmp		Add_SpriteToCollisionResponseList	
; ===========================================================================

	.type00:
		move.b	#(colHarmful|colSz_12x12),obColType(a0)
		bchg	#staFlipX,obStatus(a0)

Bom_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Bom_ActionIndex(pc,d0.w),d1
		jsr		Bom_ActionIndex(pc,d1.w)
		lea		Ani_Bomb(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================
Bom_ActionIndex:	offsetTable
		offsetTableEntry.w	Bom_Action_Walk
		offsetTableEntry.w	Bom_Action_Wait
		offsetTableEntry.w	Bom_Action_Explode
; ===========================================================================

Bom_Action_Walk:
		bsr.w	Bom_ChkDistToSonic
		subq.w	#1,obBomb_FuseTime(a0)			; subtract 1 from time delay
		bpl.s	.noflip							; if time remains, branch
		addq.b	#2,ob2ndRout(a0)				; goto .wait
		move.w	#1535,obBomb_FuseTime(a0)		; set time delay to 25 seconds
		move.w	#$10,obVelX(a0)
		move.b	#1,obAnim(a0)					; use walking animation
		bchg	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	obVelX(a0)						; change direction

	.noflip:
		rts	
; ===========================================================================

Bom_Action_Wait:
		bsr.w	Bom_ChkDistToSonic
		subq.w	#1,obBomb_FuseTime(a0)			; subtract 1 from time delay
		bmi.s	.stopwalking					; if time expires, branch
		bra.w	SpeedToPos_XOnly
; ===========================================================================

	.stopwalking:
		subq.b	#2,ob2ndRout(a0)
		move.w	#179,obBomb_FuseTime(a0)		; set time delay to 3 seconds
		clr.w	obVelX(a0)						; stop walking
		clr.b	obAnim(a0)						; use waiting animation
		rts	
; ===========================================================================

Bom_Action_Explode:
		subq.w	#1,obBomb_FuseTime(a0)			; subtract 1 from time delay
		bpl.s	.noexplode						; if time remains, branch
		_move.b	#id_ExplosionBomb,obID(a0)		; change bomb into an explosion
		clr.b	obRoutine(a0)

	.noexplode:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check Sonic's distance and load fuse object
; ---------------------------------------------------------------------------

Bom_ChkDistToSonic:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.isleft
		neg.w	d0

.isleft:
		cmpi.w	#$60,d0							; is Sonic within $60 pixels?
		bhs.s	.outofrange						; if not, branch
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		bcc.s	.isabove
		neg.w	d0

.isabove:
		cmpi.w	#$60,d0							; is Sonic within $60 pixels?
		bhs.s	.outofrange						; if not, branch
		tst.w	(v_debuguse).w					; is Debug Mode Active?
		bne.s	.outofrange						; if yes, branch

		move.b	#4,ob2ndRout(a0)
		move.w	#143,obBomb_FuseTime(a0)		; set fuse time
		clr.w	obVelX(a0)
		move.b	#2,obAnim(a0)					; use activated animation
		bsr.w	FindNextFreeObj
		bne.s	.outofrange
		_move.b	#id_Bomb,obID(a1)				; load fuse object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obY(a0),obBomb_StartY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#4,obSubtype(a1)
		move.b	#3,obAnim(a1)
		move.w	#$10,obVelY(a1)
		btst	#staFlipY,obStatus(a0)			; is bomb upside-down?
		beq.s	.normal							; if not, branch
		neg.w	obVelY(a1)						; reverse direction for fuse

.normal:
		move.w	#143,obBomb_FuseTime(a1)		; set fuse time
		move.w	a0,obBomb_Parent(a1)

.outofrange:
		rts	
; ===========================================================================

; Bom_Display:
Bom_Fuse:	; Routine 4
		bsr.s	Bom_Fuse_ChkTime
		lea		Ani_Bomb(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Bom_Fuse_ChkTime:
		subq.w	#1,obBomb_FuseTime(a0)			; decrement fuse timer
		bmi.s	.explode						; branch if fuse runs out
		bra.w	SpeedToPos_YOnly
; ===========================================================================

	.explode:
		clr.w	obBomb_FuseTime(a0)
		clr.b	obRoutine(a0)
		move.w	obBomb_StartY(a0),obY(a0)
		moveq	#2,d1							; 3 additional shrapnel objects
		movea.l	a0,a1
		lea		(Bom_ShrSpeed).l,a2				; load shrapnel speed data

		move.b	#6,obRoutine(a0)				; Bom_Shrapnel
		move.b	#4,obAnim(a0)
		move.l	(a2)+,obVelX(a0)				; move the data contained in the array to obVelX and obVelY, and increment the address in a2
		move.b	#(colHarmful|colSz_4x4),obColType(a0)
		bset	#shPropReflect,obShieldProp(a0)
		bset	#7,obRender(a0)

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	.fail

	.loop:
		tst.b	obID(a1)						; is object RAM	slot empty?
		beq.s	.makeshrapnel					; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop						; loop through object RAM
		bne.s	.fail							; We're moving this line here.

	.makeshrapnel:
		move.b	obID(a0),obID(a1)				; load shrapnel	object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#6,obSubtype(a1)				; this is copied to obRoutine later
		move.b	#4,obAnim(a1)
		move.l	(a2)+,obVelX(a1)				; move the data contained in the array to obVelX and obVelY, and increment the address in a2
		move.b	#(colHarmful|colSz_4x4),obColType(a1)

		bset	#shPropReflect,obShieldProp(a1)	; Reflected by Elemental Shields

		bset	#7,obRender(a1)

	.fail:
		dbf		d1,.loop						; repeat 3 more	times
; ---------------------------------------------------------------------------

; Bom_End:
Bom_Shrapnel:	; Routine 6
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)					; apply gravity
		lea		Ani_Bomb(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obRender(a0)					; is object on-screen?
		bpl.w	DeleteObject					; if not, branch
		bra.w	DisplayAndCollision
; ===========================================================================

Bom_ShrSpeed:
		dc.w -$200, -$300				; top left
		dc.w -$100, -$200				; bottom left
		dc.w $200, -$300				; top right
		dc.w $100, -$200				; bottom right
; ===========================================================================