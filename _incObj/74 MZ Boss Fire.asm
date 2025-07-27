; ---------------------------------------------------------------------------
; Object 74 - lava that	Eggman drops (MZ)
; ---------------------------------------------------------------------------

BossFire:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossFire_Index(pc,d0.w),d0
		jmp		BossFire_Index(pc,d0.w)		; DisplaySprite has been moved to avoid a display-after-free bug -- Clownacy DisplaySprite Fix
; ===========================================================================
BossFire_Index:		offsetTable
		offsetTableEntry.w BossFire_Main
		offsetTableEntry.w BossFire_Action
		offsetTableEntry.w BossFire_OffScreenRight
		offsetTableEntry.w BossFire_Delete2

bossfire_delaytimer = objoff_29					; delay timer for various actions (1 byte)
bossfire_bufferX = objoff_30					; stored X-position (2 bytes)
bossfire_bufferX2 = objoff_32					; second stored X-position (2 bytes)
bossfire_bufferY = objoff_38					; stored Y-position (2 bytes)
; ===========================================================================

BossFire_Main:	; Routine 0
		move.w	#$808,obHeight(a0)				; Height and Width
		move.l	#Map_Fire,obMap(a0)
		move.w	#make_art_tile(ArtTile_Fireball,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority5,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),bossfire_bufferY(a0)
		move.b	#8,obActWid(a0)
		addq.b	#2,obRoutine(a0)

		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield

		tst.b	obSubtype(a0)					; is this subtype 00?
		bne.s	loc_1870A						; if not, branch
		move.b	#(colHarmful|colSz_8x8),obColType(a0)
		addq.b	#2,obRoutine(a0)
		bra.w	BossFire_OffScreenRight
; ===========================================================================

loc_1870A:
		move.b	#30,bossfire_delaytimer(a0)		; set delay timer to drop from the tube to half a second
		move.w	#sfx_Fireball,d0
		jsr		(PlaySound_Special).w			; play lava sound

BossFire_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossFire_Index2(pc,d0.w),d0
		jsr		BossFire_Index2(pc,d0.w)
		jsr		(SpeedToPos).l
		lea		Ani_Fire(pc),a1
		jsr		(AnimateSprite).w
		cmpi.w	#boss_mz_y+$D8,obY(a0)
		bhi.w	BossFire_Delete2
		jmp		(DisplayAndCollision).l			; Clownacy DisplaySprite Fix; S3K TouchResponse
; ===========================================================================

BossFire_Index2:	offsetTable
		offsetTableEntry.w.w BossFire_Drop
		offsetTableEntry.w.w BossFire_MakeFlame
		offsetTableEntry.w.w BossFire_ChkDuplicate
		offsetTableEntry.w.w BossFire_FallEdge
; ===========================================================================

BossFire_Drop:		; Secondary Routine 0
		bset	#staFlipY,obStatus(a0)			; flip it upside down initially
		subq.b	#1,bossfire_delaytimer(a0)		; decrement timer
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
		bset	#7,obGfx(a0)
		move.w	#$A0,obVelX(a0)					; set X-speed to 0.625
		clr.w	obVelY(a0)						; clear Y-speed
		move.w	obX(a0),bossfire_bufferX(a0)	; store X and Y positions on the ground
		move.w	obY(a0),bossfire_bufferY(a0)
		move.b	#3,bossfire_delaytimer(a0)
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


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossFire_Duplicate:
		jsr		(FindNextFreeObj).l
		bne.s	.noslot
		move.b	#id_BossFire,obID(a1)			; load boss' fireball object
		move.w	obX(a0),obX(a1)					; copy X and Y-positions
		move.w	obY(a0),obY(a1)
		move.w	#$67,obSubtype(a1)				; set subtype (is this arbitrary just to be non-zero)?

	.noslot:
		rts	
; End of function BossFire_Duplicate2
; ===========================================================================

BossFire_ChkDuplicate:	; Secondary Routine 4
		jsr		(ObjFloorDist).l
		tst.w	d1								; is the fireball on the floor?
		bpl.s	.notonfloor						; if not, branch
		move.w	obX(a0),d0
		cmpi.w	#boss_mz_x+$140,d0				; is the fireball past the right edge of the right platform?
		bgt.s	.offscreenRight					; if yes, branch
		move.w	bossfire_bufferX(a0),d1			; d1 = stored ground X-position
		cmp.w	d0,d1							; is this fireball still at its stored ground position (IE it hasn't moved)?
		beq.s	.donotduplicate					; if yes, branch
		andi.w	#$10,d0							; isolate bit 4 of both X-positions
		andi.w	#$10,d1
		cmp.w	d0,d1							; are both bit 4's set?
		beq.s	.donotduplicate					; if yes, branch
		bsr.s	BossFire_Duplicate
		move.w	obX(a0),bossfire_bufferX2(a0)

	.donotduplicate:
		move.w	obX(a0),bossfire_bufferX(a0)
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
		addi.w	#$24,obVelY(a0)	; make flame fall
		move.w	obX(a0),d0
		sub.w	bossfire_bufferX2(a0),d0
		bpl.s	loc_1884A
		neg.w	d0

loc_1884A:
		cmpi.w	#$12,d0
		bne.s	loc_18856
		bclr	#7,obGfx(a0)

loc_18856:
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_1887E
		subq.b	#1,bossfire_delaytimer(a0)
		beq.s	BossFire_Delete
		clr.w	obVelY(a0)
		move.w	bossfire_bufferX2(a0),obX(a0)
		move.w	bossfire_bufferY(a0),obY(a0)
		bset	#7,obGfx(a0)
		subq.b	#2,ob2ndRout(a0)

locret_1887E:
		rts	
; ===========================================================================

BossFire_Delete:
		; Do not return to BossFire_Action, to avoid double-delete
		; and display-and-delete bugs.
		addq.l	#4,sp			; Clownacy DisplaySprite Fix

BossFire_Delete2:	; Routine 6
		jmp		(DeleteObject).l
; ===========================================================================

BossFire_OffScreenRight:			; Routine 4
		bset	#7,obGfx(a0)
		subq.b	#1,bossfire_delaytimer(a0)
		bne.s	.animate
		move.b	#1,obAnim(a0)
		subq.w	#4,obY(a0)
		clr.b	obColType(a0)

	.animate:
		lea		Ani_Fire(pc),a1
		; DisplaySprite has been moved to avoid a display-after-free bug.
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l	; S3K TouchResponse; Clownacy DisplaySprite Fix
; ===========================================================================
