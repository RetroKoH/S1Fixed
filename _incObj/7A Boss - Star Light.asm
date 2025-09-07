; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------

BossStarLight:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossStarLight_Index(pc,d0.w),d1
		jmp	BossStarLight_Index(pc,d1.w)
; ===========================================================================
BossStarLight_Index:	offsetTable
		offsetTableEntry.w BossStarLight_Main
		offsetTableEntry.w BossStarLight_ShipMain
		offsetTableEntry.w BossStarLight_FaceMain
		offsetTableEntry.w BossStarLight_FlameMain
		offsetTableEntry.w BossStarLight_TubeMain

BossStarLight_ObjData:
	; Ship
		dc.b 2,	aniID_Ship		; routine number, animation
		dc.w priority4			; priority
	; Face
		dc.b 4,	aniID_NormalFace1
		dc.w priority4
	; Flame
		dc.b 6,	aniID_Blank
		dc.w priority4
	; Tube
		dc.b 8,	0				; does not animate
		dc.w priority3
; ===========================================================================

BossStarLight_Main:
		move.w	#boss_slz_x+$188,obX(a0)
		move.w	#boss_slz_y+$18,obY(a0)
		move.w	obX(a0),boss_bufferX(a0)
		move.w	obY(a0),boss_bufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)	; set number of hits to 8
		lea		BossStarLight_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	BossStarLight_LoadBoss
; ===========================================================================

BossStarLight_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	loc_1895C
		_move.b	#id_BossStarLight,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

BossStarLight_LoadBoss:
		bclr	#staFlipX,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.w	(a2)+,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.l	a0,boss_parent(a1)
		dbf		d1,BossStarLight_Loop	; repeat sequence 3 more times

loc_1895C:
		lea		(v_lvlobjspace).w,a1	; FixBugs -- Formerly (v_objspace+object_size*1)
		lea		objoff_2A(a0),a2
		moveq	#id_Seesaw,d0
		moveq	#v_lvlobjcount,d1		; FixBugs: Normally only covered the first half of object RAM.

loc_18968:
		cmp.b	obID(a1),d0
		bne.s	loc_18974
		tst.b	obSubtype(a1)
		beq.s	loc_18974
		move.w	a1,(a2)+

loc_18974:
		adda.w	#object_size,a1
		dbf		d1,loc_18968

BossStarLight_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossStarLight_ShipIndex(pc,d0.w),d0
		jsr		BossStarLight_ShipIndex(pc,d0.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================
BossStarLight_ShipIndex:	offsetTable
		offsetTableEntry.w BossStarLight_ShipStart
		offsetTableEntry.w BossStarLight_ShipMove
		offsetTableEntry.w BossStarLight_ShipMakeBall
		offsetTableEntry.w BossStarLight_ShipExplode
		offsetTableEntry.w BossStarLight_ShipDestroyed
		offsetTableEntry.w BossStarLight_ShipFlee
; ===========================================================================

BossStarLight_ShipStart:		; Secondary Routine 0
		move.w	#-$100,obVelX(a0)
		cmpi.w	#boss_slz_x+$120,boss_bufferX(a0)
		bhs.s	loc_189CA
		addq.b	#2,ob2ndRout(a0)

loc_189CA:
		bsr.w	BossMove
		move.b	boss_hoverangle(a0),d0
		addq.b	#2,boss_hoverangle(a0)
		jsr		(CalcSine).w
		asr.w	#6,d0
		add.w	boss_bufferY(a0),d0
		move.w	d0,obY(a0)
		move.w	boss_bufferX(a0),obX(a0)
		bra.s	BossStarLight_ChkHit
; ===========================================================================

BossStarLight_ApplyMovement:
		bsr.w	BossMove
		move.w	boss_bufferY(a0),obY(a0)
		move.w	boss_bufferX(a0),obX(a0)

BossStarLight_ChkHit:
		cmpi.b	#6,ob2ndRout(a0)
		bhs.s	locret_18A44
		tst.b	obStatus(a0)
		bmi.s	BossStarLight_AwardPoints	; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	locret_18A44
		tst.b	boss_flashframes(a0)
		bne.w	BossFlash
		move.b	#$20,boss_flashframes(a0)	; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w		; play boss damage sound
		bra.w	BossFlash

locret_18A44:
		rts	
; ===========================================================================

BossStarLight_AwardPoints:
		moveq	#100,d0
		bsr.w	AddPoints			; award 1000 points
		move.b	#6,ob2ndRout(a0)	; set ship to exploding routine
		move.b	#$78,boss_delaytime(a0)
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

BossStarLight_ShipMove:		; Secondary Routine 2
		move.w	boss_bufferX(a0),d0
		move.w	#$200,obVelX(a0)
		btst	#staFlipX,obStatus(a0)
		bne.s	loc_18A7C
		neg.w	obVelX(a0)
		cmpi.w	#boss_slz_x+8,d0
		bgt.s	loc_18A88
		bra.s	loc_18A82
; ===========================================================================

loc_18A7C:
		cmpi.w	#boss_slz_x+$138,d0
		blt.s	loc_18A88

loc_18A82:
		bchg	#staFlipX,obStatus(a0)

loc_18A88:
		move.w	obX(a0),d0
		moveq	#-1,d1
		moveq	#2,d2
		lea		objoff_2A(a0),a2
		moveq	#$28,d4
		tst.w	obVelX(a0)
		bpl.s	loc_18A9E
		neg.w	d4

loc_18A9E:
		move.w	(a2)+,d1
		movea.l	d1,a3
		btst	#staSonicOnObj,obStatus(a3)
		bne.s	loc_18AB4
		move.w	obX(a3),d3
		add.w	d4,d3
		sub.w	d0,d3
		beq.s	loc_18AC0

loc_18AB4:
		dbf		d2,loc_18A9E

		move.b	d2,obSubtype(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18AC0:
		move.b	d2,obSubtype(a0)
		addq.b	#2,ob2ndRout(a0)
		move.b	#$28,boss_delaytime(a0)
		bra.w	loc_189CA
; ===========================================================================

BossStarLight_ShipMakeBall:		; Secondary Routine 4
		cmpi.b	#$28,boss_delaytime(a0)
		bne.s	loc_18B36
		moveq	#-1,d0
		move.b	obSubtype(a0),d0
		ext.w	d0
		bmi.s	loc_18B40
		subq.w	#2,d0
		neg.w	d0
		add.w	d0,d0
		lea		objoff_2A(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2
		lea		(v_lvlobjspace).w,a1	; FixBugs -- Formerly (v_objspace+object_size*1)
		moveq	#v_lvlobjcount,d1		; FixBugs: Normally only covered the first half of object RAM.

loc_18AFA:
		cmp.l	boss_delaytime(a1),d0
		beq.s	loc_18B40
		adda.w	#object_size,a1
		dbf		d1,loc_18AFA

		move.l	a0,-(sp)
		lea		(a2),a0
		jsr		(FindNextFreeObj).l
		movea.l	(sp)+,a0
		bne.s	loc_18B40
		move.b	#id_BossSpikeball,obID(a1) ; load spiked ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$20,obY(a1)
		move.b	obStatus(a2),obStatus(a1)
		move.l	a2,boss_delaytime(a1)

loc_18B36:
		subq.b	#1,boss_delaytime(a0)
		beq.s	loc_18B40
		bra.w	BossStarLight_ChkHit
; ===========================================================================

loc_18B40:
		subq.b	#2,ob2ndRout(a0)
		bra.w	loc_189CA
; ===========================================================================

BossStarLight_ShipExplode:		; Secondary Routine 6
		subq.b	#1,boss_delaytime(a0)
		bmi.s	loc_18B52
		bra.w	BossDefeated		; Make explosion in a random spot on the ship
; ===========================================================================

loc_18B52:
		addq.b	#2,ob2ndRout(a0)
		clr.w	obVelY(a0)
		bset	#staFlipX,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		move.b	#-$18,boss_delaytime(a0)
		tst.b	(v_bossstatus).w
		bne.s	loc_18B7C
		move.b	#1,(v_bossstatus).w

loc_18B7C:
		bra.w	BossStarLight_ChkHit
; ===========================================================================

BossStarLight_ShipDestroyed:		; Secondary Routine 8
		addq.b	#1,boss_delaytime(a0)
		beq.s	loc_18B90					; if timer has ticked up to 0, branch
		bpl.s	loc_18B96					; if timer is greater than zero, branch
		addi.w	#$18,obVelY(a0)				; while timer is negative, the ship should sink down
		bra.w	BossStarLight_ApplyMovement
; ===========================================================================

loc_18B90:
		clr.w	obVelY(a0)					; stop sinking
		bra.w	BossStarLight_ApplyMovement
; ===========================================================================

loc_18B96:
		cmpi.b	#$20,boss_delaytime(a0)
		blo.s	loc_18BAE					; for about half a second, the ship will rise back up
		beq.s	loc_18BB4					; if timer == $30, the ship stops rising and music resets
		cmpi.b	#$2A,boss_delaytime(a0)
		blo.w	BossStarLight_ApplyMovement
		addq.b	#2,ob2ndRout(a0)
		bra.w	BossStarLight_ApplyMovement
; ===========================================================================

loc_18BAE:
		subq.w	#8,obVelY(a0)
		bra.w	BossStarLight_ApplyMovement
; ===========================================================================

loc_18BB4:
		clr.w	obVelY(a0)

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_SLZ3,d0
		else
			move.w	#bgm_SLZ,d0
		endif

			jsr		(QueueSound1).w				; play SLZ music
			move.b	d0,(v_lastbgmplayed).w		; store last played music
	endif

		bra.w	BossStarLight_ApplyMovement
; ===========================================================================

BossStarLight_ShipFlee:		; Secondary Routine $A
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		cmpi.w	#boss_slz_end,(v_limitright2).w
		bhs.s	loc_18BE0
		addq.w	#2,(v_limitright2).w
		bra.s	loc_18BE8
; ===========================================================================

loc_18BE0:
		tst.b	obRender(a0)
		bpl.s	BossStarLight_PopAndDelete	; Clownacy DisplaySprite Fix

loc_18BE8:
		bsr.w	BossMove
		bra.w	loc_189CA

BossStarLight_PopAndDelete:
		; Avoid returning to BossStarLight_ShipMain to prevent a
		; display-and-delete bug.
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

BossStarLight_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#aniID_NormalFace1,d1
		movea.l	boss_parent(a0),a1
		move.b	ob2ndRout(a1),d0
		cmpi.b	#6,d0
		bmi.s	loc_18C06
		moveq	#aniID_DefeatFace,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C06:
		tst.b	obColType(a1)
		bne.s	loc_18C10
		moveq	#aniID_HurtFace,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C10:
		cmpi.b	#4,(v_player+obRoutine).w
		blo.s	loc_18C1A
		moveq	#aniID_LaughFace,d1

loc_18C1A:
		move.b	d1,obAnim(a0)
		cmpi.b	#$A,d0
		bne.s	BossStarLight_Animate
		move.b	#aniID_PanicFace,obAnim(a0)
		tst.b	obRender(a0)
		bpl.w	BossStarLight_Delete
		bra.s	BossStarLight_Animate
; ===========================================================================

BossStarLight_FlameMain:; Routine 6
		move.b	#aniID_Flame1,obAnim(a0)
		movea.l	boss_parent(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18C56
		tst.b	obRender(a0)
		bpl.s	BossStarLight_Delete
		move.b	#aniID_EscapeFlame,obAnim(a0)
		bra.s	BossStarLight_Animate
; ===========================================================================

loc_18C56:
		cmpi.b	#8,ob2ndRout(a1)
		bgt.s	BossStarLight_Animate
		cmpi.b	#4,ob2ndRout(a1)
		blt.s	BossStarLight_Animate
		move.b	#aniID_Blank,obAnim(a0)

BossStarLight_Animate:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w

BossStarLight_Display:
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

BossStarLight_TubeMain:	; Routine 8
		movea.l	boss_parent(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18CB8
		tst.b	obRender(a0)
		bpl.s	BossStarLight_Delete

loc_18CB8:
		move.l	#Map_BossItems,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a0)
		move.b	#3,obFrame(a0)
		bra.s	BossStarLight_Display
; ===========================================================================

BossStarLight_Delete:
		jmp		(DeleteObject).l
; ===========================================================================