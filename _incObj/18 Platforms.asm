; ---------------------------------------------------------------------------
; Object 18 - platforms	(GHZ, SYZ, SLZ)
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
		offsetTableEntry.w Plat_Action2
		offsetTableEntry.w Plat_Delete
		offsetTableEntry.w Plat_Action
; ===========================================================================

Plat_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.l	#Map_Plat_GHZ,obMap(a0)
		move.b	#$20,obDispWid(a0)
		cmpi.b	#id_SYZ,(v_zone).w ; check if level is SYZ
		bne.s	.notSYZ

		move.l	#Map_Plat_SYZ,obMap(a0) ; SYZ specific code
		move.b	#$20,obDispWid(a0)

.notSYZ:
		cmpi.b	#id_SLZ,(v_zone).w ; check if level is SLZ
		bne.s	.notSLZ
		move.l	#Map_Plat_SLZ,obMap(a0) ; SLZ specific code
		move.b	#$20,obDispWid(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#3,obSubtype(a0)

.notSLZ:
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),obPlat_BaseY(a0)
		move.w	obY(a0),obPlat_StartY(a0)
		move.w	obX(a0),obPlat_StartX(a0)
		move.w	#$80,obAngle(a0)
		moveq	#0,d1
		move.b	obSubtype(a0),d0
		cmpi.b	#$A,d0		; is object type $A (large platform)?
		bne.s	.setframe	; if not, branch
		addq.b	#1,d1		; use frame #1
		move.b	#$20,obDispWid(a0) ; set width

.setframe:
		move.b	d1,obFrame(a0)	; set frame to d1

Plat_Solid:	; Routine 2
		tst.b	obPlat_NudgeY(a0)
		beq.s	.no_dip
		subq.b	#4,obPlat_NudgeY(a0)

	.no_dip:
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		bsr.w	PlatformObject

Plat_Action:	; Routine 8
		bsr.w	Plat_Move
		bsr.w	Plat_Nudge
		bra.w	Plat_ChkDel		; Clownacy DisplaySprite Fix
; ===========================================================================

Plat_Action2:	; Routine 4
		cmpi.b	#$40,obPlat_NudgeY(a0)
		beq.s	.max_dip
		addq.b	#4,obPlat_NudgeY(a0)

	.max_dip:
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		bsr.w	ExitPlatform
		move.w	obX(a0),-(sp)
		bsr.w	Plat_Move
		bsr.w	Plat_Nudge
		move.w	(sp)+,d2
		bsr.w	MvSonicOnPtfm2
		bra.w	Plat_ChkDel		; Clownacy DisplaySprite Fix

; ---------------------------------------------------------------------------
; Subroutine to	move platform slightly when you	stand on it
; ---------------------------------------------------------------------------

Plat_Nudge:
		move.b	obPlat_NudgeY(a0),d0		; get nudge value
		bsr.w	CalcSine					; convert to sine/cosine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	obPlat_BaseY(a0),d0			; add to base Y-axis position (sans nudge)
		move.w	d0,obY(a0)					; update position
		rts	
; End of function Plat_Nudge

; ---------------------------------------------------------------------------
; Subroutine to	move platforms
; ---------------------------------------------------------------------------

Plat_Move:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0						; read low nybble of subtype
		add.w	d0,d0
		move.w	PlatMove_Index(pc,d0.w),d1
		jmp		PlatMove_Index(pc,d1.w)
; End of function Plat_Move

; ===========================================================================
PlatMove_Index:		offsetTable
		offsetTableEntry.w PlatMove_Type_Still
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

PlatMove_Type_Still:
		rts			; platform 00 doesn't move
; ===========================================================================

PlatMove_Type_Horizontal_Rev:
		move.w	obPlat_StartX(a0),d0
		move.b	obAngle(a0),d1	; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$40,d1
		bra.s	PlatMove_Type_Horizontal_move
; ===========================================================================

PlatMove_Type_Horizontal:
		move.w	obPlat_StartX(a0),d0
		move.b	obAngle(a0),d1	; load platform-motion variable
		subi.b	#$40,d1

PlatMove_Type_Horizontal_move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,obX(a0)	; change position on x-axis
;	.chgmotion
		move.b	(v_oscillate+$1A).w,obAngle(a0) ; update platform-movement variable
		rts
; ===========================================================================

PlatMove_Type_SlowVertical_Rev:
		move.w	obPlat_StartY(a0),d0
		move.b	(v_oscillate+$E).w,d1 ; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$30,d1
		bra.s	PlatMove_Type_Vertical_move
; ===========================================================================

PlatMove_Type_SlowVertical:
		move.w	obPlat_StartY(a0),d0
		move.b	(v_oscillate+$E).w,d1 ; load platform-motion variable
		subi.b	#$30,d1
		bra.s	PlatMove_Type_Vertical_move
; ===========================================================================

PlatMove_Type_Vertical_Rev:
		move.w	obPlat_StartY(a0),d0
		move.b	obAngle(a0),d1	; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$40,d1
		bra.s	PlatMove_Type_Vertical_move
; ===========================================================================

PlatMove_Type_Vertical:
		move.w	obPlat_StartY(a0),d0
		move.b	obAngle(a0),d1	; load platform-motion variable
		subi.b	#$40,d1

PlatMove_Type_Vertical_move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,obPlat_BaseY(a0)	; change position on y-axis
;	.chgmotion
		move.b	(v_oscillate+$1A).w,obAngle(a0) ; update platform-movement variable
		rts
; ===========================================================================

PlatMove_Type_Falling:
		tst.w	obPlat_WaitTime(a0)				; is time delay	set?
		bne.s	PlatMove_Type_Falling_wait				; if yes, branch
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the platform?
		beq.s	PlatMove_Type_Falling_nomove				; if not, branch
		move.w	#30,obPlat_WaitTime(a0)			; set time delay to 0.5	seconds

PlatMove_Type_Falling_nomove:
		rts	

PlatMove_Type_Falling_wait:
		subq.w	#1,obPlat_WaitTime(a0)			; subtract 1 from time
		bne.s	PlatMove_Type_Falling_nomove				; if time is > 0, branch
		move.w	#32,obPlat_WaitTime(a0)
		addq.b	#1,obSubtype(a0)			; change to type 04 (falling)
		rts	
; ===========================================================================

PlatMove_Type_FallsNow:
		tst.w	obPlat_WaitTime(a0)
		beq.s	.loc_8048
		subq.w	#1,obPlat_WaitTime(a0)
		bne.s	.loc_8048
		btst	#staSonicOnObj,obStatus(a0)
		beq.s	.loc_8042
		bset	#staAir,obStatus(a1)
		bclr	#staOnObj,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#staSonicOnObj,obStatus(a0)
		clr.b	ob2ndRout(a0)				; unused???
		move.w	obVelY(a0),obVelY(a1)

.loc_8042:
		move.b	#8,obRoutine(a0)

.loc_8048:
		move.l	obPlat_BaseY(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d3,obPlat_BaseY(a0)
		addi.w	#$38,obVelY(a0)
		move.w	(v_limitbtm).w,d0
		addi.w	#$E0,d0
		cmp.w	obPlat_BaseY(a0),d0
		bhs.s	.locret_8074
		move.b	#6,obRoutine(a0)

.locret_8074:
		rts	
; ===========================================================================

PlatMove_Type_Rising:
		tst.w	obPlat_WaitTime(a0)		; is time delay	set?
		bne.s	PlatMove_Type_Rising_wait	; if yes, branch
		lea	(f_switch).w,a2	; load switch statuses
		moveq	#0,d0
		move.b	obSubtype(a0),d0 ; move object type ($x7) to d0
		lsr.w	#4,d0		; divide d0 by 8, round	down
		tst.b	(a2,d0.w)	; has switch no. d0 been pressed?
		beq.s	PlatMove_Type_Rising_nomove	; if not, branch
		move.w	#60,obPlat_WaitTime(a0)	; set time delay to 1 second

PlatMove_Type_Rising_nomove:
		rts	

PlatMove_Type_Rising_wait:
		subq.w	#1,obPlat_WaitTime(a0)	; subtract 1 from time delay
		bne.s	PlatMove_Type_Rising_nomove	; if time is > 0, branch
		addq.b	#1,obSubtype(a0) ; change to type 08
		rts	
; ===========================================================================

PlatMove_Type_RisesNow:
		subq.w	#2,obPlat_BaseY(a0)	; move platform	up
		move.w	obPlat_StartY(a0),d0
		subi.w	#$200,d0
		cmp.w	obPlat_BaseY(a0),d0	; has platform moved $200 pixels?
		bne.s	PlatMove_Type_RisesNow_nostop	; if not, branch
		clr.b	obSubtype(a0)	; change to type 00 (stop moving)

PlatMove_Type_RisesNow_nostop:
		rts	
; ===========================================================================

PlatMove_Type_Pillar:
		move.w	obPlat_StartY(a0),d0
		move.b	obAngle(a0),d1	; load platform-motion variable
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,obPlat_BaseY(a0)	; change position on y-axis
;	.chgmotion
		move.b	(v_oscillate+$1A).w,obAngle(a0) ; update platform-movement variable
		rts
; ===========================================================================

Plat_ChkDel:
		offscreen.s	Plat_Delete,obPlat_StartX(a0)	; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite					; Clownacy DisplaySprite Fix
; ===========================================================================

Plat_Delete:	; Routine 6
		bra.w	DeleteObject
