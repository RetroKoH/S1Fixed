; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------

chop_origY = objoff_30

Chopper:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Chop_ChgSpeed
	; Object Routine Optimization End

Chop_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Chop,obMap(a0)
		move.w	#make_art_tile(ArtTile_Chopper,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#9,obColType(a0)
		move.b	#$10,obActWid(a0)
		move.w	#-$700,obVelY(a0)			; set vertical speed
		move.w	obY(a0),chop_origY(a0)		; save original position

Chop_ChgSpeed:	; Routine 2
		lea		Ani_Chop(pc),a1
		bsr.w	AnimateSprite
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)		; reduce speed
		move.w	chop_origY(a0),d0
		cmp.w	obY(a0),d0			; has Chopper returned to its original position?
		bhs.s	.chganimation		; if not, branch
		move.w	d0,obY(a0)
		move.w	#-$700,obVelY(a0)	; set vertical speed

.chganimation:
		move.b	#1,obAnim(a0)	; use fast animation
		subi.w	#$C0,d0
		cmp.w	obY(a0),d0
		bhs.s	.nochg
		clr.b	obAnim(a0)		; use slow animation
		tst.w	obVelY(a0)		; is Chopper at	its highest point?
		bmi.s	.nochg			; if not, branch
		move.b	#2,obAnim(a0)	; use stationary animation

.nochg:
		bra.w	RememberState	; LavaGaming Object Routine Optimization
