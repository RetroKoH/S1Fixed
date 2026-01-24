; ---------------------------------------------------------------------------
; Object - Eggman (SYZ)
; ---------------------------------------------------------------------------
; Exclusive OST Constants
;obBoss_BufferX:		equ objoff_2C		; 4 bytes | stored X-axis position
;obBoss_BufferY:		equ objoff_30		; 4 bytes | stored Y-axis position
obBossSYZ_BlockAddr:	equ objoff_34		; 2 bytes | address of block Eggman is above - parent only
obBossSYZ_BlockNum:		equ	objoff_36		; 1 byte  | number of block Eggman is above (0-9) - parent only
obBossSYZ_Mode:			equ objoff_37		; 1 byte  | $FF = lifting block
;obBoss_AttackFlag:		equ objoff_3B		; 1 byte  |
;obBoss_DelayTime:		equ objoff_3C		; 2 bytes | delay timer
;obBoss_FlashFrames:	equ objoff_3E		; 1 byte  | # of frames to flash white when hit
;obBoss_HoverAngle:		equ objoff_3F		; 1 byte  | Used w/ CalcSine for the ship's hover effect
; ---------------------------------------------------------------------------

BossSpringYard:
		_move.l	#BossSYZ_Ship,obAddr(a0)
		move.l	#Map_Eggman,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.w	#priority5,obPriority(a0)
		move.w	obX(a0),obBoss_BufferX(a0)
		move.w	obY(a0),obBoss_BufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)					; set number of hits to 8
		move.w	#-$100,obVelX(a0)					; move ship left -- movement applied here, instead of EVERY frame in Routine 0
		move.w	#$400,d1							; set escape speed

		jsr		(FindNextFreeObj).l
		bne.s	BossSYZ_Ship
		move.l	#BossFace,obAddr(a1)
		move.b	#1,obSubtype(a1)					; set subtype to check for 3rdRout #2
		move.b	#id_syzb_explode,obBossFace_Defeat(a1)	; boss defeat routine number
		move.w	d1,obBossFace_Escape(a1)			; set speed at which ship escapes
		move.w	a0,obBossFace_Parent(a1)			; save address of parent

		jsr		(FindNextFreeObj).l
		bne.s	BossSYZ_Ship
		_move.l	#BossFlame,obAddr(a1)
		move.w	d1,obBossFlame_Escape(a1)			; set speed at which ship escapes
		move.w	a0,obBossFlame_Parent(a1)			; save address of parent

		jsr		(FindNextFreeObj).l
		bne.s	BossSYZ_Ship
		move.l	#BossWeapon,obAddr(a1)
		move.w	#priority5,obPriority(a1)
		move.b	#5,obFrame(a1)						; Spike frame
		move.b	#1,obSubtype(a1)					; set to run special routine
		move.w	a0,obBossWeapon_Parent(a1)			; save address of parent
; ---------------------------------------------------------------------------

BossSYZ_Ship:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossSYZ_ShipIndex(pc,d0.w),d1
		jsr		BossSYZ_ShipIndex(pc,d1.w)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

BossSYZ_ShipIndex:	offsetTable
ptr_SYZB_Start:		offsetTableEntry.w BossSYZ_ShipStart
ptr_SYZB_Move:		offsetTableEntry.w BossSYZ_ShipMove
ptr_SYZB_Spike:		offsetTableEntry.w BossSYZ_ShipSpike
ptr_SYZB_Explode:	offsetTableEntry.w BossSYZ_ShipExplode
ptr_SYZB_Destroyed:	offsetTableEntry.w BossSYZ_ShipDestroyed
ptr_SYZB_Flee:		offsetTableEntry.w BossSYZ_ShipFlee

id_syzb_start = ptr_SYZB_Start-BossSYZ_ShipIndex			; 0
id_syzb_move = ptr_SYZB_Move-BossSYZ_ShipIndex				; 2
id_syzb_spike = ptr_SYZB_Spike-BossSYZ_ShipIndex			; 4
id_syzb_explode = ptr_SYZB_Explode-BossSYZ_ShipIndex		; 6
id_syzb_destroyed = ptr_SYZB_Destroyed-BossSYZ_ShipIndex	; 8
id_syzb_flee = ptr_SYZB_Flee-BossSYZ_ShipIndex				; $A
; ===========================================================================

BossSYZ_ShipStart:	; Routine 0
		cmpi.w	#boss_syz_x+$138,obBoss_BufferX(a0)	; has ship appeared from the right yet?
		bhs.s	BossSYZ_ShipHover					; if not, branch
		addq.b	#2,obRoutine(a0)					; -> BossSYZ_ShipMove

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
		cmpi.b	#id_syzb_explode,obRoutine(a0)		; Exploding, Destroyed, or Fleeing?
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
		move.b	#id_syzb_explode,obRoutine(a0)		; set ship to exploding routine
		move.w	#180,obBoss_DelayTime(a0)			; set timer to 3 seconds
		clr.w	obVelX(a0)							; stop boss moving
		rts	
; ===========================================================================

BossSYZ_ShipMove:	; Routine 2
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
		bne.w	BossSYZ_ShipHover					; if not, branch
		move.w	(v_player+obX).w,d1
		subi.w	#boss_syz_x,d1						; get x pos of Sonic relative to left edge
		asr.w	#5,d1								; divide by 32
		cmp.b	obBossSYZ_BlockNum(a0),d1			; is ship above Sonic?
		bne.w	BossSYZ_ShipHover					; if not, branch

		moveq	#0,d0
		move.b	obBossSYZ_BlockNum(a0),d0
		asl.w	#5,d0
		addi.w	#boss_syz_x+$10,d0					; get x pos of block below ship
		move.w	d0,obBoss_BufferX(a0)				; align ship to block
		bsr.w	BossSYZ_FindBlocks					; save obj address of block to obBossSYZ_BlockAddr
		addq.b	#2,obRoutine(a0)					; -> BSYZ_Attack
		clr.b	ob2ndRout(a0)						; -> BSYZ_Descend (This previously cleared $28 and $29)
		clr.w	obVelX(a0)							; stop moving horizontally
		bra.w	BossSYZ_ShipHover
; ===========================================================================

BossSYZ_ShipSpike:	; Routine 4
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BSYZSpike_Index(pc,d0.w),d0
		jmp		BSYZSpike_Index(pc,d0.w)
; ===========================================================================
BSYZSpike_Index:	offsetTable
		offsetTableEntry.w BSYZSpike_Descending
		offsetTableEntry.w BSYZSpike_CaughtBlock
		offsetTableEntry.w BSYZSpike_LiftingBlock
		offsetTableEntry.w BSYZSpike_BreakingBlock
; ===========================================================================

BSYZSpike_Descending:		; Secondary Routine 0
		move.w	#$180,obVelY(a0)					; move ship down
		move.w	obBoss_BufferY(a0),d0
		cmpi.w	#boss_syz_y+$8A,d0					; has ship reached block?
		blo.w	BossSYZ_ApplyMovement				; if not, branch
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
		addq.b	#2,ob2ndRout(a0)				; advance to next secondary routine (_CaughtBlock)
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

BSYZSpike_CaughtBlock:		; Secondary Routine 2
		subq.w	#1,obBoss_DelayTime(a0)			; is delay timer expired?
		bpl.s	.shake							; if not, branch and wait
		addq.b	#2,ob2ndRout(a0)				; advance to next secondary routine (_LiftingBlock)
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
		move.w	d0,obY(a0)							; update actual y pos to apply juddering effect as Eggman lifts the block
		move.w	obBoss_BufferX(a0),obX(a0)
		bra.w	BossSYZ_ChkHit
; ===========================================================================

BSYZSpike_LiftingBlock:		; Secondary Routine 4
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
		addq.b	#2,ob2ndRout(a0)				; goto BSYZ_BreakBlock
		clr.w	obVelY(a0)						; stop moving up
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

	.not_at_top:
		cmpi.w	#-$40,obVelY(a0)
		bge.w	BossSYZ_ApplyMovement
		addi.w	#$C,obVelY(a0)
		bra.w	BossSYZ_ApplyMovement
; ===========================================================================

BSYZSpike_BreakingBlock:	; Secondary Routine 6
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
		subq.b	#2,obRoutine(a0)				; -> BSYZ_ShipMove
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

BossSYZ_ShipExplode:		; Routine 6
		subq.w	#1,obBoss_DelayTime(a0)					; decrement timer
		bmi.s	.stop_exploding							; branch if below 0
		bra.w	BossDefeated							; make explosion in a random spot on the ship
; ===========================================================================

	.stop_exploding:
		addq.b	#2,obRoutine(a0)						; -> BossSYZ_ShipDestroyed
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

BossSYZ_ShipDestroyed:		; Routine 8
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
		addq.b	#2,obRoutine(a0)						; -> BossSYZ_ShipFlee
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

BossSYZ_ShipFlee:		; Routine $A
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
		bpl.s	.delete									; if not, branch

	.update:
		bsr.w	BossMove								; update parent position
		bra.w	BossSYZ_ShipHover						; update actual position
; ===========================================================================

	.delete:
		; Avoid returning to BossSYZ_Ship to prevent a
		; display-and-delete bug. (Clownacy DisplaySprite Fix)
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================