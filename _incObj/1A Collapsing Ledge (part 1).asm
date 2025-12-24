; ---------------------------------------------------------------------------
; Object 1A - GHZ collapsing ledge
; ---------------------------------------------------------------------------

CollapseLedge:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ledge_Index(pc,d0.w),d1
		jmp		Ledge_Index(pc,d1.w)
; ===========================================================================
Ledge_Index:	offsetTable
		offsetTableEntry.w	Ledge_Main
		offsetTableEntry.w	Ledge_Touch
		offsetTableEntry.w	Ledge_Collapse
		offsetTableEntry.w	Ledge_Display
		offsetTableEntry.w	Ledge_Delete
		offsetTableEntry.w	Ledge_WalkOff
; ===========================================================================

Ledge_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Ledge_Touch
		move.l	#Map_Ledge,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#7,obLedge_WaitTime(a0)		; set time delay for collapse
		move.b	#$64,obDispWid(a0)
		move.b	obSubtype(a0),obFrame(a0)
		move.b	#$38,obHeight(a0)
		bset	#4,obRender(a0)
; ---------------------------------------------------------------------------

Ledge_Touch:	; Routine 2
		tst.b	obLedge_TouchFlag(a0)		; is ledge collapsing?
		beq.s	.slope						; if not, branch
		tst.b	obLedge_WaitTime(a0)		; has time reached zero?
		beq.w	Ledge_Fragment				; if yes, branch
		subq.b	#1,obLedge_WaitTime(a0)		; subtract 1 from time

.slope:
		moveq	#48,d1						; width
		lea		(Ledge_SlopeData).l,a2		; heightmap
		bsr.w	SlopeObject					; detect collision with Sonic, update relevant flags & goto Ledge_Collapse next
		jmp		(RememberState).l
; ===========================================================================

Ledge_Collapse:	; Routine 4
		tst.b	obLedge_WaitTime(a0)
		beq.w	Ledge_Fragment_2
		move.b	#1,obLedge_TouchFlag(a0)	; set collapse flag
		subq.b	#1,obLedge_WaitTime(a0)
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Subroutine to update Sonic's position and status on ledge
; ---------------------------------------------------------------------------

Ledge_WalkOff:	; Routine $A
		moveq	#48,d1						; width
		bsr.w	ExitPlatform				; allow Sonic to walk off the ledge
		moveq	#48,d1						; width
		lea		(Ledge_SlopeData).l,a2		; heightmap
		move.w	obX(a0),d2
		bsr.w	SlopeObject2				; update Sonic's y position
		jmp		(RememberState).l
; End of function Ledge_WalkOff
; ===========================================================================

Ledge_Display:	; Routine 6
		tst.b	obLedge_WaitTime(a0)		; has time delay reached zero?
		beq.s	Ledge_TimeZero				; if yes, branch
		tst.b	obLedge_TouchFlag(a0)		; is ledge collapsing?
		bne.w	.stood_on					; if yes, branch
		subq.b	#1,obLedge_WaitTime(a0)		; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

	.stood_on:
		subq.b	#1,obLedge_WaitTime(a0)		; decrement timer
		bsr.w	Ledge_WalkOff				; update Sonic's y position & platform status
		lea		(v_player).w,a1
		btst	#staOnObj,obStatus(a1)		; is Sonic on ledge?
		beq.s	.platform_clear				; if not, branch
		tst.b	obLedge_WaitTime(a0)		; has time reached 0?
		bne.s	.exit						; if not, branch
		andi.b	#~(maskOnObj+maskPush),obStatus(a1)	; Clear OnObj and Push flags ($D7)
		move.b	#aniID_Run,obAnimNext(a1)			; restart Sonic's animation

	.platform_clear:
		clr.b	obLedge_TouchFlag(a0)
		move.b	#6,obRoutine(a0)			; -> Ledge_Display

	.exit:
		rts	
; ===========================================================================

Ledge_TimeZero:
		bsr.w	ObjectFall_YOnly
		tst.b	obRender(a0)
		bpl.w	DeleteObject				; is object on-screen?
		bra.w	DisplaySprite				; if not, branch -- Clownacy DisplaySprite Fix
; ===========================================================================

Ledge_Delete:	; Routine 8
		bra.w	DeleteObject	
; ===========================================================================

; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges
; ---------------------------------------------------------------------------
Ledge_FragTiming:
		dc.b $1C, $18, $14, $10, $1A, $16, $12,	$E, $A,	6, $18,	$14, $10, $C, 8, 4
		dc.b $16, $12, $E, $A, 6, 2, $14, $10, $C, 0
; ===========================================================================

Ledge_Fragment:
		clr.b	obLedge_TouchFlag(a0)

Ledge_Fragment_2:
		lea		Ledge_FragTiming(pc),a4		; fragment timing data
		moveq	#$18,d1						; number of fragments, minus 1
		addq.b	#2,obFrame(a0)				; use frame consisting of smaller pieces
		bra.w	CollapseObject
; ===========================================================================