; ---------------------------------------------------------------------------
; Object - Eggman (MZ)
; ---------------------------------------------------------------------------
; Exclusive OST Constants
;obBoss_BufferX:		equ objoff_2C		; 4 bytes | stored X-axis position
;obBoss_BufferY:		equ objoff_30		; 4 bytes | stored Y-axis position
obMZBoss_FireBallTimer:	equ objoff_34		; 1 byte  | delay timer for random fireball spawning
;obBoss_AttackFlag:		equ objoff_3B		; 1 byte  |
;obBoss_DelayTime:		equ objoff_3C		; 2 bytes | delay timer
;obBoss_FlashFrames:	equ objoff_3E		; 1 byte  | # of frames to flash white when hit
;obBoss_HoverAngle:		equ objoff_3F		; 1 byte  | Used w/ CalcSine for the ship's hover effect
; ---------------------------------------------------------------------------

BossMarble:
		_move.l	#BossMZ_Ship,obAddr(a0)
		move.l	#Map_Eggman,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.w	#priority4,obPriority(a0)
		move.w	obX(a0),obBoss_BufferX(a0)
		move.w	obY(a0),obBoss_BufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0) 				; set number of hits to 8
		move.w	#-$100,obVelX(a0)				; move ship left -- movement applied here, instead of EVERY frame in Routine 0
		move.w	#$500,d1						; set escape speed

		jsr		(FindNextFreeObj).l
		bne.s	BossMZ_Ship
		move.l	#BossFace,obAddr(a1)
		move.b	#id_mzb_explode,obBossFace_Defeat(a1)	; boss defeat routine number
		move.w	d1,obBossFace_Escape(a1)		; set speed at which ship escapes
		move.w	a0,obBossFace_Parent(a1)		; save address of parent

		jsr		(FindNextFreeObj).l
		bne.s	BossMZ_Ship
		_move.l	#BossFlame,obAddr(a1)
		move.w	d1,obBossFlame_Escape(a1)		; set speed at which ship escapes
		move.w	a0,obBossFlame_Parent(a1)		; save address of parent

		jsr		(FindNextFreeObj).l
		bne.s	BossMZ_Ship
		move.l	#BossWeapon,obAddr(a1)
		move.w	#priority3,obPriority(a1)
		move.b	#4,obFrame(a1)					; Tube frame
		move.w	a0,obBossWeapon_Parent(a1)		; save address of parent
; ---------------------------------------------------------------------------

BossMZ_Ship:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossMZ_ShipIndex(pc,d0.w),d1
		jsr		BossMZ_ShipIndex(pc,d1.w)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)			; ignore x/yflip bits
		or.b	d0,obRender(a0)				; combine x/yflip bits from status instead
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

BossMZ_ShipIndex:	offsetTable
ptr_MZB_Start:		offsetTableEntry.w BossMZ_ShipStart
ptr_MZB_Move:		offsetTableEntry.w BossMZ_ShipMove
ptr_MZB_Explode:	offsetTableEntry.w BossMZ_ShipExplode
ptr_MZB_Destroyed:	offsetTableEntry.w BossMZ_ShipDestroyed
ptr_MZB_Flee:		offsetTableEntry.w BossMZ_ShipFlee

id_mzb_wait = ptr_MZB_Start-BossMZ_ShipIndex			; 0
id_mzb_move = ptr_MZB_Move-BossMZ_ShipIndex				; 2
id_mzb_explode = ptr_MZB_Explode-BossMZ_ShipIndex		; 4
id_mzb_destroyed = ptr_MZB_Destroyed-BossMZ_ShipIndex	; 6
id_mzb_flee = ptr_MZB_Flee-BossMZ_ShipIndex				; 8
; ===========================================================================

BossMZ_ShipStart:		; Routine 0
		move.b	obBoss_HoverAngle(a0),d0			; get wobble byte
		addq.b	#2,obBoss_HoverAngle(a0)			; increment wobble (wraps to 0 after $FE)
		jsr		(CalcSine).w						; convert to sine
		asr.w	#2,d0								; divide by 4
		move.w	d0,obVelY(a0)						; set as y speed
		bsr.w	BossMove							; update parent position
		cmpi.w	#boss_mz_x+$110,obBoss_BufferX(a0)	; has boss reached target position?
		bne.s	.not_at_pos							; if not, branch
		addq.b	#2,obRoutine(a0)					; -> BossMZ_ShipMove
		moveq	#0,d0
		move.b	d0,ob2ndRout(a0)
		move.l	d0,obVelX(a0)						; stop moving

	.not_at_pos:
		jsr		(RandomNumber).w
		move.b	d0,obMZBoss_FireBallTimer(a0)		; init timer to a random value between 00-FF

BossMZ_Update:
		move.w	obBoss_BufferY(a0),obY(a0)			; update actual position
		move.w	obBoss_BufferX(a0),obX(a0)
		cmpi.b	#id_mzb_explode,obRoutine(a0)
		bhs.s	.exit								; skip hit check if boss has been defeated
		tst.b	obStatus(a0)
		bmi.s	.defeated							; if bit 7 is set, branch
		tst.b	obColType(a0)
		bne.s	.exit								; skip hit check if boss has no collision at the moment
		tst.b	obBoss_FlashFrames(a0)				; should the boss still be flashing?
		bne.w	BossFlash							; if yes, branch and flash
		move.b	#$28,obBoss_FlashFrames(a0)			; set number of	times for ship to flash
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w						; play boss damage sound
		bra.w	BossFlash							; apply flash effect

	.exit:
		rts	
; ===========================================================================

	.defeated:
		moveq	#100,d0
		bsr.w	AddPoints							; award 1000 points
		move.b	#id_mzb_explode,obRoutine(a0)		; set ship to exploding routine
		move.w	#180,obBoss_DelayTime(a0)			; set timer to 3 seconds
		clr.w	obVelX(a0)							; stop boss moving
		rts
; ===========================================================================

BossMZ_ShipMove:			; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BMZShip_MoveIndex(pc,d0.w),d0
		jsr		BMZShip_MoveIndex(pc,d0.w)
		andi.b	#6,ob2ndRout(a0)					; clamp secondary routine value to a range of 0-6
		bra.w	BossMZ_Update						; update actual position, check for hits
; ===========================================================================

BMZShip_MoveIndex:	offsetTable
		offsetTableEntry.w BossMZMove_MoveAcross	; Move from right to left
		offsetTableEntry.w BossMZMove_DropFire		; Drop fire onto the left side
		offsetTableEntry.w BossMZMove_MoveAcross	; Move from left to right
		offsetTableEntry.w BossMZMove_DropFire		; Drop fire onto the right side
; ===========================================================================

BossMZMove_MoveAcross:		; Secondary Routine 0/4
		tst.w	obVelX(a0)							; is Eggman currently moving horizontally?
		bne.s	.ismoving							; if yes, branch

; This code triggers if:
	; Eggman starts moving to the opposite side, OR
	; Eggman has reached the opposite side of the field
		moveq	#$40,d0
		cmpi.w	#boss_mz_y+$1C,obBoss_BufferY(a0)	; Is Eggman in position to drop fire?
		beq.s	.takeoff							; if yes, branch. He will take off to the other side.
		bcs.s	.applymovement
		neg.w	d0

	.applymovement:
		move.w	d0,obVelY(a0)
		bra.w	BossMove
; ===========================================================================

	.takeoff:
		move.l	#$2000100,obVelX(a0)				; set X-speed to 2 (to the right); set Y-speed to 1
		btst	#staFlipX,obStatus(a0)				; is Eggman facing left?
		bne.s	.ismoving							; if not, branch
		neg.w	obVelX(a0)							; set X-speed to -2 (to the left)

	.ismoving:
		cmpi.b	#24,obBoss_FlashFrames(a0)			; does Eggman have 24 (or more) flash frames left?
		bhs.s	.spawnfireball						; if yes, don't move and spawn lava from the center
		bsr.w	BossMove							; otherwise, begin moving Eggman
		subq.w	#4,obVelY(a0)						; reduce Y-speed (creating the arc motion)

	.spawnfireball:
		subq.b	#1,obMZBoss_FireBallTimer(a0)		; decrement random value
		bcc.s	.nofireball							; if greater than 0, branch (and don't spawn fireball)
		jsr		(FindFreeObj).l
		bne.s	.resettimer
		_move.l	#FireBall,obAddr(a1)				; load fireball object
		move.w	#boss_mz_y+$D8,obY(a1)				; hardset fireball's Y-position
		jsr		(RandomNumber).w
		moveq	#0,d2								; We save 8 cycles with the first two lines below, instead of using andi.l #$FFFF,d0
		move.w	d0,d2								; to make this work, we make use of d2
		divu.w	#$50,d2
		swap	d2
		addi.w	#boss_mz_x+$78,d2
		move.w	d2,obX(a1)							; randomly set X-position
		lsr.b	#7,d1
		move.w	#priority5,obPriority(a1)			; boss fireballs assume lower priority

	.resettimer:
		jsr		(RandomNumber).w
		andi.b	#$1F,d0
		addi.b	#$40,d0								; generate a random value from ($40-5F)
		move.b	d0,obMZBoss_FireBallTimer(a0)		; store this value

	.nofireball:
		btst	#staFlipX,obStatus(a0)				; is Eggman facing left?
		beq.s	.facingleft							; if yes, branch
		cmpi.w	#boss_mz_x+$110,obBoss_BufferX(a0)	; has Eggman reached (or passed) his boundary to the right?
		blt.s	.end								; if not, branch
		move.w	#boss_mz_x+$110,obBoss_BufferX(a0)	; set Eggman's position to the right boundary
		bra.s	.stopXmovement
; ===========================================================================

	.facingleft:
		cmpi.w	#boss_mz_x+$30,obBoss_BufferX(a0)	; has Eggman reached (or passed) his boundary to the left?
		bgt.s	.end								; if not, branch
		move.w	#boss_mz_x+$30,obBoss_BufferX(a0)	; set Eggman's position to the left boundary

	.stopXmovement:
		clr.w	obVelX(a0)							; clear X-speed, stopping horizontal movement
		move.w	#-$180,obVelY(a0)					; Set Y-speed to -1.5, moving Eggman upward
		cmpi.w	#boss_mz_y+$1C,obBoss_BufferY(a0)	; Is Eggman too high up to drop fire?
		bhs.s	.dontnegate							; if not, branch.
		neg.w	obVelY(a0)							; if yes, negate his Y-speed to lower him down slightly.

	.dontnegate:
		addq.b	#2,ob2ndRout(a0)					; Advance to fire-dropping secondary routine

	.end:
		rts	
; ===========================================================================

BossMZMove_DropFire:		; Secondary Routine 2/6
		bsr.w	BossMove
		move.w	obBoss_BufferY(a0),d0
		subi.w	#boss_mz_y+$1C,d0					; Is Eggman in position to drop fire?
		bgt.s	.end								; if not, branch
		move.w	#boss_mz_y+$1C,d0
		tst.w	obVelY(a0)							; is Eggman moving vertically?
		beq.s	.countdown							; if not, branch. We've already fired the ball.
		clr.w	obVelY(a0)							; stop moving vertically, and deploy that fire!
		move.b	#1,obBoss_AttackFlag(a0)			; set Eggman to laugh while attacking
		move.w	#$50,obBoss_DelayTime(a0)			; set timer for after Eggman fires the ball
		bchg	#staFlipX,obStatus(a0)				; turn Eggman to face toward the center of the field
		jsr		(FindFreeObj).l
		bne.s	.countdown
		_move.l	#BossFire,obAddr(a1)				; load boss' fireball object
		move.w	obBoss_BufferX(a0),obX(a1)
		move.w	obBoss_BufferY(a0),obY(a1)
		addi.w	#$18,obY(a1)
		move.b	#1,obSubtype(a1)

	.countdown:
		subq.w	#1,obBoss_DelayTime(a0)
		bne.s	.end
		addq.b	#2,ob2ndRout(a0)					; Advance to movement tertiary routine
		clr.b	obBoss_AttackFlag(a0)				; stop Eggman laughing

	.end:
		rts	
; ===========================================================================

BossMZ_ShipExplode:			; Routine 4
		subq.w	#1,obBoss_DelayTime(a0)				; decrement timer
		bmi.s	.stop_exploding						; branch if below 0
		bra.w	BossDefeated						; Make explosion in a random spot on the ship
; ===========================================================================

	.stop_exploding:
		bset	#staFlipX,obStatus(a0)				; ship face right
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)							; stop moving
		addq.b	#2,obRoutine(a0)					; goto BossMZ_ShipDestroyed next
		move.w	#-$26,obBoss_DelayTime(a0)			; set timer (counts up)
		tst.b	(v_bossstatus).w
		bne.s	.exit
		move.b	#1,(v_bossstatus).w					; set boss beaten flag
		clr.w	obVelY(a0)

	.exit:
		rts	
; ===========================================================================

BossMZ_ShipDestroyed:		; Routine 6
		addq.w	#1,obBoss_DelayTime(a0)				; increment timer
		beq.s	.stop_falling						; branch if 0
		bpl.s	.ship_recovers						; branch if 1 or more
		cmpi.w	#boss_mz_y+$60,obBoss_BufferY(a0)
		bhs.s	.stop_falling
		addi.w	#$18,obVelY(a0)						; while timer is negative, the ship should sink down
		bra.s	.update								; branch to movement
; ===========================================================================

	.stop_falling:
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obBoss_DelayTime(a0)
		bra.s	.update								; branch to movement
; ===========================================================================

	.ship_recovers:
		cmpi.w	#$30,obBoss_DelayTime(a0)
		blo.s	.ship_rises
		beq.s	.stop_rising
		cmpi.w	#$38,obBoss_DelayTime(a0)
		blo.s	.update								; branch to movement
		addq.b	#2,obRoutine(a0)
	; movement applied here, instead of EVERY frame in 2ndRout $C
		move.l	#$0500FFC0,obVelX(a0)				; (xVel: $500, yVel: -$40); move ship to the right, and upward slightly

	if PostBossScreenUnlock
		move.w	#boss_mz_end,(v_limitright).w
	endif

		bra.s	.update								; branch to movement
; ===========================================================================

	.ship_rises:
		subq.w	#8,obVelY(a0)
		bra.s	.update								; branch to movement
; ===========================================================================

	.stop_rising:
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

	.update:
		bsr.w	BossMove
		bra.w	BossMZ_Update						; we call this solely for the hover effect
; ===========================================================================

BossMZ_ShipFlee:			; Routine 8
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_mz_end,(v_limitright).w
		bhs.s	.chkdel
		addq.w	#2,(v_limitright).w
		bra.s	.update
; ===========================================================================
	endif

	.chkdel:
		tst.b	obRender(a0)						; is object on-screen?
		bpl.s	.delete								; if not, branch

	.update:
		bsr.w	BossMove
		bra.w	BossMZ_Update						; we call this solely for the hover effect
; ===========================================================================

	.delete:
		; Objects should not queue themselves for display
		; while also being deleted.
		addq.l	#4,sp								; Clownacy DisplaySprites Fix
		jmp		(DeleteObject).l
; ===========================================================================