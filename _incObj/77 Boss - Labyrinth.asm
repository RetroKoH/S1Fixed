; ---------------------------------------------------------------------------
; Object 77 - Eggman (LZ)
; ---------------------------------------------------------------------------

BossLabyrinth:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossLabyrinth_Index(pc,d0.w),d1
		jmp		BossLabyrinth_Index(pc,d1.w)
; ===========================================================================
BossLabyrinth_Index:	offsetTable
		offsetTableEntry.w BossLabyrinth_Main
		offsetTableEntry.w BossLabyrinth_ShipMain
		offsetTableEntry.w BossLabyrinth_FaceMain
		offsetTableEntry.w BossLabyrinth_FlameMain

BossLabyrinth_ObjData:
		dc.b 2,	0		; routine number, animation
		dc.b 4,	1
		dc.b 6,	7
; ===========================================================================

BossLabyrinth_Main:	; Routine 0
		move.w	#boss_lz_x+$30,obX(a0)
		move.w	#boss_lz_y+$500,obY(a0)
		move.w	obX(a0),objoff_30(a0)
		move.w	obY(a0),objoff_38(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)				; set number of hits to 8
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		lea		BossLabyrinth_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	BossLabyrinth_LoadBoss
; ===========================================================================

BossLabyrinth_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	BossLabyrinth_ShipMain
		_move.b	#id_BossLabyrinth,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

BossLabyrinth_LoadBoss:
		bclr	#staFlipX,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.w	obPriority(a0),obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.l	a0,objoff_34(a1)
		dbf		d1,BossLabyrinth_Loop

BossLabyrinth_ShipMain:	; Routine 2
		lea		(v_player).w,a1
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossLabyrinth_ShipIndex(pc,d0.w),d1
		jsr		BossLabyrinth_ShipIndex(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================
BossLabyrinth_ShipIndex:	offsetTable
		offsetTableEntry.w loc_17F1E
		offsetTableEntry.w loc_17FA0
		offsetTableEntry.w loc_17FE0
		offsetTableEntry.w loc_1801E
		offsetTableEntry.w loc_180BC
		offsetTableEntry.w loc_180F6
		offsetTableEntry.w loc_1812A
		offsetTableEntry.w loc_18152
; ===========================================================================

loc_17F1E:
		move.w	obX(a1),d0
		cmpi.w	#boss_lz_x-$40,d0
		blo.s	loc_17F38
		move.w	#-$180,obVelY(a0)
		move.w	#$60,obVelX(a0)
		addq.b	#2,ob2ndRout(a0)

loc_17F38:
		bsr.w	BossMove
		move.w	objoff_38(a0),obY(a0)
		move.w	objoff_30(a0),obX(a0)

loc_17F48:
		tst.b	objoff_3D(a0)
		bne.w	BossDefeated
		tst.b	obStatus(a0)
		bmi.s	loc_17F92
		tst.b	obColType(a0)
		bne.s	locret_17F8C
		tst.b	objoff_3E(a0)
		bne.s	BossLabyrinth_ShipFlash
		move.b	#$20,objoff_3E(a0)
		move.w	#sfx_HitBoss,d0
		jsr		(PlaySound_Special).w

BossLabyrinth_ShipFlash:
		lea		(v_palette+$22).w,a1 ; load 2nd palette, 2nd entry
		moveq	#0,d0		; move 0 (black) to d0
		tst.w	(a1)
		bne.s	loc_17F7E
		move.w	#cWhite,d0	; move 0EEE (white) to d0

loc_17F7E:
		move.w	d0,(a1)
		subq.b	#1,objoff_3E(a0)
		bne.s	locret_17F8C
		move.b	#(colEnemy|colSz_24x24),obColType(a0)

locret_17F8C:
		rts	
; ===========================================================================

loc_17F92:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#-1,objoff_3D(a0)
		rts	
; ===========================================================================

loc_17FA0:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$68,objoff_30(a0)
		blo.s	loc_17FB6
		move.w	#boss_lz_x+$68,objoff_30(a0)
		clr.w	obVelX(a0)
		addq.w	#1,d0

loc_17FB6:
		cmpi.w	#boss_lz_y+$440,objoff_38(a0)
		bgt.s	loc_17FCA
		move.w	#boss_lz_y+$440,objoff_38(a0)
		clr.w	obVelY(a0)
		addq.w	#1,d0

loc_17FCA:
		bne.w	loc_17F38
		move.w	#$140,obVelX(a0)
		move.w	#-$200,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_17FE0:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$90,objoff_30(a0)
		blo.s	loc_17FF6
		move.w	#boss_lz_x+$90,objoff_30(a0)
		clr.w	obVelX(a0)
		addq.w	#1,d0

loc_17FF6:
		cmpi.w	#boss_lz_y+$400,objoff_38(a0)
		bgt.s	loc_1800A
		move.w	#boss_lz_y+$400,objoff_38(a0)
		clr.w	obVelY(a0)
		addq.w	#1,d0

loc_1800A:
		bne.w	loc_17F38
		move.w	#-$180,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)
		clr.b	objoff_3F(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_1801E:
		cmpi.w	#boss_lz_y+$40,objoff_38(a0)
		bgt.s	loc_1804E
		move.w	#boss_lz_y+$40,objoff_38(a0)
		move.w	#$140,obVelX(a0)
		move.w	#-$80,obVelY(a0)
		tst.b	objoff_3D(a0)
		beq.s	loc_18046
		asl		obVelX(a0)
		asl		obVelY(a0)

loc_18046:
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_1804E:
		bset	#staFlipX,obStatus(a0)
		addq.b	#2,objoff_3F(a0)
		move.b	objoff_3F(a0),d0
		jsr		(CalcSine).w
		tst.w	d1
		bpl.s	loc_1806C
		bclr	#staFlipX,obStatus(a0)

loc_1806C:
		asr.w	#4,d0
		swap	d0
		clr.w	d0
		add.l	objoff_30(a0),d0
		swap	d0
		move.w	d0,obX(a0)
		move.w	obVelY(a0),d0
		move.w	(v_player+obY).w,d1
		sub.w	obY(a0),d1
		bcs.s	loc_180A2
		subi.w	#$48,d1
		bcs.s	loc_180A2
		asr.w	#1,d0
		subi.w	#$28,d1
		bcs.s	loc_180A2
		asr.w	#1,d0
		subi.w	#$28,d1
		bcs.s	loc_180A2
		moveq	#0,d0

loc_180A2:
		ext.l	d0
		asl.l	#8,d0
		tst.b	objoff_3D(a0)
		beq.s	loc_180AE
		add.l	d0,d0

loc_180AE:
		add.l	d0,objoff_38(a0)
		move.w	objoff_38(a0),obY(a0)
		bra.w	loc_17F48
; ===========================================================================

loc_180BC:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$16C,objoff_30(a0)
		blo.s	loc_180D2
		move.w	#boss_lz_x+$16C,objoff_30(a0)
		clr.w	obVelX(a0)
		addq.w	#1,d0

loc_180D2:
		cmpi.w	#boss_lz_y,objoff_38(a0)
		bgt.s	loc_180E6
		move.w	#boss_lz_y,objoff_38(a0)
		clr.w	obVelY(a0)
		addq.w	#1,d0

loc_180E6:
		bne.w	loc_17F38
		addq.b	#2,ob2ndRout(a0)
		bclr	#staFlipX,obStatus(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_180F6:
		tst.b	objoff_3D(a0)
		bne.s	loc_18112
		cmpi.w	#boss_lz_x+$E8,obX(a1)
		blt.w	loc_17F38
		cmpi.w	#boss_lz_y+$30,obY(a1)
		bgt.w	loc_17F38
		move.b	#$32,objoff_3C(a0)

loc_18112:
		move.w	#bgm_LZ,d0
		jsr		(PlaySound).w			; play LZ music
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		clr.b	(f_lockscreen).w
		bset	#staFlipX,obStatus(a0)
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_1812A:
		tst.b	objoff_3D(a0)
		bne.s	loc_18136
		subq.b	#1,objoff_3C(a0)
		bne.w	loc_17F38

loc_18136:
		clr.b	objoff_3C(a0)
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		clr.b	objoff_3D(a0)
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_17F38
; ===========================================================================

loc_18152:
		cmpi.w	#boss_lz_end,(v_limitright2).w
		bhs.s	loc_18160
		addq.w	#2,(v_limitright2).w
		bra.w	loc_17F38
; ===========================================================================

loc_18160:
		tst.b	obRender(a0)
		bpl.s	BossLabyrinth_ShipDel
		bra.w	loc_17F38
; ===========================================================================

BossLabyrinth_ShipDel:
		; Avoid returning to BossLabyrinth_ShipMain to prevent a
		; display-and-delete bug.
		addq.l	#4,sp			; Clownacy DisplaySprite Fix
		jmp		(DeleteObject).l
; ===========================================================================

BossLabyrinth_FaceMain:	; Routine 4
		movea.l	objoff_34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.s	BossLabyrinth_FaceDel
		moveq	#0,d0
		move.b	ob2ndRout(a1),d0
		moveq	#1,d1
		tst.b	objoff_3D(a0)
		beq.s	loc_1818C
		moveq	#$A,d1
		bra.s	loc_181A0
; ===========================================================================

loc_1818C:
		tst.b	obColType(a1)
		bne.s	loc_18196
		moveq	#5,d1
		bra.s	loc_181A0
; ===========================================================================

loc_18196:
		cmpi.b	#4,(v_player+obRoutine).w
		blo.s	loc_181A0
		moveq	#4,d1

loc_181A0:
		move.b	d1,obAnim(a0)
		cmpi.b	#$E,d0
		bne.s	BossLabyrinth_Display
		move.b	#6,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BossLabyrinth_FaceDel
		bra.s	BossLabyrinth_Display
; ===========================================================================

BossLabyrinth_FaceDel:
		jmp		(DeleteObject).l
; ===========================================================================

BossLabyrinth_FlameMain:; Routine 6
		move.b	#7,obAnim(a0)
		movea.l	objoff_34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.s	BossLabyrinth_FlameDel
		cmpi.b	#$E,ob2ndRout(a1)
		bne.s	BossLabyrinth_Display
		move.b	#$B,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BossLabyrinth_FlameDel
		bra.s	BossLabyrinth_Display
; ===========================================================================
		tst.w	obVelX(a1)
		beq.s	BossLabyrinth_Display
		move.b	#8,obAnim(a0)
		bra.s	BossLabyrinth_Display
; ===========================================================================

BossLabyrinth_FlameDel:
		jmp		(DeleteObject).l
; ===========================================================================

BossLabyrinth_Display:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		movea.l	objoff_34(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
