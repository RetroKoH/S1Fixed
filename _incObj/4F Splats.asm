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
		offsetTableEntry.w Splats_1
		offsetTableEntry.w Splats_2
		offsetTableEntry.w Splats_3
; ===========================================================================

Splats_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Splats,obMap(a0)
		move.w	#make_art_tile(ArtTile_Splats,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$C,obActWid(a0)
		move.b	#$14,obHeight(a0)
		move.b	#(colEnemy|$2),obColType(a0)
		tst.b	obSubtype(a0)
		beq.s	Splats_1
		move.w	#$300,d2
		bra.s	loc_D24A
; ===========================================================================

Splats_1:	; Routine 2
		move.w	#$E0,d2

loc_D24A:
		move.w	#$100,d1
		bset	#0,obRender(a0)
		move.w	(v_objspace+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	loc_D268
		neg.w	d0
		neg.w	d1
		bclr	#0,obRender(a0)

loc_D268:
		cmp.w	d2,d0
		bcc.s	Splats_2
		move.w	d1,obVelX(a0)
		addq.b	#2,obRoutine(a0)

Splats_2:	; Routine 4
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_D2AE
		move.b	#0,obFrame(a0)
		bsr.w	ObjFloorDist
		tst.w	d1
		bpl.s	loc_D2AE
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$2D2,d0
		bcs.s	loc_D2A4
		addq.b	#2,obRoutine(a0)
		bra.s	loc_D2AE
; ===========================================================================

loc_D2A4:
		add.w	d1,obY(a0)
		move.w	#-$400,obVelY(a0)

loc_D2AE:
		bsr.w	sub_D2DA
		beq.s	loc_D2C4
		neg.w	obVelX(a0)
		bchg	#0,obRender(a0)
		bchg	#0,obStatus(a0)

loc_D2C4:
		bra.w	RememberState
; ===========================================================================

Splats_3:	; Routine 6
		bsr.w	ObjectFall
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	RememberState
; ===========================================================================

sub_D2DA:
		move.w	(v_framecount).w,d0
		add.w	d7,d0
		andi.w	#3,d0
		bne.s	loc_D308
		moveq	#0,d3
		move.b	obActWid(a0),d3
		tst.w	obVelX(a0)
		bmi.s	loc_D2FE
		bsr.w	ObjHitWallRight
		tst.w	d1
		bpl.s	loc_D308

loc_D2FA:
		moveq	#1,d0
		rts
; ===========================================================================

loc_D2FE:
		not.w	d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.s	loc_D2FA

loc_D308:
		moveq	#0,d0
		rts