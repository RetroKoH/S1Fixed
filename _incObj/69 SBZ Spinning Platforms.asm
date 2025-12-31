; ---------------------------------------------------------------------------
; Object 69 - spinning platforms and trapdoors (SBZ)
; TO-DO: Split these into two separate objects
; ---------------------------------------------------------------------------

SpinPlatform:
		_move.l	#Spin_Trapdoor,obAddr(a0)
		move.l	#Map_Trap,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Trap_Door,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$40,obDispWid(a0)			; Ralakimus Trapdoor Glitch Fix

		move.b	obSubtype(a0),d2			; load subtype for repeated use
		moveq	#$F,d0
		and.b	d2,d0						; get subtype's low nybble
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,obSpin_WaitMaster(a0)
		tst.b	d2							; is subtype $8x?
		bpl.s	Spin_Trapdoor				; if not, branch
; ---------------------------------------------------------------------------

		_move.l	#Spin_Spinner,obAddr(a0)
		move.l	#Map_Spin,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Spinning_Platform,0,0),obGfx(a0)
		move.b	#$10,obDispWid(a0)
		move.b	#2,obAnim(a0)
		moveq	#0,d0
		move.b	d2,d0						; get object subtype
		move.w	d0,d1
		andi.w	#$F,d0						; read only the	low nybble
		add.w	d0,d0						; multiply by 6
		move.w	d0,d1						; Optimization from S1 in S.C.E.
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,obSpin_WaitTime(a0)
		move.w	d0,obSpin_WaitMaster(a0)	; set time delay
		andi.w	#$70,d1						; read high nybble (e.g. $80/$90), ignore high bit ($00/$10)
		addi.w	#$10,d1						; add $10 ($10/$20)
		lsl.w	#2,d1						; multiply by 4 ($40/$80)
		subq.w	#1,d1						; subtract 1 ($3F/$7F)
		move.w	d1,obSpin_TimeSync(a0)
		bra.s	Spin_Spinner
; ===========================================================================

Spin_Trapdoor:
		subq.w	#1,obSpin_WaitTime(a0)		; decrement timer
		bpl.s	.animate					; if time remains, branch

		move.w	obSpin_WaitMaster(a0),obSpin_WaitTime(a0)
		bchg	#0,obAnim(a0)				; switch between opening/closing animations
		bclr	#7,obAnim(a0)				; clear restart flag
		tst.b	obRender(a0)
		bpl.s	.animate
		move.w	#sfx_Door,d0
		jsr		(QueueSound2).w				; play door sound

	.animate:
		lea		Ani_Spin(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)					; is frame number 0 displayed?
		bne.s	.notsolid					; if not, branch
		moveq	#75,d1						; width; save 4 cycles - Filter
		moveq	#12,d2						; height (jumping); save 4 cycles - Filter
		moveq	#13,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================

	.notsolid:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the trapdoor?
		beq.w	RememberState				; if not, branch
		bclr	#staOnObj,(v_player+obStatus).w
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	RememberState
; ===========================================================================

Spin_Spinner:
		move.w	(v_framecount).w,d0			; read frame counter
		and.w	obSpin_TimeSync(a0),d0		; apply bitmask ($3F or $7F)
		bne.s	.delay						; branch if not 0
		move.b	#1,obSpin_SpinFlag(a0)		; set flag (occurs every 64 or 128 frames)

	.delay:
		tst.b	obSpin_SpinFlag(a0)			; is flag set?
		beq.s	.animate					; if not, branch
		subq.w	#1,obSpin_WaitTime(a0)		; decrement timer
		bpl.s	.animate					; branch if time remains
		move.w	obSpin_WaitMaster(a0),obSpin_WaitTime(a0)	; reset timer
		clr.b	obSpin_SpinFlag(a0)
		bchg	#0,obAnim(a0)				; restart animation (switches between identical animations)
		bclr	#7,obAnim(a0)				; clear restart flag

	.animate:
		lea		Ani_Spin(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)					; check	if frame number	0 is displayed
		bne.s	.notsolid2					; if not, branch
		moveq	#27,d1						; width; save 4 cycles - Filter
		moveq	#7,d2						; height (jumping); save 4 cycles - Filter
		moveq	#8,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================

	.notsolid2:
		btst	#staSonicOnObj,obStatus(a0)
		beq.w	RememberState
		bclr	#staOnObj,(v_player+obStatus).w
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	RememberState
; ===========================================================================