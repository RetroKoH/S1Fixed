; ---------------------------------------------------------------------------
; Object 86 - energy balls (FZ)
; ---------------------------------------------------------------------------

BossPlasma:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossPlasma_Index(pc,d0.w),d0
		jmp		BossPlasma_Index(pc,d0.w)
; ===========================================================================
BossPlasma_Index:	offsetTable
		offsetTableEntry.w BossPlasma_Main
		offsetTableEntry.w BossPlasma_Generator
		offsetTableEntry.w BossPlasma_MakeBalls
		offsetTableEntry.w BossPlasma_WaitForBalls
		offsetTableEntry.w BossPlasma_PlasmaBall

plasma_enabled = objoff_29		; flag noting when to spawn plasma balls (1 byte)
plasma_targetX = objoff_30		; target x-position for the plasma ball to move toward (2 bytes)
plasma_count = objoff_32		; plasma ball count (2 bytes)
plasma_count2 = objoff_38		; copy of plasma ball count (2 bytes)
; ===========================================================================

BossPlasma_Main:	; Routine 0
		move.w	#boss_fz_x+$138,obX(a0)
		move.w	#boss_fz_y+$2C,obY(a0)
		move.w	#make_art_tile(ArtTile_FZ_Boss,0,0),obGfx(a0)
		move.l	#Map_PLaunch,obMap(a0)
		clr.b	obAnim(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	#$808,obHeight(a0)			; Height and Width
		move.b	#4,obRender(a0)
		bset	#7,obRender(a0)
		addq.b	#2,obRoutine(a0)

BossPlasma_Generator:; Routine 2
		movea.l	boss_parent(a0),a1			; load boss object to a1
		cmpi.b	#6,objoff_34(a1)			; has boss been defeated? (See loc_19FBC)
		bne.s	loc_1A850					; if not, branch
		move.b	#id_ExplosionBomb,obID(a0)	; make explosion
		clr.b	obRoutine(a0)
		jmp		(DisplaySprite).l
; ===========================================================================

loc_1A850:
		clr.b	obAnim(a0)
		tst.b	plasma_enabled(a0)			; is it time to spawn plasma balls?
		beq.s	BossPlasma_Solid			; if not, branch
		addq.b	#2,obRoutine(a0)			; advance routine to make plasma balls
		move.b	#1,obAnim(a0)
		move.b	#$3E,obSubtype(a0)

BossPlasma_Solid:
		move.w	#$13,d1
		move.w	#8,d2
		move.w	#$11,d3
		move.w	obX(a0),d4
		jsr		(SolidObject).l
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bmi.s	.display
		subi.w	#$140,d0
		bmi.s	.display
		tst.b	obRender(a0)
		bpl.w	EggmanCylinder_Delete

	.display:
		lea		Ani_PLaunch(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

BossPlasma_MakeBalls:; Routine 4
		tst.b	plasma_enabled(a0)
		beq.w	.fail
		clr.b	plasma_enabled(a0)
		add.w	objoff_30(a0),d0
		andi.w	#$1E,d0
		adda.w	d0,a2
		addq.w	#4,objoff_30(a0)
		clr.w	plasma_count(a0)
		moveq	#3,d2								; iterate for 4 plasma balls
		_move.b	#id_BossPlasma,d3					; copy object ID

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		movea.l	a0,a1
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.w	.fail

	.loop:
		tst.b	obID(a1)							; is object RAM	slot empty?
		beq.s	.makeplasma							; if so, create plasma ball
		lea		object_size(a1),a1
		dbf		d0,.loop							; loop through object RAM
		bne.s	.fail								; We're moving this line here.

	.makeplasma:
		_move.b	d3,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	#boss_fz_y+$2C,obY(a1)
		move.b	#8,obRoutine(a1)					; set to plasma ball routine
		move.w	#make_art_tile(ArtTile_FZ_Boss,1,0),obGfx(a1)
		move.l	#Map_Plasma,obMap(a1)
		move.w	#$C0C,obHeight(a1)					; Height and Width
		clr.b	obColType(a1)

		bset	#shPropLightning,obShieldProp(a1)	; Negated by Lightning Shield

		move.w	#priority3,obPriority(a1)			; RetroKoH/Devon S3K+ Priority Manager
		move.w	#$3E,obSubtype(a1)
		move.b	#4,obRender(a1)
		bset	#7,obRender(a1)
		move.l	a0,boss_parent(a1)					; set generator as plasma ball's parent
		jsr		(RandomNumber).w
		move.w	plasma_count(a0),d1
		muls.w	#-$4F,d1
		addi.w	#boss_fz_x+$128,d1
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d1,d0
		move.w	d0,plasma_targetX(a1)				; randomly generate a target position for this ball
		addq.w	#1,plasma_count(a0)
		dbf		d2,.loop							; repeat sequence 3 more times
		move.w	plasma_count(a0),plasma_count2(a0)

	.fail:
		tst.w	plasma_count(a0)
		bne.w	BossPlasma_Solid
		addq.b	#2,obRoutine(a0)					; advance to the next routine while the balls are active
		bra.w	BossPlasma_Solid
; ===========================================================================

BossPlasma_WaitForBalls:	; Routine 6
		move.b	#2,obAnim(a0)
		tst.w	plasma_count2(a0)					; are the plasma balls offscreen?
		bne.w	BossPlasma_Solid					; if not, branch
		move.b	#2,obRoutine(a0)					; revert back to the first wait routine
		movea.l	boss_parent(a0),a1
		move.w	#-1,objoff_32(a1)
		bra.w	BossPlasma_Solid
; ===========================================================================

BossPlasma_PlasmaBall:	; Routine 8
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		jmp		PlasmaBall_Index(pc,d0.w)
; ===========================================================================
PlasmaBall_Index:
		bra.s	PlasmaBall_Init
		bra.s	PlasmaBall_GetIntoPosition
		bra.w	PlasmaBall_Descend

pball_timer = obSubtype		; timer used during movement routines
; ===========================================================================

PlasmaBall_Init:
		move.w	plasma_targetX(a0),d0
		sub.w	obX(a0),d0
		asl.w	#4,d0
		move.w	d0,obVelX(a0)						; use distance between starting XPos and target XPos to set X-speed
		move.w	#180,pball_timer(a0)				; set timer to 3 seconds
		addq.b	#2,ob2ndRout(a0)					; advance to first movement routine
		lea		Ani_Plasma(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

PlasmaBall_GetIntoPosition:
		tst.w	obVelX(a0)							; is the ball still moving into position?
		beq.s	.skip								; if not, branch
		jsr		(SpeedToPos_XOnly).l				; move horizontally
		move.w	obX(a0),d0
		sub.w	plasma_targetX(a0),d0				; is the plasma ball in position?
		bcc.s	.skip								; if not, branch
		clr.w	obVelX(a0)							; stop movement
		sub.w	d0,obX(a0)							; Devon Plasma Ball Fix
		movea.l	boss_parent(a0),a1					; load generator to a1
		subq.w	#1,plasma_count(a1)					; decrement first plasma ball count

	.skip:
		clr.b	obAnim(a0)
		subq.w	#1,pball_timer(a0)					; is wait time remaining?
		bne.s	.display							; if yes, branch
		addq.b	#2,ob2ndRout(a0)					; advance to descent routine
		move.b	#1,obAnim(a0)
		move.b	#(colHarmful|colSz_12x12),obColType(a0)
		move.w	#180,pball_timer(a0)				; set timer to 3 seconds
		moveq	#0,d0
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		move.w	d0,obVelX(a0)						; set X-speed so that it moves towards Sonic's current position
		move.w	#$140,obVelY(a0)					; set plasma ball to descend

	.display:
		lea		Ani_Plasma(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

PlasmaBall_Descend:
		jsr		(SpeedToPos).l						; drop down towards Sonic's locked position
		cmpi.w	#boss_fz_y+$D0,obY(a0)				; has the plasma ball moved below the floor ($5E0)?
		bhs.s	.delete								; if yes, branch
		subq.w	#1,pball_timer(a0)					; decrement timer
		beq.s	.delete								; if timer is up, branch
		lea		Ani_Plasma(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

	.delete:
		movea.l	boss_parent(a0),a1					; load generator to a1
		subq.w	#1,plasma_count2(a1)
		bra.w	EggmanCylinder_Delete
; ===========================================================================
