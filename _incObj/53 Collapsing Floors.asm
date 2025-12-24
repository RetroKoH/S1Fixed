; ---------------------------------------------------------------------------
; Object 53 - collapsing floors	(MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

CollapseFloor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	CFlo_Index(pc,d0.w),d1
		jmp		CFlo_Index(pc,d1.w)
; ===========================================================================

CFlo_Index:		offsetTable
		offsetTableEntry.w CFlo_Main
		offsetTableEntry.w CFlo_Touch
		offsetTableEntry.w CFlo_Collapse
		offsetTableEntry.w CFlo_WaitFall
		offsetTableEntry.w CFlo_Delete
		offsetTableEntry.w CFlo_WalkOff
; ===========================================================================

CFlo_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_CFlo,obMap(a0)
		move.w	#make_art_tile(ArtTile_MZ_Block,2,0),obGfx(a0)

		cmpi.b	#id_SLZ,(v_zone).w ; check if level is SLZ
		bne.s	.notSLZ

		; SLZ specific code
		move.w	#make_art_tile(ArtTile_SLZ_Collapsing_Floor,2,0),obGfx(a0)
		addq.b	#2,obFrame(a0)
		bra.s	.continue
; ===========================================================================

	.notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w ; check if level is SBZ
		bne.s	.continue
		move.w	#make_art_tile(ArtTile_SBZ_Collapsing_Floor,2,0),obGfx(a0) ; SBZ specific code


	.continue:
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#7,obCFloor_WaitTime(a0)
		move.b	#$44,obDispWid(a0)
; ---------------------------------------------------------------------------

CFlo_Touch:	; Routine 2
		tst.b	obCFloor_TouchFlag(a0)		; has Sonic touched the	object?
		beq.s	.solid						; if not, branch
		tst.b	obCFloor_WaitTime(a0)		; has time delay reached zero?
		beq.w	CFlo_Fragment				; if yes, branch
		subq.b	#1,obCFloor_WaitTime(a0)	; subtract 1 from time

	.solid:
		moveq	#32,d1						; width; save 4 cycles -- Filter
		bsr.w	PlatformObject				; detect collision & goto CFlo_Collapse next if stood on
		tst.b	obSubtype(a0)				; is subtype over $80?
		bpl.w	RememberState				; if not, branch
		btst	#staOnObj,obStatus(a1)
		beq.w	RememberState
		bclr	#0,obRender(a0)
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		bcc.w	RememberState				; branch if Sonic is left of the platform
		bset	#0,obRender(a0)
		bra.w	RememberState
; ===========================================================================

CFlo_Collapse:	; Routine 4
		tst.b	obCFloor_WaitTime(a0)		; has time delay reached zero?
		beq.w	CFlo_Collapse_Now			; if yes, branch
		move.b	#1,obCFloor_TouchFlag(a0)	; set object as	"touched"
		subq.b	#1,obCFloor_WaitTime(a0)	; decrement timer
; ---------------------------------------------------------------------------

CFlo_WalkOff:	; Routine $A
		moveq	#32,d1						; width; save 4 cycles -- Filter
		bsr.w	ExitPlatform				; goto CFlo_Touch next if Sonic leaves platform
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm2
		bra.w	RememberState
; End of function CFlo_WalkOff
; ===========================================================================

CFlo_WaitFall:	; Routine 6
		tst.b	obCFloor_WaitTime(a0)		; has time delay reached zero?
		beq.s	CFlo_TimeZero				; if yes, branch
		tst.b	obCFloor_TouchFlag(a0)		; has Sonic touched the	object?
		bne.w	.has_touched				; if yes, branch
		subq.b	#1,obCFloor_WaitTime(a0)	; decrement timer
		bra.w	DisplaySprite
; ===========================================================================

	.has_touched:
		subq.b	#1,obCFloor_WaitTime(a0)	; decrement timer
		bsr.w	CFlo_WalkOff				; check if Sonic leaves platform
		lea		(v_player).w,a1
		btst	#staOnObj,obStatus(a1)		; is Sonic on platform?
		beq.s	.skip_platform				; if not, branch
		tst.b	obCFloor_WaitTime(a0)
		bne.s	.end						; branch if time delay > 0
		andi.b	#~(maskOnObj+maskPush),obStatus(a1)	; Clear OnObj and Push flags ($D7)
		move.b	#aniID_Run,obAnimNext(a1)	; restart Sonic's animation

	.skip_platform:
		clr.b	obCFloor_TouchFlag(a0)
		move.b	#6,obRoutine(a0)			; -> CFlo_WaitFall

	.end:
		rts	
; ===========================================================================

CFlo_TimeZero:
		bsr.w	ObjectFall_YOnly
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix	
; ===========================================================================

CFlo_Delete:	; Routine 8
		bra.w	DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

CFlo_FragTiming_0:
		dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2		; unused
CFlo_FragTiming_1:
		dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2
; ===========================================================================

CFlo_Fragment:
		clr.b	obCFloor_TouchFlag(a0)

CFlo_Collapse_Now:
		lea		CFlo_FragTiming_0(pc),a4
		btst	#0,obSubtype(a0)			; is subtype = 0?
		beq.s	.type_0						; if yes, branch
		lea		CFlo_FragTiming_1(pc),a4

	.type_0:
		moveq	#7,d1
		addq.b	#1,obFrame(a0)				; use broken frame which comprises 8 sprites
; fallthrough to CollapseObject