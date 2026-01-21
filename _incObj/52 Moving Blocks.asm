; ---------------------------------------------------------------------------
; Object 52 - moving platform blocks (MZ, LZ, SBZ)
; ---------------------------------------------------------------------------
; OST Constants
obMBlock_StartX:		equ objoff_30		; 2 bytes | starting X-axis position
obMBlock_StartY:		equ objoff_32		; 2 bytes | starting Y-axis position
obMBlock_WaitTime:		equ objoff_34		; 2 bytes | time delay before moving platform back - subtype x9/xA only
obMBlock_MoveFlag:		equ objoff_36		; 2 bytes | 1 = move platform back to its original position - subtype x9/xA only
obMBlock_PrevX:			equ objoff_38		; 2 bytes | previous X-axis position (used instead of pushing to the stack)
; ---------------------------------------------------------------------------

; ===========================================================================
MBlock_Var:		; object width,	frame number
		dc.b $10, 0			; $0x - single block
		dc.b $20, 1			; $1x - double block (unused)
		dc.b $20, 2			; $2x - SBZ black & yellow platform
		dc.b $40, 3			; $3x - SBZ red horizontal door
		dc.b $30, 4			; $4x - triple block
; ===========================================================================

MovingBlock:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.w	MBlock_Platform
		bpl.w	MBlock_StandOn
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

MBlock_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> MBlock_Platform

		; MZ specific code
		move.l	#Map_MBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_MZ_Block,2,0),obGfx(a0)

		cmpi.b	#id_LZ,(v_zone).w			; check if level is LZ
		bne.s	.not_lz

		; LZ specific code
		move.l	#Map_MBlockLZ,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Moving_Block,2,0),obGfx(a0)
		move.b	#7,obHeight(a0)
		bra.s	.continue

	.not_lz:
		cmpi.b	#id_SBZ,(v_zone).w			; check if level is SBZ
		bne.s	.continue

		; SBZ specific code
		move.w	#make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0),obGfx(a0) ; SBZ specific code (subtype $28)
		cmpi.b	#$28,obSubtype(a0)			; is sybtype == $28?
		beq.s	.continue					; if yes, branch
		move.w	#make_art_tile(ArtTile_SBZ_Moving_Block_Long,2,0),obGfx(a0) ; SBZ specific code (sybtype $3x)

	.continue:
		move.b	#4,obRender(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$1E,d0						; read only high nybble of subtype
		lea		MBlock_Var(pc,d0.w),a2
		move.b	(a2)+,obDispWid(a0)
		move.b	(a2)+,obFrame(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),obMBlock_StartX(a0)
		move.w	obY(a0),obMBlock_StartY(a0)
		andi.b	#$F,obSubtype(a0)			; clear high nybble of subtype
; ---------------------------------------------------------------------------

MBlock_Platform: ; Routine 2
		bsr.w	MBlock_Move					; move & update position
		moveq	#0,d1
		move.b	obDispWid(a0),d1			; width
		jsr		(PlatformObject).l			; check for collision & goto MBlock_StandOn next if stood on
		bra.s	MBlock_ChkDel
; ===========================================================================

MBlock_StandOn:	; Routine 4
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		jsr		(ExitPlatform).l
	; FixBugs: MBlock_Move manipulates the stack pointer, potentially
	; resulting in a crash. To avoid this, don't store data on
	; the stack. We can use object scratch RAM instead.
		move.w	obX(a0),obMBlock_PrevX(a0)
		bsr.w	MBlock_Move
	; FixBugs: See above
		move.w	obMBlock_PrevX(a0),d2
		jsr		(MvSonicOnPtfm2).l

MBlock_ChkDel:
		offscreen.w	DeleteObject,obMBlock_StartX(a0)	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================

MBlock_Move:
		moveq	#$F,d0						; get last digit of subtype
		and.b	obSubtype(a0),d0			; SCE optimization
		beq.s	MBlock_Type00				; skip if subtype 00
		add.w	d0,d0
		move.w	MBlock_Index-2(pc,d0.w),d1
		jmp		MBlock_Index(pc,d1.w)
; ===========================================================================

MBlock_Index:	offsetTable
		offsetTableEntry.w	MBlock_LeftRight			; 1 - moves side to side
		offsetTableEntry.w	MBlock_Right				; 2 - moves right when stood on, stops at wall
		offsetTableEntry.w	MBlock_Right_Now			; 3 - moves right immediately, stops at wall
		offsetTableEntry.w	MBlock_RightDrop			; 4 - moves right when stood on, stops at wall and drops
		offsetTableEntry.w	MBlock_RightDrop_Now		; 5 - moves right immediately, stops at wall and drops
		offsetTableEntry.w	MBlock_Drop_Now				; 6 - drops immediately
		offsetTableEntry.w	MBlock_RightDrop_Button		; 7 - appears when button 2 is pressed; moves right when stood on, stops at wall and drops
		offsetTableEntry.w	MBlock_UpDown				; 8 - moves up and down
		offsetTableEntry.w	MBlock_Slide				; 9 - quickly slides right when stood on
		offsetTableEntry.w	MBlock_Slide_Now			; $A - slides right immediately
; ===========================================================================

; Type 01 - moves side to side
MBlock_LeftRight:
		move.b	(v_oscillate+$E).w,d0
		moveq	#$60,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	loc_FF26
		neg.w	d0
		add.w	d1,d0

loc_FF26:
		move.w	obMBlock_StartX(a0),d1
		sub.w	d0,d1
		move.w	d1,obX(a0)
; ---------------------------------------------------------------------------

; Type 00 - doesn't move
MBlock_Type00:
		rts	
; ===========================================================================

MBlock_Right:		; Type 02 - moves right when stood on, stops at wall
MBlock_RightDrop:	; Type 04 - moves right when stood on, stops at wall and drops
MBlock_Slide:		; Type 09 - quickly slides right when stood on
		cmpi.b	#4,obRoutine(a0)				; is Sonic standing on the platform?
		bne.s	.wait
		addq.b	#1,obSubtype(a0)				; if yes, add 1 to type

	.wait:
		rts	
; ===========================================================================

; Type 03 - moves right immediately, stops at wall
MBlock_Right_Now:
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1								; has the platform hit a wall?
		bmi.s	.hit_wall						; if yes, branch
		addq.w	#1,obX(a0)						; move platform	to the right
		move.w	obX(a0),obMBlock_StartX(a0)
		rts	
; ===========================================================================

	.hit_wall:
		clr.b	obSubtype(a0)					; change to type 00 (non-moving	type)
		rts	
; ===========================================================================

; Type 05 - moves right immediately, stops at wall and drops
MBlock_RightDrop_Now:
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1								; has the platform hit a wall?
		bmi.s	.hit_wall						; if yes, branch
		addq.w	#1,obX(a0)						; move platform	to the right
		move.w	obX(a0),obMBlock_StartX(a0)
		rts	
; ===========================================================================

	.hit_wall:
		addq.b	#1,obSubtype(a0)				; change to type 06 (falling)
		rts	
; ===========================================================================

; Type 06 - drops immediately
MBlock_Drop_Now:
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)					; make the platform fall
		bsr.w	ObjFloorDist
		tst.w	d1								; has platform hit the floor?
		bpl.w	.keep_falling					; if not, branch
		add.w	d1,obY(a0)						; align to floor
		clr.w	obVelY(a0)						; stop platform	falling
		clr.b	obSubtype(a0)					; change to type 00 (non-moving)

	.keep_falling:
		rts	
; ===========================================================================

; Type 07 - appears when button 2 is pressed; moves right when stood on, stops at wall and drops
MBlock_RightDrop_Button:
		tst.b	(f_switch+2).w					; has switch button number 02 been pressed?
		beq.s	.not_pressed
		subq.b	#3,obSubtype(a0)				; if yes, change object type to 04

	.not_pressed:
		; This line, combined with the coordinate being pushed to
		; the stack in MBlock_StandOn, could have been (potentially) disasterous.
		addq.l	#4,sp

		out_of_range.w	DeleteObject,obMBlock_StartX(a0)
		rts	
; ===========================================================================

; Type 08 - moves up and down
MBlock_UpDown:
		move.b	(v_oscillate+$1E).w,d0
		move.w	#$80,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		neg.w	d0								; reverse vertical direction if xflip bit is set
		add.w	d1,d0

	.no_xflip:
		move.w	obMBlock_StartY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

; Type 0A - slides right immediately
MBlock_Slide_Now:
		moveq	#0,d3
		move.b	obDispWid(a0),d3
		add.w	d3,d3
		moveq	#8,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		neg.w	d1
		neg.w	d3

	.no_xflip:
		tst.w	obMBlock_MoveFlag(a0)			; is platform set to move back?
		bne.s	.move_back						; if yes, branch
		move.w	obX(a0),d0
		sub.w	obMBlock_StartX(a0),d0
		cmp.w	d3,d0
		beq.s	.wait
		add.w	d1,obX(a0)						; move platform
		move.w	#300,obMBlock_WaitTime(a0)		; set time delay to 5 seconds
		rts	
; ===========================================================================

	.wait:
		subq.w	#1,obMBlock_WaitTime(a0)		; subtract 1 from time delay
		bne.s	.time_remains					; if time remains, branch
		move.w	#1,obMBlock_MoveFlag(a0)		; set platform to move back to its original position

	.time_remains:
		rts	
; ===========================================================================

	.move_back:
		move.w	obX(a0),d0
		sub.w	obMBlock_StartX(a0),d0
		beq.s	.reset
		sub.w	d1,obX(a0)						; return platform to its original position
		rts	
; ===========================================================================

	.reset:
		clr.w	obMBlock_MoveFlag(a0)
		subq.b	#1,obSubtype(a0)				; restore subtype to 9
		rts	
; ===========================================================================