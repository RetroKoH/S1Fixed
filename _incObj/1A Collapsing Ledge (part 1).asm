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

ledge_timedelay = objoff_38		; time between touching the ledge and it collapsing
ledge_collapse_flag = objoff_3A		; collapse flag
; ===========================================================================

Ledge_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Ledge,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#7,ledge_timedelay(a0)		; set time delay for collapse
		move.b	#$64,obActWid(a0)
		move.b	obSubtype(a0),obFrame(a0)
		move.b	#$38,obHeight(a0)
		bset	#4,obRender(a0)

Ledge_Touch:	; Routine 2
		tst.b	ledge_collapse_flag(a0)	; is ledge collapsing?
		beq.s	.slope					; if not, branch
		tst.b	ledge_timedelay(a0)		; has time reached zero?
		beq.w	Ledge_Fragment			; if yes, branch
		subq.b	#1,ledge_timedelay(a0)	; subtract 1 from time

.slope:
		move.w	#$30,d1
		lea		(Ledge_SlopeData).l,a2
		bsr.w	SlopeObject
		jmp		(RememberState).l
; ===========================================================================

Ledge_Collapse:	; Routine 4
		tst.b	ledge_timedelay(a0)
		beq.w	loc_847A
		move.b	#1,ledge_collapse_flag(a0)	; set collapse flag
		subq.b	#1,ledge_timedelay(a0)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Ledge_WalkOff:	; Routine $A
		move.w	#$30,d1
		bsr.w	ExitPlatform
		move.w	#$30,d1
		lea		(Ledge_SlopeData).l,a2
		move.w	obX(a0),d2
		bsr.w	SlopeObject2
		jmp		(RememberState).l
; End of function Ledge_WalkOff

; ===========================================================================

Ledge_Display:	; Routine 6
		tst.b	ledge_timedelay(a0)	; has time delay reached zero?
		beq.s	Ledge_TimeZero	; if yes, branch
		tst.b	ledge_collapse_flag(a0)	; is ledge collapsing?
		bne.w	loc_82D0	; if yes, branch
		subq.b	#1,ledge_timedelay(a0) ; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

loc_82D0:
		subq.b	#1,ledge_timedelay(a0)
		bsr.w	Ledge_WalkOff
		lea		(v_player).w,a1
		btst	#staOnObj,obStatus(a1)
		beq.s	loc_82FC
		tst.b	ledge_timedelay(a0)
		bne.s	locret_8308
		andi.b	#~(maskOnObj+maskPush),obStatus(a1)	; Clear OnObj and Push flags ($D7)
		move.b	#aniID_Run,obPrevAni(a1)			; restart Sonic's animation

loc_82FC:
		clr.b	ledge_collapse_flag(a0)
		move.b	#6,obRoutine(a0)					; run "Ledge_Display" routine

locret_8308:
		rts	
; ===========================================================================

Ledge_TimeZero:
		bsr.w	ObjectFall_YOnly
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
; ===========================================================================

Ledge_Delete:	; Routine 8
		bra.w	DeleteObject	
