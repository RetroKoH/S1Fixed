; ---------------------------------------------------------------------------
; Object 73 - Eggman (MZ)
; ---------------------------------------------------------------------------

BossMarble:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossMarble_Index(pc,d0.w),d1
		jmp		BossMarble_Index(pc,d1.w)
; ===========================================================================
BossMarble_Index:	offsetTable
		offsetTableEntry.w BossMarble_Main
		offsetTableEntry.w BossMarble_ShipMain
		offsetTableEntry.w BossMarble_FaceMain
		offsetTableEntry.w BossMarble_FlameMain
		offsetTableEntry.w BossMarble_TubeMain

BossMarble_ObjData:
	; Ship
		dc.b 2,	aniID_Ship			; routine number, animation
		dc.w priority4				; priority
	; Face
		dc.b 4,	aniID_NormalFace1
		dc.w priority4
	; Flame
		dc.b 6,	aniID_Blank
		dc.w priority4
	; Tube -- Does not animate
		dc.b 8,	0
		dc.w priority3

mzboss_lavatimer = objoff_34		; delay timer for random lava ball spawning (1 byte)
; ===========================================================================

BossMarble_Main:			; Routine 0
		move.w	obX(a0),boss_bufferX(a0)
		move.w	obY(a0),boss_bufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0) 		; set number of hits to 8
		lea		BossMarble_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	BossMarble_LoadBoss
; ===========================================================================

BossMarble_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	BossMarble_ShipMain
		_move.b	#id_BossMarble,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

BossMarble_LoadBoss:
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
		dbf		d1,BossMarble_Loop		; repeat sequence 3 more times

BossMarble_ShipMain:		; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossMarble_ShipIndex(pc,d0.w),d1
		jsr		BossMarble_ShipIndex(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================
BossMarble_ShipIndex:	offsetTable
		offsetTableEntry.w BossMarble_ShipStart
		offsetTableEntry.w BossMarble_ShipMove
		offsetTableEntry.w BossMarble_ShipExplode
		offsetTableEntry.w BossMarble_ShipDestroyed
		offsetTableEntry.w BossMarble_ShipFlee
; ===========================================================================

BossMarble_ShipStart:		; Secondary Routine 0
		move.b	boss_hoverangle(a0),d0
		addq.b	#2,boss_hoverangle(a0)
		jsr		(CalcSine).w
		asr.w	#2,d0
		move.w	d0,obVelY(a0)
		move.w	#-$100,obVelX(a0)
		bsr.w	BossMove
		cmpi.w	#boss_mz_x+$110,boss_bufferX(a0)
		bne.s	loc_18334
		addq.b	#2,ob2ndRout(a0)
		clr.b	obSubtype(a0)
		clr.l	obVelX(a0)

loc_18334:
		jsr		(RandomNumber).w
		move.b	d0,mzboss_lavatimer(a0)				; init timer to a random value between 00-FF

BossMarble_ChkHit:
		move.w	boss_bufferY(a0),obY(a0)
		move.w	boss_bufferX(a0),obX(a0)
		cmpi.b	#4,ob2ndRout(a0)
		bhs.s	.end								; skip hit check if boss has been defeated
		tst.b	obStatus(a0)
		bmi.s	BossMarble_AwardPoints				; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	.end								; skip hit check if boss has no collision at the moment
		tst.b	boss_flashframes(a0)				; should the boss still be flashing?
		bne.w	BossFlash							; if yes, branch and flash
		move.b	#$28,boss_flashframes(a0)			; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w				; play boss damage sound
		bra.w	BossFlash							; apply flash effect

	.end:
		rts	
; ===========================================================================

BossMarble_AwardPoints:
		moveq	#100,d0
		bsr.w	AddPoints							; award 1000 points
		move.b	#4,ob2ndRout(a0)					; set ship to exploding routine
		move.w	#$B4,boss_delaytime(a0)
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

BossMarble_ShipMove:		; Secondary Routine 2
		moveq	#0,d0
		move.b	ob3rdRout(a0),d0
		move.w	BMZShip_MoveIndex(pc,d0.w),d0
		jsr		BMZShip_MoveIndex(pc,d0.w)
		andi.b	#6,ob3rdRout(a0)					; clamp tertiary routine value to a range of 0-6
		bra.w	BossMarble_ChkHit
; ===========================================================================

BMZShip_MoveIndex:	offsetTable
		offsetTableEntry.w BossMarble_MoveAcross	; Move from right to left
		offsetTableEntry.w BossMarble_DropFire		; Drop fire onto the left side
		offsetTableEntry.w BossMarble_MoveAcross	; Move from left to right
		offsetTableEntry.w BossMarble_DropFire		; Drop fire onto the right side
; ===========================================================================

BossMarble_MoveAcross:		; Tertiary Routine 0/4
		tst.w	obVelX(a0)							; is Eggman currently moving horizontally?
		bne.s	.ismoving							; if yes, branch

; This code triggers if:
	; Eggman starts moving to the opposite side, OR
	; Eggman has reached the opposite side of the field
		moveq	#$40,d0
		cmpi.w	#boss_mz_y+$1C,boss_bufferY(a0)		; Is Eggman in position to drop fire?
		beq.s	.takeoff							; if yes, branch. He will take off to the other side.
		bcs.s	.applymovement
		neg.w	d0

	.applymovement:
		move.w	d0,obVelY(a0)
		bra.w	BossMove
; ===========================================================================

	.takeoff:
		move.w	#$200,obVelX(a0)					; set X-speed to 2 (to the right)
		move.w	#$100,obVelY(a0)					; set Y-speed to 1
		btst	#staFlipX,obStatus(a0)				; is Eggman facing left?
		bne.s	.ismoving							; if not, branch
		neg.w	obVelX(a0)							; set X-speed to -2 (to the left)

	.ismoving:
		cmpi.b	#24,boss_flashframes(a0)			; does Eggman have 24 (or more) flash frames left?
		bhs.s	.spawnlavaball						; if yes, don't move and spawn lava from the center
		bsr.w	BossMove							; otherwise, begin moving Eggman
		subq.w	#4,obVelY(a0)						; reduce Y-speed (creating the arc motion)

	.spawnlavaball:
		subq.b	#1,mzboss_lavatimer(a0)				; decrement random value
		bcc.s	.nolavaball							; if greater than 0, branch (and don't spawn lava ball)
		jsr		(FindFreeObj).l
		bne.s	.resettimer
		_move.b	#id_LavaBall,obID(a1)				; load lava ball object
		move.w	#boss_mz_y+$D8,obY(a1)				; hardset lava ball's Y-position
		jsr		(RandomNumber).w
		andi.l	#$FFFF,d0
		divu.w	#$50,d0
		swap	d0
		addi.w	#boss_mz_x+$78,d0
		move.w	d0,obX(a1)							; randomly set X-position
		lsr.b	#7,d1
		move.w	#$FF,obSubtype(a1)					; set lava ball's subtype to -1

	.resettimer:
		jsr		(RandomNumber).w
		andi.b	#$1F,d0
		addi.b	#$40,d0								; generate a random value from ($40-5F)
		move.b	d0,mzboss_lavatimer(a0)				; store this value

	.nolavaball:
		btst	#staFlipX,obStatus(a0)				; is Eggman facing left?
		beq.s	.facingleft							; if yes, branch
		cmpi.w	#boss_mz_x+$110,boss_bufferX(a0)	; has Eggman reached (or passed) his boundary to the right?
		blt.s	.end								; if not, branch
		move.w	#boss_mz_x+$110,boss_bufferX(a0)	; set Eggman's position to the right boundary
		bra.s	.stopXmovement
; ===========================================================================

	.facingleft:
		cmpi.w	#boss_mz_x+$30,boss_bufferX(a0)		; has Eggman reached (or passed) his boundary to the left?
		bgt.s	.end								; if not, branch
		move.w	#boss_mz_x+$30,boss_bufferX(a0)		; set Eggman's position to the left boundary

	.stopXmovement:
		clr.w	obVelX(a0)							; clear X-speed, stopping horizontal movement
		move.w	#-$180,obVelY(a0)					; Set Y-speed to -1.5, moving Eggman upward
		cmpi.w	#boss_mz_y+$1C,boss_bufferY(a0)		; Is Eggman too high up to drop fire?
		bhs.s	.dontnegate							; if not, branch.
		neg.w	obVelY(a0)							; if yes, negate his Y-speed to lower him down slightly.

	.dontnegate:
		addq.b	#2,ob3rdRout(a0)					; Advance to fire-dropping tertiary routine

	.end:
		rts	
; ===========================================================================

BossMarble_DropFire:		; Tertiary Routine 2/6
		bsr.w	BossMove
		move.w	boss_bufferY(a0),d0
		subi.w	#boss_mz_y+$1C,d0					; Is Eggman in position to drop fire?
		bgt.s	.end								; if not, branch
		move.w	#boss_mz_y+$1C,d0					; ???
		tst.w	obVelY(a0)							; is Eggman moving vertically?
		beq.s	.countdown							; if not, branch. We've already fired the ball.
		clr.w	obVelY(a0)							; stop moving vertically, and deploy that fire!
		move.w	#$50,boss_delaytime(a0)				; set timer for after Eggman fires the ball
		bchg	#staFlipX,obStatus(a0)				; turn Eggman to face toward the center of the field
		jsr		(FindFreeObj).l
		bne.s	.countdown
		move.b	#id_BossFire,obID(a1)				; load boss' fireball object
		move.w	boss_bufferX(a0),obX(a1)
		move.w	boss_bufferY(a0),obY(a1)
		addi.w	#$18,obY(a1)
		move.b	#1,obSubtype(a1)

	.countdown:
		subq.w	#1,boss_delaytime(a0)
		bne.s	.end
		addq.b	#2,ob3rdRout(a0)					; Advance to movement tertiary routine

	.end:
		rts	
; ===========================================================================

BossMarble_ShipExplode:			; Secondary Routine 4
		subq.w	#1,boss_delaytime(a0)
		bmi.s	loc_18500
		bra.w	BossDefeated						; Make explosion in a random spot on the ship
; ===========================================================================

loc_18500:
		bset	#staFlipX,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$26,boss_delaytime(a0)
		tst.b	(v_bossstatus).w
		bne.s	locret_1852A
		move.b	#1,(v_bossstatus).w
		clr.w	obVelY(a0)

locret_1852A:
		rts	
; ===========================================================================

BossMarble_ShipDestroyed:		; Secondary Routine 6
		addq.w	#1,boss_delaytime(a0)
		beq.s	loc_18544
		bpl.s	loc_1854E
		cmpi.w	#boss_mz_y+$60,boss_bufferY(a0)
		bhs.s	loc_18544
		addi.w	#$18,obVelY(a0)						; while timer is negative, the ship should sink down
		bra.s	loc_1857A							; branch to movement
; ===========================================================================

loc_18544:
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,boss_delaytime(a0)
		bra.s	loc_1857A							; branch to movement
; ===========================================================================

loc_1854E:
		cmpi.w	#$30,boss_delaytime(a0)
		blo.s	loc_18566
		beq.s	loc_1856C
		cmpi.w	#$38,boss_delaytime(a0)
		blo.s	loc_1857A							; branch to movement
		addq.b	#2,ob2ndRout(a0)
		bra.s	loc_1857A							; branch to movement
; ===========================================================================

loc_18566:
		subq.w	#8,obVelY(a0)
		bra.s	loc_1857A							; branch to movement
; ===========================================================================

loc_1856C:
		clr.w	obVelY(a0)

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_MZ3,d0
		else
			move.w	#bgm_MZ,d0
		endif

			jsr		(QueueSound1).w					; play MZ music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	endif

loc_1857A:
		bsr.w	BossMove
		bra.w	BossMarble_ChkHit					; we call this solely for the hover effect
; ===========================================================================

BossMarble_ShipFlee:			; Secondary Routine 8
		move.w	#$500,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		cmpi.w	#boss_mz_end,(v_limitright2).w
		bhs.s	loc_1859C
		addq.w	#2,(v_limitright2).w
		bra.s	loc_185A2
; ===========================================================================

loc_1859C:
		tst.b	obRender(a0)
		bpl.s	BossMarble_ShipDel

loc_185A2:
		bsr.w	BossMove
		bra.w	BossMarble_ChkHit					; we call this solely for the hover effect
; ===========================================================================

BossMarble_ShipDel:
		; Objects should not queue themselves for display
		; while also being deleted.
		addq.l	#4,sp			; Clownacy DisplaySprites Fix
		jmp		(DeleteObject).l
; ===========================================================================

BossMarble_FaceMain:			; Routine 4
		moveq	#0,d0
		moveq	#aniID_NormalFace1,d1
		movea.l	boss_parent(a0),a1					; load the parent object (ship) to a1
		move.b	ob2ndRout(a1),d0					; get the ship's current routine
		subq.w	#2,d0								; is ship in a movement phase?
		bne.s	.notMoving							; if not, branch
		btst	#1,obSubtype(a1)
		beq.s	.chkHurt
		tst.w	obVelY(a1)
		bne.s	.chkHurt
		moveq	#aniID_LaughFace,d1					; use laughing animation
		bra.s	.setAnim
; ===========================================================================

	.notMoving:
		subq.b	#2,d0
		bmi.s	.chkHurt							; if not in Routine 6, branch
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
		subq.b	#4,d0								; is Eggman fleeing?
		bne.s	BossMarble_Animate					; if not, branch
		move.b	#aniID_PanicFace,obAnim(a0)			; set panicking face
		tst.b	obRender(a0)
		bpl.s	BossMarble_Delete
		bra.s	BossMarble_Animate					; Face display
; ===========================================================================

BossMarble_FlameMain:			; Routine 6
		move.b	#aniID_Blank,obAnim(a0)
		movea.l	boss_parent(a0),a1					; load the parent object (ship) to a1
		cmpi.b	#8,ob2ndRout(a1)					; has Eggman begun fleeing?
		blt.s	.notfleeing							; if not, branch
		move.b	#aniID_EscapeFlame,obAnim(a0)		; use the escape animation for the flame
		tst.b	obRender(a0)
		bpl.s	BossMarble_Delete
		bra.s	BossMarble_Animate					; Flame Display
; ===========================================================================

	.notfleeing:
		tst.w	obVelX(a1)
		beq.s	BossMarble_Animate
		move.b	#aniID_Flame1,obAnim(a0)

BossMarble_Animate:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w

BossMarble_Display:
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

BossMarble_Delete:
		jmp	(DeleteObject).l
; ===========================================================================

BossMarble_TubeMain:			; Routine 8
		movea.l	boss_parent(a0),a1
		cmpi.b	#8,ob2ndRout(a1)
		bne.s	loc_18688
		tst.b	obRender(a0)
		bpl.s	BossMarble_Delete

loc_18688:
		move.l	#Map_BossItems,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a0)
		move.b	#4,obFrame(a0)
		bra.s	BossMarble_Display
; ===========================================================================