; ---------------------------------------------------------------------------
; Object 6C - vanishing	platforms (SBZ)
; ---------------------------------------------------------------------------

VanishPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	VanP_Index(pc,d0.w),d1
		jmp		VanP_Index(pc,d1.w)
; ===========================================================================
VanP_Index:		offsetTable
		offsetTableEntry.w 	VanP_Main
		offsetTableEntry.w 	VanP_Vanish
		offsetTableEntry.w 	VanP_Appear
		offsetTableEntry.w 	loc_16068

vanp_timer = objoff_30		; counter for time until event
vanp_timelen = objoff_32	; time between events (general)
; ===========================================================================

VanP_Main:	; Routine 0
		addq.b	#6,obRoutine(a0)
		move.l	#Map_VanP,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Vanishing_Block,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		moveq	#0,d0
		move.b	obSubtype(a0),d0 ; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		addq.w	#1,d0		; add 1
		lsl.w	#7,d0		; multiply by $80
		move.w	d0,d1
		subq.w	#1,d0
		move.w	d0,vanp_timer(a0)
		move.w	d0,vanp_timelen(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0 ; get object type
		andi.w	#$F0,d0		; read only the	1st digit
		addi.w	#$80,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
		move.w	d0,objoff_36(a0)
		subq.w	#1,d1
		move.w	d1,objoff_38(a0)

loc_16068:	; Routine 6
		move.w	(v_framecount).w,d0
		sub.w	objoff_36(a0),d0
		and.w	objoff_38(a0),d0
		bne.s	.animate
		subq.b	#4,obRoutine(a0) ; goto VanP_Vanish next
		bra.s	VanP_Vanish
; ===========================================================================

.animate:
		lea		Ani_Van(pc),a1
		jsr		(AnimateSprite).w
		jmp		(RememberState).l
; ===========================================================================

VanP_Vanish:	; Routine 2
VanP_Appear:	; Routine 4
		subq.w	#1,vanp_timer(a0)
		bpl.s	.wait
		move.w	#127,vanp_timer(a0)
		tst.b	obAnim(a0)	; is platform vanishing?
		beq.s	.isvanishing	; if yes, branch
		move.w	vanp_timelen(a0),vanp_timer(a0)

.isvanishing:
		bchg	#0,obAnim(a0)

.wait:
		lea		Ani_Van(pc),a1
		jsr		(AnimateSprite).w
		btst	#1,obFrame(a0)	; has platform vanished?
		bne.s	.notsolid	; if yes, branch
		cmpi.b	#2,obRoutine(a0)
		bne.s	.loc_160D6
		moveq	#0,d1
		move.b	obActWid(a0),d1
		jsr		(PlatformObject).l
		jmp		(RememberState).l
; ===========================================================================

.loc_160D6:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		jsr		(ExitPlatform).l
		move.w	obX(a0),d2
		jsr		(MvSonicOnPtfm2).l
		jmp		(RememberState).l
; ===========================================================================

.notsolid:
		btst	#staSonicOnObj,obStatus(a0)
		beq.s	.display
		lea		(v_player).w,a1
		bclr	#staOnObj,obStatus(a1)
		bclr	#staSonicOnObj,obStatus(a0)
		move.b	#2,obRoutine(a0)
		clr.b	obSolid(a0)

.display:
		jmp		(RememberState).l
