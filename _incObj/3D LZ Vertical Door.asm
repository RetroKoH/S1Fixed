; ---------------------------------------------------------------------------
; Object 3D - small vertical door (LZ)
; ---------------------------------------------------------------------------

LZDoorVert:
		_move.l	#DoorV_Action,obAddr(a0)
		move.l	#Map_FBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Door,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager

		move.b	#8,obDispWid(a0)
		move.b	#$20,obHeight(a0)	
		move.b	#6,obFrame(a0)					; will use its own mappings later
		move.w	obY(a0),obFBlock_StartY(a0)

		moveq	#$F,d0							; read low nybble of subtype
		and.b	obSubtype(a0),d0				; SCE Optimization
		move.b	d0,obFBlock_ButtonNum(a0)		; set low nybble of subtype as switch index
		move.b	#1,obSubtype(a0)				; force subtype to 1: moves up when button is pressed
		move.w	#$40,obFBlock_MoveDist(a0)		; store full height (from top to bottom)

	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0			; get address in respawn table
		beq.s	DoorV_Action					; if it's zero, don't remember object
		movea.w	d0,a2							; load address into a2
		bclr	#7,(a2)							; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)
	; End
		beq.s	DoorV_Action
		addq.b	#1,obSubtype(a0)				; increment to $06 (or $0D for long horizontal doors) if previously activated
		clr.w	obFBlock_MoveDist(a0)
; ---------------------------------------------------------------------------

DoorV_Action:	; Routine 2
		moveq	#$F,d0							; get low nybble of subtype  (changed if original was $80+)
		and.b	obSubtype(a0),d0				; SCE optimization
		beq.s	.type00							; skip if subtype 00 (doesn't move)
		add.w	d0,d0
		move.w	DoorV_Index-2(pc,d0.w),d1
		jsr		DoorV_Index(pc,d1.w)			; move block subroutines

	.type00:
		tst.b	obRender(a0)					; is object on-screen?
		bpl.s	.chkdel							; if not, branch
		moveq	#19,d1							; width
		moveq	#32,d2							; height (jumping)
		moveq	#33,d3							; height (walking)
		move.w	obX(a0),d4						; axis position
		bsr.w	SolidObject

	.chkdel:
		offscreen.s	.delete						; ProjectFM S3K Object Manager

	.display:
		bra.w	DisplaySprite

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

DoorV_Index:	offsetTable
		offsetTableEntry.w	DoorV_UpButton			; Type 01 - moves up when a button is pressed
		offsetTableEntry.w	DoorV_DownButton		; Type 02 - moves down when button is pressed
; ===========================================================================

; Type 01 - moves up when a button is pressed
DoorV_UpButton:
		tst.b	obFBlock_MoveFlag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		cmpi.w	#(id_LZ<<8)+0,(v_zone).w	; is level LZ1?
		bne.s	.not_lz1					; if not, branch
		cmpi.b	#3,obFBlock_ButtonNum(a0)	; is object linked to button 3?
		bne.s	.not_lz1					; if not, branch
		clr.b	(f_wtunnelallow).w			; enable water tunnels
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0					; is Sonic to the right?
		bhs.s	.not_lz1					; if yes, branch
		move.b	#1,(f_wtunnelallow).w		; disable water tunnels if Sonic is to the left

	.not_lz1:
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obFBlock_ButtonNum(a0),d0
		btst	#0,(a2,d0.w)				; check status of linked button
		beq.s	.not_pressed				; branch if not pressed
		cmpi.w	#(id_LZ<<8)+0,(v_zone).w	; is level LZ1 ?
		bne.s	.set_moveflag				; if not, branch
		cmpi.b	#3,d0						; is object linked to button 3?
		bne.s	.set_moveflag				; if not, branch
		clr.b	(f_wtunnelallow).w			; enable water tunnels

	.set_moveflag:
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

	.no_xflip:
		move.w	obFBlock_StartY(a0),d1
		add.w	d0,d1						; add distance to start position
		move.w	d1,obY(a0)					; update y pos
		rts	
; ===========================================================================

	.finish:
		addq.b	#1,obSubtype(a0)			; convert to type 6
		clr.b	obFBlock_MoveFlag(a0)		; clear movement flag
	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.not_pressed				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bset	#0,(a2)
	; End
		bra.s	.not_pressed
; ===========================================================================

; Type 02 - moves down when button is pressed
DoorV_DownButton:
		tst.b	obFBlock_MoveFlag(a0)		; is object moving?
		bne.s	.chk_distance				; if yes, branch
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obFBlock_ButtonNum(a0),d0
		tst.b	(a2,d0.w)					; check status of linked button (unused button subtype $4x)
		bpl.s	.not_pressed				; branch if not pressed
		move.b	#1,obFBlock_MoveFlag(a0)

	.chk_distance:
		moveq	#0,d0
		move.b	obHeight(a0),d0
		add.w	d0,d0
		cmp.w	obFBlock_MoveDist(a0),d0	; has object moved distance equal to its height?
		beq.s	.finish						; if yes, branch
		addq.w	#2,obFBlock_MoveDist(a0)	; increment distance

	.not_pressed:
		move.w	obFBlock_MoveDist(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		neg.w	d0							; invert if xflipped

	.no_xflip:
		move.w	obFBlock_StartY(a0),d1
		add.w	d0,d1						; add distance to start position
		move.w	d1,obY(a0)					; update y pos
		rts	
; ===========================================================================

	.finish:
		subq.b	#1,obSubtype(a0)			; convert to type 5
		clr.b	obFBlock_MoveFlag(a0)		; clear movement flag
	; ProjectFM S3K Obj Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.not_pressed				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#0,(a2)
	; End
		bra.s	.not_pressed
; ===========================================================================