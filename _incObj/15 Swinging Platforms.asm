; ----------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;			- spiked ball on a chain (SBZ)
; Adapted from Sonic Clean Engine
; ----------------------------------------------------------------------------
; OST Constants
obSwing_StartX:				equ objoff_30		; 2 bytes | starting X-axis position
obSwing_StartY:				equ objoff_32		; 2 bytes | starting Y-axis position
obSwing_Chain:				equ objoff_3E		; 2 bytes | object RAM address of chain
; ----------------------------------------------------------------------------

Swing_Sub:
		move.w	#priority5,d0					; decreased from 4
		bra.w	DisplaySprite2
; ===========================================================================

SwingingPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Swing_Index(pc,d0.w),d0
		jmp		Swing_Index(pc,d0.w)
; ===========================================================================

Swing_Index:	offsetTable
		offsetTableEntry.w Swing_Main			;  0
		offsetTableEntry.w Swing_Platform		;  2 -- GHZ/MZ, and SLZ
		offsetTableEntry.w Swing_Action2		;  4 -- GHZ/MZ/SLZ when stood upon
		offsetTableEntry.w Swing_SBZ			;  $6 -- SBZ2 Spikeball
; ===========================================================================

Swing_Main:
		addq.b	#2,obRoutine(a0)				; initialize to normal swinging platform routine
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obDispWid(a0)
		move.b	#8,obHeight(a0)
		move.w	obY(a0),obSwing_StartY(a0)
		move.w	obX(a0),obSwing_StartX(a0)

	; GHZ and MZ specific code
		move.l	#Map_Swing_GHZ,d0
		move.w	#make_art_tile(ArtTile_GHZ_MZ_Swing,1,0),d1
		cmpi.b	#id_SLZ,(v_zone).w				; check if level is SLZ
		bne.s	.notSLZ

	; SLZ specific code
		move.l	#Map_Swing_SLZ,d0
		move.w	#make_art_tile(ArtTile_SLZ_Swing,2,0),d1
		move.b	#$20,obDispWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#(colHarmful|colSz_32x8),obColType(a0)
		bra.s	.finishInit

	.notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w				; check if level is SBZ
		bne.s	.finishInit

	; SBZ specific code
		addq.b	#4,obRoutine(a0)				; initialize to spikeball routine (6)
		move.l	#Map_BBall,d0
		move.w	#make_art_tile(ArtTile_SYZ_Big_Spikeball,1,0),d1
		move.b	#$18,obHeight(a0)
		move.b	#(colHarmful|colSz_16x16),obColType(a0)

	.finishInit:
		move.l	d0,obMap(a0)
		move.w	d1,obGfx(a0)

	; create chain
		bsr.w	FindFreeObj
		bne.w	Swing_OffScreen

		_move.l	#Swing_Sub,obAddr(a1)			; load subsprite object
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#renMultiDraw,obRender(a1)		; set multi-draw flag
		bset	#renUseHeight,obRender(a1)
		move.w	a1,obSwing_Chain(a0)			; save chain address
		move.w	obX(a0),d2
		move.w	d2,obX(a1)						; store x, but retain for later use
		move.w	obY(a0),d3
		move.w	d3,obY(a1)						; store y, but retain for later use

		moveq	#$F,d1
		and.b	obSubtype(a0),d1
		move.b	d1,d0
		addq.b	#1,d0
		lsl.b	#4,d0							; multiply by $10
		move.b	d0,mainspr_width(a1)			; width/height is (chainlinks+1)*$10
		move.b	d0,mainspr_height(a1)
		move.b	d1,mainspr_childsprites(a1)		; number of chain links
		subq.b	#1,d1							; loop iterator
		blo.w	Swing_OffScreen

        lea		subspr_posdata(a1),a2
		lea		subspr_frames(a1),a3

	.loop:
        move.w	d2,(a2)+                        ; sub?_x_pos
        move.w	d3,(a2)+                        ; sub?_y_pos
        move.b	#1,(a3)+                        ; sub?_mapframe
        dbf		d1,.loop

		move.b	#2,mainspr_mapframe(a1)			; set frame for anchor
		rts
; ===========================================================================

Swing_Platform:	; Routine 2
		move.w	obX(a0),-(sp)
		bsr.w	Swing_Move
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		moveq	#1,d3
		add.b	obHeight(a0),d3
		move.w	(sp)+,d4
		bsr.w	PlatformObject
		tst.b	obColType(a0)
		bne.s	Swing_SpikeChkDel

Swing_ChkDel:
        move.w	obSwing_StartX(a0),d0	; get object position
        andi.w	#$FF80,d0				; round down to nearest $80
        move.w	(v_screenposx).w,d1		; get screen position
        subi.w	#$80,d1
        andi.w	#$FF80,d1
        sub.w	d1,d0					; approx distance between object and screen
        cmpi.w	#$280,d0
        bhi.w	Swing_OffScreen

		; draw
		bra.w	DisplaySprite
; ===========================================================================

Swing_OffScreen:
		move.w	obRespawnAddr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

	.delete:
		movea.w	obSwing_Chain(a0),a1
		bsr.w	DeleteChild
		jmp		(DeleteObject).l
; ===========================================================================

Swing_SBZ:	; Routine 6
		bsr.s	Swing_Move

Swing_SpikeChkDel:
        move.w	obSwing_StartX(a0),d0	; get object position
        andi.w	#$FF80,d0				; round down to nearest $80
        move.w	(v_screenposx).w,d1		; get screen position
        subi.w	#$80,d1
        andi.w	#$FF80,d1
        sub.w	d1,d0					; approx distance between object and screen
        cmpi.w	#$280,d0
        bhi.w	Swing_OffScreen
		bra.w	DisplayAndCollision
; ===========================================================================

Swing_Action2:	; Routine 4
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		bsr.w	ExitPlatform
		move.w	obX(a0),-(sp)
		bsr.s	Swing_Move
		move.w	(sp)+,d2
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		bsr.w	MvSonicOnPtfm
		bra.w	Swing_ChkDel			; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update positions of all chainlinks and platform
; ---------------------------------------------------------------------------

Swing_Move:
		moveq	#0,d0
		move.b	(v_oscillate+$1A).w,d0
		btst	#0,obStatus(a0)
		beq.s	.notflipx
		neg.b	d0
		addi.b	#$80,d0

	.notflipx:
		btst	#1,obStatus(a0)
		beq.s	.notflipy
		neg.b	d0

	.notflipy:
		calcsine_direct

		move.w	obSwing_StartY(a0),d2
		move.w	obSwing_StartX(a0),d3
		movea.w	obSwing_Chain(a0),a1				; load chain address
		moveq	#0,d6
		move.b	mainspr_childsprites(a1),d6
		subq.b	#1,d6
		blo.s	.return
		swap	d0
		clr.w	d0
		swap	d1
		clr.w	d1
		asr.l	#4,d0
		asr.l	#4,d1
		move.l	d0,d4
		move.l	d1,d5
		lea		subspr_posdata(a1),a2

	.loop:
		movem.l	d4-d5,-(sp)
		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d5,(a2)+						; x_pos
		move.w	d4,(a2)+						; y_pos
		movem.l	(sp)+,d4-d5
		add.l	d0,d4
		add.l	d1,d5
		dbf		d6,.loop

		; sonic 1 fix pos
		asr.l	d0
		asr.l	d1
		sub.l	d0,d4
		sub.l	d1,d5

		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d5,obX(a0)
		move.w	d4,obY(a0)

	.return:
		rts
; ===========================================================================