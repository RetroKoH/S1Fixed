; ---------------------------------------------------------------------------
; Object 50 - Yadrin enemy (SYZ)
; ---------------------------------------------------------------------------

Yadrin:
		move.l	#Map_Yad,obMap(a0)
		move.w	#make_art_tile(ArtTile_Yadrin,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$14,obDispWid(a0)
		move.w	#$1108,obHeight(a0)			; Height and Width
		move.b	#(colSpecial|colSz_20x16),obColType(a0)
		bsr.w	ObjectFall_YOnly
		bsr.w	ObjFloorDist
		tst.w	d1							; has yadrin hit the floor?
		bpl.s	.keep_falling				; if not, branch
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop falling
		_move.l	#Yad_Move,obAddr(a0)
		bchg	#staFlipX,obStatus(a0)

	.keep_falling:
		rts	
; ===========================================================================

Yad_Move:
		subq.w	#1,obYadrin_WaitTime(a0)	; decrement timer
		bpl.s	.animate					; if time remains, branch
		_move.l	#Yad_FixToFloor,obAddr(a0)
		move.w	#-$100,obVelX(a0)			; move object left
		move.b	#1,obAnim(a0)
		bchg	#staFlipX,obStatus(a0)
		bne.s	.animate
		neg.w	obVelX(a0)					; change direction

	.animate:
		lea		Ani_Yad(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState	
; ===========================================================================

Yad_FixToFloor:
		bsr.w	SpeedToPos_XOnly
		bsr.w	ObjFloorDist
		cmpi.w	#-8,d1
		blt.s	.pause						; branch if > 8px below floor
		cmpi.w	#$C,d1
		bge.s	.pause						; branch if > 11px above floor (also detects a ledge)
		add.w	d1,obY(a0)					; align to floor
		bsr.s	Yad_ChkWall					; detect wall
		bne.s	.pause						; branch if wall is hit

;	.animate:
		lea		Ani_Yad(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState	
; ===========================================================================

	.pause:
		_move.l	#Yad_Move,obAddr(a0)
		move.w	#59,obYadrin_WaitTime(a0)	; set pause time to 1 second
		clr.w	obVelX(a0)					; stop moving
		clr.b	obAnim(a0)					; use standing animation
	; Animate
		lea		Ani_Yad(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to have Yadrin check for a wall
; ---------------------------------------------------------------------------

Yad_ChkWall:
		move.w	(v_framecount).w,d0			; get word that increments every frame
		add.w	d7,d0						; add OST id (so that multiple yadrins don't do wall check on the same frame)
		andi.w	#3,d0						; read only bits 0-1
		bne.s	.no_collision				; branch if either are set
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		tst.w	obVelX(a0)					; is yadrin moving to the left?
		bmi.s	.moving_left				; if yes, branch
		bsr.w	ObjHitWallRight
		tst.w	d1							; has yadrin hit wall to the right?
		bpl.s	.no_collision				; if not, branch

	.collision:
		moveq	#1,d0						; set collision flag
		rts	
; ===========================================================================

	.moving_left:
		not.w	d3							; flip width
		bsr.w	ObjHitWallLeft
		tst.w	d1							; has yadrin hit wall to the left?
		bmi.s	.collision					; if yes, branch

	.no_collision:
		moveq	#0,d0						; clear collision flag
		rts	
; End of function Yad_ChkWall
; ===========================================================================