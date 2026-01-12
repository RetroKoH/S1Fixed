; ---------------------------------------------------------------------------
; Object 4F - Splats enemy (Unused)
; Ported up from prototype (Need to add second subtype)
; ---------------------------------------------------------------------------

Splats:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Splats_Index(pc,d0.w),d1
		jmp		Splats_Index(pc,d1.w)
; ===========================================================================
Splats_Index:	offsetTable
		offsetTableEntry.w Splats_Main
		offsetTableEntry.w Splats_ChkDist
		offsetTableEntry.w Splats_Move
		offsetTableEntry.w Splats_Fall
; ===========================================================================

Splats_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Splats,obMap(a0)
		move.w	#make_art_tile(ArtTile_Splats,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$C,obDispWid(a0)
		move.b	#$14,obHeight(a0)
		move.b	#(colEnemy|colSz_12x20),obColType(a0)
		tst.b	obSubtype(a0)
		beq.s	Splats_ChkDist
		move.w	#$300,d2
		bra.s	loc_D24A
; ===========================================================================

Splats_ChkDist:	; Routine 2
		move.w	#$E0,d2

loc_D24A:
		move.w	#$100,d1				; move right
		bset	#renXFlip,obRender(a0)	; face right
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	loc_D268
		neg.w	d0
		neg.w	d1						; move left
		bclr	#renXFlip,obRender(a0)	; face left

loc_D268:
		cmp.w	d2,d0
		bcc.s	Splats_Move
		move.w	d1,obVelX(a0)			; apply movement
		addq.b	#2,obRoutine(a0)		; -> Splats_Move

Splats_Move:	; Routine 4
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	.chk_walls				; branch if Splats is moving up
		move.b	#0,obFrame(a0)
		bsr.w	ObjFloorDist
		tst.w	d1
		bpl.s	.chk_walls				; branch if Splats is above the floor
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$2D2,d0
		bcs.s	.bounce
		addq.b	#2,obRoutine(a0)
		bra.s	.chk_walls
; ===========================================================================

	.bounce:
		add.w	d1,obY(a0)				; align to floor
		move.w	#-$400,obVelY(a0)		; bounce

	.chk_walls:
		bsr.w	Splats_ChkWalls
		beq.s	loc_D2C4
		neg.w	obVelX(a0)
		bchg	#renXFlip,obRender(a0)	; change sprite direction
		bchg	#0,obStatus(a0)

loc_D2C4:
		bra.w	RememberState
; ===========================================================================

Splats_Fall:	; Routine 6
		bsr.w	ObjectFall
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to detect collision with walls
;
; output:
;	d0.l = 1 when wall is found; 0 otherwise
;	d1.w = distance to wall
; ---------------------------------------------------------------------------

Splats_ChkWalls:
		move.w	(v_framecount).w,d0
		add.w	d7,d0
		andi.w	#3,d0					; subroutine only runs every 4th frame (different for each Splats)
		bne.s	.no_wall				; branch if not on specific frame
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		tst.w	obVelX(a0)
		bmi.s	.moving_left
		bsr.w	ObjHitWallRight
		tst.w	d1
		bpl.s	.no_wall				; branch if Splats hasn't hit wall

	.found_wall:
		moveq	#1,d0
		rts
; ===========================================================================

	.moving_left:
		not.w	d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.s	.found_wall

	.no_wall:
		moveq	#0,d0
		rts
; ===========================================================================