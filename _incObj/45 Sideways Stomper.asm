; ---------------------------------------------------------------------------
; Object 45 - spiked metal block from beta version (MZ)
; ---------------------------------------------------------------------------
; OST Constants (Similar to Obj31, but not identical)
obSStom_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obSStom_PoleLength:		equ objoff_32		; 2 bytes | current pole length
obSStom_PoleMax:		equ objoff_34		; 2 bytes | maximum pole length
obSStom_RetractFlag:	equ objoff_36		; 2 bytes | 1 = retract
obSStom_DelayTime:		equ objoff_38		; 2 bytes | time to wait while fully extended
obSStom_StartY:			equ objoff_3A		; 2 bytes | starting Y-axis position
obSStom_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

SideStomp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SStom_Index(pc,d0.w),d1
		jmp		SStom_Index(pc,d1.w)
; ===========================================================================

SStom_Index:	offsetTable
		offsetTableEntry.w SStom_Main
		offsetTableEntry.w SStom_Solid
		offsetTableEntry.w SStom_Spikes
		offsetTableEntry.w SStom_Display
		offsetTableEntry.w SStom_Pole

SStom_Var:
		;		routine		xpos	frame
		dc.b	2,			4,		0		; main block
		dc.b	4,			-$1C,	1		; spikes
		dc.b	8,			$54,	3		; pole			; Clownacy Sideways Stomper Fix
		dc.b	6,			$28,	2		; wall bracket

;word_B9BE:	; Note that this indicates three subtypes
SStom_Len:
		dc.w $3800	; short
		dc.w $A000	; long
		dc.w $5000	; medium
; ===========================================================================

SStom_Main:	; Routine 0
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	SStom_Len(pc,d0.w),d2
		lea		(SStom_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	.load

.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail

.load:
		move.b	(a2)+,obRoutine(a1)
		_move.l	#SideStomp,obAddr(a1)
		move.w	obY(a0),obY(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obX(a0),d0
		move.w	d0,obX(a1)
		move.l	#Map_SStom,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Spike_Stomper,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	obX(a1),obSStom_StartX(a1)
		move.w	obX(a0),obSStom_StartY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.b	#$20,obDispWid(a1)
		move.w	d2,obSStom_PoleMax(a1)
		move.w	#priority4,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#1,(a2)							; is subobject spikes?
		bne.s	.notspikes						; if not, branch
		move.b	#(colHarmful|colSz_16x24),obColType(a1)	; use harmful collision type

.notspikes:
		move.b	(a2)+,obFrame(a1)
		move.w	a0,obSStom_Parent(a1)
		dbf		d1,.loop					; repeat 3 times
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager

.fail:
		move.b	#$10,obDispWid(a0)
; ---------------------------------------------------------------------------

SStom_Solid:	; Routine 2
		move.w	obX(a0),-(sp)	; save axis position to the stack
		bsr.w	SStom_Move
		moveq	#23,d1			; width; save 4 cycles - Filter
		moveq	#32,d2			; height (jumping); save 4 cycles - Filter
		moveq	#32,d3			; height (walking); save 4 cycles - Filter
		move.w	(sp)+,d4		; axis position (pulled from stack)
		bsr.w	SolidObject
		bra.w	SStom_Display	; Clownacy DisplaySprite Fix
; ===========================================================================

SStom_Pole:	; Routine 8
		movea.w	obSStom_Parent(a0),a1			; get parent object slot
		move.b	obSStom_PoleLength(a1),d0		; get current pole length
		addi.b	#$10,d0
		lsr.b	#5,d0							; divide by $20
		addq.b	#3,d0							; first pole frame (3)
		move.b	d0,obFrame(a0)					; update frame

SStom_Spikes:	; Routine 4
		movea.w	obSStom_Parent(a0),a1			; get parent object slot
		moveq	#0,d0
		move.b	obSStom_PoleLength(a1),d0		; get current pole length
		neg.w	d0								; make it negative
		add.w	obSStom_StartX(a0),d0			; add to initial x pos
		move.w	d0,obX(a0)						; update x pos

SStom_Display:	; Routine 6
		offscreen.w	DeleteObject,obSStom_StartY(a0)	; ProjectFM S3K Objects Manager
		cmpi.b	#1,obFrame(a0)
		bne.s	.notSpikes
		bra.w	DisplayAndCollision

	.notSpikes:
		bra.w	DisplaySprite					; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to move the main metal block
; ---------------------------------------------------------------------------

SStom_Move:
	; Removed offset table -- Clownacy Sideways Stomper Fix
		tst.w	obSStom_RetractFlag(a0)		; is flag set to retract?
		beq.s	.extend						; if not, branch
		tst.w	obSStom_DelayTime(a0)		; has time delay run out?
		beq.s	.retract					; if yes, branch
		subq.w	#1,obSStom_DelayTime(a0)	; decrement timer
		bra.s	.update_pos
; ===========================================================================

	.retract:
		subi.w	#$80,obSStom_PoleLength(a0)	; retract
		bcc.s	.update_pos					; branch if at least $80 is left on length
		clr.w	obSStom_PoleLength(a0)		; set to 0
		clr.w	obVelX(a0)
		clr.w	obSStom_RetractFlag(a0)		; reset flag to extend
		bra.s	.update_pos
; ===========================================================================

	.extend:
		move.w	obSStom_PoleMax(a0),d1
		cmp.w	obSStom_PoleLength(a0),d1	; is pole fully extended?
		beq.s	.update_pos					; if yes, branch
		move.w	obVelX(a0),d0
		addi.w	#$70,obVelX(a0)				; increase speed
		add.w	d0,obSStom_PoleLength(a0)
		cmp.w	obSStom_PoleLength(a0),d1	; is pole fully extended?
		bhi.s	.update_pos					; if not, branch
		move.w	d1,obSStom_PoleLength(a0)
		clr.w	obVelX(a0)					; stop
		move.w	#1,obSStom_RetractFlag(a0)	; set flag to retract
		move.w	#$3C,obSStom_DelayTime(a0)	; set delay to 1 second

	.update_pos:
		moveq	#0,d0
		move.b	obSStom_PoleLength(a0),d0
		neg.w	d0
		add.w	obSStom_StartX(a0),d0
		move.w	d0,obX(a0)
		rts	
; ===========================================================================