; ---------------------------------------------------------------------------
; Object 4E - advancing	wall of	lava (MZ)
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
		offsetTableEntry.w LWall_Move
		offsetTableEntry.w LWall_Delete

lwall_flag = objoff_36		; flag to start wall moving
; ===========================================================================

LWall_Main:	; Routine 0
		addq.b	#4,obRoutine(a0)
		movea.l	a0,a1
		moveq	#1,d1
		bra.s	.make
; ===========================================================================

.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail

.make:
		_move.b	#id_LavaWall,obID(a1)	; load object
		move.l	#Map_LWall,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Lava,3,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$50,obActWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obAnim(a1)
		move.b	#$94,obColType(a1)
		
		bset	#shPropFlame,obShieldProp(a1)	; Negated by Flame Shield
		
		move.l	a0,objoff_3C(a1)

.fail:
		dbf		d1,.loop	; repeat sequence once

		addq.b	#6,obRoutine(a1)
		move.b	#4,obFrame(a1)

LWall_Action:	; Routine 4
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.rangechk
		neg.w	d0

.rangechk:
		cmpi.w	#$C0,d0		; is Sonic within $C0 pixels (x-axis)?
		bhs.s	.movewall	; if not, branch
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		bcc.s	.rangechk2
		neg.w	d0

.rangechk2:
		cmpi.w	#$60,d0		; is Sonic within $60 pixels (y-axis)?
		bhs.s	.movewall	; if not, branch
		move.b	#1,lwall_flag(a0) ; set object to move
		bra.s	LWall_Solid
; ===========================================================================

.movewall:
		tst.b	lwall_flag(a0)		; is object set	to move?
		beq.s	LWall_Solid			; if not, branch
		move.w	#$180,obVelX(a0)	; set object speed
		subq.b	#2,obRoutine(a0)

LWall_Solid:	; Routine 2
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		move.b	obRoutine(a0),d0
		move.w	d0,-(sp)
		bsr.w	SolidObject
		move.w	(sp)+,d0
		move.b	d0,obRoutine(a0)
		cmpi.w	#$6A0,obX(a0)		; has object reached $6A0 on the x-axis?
		bne.s	.animate			; if not, branch
		clr.w	obVelX(a0)			; stop object moving
		clr.b	lwall_flag(a0)

.animate:
		lea		(Ani_LWall).l,a1
		jsr		(AnimateSprite).w
		cmpi.b	#4,(v_player+obRoutine).w
		bhs.s	.rangechk
		bsr.w	SpeedToPos

.rangechk:
		tst.b	lwall_flag(a0)		; is wall already moving?
		bne.s	.moving				; if yes, branch
		out_of_range.s	.chkgone	; retain old macro

.moving:
		jmp		(DisplayAndCollision).l		; Clownacy DisplaySprites fix
; ===========================================================================

.chkgone:
	; ProjectFM S3K Object Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
	; S3K Object Manager
		move.b	#8,obRoutine(a0)
		rts	
; ===========================================================================

LWall_Move:	; Routine 6
		movea.l	objoff_3C(a0),a1
		cmpi.b	#8,obRoutine(a1)
		beq.w	DeleteObject
		move.w	obX(a1),obX(a0)	; move rest of lava wall
		subi.w	#$80,obX(a0)
		bra.w	DisplaySprite
; ===========================================================================

LWall_Delete:	; Routine 8
		bra.w	DeleteObject
