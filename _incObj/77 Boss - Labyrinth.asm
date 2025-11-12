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
	; Ship
		dc.b 2,	aniID_Ship		; routine counter, animation
	; Face
		dc.b 4,	aniID_NormalFace1
	; Flame
		dc.b 6,	aniID_Blank
; ===========================================================================

BossLabyrinth_Main:	; Routine 0
		move.w	#boss_lz_x+$30,obX(a0)
		move.w	#boss_lz_y+$500,obY(a0)
		move.w	obX(a0),boss_bufferX(a0)
		move.w	obY(a0),boss_bufferY(a0)
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
		move.b	#$20,obDispWid(a1)
		move.l	a0,boss_parent(a1)
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
		offsetTableEntry.w BossLabyrinth_ShipStart
		offsetTableEntry.w BossLabyrinth_ShipMove
		offsetTableEntry.w BossLabyrinth_ShipMove2
		offsetTableEntry.w BossLabyrinth_ShipMove3
		offsetTableEntry.w BossLabyrinth_ShipApproachEnd
		offsetTableEntry.w BossLabyrinth_ShipWaitAtEnd
		offsetTableEntry.w BossLabyrinth_ShipTurnToFlee
		offsetTableEntry.w BossLabyrinth_ShipFlee
; ===========================================================================

BossLabyrinth_ShipStart:
		move.w	obX(a1),d0
		cmpi.w	#boss_lz_x-$40,d0
		blo.s	loc_17F38
		move.w	#-$180,obVelY(a0)
		move.w	#$60,obVelX(a0)
		addq.b	#2,ob2ndRout(a0)

loc_17F38:
		bsr.w	BossMove
		move.w	boss_bufferY(a0),obY(a0)
		move.w	boss_bufferX(a0),obX(a0)

loc_17F48:
		tst.b	objoff_3D(a0)
		bne.w	BossDefeated				; Make explosion in a random spot on the ship
		tst.b	obStatus(a0)
		bmi.s	BossLabyrinth_AwardPoints	; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	locret_17F8C
		tst.b	boss_flashframes(a0)
		bne.w	BossFlash
		move.b	#$20,boss_flashframes(a0)	; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w		; play boss damage sound
		bra.w	BossFlash

locret_17F8C:
		rts	
; ===========================================================================

BossLabyrinth_AwardPoints:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#-1,objoff_3D(a0)
		rts	
; ===========================================================================

BossLabyrinth_ShipMove:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$68,boss_bufferX(a0)
		blo.s	loc_17FB6
		move.w	#boss_lz_x+$68,boss_bufferX(a0)
		clr.w	obVelX(a0)
		addq.w	#1,d0

loc_17FB6:
		cmpi.w	#boss_lz_y+$440,boss_bufferY(a0)
		bgt.s	loc_17FCA
		move.w	#boss_lz_y+$440,boss_bufferY(a0)
		clr.w	obVelY(a0)
		addq.w	#1,d0

loc_17FCA:
		bne.w	loc_17F38
		move.w	#$140,obVelX(a0)
		move.w	#-$200,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_17F38
; ===========================================================================

BossLabyrinth_ShipMove2:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$90,boss_bufferX(a0)
		blo.s	loc_17FF6
		move.w	#boss_lz_x+$90,boss_bufferX(a0)
		clr.w	obVelX(a0)
		addq.w	#1,d0

loc_17FF6:
		cmpi.w	#boss_lz_y+$400,boss_bufferY(a0)
		bgt.s	loc_1800A
		move.w	#boss_lz_y+$400,boss_bufferY(a0)
		clr.w	obVelY(a0)
		addq.w	#1,d0

loc_1800A:
		bne.w	loc_17F38
		move.w	#-$180,obVelY(a0)
		addq.b	#2,ob2ndRout(a0)
		clr.b	boss_hoverangle(a0)
		bra.w	loc_17F38
; ===========================================================================

BossLabyrinth_ShipMove3:
		cmpi.w	#boss_lz_y+$40,boss_bufferY(a0)
		bgt.s	loc_1804E
		move.w	#boss_lz_y+$40,boss_bufferY(a0)
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
		addq.b	#2,boss_hoverangle(a0)
		move.b	boss_hoverangle(a0),d0
		jsr		(CalcSine).w
		tst.w	d1
		bpl.s	loc_1806C
		bclr	#staFlipX,obStatus(a0)

loc_1806C:
		asr.w	#4,d0
		swap	d0
		clr.w	d0
		add.l	boss_bufferX(a0),d0
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
		add.l	d0,boss_bufferY(a0)
		move.w	boss_bufferY(a0),obY(a0)
		bra.w	loc_17F48
; ===========================================================================

BossLabyrinth_ShipApproachEnd:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$16C,boss_bufferX(a0)
		blo.s	loc_180D2
		move.w	#boss_lz_x+$16C,boss_bufferX(a0)
		clr.w	obVelX(a0)
		addq.w	#1,d0

loc_180D2:
		cmpi.w	#boss_lz_y,boss_bufferY(a0)
		bgt.s	loc_180E6
		move.w	#boss_lz_y,boss_bufferY(a0)
		clr.w	obVelY(a0)
		addq.w	#1,d0

loc_180E6:
		bne.w	loc_17F38
		addq.b	#2,ob2ndRout(a0)
		bclr	#staFlipX,obStatus(a0)
		bra.w	loc_17F38
; ===========================================================================

BossLabyrinth_ShipWaitAtEnd:
		tst.b	objoff_3D(a0)
		bne.s	loc_18112
		cmpi.w	#boss_lz_x+$E8,obX(a1)
		blt.w	loc_17F38
		cmpi.w	#boss_lz_y+$30,obY(a1)
		bgt.w	loc_17F38
		move.b	#$32,boss_delaytime(a0)

loc_18112:

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_LZ3,d0
		else
			move.w	#bgm_LZ,d0
		endif

			jsr		(QueueSound1).w			; play LZ music
			move.b	d0,(v_lastbgmplayed).w	; store last played music
	endif

		clr.b	(f_lockscreen).w
		bset	#staFlipX,obStatus(a0)
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_17F38
; ===========================================================================

BossLabyrinth_ShipTurnToFlee:
		tst.b	objoff_3D(a0)
		bne.s	loc_18136
		subq.b	#1,boss_delaytime(a0)
		bne.w	loc_17F38

loc_18136:
		clr.b	boss_delaytime(a0)
		move.l	#$0400FFC0,obVelX(a0)	; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly
		clr.b	objoff_3D(a0)
		addq.b	#2,ob2ndRout(a0)

	if PostBossScreenUnlock
		move.w	#boss_lz_end,(v_limitright).w
	endif

		bra.w	loc_17F38
; ===========================================================================

BossLabyrinth_ShipFlee:
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_lz_end,(v_limitright).w
		bhs.s	loc_18160
		addq.w	#2,(v_limitright).w
		bra.w	loc_17F38
; ===========================================================================

loc_18160:
	endif

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
		movea.l	boss_parent(a0),a1

	; Devon Boss Object Fix
		cmpi.b	#id_BossLabyrinth,obID(a1)			; is the boss still loaded?
		bne.s	BossLabyrinth_Delete				; if not, delete object
	; Boss Object Fix End

		moveq	#0,d0
		move.b	ob2ndRout(a1),d0
		moveq	#aniID_NormalFace1,d1
		tst.b	objoff_3D(a0)
		beq.s	loc_1818C
		moveq	#aniID_DefeatFace,d1
		bra.s	loc_181A0
; ===========================================================================

loc_1818C:
		tst.b	obColType(a1)
		bne.s	loc_18196
		moveq	#aniID_HurtFace,d1
		bra.s	loc_181A0
; ===========================================================================

loc_18196:
		cmpi.b	#4,(v_player+obRoutine).w
		blo.s	loc_181A0
		moveq	#aniID_LaughFace,d1

loc_181A0:
		move.b	d1,obAnim(a0)
		cmpi.b	#$E,d0
		bne.s	BossLabyrinth_Display
		move.b	#aniID_PanicFace,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BossLabyrinth_Delete
		bra.s	BossLabyrinth_Display
; ===========================================================================

BossLabyrinth_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

BossLabyrinth_FlameMain:; Routine 6
		movea.l	boss_parent(a0),a1

	; Devon Boss Object Fix
		cmpi.b	#id_BossLabyrinth,obID(a1)			; is the boss still loaded?
		bne.s	BossLabyrinth_Delete				; if not, delete object
	; Boss Object Fix End

		move.b	#aniID_Blank,obAnim(a0)
		cmpi.b	#$E,ob2ndRout(a1)
		bne.s	BossLabyrinth_Display
		move.b	#aniID_EscapeFlame,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BossLabyrinth_Delete

BossLabyrinth_Display:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		movea.l	boss_parent(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================