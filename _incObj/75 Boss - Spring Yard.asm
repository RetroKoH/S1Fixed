; ---------------------------------------------------------------------------
; Object 75 - Eggman (SYZ)
; ---------------------------------------------------------------------------

BossSpringYard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossSYZ_Index(pc,d0.w),d1
		jmp		BossSYZ_Index(pc,d1.w)
; ===========================================================================

BossSYZ_Index:	offsetTable
		offsetTableEntry.w BossSYZ_Main
		offsetTableEntry.w BossSYZ_Ship
		offsetTableEntry.w BossSYZ_Spike

BossSYZ_ObjData:
	; Ship
		dc.b 2,	aniID_Ship		; routine counter, animation
	; Spike
		dc.b 4,	0				; does not animate
; ===========================================================================

BossSYZ_Main:	; Routine 0
		move.w	#boss_syz_x+$1B0,obX(a0)
		move.w	#boss_syz_y+$E,obY(a0)
		move.w	obX(a0),obBoss_BufferX(a0)
		move.w	obY(a0),obBoss_BufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)					; set number of hits to 8
		lea		BossSYZ_ObjData(pc),a2				; get routine number, animation & priority
		movea.l	a0,a1								; replace current object with 1st in list
		moveq	#1,d1								; 1 additional object
		bra.s	.load_boss
; ===========================================================================

	.loop:
		jsr		(FindNextFreeObj).l
		bne.w	BossSYZ_Ship
		_move.l	#BossSpringYard,obAddr(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	.load_boss:
		bclr	#staFlipX,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)					; goto BSYZ_ShipMain/BSYZ_FaceMain/BSYZ_FlameMain/BSYZ_SpikeMain next
		move.b	(a2)+,obAnim(a1)
		move.w	#priority5,obPriority(a1)			; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obDispWid(a1)
		move.w	a0,obBoss_Parent(a1)				; save address of parent
		dbf		d1,.loop							; repeat sequence 1 more time

	; Set data for Spike
		move.l	#Map_BossItems,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a1)
		move.b	#5,obFrame(a1)
		move.w	#$400,d1

		jsr		(FindNextFreeObj).l
		bne.s	BossSYZ_Ship
		move.l	#BossFace,obAddr(a1)
		move.b	#1,obSubtype(a1)					; set subtype to check for 3rdRout #2
		move.b	#6,obBossFace_Defeat(a1)			; boss defeat routine number
		move.w	d1,obBossFace_Escape(a1)			; set speed at which ship escapes
		move.w	a0,obBossFace_Parent(a1)			; save address of parent

		jsr		(FindNextFreeObj).l
		bne.s	BossSYZ_Ship
		_move.l	#BossFlame,obAddr(a1)
		move.w	d1,obBossFlame_Escape(a1)			; set speed at which ship escapes
		move.w	a0,obBossFlame_Parent(a1)			; save address of parent
; ---------------------------------------------------------------------------

BossSYZ_Ship:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossSYZ_ShipIndex(pc,d0.w),d1
		jsr		BossSYZ_ShipIndex(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================
BossSYZ_ShipIndex:	offsetTable
		offsetTableEntry.w BossSYZ_ShipStart
		offsetTableEntry.w BossSYZ_ShipMove
		offsetTableEntry.w BossSYZ_ShipSpike
		offsetTableEntry.w BossSYZ_ShipExplode
		offsetTableEntry.w BossSYZ_ShipDestroyed
		offsetTableEntry.w BossSYZ_ShipFlee
; ===========================================================================

BossSYZ_ShipStart:	; Secondary Routine 0
		move.w	#-$100,obVelX(a0)					; move ship left
		cmpi.w	#boss_syz_x+$138,obBoss_BufferX(a0)	; has ship appeared from the right yet?
		bhs.s	BossSYZ_ShipHover			; if not, branch
		addq.b	#2,ob2ndRout(a0)					; -> BossSYZ_ShipMove

BossSYZ_ShipHover:
		move.b	obBoss_HoverAngle(a0),d0			; get wobble byte
		addq.b	#2,obBoss_HoverAngle(a0)			; increment wobble (wraps to 0 after $FE)
		jsr		(CalcSine).w						; convert to sine
		asr.w	#2,d0								; divide by 4
		move.w	d0,obVelY(a0)						; set as y speed

BossSYZ_ApplyMovement:
		bsr.w	BossMove							; update parent position
		move.w	obBoss_BufferY(a0),obY(a0)			; update actual position
		move.w	obBoss_BufferX(a0),obX(a0)

BossSYZ_ChkHit:
		move.w	obX(a0),d0
		subi.w	#boss_syz_x,d0						; subtract x pos of first block
		lsr.w	#5,d0								; divide by 32
		move.b	d0,obBossSYZ_BlockNum(a0)			; id of block the ship is above
		cmpi.b	#6,ob2ndRout(a0)					; Exploding, Destroyed, or Fleeing?
		bcc.s	.exit								; if yes, branch
		tst.b	obStatus(a0)						; has boss been beaten (bit 7 is set)?
		bmi.s	.defeated							; if yes, branch
		tst.b	obColType(a0)						; is ship collision clear?
		bne.s	.exit								; if not, branch
		tst.b	obBoss_FlashFrames(a0)				; is ship flashing?
		bne.w	BossFlash							; if yes, branch
		move.b	#32,obBoss_FlashFrames(a0)			; set ship to flash 32 times
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w						; play boss damage sound
		bra.w	BossFlash
; ===========================================================================

	.exit:
		rts	
; ===========================================================================

	.defeated:
		moveq	#100,d0
		bsr.w	AddPoints							; award 1000 points
		move.b	#6,ob2ndRout(a0)					; set ship to exploding routine
		move.w	#180,obBoss_DelayTime(a0)			; set timer to 3 seconds
		clr.w	obVelX(a0)							; stop boss moving
		rts	
; ===========================================================================

BossSYZ_ShipMove:	; Secondary Routine 2
		move.w	obBoss_BufferX(a0),d0
		move.w	#$140,obVelX(a0)					; move ship right
		btst	#staFlipX,obStatus(a0)				; is ship facing left?
		bne.s	.face_right							; if not, branch
		neg.w	obVelX(a0)							; move left instead
		cmpi.w	#boss_syz_x+8,d0					; is ship at left edge of screen?
		bgt.s	.inside_boundary					; if not, branch
		bra.s	.chg_dir
; ===========================================================================

	.face_right:
		cmpi.w	#boss_syz_x+$138,d0					; is ship at right edge of screen?
		blt.s	.inside_boundary					; if not, branch

	.chg_dir:
		bchg	#staFlipX,obStatus(a0)				; change direction
		clr.b	obBoss_DelayTime+1(a0)				; clear low byte of timer

	.inside_boundary:
		subi.w	#boss_syz_x+$10,d0					; get x pos of ship relative to left edge
		andi.w	#$1F,d0								; read only bits 0-4
		subi.w	#$1F,d0
		bpl.s	.d0_is_0							; branch if all those bits were set
		neg.w	d0									; make d0 positive

	.d0_is_0:
		subq.w	#1,d0
		bgt.w	BossSYZ_ShipHover
		tst.b	obBoss_DelayTime+1(a0)				; is low byte of timer 0?
		bne.w	BossSYZ_ShipHover			; if not, branch
		move.w	(v_player+obX).w,d1
		subi.w	#boss_syz_x,d1						; get x pos of Sonic relative to left edge
		asr.w	#5,d1								; divide by 32
		cmp.b	obBossSYZ_BlockNum(a0),d1			; is ship above Sonic?
		bne.w	BossSYZ_ShipHover			; if not, branch

		moveq	#0,d0
		move.b	obBossSYZ_BlockNum(a0),d0
		asl.w	#5,d0
		addi.w	#boss_syz_x+$10,d0					; get x pos of block below ship
		move.w	d0,obBoss_BufferX(a0)				; align ship to block
		bsr.w	BossSYZ_FindBlocks			; save obj address of block to obBossSYZ_BlockAddr
		addq.b	#2,ob2ndRout(a0)					; -> BSYZ_Attack
		clr.w	obBoss_3rdRout(a0)					; -> BSYZ_Descend
		clr.w	obVelX(a0)							; stop moving horizontally
		bra.w	BossSYZ_ShipHover
; ===========================================================================

BossSYZ_ShipSpike:	; Secondary Routine 4
		moveq	#0,d0
		move.b	obBoss_3rdRout(a0),d0
		move.w	BSYZSpike_Index(pc,d0.w),d0
		jmp		BSYZSpike_Index(pc,d0.w)
; ===========================================================================
BSYZSpike_Index:	offsetTable
		offsetTableEntry.w BSYZSpike_Descending
		offsetTableEntry.w BSYZSpike_CaughtBlock
		offsetTableEntry.w BSYZSpike_LiftingBlock
		offsetTableEntry.w BSYZSpike_BreakingBlock
; ===========================================================================

BSYZSpike_Descending:		; Tertiary Routine 0
		move.w	#$180,obVelY(a0)					; move ship down
		move.w	obBoss_BufferY(a0),d0
		cmpi.w	#boss_syz_y+$8A,d0					; has ship reached block?
		blo.w	BossSYZ_ApplyMovement		; if not, branch
		move.w	#boss_syz_y+$8A,obBoss_BufferY(a0)	; align to block
		clr.w	obBoss_DelayTime(a0)
		moveq	#-1,d0
		move.w	obBossSYZ_BlockAddr(a0),d0			; get obj address of block
		beq.s	.no_block							; if Eggman doesn't have a block, branch (and don't set delay timer)
		movea.l	d0,a1								; a1 = address of targeted block
		move.b	#-1,obBossBlock_Mode(a1)			; set block lifting flag
		move.b	#-1,obBossSYZ_Mode(a0)
		move.w	a0,obBossBlock_Parent(a1)			; assign main boss object as brick's "parent"
		move.w	#$32,obBoss_DelayTime(a0)			; set delay timer

	.no_block:
		clr.w	obVelY(a0)
		addq.b	#2,obBoss_3rdRout(a0)				; advance to next tertiary routine (_CaughtBlock)
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

BSYZSpike_CaughtBlock:		; Tertiary Routine 2
		subq.w	#1,obBoss_DelayTime(a0)			; is delay timer expired?
		bpl.s	.shake							; if not, branch and wait
		addq.b	#2,obBoss_3rdRout(a0)			; advance to next tertiary routine (_LiftingBlock)
		move.w	#-$800,obVelY(a0)				; rise at a speed of -8
		tst.w	obBossSYZ_BlockAddr(a0)			; is Eggman carrying a block?
		bne.s	.lifting						; if yes, branch
		asr		obVelY(a0)						; if not, halve to -4 instead

	.lifting:
		moveq	#0,d0							; no shake
		bra.s	.update
; ===========================================================================

	.shake:
		moveq	#0,d0
		cmpi.w	#30,obBoss_DelayTime(a0)		; have 20 frames passed since making contact with the block?
		bgt.s	.update							; if not, branch
		moveq	#2,d0							; shake 2px
		btst	#1,obBoss_DelayTime+1(a0)		; test bit 1 of timer (changes every 2nd frame)
		beq.s	.update							; branch if 0
		neg.w	d0								; shake -2px

	.update:
		add.w	obBoss_BufferY(a0),d0				; add parent y pos to shake
		move.w	d0,obY(a0)						; update actual y pos to apply juddering effect as Eggman lifts the block
		move.w	obBoss_BufferX(a0),obX(a0)
		bra.w	BossSYZ_ChkHit
; ===========================================================================

BSYZSpike_LiftingBlock:		; Tertiary Routine 4
		move.w	#boss_syz_y+$E,d0
		tst.w	obBossSYZ_BlockAddr(a0)			; is Eggman carrying a block?
		beq.s	.no_block						; if not, branch
		subi.w	#$18,d0

	.no_block:
		cmp.w	obBoss_BufferY(a0),d0				; has ship reached top of the screen?
		blt.s	.not_at_top						; if not, branch
		move.w	#8,obBoss_DelayTime(a0)
		tst.w	obBossSYZ_BlockAddr(a0)			; is Eggman carrying a block?
		beq.s	.no_block2						; if not, branch
		move.w	#45,obBoss_DelayTime(a0)

	.no_block2:
		addq.b	#2,obBoss_3rdRout(a0)			; goto BSYZ_BreakBlock
		clr.w	obVelY(a0)						; stop moving up
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

	.not_at_top:
		cmpi.w	#-$40,obVelY(a0)
		bge.w	BossSYZ_ApplyMovement
		addi.w	#$C,obVelY(a0)
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

BSYZSpike_BreakingBlock:		; Tertiary Routine 6
		subq.w	#1,obBoss_DelayTime(a0)			; decrement timer
		bgt.s	.shake
		bmi.s	.reset_to_hover					; branch if below 0
		moveq	#-1,d0
		move.w	obBossSYZ_BlockAddr(a0),d0		; get RAM address of block
		beq.s	.no_block						; if Eggman doesn't have a block, branch 
		movea.l	d0,a1							; load block to a1
		move.b	#$A,obBossBlock_Mode(a1)		; signal block to break

	.no_block:
		clr.w	obBossSYZ_BlockAddr(a0)			; clear block address
		bra.s	.shake
; ===========================================================================

	.reset_to_hover:
		cmpi.w	#-$1E,obBoss_DelayTime(a0)
		bne.s	.shake
		clr.b	obBossSYZ_Mode(a0)
		subq.b	#2,ob2ndRout(a0)				; -> BSYZ_ShipMove
		move.b	#-1,obBoss_DelayTime+1(a0)
		bra.w	BossSYZ_ChkHit
; ===========================================================================

	.shake:
		moveq	#1,d0
		tst.w	obBossSYZ_BlockAddr(a0)			; is Eggman carrying a block?
		beq.s	.no_block2						; if not, branch
		moveq	#2,d0							; shake value

	.no_block2:
		cmpi.w	#boss_syz_y+$E,obBoss_BufferY(a0)	; is ship at top of screen?
		beq.s	.skip_shake						; if yes, branch
		blt.s	.above_top						; branch if above top
		neg.w	d0								; invert shake

	.above_top:
		tst.w	obBossSYZ_BlockAddr(a0)			; why is this test here???
		add.w	d0,obBoss_BufferY(a0)

	.skip_shake:
		moveq	#0,d0
		tst.w	obBossSYZ_BlockAddr(a0)			; is Eggman carrying a block?
		beq.s	.skip_shake2					; if not, branch
		moveq	#2,d0
		btst	#0,obBoss_DelayTime+1(a0)
		beq.s	.skip_shake2
		neg.w	d0

	.skip_shake2:
		add.w	obBoss_BufferY(a0),d0
		move.w	d0,obY(a0)						; update actual y pos
		move.w	obBoss_BufferX(a0),obX(a0)
		bra.w	BossSYZ_ChkHit
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to find the OST address of the block Eggman is above
;
; output:
;	a1 = address of OST of block Eggman is above
; ---------------------------------------------------------------------------

BossSYZ_FindBlocks:
		clr.w	obBossSYZ_BlockAddr(a0)					; clear stored block address
		lea		(v_lvlobjspace).w,a1					; Fixed from (v_objspace+object_size*1)
		moveq	#v_lvlobjcount,d0						; Fixed. Originally only covered the first half of object RAM.
		move.b	obBossSYZ_BlockNum(a0),d2

	.loop:
		; is object a SYZ boss block? (d1 = obAddr)?
		cmp_addr	#BossBlock,obAddr(a1),d1
		bne.s	.nextObj								; if not, branch
		cmp.b	obSubtype(a1),d2						; can block be plucked?
		bne.s	.nextObj								; if not, branch
		move.w	a1,obBossSYZ_BlockAddr(a0)				; set pointer to block object RAM
		bra.s	.endloop
; ===========================================================================

	.nextObj:
		lea		object_size(a1),a1						; next object RAM entry
		dbf		d0,.loop								; repeat for remaining slots

	.endloop:
		rts	
; End of function BossSYZ_FindBlocks
; ===========================================================================

BossSYZ_ShipExplode:		; Secondary Routine 6
		subq.w	#1,obBoss_DelayTime(a0)					; decrement timer
		bmi.s	.stop_exploding							; branch if below 0
		bra.w	BossDefeated							; make explosion in a random spot on the ship
; ===========================================================================

	.stop_exploding:
		addq.b	#2,ob2ndRout(a0)						; -> BossSYZ_ShipDestroyed
		clr.w	obVelY(a0)								; stop moving
		bset	#staFlipX,obStatus(a0)					; ship face right
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		move.w	#-1,obBoss_DelayTime(a0)				; set timer (counts up)
		tst.b	(v_bossstatus).w
		bne.w	BossSYZ_ChkHit
		move.b	#1,(v_bossstatus).w						; set boss beaten flag
		bra.w	BossSYZ_ChkHit
; ===========================================================================

BossSYZ_ShipDestroyed:		; Secondary Routine 8
		addq.w	#1,obBoss_DelayTime(a0)					; increment timer
		beq.s	.stop_falling							; branch if 0
		bpl.s	.ship_recovers							; branch if 1 or more
		addi.w	#$18,obVelY(a0)							; apply gravity (falls)
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

	.stop_falling:
		clr.w	obVelY(a0)								; stop falling
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

	.ship_recovers:
		cmpi.w	#32,obBoss_DelayTime(a0)				; have 32 frames passed since ship stopped falling?
		blo.s	.ship_rises								; if not, branch
		beq.s	.stop_rising							; if exactly 32, branch
		cmpi.w	#42,obBoss_DelayTime(a0)				; have 42 frames passed since ship stopped falling?
		blo.w	BossSYZ_ApplyMovement					; if not, branch
		addq.b	#2,ob2ndRout(a0)						; -> BossSYZ_ShipFlee
;		move.l	#$0400FFC0,obVelX(a0)					; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly

	if PostBossScreenUnlock
		move.w	#boss_syz_end,(v_limitright).w			; immediately extend right-side level boundary
	endif

		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

	.ship_rises:
		subq.w	#8,obVelY(a0)							; move ship upwards
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

	.stop_rising:
		clr.w	obVelY(a0)

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_SYZ3,d0
		else
			move.w	#bgm_SYZ,d0
		endif

			jsr		(QueueSound1).w						; play SYZ music
			move.b	d0,(v_lastbgmplayed).w				; store last played music
	endif

		bra.w	BossSYZ_ApplyMovement					; update actual position, check for hits
; ===========================================================================

BossSYZ_ShipFlee:		; Secondary Routine $A
		move.l	#$0400FFC0,obVelX(a0)					; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_syz_end,(v_limitright).w			; check for new boundary
		bhs.s	.chkdel
		addq.w	#2,(v_limitright).w						; expand right edge of level boundary
		bra.s	.update
; ===========================================================================
	endif

	.chkdel:
		tst.b	obRender(a0)							; is ship on-screen?
		bpl.s	BossSYZ_ShipDelete						; if not, branch

.update:
		bsr.w	BossMove								; update parent position
		bra.w	BossSYZ_ShipHover						; update actual position
; ===========================================================================

BossSYZ_ShipDelete:
		; Avoid returning to BossSYZ_Ship to prevent a
		; display-and-delete bug. (Clownacy DisplaySprite Fix)
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

BossSYZ_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

BossSYZ_Display:
		jsr		(NewAnim).w								; set next animation (TO-DO: Change this to fallthrough to AnimateSprite)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		movea.w	obBoss_Parent(a0),a1					; get address of parent object (ship)
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)

BSYZ_Display_SkipAnim:
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)						; ignore x/yflip bits
		or.b	d0,obRender(a0)							; combine x/yflip bits from status instead
		jmp		(DisplaySprite).l
; ===========================================================================

BossSYZ_Spike:	; Routine 4
		movea.w	obBoss_Parent(a0),a1					; get address of parent object (ship)

	; Devon Boss Object Fix
		; is the boss still loaded (d1 = obAddr)?
		cmp_addr	#BossSpringYard,obAddr(a1),d1
		bne.s	BossSYZ_Delete							; if not, delete object
	; Boss Object Fix End

		cmpi.b	#$A,ob2ndRout(a1)						; is ship on BSYZ_Escape?
		bne.s	.not_escaping							; if not, branch
		tst.b	obRender(a0)							; is object on-screen?
		bpl.s	BossSYZ_Delete							; if not, branch

	.not_escaping:
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.w	obBoss_DelayTime(a0),d0
		cmpi.b	#4,ob2ndRout(a1)						; is ship descending or lifting a block?
		bne.s	.not_attacking							; if not, branch
		cmpi.b	#6,obSubtype(a1)						; is block being broken right now?
		beq.s	.breaking_block							; if yes, branch
		tst.b	obSubtype(a1)							; is ship descending?
		bne.s	.set_spike								; if not branch
		cmpi.w	#$94,d0
		bge.s	.set_spike
		addq.w	#7,d0
		bra.s	.set_spike
; ===========================================================================

	.breaking_block:
		tst.w	obBoss_DelayTime(a1)
		bpl.s	.set_spike

	.not_attacking:
		tst.w	d0
		ble.s	.set_spike
		subq.w	#5,d0

	.set_spike:
		move.w	d0,obBoss_DelayTime(a0)					; set timer
		asr.w	#2,d0
		add.w	d0,obY(a0)								; extend or retract spike
		move.b	#8,obDispWid(a0)
		move.b	#$C,obHeight(a0)
		clr.b	obColType(a0)
		movea.w	obBoss_Parent(a0),a1					; get address of parent object (ship)
		tst.b	obColType(a1)							; has ship been hit recently?
		beq.w	BSYZ_Display_SkipAnim					; if yes, branch
		tst.b	obBossSYZ_Mode(a1)						; is block being lifted?
		bne.w	BSYZ_Display_SkipAnim					; if yes, branch
		move.b	#(colHarmful|colSz_4x16),obColType(a0)	; make spike harmful
		bra.w	BSYZ_Display_SkipAnim
; ===========================================================================