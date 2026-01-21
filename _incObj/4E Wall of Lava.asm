; ---------------------------------------------------------------------------
; Object 4E - advancing	wall of	lava (MZ)
; ---------------------------------------------------------------------------
; OST Constants
obLWall_MoveFlag:		equ objoff_36		; 1 byte  | flag to start wall moving
obLWall_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

LavaWall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LWall_Index(pc,d0.w),d1
		jmp		LWall_Index(pc,d1.w)
; ===========================================================================

LWall_Index:	offsetTable
		offsetTableEntry.w LWall_Main
		offsetTableEntry.w LWall_Solid
		offsetTableEntry.w LWall_Action
		offsetTableEntry.w LWall_BackHalf
		offsetTableEntry.w LWall_Delete
; ===========================================================================

LWall_Main:	; Routine 0
		addq.b	#4,obRoutine(a0)			; -> LWall_Action
		movea.l	a0,a1
		moveq	#1,d1
		bra.s	.make
; ===========================================================================

	.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail						; branch if object slot not found

	.make:
		_move.l	#LavaWall,obAddr(a1)		; load object
		move.l	#Map_LWall,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Lava,3,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$50,obDispWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obAnim(a1)
		move.b	#(colHarmful|colSz_64x32),obColType(a1)
		
		bset	#shPropFlame,obShieldProp(a1)	; Negated by Flame Shield
		
		move.w	a0,obLWall_Parent(a1)

	.fail:
		dbf		d1,.loop					; repeat sequence once

		addq.b	#6,obRoutine(a1)			; goto LWall_BackHalf next (2nd object only)
		move.b	#4,obFrame(a1)				; use back of lava wall frame
; ---------------------------------------------------------------------------

LWall_Action:	; Routine 4
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.rangechk
		neg.w	d0

	.rangechk:
		cmpi.w	#192,d0						; is Sonic within 192px on x-axis?
		bhs.s	.movewall					; if not, branch
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		bcc.s	.rangechk2
		neg.w	d0

	.rangechk2:
		cmpi.w	#96,d0						; is Sonic within 96px on y-axis?
		bhs.s	.movewall					; if not, branch
		move.b	#1,obLWall_MoveFlag(a0)		; set object to move
		bra.s	LWall_Solid
; ===========================================================================

	.movewall:
		tst.b	obLWall_MoveFlag(a0)		; is object set	to move?
		beq.s	LWall_Solid					; if not, branch
		move.w	#$180,obVelX(a0)			; set object speed
		subq.b	#2,obRoutine(a0)			; -> LWall_Solid
; ---------------------------------------------------------------------------

LWall_Solid:	; Routine 2
		moveq	#43,d1						; width; save 4 cycles - Filter
		moveq	#24,d2						; height (jumping); save 4 cycles - Filter
		moveq	#25,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		move.b	obRoutine(a0),d0			; store current routine
		move.w	d0,-(sp)
		bsr.w	SolidObject
		move.w	(sp)+,d0
		move.b	d0,obRoutine(a0)			; restore current routine
		cmpi.w	#$6A0,obX(a0)				; has object reached $6A0 on the x-axis?
		bne.s	.animate					; if not, branch
		clr.w	obVelX(a0)					; stop object moving
		clr.b	obLWall_MoveFlag(a0)

	.animate:
		lea		Ani_LWall(pc),a1
		jsr		(AnimateSprite).w
		cmpi.b	#4,(v_player+obRoutine).w	; is Sonic hurt or dead?
		bhs.s	.rangechk					; if yes, branch
		bsr.w	SpeedToPos_XOnly

	.rangechk:
		tst.b	obLWall_MoveFlag(a0)		; is wall already moving?
		bne.s	.moving						; if yes, branch
		out_of_range.s	.chkgone			; retain old macro

	.moving:
		jmp		(DisplayAndCollision).l		; Clownacy DisplaySprites fix
; ===========================================================================

	.chkgone:
	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
	; S3K Object Manager
		move.b	#8,obRoutine(a0)
		rts	
; ===========================================================================

LWall_BackHalf:	; Routine 6
		movea.w	obLWall_Parent(a0),a1		; get object address of parent (front half)
		cmpi.b	#8,obRoutine(a1)			; is parent set to delete?
		beq.w	DeleteObject				; if yes, branch
		move.w	obX(a1),obX(a0)				; move rest of lava wall
		subi.w	#128,obX(a0)				; move 128px to the left
		bra.w	DisplaySprite
; ===========================================================================

LWall_Delete:	; Routine 8
		bra.w	DeleteObject
; ===========================================================================