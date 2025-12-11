; ---------------------------------------------------------------------------
; Object 61 - blocks (LZ)
; ---------------------------------------------------------------------------

; ===========================================================================

LBlk_Var:
		; width, height
		dc.b $10, $10					; $0x
		dc.b $20, $C					; $1x
		dc.b $10, $10					; $2x
		dc.b $10, $10					; $3x
; ===========================================================================

LabyrinthBlock:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	LBlk_Action
	; Object Routine Optimization End

LBlk_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)						; -> LBlk_Action
		move.l	#Map_LBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Blocks,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		moveq	#0,d0
		move.b	obSubtype(a0),d0						; get block type
		lsr.w	#3,d0									; read only the 1st digit
		andi.w	#$E,d0
		lea		LBlk_Var(pc,d0.w),a2
		move.b	(a2)+,obDispWid(a0)						; set width
		move.b	(a2),obHeight(a0)						; set height
		lsr.w	#1,d0
		move.b	d0,obFrame(a0)
		move.w	obX(a0),obLBlock_StartX(a0)
		move.w	obY(a0),obLBlock_StartY(a0)
		move.b	obSubtype(a0),d0						; get block type
		andi.b	#$F,d0									; read only the 2nd digit
		beq.s	LBlk_Action								; branch if 0
		cmpi.b	#7,d0
		beq.s	LBlk_Action								; branch if 7 (floats on water)
		move.b	#1,obLBlock_Flag(a0)					; for types 1/3, set "untouched" flag
; ---------------------------------------------------------------------------

LBlk_Action:	; Routine 2
		move.w	obX(a0),obLBlock_PrevX(a0)				; store current pre-movement x-position
	;(it does this next part EVERY frame. Can we optimize this?)
		moveq	#$F,d0									; get last digit of subtype
		and.b	obSubtype(a0),d0						; SCE optimization
		beq.s	.solid									; skip if subtype 00
		add.w	d0,d0
		move.w	LBlk_Type_Index-2(pc,d0.w),d1
		jsr		LBlk_Type_Index(pc,d1.w)
; ---------------------------------------------------------------------------

	.solid:
		move.w	obLBlock_PrevX(a0),d4					; restore pre-movement axis position
		tst.b	obRender(a0)							; is block on-screen?
		bpl.s	.chkdel									; if not, branch
		moveq	#11,d1
		add.b	obDispWid(a0),d1						; width; save 8 cycles
		moveq	#0,d2
		move.b	obHeight(a0),d2							; height (jumping)
		move.w	d2,d3
		addq.w	#1,d3									; height (walking)
		bsr.w	SolidObject
		move.b	d4,obLBlock_ColFlag(a0)
		bsr.w	LBlk_Sink

	.chkdel:
		offscreen.w	DeleteObject,obLBlock_StartX(a0)	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================

LBlk_Type_Index:	offsetTable
		offsetTableEntry.w	LBlk_Type_Sinks
		offsetTableEntry.w	LBlk_Type_Sinks_Now
		offsetTableEntry.w	LBlk_Type_Rises
		offsetTableEntry.w	LBlk_Type_Rises_Now
		offsetTableEntry.w	LBlk_Type_Sinks_Side		; unused
		offsetTableEntry.w	LBlk_Type_Sinks_Side_Now
		offsetTableEntry.w	LBlk_Type_Floats
; ===========================================================================

; Type 1/3 - sinks or rises when stood on
LBlk_Type_Sinks:
LBlk_Type_Rises:
		tst.w	obLBlock_WaitTime(a0)					; does time remain?
		bne.s	.wait01									; if yes, branch
		btst	#staSonicOnObj,obStatus(a0)				; is Sonic standing on the object?
		beq.s	.donothing01							; if not, branch
		move.w	#30,obLBlock_WaitTime(a0)				; wait for half second

	.donothing01:
		rts	
; ===========================================================================

	.wait01:
		subq.w	#1,obLBlock_WaitTime(a0)				; decrement waiting time
		bne.s	.donothing01							; if time remains, branch
		addq.b	#1,obSubtype(a0)						; goto LBlk_Type_Sinks_Now or LBlk_Type_Rises_Now
		clr.b	obLBlock_Flag(a0)						; flag block as touched
		rts	
; ===========================================================================

; Type 2/6 - sinks until it hits the floor
LBlk_Type_Sinks_Now:
LBlk_Type_Sinks_Side_Now:
		bsr.w	SpeedToPos_YOnly
		addq.w	#8,obVelY(a0)							; make block fall
		bsr.w	ObjFloorDist
		tst.w	d1										; has block hit the floor?
		bpl.w	.nofloor02								; if not, branch
		addq.w	#1,d1
		add.w	d1,obY(a0)								; align to floor
		clr.w	obVelY(a0)								; stop when it touches the floor
		clr.b	obSubtype(a0)							; set type to 00 (non-moving type)

	.nofloor02:
		rts	
; ===========================================================================

; Type 4 - rises until it hits the ceiling
LBlk_Type_Rises_Now:
	; !!! Devon Note: Placing this object within Fully Solid tiles breaks this
	; object. See SBZ3 Lower right section after the water tunnel.
	; Make sure to place within Top-Solid tiles if placing in the ground as
	; a trap. Consult Clownacy to see if the Top-Solid tiles were a One-28 error.
		bsr.w	SpeedToPos_YOnly
		
	if LimitLZBlockRisingSpeed	; Mercury Limit LZ Block Rising Speed
		cmpi.w	#-$200,obVelY(a0)
		beq.s	.attopspeed
		subq.w	#8,obVelY(a0)							; make block rise
		
	.attopspeed:
	else
		subq.w	#8,obVelY(a0)							; make block rise
	endif	; Limit LZ Block Rising Speed End
		
		bsr.w	ObjHitCeiling
		tst.w	d1										; has block hit the ceiling?
		bpl.w	.noceiling04							; if not, branch
		sub.w	d1,obY(a0)								; align to ceiling
		clr.w	obVelY(a0)								; stop when it touches the ceiling
		clr.b	obSubtype(a0)							; set type to 00 (non-moving type)

	.noceiling04:
		rts	
; ===========================================================================

; Type 5 - sinks when touched from the side (unused)
LBlk_Type_Sinks_Side:
		cmpi.b	#1,obLBlock_ColFlag(a0)					; is Sonic touching the	block?
		bne.s	.notouch05								; if not, branch
		addq.b	#1,obSubtype(a0)						; -> LBlk_Type_Sinks_Side_Now
		clr.b	obLBlock_Flag(a0)						; flag block as touched

	.notouch05:
		rts	
; ===========================================================================

; Type 7 - floats on top of water
LBlk_Type_Floats:
		move.w	(v_waterpos_actual).w,d0
		sub.w	obY(a0),d0								; is block level with water?
		beq.s	.stop07									; if yes, branch
		bcc.s	.fall07									; branch if block is above water
		cmpi.w	#-2,d0									; is block within 2 pixels of water surface?
		bge.s	.near_surface							; if yes, branch
		moveq	#-2,d0									; set maximum rate for block rising

	.near_surface:
		add.w	d0,obY(a0)								; make the block rise with water level
		bsr.w	ObjHitCeiling
		tst.w	d1										; has block hit the ceiling?
		bpl.w	.noceiling07							; if not, branch
		sub.w	d1,obY(a0)								; stop block

	.noceiling07:
		rts	
; ===========================================================================

	.fall07:
		cmpi.w	#2,d0									; is block within 2 pixels of water surface?
		ble.s	.near_surface2							; if yes, branch
		moveq	#2,d0									; set maximum rate for block sinking

	.near_surface2:
		add.w	d0,obY(a0)								; make the block sink with water level
		bsr.w	ObjFloorDist
		tst.w	d1										; has block hit the floor?
		bpl.w	.stop07									; if not, branch
		addq.w	#1,d1
		add.w	d1,obY(a0)								; stop block

	.stop07:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to sink block slightly when stood on
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