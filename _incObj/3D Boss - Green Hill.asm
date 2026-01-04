; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ)
; ---------------------------------------------------------------------------

BossGreenHill:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossGHZ_Index(pc,d0.w),d1
		jmp		BossGHZ_Index(pc,d1.w)
; ===========================================================================

BossGHZ_Index:		offsetTable
		offsetTableEntry.w BossGHZ_Main
		offsetTableEntry.w BossGHZ_ShipMain
		offsetTableEntry.w BossGHZ_FaceMain
		; The wrecking ball is its own object (Obj48)

BossGHZ_ObjData:
	; Ship
		dc.b 2,	aniID_Ship		; routine counter, animation
	; Face
		dc.b 4,	aniID_NormalFace1
; ===========================================================================

BossGHZ_Main:	; Routine 0
		lea		(BossGHZ_ObjData).l,a2			; get data for routine number & animation
		movea.l	a0,a1							; replace current object with 1st in list
		moveq	#1,d1							; 1 additional objects
		bra.s	.loadboss
; ---------------------------------------------------------------------------

	.loop:
		jsr		(FindNextFreeObj).l
		bne.s	.notfound
		_move.l	#BossGreenHill,obAddr(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	.loadboss:
		bclr	#staFlipX,obStatus(a1)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)				; -> BGHZ_ShipMain/BGHZ_FaceMain/BGHZ_FlameMain next
		move.b	(a2)+,obAnim(a1)
		move.w	#priority3,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obDispWid(a1)
		move.w	a0,obBoss_Parent(a1)			; save address of OST of parent
		dbf		d1,.loop						; repeat sequence 2 more times

		jsr		(FindNextFreeObj).l
		bne.s	.notfound
		_move.l	#BossFlame,obAddr(a1)
		move.b	#$40,obSubtype(a1)				; set speed at which ship escapes (div by $10)
		move.w	a0,obBoss_Parent(a1)			; save address of parent

	.notfound:
		move.w	obX(a0),obBoss_BufferX(a0)
		move.w	obY(a0),obBoss_BufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)				; set number of hits to 8
		move.w	#$100,obVelY(a0)				; start moving ship down -- movement applied here, instead of EVERY frame in 2ndRout 0
; ---------------------------------------------------------------------------

BossGHZ_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossGHZ_ShipIndex(pc,d0.w),d1
		jsr		BossGHZ_ShipIndex(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		move.b	obStatus(a0),d0
		andi.b	#(maskFlipX+maskFlipY),d0
		andi.b	#$FC,obRender(a0)				; ignore x/y flip bits
		or.b	d0,obRender(a0)					; combine x/y flip bits from status instead

	if GHZBossDelay
		tst.b	obBossGHZ_Active(a0)
		beq.s	.nohit							; skip hit check if boss isn't ready
		jmp		(DisplayAndCollision).l			; S3K TouchResponse

	.nohit:
		jmp		(DisplaySprite).l
	else
		jmp		(DisplayAndCollision).l			; S3K TouchResponse
	endif
; ===========================================================================

BossGHZ_ShipIndex:		offsetTable
ptr_GHZB_DropDown:	offsetTableEntry.w BossGHZ_ShipDropDown
ptr_GHZB_MakeBall:	offsetTableEntry.w BossGHZ_MakeBall
ptr_GHZB_Wait:		offsetTableEntry.w BossGHZ_ShipWait
ptr_GHZB_Move:		offsetTableEntry.w BossGHZ_ShipMove
ptr_GHZB_Explode:	offsetTableEntry.w BossGHZ_ShipExplode
ptr_GHZB_Destroyed:	offsetTableEntry.w BossGHZ_ShipDestroyed
ptr_GHZB_Flee:		offsetTableEntry.w BossGHZ_ShipFlee

id_ghzb_drop = ptr_GHZB_DropDown-BossGHZ_ShipIndex		; 0
id_ghzb_makeball = ptr_GHZB_MakeBall-BossGHZ_ShipIndex	; 2
id_ghzb_wait = ptr_GHZB_Wait-BossGHZ_ShipIndex			; 4
id_ghzb_move = ptr_GHZB_Move-BossGHZ_ShipIndex			; 6
id_ghzb_explode = ptr_GHZB_Explode-BossGHZ_ShipIndex		; 8
id_ghzb_destroyed = ptr_GHZB_Destroyed-BossGHZ_ShipIndex	; $A
id_ghzb_flee = ptr_GHZB_Flee-BossGHZ_ShipIndex			; $C
; ===========================================================================

BossGHZ_ShipDropDown:	; Secondary Routine 0
		bsr.w	BossMove
		cmpi.w	#boss_ghz_y+$38,obBoss_BufferY(a0)	; has Eggman finished lowering down?
		bne.s	BossGHZ_ChkHit						; if not, branch ahead
	; movement applied here, instead of EVERY frame in 2ndRout 2
		move.l	#$FF00FFC0,obVelX(a0)				; (xVel: -$100, yVel: -$40); move ship to the left, and upward slightly
		addq.b	#2,ob2ndRout(a0)					; go to next routine

BossGHZ_ChkHit:
		move.b	obBoss_HoverAngle(a0),d0			; get wobble byte
		jsr		(CalcSine).w						; convert to sine
		asr.w	#6,d0								; divide by 64
		add.w	obBoss_BufferY(a0),d0				; add y pos
		move.w	d0,obY(a0)							; update actual y pos
		move.w	obBoss_BufferX(a0),obX(a0)			; update actual x pos
		addq.b	#2,obBoss_HoverAngle(a0)			; increment wobble (wraps to 0 after $FE)

	if GHZBossDelay
		tst.b	obBossGHZ_Active(a0)
		beq.s	.exit								; skip hit check if boss isn't ready
	endif

		cmpi.b	#id_ghzb_explode,ob2ndRout(a0)
		bhs.s	.exit								; skip hit check if boss has been defeated
		tst.b	obStatus(a0)
		bmi.s	.defeated							; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	.exit								; skip hit check if boss has no collision at the moment
		tst.b	obBoss_FlashFrames(a0)				; should the boss still be flashing?
		bne.w	BossFlash							; if yes, branch and flash
		move.b	#$20,obBoss_FlashFrames(a0)			; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w						; play boss damage sound
		bra.w	BossFlash							; apply flash effect

	.exit:
		rts
; ===========================================================================

	.defeated:
		moveq	#100,d0
		bsr.w	AddPoints							; give Sonic 1000 points
		move.b	#id_ghzb_explode,ob2ndRout(a0)
		move.w	#179,obBoss_DelayTime(a0)			; set timer to 3 seconds
		rts
; ===========================================================================

BossGHZ_MakeBall:	; Secondary Routine 2
		bsr.w	BossMove
		cmpi.w	#boss_ghz_x+$A0,obBoss_BufferX(a0)	; has Eggman reached the center of the field?
		bne.w	BossGHZ_ChkHit						; if not, branch
		clr.l	obVelX(a0)							; stop ship movement (clear both X and Y velocities)
		addq.b	#2,ob2ndRout(a0)					; go to next routine
		jsr		(FindNextFreeObj).l
		bne.s	.notfound
		_move.l	#BossBall,obAddr(a1)				; load swinging ball object
		move.w	obBoss_BufferX(a0),obX(a1)
		move.w	obBoss_BufferY(a0),obY(a1)
		move.w	a0,obBossBall_Parent(a1)

	.notfound:
		move.w	#119,obBoss_DelayTime(a0)			; set wait timer to 2 seconds (Eggman won't move until this timer is up)
		bra.w	BossGHZ_ChkHit
; ===========================================================================

BossGHZ_ShipWait:	; Secondary Routine 4
		subq.w	#1,obBoss_DelayTime(a0)
		bpl.s	.reverse
		addq.b	#2,ob2ndRout(a0)
		move.w	#$40-1,obBoss_DelayTime(a0)
		move.w	#$100,obVelX(a0)					; move the ship sideways
		cmpi.w	#boss_ghz_x+$A0,obBoss_BufferX(a0)
		bne.s	.reverse
		move.w	#($40*2)-1,obBoss_DelayTime(a0)
		move.w	#$40,obVelX(a0)

	.reverse:
		btst	#staFlipX,obStatus(a0)
		bne.w	BossGHZ_ChkHit
		neg.w	obVelX(a0)							; reverse direction of the ship
		bra.w	BossGHZ_ChkHit
; ===========================================================================

BossGHZ_ShipMove:	; Secondary Routine 6
		subq.w	#1,obBoss_DelayTime(a0)
		bmi.s	.timeup
		bsr.w	BossMove
		bra.w	BossGHZ_ChkHit
; ===========================================================================

	.timeup:
		bchg	#staFlipX,obStatus(a0)
		move.w	#$40-1,obBoss_DelayTime(a0)
		subq.b	#2,ob2ndRout(a0)
		clr.w	obVelX(a0)
		bra.w	BossGHZ_ChkHit
; ===========================================================================

BossGHZ_ShipExplode:	; Secondary Routine 8
		subq.w	#1,obBoss_DelayTime(a0)
		bmi.s	.timeup
		bra.w	BossDefeated			; Make explosion in a random spot on the ship
; ===========================================================================

	.timeup:
		bset	#staFlipX,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		addq.b	#2,ob2ndRout(a0)
		move.w	#-$26,obBoss_DelayTime(a0)
		tst.b	(v_bossstatus).w
		bne.s	.end
		move.b	#1,(v_bossstatus).w

	.end:
		rts	
; ===========================================================================

BossGHZ_ShipDestroyed:	; Secondary Routine $A
		addq.w	#1,obBoss_DelayTime(a0)
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
		cmpi.w	#$30,obBoss_DelayTime(a0)
		blo.s	.riseslightly			; for just under a second, the ship will rise back up
		beq.s	.resetmusic				; if timer == $30, the ship stops rising and music resets
		cmpi.w	#$38,obBoss_DelayTime(a0)
		blo.s	.applymovement
		addq.b	#2,ob2ndRout(a0)
	; movement applied here, instead of EVERY frame in 2ndRout $C
		move.l	#$0400FFC0,obVelX(a0)	; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly

	if PostBossScreenUnlock
		move.w	#boss_ghz_end,(v_limitright).w
	endif

		bra.s	.applymovement
; ===========================================================================

	.riseslightly:
		subq.w	#8,obVelY(a0)
		bra.s	.applymovement
; ===========================================================================

	.resetmusic:
		clr.w	obVelY(a0)

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_GHZ3,d0
		else
			move.w	#bgm_GHZ,d0
		endif

			jsr		(QueueSound1).w					; play GHZ music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	endif

	.applymovement:
		bsr.w	BossMove
		bra.w	BossGHZ_ChkHit						; we call this solely for the hover effect
; ===========================================================================

BossGHZ_ShipFlee:	; Secondary Routine $C
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_ghz_end,(v_limitright).w
		beq.s	.limitreached
		addq.w	#2,(v_limitright).w
		bra.s	.moveboss
; ===========================================================================
	endif

	.limitreached:
		tst.b	obRender(a0)
		bpl.s	BossGHZ_ShipDel

	.moveboss:
		bsr.w	BossMove
		bra.w	BossGHZ_ChkHit						; we call this solely for the hover effect
; ===========================================================================

BossGHZ_ShipDel:
		; We do not want to return to BossGHZ_ShipMain, as objects
		; should not queue themselves for display while also being
		; deleted.
		addq.l	#4,sp								; Clownacy DisplaySprites Fix
		jmp		(DeleteObject).l
; ===========================================================================

BossGHZ_FaceMain:	; Routine 4
		movea.w	obBoss_Parent(a0),a1				; get address of parent object (ship)

	; Devon Boss Object Fix
		; is the boss still loaded (d1 = obAddr)?
		cmp_addr	#BossGreenHill,obAddr(a1),d1
		bne.s	BossGHZ_Delete						; if not, delete object
	; Boss Object Fix End

		moveq	#0,d1
		moveq	#aniID_NormalFace1,d0
		move.b	ob2ndRout(a1),d1					; get the ship's current routine
		subq.b	#id_ghzb_wait,d1					; is ship in an idle phase?
		bne.s	.notIdle							; if not, branch
		cmpi.w	#boss_ghz_x+$A0,obBoss_BufferX(a1)
		bne.s	.chkHurt
		moveq	#aniID_LaughFace,d0

	.notIdle:
		subq.b	#id_ghzb_destroyed-id_ghzb_wait,d1	; is d0 == 6? check for 2ndRout $A
		bmi.s	.chkHurt							; if not in Routine $A, branch
		moveq	#aniID_DefeatFace,d0				; show defeated (burned) face
		bra.s	.setAnim
; ===========================================================================

	.chkHurt:
		tst.b	obColType(a1)
		bne.s	.chkLaughing
		moveq	#aniID_HurtFace,d0
		bra.s	.setAnim
; ===========================================================================

	.chkLaughing:
		cmpi.b	#4,(v_player+obRoutine).w			; is Sonic hurt (or dead)?
		blo.s	.setAnim							; if not, branch
		moveq	#aniID_LaughFace,d0					; use laughing animation

	.setAnim:
		subq.b	#2,d1								; is Eggman fleeing?
		bne.s	BossGHZ_Display						; if not, branch
		moveq	#aniID_PanicFace,d0					; set panicking face
		tst.b	obRender(a0)						; is object on-screen?
		bpl.s	BossGHZ_Delete						; if not, branch and delete
		bra.s	BossGHZ_Display						; Face display
; ===========================================================================

BossGHZ_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

BossGHZ_Display:
		movea.w	obBoss_Parent(a0),a1				; get address of parent object (ship)
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		jsr		(NewAnim).w							; set next animation (TO-DO: Maybe change this to fallthrough to AnimateSprite)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		move.b	obStatus(a0),d0
		andi.b	#(maskFlipX+maskFlipY),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		jmp		(DisplaySprite).l
; ===========================================================================