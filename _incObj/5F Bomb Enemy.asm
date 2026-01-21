; ---------------------------------------------------------------------------
; Object 5F - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------
; OST Constants
obBomb_FuseTime:		equ objoff_30		; 2 bytes | time of fuse
obBomb_StartY:			equ objoff_34		; 2 bytes | original y-axis position
obBomb_Parent:			equ objoff_3E		; 2 bytes | address of parent object (unused?)
; ---------------------------------------------------------------------------

Bomb:
		obj_addr	#Bom_Wait
		move.l	#Map_Bomb,obMap(a0)
		move.w	#make_art_tile(ArtTile_Bomb,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$C,obDispWid(a0)
		move.b	#(colHarmful|colSz_12x12),obColType(a0)
		bchg	#staFlipX,obStatus(a0)
		move.w	#$10,obVelX(a0)
; ---------------------------------------------------------------------------

Bom_Wait:
		subq.b	#1,obTimeFrame(a0)				; decrement time
		bpl.s	.wait							; if time remains, branch
		move.b	#$13,obTimeFrame(a0)			; reset time based on desired animation speed
		bchg	#0,obFrame(a0)					; swap frames to animate

	.wait:
		bsr.w	Bom_ChkDistToSonic
		subq.w	#1,obBomb_FuseTime(a0)			; subtract 1 from time delay
		bpl.s	Bom_ChkDistToSonic				; if time remains, branch
		obj_addr	#Bom_Walk
		clr.w	obAniFrame(a0)					; reset animation
		move.w	#1535,obBomb_FuseTime(a0)		; set time delay to 25.5 seconds
		bchg	#staFlipX,obStatus(a0)
		neg.w	obVelX(a0)						; change direction
		bra.s	Bom_ChkDistToSonic
; ===========================================================================

Bom_Walk:
		lea		Ani_Bomb(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	SpeedToPos_XOnly
		subq.w	#1,obBomb_FuseTime(a0)			; decrement timer
		bpl.s	Bom_ChkDistToSonic				; if time remains, branch
		obj_addr	#Bom_Wait
		move.w	#179,obBomb_FuseTime(a0)		; set time delay to 3 seconds
		move.b	#0,obFrame(a0)					; second standing frame

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
		bhs.w	RememberState					; if not, branch
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		bcc.s	.isabove
		neg.w	d0

	.isabove:
		cmpi.w	#$60,d0							; is Sonic within $60 pixels?
		bhs.w	RememberState					; if not, branch
		tst.w	(v_debuguse).w					; is Debug Mode Active?
		bne.w	RememberState					; if yes, branch

		obj_addr	#Bom_Explode
		move.w	#143,obBomb_FuseTime(a0)		; set fuse time
		clr.w	obVelX(a0)
		move.b	#7,obFrame(a0)					; first activated frame
		bsr.w	FindNextFreeObj
		bne.w	RememberState

		_move.l	#Bomb_Fuse,obAddr(a1)			; load fuse object
		move.l	#Map_Bomb,obMap(a1)
		move.w	#make_art_tile(ArtTile_Bomb,0,0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#priority3,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obY(a0),obBomb_StartY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#8,obFrame(a1)					; first fuse frame
		move.w	#$10,obVelY(a1)
		btst	#staFlipY,obStatus(a1)			; is bomb upside-down?
		beq.s	.normal							; if not, branch
		neg.w	obVelY(a1)						; reverse direction for fuse

	.normal:
		move.w	#143,obBomb_FuseTime(a1)		; set fuse time
		move.w	a0,obBomb_Parent(a1)

	.outofrange:
		bra.w	RememberState	
; ===========================================================================

Bom_Explode:
		subq.b	#1,obTimeFrame(a0)				; decrement time
		bpl.s	.wait							; if time remains, branch
		move.b	#$13,obTimeFrame(a0)			; reset time based on desired animation speed
		bchg	#0,obFrame(a0)					; swap frames to animate

	.wait:
		subq.w	#1,obBomb_FuseTime(a0)			; subtract 1 from time delay
		bpl.s	.noexplode						; if time remains, branch
		_move.l	#ExplosionBomb,obAddr(a0)		; change bomb into an explosion

	.noexplode:
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 5F - Bomb's fuse
; ---------------------------------------------------------------------------

Bomb_Fuse:
		subq.b	#1,obTimeFrame(a0)			; decrement time
		bpl.s	.wait						; if time remains, branch
		move.b	#3,obTimeFrame(a0)			; reset time based on desired animation speed
		bchg	#0,obFrame(a0)				; swap frames to animate

	.wait:
		bsr.s	Bom_Fuse_ChkTime
		bra.w	DisplaySprite
; ===========================================================================

Bom_Fuse_ChkTime:
		subq.w	#1,obBomb_FuseTime(a0)			; decrement fuse timer
		bmi.s	.explode						; branch if fuse runs out
		bra.w	SpeedToPos_YOnly
; ===========================================================================

	.explode:
		clr.w	obBomb_FuseTime(a0)
		move.w	obBomb_StartY(a0),obY(a0)
		moveq	#2,d1							; 3 additional shrapnel objects
		_move.l	#Bomb_Shrapnel,d2				; store code address for shrapnel
		movea.l	a0,a1							; turn this object into shrapnel
		lea		(Bom_ShrSpeed).l,a2				; load shrapnel speed data

	; Init the first shrapnel object
		_move.l	d2,obAddr(a1)					; this is now a shrapnel object
		move.b	#4,obRender(a1)
		move.b	#8,obDispWid(a1)
		move.b	#$A,obFrame(a1)					; first shrapnel frame
		move.l	(a2)+,obVelX(a1)				; move the data contained in the array to obVelX and obVelY, and increment the address in a2
		move.b	#(colHarmful|colSz_4x4),obColType(a1)

		bset	#shPropReflect,obShieldProp(a1)	; Reflected by Elemental Shields

		bset	#renVisible,obRender(a1)		; set object as visible

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	.fail

	.loop:
		tst.l	obAddr(a1)						; is object RAM	slot empty?
		beq.s	.makeshrapnel					; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop						; loop through object RAM
		bne.s	.fail							; We're moving this line here.

	; make 3 more shrapnel fragments
	.makeshrapnel:
		_move.l	d2,obAddr(a1)					; load shrapnel	object
		move.l	#Map_Bomb,obMap(a1)
		move.w	#make_art_tile(ArtTile_Bomb,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority3,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	#8,obDispWid(a1)
		move.b	#$A,obFrame(a1)					; first shrapnel frame
		move.l	(a2)+,obVelX(a1)				; move the data contained in the array to obVelX and obVelY, and increment the address in a2
		move.b	#(colHarmful|colSz_4x4),obColType(a1)

		bset	#shPropReflect,obShieldProp(a1)	; Reflected by Elemental Shields

		bset	#renVisible,obRender(a1)		; set object as visible

	.fail:
		dbf		d1,.loop						; repeat 3 more	times
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Object 5F - Bomb's shrapnel (could share with SLZ boss?)
; ---------------------------------------------------------------------------

Bomb_Shrapnel:
		subq.b	#1,obTimeFrame(a0)				; decrement time
		bpl.s	.wait							; if time remains, branch
		move.b	#3,obTimeFrame(a0)				; reset time based on desired animation speed
		bchg	#0,obFrame(a0)					; swap frames to animate

	.wait:
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)					; apply gravity
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