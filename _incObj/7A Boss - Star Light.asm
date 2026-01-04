; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------

BossStarLight:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossSLZ_Index(pc,d0.w),d1
		jmp	BossSLZ_Index(pc,d1.w)
; ===========================================================================
BossSLZ_Index:	offsetTable
		offsetTableEntry.w BossSLZ_Main
		offsetTableEntry.w BossSLZ_ShipMain
		offsetTableEntry.w BossSLZ_FaceMain
		offsetTableEntry.w BossSLZ_TubeMain

BossSLZ_ObjData:
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
		dc.b 6,	0				; does not animate
		dc.w priority3
; ===========================================================================

BossSLZ_Main:
		move.w	#boss_slz_x+$188,obX(a0)
		move.w	#boss_slz_y+$18,obY(a0)
		move.w	obX(a0),obBoss_BufferX(a0)
		move.w	obY(a0),obBoss_BufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)				; set number of hits to 8
		lea		BossSLZ_ObjData(pc),a2			; get data for routine number, animation & priority
		movea.l	a0,a1							; replace current object with 1st in list
		moveq	#2,d1							; 2 additional objects
		bra.s	.load_boss
; ===========================================================================

	.loop:
		jsr		(FindNextFreeObj).l
		bne.s	.fail
		_move.l	#BossStarLight,obAddr(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	.load_boss:
		bclr	#staFlipX,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.w	(a2)+,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obDispWid(a1)
		move.w	a0,obBoss_Parent(a1)
		dbf		d1,.loop					; repeat sequence 3 more times

	; Set data for Tube
		move.l	#Map_BossItems,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a1)
		move.b	#3,obFrame(a1)

		jsr		(FindNextFreeObj).l
		bne.s	.fail
		_move.l	#BossFlame,obAddr(a1)
		move.b	#$40,obSubtype(a1)				; set speed at which ship escapes (div by $10)
		move.w	a0,obBoss_Parent(a1)			; save address of parent

	.fail:
		lea		(v_lvlobjspace).w,a1		; FixBugs -- Formerly (v_objspace+object_size*1)
		lea		obBossSLZ_Seesaws(a0),a2	; pointers to Eggman's seesaws
		moveq	#v_lvlobjcount,d0			; FixBugs: Normally only covered the first half of object RAM.

	.seesaw_loop:
		; is object a seesaw? (d1 = obAddr)?
		cmp_addr	#Seesaw,obAddr(a1),d1
		bne.s	.next						; if not, branch
		tst.b	obSubtype(a1)				; is seesaw empty?
		beq.s	.next						; if not, branch
		move.w	a1,(a2)+					; set pointer to seesaw object RAM

	.next:
		lea		object_size(a1),a1			; next object RAM entry
		dbf		d0,.seesaw_loop				; repeat for remaining slots
; ---------------------------------------------------------------------------

BossSLZ_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossSLZ_ShipIndex(pc,d0.w),d0
		jsr		BossSLZ_ShipIndex(pc,d0.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================
BossSLZ_ShipIndex:	offsetTable
		offsetTableEntry.w BossSLZ_ShipStart
		offsetTableEntry.w BossSLZ_ShipMove
		offsetTableEntry.w BossSLZ_ShipMakeBall
		offsetTableEntry.w BossSLZ_ShipExplode
		offsetTableEntry.w BossSLZ_ShipDestroyed
		offsetTableEntry.w BossSLZ_ShipFlee
; ===========================================================================

BossSLZ_ShipStart:		; Secondary Routine 0
		move.w	#-$100,obVelX(a0)					; move ship left
		cmpi.w	#boss_slz_x+$120,obBoss_BufferX(a0)	; has ship reached right side of screen?
		bhs.s	BossSLZ_Update						; if not, branch
		addq.b	#2,ob2ndRout(a0)

BossSLZ_Update:
		bsr.w	BossMove							; update parent position
		move.b	obBoss_HoverAngle(a0),d0
		addq.b	#2,obBoss_HoverAngle(a0)
		jsr		(CalcSine).w
		asr.w	#6,d0
		add.w	obBoss_BufferY(a0),d0
		move.w	d0,obY(a0)
		move.w	obBoss_BufferX(a0),obX(a0)
		bra.s	BossSLZ_ChkHit						; check for hit
; ===========================================================================

BossSLZ_ApplyMovement:
		bsr.w	BossMove							; update parent position
		move.w	obBoss_BufferY(a0),obY(a0)			; update actual position
		move.w	obBoss_BufferX(a0),obX(a0)

BossSLZ_ChkHit:
		cmpi.b	#6,ob2ndRout(a0)
		bhs.s	.exit
		tst.b	obStatus(a0)						; has boss been beaten (bit 7 is set)?
		bmi.s	.defeated							; if yes, branch
		tst.b	obColType(a0)						; is ship collision clear?
		bne.s	.exit								; if not, branch
		tst.b	obBoss_FlashFrames(a0)				; is ship flashing?
		bne.w	BossFlash							; if yes, branch
		move.b	#$20,obBoss_FlashFrames(a0)			; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w						; play boss damage sound
		bra.w	BossFlash

	.exit:
		rts	
; ===========================================================================

	.defeated:
		moveq	#100,d0
		bsr.w	AddPoints							; award 1000 points
		move.b	#6,ob2ndRout(a0)					; set ship to exploding routine
		move.b	#120,obBoss_DelayTime(a0)			; set timer to 2 seconds
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

BossSLZ_ShipMove:		; Secondary Routine 2
		move.w	obBoss_BufferX(a0),d0
		move.w	#$200,obVelX(a0)			; move ship right
		btst	#staFlipX,obStatus(a0)
		bne.s	.face_right
		neg.w	obVelX(a0)					; move ship left
		cmpi.w	#boss_slz_x+8,d0
		bgt.s	.find_seesaw
		bra.s	.chg_dir
; ===========================================================================

	.face_right:
		cmpi.w	#boss_slz_x+$138,d0			; has ship reached right side of screen?
		blt.s	.find_seesaw				; if not, branch

	.chg_dir:
		bchg	#staFlipX,obStatus(a0)		; change direction

	.find_seesaw:
		move.w	obX(a0),d0
		moveq	#-1,d1
		moveq	#2,d2						; number of seesaws (3)
		lea		obBossSLZ_Seesaws(a0),a2	; get object addresses for the 3 seesaws
		moveq	#$28,d4						; dist from center to right side of seesaw
		tst.w	obVelX(a0)
		bpl.s	.seesaw_loop				; branch if ship is moving righ
		neg.w	d4							; dist from centre to left side of seesaw

	.seesaw_loop:
		move.w	(a2)+,d1
		movea.l	d1,a3						; a3 = RAM address of seesaw
		btst	#staSonicOnObj,obStatus(a3)	; is Sonic on the seesaw?
		bne.s	.sonic_on_seesaw			; if yes, branch
		move.w	obX(a3),d3
		add.w	d4,d3						; d3 = x position of left/right side of seesaw
		sub.w	d0,d3
		beq.s	.seesaw_found				; branch if ship is directly over side of seesaw

	.sonic_on_seesaw:
		dbf		d2,.seesaw_loop

		move.b	d2,obSubtype(a0)			; set subtype to -1 if no seesaw is found
		bra.w	BossSLZ_Update				; update position, check for hit
; ===========================================================================

	.seesaw_found:
		move.b	d2,obSubtype(a0)			; number of seesaw the ship is above (0/1/2)
		addq.b	#2,ob2ndRout(a0)			; goto BSLZ_MakeBall next
		move.b	#$28,obBoss_DelayTime(a0)	; set timer to 40 frames
		bra.w	BossSLZ_Update				; update position, check for hit
; ===========================================================================

BossSLZ_ShipMakeBall:		; Secondary Routine 4
		cmpi.b	#$28,obBoss_DelayTime(a0)	; has timer started counting down yet?
		bne.s	.wait_next					; if yes, branch
		moveq	#-1,d0
		move.b	obSubtype(a0),d0			; get number of seesaw the ship is above (0/1/2)
		ext.w	d0
		bmi.s	.exit						; branch if no seesaw found (-1)
		subq.w	#2,d0
		neg.w	d0							; switch between 0 and 2
		add.w	d0,d0
		lea		obBossSLZ_Seesaws(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2						; get obj RAM address of seesaw
		lea		(v_lvlobjspace).w,a1		; FixBugs -- Formerly (v_objspace+object_size*1)
		moveq	#v_lvlobjcount,d1			; FixBugs: Normally only covered the first half of object RAM.
		moveq	#object_size,d2

	.loop:
		cmp.w	obBossSpike_Seesaw(a1),d0	; does seesaw already have a spikeball?
		beq.s	.exit						; if yes, branch
		adda.w	d2,a1						; next object slot
		dbf		d1,.loop					; repeat for remaining slots

		move.l	a0,-(sp)					; save current object address to stack
		lea		(a2),a0						; temporarily load seesaw to a0
		jsr		(FindNextFreeObj).l			; find free obj RAM slot after this one
		movea.l	(sp)+,a0
		bne.s	.exit

		_move.l	#BossSpikeball,obAddr(a1)	; load spiked ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$20,obY(a1)
		move.b	obStatus(a2),obStatus(a1)
		move.w	a2,obBossSpike_Seesaw(a1)	; set address of seesaw below
		move.w	a0,obBossSpike_Parent(a1)	; set address of parent object

	.wait_next:
		subq.b	#1,obBoss_DelayTime(a0)		; decrement timer
		beq.s	.exit						; branch if 0
		bra.w	BossSLZ_ChkHit				; check for hit
; ===========================================================================

	.exit:
		subq.b	#2,ob2ndRout(a0)			; -> BossSLZ_ShipMove
		bra.w	BossSLZ_Update				; update position, check for hit
; ===========================================================================

BossSLZ_ShipExplode:		; Secondary Routine 6
		subq.b	#1,obBoss_DelayTime(a0)		; decrement timer
		bmi.s	.stop_exploding				; branch if below 0
		bra.w	BossDefeated				; spawn explosions on the ship
; ===========================================================================

	.stop_exploding:
		addq.b	#2,ob2ndRout(a0)			; -> BossSLZ_ShipDestroyed
		clr.w	obVelY(a0)					; stop moving
		bset	#staFlipX,obStatus(a0)		; ship face right
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		move.b	#-$18,obBoss_DelayTime(a0)	; set timer (counts up)
		tst.b	(v_bossstatus).w
		bne.s	.exit
		move.b	#1,(v_bossstatus).w			; set boss beaten flag

	.exit:
		bra.w	BossSLZ_ChkHit
; ===========================================================================

BossSLZ_ShipDestroyed:		; Secondary Routine 8
		addq.b	#1,obBoss_DelayTime(a0)		; increment timer
		beq.s	.stop_falling				; branch if 0
		bpl.s	.ship_recovers				; branch if 1 or more
		addi.w	#$18,obVelY(a0)				; while timer is negative, the ship should sink down
		bra.w	BossSLZ_ApplyMovement
; ===========================================================================

	.stop_falling:
		clr.w	obVelY(a0)					; stop sinking
		bra.w	BossSLZ_ApplyMovement
; ===========================================================================

	.ship_recovers:
		cmpi.b	#32,obBoss_DelayTime(a0)
		bcs.s	.ship_rises					; for about half a second, the ship will rise back up
		beq.s	.ship_rising				; if timer == $30, the ship stops rising and music resets
		cmpi.b	#42,obBoss_DelayTime(a0)
		bcs.w	BossSLZ_ApplyMovement
		addq.b	#2,ob2ndRout(a0)			; -> BossSLZ_ShipFlee
		move.l	#$0400FFC0,obVelX(a0)		; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly

	if PostBossScreenUnlock
		move.w	#boss_slz_end,(v_limitright).w
	endif

		bra.w	BossSLZ_ApplyMovement
; ===========================================================================

	.ship_rises:
		subq.w	#8,obVelY(a0)
		bra.w	BossSLZ_ApplyMovement
; ===========================================================================

	.ship_rising:
		clr.w	obVelY(a0)

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_SLZ3,d0
		else
			move.w	#bgm_SLZ,d0
		endif

			jsr		(QueueSound1).w			; play SLZ music
			move.b	d0,(v_lastbgmplayed).w	; store last played music
	endif

		bra.w	BossSLZ_ApplyMovement		; update position
; ===========================================================================

BossSLZ_ShipFlee:		; Secondary Routine $A
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_slz_end,(v_limitright).w	; check for new boundary
		bhs.s	.chkdel
		addq.w	#2,(v_limitright).w				; expand right edge of level boundary
		bra.s	.update
; ===========================================================================

	.chkdel:
	endif

		tst.b	obRender(a0)
		bpl.s	.delete			; Clownacy DisplaySprite Fix

	.update:
		bsr.w	BossMove
		bra.w	BossSLZ_Update

	.delete:
		; Avoid returning to BossSLZ_ShipMain to prevent a
		; display-and-delete bug.
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

BossSLZ_FaceMain:	; Routine 4
		movea.w	obBoss_Parent(a0),a1			; get address of parent object (ship)

	; Devon Boss Object Fix
		; is the boss still loaded (d1 = obAddr)?
		cmp_addr	#BossStarLight,obAddr(a1),d1
		bne.w	BossSLZ_Delete					; if not, delete object
	; Boss Object Fix End

		moveq	#0,d1
		moveq	#aniID_NormalFace1,d0
		move.b	ob2ndRout(a1),d1
		cmpi.b	#6,d1
		bmi.s	.chk_hit
		moveq	#aniID_DefeatFace,d0
		bra.s	.update
; ===========================================================================

	.chk_hit:
		tst.b	obColType(a1)					; is boss collision on?
		bne.s	.chk_sonic_hurt					; if yes, branch
		moveq	#aniID_HurtFace,d0				; use hit animation
		bra.s	.update
; ===========================================================================

	.chk_sonic_hurt:
		cmpi.b	#4,(v_player+obRoutine).w		; is Sonic hurt or dead?
		blo.s	.update							; if not, branch
		moveq	#aniID_LaughFace,d0

	.update:
		cmpi.b	#$A,d1							; is ship on BossSLZ_ShipFlee?
		bne.s	BossSLZ_Animate					; if not, branch
		move.b	#aniID_PanicFace,obAnim(a0)		; use sweating animation
		tst.b	obRender(a0)					; is object on-screen?
		bpl.s	BossSLZ_Delete					; if not, branch
; ---------------------------------------------------------------------------

BossSLZ_Animate:
		jsr		(NewAnim).w						; set next animation (TO-DO: Change this to fallthrough to AnimateSprite)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w

BossSLZ_Display:
		movea.w	obBoss_Parent(a0),a1			; get address of parent object (ship)
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)				; ignore x/y flip bits
		or.b	d0,obRender(a0)					; combine x/y flip bits from status instead
		jmp		(DisplaySprite).l
; ===========================================================================

BossSLZ_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

BossSLZ_TubeMain:	; Routine 8
		movea.w	obBoss_Parent(a0),a1			; get address of parent object (ship)

	; Devon Boss Object Fix
		; is the boss still loaded (d1 = obAddr)?
		cmp_addr	#BossStarLight,obAddr(a1),d1
		bne.s	BossSLZ_Delete					; if not, delete object
	; Boss Object Fix End

		cmpi.b	#$A,ob2ndRout(a1)				; is ship on BossSLZ_ShipFlee?
		bne.s	BossSLZ_Display					; if not, branch
		tst.b	obRender(a0)					; is object on-screen?
		bpl.s	BossSLZ_Delete					; if not, branch
		bra.s	BossSLZ_Display
; ===========================================================================