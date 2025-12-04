; ---------------------------------------------------------------------------
; Object 31 - stomping metal blocks on chains (MZ)
; ---------------------------------------------------------------------------

ChainStomp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	CStom_Index(pc,d0.w),d1
		jmp		CStom_Index(pc,d1.w)
; ===========================================================================
CStom_Index:	offsetTable
		offsetTableEntry.w CStom_Main
		offsetTableEntry.w CStom_Block
		offsetTableEntry.w CStom_Spikes
		offsetTableEntry.w CStom_Ceiling
		offsetTableEntry.w CStom_Chain

CStom_SwchNums:
		dc.b 0,	0		; switch number, obj number
		dc.b 1,	0

CStom_Var:
		dc.b 2,	0, 0		; routine number, y-position, frame number
		dc.b 4,	$1C, 1
		dc.b 8,	$CC, 3
		dc.b 6,	$F0, 2

CStom_Lengths:
		dc.w $7000
		dc.w $A000
		dc.w $5000
		dc.w $7800
		dc.w $3800
		dc.w $5800
		dc.w $B800
; ===========================================================================

CStom_Main:	; Routine 0
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype
		bpl.s	.positive					; branch if 0-$7F
		andi.w	#$7F,d0
		add.w	d0,d0
		lea		CStom_SwchNums(pc,d0.w),a2
		move.b	(a2)+,obCStom_SwitchID(a0)	; get switch number
		move.b	(a2)+,d0					; get replacement subtype
		move.b	d0,obSubtype(a0)

	.positive:
		andi.b	#$F,d0						; read low nybble of subtype
		add.w	d0,d0
		move.w	CStom_Lengths(pc,d0.w),d2	; get length
		tst.w	d0
		bne.s	.not_0						; branch if subtype isn't 0
		move.w	d2,obCStom_ChainLength(a0)

	.not_0:
		lea		(CStom_Var).l,a2
		movea.l	a0,a1						; first object is parent (block)
		moveq	#3,d1						; 3 additional objects (chain, spikes, ceiling)
		bra.s	CStom_MakeStomper
; ===========================================================================

CStom_Loop:
		bsr.w	FindNextFreeObj
		bne.w	CStom_SetSize				; branch if object RAM slot not found

CStom_MakeStomper:
		move.b	(a2)+,obRoutine(a1)			; goto CStom_Block/CStom_Spikes/CStom_Chain/CStom_Ceiling next
		_move.b	#id_ChainStomp,obID(a1)
		move.w	obX(a0),obX(a1)
		move.b	(a2)+,d0					; get relative y position
		ext.w	d0
		add.w	obY(a0),d0					; add to initial y position
		move.w	d0,obY(a1)
		move.l	#Map_CStom,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Spike_Stomper,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	obY(a1),obCStom_StartY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.b	#$10,obDispWid(a1)
		move.w	d2,obCStom_ChainMax(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	(a2)+,obFrame(a1)
		cmpi.b	#1,obFrame(a1)				; is the spikes component being loaded?
		bne.s	.not_spikes					; if not, branch
		subq.w	#1,d1
		move.b	obSubtype(a0),d0
		andi.w	#$F0,d0						; read high nybble of subtype
		cmpi.w	#$20,d0						; is subtype $2x (no spikes)?
		beq.s	CStom_MakeStomper			; if yes, branch
		move.b	#$38,obDispWid(a1)
		move.b	#(colHarmful|colSz_40x16),obColType(a1) ; make spikes harmful (not solid)
		addq.w	#1,d1

	.not_spikes:
		move.w	a0,obCStom_Parent(a1)
		dbf		d1,CStom_Loop

		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

CStom_SetSize:
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype
		lsr.w	#3,d0
		andi.b	#$E,d0						; read only high nybble
		lea		CStom_Var2(pc,d0.w),a2
		move.b	(a2)+,obDispWid(a0)
		move.b	(a2)+,obFrame(a0)
		bra.s	CStom_Block
; ===========================================================================
CStom_Var2:
		dc.b $38, 0		; width, frame number
		dc.b $30, 9
		dc.b $10, $A
; ===========================================================================

CStom_Block:	; Routine 2
		bsr.w	CStom_Types
		move.w	obY(a0),(v_obj31ypos).w			; store y position for pushable green block interaction
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		addi.w	#$B,d1
		move.w	#$C,d2
		move.w	#$D,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#staSonicOnObj,obStatus(a0)		; is Sonic standing on it?
		beq.s	.chkdel							; if not, branch
		cmpi.b	#$10,obCStom_ChainLength(a0)	; is chain longer than $10?
		bhs.s	.chkdel							; if yes, branch
		movea.l	a0,a2
		lea		(v_player).w,a0
		jsr		(KillSonic).l					; Sonic gets crushed against ceiling
		movea.l	a2,a0

	.chkdel:
		offscreen.w	DeleteObject				; ProjectFM S3K Objects Manager
		bra.w	DisplayAndCollision				; S3K TouchResponse; Clownacy DisplaySprites Fix
; ===========================================================================

CStom_Chain:	; Routine 8
		move.b	#$80,obHeight(a0)
		bset	#4,obRender(a0)
		movea.w	obCStom_Parent(a0),a1			; get address of parent object
		move.b	obCStom_ChainLength(a1),d0		; get current chain length
		lsr.b	#5,d0							; divide by $20
		addq.b	#3,d0							; convert to frame number
		move.b	d0,obFrame(a0)					; update frame

CStom_Spikes:	; Routine 4
		movea.w	obCStom_Parent(a0),a1
		moveq	#0,d0
		move.b	obCStom_ChainLength(a1),d0
		add.w	obCStom_StartY(a0),d0
		move.w	d0,obY(a0)						; update y position (chain and spikes)

CStom_Ceiling:	; Routine 6 (Replaced CStom_Display2 as that became a fallthrough)
		offscreen.w	DeleteObject				; ProjectFM S3K Objects Manager
		bra.w	DisplayAndCollision				; S3K TouchResponse; Clownacy DisplaySprites Fix
; ===========================================================================

CStom_Types:
		moveq	#$F,d0
		and.b	obSubtype(a0),d0				; read low nybble of subtype; SCE Optimization
		add.w	d0,d0							; (for button-controlled stompers this will have changed to 0)
		move.w	CStom_TypeIndex(pc,d0.w),d1
		jmp		CStom_TypeIndex(pc,d1.w)
; ===========================================================================

CStom_TypeIndex:	offsetTable
		offsetTableEntry.w CStom_Type00
		offsetTableEntry.w CStom_Type01
		offsetTableEntry.w CStom_Type01
		offsetTableEntry.w CStom_Type03
		offsetTableEntry.w CStom_Type01
		offsetTableEntry.w CStom_Type03			; unused
		offsetTableEntry.w CStom_Type01			; unused
; ===========================================================================

; Type 0 - rises when button is pressed
CStom_Type00:
		lea		(f_switch).w,a2					; load switch statuses
		moveq	#0,d0
		move.b	obCStom_SwitchID(a0),d0			; move number 0 or 1 to d0
		tst.b	(a2,d0.w)						; has switch (d0) been pressed?
		beq.s	CStom_Type00_Fall				; if not, branch
		tst.w	(v_obj31ypos).w					; is stomper below the top edge of the level?
		bpl.s	.within_boundary				; is yes, branch
		cmpi.b	#$10,obCStom_ChainLength(a0)	; is chain at its shortest?
		beq.s	.stop							; if yes, branch

	.within_boundary:
		tst.w	obCStom_ChainLength(a0)
		beq.s	.stop
		moveq	#$F,d0
		and.b	(v_vbla_byte).w,d0				; read low nybble of byte that increments every frame						; 
		bne.s	.skip_sound						; branch if not 0
		tst.b	obRender(a0)
		bpl.s	.skip_sound
		move.w	#sfx_ChainRise,d0
		jsr		(QueueSound2).w					; play rising chain sound

	.skip_sound:
		subi.w	#$80,obCStom_ChainLength(a0)	; shorten chain
		bcc.s	CStom_SetPos					; branch if positive
		clr.w	obCStom_ChainLength(a0)

	.stop:
		clr.w	obVelY(a0)						; stop stomper rising
		bra.s	CStom_SetPos
; ===========================================================================

CStom_Type00_Fall:
		move.w	obCStom_ChainMax(a0),d1
		cmp.w	obCStom_ChainLength(a0),d1		; is chain at its maximum?
		beq.s	CStom_SetPos					; if yes, branch

		move.w	obVelY(a0),d0
		addi.w	#$70,obVelY(a0)					; make object fall
		add.w	d0,obCStom_ChainLength(a0)
		cmp.w	obCStom_ChainLength(a0),d1
		bhi.s	CStom_SetPos
		move.w	d1,obCStom_ChainLength(a0)
		clr.w	obVelY(a0)						; stop object falling
		tst.b	obRender(a0)
		bpl.s	CStom_SetPos
		move.w	#sfx_ChainStomp,d0
		jsr		(QueueSound2).w					; play stomping sound

CStom_SetPos:
		moveq	#0,d0
		move.b	obCStom_ChainLength(a0),d0
		add.w	obCStom_StartY(a0),d0			; d0 = initial y pos + chain length
		move.w	d0,obY(a0)						; update position
		rts	
; ===========================================================================

; Type 1/2 - alternately rises and drops
CStom_Type01:
		tst.w	obCStom_RiseFlag(a0)			; is stomper falling?
		beq.s	CStom_Type01_Fall				; if yes, branch
		tst.w	obCStom_DelayTime(a0)
		beq.s	CStom_Type01_Rise				; branch if timer = 0
		subq.w	#1,obCStom_DelayTime(a0)		; decrement timer
		bra.s	CStom_SetPos
; ===========================================================================

CStom_Type01_Rise:
		moveq	#$F,d0
		and.b	(v_vbla_byte).w,d0
		bne.s	.skip_sound
		tst.b	obRender(a0)					; is object onscreen?
		bpl.s	.skip_sound						; if not, branch
		move.w	#sfx_ChainRise,d0
		jsr		(QueueSound2).w					; play rising chain sound every 16 frames

.skip_sound:
		subi.w	#$80,obCStom_ChainLength(a0)
		bcc.s	CStom_SetPos
		clr.w	obCStom_ChainLength(a0)
		clr.w	obVelY(a0)
		clr.w	obCStom_RiseFlag(a0)
		bra.s	CStom_SetPos
; ===========================================================================

CStom_Type01_Fall:
		move.w	obCStom_ChainMax(a0),d1
		cmp.w	obCStom_ChainLength(a0),d1
		beq.s	CStom_SetPos
		move.w	obVelY(a0),d0
		addi.w	#$70,obVelY(a0)					; make object fall
		add.w	d0,obCStom_ChainLength(a0)
		cmp.w	obCStom_ChainLength(a0),d1
		bhi.s	CStom_SetPos
		move.w	d1,obCStom_ChainLength(a0)
		clr.w	obVelY(a0)						; stop object falling
		move.w	#1,obCStom_RiseFlag(a0)
		move.w	#$3C,obCStom_DelayTime(a0)
		tst.b	obRender(a0)
		bpl.w	CStom_SetPos
		move.w	#sfx_ChainStomp,d0
		jsr		(QueueSound2).w					; play stomping sound
		bra.w	CStom_SetPos
; ===========================================================================

; Type 3 - drops when Sonic is nearby
CStom_Type03:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.sonic_is_right					; branch if Sonic is to the right
		neg.w	d0								; d0 = distance between Sonic & stomper

.sonic_is_right:
		cmpi.w	#144,d0							; is Sonic within 144px?
		bhs.w	CStom_SetPos					; if over 144px, branch
		addq.b	#1,obSubtype(a0)				; allow stomper to drop by changing subtype
		bra.w	CStom_SetPos
; ===========================================================================