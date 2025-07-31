; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ)
; ---------------------------------------------------------------------------

BossGreenHill:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossGreenHill_Index(pc,d0.w),d1
		jmp		BossGreenHill_Index(pc,d1.w)
; ===========================================================================
BossGreenHill_Index:		offsetTable
		offsetTableEntry.w BossGreenHill_Main
		offsetTableEntry.w BossGreenHill_ShipMain
		offsetTableEntry.w BossGreenHill_FaceMain
		offsetTableEntry.w BossGreenHill_FlameMain
		; The wrecking ball is its own object (Obj48)

BossGreenHill_ObjData:
	; Ship
		dc.b 2,	aniID_Ship		; routine counter, animation
	; Face
		dc.b 4,	aniID_NormalFace1
	; Flame
		dc.b 6,	aniID_Blank
; ===========================================================================

BossGreenHill_Main:	; Routine 0
		lea		(BossGreenHill_ObjData).l,a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	BossGreenHill_LoadBoss
; ===========================================================================

BossGreenHill_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	loc_17772

BossGreenHill_LoadBoss:
		move.b	(a2)+,obRoutine(a1)
		_move.b	#id_BossGreenHill,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	(a2)+,obAnim(a1)
		move.l	a0,boss_parent(a1)
		dbf		d1,BossGreenHill_Loop		; repeat sequence 2 more times

loc_17772:
		move.w	obX(a0),boss_bufferX(a0)
		move.w	obY(a0),boss_bufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)			; set number of hits to 8

BossGreenHill_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossGreenHill_ShipIndex(pc,d0.w),d1
		jsr		BossGreenHill_ShipIndex(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		move.b	obStatus(a0),d0
		andi.b	#(maskFlipX+maskFlipY),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================
BossGreenHill_ShipIndex:		offsetTable
		offsetTableEntry.w BossGreenHill_ShipDropDown
		offsetTableEntry.w BossGreenHill_MakeBall
		offsetTableEntry.w BossGreenHill_ShipWait
		offsetTableEntry.w BossGreenHill_ShipMove
		offsetTableEntry.w BossGreenHill_ShipExplode
		offsetTableEntry.w BossGreenHill_ShipDestroyed
		offsetTableEntry.w BossGreenHill_ShipFlee
; ===========================================================================

BossGreenHill_ShipDropDown:	; Secondary Routine 0
		move.w	#$100,obVelY(a0)					; move ship down
		bsr.w	BossMove
		cmpi.w	#boss_ghz_y+$38,boss_bufferY(a0)	; has Eggman finished lowering down?
		bne.s	BossGreenHill_ChkHit				; if not, branch ahead
		clr.w	obVelY(a0)							; stop ship movement
		addq.b	#2,ob2ndRout(a0)					; go to next routine

BossGreenHill_ChkHit:
		move.b	boss_hoverangle(a0),d0
		jsr		(CalcSine).w
		asr.w	#6,d0
		add.w	boss_bufferY(a0),d0
		move.w	d0,obY(a0)
		move.w	boss_bufferX(a0),obX(a0)
		addq.b	#2,boss_hoverangle(a0)
		cmpi.b	#8,ob2ndRout(a0)
		bhs.s	.end								; skip hit check if boss has been defeated
		tst.b	obStatus(a0)
		bmi.s	BossGreenHill_AwardPoints			; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	.end								; skip hit check if boss has no collision at the moment
		tst.b	boss_flashframes(a0)				; should the boss still be flashing?
		bne.w	BossFlash							; if yes, branch and flash
		move.b	#$20,boss_flashframes(a0)			; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(PlaySound_Special).w				; play boss damage sound
		bra.w	BossFlash							; apply flash effect

	.end:
		rts
; ===========================================================================

BossGreenHill_AwardPoints:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#8,ob2ndRout(a0)
		move.w	#$B3,boss_delaytime(a0)
		rts
; ===========================================================================

BossGreenHill_MakeBall:	; Secondary Routine 2
		move.w	#-$100,obVelX(a0)					; move ship to the left
		move.w	#-$40,obVelY(a0)					; move it upward slightly
		bsr.w	BossMove
		cmpi.w	#boss_ghz_x+$A0,boss_bufferX(a0)	; has Eggman reached the center of the field?
		bne.w	BossGreenHill_ChkHit				; if not, branch
		clr.l	obVelX(a0)							; stop ship movement (clear both X and Y velocities)
		addq.b	#2,ob2ndRout(a0)					; go to next routine
		jsr		(FindNextFreeObj).l
		bne.s	loc_17910
		_move.b	#id_BossBall,obID(a1)				; load swinging ball object
		move.w	boss_bufferX(a0),obX(a1)
		move.w	boss_bufferY(a0),obY(a1)
		move.l	a0,boss_parent(a1)

loc_17910:
		move.w	#$77,boss_delaytime(a0)				; set wait timer (Eggman won't move until this timer is up)
		bra.w	BossGreenHill_ChkHit
; ===========================================================================

BossGreenHill_ShipWait:	; Secondary Routine 4
		subq.w	#1,boss_delaytime(a0)
		bpl.s	BossGreenHill_Reverse
		addq.b	#2,ob2ndRout(a0)
		move.w	#$40-1,boss_delaytime(a0)
		move.w	#$100,obVelX(a0)					; move the ship sideways
		cmpi.w	#boss_ghz_x+$A0,boss_bufferX(a0)
		bne.s	BossGreenHill_Reverse
		move.w	#($40*2)-1,boss_delaytime(a0)
		move.w	#$40,obVelX(a0)

BossGreenHill_Reverse:
		btst	#staFlipX,obStatus(a0)
		bne.w	BossGreenHill_ChkHit
		neg.w	obVelX(a0)							; reverse direction of the ship
		bra.w	BossGreenHill_ChkHit
; ===========================================================================

BossGreenHill_ShipMove:	; Secondary Routine 6
		subq.w	#1,boss_delaytime(a0)
		bmi.s	loc_17960
		bsr.w	BossMove
		bra.w	BossGreenHill_ChkHit
; ===========================================================================

loc_17960:
		bchg	#staFlipX,obStatus(a0)
		move.w	#$40-1,boss_delaytime(a0)
		subq.b	#2,ob2ndRout(a0)
		clr.w	obVelX(a0)
		bra.w	BossGreenHill_ChkHit
; ===========================================================================

BossGreenHill_ShipExplode:	; Secondary Routine 8
		subq.w	#1,boss_delaytime(a0)
		bmi.s	loc_17984
		bra.w	BossDefeated		; Make explosion in a random spot on the ship
; ===========================================================================

loc_17984:
		bset	#staFlipX,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$26,boss_delaytime(a0)
		tst.b	(v_bossstatus).w
		bne.s	locret_179AA
		move.b	#1,(v_bossstatus).w

locret_179AA:
		rts	
; ===========================================================================

BossGreenHill_ShipDestroyed:	; Secondary Routine $A
		addq.w	#1,boss_delaytime(a0)
		beq.s	.stopsinking			; if timer has ticked up to 0, branch
		bpl.s	.checkrising			; if timer is greater than zero, branch
		addi.w	#$18,obVelY(a0)			; while timer is negative, the ship should sink down
		bra.s	.applymovement			; branch to movement
; ===========================================================================

	.stopsinking:
		clr.w	obVelY(a0)				; stop sinking
		bra.s	.applymovement
; ===========================================================================

	.checkrising:
		cmpi.w	#$30,boss_delaytime(a0)
		blo.s	.riseslightly			; for just under a second, the ship will rise back up
		beq.s	.resetmusic				; if timer == $30, the ship stops rising and music resets
		cmpi.w	#$38,boss_delaytime(a0)
		blo.s	.applymovement
		addq.b	#2,ob2ndRout(a0)
		bra.s	.applymovement
; ===========================================================================

	.riseslightly:
		subq.w	#8,obVelY(a0)
		bra.s	.applymovement
; ===========================================================================

	.resetmusic:
		clr.w	obVelY(a0)

	if DynamicBGMs
		move.w	#bgm_GHZ3,d0
	else
		move.w	#bgm_GHZ,d0
	endif

		jsr		(PlaySound).w			; play GHZ music
		move.b	d0,(v_lastbgmplayed).w	; store last played music

	.applymovement:
		bsr.w	BossMove
		bra.w	BossGreenHill_ChkHit	; we call this solely for the hover effect
; ===========================================================================

BossGreenHill_ShipFlee:	; Secondary Routine $C
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		cmpi.w	#boss_ghz_end,(v_limitright2).w
		beq.s	loc_17A10
		addq.w	#2,(v_limitright2).w
		bra.s	loc_17A16
; ===========================================================================

loc_17A10:
		tst.b	obRender(a0)
		bpl.s	BossGreenHill_ShipDel

loc_17A16:
		bsr.w	BossMove
		bra.w	BossGreenHill_ChkHit	; we call this solely for the hover effect
; ===========================================================================

BossGreenHill_ShipDel:
		; We do not want to return to BossGreenHill_ShipMain, as objects
		; should not queue themselves for display while also being
		; deleted.
		addq.l	#4,sp					; Clownacy DisplaySprites Fix
		jmp		(DeleteObject).l
; ===========================================================================

BossGreenHill_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#aniID_NormalFace1,d1
		movea.l	boss_parent(a0),a1					; load the parent object (ship) to a1
		move.b	ob2ndRout(a1),d0					; get the ship's current routine
		subq.b	#4,d0								; is ship in an idle phase?
		bne.s	.notIdle							; if not, branch
		cmpi.w	#boss_ghz_x+$A0,boss_bufferX(a1)
		bne.s	.chkHurt
		moveq	#aniID_LaughFace,d1

	.notIdle:
		subq.b	#6,d0
		bmi.s	.chkHurt							; if not in Routine $A, branch
		moveq	#aniID_DefeatFace,d1				; show defeated (burned) face
		bra.s	.setAnim
; ===========================================================================

	.chkHurt:
		tst.b	obColType(a1)
		bne.s	.chkLaughing
		moveq	#aniID_HurtFace,d1
		bra.s	.setAnim
; ===========================================================================

	.chkLaughing:
		cmpi.b	#4,(v_player+obRoutine).w			; is Sonic hurt (or dead)?
		blo.s	.setAnim							; if not, branch
		moveq	#aniID_LaughFace,d1					; use laughing animation

	.setAnim:
		move.b	d1,obAnim(a0)						; set next face animation
		subq.b	#2,d0								; is Eggman fleeing?
		bne.s	BossGreenHill_Display				; if not, branch
		move.b	#aniID_PanicFace,obAnim(a0)			; set panicking face
		tst.b	obRender(a0)
		bpl.s	BossGreenHill_Delete
		bra.s	BossGreenHill_Display				; Face display
; ===========================================================================

BossGreenHill_FlameMain:	; Routine 6
		move.b	#aniID_Blank,obAnim(a0)
		movea.l	boss_parent(a0),a1					; load the parent object (ship) to a1
		cmpi.b	#$C,ob2ndRout(a1)					; has Eggman begun fleeing?
		bne.s	.notfleeing							; if not, branch
		move.b	#aniID_EscapeFlame,obAnim(a0)		; use the escape animation for the flame
		tst.b	obRender(a0)
		bpl.s	BossGreenHill_Delete
		bra.s	BossGreenHill_Display				; Flame Display
; ===========================================================================

	.notfleeing:
		move.w	obVelX(a1),d0
		beq.s	BossGreenHill_Display				; Flame display
		move.b	#aniID_Flame1,obAnim(a0)			; only show the flame if Eggman is moving

BossGreenHill_Display:
		movea.l	boss_parent(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		move.b	obStatus(a0),d0
		andi.b	#(maskFlipX+maskFlipY),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplaySprite).l
; ===========================================================================

BossGreenHill_Delete:
		jmp		(DeleteObject).l
; ===========================================================================