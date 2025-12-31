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
		offsetTableEntry.w BossPlasma_Finish
		offsetTableEntry.w BossPlasma_PlasmaBalls
; ===========================================================================

BossPlasma_Main:	; Routine 0
		move.w	#boss_fz_x+$138,obX(a0)
		move.w	#boss_fz_y+$2C,obY(a0)
		move.w	#make_art_tile(ArtTile_FZ_Boss,0,0),obGfx(a0)
		move.l	#Map_PLaunch,obMap(a0)
		clr.b	obAnim(a0)							; set initial animation
		move.w	#priority3,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager
		move.w	#$808,obHeight(a0)					; Height and Width
		move.b	#4,obRender(a0)
		bset	#7,obRender(a0)
		addq.b	#2,obRoutine(a0)					; -> BossPlasma_Generator
; ---------------------------------------------------------------------------

BossPlasma_Generator:	; Routine 2
		movea.w	obPlasma_Parent(a0),a1				; get address of parent object (Boss)
		cmpi.b	#6,obBFZ_Mode(a1)					; has boss been defeated?
		bne.s	.not_beaten							; if not, branch
		_move.l	#ExplosionBomb,obAddr(a0)			; make explosion
		clr.b	obRoutine(a0)
		jmp		(DisplaySprite).l
; ===========================================================================

	.not_beaten:
		moveq	#0,d0								; use initial red animation
		tst.b	obPlasma_Enabled(a0)				; is it time to spawn plasma balls?
		beq.s	Plasma_Update						; if not, branch
		addq.b	#2,obRoutine(a0)					; advance routine to make plasma balls
		moveq	#1,d0								; use sparking animation
; ---------------------------------------------------------------------------

Plasma_Update:
		jsr		(NewAnim).w							; set animation

BossPlasma_Solid:
		moveq	#19,d1								; width; save 4 cycles -- Filter
		moveq	#8,d2								; height (jumping); save 4 cycles -- Filter
		moveq	#17,d3								; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4							; axis position
		jsr		(SolidObject).l
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bmi.s	.animate							; branch if Sonic is left of the plasma launcher
		subi.w	#320,d0
		bmi.s	.animate							; branch if Sonic is within 320px of plasma launcher
		tst.b	obRender(a0)						; is object on-screen?
		bpl.w	ECyl_Delete							; if not, branch

	.animate:
		lea		Ani_PLaunch(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

BossPlasma_MakeBalls:	; Routine 4
		tst.b	obPlasma_Enabled(a0)				; is plasma set to activate?
		beq.w	.skip_balls							; if not, branch
		clr.b	obPlasma_Enabled(a0)
		clr.w	obPlasma_Count(a0)					; initialise plasma ball count
		moveq	#3,d2								; iterate for 4 plasma balls
		_move.l	#BossPlasma,d3						; copy object ID

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		movea.l	a0,a1
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.w	.skip_balls

	.loop:
		tst.l	obAddr(a1)							; is object RAM	slot empty?
		beq.s	.makeplasma							; if so, create plasma ball
		lea		object_size(a1),a1
		dbf		d0,.loop							; loop through object RAM
		bne.s	.skip_balls							; We're moving this line here.

	.makeplasma:
		_move.l	d3,obAddr(a1)						; create plasma object
		move.w	obX(a0),obX(a1)						; start at same position as launcher object
		move.w	#boss_fz_y+$2C,obY(a1)
		move.b	#8,obRoutine(a1)					; -> Plasma_Balls
		move.w	#make_art_tile(ArtTile_FZ_Boss,1,0),obGfx(a1)
		move.l	#Map_Plasma,obMap(a1)
		move.w	#$C0C,obHeight(a1)					; Height and Width
		clr.b	obColType(a1)

		bset	#shPropLightning,obShieldProp(a1)	; Negated by Lightning Shield

		move.w	#priority3,obPriority(a1)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$3E,obPlasma_Timer(a1)
		move.b	#4,obRender(a1)
		bset	#7,obRender(a1)
		move.w	a0,obPlasma_Parent(a1)				; set generator as plasma ball's parent
		jsr		(RandomNumber).w					; d0 = random number
		move.w	obPlasma_Count(a0),d1				; id of plasma ball (0-3)
		muls.w	#-$4F,d1							; avg distance between balls
		addi.w	#boss_fz_x+$128,d1					; add initial x pos
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d1,d0								; add random number between -16 and 15
		move.w	d0,obPlasma_TargetX(a1)				; randomly generate a target position for this ball to stop at
		addq.w	#1,obPlasma_Count(a0)				; next plasma ball
		dbf		d2,.loop							; repeat sequence 3 more times

		move.w	obPlasma_Count(a0),obPlasma_Count2(a0)	; call once when finished, instead of 4 times

	.skip_balls:
		tst.w	obPlasma_Count(a0)					; are plasma balls still loaded?
		bne.w	BossPlasma_Solid					; if yes, branch
		addq.b	#2,obRoutine(a0)					; -> Plasma_Finish (while the plasma balls are active)
		bra.w	BossPlasma_Solid
; ===========================================================================

BossPlasma_Finish:	; Routine 6
		moveq	#2,d0								; set animation to white sparking
		tst.w	obPlasma_Count2(a0)					; are the plasma balls offscreen?
		bne.w	Plasma_Update						; if not, branch
		move.b	#2,obRoutine(a0)					; -> Plasma_Generator (revert back to the first wait routine)
		movea.w	obPlasma_Parent(a0),a1				; object RAM address of parent object (Eggman)
		move.w	#-1,obBFZ_PhaseState(a1)			; signal to boss that plasma phase is finished
		bra.w	Plasma_Update
; ===========================================================================

BossPlasma_PlasmaBalls:	; Routine 8
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		jmp		PlasmaBall_Index(pc,d0.w)
; ===========================================================================

PlasmaBall_Index:
		bra.s	PlasmaBall_Init
		bra.s	PlasmaBall_GetIntoPosition
		bra.w	PlasmaBall_Descend
; ===========================================================================

PlasmaBall_Init:
		move.w	obPlasma_TargetX(a0),d0
		sub.w	obX(a0),d0
		asl.w	#4,d0
		move.w	d0,obVelX(a0)						; set speed so balls all arrive in position at the same time
		move.b	#180,obPlasma_Timer(a0)				; set timer to 3 seconds
		addq.b	#2,ob2ndRout(a0)					; -> PlasmaBall_GetIntoPosition
		lea		Ani_Plasma(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

PlasmaBall_GetIntoPosition:
		tst.w	obVelX(a0)							; is the ball still moving into position?
		beq.s	.skip_stop							; if not, branch
		jsr		(SpeedToPos_XOnly).l				; move horizontally
		move.w	obX(a0),d0
		sub.w	obPlasma_TargetX(a0),d0				; has the plasma ball reached target x-position?
		bcc.s	.skip_stop							; if not, branch
		clr.w	obVelX(a0)							; stop movement
		sub.w	d0,obX(a0)							; Devon Plasma Ball Fix
		movea.w	obPlasma_Parent(a0),a1				; object RAM address of parent object (generator)
		subq.w	#1,obPlasma_Count(a1)				; decrement count of plasma balls at top

	.skip_stop:
		moveq	#0,d0								; ani_plasma_full
		subq.b	#1,obPlasma_Timer(a0)				; decrement timer
		bne.s	.animate							; branch if not 0
		addq.b	#2,ob2ndRout(a0)					; -> PlasmaBall_Descend
		moveq	#1,d0								; ani_plasma_short
		move.b	#(colHarmful|colSz_12x12),obColType(a0)	; make plasma ball harmful
		move.b	#180,obPlasma_Timer(a0)				; set timer to 3 seconds
		moveq	#0,d1
		move.w	(v_player+obX).w,d1
		sub.w	obX(a0),d1
		move.w	d1,obVelX(a0)						; move towards Sonic's x-axis position
		move.w	#$140,obVelY(a0)					; set plasma ball to descend

	.animate:
		jsr		(NewAnim).w
		lea		Ani_Plasma(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

PlasmaBall_Descend:
		jsr		(SpeedToPos).l						; drop down towards Sonic's locked position
		cmpi.w	#boss_fz_y+$D0,obY(a0)				; has plasma ball moved off screen?
		bhs.s	.delete								; if yes, branch
		subq.b	#1,obPlasma_Timer(a0)				; decrement timer
		beq.s	.delete								; branch if 0
		lea		Ani_Plasma(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

	.delete:
		movea.w	obPlasma_Parent(a0),a1				; object RAM address of parent object (generator)
		subq.w	#1,obPlasma_Count2(a1)				; decrement count of plasma balls
		jmp		(DeleteObject).l
; ===========================================================================