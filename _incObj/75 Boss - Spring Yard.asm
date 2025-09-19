; ---------------------------------------------------------------------------
; Object 75 - Eggman (SYZ)
; ---------------------------------------------------------------------------

BossSpringYard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossSpringYard_Index(pc,d0.w),d1
		jmp		BossSpringYard_Index(pc,d1.w)
; ===========================================================================
BossSpringYard_Index:	offsetTable
		offsetTableEntry.w BossSpringYard_Main
		offsetTableEntry.w BossSpringYard_ShipMain
		offsetTableEntry.w BossSpringYard_FaceMain
		offsetTableEntry.w BossSpringYard_FlameMain
		offsetTableEntry.w BossSpringYard_SpikeMain

BossSpringYard_ObjData:
	; Ship
		dc.b 2,	aniID_Ship		; routine counter, animation
	; Face
		dc.b 4,	aniID_NormalFace1
	; Flame
		dc.b 6,	aniID_Blank
	; Spike
		dc.b 8,	0				; does not animate

syzboss_target = objoff_34		; block column currently targeted by Eggman (1 byte)
syzboss_block = objoff_36		; address of located block (2 bytes)
; ===========================================================================

BossSpringYard_Main:	; Routine 0
		move.w	#boss_syz_x+$1B0,obX(a0)
		move.w	#boss_syz_y+$E,obY(a0)
		move.w	obX(a0),boss_bufferX(a0)
		move.w	obY(a0),boss_bufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0) ; set number of hits to 8
		lea		BossSpringYard_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	BossSpringYard_LoadBoss
; ===========================================================================

BossSpringYard_Loop:
		jsr	(FindNextFreeObj).l
		bne.s	BossSpringYard_ShipMain
		move.b	#id_BossSpringYard,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

BossSpringYard_LoadBoss:
		bclr	#staFlipX,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.w	#priority5,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.l	a0,boss_parent(a1)
		dbf		d1,BossSpringYard_Loop	; repeat sequence 3 more times

	; Set data for Spike
		move.l	#Map_BossItems,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a1)
		move.b	#5,obFrame(a1)

BossSpringYard_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossSpringYard_ShipIndex(pc,d0.w),d1
		jsr		BossSpringYard_ShipIndex(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================
BossSpringYard_ShipIndex:	offsetTable
		offsetTableEntry.w BossSpringYard_ShipStart
		offsetTableEntry.w BossSpringYard_ShipMove
		offsetTableEntry.w BossSpringYard_ShipSpike
		offsetTableEntry.w BossSpringYard_ShipExplode
		offsetTableEntry.w BossSpringYard_ShipDestroyed
		offsetTableEntry.w BossSpringYard_ShipFlee
; ===========================================================================

BossSpringYard_ShipStart:	; Secondary Routine 0
		move.w	#-$100,obVelX(a0)
		cmpi.w	#boss_syz_x+$138,boss_bufferX(a0)
		bhs.s	BossSpringYard_ShipHover
		addq.b	#2,ob2ndRout(a0)

BossSpringYard_ShipHover:
		move.b	boss_hoverangle(a0),d0
		addq.b	#2,boss_hoverangle(a0)
		jsr		(CalcSine).w
		asr.w	#2,d0
		move.w	d0,obVelY(a0)

BossSpringYard_ApplyMovement:
		bsr.w	BossMove
		move.w	boss_bufferY(a0),obY(a0)
		move.w	boss_bufferX(a0),obX(a0)

BossSpringYard_ChkHit:
		move.w	obX(a0),d0
		subi.w	#boss_syz_x,d0
		lsr.w	#5,d0
		move.b	d0,syzboss_target(a0)		; set target column based on current x-position
		cmpi.b	#6,ob2ndRout(a0)
		bhs.s	locret_19256
		tst.b	obStatus(a0)
		bmi.s	BossSpringYard_AwardPoints	; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	locret_19256
		tst.b	boss_flashframes(a0)
		bne.w	BossFlash
		move.b	#$20,boss_flashframes(a0)	; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w		; play boss damage sound
		bra.w	BossFlash

locret_19256:
		rts	
; ===========================================================================

BossSpringYard_AwardPoints:
		moveq	#100,d0
		bsr.w	AddPoints			; award 1000 points
		move.b	#6,ob2ndRout(a0)	; set ship to exploding routine
		move.w	#$B4,boss_delaytime(a0)
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

BossSpringYard_ShipMove:	; Secondary Routine 2
		move.w	boss_bufferX(a0),d0
		move.w	#$140,obVelX(a0)
		btst	#staFlipX,obStatus(a0)
		bne.s	loc_1928E
		neg.w	obVelX(a0)
		cmpi.w	#boss_syz_x+8,d0
		bgt.s	loc_1929E
		bra.s	loc_19294
; ===========================================================================

loc_1928E:
		cmpi.w	#boss_syz_x+$138,d0
		blt.s	loc_1929E

loc_19294:
		bchg	#staFlipX,obStatus(a0)
		clr.b	objoff_3D(a0)

loc_1929E:
		subi.w	#boss_syz_x+$10,d0
		andi.w	#$1F,d0
		subi.w	#$1F,d0
		bpl.s	loc_192AE
		neg.w	d0

loc_192AE:
		subq.w	#1,d0
		bgt.s	loc_192E8
		tst.b	objoff_3D(a0)
		bne.s	loc_192E8
		move.w	(v_player+obX).w,d1
		subi.w	#boss_syz_x,d1
		asr.w	#5,d1
		cmp.b	syzboss_target(a0),d1
		bne.s	loc_192E8
		moveq	#0,d0
		move.b	syzboss_target(a0),d0
		asl.w	#5,d0
		addi.w	#boss_syz_x+$10,d0
		move.w	d0,boss_bufferX(a0)
		bsr.w	BossSpringYard_FindBlocks
		addq.b	#2,ob2ndRout(a0)
		clr.w	obSubtype(a0)
		clr.w	obVelX(a0)

loc_192E8:
		bra.w	BossSpringYard_ShipHover
; ===========================================================================

BossSpringYard_ShipSpike:	; Secondary Routine 4
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.w	BSYZSpike_Index(pc,d0.w),d0
		jmp		BSYZSpike_Index(pc,d0.w)
; ===========================================================================
BSYZSpike_Index:	offsetTable
		offsetTableEntry.w BSYZSpike_Lowering
		offsetTableEntry.w BSYZSpike_CaughtBlock
		offsetTableEntry.w BSYZSpike_LiftingBlock
		offsetTableEntry.w BSYZSpike_BreakingBlock
; ===========================================================================

BSYZSpike_Lowering:		; Tertiary Routine 0
		move.w	#$180,obVelY(a0)
		move.w	boss_bufferY(a0),d0
		cmpi.w	#boss_syz_y+$8A,d0
		blo.w	BossSpringYard_ApplyMovement
		move.w	#boss_syz_y+$8A,boss_bufferY(a0)
		clr.w	boss_delaytime(a0)
		moveq	#-1,d0
		move.w	syzboss_block(a0),d0
		beq.s	loc_1933C					; if Eggman doesn't have a block, branch (and don't set delay timer)
		movea.l	d0,a1						; a1 = address of targeted block
		move.b	#-1,objoff_29(a1)
		move.b	#-1,objoff_29(a0)
		move.l	a0,boss_parent(a1)			; assign main boss object as brick's "parent"
		move.w	#$32,boss_delaytime(a0)		; set delay timer

loc_1933C:
		clr.w	obVelY(a0)
		addq.b	#2,obSubtype(a0)			; advance to next tertiary routine (_CaughtBlock)
		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

BSYZSpike_CaughtBlock:		; Tertiary Routine 2
		subq.w	#1,boss_delaytime(a0)		; is delay timer expired?
		bpl.s	loc_19366					; if not, branch and wait
		addq.b	#2,obSubtype(a0)			; advance to next tertiary routine (_LiftingBlock)
		move.w	#-$800,obVelY(a0)			; rise at a speed of -8
		tst.w	syzboss_block(a0)			; is Eggman carrying a block?
		bne.s	loc_19362					; if yes, branch
		asr		obVelY(a0)					; if not, halve to -4 instead

loc_19362:
		moveq	#0,d0
		bra.s	loc_1937C
; ===========================================================================

loc_19366:
		moveq	#0,d0
		cmpi.w	#$1E,boss_delaytime(a0)
		bgt.s	loc_1937C
		moveq	#2,d0
		btst	#1,objoff_3D(a0)
		beq.s	loc_1937C
		neg.w	d0

loc_1937C:
		add.w	boss_bufferY(a0),d0
		move.w	d0,obY(a0)					; apply juddering effect as Eggman lifts the block
		move.w	boss_bufferX(a0),obX(a0)
		bra.w	BossSpringYard_ChkHit
; ===========================================================================

BSYZSpike_LiftingBlock:		; Tertiary Routine 4
		move.w	#boss_syz_y+$E,d0
		tst.w	syzboss_block(a0)			; is Eggman carrying a block?
		beq.s	loc_1939C					; if not, branch
		subi.w	#$18,d0

loc_1939C:
		cmp.w	boss_bufferY(a0),d0
		blt.s	loc_193BE
		move.w	#8,boss_delaytime(a0)
		tst.w	syzboss_block(a0)			; is Eggman carrying a block?
		beq.s	loc_193B4					; if not, branch
		move.w	#$2D,boss_delaytime(a0)

loc_193B4:
		addq.b	#2,obSubtype(a0)
		clr.w	obVelY(a0)
		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

loc_193BE:
		cmpi.w	#-$40,obVelY(a0)
		bge.w	BossSpringYard_ApplyMovement
		addi.w	#$C,obVelY(a0)
		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

BSYZSpike_BreakingBlock:		; Tertiary Routine 6
		subq.w	#1,boss_delaytime(a0)
		bgt.s	loc_19406
		bmi.s	loc_193EE
		moveq	#-1,d0
		move.w	syzboss_block(a0),d0
		beq.s	loc_193E8					; if Eggman doesn't have a block, branch 
		movea.l	d0,a1
		move.b	#$A,objoff_29(a1)

loc_193E8:
		clr.w	syzboss_block(a0)			; clear block address
		bra.s	loc_19406
; ===========================================================================

loc_193EE:
		cmpi.w	#-$1E,boss_delaytime(a0)
		bne.s	loc_19406
		clr.b	objoff_29(a0)
		subq.b	#2,ob2ndRout(a0)
		move.b	#-1,objoff_3D(a0)
		bra.w	BossSpringYard_ChkHit
; ===========================================================================

loc_19406:
		moveq	#1,d0
		tst.w	syzboss_block(a0)			; is Eggman carrying a block?
		beq.s	loc_19410					; if not, branch
		moveq	#2,d0

loc_19410:
		cmpi.w	#boss_syz_y+$E,boss_bufferY(a0)
		beq.s	loc_19424
		blt.s	loc_1941C
		neg.w	d0

loc_1941C:
		tst.w	syzboss_block(a0)			; why is this test here???
		add.w	d0,boss_bufferY(a0)

loc_19424:
		moveq	#0,d0
		tst.w	syzboss_block(a0)			; is Eggman carrying a block?
		beq.s	loc_19438					; if not, branch
		moveq	#2,d0
		btst	#0,objoff_3D(a0)
		beq.s	loc_19438
		neg.w	d0

loc_19438:
		add.w	boss_bufferY(a0),d0
		move.w	d0,obY(a0)
		move.w	boss_bufferX(a0),obX(a0)
		bra.w	BossSpringYard_ChkHit
; ===========================================================================


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossSpringYard_FindBlocks:
		clr.w	syzboss_block(a0)		; clear stored block address
		lea		(v_lvlobjspace).w,a1	; Fixed from (v_objspace+object_size*1)
		moveq	#v_lvlobjcount,d0		; Fixed. Originally only covered the first half of object RAM.
		moveq	#id_BossBlock,d1
		move.b	boss_parent(a0),d2

	.loop:
		cmp.b	obID(a1),d1				; is object a SYZ boss block?
		bne.s	.nextObj				; if not, branch
		cmp.b	obSubtype(a1),d2
		bne.s	.nextObj
		move.w	a1,syzboss_block(a0)
		bra.s	.endloop
; ===========================================================================

	.nextObj:
		lea		object_size(a1),a1		; next object RAM entry
		dbf		d0,.loop

	.endloop:
		rts	
; End of function BossSpringYard_FindBlocks
; ===========================================================================

BossSpringYard_ShipExplode:		; Secondary Routine 6
		subq.w	#1,boss_delaytime(a0)
		bmi.s	loc_1947E
		bra.w	BossDefeated		; Make explosion in a random spot on the ship
; ===========================================================================

loc_1947E:
		addq.b	#2,ob2ndRout(a0)
		clr.w	obVelY(a0)
		bset	#staFlipX,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		move.w	#-1,boss_delaytime(a0)
		tst.b	(v_bossstatus).w
		bne.w	BossSpringYard_ChkHit
		move.b	#1,(v_bossstatus).w
		bra.w	BossSpringYard_ChkHit
; ===========================================================================

BossSpringYard_ShipDestroyed:		; Secondary Routine 8
		addq.w	#1,boss_delaytime(a0)
		beq.s	loc_194BC
		bpl.s	loc_194C2
		addi.w	#$18,obVelY(a0)
		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

loc_194BC:
		clr.w	obVelY(a0)
		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

loc_194C2:
		cmpi.w	#$20,boss_delaytime(a0)
		blo.s	loc_194DA
		beq.s	loc_194E0
		cmpi.w	#$2A,boss_delaytime(a0)
		blo.w	BossSpringYard_ApplyMovement
		addq.b	#2,ob2ndRout(a0)
		move.l	#$0400FFC0,obVelX(a0)	; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly

	if PostBossScreenUnlock
		move.w	#boss_syz_end,(v_limitright2).w
	endif

		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

loc_194DA:
		subq.w	#8,obVelY(a0)
		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

loc_194E0:
		clr.w	obVelY(a0)

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_SYZ3,d0
		else
			move.w	#bgm_SYZ,d0
		endif

			jsr		(QueueSound1).w			; play SYZ music
			move.b	d0,(v_lastbgmplayed).w	; store last played music
	endif

		bra.w	BossSpringYard_ApplyMovement
; ===========================================================================

BossSpringYard_ShipFlee:		; Secondary Routine $A
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_syz_end,(v_limitright2).w
		bhs.s	loc_1950C
		addq.w	#2,(v_limitright2).w
		bra.s	loc_19512
; ===========================================================================
	endif

loc_1950C:
		tst.b	obRender(a0)
		bpl.s	BossSpringYard_ShipDelete

loc_19512:
		bsr.w	BossMove
		bra.w	BossSpringYard_ShipHover
; ===========================================================================

BossSpringYard_ShipDelete:
		; Avoid returning to BossSpringYard_ShipMain to prevent a
		; display-and-delete bug.
		addq.l	#4,sp			; Clownacy DisplaySprite Fix
		jmp		(DeleteObject).l
; ===========================================================================

BossSpringYard_FaceMain:	; Routine 4
		movea.l	boss_parent(a0),a1

	; Devon Boss Object Fix
		cmpi.b	#id_BossSpringYard,obID(a1)			; is the boss still loaded?
		bne.w	BossSpringYard_Delete				; if not, delete object
	; Boss Object Fix End

		moveq	#0,d0
		moveq	#aniID_NormalFace1,d1
		move.b	ob2ndRout(a1),d0
		move.w	BossSpringYard_FaceRoutines(pc,d0.w),d0
		jsr		BossSpringYard_FaceRoutines(pc,d0.w)
		move.b	d1,obAnim(a0)
		move.b	(a0),d0
		cmp.b	(a1),d0
		bne.s	BossSpringYard_Delete
		bra.s	BossSpringYard_Display
; ===========================================================================

BossSpringYard_FaceRoutines:	offsetTable
		offsetTableEntry.w loc_19574
		offsetTableEntry.w loc_19574
		offsetTableEntry.w loc_1955A
		offsetTableEntry.w loc_19552
		offsetTableEntry.w loc_19552
		offsetTableEntry.w loc_19556
; ===========================================================================

loc_19552:
		moveq	#aniID_DefeatFace,d1
		rts	
; ===========================================================================

loc_19556:
		moveq	#aniID_PanicFace,d1
		rts	
; ===========================================================================

loc_1955A:
		cmpi.b	#2,obSubtype(a1)
		beq.s	loc_19574
		moveq	#aniID_PanicFace,d1

loc_19574:
		tst.b	obColType(a1)
		bne.s	loc_1957E
		moveq	#aniID_HurtFace,d1
		rts	
; ===========================================================================

loc_1957E:
		cmpi.b	#4,(v_player+obRoutine).w
		blo.s	locret_19588
		moveq	#aniID_LaughFace,d1

locret_19588:
		rts	
; ===========================================================================

BossSpringYard_FlameMain:; Routine 6
		movea.l	boss_parent(a0),a1

	; Devon Boss Object Fix
		cmpi.b	#id_BossSpringYard,obID(a1)			; is the boss still loaded?
		bne.w	BossSpringYard_Delete				; if not, delete object
	; Boss Object Fix End

		move.b	#aniID_Blank,obAnim(a0)
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_195AA
		move.b	#aniID_EscapeFlame,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	BossSpringYard_Delete
		bra.s	BossSpringYard_Display
; ===========================================================================

BossSpringYard_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

loc_195AA:
		tst.w	obVelX(a1)
		beq.s	BossSpringYard_Display
		move.b	#aniID_Flame1,obAnim(a0)

BossSpringYard_Display:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		movea.l	boss_parent(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)

loc_195DA:
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================

BossSpringYard_SpikeMain:	; Routine 8
		movea.l	boss_parent(a0),a1

	; Devon Boss Object Fix
		cmpi.b	#id_BossSpringYard,obID(a1)			; is the boss still loaded?
		bne.w	BossSpringYard_Delete				; if not, delete object
	; Boss Object Fix End

		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_1961C
		tst.b	obRender(a0)
		bpl.s	BossSpringYard_Delete

loc_1961C:
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.w	boss_delaytime(a0),d0
		cmpi.b	#4,ob2ndRout(a1)
		bne.s	loc_19652
		cmpi.b	#6,obSubtype(a1)
		beq.s	loc_1964C
		tst.b	obSubtype(a1)
		bne.s	loc_19658
		cmpi.w	#$94,d0
		bge.s	loc_19658
		addq.w	#7,d0
		bra.s	loc_19658
; ===========================================================================

loc_1964C:
		tst.w	boss_delaytime(a1)
		bpl.s	loc_19658

loc_19652:
		tst.w	d0
		ble.s	loc_19658
		subq.w	#5,d0

loc_19658:
		move.w	d0,boss_delaytime(a0)
		asr.w	#2,d0
		add.w	d0,obY(a0)
		move.b	#8,obActWid(a0)
		move.b	#$C,obHeight(a0)
		clr.b	obColType(a0)
		movea.l	boss_parent(a0),a1
		tst.b	obColType(a1)
		beq.w	loc_195DA
		tst.b	objoff_29(a1)
		bne.w	loc_195DA
		move.b	#(colHarmful|colSz_4x16),obColType(a0)
		bra.w	loc_195DA
; ===========================================================================