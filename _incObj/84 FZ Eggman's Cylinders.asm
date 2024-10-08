; ---------------------------------------------------------------------------
; Object 84 - cylinder Eggman hides in (FZ)
; ---------------------------------------------------------------------------

EggmanCylinder_Delete:
		jmp	(DeleteObject).l
; ===========================================================================

EggmanCylinder:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	EggmanCylinder_Index(pc,d0.w),d0
		jmp		EggmanCylinder_Index(pc,d0.w)
; ===========================================================================
EggmanCylinder_Index:	offsetTable
		offsetTableEntry.w EggmanCylinder_Main
		offsetTableEntry.w loc_1A4CE
		offsetTableEntry.w loc_1A57E

EggmanCylinder_PosData:
		dc.w boss_fz_x+$80,  boss_fz_y+$110
		dc.w boss_fz_x+$100, boss_fz_y+$110
		dc.w boss_fz_x+$40,  boss_fz_y-$50
		dc.w boss_fz_x+$C0,  boss_fz_y-$50
; ===========================================================================

EggmanCylinder_Main:	; Routine 0
		lea		EggmanCylinder_PosData(pc),a1
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		adda.w	d0,a1
		move.b	#4,obRender(a0)
		bset	#7,obRender(a0)
		bset	#4,obRender(a0)
		move.w	#make_art_tile(ArtTile_FZ_Boss,0,0),obGfx(a0)
		move.l	#Map_EggCyl,obMap(a0)
		move.w	(a1)+,obX(a0)
		move.w	(a1),obY(a0)
		move.w	(a1)+,objoff_38(a0)
		move.b	#$20,obHeight(a0)
		move.b	#$60,obWidth(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$60,obHeight(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		addq.b	#2,obRoutine(a0)

loc_1A4CE:	; Routine 2
		cmpi.b	#2,obSubtype(a0)
		ble.s	loc_1A4DC
		bset	#1,obRender(a0)

loc_1A4DC:
		clr.l	objoff_3C(a0)
		tst.b	objoff_29(a0)
		beq.s	loc_1A4EA
		addq.b	#2,obRoutine(a0)

loc_1A4EA:
		move.l	objoff_3C(a0),d0
		move.l	objoff_38(a0),d1
		add.l	d0,d1
		swap	d1
		move.w	d1,obY(a0)
		cmpi.b	#4,obRoutine(a0)
		bne.s	loc_1A524
		tst.w	objoff_30(a0)
		bpl.s	loc_1A524
		moveq	#-$A,d0
		cmpi.b	#2,obSubtype(a0)
		ble.s	loc_1A514
		moveq	#$E,d0

loc_1A514:
		add.w	d0,d1
		movea.l	objoff_34(a0),a1
		move.w	d1,obY(a1)
		move.w	obX(a0),obX(a1)

loc_1A524:
		move.w	#$2B,d1
		move.w	#$60,d2
		move.w	#$61,d3
		move.w	obX(a0),d4
		jsr		(SolidObject).l
		moveq	#0,d0
		move.w	objoff_3C(a0),d1
		bpl.s	loc_1A550
		neg.w	d1
		subq.w	#8,d1
		bcs.s	loc_1A55C
		addq.b	#1,d0
		asr.w	#4,d1
		add.w	d1,d0
		bra.s	loc_1A55C
; ===========================================================================

loc_1A550:
		subi.w	#$27,d1
		bcs.s	loc_1A55C
		addq.b	#1,d0
		asr.w	#4,d1
		add.w	d1,d0

loc_1A55C:
		move.b	d0,obFrame(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bmi.s	loc_1A578
		subi.w	#$140,d0
		bmi.s	loc_1A578
		tst.b	obRender(a0)
		bpl.w	EggmanCylinder_Delete

loc_1A578:
		jmp		(DisplaySprite).l
; ===========================================================================

loc_1A57E:	; Routine 4
	; LavaGaming Object Routine Optimization
		cmpi.b	#2,obSubtype(a0)
		bgt.s	loc_1A604
	; Object Routine Optimization End

loc_1A598:	; Subtypes 00 and 02
		tst.b	objoff_29(a0)
		bne.s	loc_1A5D4
		movea.l	objoff_34(a0),a1
		tst.b	obColProp(a1)
		bne.s	loc_1A5B4
		bsr.w	BossDefeated
		subi.l	#$10000,objoff_3C(a0)

loc_1A5B4:
		addi.l	#$20000,objoff_3C(a0)
		bcc.w	loc_1A4EA
		clr.l	objoff_3C(a0)
		movea.l	objoff_34(a0),a1
		subq.w	#1,objoff_32(a1)
		clr.w	objoff_30(a1)
		subq.b	#2,obRoutine(a0)
		bra.w	loc_1A4EA	
; ===========================================================================

loc_1A5D4:
		cmpi.w	#-$10,objoff_3C(a0)
		bge.s	loc_1A5E4
		subi.l	#$28000,objoff_3C(a0)

loc_1A5E4:
		subi.l	#$8000,objoff_3C(a0)
		cmpi.w	#-$A0,objoff_3C(a0)
		bgt.w	loc_1A4EA
		clr.w	objoff_3E(a0)
		move.w	#-$A0,objoff_3C(a0)
		clr.b	objoff_29(a0)
		bra.w	loc_1A4EA	
; ===========================================================================

loc_1A604:	; Subtypes 04 and 06
		bset	#1,obRender(a0)
		tst.b	objoff_29(a0)
		bne.s	loc_1A646
		movea.l	objoff_34(a0),a1
		tst.b	obColProp(a1)
		bne.s	loc_1A626
		bsr.w	BossDefeated
		addi.l	#$10000,objoff_3C(a0)

loc_1A626:
		subi.l	#$20000,objoff_3C(a0)
		bcc.w	loc_1A4EA
		clr.l	objoff_3C(a0)
		movea.l	objoff_34(a0),a1
		subq.w	#1,objoff_32(a1)
		clr.w	objoff_30(a1)
		subq.b	#2,obRoutine(a0)
		bra.w	loc_1A4EA	
; ===========================================================================

loc_1A646:
		cmpi.w	#$10,objoff_3C(a0)
		blt.s	loc_1A656
		addi.l	#$28000,objoff_3C(a0)

loc_1A656:
		addi.l	#$8000,objoff_3C(a0)
		cmpi.w	#$A0,objoff_3C(a0)
		blt.w	loc_1A4EA
		clr.w	objoff_3E(a0)
		move.w	#$A0,objoff_3C(a0)
		clr.b	objoff_29(a0)
		bra.w	loc_1A4EA	
