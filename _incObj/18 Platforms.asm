; ---------------------------------------------------------------------------
; Object 18 - platforms	(GHZ, SYZ, SLZ)
; ---------------------------------------------------------------------------
; OST Constants
obPlat_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obPlat_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obPlat_PrevX:			equ objoff_34		; 2 bytes | previous X-axis position (used instead of pushing to the stack)
obPlat_BaseY:			equ objoff_36		; 2 bytes | y position ignoring dip when Sonic is on the platform
obPlat_WaitTime:		equ objoff_38		; 2 bytes | time delay for platform moving when stood on
obPlat_DipPixels:		equ objoff_3A		; 1 byte  | amount of dip when Sonic is on the platform
; ---------------------------------------------------------------------------

BasicPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Plat_Index(pc,d0.w),d1
		jmp		Plat_Index(pc,d1.w)
; ===========================================================================

Plat_Index:		offsetTable
		offsetTableEntry.w Plat_Main
		offsetTableEntry.w Plat_Solid
		offsetTableEntry.w Plat_StoodOn
		offsetTableEntry.w Plat_Delete
		offsetTableEntry.w Plat_Action
; ===========================================================================

Plat_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> Plat_Solid
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.l	#Map_Plat_GHZ,obMap(a0)
		move.b	#$20,obDispWid(a0)
		cmpi.b	#id_SYZ,(v_zone).w				; check if level is SYZ
		bne.s	.notSYZ

	; SYZ specific code
		move.l	#Map_Plat_SYZ,obMap(a0)
		bra.s	.continue
; ===========================================================================

	.notSYZ:
		cmpi.b	#id_SLZ,(v_zone).w				; check if level is SLZ
		bne.s	.continue

	; SLZ specific code
		move.l	#Map_Plat_SLZ,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#3,obSubtype(a0)				; force subtype 3 (_Falling)
; ---------------------------------------------------------------------------

	.continue:
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),obPlat_BaseY(a0)
		move.w	obY(a0),obPlat_StartY(a0)
		move.w	obX(a0),obPlat_StartX(a0)
		move.w	#$80,obAngle(a0)
		moveq	#0,d1
		move.b	obSubtype(a0),d0
		cmpi.b	#$A,d0							; is object type $A (large platform)?
		bne.s	.setframe						; if not, branch
		addq.b	#1,d1							; use frame #1

	.setframe:
		move.b	d1,obFrame(a0)					; set frame to d1
; ---------------------------------------------------------------------------

Plat_Solid:	; Routine 2
		tst.b	obPlat_DipPixels(a0)				; has platform dipped from being stood on?
		beq.s	.no_dip							; if not, branch
		subq.b	#4,obPlat_DipPixels(a0)			; decrement dip amount

	.no_dip:
		moveq	#0,d1
		move.b	obDispWid(a0),d1				; width
		bsr.w	PlatformObject					; detect collision, update flags, goto Plat_StoodOn next if stood on
; ---------------------------------------------------------------------------

Plat_Action:	; Routine 8
		bsr.w	Plat_Move						; move platform
		bsr.w	Plat_Nudge						; apply nudge
		bra.w	Plat_ChkDel						; Clownacy DisplaySprite Fix
; ===========================================================================

Plat_StoodOn:	; Routine 4
		cmpi.b	#$40,obPlat_DipPixels(a0)			; is platform at max dip?
		beq.s	.max_dip						; if yes, branch
		addq.b	#4,obPlat_DipPixels(a0)			; increment dip

	.max_dip:
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		bsr.w	ExitPlatform					; detect Sonic leaving platform, goto Plat_Solid next if he does
		move.w	obX(a0),obPlat_PrevX(a0)
		bsr.w	Plat_Move
		bsr.w	Plat_Nudge
		move.w	obPlat_PrevX(a0),d2
		bsr.w	MvSonicOnPtfm2
		bra.w	Plat_ChkDel						; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	move platform slightly when you	stand on it
; ---------------------------------------------------------------------------

Plat_Nudge:
		move.b	obPlat_DipPixels(a0),d0			; get nudge value
		calcsine_direct							; convert to sine/cosine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	obPlat_BaseY(a0),d0				; add to base Y-axis position (sans nudge)
		move.w	d0,obY(a0)						; update position
		rts	
; End of function Plat_Nudge
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	move platforms
; ---------------------------------------------------------------------------

Plat_Move:
		moveq	#$F,d0
		and.b	obSubtype(a0),d0				; read low nybble of subtype (SCE Optimization)
		beq.s	PlatMove_Type_Still				; skip if subtype 00
		add.w	d0,d0
		move.w	PlatMove_Index-2(pc,d0.w),d1
		jmp		PlatMove_Index(pc,d1.w)
; End of function Plat_Move
; ===========================================================================

PlatMove_Index:		offsetTable
		offsetTableEntry.w PlatMove_Type_Horizontal
		offsetTableEntry.w PlatMove_Type_Vertical
		offsetTableEntry.w PlatMove_Type_Falling
		offsetTableEntry.w PlatMove_Type_FallsNow
		offsetTableEntry.w PlatMove_Type_Horizontal_Rev
		offsetTableEntry.w PlatMove_Type_Vertical_Rev
		offsetTableEntry.w PlatMove_Type_Rising
		offsetTableEntry.w PlatMove_Type_RisesNow
		offsetTableEntry.w PlatMove_Type_Still
		offsetTableEntry.w PlatMove_Type_Pillar
		offsetTableEntry.w PlatMove_Type_SlowVertical
		offsetTableEntry.w PlatMove_Type_SlowVertical_Rev
; ===========================================================================

; Types 0, 9
PlatMove_Type_Still:
		rts							; platform 00 doesn't move
; ===========================================================================

; Type 5
PlatMove_Type_Horizontal_Rev:
		move.w	obPlat_StartX(a0),d0
		move.b	obAngle(a0),d1		; load platform-motion variable
		neg.b	d1					; reverse platform-motion
		addi.b	#$40,d1
		bra.s	PlatMove_Type_Horizontal_move
; ===========================================================================

; Type 1
PlatMove_Type_Horizontal:
		move.w	obPlat_StartX(a0),d0
		move.b	obAngle(a0),d1		; load platform-motion variable
		subi.b	#$40,d1

PlatMove_Type_Horizontal_move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,obX(a0)			; change position on x-axis
;	.chgmotion
		move.b	(v_oscillate+$1A).w,obAngle(a0) ; update platform-movement variable
		rts
; ===========================================================================

; Type $C
PlatMove_Type_SlowVertical_Rev:
		move.w	obPlat_StartY(a0),d0
		move.b	(v_oscillate+$E).w,d1	; load platform-motion variable
		neg.b	d1						; reverse platform-motion
		addi.b	#$30,d1
		bra.s	PlatMove_Type_Vertical_move
; ===========================================================================

; Type $B
PlatMove_Type_SlowVertical:
		move.w	obPlat_StartY(a0),d0
		move.b	(v_oscillate+$E).w,d1	; load platform-motion variable
		subi.b	#$30,d1
		bra.s	PlatMove_Type_Vertical_move
; ===========================================================================

; Type 6
PlatMove_Type_Vertical_Rev:
		move.w	obPlat_StartY(a0),d0
		move.b	obAngle(a0),d1			; load platform-motion variable
		neg.b	d1						; reverse platform-motion
		addi.b	#$40,d1
		bra.s	PlatMove_Type_Vertical_move
; ===========================================================================

; Type 2
PlatMove_Type_Vertical:
		move.w	obPlat_StartY(a0),d0
		move.b	obAngle(a0),d1			; load platform-motion variable
		subi.b	#$40,d1

PlatMove_Type_Vertical_move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,obPlat_BaseY(a0)		; change position on y-axis
;	.chgmotion
		move.b	(v_oscillate+$1A).w,obAngle(a0) ; update platform-movement variable
		rts
; ===========================================================================

; Type 3
PlatMove_Type_Falling:
		tst.w	obPlat_WaitTime(a0)			; is time delay	set?
		bne.s	.wait						; if yes, branch
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the platform?
		beq.s	.nomove						; if not, branch
		move.w	#30,obPlat_WaitTime(a0)		; set time delay to 0.5	seconds

	.nomove:
		rts	
; ===========================================================================

	.wait:
		subq.w	#1,obPlat_WaitTime(a0)		; subtract 1 from time
		bne.s	.nomove						; if time is > 0, branch
		move.w	#32,obPlat_WaitTime(a0)
		addq.b	#1,obSubtype(a0)			; change to type 04 (falling)
		rts	
; ===========================================================================

; Type 4
PlatMove_Type_FallsNow:
		tst.w	obPlat_WaitTime(a0)			; check timer
		beq.s	.wait						; branch if time is 0
		subq.w	#1,obPlat_WaitTime(a0)		; decrement timer
		bne.s	.wait						; branch if time remains
		btst	#staSonicOnObj,obStatus(a0)
		beq.s	.skip_sonic					; branch if Sonic isn't on platform
		bset	#staAir,obStatus(a1)
		bclr	#staOnObj,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#staSonicOnObj,obStatus(a0)
		move.w	obVelY(a0),obVelY(a1)		; pull Sonic down with platform

	.skip_sonic:
		move.b	#8,obRoutine(a0)			; -> Plat_Action (same as Plat_Solid without platform detection)

	.wait:
		move.l	obPlat_BaseY(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3						; add falling speed to y pos
		move.l	d3,obPlat_BaseY(a0)			; update y pos
		addi.w	#$38,obVelY(a0)				; apply gravity
		move.w	(v_limitbtm).w,d0
		addi.w	#224,d0						; d0 = y pos of bottom edge of level
		cmp.w	obPlat_BaseY(a0),d0
		bhs.s	.within_level				; if platform is inside level, branch
		move.b	#6,obRoutine(a0)			; else, goto Plat_Delete next

	.within_level:
		rts	
; ===========================================================================

; Type 7
PlatMove_Type_Rising:
		tst.w	obPlat_WaitTime(a0)			; is time delay	set?
		bne.s	.wait						; if yes, branch
		lea		(f_switch).w,a2				; load switch statuses
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; move object type ($x7) to d0
		lsr.w	#4,d0						; divide d0 by 8, round	down
		tst.b	(a2,d0.w)					; has switch no. d0 been pressed?
		beq.s	.nomove	; if not, branch
		move.w	#60,obPlat_WaitTime(a0)		; set time delay to 1 second

	.nomove:
		rts	
; ===========================================================================

	.wait:
		subq.w	#1,obPlat_WaitTime(a0)		; subtract 1 from time delay
		bne.s	.nomove						; if time is > 0, branch
		addq.b	#1,obSubtype(a0)			; change to type 08
		rts	
; ===========================================================================

; Type 8
PlatMove_Type_RisesNow:
		subq.w	#2,obPlat_BaseY(a0)			; move platform	up
		move.w	obPlat_StartY(a0),d0
		subi.w	#$200,d0
		cmp.w	obPlat_BaseY(a0),d0			; has platform moved $200 pixels?
		bne.s	.nostop						; if not, branch
		clr.b	obSubtype(a0)				; change to type 00 (stop moving)

	.nostop:
		rts	
; ===========================================================================

PlatMove_Type_Pillar:
		move.w	obPlat_StartY(a0),d0
		move.b	obAngle(a0),d1				; load platform-motion variable
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,obPlat_BaseY(a0)			; change position on y-axis
;	.chgmotion
		move.b	(v_oscillate+$1A).w,obAngle(a0)	; update platform-movement variable
		rts
; ===========================================================================

Plat_ChkDel:
		offscreen.w	DeleteObject,obPlat_StartX(a0)	; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite						; Clownacy DisplaySprite Fix
; ===========================================================================

Plat_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================