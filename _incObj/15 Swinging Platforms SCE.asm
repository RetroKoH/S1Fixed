; ----------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;			- spiked ball on a chain (SBZ)
; Adapted from Sonic Clean Engine
; ----------------------------------------------------------------------------
SwingingPlatform:
	btst	#6,obRender(a0)
	bne.w	.subSpr
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Swing_Index(pc,d0.w),d0
	jmp		Swing_Index(pc,d0.w)
; ---------------------------------------------------------------------------
.subSpr
	move.w	#priority4,d0	; 4 or 5?
	bra.w	DisplaySprite2
; ===========================================================================
Swing_Index:	offsetTable
		offsetTableEntry.w Swing_Main			;  0
		offsetTableEntry.w Swing_NormalSwing	;  2 -- GHZ/MZ
		offsetTableEntry.w Swing_Action2		;  4 -- GHZ/MZ (When stood upon; Called by Platform3)
		offsetTableEntry.w Swing_SLZSwing		;  4 -- SLZ
		offsetTableEntry.w Swing_SBZSwing		;  6

swing_parent = objoff_30
swing_origX = objoff_3A		; original x-axis position
swing_origY = objoff_38		; original y-axis position

swing_angle = $10			; precise rotation angle (2 bytes)
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.
	; Unlike other similar objects, I set this to $10 because the GHZ boss chain
	; uses up much of its scratch RAM, and that object use's this object's movement
	; routines.
; ===========================================================================
Swing_Main:
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obActWid(a0)
		move.b	#8,obHeight(a0)
		move.w	obY(a0),swing_origY(a0)
		move.w	obX(a0),swing_origX(a0)

	; GHZ and MZ specific code
		addq.b	#2,obRoutine(a0)				; initialize to normal routine (#2: GHZ/MZ)
		move.l	#Map_Swing_GHZ,d1
		move.w	#make_art_tile(ArtTile_GHZ_MZ_Swing,0,0),d0
		cmpi.b	#id_SLZ,(v_zone).w				; check if level is SLZ
		bne.s	.notSLZ

	; SLZ specific code
		addq.b	#2,obRoutine(a0)				; initialize to SLZ routine (#4)
		move.l	#Map_Swing_SLZ,d1
		move.w	#make_art_tile(ArtTile_SLZ_Swing,2,0),d0
		move.b	#$20,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$99,obColType(a0)
		bra.s	.finishInit

.notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w				; check if level is SBZ
		bne.s	.finishInit

	; SBZ specific code
		addq.b	#4,obRoutine(a0)				; initialize to SBZ routine (#4)
		move.l	#Map_BBall,d1
		move.w	#make_art_tile(ArtTile_SYZ_Big_Spikeball,0,0),d0
		move.b	#$18,obHeight(a0)
		move.b	#$86,obColType(a0)
		move.b	#$C,obRoutine(a0)				; goto Swing_Action next

.finishInit:
		move.w	d0,obGfx(a0)
		move.l	d1,obMap(a0)

	; create chain
		bsr.w	FindFreeObj
		bne.w	Swing_OffScreen
		move.b	obID(a0),obID(a1)				; load obj15
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#priority4,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		bset	#6,obRender(a1)					; set multi-draw flag
		move.w	a1,swing_parent(a0)				; save chain address
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
		blo.s	Swing_OffScreen
		lea		sub2_x_pos(a1),a2

.loop:
		move.w	d2,(a2)+						; sub?_x_pos
		move.w	d3,(a2)+						; sub?_y_pos
		move.w	#1,(a2)+						; sub2_mapframe
		dbf		d1,.loop
		move.b	#2,sub2_mapframe(a1)

		rts
; ===========================================================================

Swing_NormalSwing:
Swing_SLZSwing:		; Should be the same as GHZ, but have harmful collision as well.
Swing_SBZSwing:		; Only harmful collision
		move.w	obX(a0),-(sp)
		bsr.w	Swing_Move
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#1,d3
		add.b	obHeight(a0),d3
		move.w	(sp)+,d4
		bsr.w	PlatformObject

Swing_ChkDel:
		moveq	#-$80,d0						; round down to nearest $80
		and.w	swing_origX(a0),d0				; get object position
		offscreen.s	Swing_OffScreen
		bra.w	DisplaySprite
; ===========================================================================

Swing_OffScreen:
		move.w	obRespawnNo(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		movea.w	swing_parent(a0),a1
		bsr.w	DeleteChild
		jmp		(DeleteObject).l
; ===========================================================================

Swing_Action2:	; Routine 4
		moveq	#0,d1
		move.b	obActWid(a0),d1
		bsr.w	ExitPlatform
		move.w	obX(a0),-(sp)
		bsr.s	Swing_Move
		move.w	(sp)+,d2
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		bsr.w	MvSonicOnPtfm
		bra.w	Swing_ChkDel		; Clownacy DisplaySprite Fix
; ===========================================================================

; =============== S U B R O U T I N E =======================================

Swing_Move:
		moveq	#0,d0
		move.b	(v_oscillate+$1A).w,d0
		btst	#0,obStatus(a0)
		beq.s	.notflipx
		neg.b	d0
		addi.b	#$80,d0

.notflipx
		btst	#1,obStatus(a0)
		beq.s	.notflipy
		neg.b	d0

.notflipy
		jsr		(CalcSine).w
		move.w	swing_origY(a0),d2
		move.w	swing_origX(a0),d3
		movea.w	swing_parent(a0),a1				; load chain address
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
		lea		sub2_x_pos(a1),a2

.loop
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
		addq.w	#2,a2							; skip mapping frame
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

.return
		rts
; ===========================================================================


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj48_Move:
		tst.b	objoff_3D(a0)
		bne.s	loc_7B9C
		move.w	objoff_3E(a0),d0
		addq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		cmpi.w	#$200,d0
		bne.s	loc_7BB6
		move.b	#1,objoff_3D(a0)
		bra.s	loc_7BB6
; ===========================================================================

loc_7B9C:
		move.w	objoff_3E(a0),d0
		subq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		cmpi.w	#-$200,d0
		bne.s	loc_7BB6
		clr.b	objoff_3D(a0)

loc_7BB6:
		move.b	obAngle(a0),d0
; End of function Obj48_Move
; ===========================================================================

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move2:
		bsr.w	CalcSine
		move.w	swing_origY(a0),d2
		move.w	swing_origX(a0),d3
		lea		obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_7BCE:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	objoff_3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		dbf		d6,loc_7BCE
		rts	
; End of function Swing_Move2
; ===========================================================================
