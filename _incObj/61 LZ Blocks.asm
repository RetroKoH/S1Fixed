; ---------------------------------------------------------------------------
; Object 61 - blocks (LZ)
; rising platforms and corks are split into their own objects
; ---------------------------------------------------------------------------

LabyrinthBlock:
		_move.l	#LBlk_Action,obAddr(a0)
		move.l	#Map_LBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Blocks,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)						; set width
		move.b	#$10,obHeight(a0)						; set height
		move.w	obY(a0),obLBlock_StartY(a0)
		tst.b	obSubtype(a0)							; is this a sinking block?
		beq.s	LBlk_Action								; if not, branch
		move.b	#1,obFrame(a0)							; set frame for the sinking block
		move.b	#1,obLBlock_Flag(a0)					; set "untouched" flag
; ---------------------------------------------------------------------------

LBlk_Action:	; Routine 2
		moveq	#$F,d0									; get last digit of subtype
		and.b	obSubtype(a0),d0						; SCE optimization
		beq.s	.solid									; skip if subtype 00
		add.w	d0,d0
		move.w	LBlk_Type_Index-2(pc,d0.w),d1
		jsr		LBlk_Type_Index(pc,d1.w)
; ---------------------------------------------------------------------------

	.solid:
		tst.b	obRender(a0)							; is block on-screen?
		bpl.s	.chkdel									; if not, branch
		moveq	#27,d1									; width
		moveq	#16,d2									; height (jumping)
		moveq	#17,d3									; height (walking)
		move.w	obX(a0),d4								; axis position
		bsr.w	SolidObject
		move.b	d4,obLBlock_ColFlag(a0)
		bsr.w	LBlk_Sink

	.chkdel:
		offscreen.w	DeleteObject						; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================

LBlk_Type_Index:	offsetTable
		offsetTableEntry.w	LBlk_Type_Sinks
		offsetTableEntry.w	LBlk_Type_Sinks_Side		; unused
		offsetTableEntry.w	LBlk_Type_Sinks_Now
		offsetTableEntry.w	LBlk_Type_Sinks_Side_Now
; ===========================================================================

; Type 1 - sinks or rises when stood on
LBlk_Type_Sinks:
		tst.w	obLBlock_WaitTime(a0)					; does time remain?
		bne.s	.wait									; if yes, branch
		btst	#staSonicOnObj,obStatus(a0)				; is Sonic standing on the object?
		beq.s	.donothing								; if not, branch
		move.w	#30,obLBlock_WaitTime(a0)				; wait for half second

	.donothing:
		rts	
; ===========================================================================

	.wait:
		subq.w	#1,obLBlock_WaitTime(a0)				; decrement waiting time
		bne.s	.donothing								; if time remains, branch
		addq.b	#2,obSubtype(a0)						; goto LBlk_Type_Sinks_Now or LBlk_Type_Rises_Now
		clr.b	obLBlock_Flag(a0)						; flag block as touched
		rts	
; ===========================================================================

; Type 3/4 - sinks until it hits the floor
LBlk_Type_Sinks_Now:
LBlk_Type_Sinks_Side_Now:
		bsr.w	SpeedToPos_YOnly
		addq.w	#8,obVelY(a0)							; make block fall
		bsr.w	ObjFloorDist
		tst.w	d1										; has block hit the floor?
		bpl.w	.nofloor								; if not, branch
		addq.w	#1,d1
		add.w	d1,obY(a0)								; align to floor
		clr.w	obVelY(a0)								; stop when it touches the floor
		clr.b	obSubtype(a0)							; set type to 00 (non-moving type)

	.nofloor:
		rts	
; ===========================================================================

; Type 2 - sinks when touched from the side (unused)
LBlk_Type_Sinks_Side:
		cmpi.b	#1,obLBlock_ColFlag(a0)					; is Sonic touching the	block?
		bne.s	.notouch								; if not, branch
		addq.b	#2,obSubtype(a0)						; -> LBlk_Type_Sinks_Side_Now
		clr.b	obLBlock_Flag(a0)						; flag block as touched

	.notouch:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to sink block slightly when stood on
; Used by this object, and the Rising Platform
; ---------------------------------------------------------------------------

LBlk_Sink:
		tst.b	obLBlock_Flag(a0)						; has block been stood on or touched?
		beq.s	.exit									; if yes, branch
		btst	#staSonicOnObj,obStatus(a0)				; is Sonic standing on it now?
		bne.s	.standing_on							; if yes, branch
		tst.b	obLBlock_SinkPixels(a0)					; is block in default position?
		beq.s	.exit									; if yes, branch
		subq.b	#4,obLBlock_SinkPixels(a0)				; incrementally return block to default
		bra.s	.update_y
; ===========================================================================

	.standing_on:
		cmpi.b	#$40,obLBlock_SinkPixels(a0)			; is block at maximum sink?
		beq.s	.exit									; if yes, branch
		addq.b	#4,obLBlock_SinkPixels(a0)				; keep sinking

	.update_y:
		move.b	obLBlock_SinkPixels(a0),d0
		jsr		(CalcSine).w							; convert sink value to sine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	obLBlock_StartY(a0),d0
		move.w	d0,obY(a0)								; update position

	.exit:
		rts	
; ===========================================================================