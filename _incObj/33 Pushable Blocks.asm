; ---------------------------------------------------------------------------
; Object 33 - pushable blocks (MZ, LZ)
; ---------------------------------------------------------------------------

PushBlock:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PushB_Index(pc,d0.w),d1
		jmp		PushB_Index(pc,d1.w)
; ===========================================================================
PushB_Index:	offsetTable
		offsetTableEntry.w PushB_Main
		offsetTableEntry.w PushB_Action
		offsetTableEntry.w PushB_ChkVisible

PushB_Var:
		dc.b $10, 0	; object width,	frame number
		dc.b $40, 1
; ===========================================================================

PushB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> PushB_Action
		move.w	#$F0F,obHeight(a0)			; Height and Width
		move.l	#Map_Push,obMap(a0)
		move.w	#make_art_tile(ArtTile_MZ_Block,2,0),obGfx(a0)		; MZ specific code
		cmpi.b	#id_LZ,(v_zone).w			; is current zone Labyrinth?
		bne.s	.notLZ						; if not, branch
		move.w	#make_art_tile(ArtTile_LZ_Push_Block,2,0),obGfx(a0)	; LZ specific code

	.notLZ:
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),obPushB_StartX(a0)
		move.w	obY(a0),obPushB_StartY(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype
		add.w	d0,d0
		andi.w	#$E,d0						; read low nybble
		lea		PushB_Var(pc,d0.w),a2		; get width & frame values from array
		move.b	(a2)+,obDispWid(a0)
		move.b	(a2)+,obFrame(a0)
		tst.b	obSubtype(a0)				; is subtype 0?
		beq.s	.chkgone					; if yes, branch
		bset	#7,obGfx(a0)				; set highest bit and make sprite appear in foreground

	.chkgone:
	; ProjectFM S3K Objects Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	PushB_Action				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
		bset	#0,(a2)
	; S3K Objects Manager End
		bne.w	DeleteObject
; ---------------------------------------------------------------------------

PushB_Action:	; Routine 2
		tst.b	obPushB_LavaFlag(a0)		; is block on lava?
		bne.w	PushB_OnLava				; if yes, branch
		moveq	#11,d1
		add.b	obDispWid(a0),d1			; width; save 8 cycles
		moveq	#16,d2						; jumping (jumping); save 4 cycles -- Filter
		moveq	#17,d3						; jumping (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	PushB_Solid					; make block solid & update its position
		cmpi.w	#(id_MZ<<8)+0,(v_zone).w	; is the level MZ act 1?
		bne.s	PushB_Display				; if not, branch
		bclr	#7,obSubtype(a0)
		move.w	obX(a0),d0
		cmpi.w	#$A20,d0
		bcs.s	PushB_Display
		cmpi.w	#$AA1,d0					; is block between $A20 and $AA1 on x axis?
		bcc.s	PushB_Display				; if not, branch

		move.w	(v_obj31ypos).w,d0			; get y pos of nearby chain stomper
		subi.w	#$1C,d0
		move.w	d0,obY(a0)					; set y pos of block so it's resting on the stomper
		bset	#7,(v_obj31ypos).w			; set high bit of high byte of stomper y pos
		bset	#7,obSubtype(a0)			; set flag to disable gravity for block

PushB_Display:
		offscreen.s	PushB_ChkDel			; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================

PushB_ChkDel:
		out_of_range.s	PushB_ChkDel2,obPushB_StartX(a0)	; We will actually retain the old macro here
		move.w	obPushB_StartX(a0),obX(a0)
		move.w	obPushB_StartY(a0),obY(a0)
		move.b	#4,obRoutine(a0)
		bra.s	PushB_ChkVisible
; ===========================================================================

PushB_ChkDel2:
	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0	; get address in respawn table
		beq.w	DeleteObject			; if it's zero, don't remember object
		movea.w	d0,a2					; load address into a2
		bclr	#0,(a2)
	; S3K Object Manager End
		bra.w	DeleteObject
; ===========================================================================

PushB_ChkVisible:	; Routine 4
		bsr.w	ChkPartiallyVisible		; is block still on screen? (CheckOffScreen_Wide)
		beq.s	.visible				; if yes, branch
		move.b	#2,obRoutine(a0)
		clr.b	obPushB_LavaFlag(a0)
		clr.l	obVelX(a0)				; clear x/y speeds

	.visible:
		rts	
; ===========================================================================

PushB_OnLava:
		move.w	obX(a0),obPushB_PrevX(a0)	; store pre-movement axis position
		cmpi.b	#4,ob2ndRout(a0)		; is block falling after being pushed?
		bhs.s	.pushing				; if yes, branch if ob2ndRout = 4 or 6 (PushB_Solid_Lava/PushB_Solid_Push)
		bsr.w	SpeedToPos

	.pushing:
		btst	#staAir,obStatus(a0)	; has block been thrown into the air?
		beq.s	PushB_OnLava_ChkWall	; if not, branch
		addi.w	#$18,obVelY(a0)			; apply gravity
		jsr		(ObjFloorDist).l
		tst.w	d1						; has block hit the floor?
		bpl.s	PushB_OnLava_Solid		; if not, branch
		add.w	d1,obY(a0)				; align to floor
		clr.w	obVelY(a0)				; stop falling
		bclr	#staFlipY,obStatus(a0)
		move.w	(a1),d0					; get 16x16 tile the block is on
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0				; is it block $16A+ (lava)?
		blo.s	PushB_OnLava_Solid		; if not, branch
		move.w	obPushB_LavaSpeed(a0),d0
		asr.w	#3,d0
		move.w	d0,obVelX(a0)			; make block float horizontally
		move.b	#1,obPushB_LavaFlag(a0)
		clr.w	obYSub(a0)
		bra.s	PushB_OnLava_Solid
; ===========================================================================

PushB_OnLava_ChkWall:
		tst.w	obVelX(a0)
		beq.w	PushB_OnLava_Sink		; branch if block isn't moving
		bmi.s	.wall_left				; branch if moving left

;	.wall_right:
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		jsr		(ObjHitWallRight).l
		tst.w	d1						; has block touched a wall?
		bmi.s	PushB_StopPush			; if yes, branch
		bra.s	PushB_OnLava_Solid
; ===========================================================================

	.wall_left:
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		not.w	d3
		jsr		(ObjHitWallLeft).l
		tst.w	d1						; has block touched a wall?
		bmi.s	PushB_StopPush			; if yes, branch
		bra.s	PushB_OnLava_Solid
; ===========================================================================

PushB_StopPush:
		clr.w	obVelX(a0)				; stop block moving
		bra.s	PushB_OnLava_Solid
; ===========================================================================

PushB_OnLava_Sink:
		addi.l	#$2001,obY(a0)			; sink in lava, $2001 subpixels each frame
		cmpi.b	#$A0,obYSub+1(a0)		; has block been sinking for 160 frames?
		bhs.s	PushB_OnLava_Sunk		; if yes, branch

PushB_OnLava_Solid:
		moveq	#11,d1
		add.b	obDispWid(a0),d1		; width; save 8 cycles
		moveq	#16,d2					; jumping (jumping); save 4 cycles -- Filter
		moveq	#17,d3					; jumping (walking); save 4 cycles -- Filter
		move.w	obPushB_PrevX(a0),d4	; pre-movement axis position
		bsr.w	PushB_Solid				; make block solid & update its position
		bsr.s	PushB_ChkGeyser
		bra.w	PushB_Display
; ===========================================================================

PushB_OnLava_Sunk:
		move.w	(sp)+,d4
		lea		(v_player).w,a1
		bclr	#staOnObj,obStatus(a1)
		bclr	#staSonicOnObj,obStatus(a0)
		bra.w	PushB_ChkDel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to load lava geysers when the block reaches specific x pos
; ---------------------------------------------------------------------------

PushB_ChkGeyser:
		cmpi.w	#(id_MZ<<8)+1,(v_zone).w	; is the level MZ act 2?
		bne.s	.not_mz2					; if not, branch
		move.w	#-$20,d2					; TO-DO: Can this be moveq?
		cmpi.w	#$DD0,obX(a0)
		beq.s	PushB_LoadLava
		cmpi.w	#$CC0,obX(a0)
		beq.s	PushB_LoadLava
		cmpi.w	#$BA0,obX(a0)
		beq.s	PushB_LoadLava
		rts	
; ===========================================================================

	.not_mz2:
		cmpi.w	#(id_MZ<<8)+2,(v_zone).w	; is the level MZ act 3?
		bne.s	.not_mz3					; if not, branch
		moveq	#$20,d2
		cmpi.w	#$560,obX(a0)
		beq.s	PushB_LoadLava
		cmpi.w	#$5C0,obX(a0)
		beq.s	PushB_LoadLava

	.not_mz3:
		rts	
; ===========================================================================

PushB_LoadLava:
		bsr.w	FindFreeObj
		bne.s	.fail						; branch if object slot not found
		_move.b	#id_GeyserMaker,obID(a1)	; load lava geyser object
		move.w	obX(a0),obX(a1)
		add.w	d2,obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$10,obY(a1)
		move.w	a0,obGeyser_Parent(a1)		; record block OST address as geyser's parent

	.fail:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to make the block solid, update its speed/position when pushed
; or on lava
;
; input:
;	d1 = width
;	d2 = height / 2 (when jumping)
;	d3 = height / 2 (when walking)
;	d4 = x-axis position
; ---------------------------------------------------------------------------

PushB_Solid:
		move.b	ob2ndRout(a0),d0
		beq.w	PushB_Solid_Detect			; branch if ost_routine2 = 0
		subq.b	#2,d0
		bne.s	PushB_Solid_Lava			; branch if ost_routine2 > 2
		bsr.w	ExitPlatform
		btst	#staOnObj,obStatus(a1)
		bne.s	.on_block					; branch if Sonic is on the block
		clr.b	ob2ndRout(a0)
		rts	
; ===========================================================================

	.on_block:
		move.w	d4,d2
		bra.w	MvSonicOnPtfm
; ===========================================================================

PushB_Solid_Lava:
		subq.b	#2,d0
		bne.s	PushB_Solid_Push			; branch if ost_routine2 = 6
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)				; apply gravity
		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.w	.exit						; if not, branch
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop falling
		clr.b	ob2ndRout(a0)				; -> PushB_Solid
		move.w	(a1),d0						; get 16x16 tile the block is on
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0					; is it block $16A+ (lava)?
		blo.s	.exit						; if not, branch
		move.w	obPushB_LavaSpeed(a0),d0
		asr.w	#3,d0
		move.w	d0,obVelX(a0)				; make block float horizontally
		move.b	#1,obPushB_LavaFlag(a0)
		clr.w	obYSub(a0)

	.exit:
		rts	
; ===========================================================================

PushB_Solid_Push:
		bsr.w	SpeedToPos
		move.w	obX(a0),d0
		andi.w	#$C,d0
		bne.s	.locret					; branch if bits 2 or 3 of x pos are set
		andi.w	#$FFF0,obX(a0)						; snap to grid
		move.w	obVelX(a0),obPushB_LavaSpeed(a0)	; set speed to move on lava
		clr.w	obVelX(a0)
		subq.b	#2,ob2ndRout(a0)					; -> PushB_Solid_Lava

	.locret:
		rts
; ===========================================================================

PushB_Solid_Detect:
		bsr.w	Solid_ChkEnter				; make block solid & update flags for interaction
		tst.w	d4
		beq.s	.locret						; branch if no collision
		bmi.s	.chkStand					; branch if top/bottom collision (different from original)
		tst.b	obPushB_LavaFlag(a0)
		beq.s	PushB_Solid_Side			; branch if not on lava

	.locret:
		rts

	.chkStand:
		btst	#staSonicOnObj,obStatus(a0)
		beq.s	.locret
		move.b	#2,ob2ndRout(a0)
		rts
; ===========================================================================

PushB_Solid_Side:
		tst.w	d0							; where is Sonic?
		beq.w	.locret						; if inside the object, branch
		bmi.s	PushB_Solid_Left			; if left of the object, branch
		btst	#staFacing,obStatus(a1)		; is Sonic facing left?
		bne.w	.locret						; if yes, branch
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		jsr		(ObjHitWallRight).l
		move.w	(sp)+,d0
		tst.w	d1							; has object hit right wall?
		bmi.w	.locret						; if not, branch
		addi.l	#$10000,obX(a0)				; move 1px right and clear subpixels
		moveq	#1,d0
		moveq	#$40,d1
		bra.s	PushB_Solid_Side_Sonic

	.locret:
		rts
; ===========================================================================

PushB_Solid_Left:
		btst	#staFacing,obStatus(a1)		; is Sonic facing right?
		beq.s	PushB_Solid_Exit			; if yes, branch
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		not.w	d3
		jsr		(ObjHitWallLeft).l
		move.w	(sp)+,d0
		tst.w	d1							; has object hit left wall?
		bmi.s	PushB_Solid_Exit			; if not, branch
		subi.l	#$10000,obX(a0)				; move 1px left and clear subpixels
		moveq	#-1,d0
		move.w	#-$40,d1

PushB_Solid_Side_Sonic:
		lea		(v_player).w,a1
		add.w	d0,obX(a1)					; + or - 1 to Sonic's x position
		move.w	d1,obInertia(a1)			; + or - $40 to Sonic's inertia
		clr.w	obVelX(a1)
		move.w	d0,-(sp)
		move.w	#sfx_Push,d0
		jsr		(QueueSound2).w				; play pushing sound
		move.w	(sp)+,d0
		tst.b	obSubtype(a0)				; is bit 7 of subtype set? (no gravity flag)
		bmi.s	PushB_Solid_Exit			; if yes, branch
		move.w	d0,-(sp)
		jsr		(ObjFloorDist).l
		move.w	(sp)+,d0
		cmpi.w	#4,d1
		ble.s	.align_floor				; branch if object is within 4px of floor
		move.w	#$400,obVelX(a0)
		tst.w	d0
		bpl.s	.moving_right				; branch if moving right
		neg.w	obVelX(a0)					; move left

	.moving_right:
		move.b	#6,ob2ndRout(a0)			; move block forward to fall down
		rts
; ===========================================================================

	.align_floor:
		add.w	d1,obY(a0)

PushB_Solid_Exit:
		rts	
; ===========================================================================