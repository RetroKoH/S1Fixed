; ---------------------------------------------------------------------------
; Object 30 - large green glass blocks (MZ)
; ---------------------------------------------------------------------------
; OST Constants
obGlass_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obGlass_DistY:			equ objoff_32		; 2 bytes | distance block moves when switch is pressed
obGlass_MoveMode:		equ objoff_34		; 1 byte  | 1 when block moves after switch is pressed
obGlass_JumpInit:		equ objoff_35		; 1 byte  | 1 when block has been jumped on at least once
obGlass_SinkDist:		equ objoff_36		; 2 bytes | distance to make block sink when jumped on (unused type 3 block)
obGlass_SinkDelay:		equ objoff_38		; 1 byte  | time to delay block sinking
obGlass_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

GlassBlock:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Glass_Index(pc,d0.w),d1
		jsr		Glass_Index(pc,d1.w)
		offscreen.w	DeleteObject	; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite
; ===========================================================================

Glass_Index:	offsetTable
		offsetTableEntry.w Glass_Main
		offsetTableEntry.w Glass_Block012
		offsetTableEntry.w Glass_Reflect012
		offsetTableEntry.w Glass_Block34
		offsetTableEntry.w Glass_Reflect34

Glass_Vars1:
	; routine num, y-axis dist from	origin,	frame num
		dc.b 2,	0, 0
		dc.b 4,	0, 1
Glass_Vars2:
		dc.b 6,	0, 2
		dc.b 8,	0, 1
; ===========================================================================

Glass_Main:	; Routine 0
		lea		(Glass_Vars1).l,a2
		moveq	#1,d1
		move.b	#$48,obHeight(a0)
		cmpi.b	#3,obSubtype(a0)	; is object type 0/1/2 ?
		blo.s	.type012			; if yes, branch

		lea		(Glass_Vars2).l,a2
		moveq	#1,d1
		move.b	#$38,obHeight(a0)

	.type012:
		movea.l	a0,a1
		bra.s	.load				; load main object
; ===========================================================================

	.repeat:
		bsr.w	FindNextFreeObj
		bne.s	.Fail

	.load:
		move.b	(a2)+,obRoutine(a1)
		_move.l	#GlassBlock,obAddr(a1)
		move.w	obX(a0),obX(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obY(a0),d0
		move.w	d0,obY(a1)
		move.l	#Map_Glass,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Glass_Pillar,2,1),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	obY(a1),obGlass_StartY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.b	#$20,obDispWid(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	(a2)+,obFrame(a1)
		move.w	a0,obGlass_Parent(a1)
		dbf		d1,.repeat					; repeat once to load "reflection object"

		move.b	#$10,obDispWid(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		addq.b	#8,obSubtype(a1)
		andi.b	#$F,obSubtype(a1)

	.Fail:
		move.w	#$90,obGlass_DistY(a0)
		bset	#renUseHeight,obRender(a0)	; set height flag, as this is a larger object
; ---------------------------------------------------------------------------

Glass_Block012:	; Routine 2
		bsr.w	Glass_Types				; update position
		moveq	#43,d1					; width; save 4 cycles -- Filter
		moveq	#72,d2					; height (jumping); save 4 cycles -- Filter
		moveq	#73,d3					; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4				; axis position
		bra.w	SolidObject
; ===========================================================================

Glass_Reflect012:
		; Routine 4
		movea.w	obGlass_Parent(a0),a1
		move.w	obGlass_DistY(a1),obGlass_DistY(a0)
		bra.w	Glass_Types				; update position
; ===========================================================================

Glass_Block34:	; Routine 6
		bsr.w	Glass_Types				; update position
		moveq	#43,d1					; width; save 4 cycles -- Filter
		moveq	#56,d2					; height (jumping); save 4 cycles -- Filter
		moveq	#57,d3					; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4				; axis position
		bra.w	SolidObject
; ===========================================================================

Glass_Reflect34:
		; Routine 8
		movea.w	obGlass_Parent(a0),a1
		move.w	obGlass_DistY(a1),obGlass_DistY(a0)
		move.w	obY(a1),obGlass_StartY(a0)
		bra.w	Glass_Types				; update position
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update block position
; ---------------------------------------------------------------------------

Glass_Types:
		moveq	#7,d0
		and.b	obSubtype(a0),d0
		beq.s	Glass_Still				; skip if subtype 00
		add.w	d0,d0
		move.w	Glass_TypeIndex-2(pc,d0.w),d1
		jmp		Glass_TypeIndex(pc,d1.w)
; End of function Glass_Types
; ===========================================================================

Glass_TypeIndex:	offsetTable
		offsetTableEntry.w Glass_UpDown			; Type 1 - moves up and down
		offsetTableEntry.w Glass_UpDown_Rev		; Type 2 - moves up and down, reversed
		offsetTableEntry.w Glass_Drop_Jump		; Type 3 - drops each time it's jumped on
		offsetTableEntry.w Glass_Drop_Button	; Type 4 - drops when button is pressed
; ===========================================================================

; Type 0 - doesn't move
Glass_Still:
		rts	
; ===========================================================================

; Type 1 - moves up and down
Glass_UpDown:
		move.b	(v_oscillate+$12).w,d0
		moveq	#$40,d1
		bra.s	Glass_UpDown_Reflect
; ===========================================================================

; Type 2 - moves up and down, reversed
Glass_UpDown_Rev:
		move.b	(v_oscillate+$12).w,d0
		moveq	#$40,d1
		neg.w	d0					; reverse direction of movement
		add.w	d1,d0

Glass_UpDown_Reflect:
		btst	#3,obSubtype(a0)	; is object a reflection?
		beq.w	Glass_Move			; if not, branch
		neg.w	d0
		add.w	d1,d0
		lsr.b	#1,d0				; divide by 2
		addi.w	#32,d0				; move down 32px
		bra.w	Glass_Move
; ===========================================================================

; Type 3 - drops each time it's jumped on
Glass_Drop_Jump:
		btst	#3,obSubtype(a0)			; is object a reflection?
		beq.s	.not_reflection				; if not, branch
		move.b	(v_oscillate+$12).w,d0
		subi.w	#$10,d0
		bra.w	Glass_Move
; ===========================================================================

	.not_reflection:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic on the block?
		bne.s	.chk_move					; if yes, branch
		bclr	#0,obGlass_MoveMode(a0)
		bra.s	.skip_move
; ===========================================================================

	.chk_move:
		tst.b	obGlass_MoveMode(a0)		; is block already moving?
		bne.s	.skip_move					; if yes, branch
		move.b	#1,obGlass_MoveMode(a0)		; set moving flag
		bset	#0,obGlass_JumpInit(a0)		; set first jump flag
		beq.s	.skip_move					; branch if previously 0 (i.e. not jumped on before)
		bset	#7,obGlass_MoveMode(a0)		; +$80 to moving flag
		move.w	#16,obGlass_SinkDist(a0)	; sink 16 pixels after it's jumped on
		move.b	#$A,obGlass_SinkDelay(a0)
		cmpi.w	#$40,obGlass_DistY(a0)		; is block within $40 of its final position?
		bne.s	.skip_move					; if not, branch
		move.w	#$40,obGlass_SinkDist(a0)	; sink rest of the way

	.skip_move:
		tst.b	obGlass_MoveMode(a0)
		bpl.s	.update_pos
		tst.b	obGlass_SinkDelay(a0)
		beq.s	.wait						; branch if time remains on delay timer
		subq.b	#1,obGlass_SinkDelay(a0)	; decrement timer
		bne.s	.update_pos					; if time remains, branch

	.wait:
		tst.w	obGlass_DistY(a0)
		beq.s	.no_dist
		subq.w	#1,obGlass_DistY(a0)
		subq.w	#1,obGlass_SinkDist(a0)
		bne.s	.update_pos

	.no_dist:
		bclr	#7,obGlass_MoveMode(a0)

	.update_pos:
		move.w	obGlass_DistY(a0),d0
		bra.s	Glass_Move
; ===========================================================================

; Type 4 - drops when button is pressed
Glass_Drop_Button:
		btst	#3,obSubtype(a0)			; is object a reflection?
		beq.s	Glass_ChkSwitch				; if not, branch
		move.b	(v_oscillate+$12).w,d0
		subi.w	#$10,d0
		bra.s	Glass_Move
; ===========================================================================

Glass_ChkSwitch:
		tst.b	obGlass_MoveMode(a0)		; is block already moving?
		bne.s	.skip_button				; if yes, branch
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obSubtype(a0),d0 			; load object type number
		lsr.w	#4,d0						; read only the	first nybble
		tst.b	(a2,d0.w)					; has switch number d0 been pressed?
		beq.s	.no_dist					; if not, branch
		move.b	#1,obGlass_MoveMode(a0)		; set moving flag

	.skip_button:
		tst.w	obGlass_DistY(a0)			; does block still have distance to move?
		beq.s	.no_dist					; if not, branch
		subq.w	#2,obGlass_DistY(a0)		; decrement distance

	.no_dist:
		move.w	obGlass_DistY(a0),d0
; ---------------------------------------------------------------------------

Glass_Move:
		move.w	obGlass_StartY(a0),d1		; get initial y position
		sub.w	d0,d1						; apply difference
		move.w	d1,obY(a0)					; update y position
		rts	
; ===========================================================================