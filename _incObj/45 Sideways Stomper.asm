; ---------------------------------------------------------------------------
; Object 45 - spiked metal block from beta version (MZ)
; ---------------------------------------------------------------------------

SideStomp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SStom_Index(pc,d0.w),d1
		jmp		SStom_Index(pc,d1.w)
; ===========================================================================
SStom_Index:	offsetTable
		offsetTableEntry.w SStom_Main
		offsetTableEntry.w SStom_Solid
		offsetTableEntry.w loc_BA8E
		offsetTableEntry.w SStom_Display
		offsetTableEntry.w SStom_Pole

SStom_Var:
		;		routine		xpos	frame
		dc.b	2,			4,		0		; main block
		dc.b	4,			-$1C,	1		; spikes
		dc.b	8,			$54,	3		; pole			; Clownacy Sideways Stomper Fix
		dc.b	6,			$28,	2		; wall bracket

;word_B9BE:	; Note that this indicates three subtypes
SStom_Len:
		dc.w $3800	; short
		dc.w $A000	; long
		dc.w $5000	; medium
; ===========================================================================

SStom_Main:	; Routine 0
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	SStom_Len(pc,d0.w),d2
		lea		(SStom_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	.load

.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail

.load:
		move.b	(a2)+,obRoutine(a1)
		_move.b	#id_SideStomp,obID(a1)
		move.w	obY(a0),obY(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obX(a0),d0
		move.w	d0,obX(a1)
		move.l	#Map_SStom,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Spike_Stomper,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	obX(a1),objoff_30(a1)
		move.w	obX(a0),objoff_3A(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.b	#$20,obActWid(a1)
		move.w	d2,objoff_34(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#1,(a2)						; is subobject spikes?
		bne.s	.notspikes					; if not, branch
		move.b	#$91,obColType(a1)			; use harmful collision type

.notspikes:
		move.b	(a2)+,obFrame(a1)
		move.l	a0,objoff_3C(a1)
		dbf		d1,.loop					; repeat 3 times
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager

.fail:
		move.b	#$10,obActWid(a0)

SStom_Solid:	; Routine 2
		move.w	obX(a0),-(sp)
		bsr.w	SStom_Move
		move.w	#$17,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	(sp)+,d4
		bsr.w	SolidObject
		bra.w	SStom_ChkDel	; Clownacy DisplaySprite Fix
; ===========================================================================

SStom_Pole:	; Routine 8
		movea.l	objoff_3C(a0),a1
		move.b	objoff_32(a1),d0
		addi.b	#$10,d0
		lsr.b	#5,d0
		addq.b	#3,d0
		move.b	d0,obFrame(a0)

loc_BA8E:	; Routine 4
		movea.l	objoff_3C(a0),a1
		moveq	#0,d0
		move.b	objoff_32(a1),d0
		neg.w	d0
		add.w	objoff_30(a0),d0
		move.w	d0,obX(a0)

SStom_Display:	; Routine 6
SStom_ChkDel:
		offscreen.w	DeleteObject,objoff_3A(a0)	; ProjectFM S3K Objects Manager
		cmpi.b	#1,obFrame(a0)
		bne.s	.notSpikes
		bra.w	DisplayAndCollision
	.notSpikes:
		bra.w	DisplaySprite					; Clownacy DisplaySprite Fix

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SStom_Move:
	; Removed offset table -- Clownacy Sideways Stomper Fix
		tst.w	objoff_36(a0)
		beq.s	loc_BB08
		tst.w	objoff_38(a0)
		beq.s	loc_BAEC
		subq.w	#1,objoff_38(a0)
		bra.s	loc_BB3C
; ===========================================================================

loc_BAEC:
		subi.w	#$80,objoff_32(a0)
		bcc.s	loc_BB3C
		clr.w	objoff_32(a0)
		clr.w	obVelX(a0)
		clr.w	objoff_36(a0)
		bra.s	loc_BB3C
; ===========================================================================

loc_BB08:
		move.w	objoff_34(a0),d1
		cmp.w	objoff_32(a0),d1
		beq.s	loc_BB3C
		move.w	obVelX(a0),d0
		addi.w	#$70,obVelX(a0)
		add.w	d0,objoff_32(a0)
		cmp.w	objoff_32(a0),d1
		bhi.s	loc_BB3C
		move.w	d1,objoff_32(a0)
		clr.w	obVelX(a0)
		move.w	#1,objoff_36(a0)
		move.w	#$3C,objoff_38(a0)

loc_BB3C:
		moveq	#0,d0
		move.b	objoff_32(a0),d0
		neg.w	d0
		add.w	objoff_30(a0),d0
		move.w	d0,obX(a0)
		rts	
