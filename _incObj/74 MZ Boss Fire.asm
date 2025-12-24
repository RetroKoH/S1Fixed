; ---------------------------------------------------------------------------
; Object 74 - lava that	Eggman drops (MZ)
; ---------------------------------------------------------------------------

BossFire:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossFire_Index(pc,d0.w),d0
		jmp		BossFire_Index(pc,d0.w)			; DisplaySprite has been moved to avoid a display-after-free bug -- Clownacy DisplaySprite Fix
; ===========================================================================

BossFire_Index:		offsetTable
		offsetTableEntry.w BossFire_Main
		offsetTableEntry.w BossFire_Action
		offsetTableEntry.w BossFire_TempFire
		offsetTableEntry.w BossFire_TempFireDel
; ===========================================================================

BossFire_Main:	; Routine 0
		move.w	#$808,obHeight(a0)				; Height and Width
		move.l	#Map_Fire,obMap(a0)
		move.w	#make_art_tile(ArtTile_Fireball,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority5,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),obBossFire_BufferY(a0)
		move.b	#8,obDispWid(a0)
		addq.b	#2,obRoutine(a0)				; -> BossFire_Action

		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield

		tst.b	obSubtype(a0)					; is this subtype 00?
		bne.s	BossFire_First					; if not, branch
		move.b	#(colHarmful|colSz_8x8),obColType(a0)
		addq.b	#2,obRoutine(a0)				; -> BossFire_TempFire
		bra.w	BossFire_TempFire
; ===========================================================================

BossFire_First:
		move.b	#30,obBossFire_DelayTime(a0)	; set delay timer to drop from the tube to half a second
		move.w	#sfx_Fireball,d0
		jsr		(QueueSound2).w					; play lava sound

BossFire_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossFire_Index2(pc,d0.w),d0
		jsr		BossFire_Index2(pc,d0.w)
		jsr		(SpeedToPos).l
		lea		Ani_Fire(pc),a1
		jsr		(AnimateSprite).w
		cmpi.w	#boss_mz_y+$D8,obY(a0)			; has fireball fallen into the lava in the middle?
		bhi.w	BossFire_TempFireDel			; if yes, branch
		jmp		(DisplayAndCollision).l			; Clownacy DisplaySprite Fix; S3K TouchResponse
; ===========================================================================

BossFire_Index2:	offsetTable
		offsetTableEntry.w.w BossFire_Drop
		offsetTableEntry.w.w BossFire_MakeFlame
		offsetTableEntry.w.w BossFire_FireSpread
		offsetTableEntry.w.w BossFire_FallEdge
; ===========================================================================

BossFire_Drop:		; Secondary Routine 0
		bset	#staFlipY,obStatus(a0)			; flip it upside down initially
		subq.b	#1,obBossFire_DelayTime(a0)		; decrement timer
		bpl.s	.end							; if timer is positive, branch and exit
	; delaytimer will continue decrementing, but we can ignore it now
		move.b	#(colHarmful|colSz_8x8),obColType(a0)
		clr.b	obSubtype(a0)					; clear subtype to 00
		addi.w	#$18,obVelY(a0)					; let fireball drop down
		bclr	#staFlipY,obStatus(a0)			; fireball is no longer upside down
		jsr		(ObjFloorDist).l
		tst.w	d1								; has the fireball collided with the floor?
		bpl.s	.end							; if not, branch and exit
		addq.b	#2,ob2ndRout(a0)				; go to the next secondary routine (_MakeFlame)

	.end:
		rts	
; ===========================================================================

BossFire_MakeFlame:	; Secondary Routine 2
		subq.w	#2,obY(a0)						; upon landing, nudge the ball up by 2 pixels
		bset	#gfxPriority,obGfx(a0)
		move.l	#$00A00000,obVelX(a0)			; set X-speed to 0.625 and clear obVelY
		move.w	obX(a0),obBossFire_BufferX(a0)	; store X and Y positions on the ground
		move.w	obY(a0),obBossFire_BufferY(a0)
		move.b	#3,obBossFire_DelayTime(a0)
		jsr		(FindNextFreeObj).l
		bne.s	.end
		lea		(a1),a3							; a3 = new object
		lea		(a0),a2							; a2 = THIS object
		moveq	#3,d0							; run the loop 4 times for $40 bytes

	.loop:			; Copy all data to the new object
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf		d0,.loop

		neg.w	obVelX(a1)						; negate new object's X-speed to (-0.625)
		addq.b	#2,ob2ndRout(a1)				; set new object's secondary routine to 4 (_Duplicate)

	.end:
		addq.b	#2,ob2ndRout(a0)				; set current object's secondary routine to 4 (_Duplicate)
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to spawn another fireball in the current one's position
; ---------------------------------------------------------------------------

;BossFire_Duplicate:
BossFire_SpawnFire:
		jsr		(FindNextFreeObj).l
		bne.s	.noslot
		move.b	#id_BossFire,obID(a1)			; load boss' fireball object
		move.w	obX(a0),obX(a1)					; copy X and Y-positions
		move.w	obY(a0),obY(a1)
		move.b	#$67,obBossFire_DelayTime(a1)	; set timer (no need to clear subtype here)

	.noslot:
		rts	
; End of function BossFire_SpawnFire
; ===========================================================================

;BossFire_ChkDuplicate:
BossFire_FireSpread:	; Secondary Routine 4
		jsr		(ObjFloorDist).l
		tst.w	d1								; is the fireball on the floor?
		bpl.s	.notonfloor						; if not, branch
		move.w	obX(a0),d0
		cmpi.w	#boss_mz_x+$140,d0				; is the fireball past the right edge of the right platform?
		bgt.s	.offscreenRight					; if yes, branch
		move.w	obBossFire_BufferX(a0),d1		; d1 = stored ground X-position
		cmp.w	d0,d1							; is this fireball still at its stored ground position (IE it hasn't moved)?
		beq.s	.donotduplicate					; if yes, branch
		andi.w	#$10,d0							; isolate bit 4 of both X-positions
		andi.w	#$10,d1
		cmp.w	d0,d1							; are both bit 4's set?
		beq.s	.donotduplicate					; if yes, branch
		bsr.s	BossFire_SpawnFire
		move.w	obX(a0),obBossFire_BufferX2(a0)

	.donotduplicate:
		move.w	obX(a0),obBossFire_BufferX(a0)
		rts	
; ===========================================================================

	.notonfloor:
		addq.b	#2,ob2ndRout(a0)				; go to the next secondary routine (_FallEdge)
		rts	
; ===========================================================================

	.offscreenRight:
		addq.b	#2,obRoutine(a0)				; go to the next primary routine 4
		rts	
; ===========================================================================

BossFire_FallEdge:	; Secondary Routine 6
		bclr	#staFlipY,obStatus(a0)
		addi.w	#$24,obVelY(a0)					; make flame fall
		move.w	obX(a0),d0
		sub.w	obBossFire_BufferX2(a0),d0		; d0 = distance from last new fireball object spawn
		bpl.s	.is_positive
		neg.w	d0								; make d0 positive

	.is_positive:
		cmpi.w	#18,d0
		bne.s	.not_18px						; branch if not 18px
		bclr	#gfxPriority,obGfx(a0)			; clear priority bit so it's drawn behind the lava

	.not_18px:
		jsr		(ObjFloorDist).l
		tst.w	d1								; has fireball hit the floor?
		bpl.s	.not_on_floor					; if not, branch
		subq.b	#1,obBossFire_DelayTime(a0)		; decrement timer (starts at 3)
		beq.s	BossFire_Delete					; branch if time remains
		clr.w	obVelY(a0)						; stop falling
		move.w	obBossFire_BufferX2(a0),obX(a0)	; return to previous position
		move.w	obBossFire_BufferY(a0),obY(a0)
		bset	#gfxPriority,obGfx(a0)
		subq.b	#2,ob2ndRout(a0)				; -> BFire_FireSpread

	.not_on_floor:
		rts	
; ===========================================================================

BossFire_Delete:
		; Do not return to BossFire_Action, to avoid double-delete
		; and display-and-delete bugs.
		addq.l	#4,sp			; Clownacy DisplaySprite Fix

BossFire_TempFireDel:	; Routine 6
		jmp		(DeleteObject).l
; ===========================================================================

;BossFire_OffScreenRight
BossFire_TempFire:			; Routine 4
		bset	#gfxPriority,obGfx(a0)
		subq.b	#1,obBossFire_DelayTime(a0)		; decrement timer
		bne.s	.animate						; branch if time remains
		move.b	#1,obAnim(a0)					; use animation for vertical fireball disappearing
		subq.w	#4,obY(a0)
		clr.b	obColType(a0)					; make fireball harmless

	.animate:
		lea		Ani_Fire(pc),a1
		; DisplaySprite has been moved to avoid a display-after-free bug.
		jsr		(AnimateSprite).w				; animate and goto BFire_TempFireDel if 2nd animation ran
		jmp		(DisplayAndCollision).l			; S3K TouchResponse; Clownacy DisplaySprite Fix
; ===========================================================================
