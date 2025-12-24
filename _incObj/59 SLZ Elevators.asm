; ---------------------------------------------------------------------------
; Object 59 - platforms	that move when you stand on them (SLZ)
; ---------------------------------------------------------------------------

Elevator:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Elev_Index(pc,d0.w),d1
		jsr		Elev_Index(pc,d1.w)
		offscreen.w	DeleteObject,obElev_StartX(a0)	; PFM S3K Obj
		bra.w	DisplaySprite
; ===========================================================================
Elev_Index:		offsetTable
		offsetTableEntry.w Elev_Main
		offsetTableEntry.w Elev_Platform
		offsetTableEntry.w Elev_StoodOn
		offsetTableEntry.w Elev_MakeMulti

Elev_Vars:
		; distance to move, action type
		dc.b $10, 1
		dc.b $20, 1
		dc.b $34, 1				; unused
		dc.b $10, 3
		dc.b $20, 3				; unused
		dc.b $34, 3				; unused
		dc.b $14, 1				; unused
		dc.b $24, 1				; unused
		dc.b $2C, 1				; unused
		dc.b $14, 3				; unused
		dc.b $24, 3				; unused
		dc.b $2C, 3				; unused
		dc.b $20, 5
		dc.b $20, 7				; unused
		dc.b $30, 9
; ===========================================================================

Elev_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		bpl.s	.normal						; branch for types 00-7F

	; Elevator Spawners:
		addq.b	#4,obRoutine(a0)			; -> Elev_MakeMulti
		andi.w	#$7F,d0
		add.w	d0,d0						; multiply by 6
		move.w	d0,d1						; Optimization from S1 in S.C.E.
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,obElev_Dist(a0)			; set as time between platform spawns
		move.w	d0,obElev_DistCopy(a0)
		addq.l	#4,sp
		rts	
; ===========================================================================

.normal:
		move.b	#$28,obDispWid(a0)			; set width (Set directly instead of using a table)
		clr.b	obFrame(a0)					; set frame (A table for only two values was unnecessary)
	; we still have the subtype stored in d0
		add.w	d0,d0
		andi.w	#$1E,d0						; read only low nybble
		lea		Elev_Vars(pc,d0.w),a2
		move.b	(a2)+,d0					; get distance value
		lsl.w	#2,d0						; multiply by 4
		move.w	d0,obElev_Dist(a0)			; set distance to move
		move.b	(a2)+,obSubtype(a0)			; set type
		move.l	#Map_Elev,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),obElev_StartX(a0)
		move.w	obY(a0),obElev_StartY(a0)
; ---------------------------------------------------------------------------

Elev_Platform:	; Routine 2
		moveq	#0,d1
		move.b	obDispWid(a0),d1			; width
		jsr		(PlatformObject).l			; detect collision & goto Elev_StoodOn next if stood on
		bra.w	Elev_Types
; ===========================================================================

Elev_StoodOn:	; Routine 4
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		jsr		(ExitPlatform).l			; goto Elev_Platform next if Sonic leaves platform
		move.w	obX(a0),obElev_PrevX(a0)	; store pre-movement x-position
		bsr.w	Elev_Types
		move.w	obElev_PrevX(a0),d2			; restore pre-movement x-position
		_tst.l	obAddr(a0)					; does object still exist?
		beq.s	.deleted					; if not, branch
		jmp		(MvSonicOnPtfm2).l			; update Sonic's position

.deleted:
		; Avoid returning to Elevator to prevent display-and-delete
		; and double-delete bugs (Is this still needed?).
;		addq.l	#4,sp
		rts	
; ===========================================================================

Elev_Types:
		moveq	#$F,d0						; read only low nybble (SCE Optimization)
		and.b	obSubtype(a0),d0			; subtype has changed by now, see Elev_Var2
		beq.s	Elev_Still
		add.w	d0,d0
		move.w	Elev_TypeIndex(pc,d0.w),d1
		jmp		Elev_TypeIndex(pc,d1.w)
; ===========================================================================
Elev_TypeIndex:		offsetTable
		offsetTableEntry.w Elev_Still
		offsetTableEntry.w Elev_Up
		offsetTableEntry.w Elev_Up_Now
		offsetTableEntry.w Elev_Down
		offsetTableEntry.w Elev_Down_Now
		offsetTableEntry.w Elev_UpRight
		offsetTableEntry.w Elev_UpRight_Now
		offsetTableEntry.w Elev_DownLeft
		offsetTableEntry.w Elev_DownLeft_Now
		offsetTableEntry.w Elev_UpVanish
; ===========================================================================

Elev_Up:
Elev_Down:
Elev_UpRight:
Elev_DownLeft:
		cmpi.b	#4,obRoutine(a0)			; check if Sonic is standing on the object
		bne.s	.notstanding				; if not, branch
		addq.b	#1,obSubtype(a0)			; if yes, add 1 to type (goes to 2, 4, 6 or 8)

	.notstanding:
Elev_Still:
		rts	
; ===========================================================================

Elev_Up_Now:
		bsr.w	Elev_Move					; update distance moved
		move.w	obElev_DistMoved(a0),d0		; get distance moved
		neg.w	d0							; invert
		add.w	obElev_StartY(a0),d0		; combine with start position
		move.w	d0,obY(a0)					; update y position
		rts	
; ===========================================================================

Elev_Down_Now:
		bsr.w	Elev_Move					; update distance moved
		move.w	obElev_DistMoved(a0),d0
		add.w	obElev_StartY(a0),d0
		move.w	d0,obY(a0)					; update y position
		rts	
; ===========================================================================

Elev_UpRight_Now:
		bsr.w	Elev_Move					; update distance moved
		move.w	obElev_DistMoved(a0),d0		; get distance moved
		asr.w	#1,d0						; divide by 2
		neg.w	d0							; invert
		add.w	obElev_StartY(a0),d0		; combine with start position
		move.w	d0,obY(a0)					; update y position (moves half as far as x distance)
		move.w	obElev_DistMoved(a0),d0		; get distance moved
		add.w	obElev_StartX(a0),d0		; combine with start position
		move.w	d0,obX(a0)					; update x position
		rts	
; ===========================================================================

Elev_DownLeft_Now:
		bsr.w	Elev_Move					; update distance moved
		move.w	obElev_DistMoved(a0),d0		; get distance moved
		asr.w	#1,d0						; divide by 2
		add.w	obElev_StartY(a0),d0		; combine with start position
		move.w	d0,obY(a0)					; update y position (moves half as far as x distance)
		move.w	obElev_DistMoved(a0),d0		; get distance moved
		neg.w	d0							; invert
		add.w	obElev_StartX(a0),d0		; combine with start position
		move.w	d0,obX(a0)					; update x position
		rts	
; ===========================================================================

Elev_UpVanish:
		bsr.w	Elev_Move					; update distance moved
		move.w	obElev_DistMoved(a0),d0		; get distance moved
		neg.w	d0							; invert
		add.w	obElev_StartY(a0),d0		; combine with start position
		move.w	d0,obY(a0)					; update y position
		tst.b	obSubtype(a0)				; has platform reached destination and stopped?
		beq.w	.typereset					; if yes, branch
		rts	
; ===========================================================================

	.typereset:
		btst	#staSonicOnObj,obStatus(a0)	; is platform being stood on?
		beq.w	DeleteObject				; if not, branch
		bset	#staAir,obStatus(a1)
		bclr	#staOnObj,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bra.w	DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update the distance moved value
; ---------------------------------------------------------------------------

Elev_Move:
		move.w	obElev_AccelRate(a0),d0		; get current acceleration
		tst.b	obElev_DecelFlag(a0)		; is platform in deceleration phase?
		bne.s	.decelerate					; if yes, branch
		cmpi.w	#$800,d0					; is acceleration at or above max?
		bhs.s	.update_acc					; if yes, branch
		addi.w	#$10,d0						; increase acceleration
		bra.s	.update_acc
; ===========================================================================

	.decelerate:
		tst.w	d0							; is acceleration 0?
		beq.s	.update_acc					; if yes, branch
		subi.w	#$10,d0						; decrease acceleration

	.update_acc:
		move.w	d0,obElev_AccelRate(a0)		; set new acceleration
		ext.l	d0
		asl.l	#8,d0						; multiply by $100
		add.l	obElev_DistMoved(a0),d0		; add total previous movement
		move.l	d0,obElev_DistMoved(a0)		; update movement
		swap	d0
		move.w	obElev_Dist(a0),d2			; get target distance
		cmp.w	d2,d0						; has distance been covered?
		bls.s	.dont_dec					; if not, branch
		move.b	#1,obElev_DecelFlag(a0)		; set deceleration flag

	.dont_dec:
		add.w	d2,d2
		cmp.w	d2,d0						; has complete distance been covered? (including deceleration phase)
		bne.s	.keep_type					; if not, branch
		clr.b	obSubtype(a0)				; convert to type 0 (non-moving)

	.keep_type:
		rts	
; End of function Elev_Move
; ===========================================================================

Elev_MakeMulti:	; Routine 6
		subq.w	#1,obElev_Dist(a0)			; decrement timer
		bne.s	.chkdel						; branch if time remains

		move.w	obElev_DistCopy(a0),obElev_Dist(a0) ; reset timer
		bsr.w	FindFreeObj					; find free object RAM slot
		bne.s	.chkdel						; branch if not found
		_move.l	#Elevator,obAddr(a1)		; duplicate the object
		move.w	obX(a0),obX(a1)				; match position
		move.w	obY(a0),obY(a1)
		move.b	#$E,obSubtype(a1)			; platform rises and vanishes

	.chkdel:
		addq.l	#4,sp
		out_of_range.w	DeleteObject
		rts	
; ===========================================================================