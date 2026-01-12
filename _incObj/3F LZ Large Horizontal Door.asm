; ---------------------------------------------------------------------------
; Object 3F - large horizontal door (LZ)
; ---------------------------------------------------------------------------

LZDoorHoriz:
		_move.l	#DoorH_Action,obAddr(a0)
		move.l	#Map_FBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Door,2,0),obGfx(a0)	; LZ specific code
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager

		move.b	#$40,obDispWid(a0)
		move.b	#$10,obHeight(a0)	
		move.b	#7,obFrame(a0)					; will use its own mappings later
		move.w	obX(a0),obFBlock_StartX(a0)		; store starting positions
		move.w	obY(a0),obFBlock_StartY(a0)

		moveq	#$F,d0							; read low nybble of subtype
		and.b	obSubtype(a0),d0				; SCE Optimization
		move.b	d0,obFBlock_ButtonNum(a0)		; set low nybble of subtype as switch index
		move.b	#$C,obSubtype(a0)				; force subtype to $C: moves left when button is pressed
		move.w	#128,obFBlock_MoveDist(a0)		; store full width (from side to side)

	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0			; get address in respawn table
		beq.s	DoorH_Action					; if it's zero, don't remember object
		movea.w	d0,a2							; load address into a2
		bclr	#7,(a2)							; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)
	; End
		beq.s	DoorH_Action
		addq.b	#1,obSubtype(a0)				; increment to $06 (or $0D for long horizontal doors) if previously activated
		clr.w	obFBlock_MoveDist(a0)
; ---------------------------------------------------------------------------

DoorH_Action:	; Routine 2
		move.w	obX(a0),obFBlock_PrevX(a0)		; store current pre-movement x-position
		moveq	#$F,d0							; get low nybble of subtype  (changed if original was $80+)
		and.b	obSubtype(a0),d0				; SCE optimization
		beq.s	.type00							; skip if subtype 00 (doesn't move)
		add.w	d0,d0
		move.w	DoorH_Index-2(pc,d0.w),d1
		jsr		DoorH_Index(pc,d1.w)			; move block subroutines

	.type00:
		tst.b	obRender(a0)					; is object on-screen?
		bpl.s	.chkdel							; if not, branch
		moveq	#75,d1							; width
		moveq	#16,d2							; height (jumping)
		moveq	#17,d3							; height (walking)
		move.w	obFBlock_PrevX(a0),d4			; pre-movement axis position
		bsr.w	SolidObject

	.chkdel:
		offscreen.s	.delete,obFBlock_StartX(a0)	; ProjectFM S3K Object Manager

	.display:
		bra.w	DisplaySprite

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

DoorH_Index:	offsetTable
		offsetTableEntry.w	DoorH_LeftButton		; Type 01 - moves left when button is pressed
		offsetTableEntry.w	DoorH_RightButton		; Type 02 - moves right when button is pressed
; ===========================================================================

; Type 01 - moves left when button is pressed
DoorH_LeftButton:
		tst.b	obFBlock_MoveFlag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obFBlock_ButtonNum(a0),d0
		btst	#0,(a2,d0.w)				; check status of linked button
		beq.s	.not_pressed				; branch if not pressed
		move.b	#1,obFBlock_MoveFlag(a0)	; flag object as moving

	.chk_distance:
		tst.w	obFBlock_MoveDist(a0)		; is remaining distance = 0?
		beq.s	.finish						; if yes, branch
		subq.w	#2,obFBlock_MoveDist(a0)	; decrement distance

	.not_pressed:
		move.w	obFBlock_MoveDist(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		neg.w	d0							; invert if xflipped
		addi.w	#$80,d0

	.no_xflip:
		move.w	obFBlock_StartX(a0),d1
		add.w	d0,d1						; add distance to start position
		move.w	d1,obX(a0)					; update x pos
		rts	
; ===========================================================================

	.finish:
		addq.b	#1,obSubtype(a0)			; convert to type $D
		clr.b	obFBlock_MoveFlag(a0)		; clear movement flag
	; ProjectFM S3K Obj Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.not_pressed				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bset	#0,(a2)
	; End
		bra.s	.not_pressed
; ===========================================================================

; Type 02 - moves right when button is pressed
DoorH_RightButton:
		tst.b	obFBlock_MoveFlag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obFBlock_ButtonNum(a0),d0
		tst.b	(a2,d0.w)					; check status of linked button (unused button subtype $4x)
		bpl.s	.not_pressed				; branch if not pressed
		move.b	#1,obFBlock_MoveFlag(a0)

	.chk_distance:
		move.w	#128,d0
		cmp.w	obFBlock_MoveDist(a0),d0	; has object moved 128 ($80) px?
		beq.s	.finish						; if yes, branch
		addq.w	#2,obFBlock_MoveDist(a0)	; increment distance

	.not_pressed:
		move.w	obFBlock_MoveDist(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		neg.w	d0							; invert if xflipped
		addi.w	#$80,d0

	.no_xflip:
		move.w	obFBlock_StartX(a0),d1
		add.w	d0,d1						; add distance to start position
		move.w	d1,obX(a0)					; update x pos
		rts	
; ===========================================================================

	.finish:
		subq.b	#1,obSubtype(a0)			; convert to type $C
		clr.b	obFBlock_MoveFlag(a0)		; clear movement flag
	; ProjectFM S3K Obj Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.not_pressed				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#0,(a2)
	; End
		bra.s	.not_pressed
; ===========================================================================