; ---------------------------------------------------------------------------
; Object 06 - Sonic (special stage)
; ---------------------------------------------------------------------------

SpecialCursor:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		bne.s	SpCursor_Normal	; if yes, branch
		rts
; ===========================================================================

SpCursor_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SpCursor_Index(pc,d0.w),d1
		jmp		SpCursor_Index(pc,d1.w)
; ===========================================================================
SpCursor_Index:	offsetTable
		offsetTableEntry.w	SpCursor_Main
		offsetTableEntry.w	SpCursor_Action
; ===========================================================================

SpCursor_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.l	#Map_Cursor,obMap(a0)
		move.w	#make_art_tile(ArtTile_SS_Cursor,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

SpCursor_Action:	; Routine 2
		lea		(v_player).w,a1
		moveq	#0,d2
		move.w	obY(a1),d2
;		subi.w	#$50,d2
		divu.w	#$18,d2
		mulu.w	#$18,d2
		addq.w	#4,d2
		move.w	d2,obY(a0)
		moveq	#0,d2
		move.w	obX(a1),d2
;		addi.w	#$1A,d2
		divu.w	#$18,d2
		mulu.w	#$18,d2
		addq.w	#4,d2
		move.w	d2,obX(a0)
		jmp		DisplaySprite
; ===========================================================================