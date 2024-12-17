; ---------------------------------------------------------------------------
; Object 4C - lava geyser / lavafall producer (MZ)
; ---------------------------------------------------------------------------
; Clownacy DisplaySprite Fix (FixBugs solutions implemented as opposed to stack-meddling)

GeyserMaker:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GMake_Index(pc,d0.w),d1
		jmp		GMake_Index(pc,d1.w)	; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
; ===========================================================================
GMake_Index:	offsetTable
		offsetTableEntry.w GMake_Main
		offsetTableEntry.w GMake_Wait
		offsetTableEntry.w GMake_ChkType
		offsetTableEntry.w GMake_MakeLava
		offsetTableEntry.w GMake_Display
		offsetTableEntry.w GMake_Delete

gmake_time = objoff_34		; time delay (2 bytes)
gmake_timer = objoff_32		; current time remaining (2 bytes)
gmake_parent = objoff_3C	; address of parent object
; ===========================================================================

GMake_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Geyser,obMap(a0)
		move.w	#make_art_tile(ArtTile_MZ_Lava,3,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$38,obActWid(a0)
		move.w	#120,gmake_time(a0)		; set time delay to 2 seconds

GMake_Wait:	; Routine 2
		subq.w	#1,gmake_timer(a0)		; decrement timer
		bpl.s	.cancel					; if time remains, branch

		move.w	gmake_time(a0),gmake_timer(a0) ; reset timer
		move.w	(v_player+obY).w,d0
		move.w	obY(a0),d1
		cmp.w	d1,d0
		bhs.s	.cancel
		subi.w	#$170,d1
		cmp.w	d1,d0
		blo.s	.cancel
		addq.b	#2,obRoutine(a0)	; if Sonic is within range, goto GMake_ChkType

.cancel:
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		rts	
; ===========================================================================

GMake_MakeLava:	; Routine 6
		addq.b	#2,obRoutine(a0)
		bsr.w	FindNextFreeObj
		bne.s	.fail
		_move.b	#id_LavaGeyser,obID(a1) ; load lavafall object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.l	a0,gmake_parent(a1)

.fail:
		move.b	#1,obAnim(a0)
		tst.b	obSubtype(a0)	; is object type 0 (geyser) ?
		beq.s	.isgeyser	; if yes, branch
		move.b	#4,obAnim(a0)
		bra.s	GMake_Display
; ===========================================================================

.isgeyser:
		movea.l	gmake_parent(a0),a1 ; get parent object address
		bset	#staFlipY,obStatus(a1)
		move.w	#-$580,obVelY(a1)
		bra.s	GMake_Display
; ===========================================================================

GMake_ChkType:	; Routine 4
		tst.b	obSubtype(a0)	; is object type 00 (geyser) ?
		beq.s	GMake_Display	; if yes, branch
		addq.b	#2,obRoutine(a0)
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		rts	
; ===========================================================================

GMake_Display:	; Routine 8
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		lea		Ani_Geyser(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

GMake_Delete:	; Routine $A
		clr.b	obAnim(a0)
		move.b	#2,obRoutine(a0)
		tst.b	obSubtype(a0)
		beq.w	DeleteObject
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		rts	

; ---------------------------------------------------------------------------
; Object 4D - lava geyser / lavafall (MZ)
; ---------------------------------------------------------------------------

LavaGeyser:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Geyser_Index(pc,d0.w),d1
		jmp		Geyser_Index(pc,d1.w)	; FixBugs - The call to DisplaySprite has been moved to prevent a display-and-delete bug.
; ===========================================================================
Geyser_Index:	offsetTable
		offsetTableEntry.w Geyser_Main
		offsetTableEntry.w Geyser_Action
		offsetTableEntry.w loc_EFFC
		offsetTableEntry.w Geyser_Delete

Geyser_Speeds:	dc.w $FB00, 0
; ===========================================================================

Geyser_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	obY(a0),objoff_30(a0)
		tst.b	obSubtype(a0)
		beq.s	.isgeyser
		subi.w	#$250,obY(a0)

.isgeyser:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	Geyser_Speeds(pc,d0.w),obVelY(a0)
		movea.l	a0,a1
		moveq	#1,d1
		bsr.s	.makelava
		bra.s	.activate
; ===========================================================================

.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail

.makelava:
		_move.b	#id_LavaGeyser,obID(a1)
		move.l	#Map_Geyser,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Lava,3,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#5,obAnim(a1)
		tst.b	obSubtype(a0)
		beq.s	.fail
		move.b	#2,obAnim(a1)

.fail:
		dbf		d1,.loop
		rts	
; ===========================================================================

.activate:
		addi.w	#$60,obY(a1)
		move.w	objoff_30(a0),objoff_30(a1)
		addi.w	#$60,objoff_30(a1)
		move.b	#(colHarmful|colSz_32x112),obColType(a1)

		bset	#shPropFlame,obShieldProp(a1)	; Negated by Flame Shield

		move.b	#$80,obHeight(a1)
		bset	#4,obRender(a1)
		addq.b	#4,obRoutine(a1)
		move.l	a0,objoff_3C(a1)
		tst.b	obSubtype(a0)
		beq.s	.sound
		moveq	#0,d1
		bsr.w	.loop
		addq.b	#2,obRoutine(a1)
		bset	#4,obGfx(a1)
		addi.w	#$100,obY(a1)
		move.w	#priority0,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.w	objoff_30(a0),objoff_30(a1)
		move.l	objoff_3C(a0),objoff_3C(a1)
		clr.b	obSubtype(a0)

.sound:
		move.w	#sfx_Burning,d0
		jsr		(PlaySound_Special).w	; play flame sound

Geyser_Action:	; Routine 2
	; LavaGaming Object Routine Optimization
		tst.b	obSubtype(a0)
		bne.s	Geyser_Type01
	; Object Routine Optimization End

Geyser_Type00:
		addi.w	#$18,obVelY(a0)		; increase object's falling speed
		move.w	objoff_30(a0),d0
		cmp.w	obY(a0),d0
		bhs.s	loc_EFDA
		addq.b	#4,obRoutine(a0)
		movea.l	objoff_3C(a0),a1
		move.b	#3,obAnim(a1)

loc_EFDA:
		bsr.w	SpeedToPos_YOnly
		lea		Ani_Geyser(pc),a1
		jsr		(AnimateSprite).w
		offscreen.w	DeleteObject			; ProjectFM S3k OBject Manager
		jmp		(DisplayAndCollision).l		; FixBugs - Moved to prevent a delete-and-display bug.
; ===========================================================================

Geyser_Type01:
		addi.w	#$18,obVelY(a0)		; increase object's falling speed
		move.w	objoff_30(a0),d0
		cmp.w	obY(a0),d0
		bhs.s	loc_EFFA
		addq.b	#4,obRoutine(a0)
		movea.l	objoff_3C(a0),a1
		move.b	#1,obAnim(a1)

loc_EFFA:
		bsr.w	SpeedToPos_YOnly
		lea		Ani_Geyser(pc),a1
		jsr		(AnimateSprite).w
		offscreen.w	DeleteObject			; ProjectFM S3k OBject Manager
		jmp		(DisplayAndCollision).l		; FixBugs - Moved to prevent a delete-and-display bug.	
; ===========================================================================

loc_EFFC:	; Routine 4
		movea.l	objoff_3C(a0),a1
		cmpi.b	#6,obRoutine(a1)
		beq.w	DeleteObject
		move.w	obY(a1),d0
		addi.w	#$60,d0
		move.w	d0,obY(a0)
		sub.w	objoff_30(a0),d0
		neg.w	d0
		moveq	#8,d1
		cmpi.w	#$40,d0
		bge.s	loc_F026
		moveq	#$B,d1

loc_F026:
		cmpi.w	#$80,d0
		ble.s	loc_F02E
		moveq	#$E,d1

loc_F02E:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	loc_F04C
		move.b	#7,obTimeFrame(a0)
		addq.b	#1,obAniFrame(a0)
		cmpi.b	#2,obAniFrame(a0)
		blo.s	loc_F04C
		clr.b	obAniFrame(a0)

loc_F04C:
		move.b	obAniFrame(a0),d0
		add.b	d1,d0
		move.b	d0,obFrame(a0)
		offscreen.w	DeleteObject			; ProjectFM S3k OBject Manager
		jmp		(DisplayAndCollision).l		; FixBugs - Moved to prevent a delete-and-display bug.
; ===========================================================================

Geyser_Delete:	; Routine 6
		bra.w	DeleteObject
