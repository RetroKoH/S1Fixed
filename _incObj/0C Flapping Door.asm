; ---------------------------------------------------------------------------
; Object 0C - flapping door (LZ)
; Rewritten by Hivebrain to work when x-flipped; now solid from both sides
; ---------------------------------------------------------------------------

FlapDoor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Flap_Index(pc,d0.w),d1
		jmp		Flap_Index(pc,d1.w)
; ===========================================================================

Flap_Index:	offsetTable
		offsetTableEntry.w Flap_Main
	; New open/close routines
		offsetTableEntry.w Flap_Opening
		offsetTableEntry.w Flap_Open
		offsetTableEntry.w Flap_Open2
		offsetTableEntry.w Flap_Closing
		offsetTableEntry.w Flap_Closed
		offsetTableEntry.w Flap_Closed2
; ===========================================================================

Flap_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Flap,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Flapping_Door,2,0),obGfx(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		ori.b	#4,obRender(a0)
		move.b	#$28,obDispWid(a0)
		moveq	#$F,d0
		and.b	obSubtype(a0),d0			; get object type (clamp at 0-F)
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,obFlap_Time(a0)			; set flap delay time

Flap_Opening:	; Routine 2
Flap_Closing:	; Routine 8
		lea		Ani_Flap(pc),a1
		jsr		(AnimateSprite).w			; only animate on opening/closing routines
		clr.b	(f_wtunnelallow).w			; enable wind tunnel
		cmpi.b	#2,obFrame(a0)				; is the door open?
		beq.s	.open						; branch if fully open
		moveq	#19,d1						; width; save 4 cycles - Filter
		moveq	#32,d2						; height (jumping); save 4 cycles - Filter
		moveq	#33,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		move.w	obX(a0),d0
		sub.w	obX(a1),d0
		bmi.w	RememberState				; branch if Sonic is to the right
		move.b	#1,(f_wtunnelallow).w		; disable water tunnel
		bra.w	RememberState
; ===========================================================================

	.open:
		lea		(v_player).w,a1
		bclr	#staSonicOnObj,obStatus(a0)
		beq.s	.skip_top					; branch if Sonic isn't standing on the object
		bclr	#staOnObj,obStatus(a1)		; remove platform effect
		bset	#staAir,obStatus(a1)		; make Sonic airborne

	.skip_top:
		bclr	#staSonicPush,obStatus(a0)
		beq.w	RememberState				; branch if Sonic isn't pushing the object
		bclr	#staPush,obStatus(a1)		; remove pushing effect
		bra.w	RememberState
; ===========================================================================

Flap_Open:	; Routine 4
		move.w	obFlap_Time(a0),obFlap_Wait(a0) ; reset time delay
		addq.b	#2,obRoutine(a0)				; -> Flap_Open2

Flap_Open2:	; Routine 6
		subq.w	#1,obFlap_Wait(a0)				; decrement time delay
		bpl.w	RememberState					; branch if time remains
		move.b	#1,obAnim(a0)					; closing animation
		addq.b	#2,obRoutine(a0)				; -> Flap_Closing
		tst.b	obRender(a0)
		bpl.w	RememberState					; branch if not on screen
		move.w	#sfx_Door,d0
		jsr		(QueueSound2).w					; play door sound
		bra.w	RememberState
; ===========================================================================

Flap_Closed:	; Routine $A
		move.w	obFlap_Time(a0),obFlap_Wait(a0) ; reset time delay
		addq.b	#2,obRoutine(a0)				; -> Flap_Closed2

Flap_Closed2:	; Routine $C
		moveq	#19,d1							; width; save 4 cycles - Filter
		moveq	#32,d2							; height (jumping); save 4 cycles - Filter
		moveq	#33,d3							; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4						; axis position
		bsr.w	SolidObject
		subq.w	#1,obFlap_Wait(a0)				; decrement time delay
		bpl.w	RememberState					; branch if time remains
		move.b	#0,obAnim(a0)
		move.b	#2,obRoutine(a0)				; -> Flap_Opening
		tst.b	obRender(a0)
		bpl.w	RememberState					; branch if not on screen
		move.w	#sfx_Door,d0
		jsr		(QueueSound2).w					; play door sound
		bra.w	RememberState
; ===========================================================================