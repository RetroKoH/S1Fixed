; ---------------------------------------------------------------------------
; Object 5C - rotating staircase blocks (SLZ)
; Split from Obj56 by RetroKoH (Special Thanks: Hivebrain)
; ---------------------------------------------------------------------------
; OST Constants (based on Obj56)
obRBlock_StartX:		equ objoff_30		; 2 bytes | starting X-axis position
obRBlock_StartY:		equ objoff_32		; 2 bytes | starting Y-axis position
obRBlock_PrevX:			equ objoff_34		; 2 bytes | previous X-axis position (used instead of pushing to the stack)
obRBlock_MoveFlag:		equ objoff_38		; 1 byte  | 1 = block/door is moving
obRBlock_MoveDist:		equ objoff_3A		; 2 bytes | distance to move
obRBlock_ButtonNum:		equ objoff_3C		; 1 byte  | which button the block is linked to (2nd digit of subtype)
; ---------------------------------------------------------------------------

RotatingBlock:
		_move.l	#RBlock_Action,obAddr(a0)
		move.l	#Map_Stair,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager

		move.b	#$10,obDispWid(a0)
		move.b	#$10,obHeight(a0)
		move.w	obX(a0),obRBlock_StartX(a0)		; store starting positions
		move.w	obY(a0),obRBlock_StartY(a0)

		move.w	#$20,obRBlock_MoveDist(a0)		; store full height (from top to bottom)
		moveq	#$F,d0							; read low nybble of subtype
		and.b	obSubtype(a0),d0				; SCE Optimization
		subq.w	#8,d0
		bcs.s	RBlock_Action					; branch if low nybble was > 8
		lsl.w	#2,d0							; multiply by 4
		lea		(v_oscillate+$2C).w,a2
		adda.w	d0,a2							; read oscillating value (HAME: Replace lea instruction)
		tst.w	(a2)
		bpl.s	RBlock_Action					; branch if not negative
		bchg	#staFlipX,obStatus(a0)			; otherwise, xflip object
; ---------------------------------------------------------------------------

RBlock_Action:
		move.w	obX(a0),obRBlock_PrevX(a0)		; store current pre-movement x-position
		moveq	#$F,d0							; get low nybble of subtype  (changed if original was $80+)
		and.b	obSubtype(a0),d0				; SCE optimization
		beq.s	.type00							; skip if subtype 00 (doesn't move)
		add.w	d0,d0
		move.w	RBlock_Index-2(pc,d0.w),d1
		jsr		RBlock_Index(pc,d1.w)			; move block subroutines

	.type00:
		tst.b	obRender(a0)					; is object on-screen?
		bpl.s	.chkdel							; if not, branch
		moveq	#27,d1							; width
		moveq	#16,d2							; height (jumping)
		moveq	#17,d3							; height (walking)
		move.w	obRBlock_PrevX(a0),d4			; pre-movement axis position
		bsr.w	SolidObject

	.chkdel:
		offscreen.s	.delete,obRBlock_StartX(a0)	; ProjectFM S3K Object Manager

	.display:
		bra.w	DisplaySprite

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

RBlock_Index:	offsetTable
		offsetTableEntry.w	RBlock_SquareSmall		; Type 01 - moves around in a small square
		offsetTableEntry.w	RBlock_SquareMedium		; Type 02 - moves around in a medium square
		offsetTableEntry.w	RBlock_SquareBig		; Type 03 - moves around in a large square
		offsetTableEntry.w	RBlock_SquareBiggest	; Type 04 - moves around in the largest square
; ===========================================================================

; Type 01 - moves around in a small square
RBlock_SquareSmall:
		moveq	#16,d1
		moveq	#0,d0
		move.b	(v_oscillate+$2A).w,d0
		lsr.w	#1,d0
		move.w	(v_oscillate+$2C).w,d3
		bra.s	RBlock_Square_Move
; ===========================================================================

; Type 02 - moves around in a medium square
RBlock_SquareMedium:
		moveq	#48,d1
		moveq	#0,d0
		move.b	(v_oscillate+$2E).w,d0
		move.w	(v_oscillate+$30).w,d3
		bra.s	RBlock_Square_Move
; ===========================================================================

; Type 03 - moves around in a large square
RBlock_SquareBig:
		moveq	#80,d1
		moveq	#0,d0
		move.b	(v_oscillate+$32).w,d0
		move.w	(v_oscillate+$34).w,d3
		bra.s	RBlock_Square_Move
; ===========================================================================

; Type 04 - moves around in the largest square
RBlock_SquareBiggest:
		moveq	#112,d1
		moveq	#0,d0
		move.b	(v_oscillate+$36).w,d0
		move.w	(v_oscillate+$38).w,d3
; ---------------------------------------------------------------------------

RBlock_Square_Move:
		tst.w	d3		; is oscillating value rate currently 0? (i.e. at peak or nadir of oscillation)
		bne.s	.keep_going								; if not, branch
		addq.b	#1,obStatus(a0)							; change direction
		andi.b	#(maskFlipX+maskFlipY),obStatus(a0)		; prevent bit overflow

	.keep_going:
		moveq	#(maskFlipX+maskFlipY),d2
		and.b	obStatus(a0),d2							; read xflip and yflip bits (SCE Optimization)
		bne.s	.xflip									; branch if either are set
		sub.w	d1,d0
		add.w	obRBlock_StartX(a0),d0
		move.w	d0,obX(a0)								; update position
		neg.w	d1
		add.w	obRBlock_StartY(a0),d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

	.xflip:
		subq.b	#1,d2
		bne.s	.yflip									; branch if yflip bit is set
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	obRBlock_StartY(a0),d0
		move.w	d0,obY(a0)								; update position
		addq.w	#1,d1
		add.w	obRBlock_StartX(a0),d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================

	.yflip:
		subq.b	#1,d2
		bne.s	.xflip_and_yflip						; branch if xflip and yflip bits are set
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	obRBlock_StartX(a0),d0
		move.w	d0,obX(a0)								; update position
		addq.w	#1,d1
		add.w	obRBlock_StartY(a0),d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

	.xflip_and_yflip:
		sub.w	d1,d0
		add.w	obRBlock_StartY(a0),d0
		move.w	d0,obY(a0)								; update position
		neg.w	d1
		add.w	obRBlock_StartX(a0),d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================