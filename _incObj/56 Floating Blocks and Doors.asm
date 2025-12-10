; ---------------------------------------------------------------------------
; Object 56 - floating blocks (SYZ/SLZ), large doors (LZ)
; ---------------------------------------------------------------------------

; ===========================================================================

FBlock_Var:	; width/2, height/2
		dc.b  $10, $10	; subtype 0x/8x ($0)
		dc.b  $20, $20	; subtype 1x/9x ($2)
		dc.b  $10, $20	; subtype 2x/Ax ($4)
		dc.b  $20, $1A	; subtype 3x/Bx ($6)
		dc.b  $10, $27	; subtype 4x/Cx ($8) - unused
		dc.b  $10, $10	; subtype 5x/Dx ($A)
		dc.b	8, $20	; subtype 6x/Ex ($C)
		dc.b  $40, $10	; subtype 7x/Fx ($E)
		
	; Giant stairs seem to be formed by subtypes $58, 59, 5A, and 5B placed together
; ===========================================================================

FloatingBlock:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	FBlock_Action
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

FBlock_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_FBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)		; SYZ/SLZ code
		cmpi.b	#id_LZ,(v_zone).w				; check if level is LZ
		bne.s	.notLZ							; if not, branch
		move.w	#make_art_tile(ArtTile_LZ_Door,2,0),obGfx(a0)	; LZ specific code

	.notLZ:
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		moveq	#0,d0
		move.b	obSubtype(a0),d0				; get subtype
		lsr.w	#3,d0
		andi.w	#$E,d0							; Example: Subtype $F8 >> 3 = $1F. $1F & $E = $E.
		lea		FBlock_Var(pc,d0.w),a2			; get size data
		move.b	(a2)+,obDispWid(a0)
		lsr.w	#1,d0
		move.b	d0,obFrame(a0)					; set frame as high nybble of subtype
		move.w	obX(a0),obFBlock_StartX(a0)		; store starting positions
		move.w	obY(a0),obFBlock_StartY(a0)
		moveq	#0,d0
		move.b	(a2),d0							; get height from size list
		move.b	d0,obHeight(a0)					; loading height from d0 here saves cycles
		add.w	d0,d0
		move.w	d0,obFBlock_MoveDist(a0)		; store full height (from top to bottom)
		cmpi.b	#$37,obSubtype(a0)
		bne.s	.dontdelete						; Branch if subtype /= $37
	; Only applies to subtype $37
		cmpi.w	#$1BB8,obX(a0)					; is object in its start position?
		bne.s	.notatpos						; if not branch
		tst.b	(f_obj56).w						; has similar object reached its destination?
		beq.s	.dontdelete						; if delete flag isn't set, branch
		jmp		(DeleteObject).l
; ===========================================================================

	.notatpos:
		clr.b	obSubtype(a0)					; clear subtype for obj $5637 (stop object moving)
		tst.b	(f_obj56).w
		bne.s	.dontdelete
		jmp		(DeleteObject).l
; ===========================================================================

	.dontdelete:
		moveq	#0,d0
		cmpi.b	#id_LZ,(v_zone).w				; check if level is LZ
		beq.s	.isLZ							; if yes, branch

		moveq	#$F,d0							; SYZ/SLZ specific code
		and.b	obSubtype(a0),d0				; read low nybble of subtype (SCE Optimization)
		subq.w	#8,d0
		bcs.s	.isLZ							; branch if low nybble was > 8
		lsl.w	#2,d0							; multiply by 4
		lea		(v_oscillate+$2C).w,a2
		lea		(a2,d0.w),a2					; read oscillating value
		tst.w	(a2)
		bpl.s	.isLZ							; branch if not negative
		bchg	#staFlipX,obStatus(a0)			; otherwise, xflip object

	.isLZ:
		move.b	obSubtype(a0),d0
		bpl.s	FBlock_Action					; if subtype is 0-$7F, branch
		andi.b	#$F,d0							; read low nybble
		move.b	d0,obFBlock_ButtonNum(a0)		; set low nybble of subtype as switch index
		move.b	#5,obSubtype(a0)				; force subtype to 5 (moves up when button is pressed)
		cmpi.b	#7,obFrame(a0)					; is object a large horizontal LZ door?
		bne.s	.chkstate						; if not, branch
		move.b	#$C,obSubtype(a0)				; force subtype to $C (moves left when button is pressed)
		move.w	#128,obFBlock_MoveDist(a0)

	.chkstate:
	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0			; get address in respawn table
		beq.s	FBlock_Action					; if it's zero, don't remember object
		movea.w	d0,a2							; load address into a2
		bclr	#7,(a2)							; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)
	; End
		beq.s	FBlock_Action
		addq.b	#1,obSubtype(a0)				; increment to $06 (or $0D for long horizontal doors) if previously activated
		clr.w	obFBlock_MoveDist(a0)
; ---------------------------------------------------------------------------

FBlock_Action:	; Routine 2
		move.w	obX(a0),obFBlock_PrevX(a0)		; store current pre-movement x-position
		moveq	#$F,d0							; get low nybble of subtype  (changed if original was $80+)
		and.b	obSubtype(a0),d0				; SCE optimization
		beq.s	.type00							; skip if subtype 00 (doesn't move)
		add.w	d0,d0
		move.w	FBlock_Index-2(pc,d0.w),d1
		jsr		FBlock_Index(pc,d1.w)			; move block subroutines

	.type00:
		move.w	obFBlock_PrevX(a0),d4			; pre-movement axis position
		tst.b	obRender(a0)
		bpl.s	.chkdel
		moveq	#11,d1
		add.b	obDispWid(a0),d1				; width; save 8 cycles
		moveq	#0,d2
		move.b	obHeight(a0),d2					; height (jumping)
		move.w	d2,d3
		addq.w	#1,d3							; height (walking)
		bsr.w	SolidObject

	.chkdel:
		offscreen.s	.chkdel2,obFBlock_StartX(a0)	; ProjectFM S3K Object Manager

	.display:
		bra.w	DisplaySprite

	.chkdel2:
		cmpi.b	#$37,obSubtype(a0)
		bne.s	.delete
		tst.b	obFBlock_MoveFlag(a0)
		bne.w	DisplaySprite

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

FBlock_Index:	offsetTable
		offsetTableEntry.w	FBlock_LeftRight		; Type 01 - moves side-to-side
		offsetTableEntry.w	FBlock_LeftRightWide	; Type 02 - moves side-to-side
		offsetTableEntry.w	FBlock_UpDown			; Type 03 - moves up/down
		offsetTableEntry.w	FBlock_UpDownWide		; Type 04 - moves up/down (wide distance)
		offsetTableEntry.w	FBlock_UpButton			; Type 05 - moves up when a button is pressed
		offsetTableEntry.w	FBlock_DownButton		; Type 06 - moves down when button is pressed
		offsetTableEntry.w	FBlock_FarRightButton	; Type 07 - moves far right when button $F is pressed
		offsetTableEntry.w	FBlock_SquareSmall		; Type 08 - moves around in a small square
		offsetTableEntry.w	FBlock_SquareMedium		; Type 09 - moves around in a medium square
		offsetTableEntry.w	FBlock_SquareBig		; Type $0A - moves around in a large square
		offsetTableEntry.w	FBlock_SquareBiggest	; Type $0B - moves around in the largest square
		offsetTableEntry.w	FBlock_LeftButton		; Type $0C - moves left when button is pressed
		offsetTableEntry.w	FBlock_RightButton		; Type $0D - moves right when button is pressed
; ===========================================================================

; Type 01 - moves side-to-side
FBlock_LeftRight:
		moveq	#64,d1						; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$A).w,d0
		bra.s	FBlock_LeftRightWide.moveLR
; ===========================================================================

; Type 02 - moves side-to-side
FBlock_LeftRightWide:
		move.w	#128,d1						; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$1E).w,d0

	.moveLR:
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	d0
		add.w	d1,d0

	.noflip:
		move.w	obFBlock_StartX(a0),d1
		sub.w	d0,d1
		move.w	d1,obX(a0)					; move object horizontally
		rts		
; ===========================================================================

; Type 03 - moves up/down
FBlock_UpDown:
		moveq	#64,d1						; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$A).w,d0
		bra.s	FBlock_UpDownWide.moveUD
; ===========================================================================

; Type 04 - moves up/down (wide distance)
FBlock_UpDownWide:
		move.w	#128,d1						; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$1E).w,d0

	.moveUD:
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip04
		neg.w	d0
		add.w	d1,d0

	.noflip04:
		move.w	obFBlock_StartY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)					; move object vertically
		rts	
; ===========================================================================

; Type 05 - moves up when a button is pressed
FBlock_UpButton:
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

; Type 06 - moves down when button is pressed
FBlock_DownButton:
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

; Type 07 - moves far right when button $F is pressed
FBlock_FarRightButton:
		tst.b	obFBlock_MoveFlag(a0)		; is object moving already?
		bne.s	.chk_distance				; if yes, branch
		tst.b	(f_switch+$F).w				; has button number $F been pressed?
		beq.s	.end						; if not, branch
		move.b	#1,obFBlock_MoveFlag(a0)
		clr.w	obFBlock_MoveDist(a0)

	.chk_distance:
		addq.w	#1,obX(a0)					; move object right
		move.w	obX(a0),obFBlock_StartX(a0)
		addq.w	#1,obFBlock_MoveDist(a0)	; increment movement counter
		cmpi.w	#896,obFBlock_MoveDist(a0)	; has object moved 896 ($380) pixels?
		bne.s	.end						; if not, branch
		move.b	#1,(f_obj56).w
		clr.b	obFBlock_MoveFlag(a0)
		clr.b	obSubtype(a0)				; stop object moving

	.end:
		rts	
; ===========================================================================

; Type $0C - moves left when button is pressed
FBlock_LeftButton:
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

; Type $0D - moves right when button is pressed
FBlock_RightButton:
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

; Type 08 - moves around in a small square
FBlock_SquareSmall:
		moveq	#16,d1
		moveq	#0,d0
		move.b	(v_oscillate+$2A).w,d0
		lsr.w	#1,d0
		move.w	(v_oscillate+$2C).w,d3
		bra.s	FBlock_Square_Move
; ===========================================================================

; Type 09 - moves around in a medium square
FBlock_SquareMedium:
		moveq	#48,d1
		moveq	#0,d0
		move.b	(v_oscillate+$2E).w,d0
		move.w	(v_oscillate+$30).w,d3
		bra.s	FBlock_Square_Move
; ===========================================================================

; Type $0A - moves around in a large square
FBlock_SquareBig:
		moveq	#80,d1
		moveq	#0,d0
		move.b	(v_oscillate+$32).w,d0
		move.w	(v_oscillate+$34).w,d3
		bra.s	FBlock_Square_Move
; ===========================================================================

; Type $0B - moves around in the largest square
FBlock_SquareBiggest:
		moveq	#112,d1
		moveq	#0,d0
		move.b	(v_oscillate+$36).w,d0
		move.w	(v_oscillate+$38).w,d3
; ---------------------------------------------------------------------------

FBlock_Square_Move:
		tst.w	d3		; is oscillating value rate currently 0? (i.e. at peak or nadir of oscillation)
		bne.s	.keep_going								; if not, branch
		addq.b	#1,obStatus(a0)							; change direction
		andi.b	#(maskFlipX+maskFlipY),obStatus(a0)		; prevent bit overflow

	.keep_going:
		moveq	#(maskFlipX+maskFlipY),d2
		and.b	obStatus(a0),d2							; read xflip and yflip bits (SCE Optimization)
		bne.s	.xflip									; branch if either are set
		sub.w	d1,d0
		add.w	obFBlock_StartX(a0),d0
		move.w	d0,obX(a0)								; update position
		neg.w	d1
		add.w	obFBlock_StartY(a0),d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

	.xflip:
		subq.b	#1,d2
		bne.s	.yflip									; branch if yflip bit is set
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	obFBlock_StartY(a0),d0
		move.w	d0,obY(a0)								; update position
		addq.w	#1,d1
		add.w	obFBlock_StartX(a0),d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================

	.yflip:
		subq.b	#1,d2
		bne.s	.xflip_and_yflip						; branch if xflip and yflip bits are set
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	obFBlock_StartX(a0),d0
		move.w	d0,obX(a0)								; update position
		addq.w	#1,d1
		add.w	obFBlock_StartY(a0),d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

	.xflip_and_yflip:
		sub.w	d1,d0
		add.w	obFBlock_StartY(a0),d0
		move.w	d0,obY(a0)								; update position
		neg.w	d1
		add.w	obFBlock_StartX(a0),d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================