; ---------------------------------------------------------------------------
; Object - Eggman (LZ)
; ---------------------------------------------------------------------------
; Exclusive OST Constants
;obBoss_BufferX:		equ objoff_2C		; 4 bytes | stored X-axis position
;obBoss_BufferY:		equ objoff_30		; 4 bytes | stored Y-axis position
obBossLZ_Defeated:		equ objoff_34		; 1 byte  | $FF = boss is defeated
;obBoss_AttackFlag:		equ objoff_3B		; 1 byte  |
;obBoss_DelayTime:		equ objoff_3C		; 2 bytes | delay timer
;obBoss_FlashFrames:	equ objoff_3E		; 1 byte  | # of frames to flash white when hit
;obBoss_HoverAngle:		equ objoff_3F		; 1 byte  | Used w/ CalcSine for the ship's hover effect
; ---------------------------------------------------------------------------

BossLabyrinth:
		_move.l	#BossLZ_Ship,obAddr(a0)
		move.w	#boss_lz_x+$30,obX(a0)
		move.w	#boss_lz_y+$500,obY(a0)
		move.w	obX(a0),obBoss_BufferX(a0)
		move.w	obY(a0),obBoss_BufferY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)				; set number of hits to 8
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		bclr	#staFlipX,obStatus(a0)
		clr.b	obRoutine(a0)
		move.l	#Map_Eggman,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.w	#$400,d1

		jsr		(FindNextFreeObj).l
		bne.s	BossLZ_Ship
		move.l	#BossFace,obAddr(a1)
		; no defeat routine marker
		move.w	d1,obBossFace_Escape(a1)			; set speed at which ship escapes
		move.w	a0,obBossFace_Parent(a1)			; save address of parent

		jsr		(FindNextFreeObj).l
		bne.s	BossLZ_Ship
		_move.l	#BossFlame,obAddr(a1)
		move.w	d1,obBossFlame_Escape(a1)			; set speed at which ship escapes
		move.w	a0,obBossFlame_Parent(a1)			; save address of parent
; ---------------------------------------------------------------------------

BossLZ_Ship:
		lea		(v_player).w,a1
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossLZ_ShipIndex(pc,d0.w),d1
		jsr		BossLZ_ShipIndex(pc,d1.w)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)				; ignore x/yflip bits
		or.b	d0,obRender(a0)					; combine x/yflip bits from status instead
		jmp		(DisplayAndCollision).l			; S3K TouchResponse
; ===========================================================================

BossLZ_ShipIndex:	offsetTable
		offsetTableEntry.w BossLZ_ShipStart
		offsetTableEntry.w BossLZ_ShipMove
		offsetTableEntry.w BossLZ_ShipMove2
		offsetTableEntry.w BossLZ_ShipMove3
		offsetTableEntry.w BossLZ_ShipAtTop
		offsetTableEntry.w BossLZ_ShipWaitAtTop
		offsetTableEntry.w BossLZ_ShipTurnToFlee
		offsetTableEntry.w BossLZ_ShipFlee
; ===========================================================================

BossLZ_ShipStart:
		move.w	obX(a1),d0
		cmpi.w	#boss_lz_x-$40,d0				; has Sonic passed $1DA0 on x axis?
		blo.s	BossLZ_Update					; if not, branch
		move.w	#-$180,obVelY(a0)				; move ship up
		move.w	#$60,obVelX(a0)					; move ship right
		addq.b	#2,obRoutine(a0)				; -> BossLZ_ShipMove

BossLZ_Update:
		bsr.w	BossMove						; update parent position
		move.w	obBoss_BufferY(a0),obY(a0)		; update actual position
		move.w	obBoss_BufferX(a0),obX(a0)

BossLZ_Update_SkipPos:
		tst.b	obBossLZ_Defeated(a0)			; has boss been defeated? (and points received)
		bne.w	BossDefeated					; if yes, branch
		tst.b	obStatus(a0)					; has boss been defeated (has bit 7 been set)?
		bmi.s	.defeated						; if yes, branch
		tst.b	obColType(a0)					; is ship collision clear?
		bne.s	.exit							; if not, branch
		tst.b	obBoss_FlashFrames(a0)			; is ship flashing?
		bne.w	BossFlash						; if yes, branch
		move.b	#32,obBoss_FlashFrames(a0)		; set ship to flash 32 times
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w					; play boss damage sound
		bra.w	BossFlash

	.exit:
		rts	
; ===========================================================================

	.defeated:
		moveq	#100,d0
		bsr.w	AddPoints							; give Sonic 1000 points
		move.b	#-1,obBossLZ_Defeated(a0)			; set defeated flag
		rts	
; ===========================================================================

BossLZ_ShipMove:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$68,obBoss_BufferX(a0)	; has ship reached x pos?
		bcs.s	.continue_right						; if not, branch
		move.w	#boss_lz_x+$68,obBoss_BufferX(a0)	; align to x pos
		clr.w	obVelX(a0)							; stop moving right
		addq.w	#1,d0

	.continue_right:
		cmpi.w	#boss_lz_y+$440,obBoss_BufferY(a0)	; has ship reached y pos?
		bgt.s	.continue_up						; if not, branch
		move.w	#boss_lz_y+$440,obBoss_BufferY(a0)	; align to y pos
		clr.w	obVelY(a0)							; stop moving up
		addq.w	#1,d0

	.continue_up:
		bne.w	BossLZ_Update						; branch if ship is still moving
		move.w	#$140,obVelX(a0)					; move ship right
		move.w	#-$200,obVelY(a0)					; move ship up
		addq.b	#2,obRoutine(a0)					; -> BossLZ_ShipMove2 
		bra.w	BossLZ_Update
; ===========================================================================

BossLZ_ShipMove2:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$90,obBoss_BufferX(a0)	; has ship reached x pos?
		bcs.s	.continue_right						; if not, branch
		move.w	#boss_lz_x+$90,obBoss_BufferX(a0)	; align to x pos
		clr.w	obVelX(a0)							; stop moving right
		addq.w	#1,d0

	.continue_right:
		cmpi.w	#boss_lz_y+$400,obBoss_BufferY(a0)	; has ship reached y pos?
		bgt.s	.continue_up						; if not, branch
		move.w	#boss_lz_y+$400,obBoss_BufferY(a0)	; align to y pos
		clr.w	obVelY(a0)							; stop moving up
		addq.w	#1,d0

	.continue_up:
		bne.w	BossLZ_Update						; branch if ship is still moving
		move.w	#-$180,obVelY(a0)					; move ship up
		addq.b	#2,obRoutine(a0)					; -> BossLZ_ShipMove3
		clr.b	obBoss_HoverAngle(a0)
		bra.w	BossLZ_Update
; ===========================================================================

BossLZ_ShipMove3:
		cmpi.w	#boss_lz_y+$40,obBoss_BufferY(a0)	; has ship reached y pos?
		bgt.s	BossLZ_ShipWobble					; if not, branch
		move.w	#boss_lz_y+$40,obBoss_BufferY(a0)	; align to y pos
		move.w	#$140,obVelX(a0)					; move ship right
		move.w	#-$80,obVelY(a0)					; move ship up
		tst.b	obBossLZ_Defeated(a0)				; has boss been beaten?
		beq.s	.not_beaten							; if not, branch
		asl		obVelX(a0)
		asl		obVelY(a0)

	.not_beaten:
		addq.b	#2,obRoutine(a0)
		bra.w	BossLZ_Update
; ===========================================================================

BossLZ_ShipWobble:
		bset	#staFlipX,obStatus(a0)				; ship face right
		addq.b	#2,obBoss_HoverAngle(a0)			; increment wobble
		move.b	obBoss_HoverAngle(a0),d0
		jsr		(CalcSine).w						; convert to sine/cosine
		tst.w	d1
		bpl.s	.face_right							; branch if cosine is positive
		bclr	#staFlipX,obStatus(a0)				; ship face left

	.face_right:
		asr.w	#4,d0
		swap	d0
		clr.w	d0
		add.l	obBoss_BufferX(a0),d0
		swap	d0
		move.w	d0,obX(a0)							; apply wobble to x pos
		move.w	obVelY(a0),d0
		move.w	(v_player+obY).w,d1
		sub.w	obY(a0),d1
		bcs.s	.in_range							; branch if Sonic is above the ship
		subi.w	#72,d1
		bcs.s	.in_range							; branch if Sonic is within 72px below the ship
		asr.w	#1,d0
		subi.w	#40,d1
		bcs.s	.in_range							; branch if Sonic is within 112px below the ship
		asr.w	#1,d0
		subi.w	#40,d1
		bcs.s	.in_range							; branch if Sonic is within 152px below the ship
		moveq	#0,d0

	.in_range:
		ext.l	d0
		asl.l	#8,d0
		tst.b	obBossLZ_Defeated(a0)				; has boss been defeated?
		beq.s	.defeated							; if not, branch
		add.l	d0,d0								; double speed if beaten

	.defeated:
		add.l	d0,obBoss_BufferY(a0)
		move.w	obBoss_BufferY(a0),obY(a0)			; update y position (moves slower if further from Sonic)
		bra.w	BossLZ_Update_SkipPos				; check for hit
; ===========================================================================

BossLZ_ShipAtTop:
		moveq	#-2,d0
		cmpi.w	#boss_lz_x+$16C,obBoss_BufferX(a0)	; has ship reached x pos?
		blo.s	.continue_right						; if not, branch
		move.w	#boss_lz_x+$16C,obBoss_BufferX(a0)	; align to x pos
		clr.w	obVelX(a0)							; stop moving right
		addq.w	#1,d0

	.continue_right:
		cmpi.w	#boss_lz_y,obBoss_BufferY(a0)		; has ship reached y pos?
		bgt.s	.continue_up						; if not, branch
		move.w	#boss_lz_y,obBoss_BufferY(a0)		; align to y pos
		clr.w	obVelY(a0)							; stop moving up
		addq.w	#1,d0

	.continue_up:
		bne.w	BossLZ_Update						; branch if ship is still moving
		addq.b	#2,obRoutine(a0)					; goto BossLZ_ShipWaitAtTop
		bclr	#staFlipX,obStatus(a0)				; ship face left
		bra.w	BossLZ_Update						; update position, check for hit
; ===========================================================================

BossLZ_ShipWaitAtTop:
		tst.b	obBossLZ_Defeated(a0)				; has boss been beaten?
		bne.s	.beaten								; if yes, branch
		cmpi.w	#boss_lz_x+$E8,obX(a1)				; has Sonic passed x pos?
		blt.w	BossLZ_Update						; if not, branch
		cmpi.w	#boss_lz_y+$30,obY(a1)
		bgt.w	BossLZ_Update
		move.b	#50,obBoss_DelayTime(a0)			; set timer for 50 frames

	.beaten:

	if ~~AmbienceMode
		if DynamicBGMs
			move.w	#bgm_LZ3,d0
		else
			move.w	#bgm_LZ,d0
		endif

			jsr		(QueueSound1).w					; play LZ music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	endif

		clr.b	(f_lockscreen).w
		bset	#staFlipX,obStatus(a0)				; ship face right
		addq.b	#2,obRoutine(a0)					; goto BossLZ_ShipTurnToFlee
		bra.w	BossLZ_Update						; update position, check for hit
; ===========================================================================

BossLZ_ShipTurnToFlee:
		tst.b	obBossLZ_Defeated(a0)				; has boss been beaten?
		bne.s	.beaten								; if yes, branch
		subq.b	#1,obBoss_DelayTime(a0)				; decrement timer
		bne.w	BossLZ_Update						; branch if time remains

	.beaten:
		clr.b	obBoss_DelayTime(a0)
		move.l	#$0400FFC0,obVelX(a0)				; (xVel: $400, yVel: -$40); move ship to the right, and upward slightly
		clr.b	obBossLZ_Defeated(a0)
		addq.b	#2,obRoutine(a0)					; goto BossLZ_ShipFlee

	if PostBossScreenUnlock
		move.w	#boss_lz_end,(v_limitright).w
	endif

		bra.w	BossLZ_Update						; update position
; ===========================================================================

BossLZ_ShipFlee:
	if ~~PostBossScreenUnlock
		cmpi.w	#boss_lz_end,(v_limitright).w		; check for new boundary
		bhs.s	.chkdel
		addq.w	#2,(v_limitright).w					; expand right edge of level boundary
		bra.w	BossLZ_Update
; ===========================================================================

	.chkdel:
	endif

		tst.b	obRender(a0)						; is ship on-screen?
		bpl.s	BossLZ_ShipDel						; if not, branch
		bra.w	BossLZ_Update						; update position
; ===========================================================================

BossLZ_ShipDel:
		; Avoid returning to BossLZ_Ship to prevent a
		; display-and-delete bug.
		addq.l	#4,sp			; Clownacy DisplaySprite Fix
		jmp		(DeleteObject).l
; ===========================================================================