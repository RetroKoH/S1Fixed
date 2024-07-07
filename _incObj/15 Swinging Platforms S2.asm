; ----------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;			- spiked ball on a chain (SBZ)
; ----------------------------------------------------------------------------
SwingingPlatform:
	btst	#6,obRender(a0)
	bne.w	.subSpr
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Swing_Index(pc,d0.w),d1
	jmp		Swing_Index(pc,d1.w)
; ---------------------------------------------------------------------------
.subSpr
	move.w	#$200,d0			; $200 or $180?
	bra.w	DisplaySprite2
; ===========================================================================
Swing_Index:	offsetTable
		offsetTableEntry.w Swing_Main			;  0
		offsetTableEntry.w Swing_NormalSwing	;  2
		offsetTableEntry.w Swing_Display		;  4
		offsetTableEntry.w Swing_State4			;  6
		offsetTableEntry.w Swing_State5			;  8
		offsetTableEntry.w Swing_State6			; $A
		offsetTableEntry.w Swing_ARZFall		; $C (Unused atm)

swing_origX = objoff_3A		; original x-axis position
swing_origY = objoff_38		; original y-axis position

swing_angle = $10		; precise rotation angle (2 bytes)
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.
	; Unlike other similar objects, I set this to $10 because the GHZ boss chain
	; uses up much of its scratch RAM, and that object use's this object's movement
	; routines.
; ===========================================================================
Swing_Main:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Swing_GHZ,obMap(a0)	; GHZ and MZ specific code
		move.w	#make_art_tile(ArtTile_GHZ_MZ_Swing,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)		; RetroKoH S3K Priority Manager
		move.b	#$18,obActWid(a0)
		move.b	#8,obHeight(a0)
		move.w	obY(a0),swing_origY(a0)
		move.w	obX(a0),swing_origX(a0)
		cmpi.b	#id_SLZ,(v_zone).w			; check if level is SLZ
		bne.s	.notSLZ

		move.l	#Map_Swing_SLZ,obMap(a0)	; SLZ specific code
		move.w	#make_art_tile(ArtTile_SLZ_Swing,2,0),obGfx(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#$99,obColType(a0)

.notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w		; check if level is SBZ
		bne.s	.length

		move.l	#Map_BBall,obMap(a0)	; SBZ specific code
		move.w	#make_art_tile(ArtTile_SYZ_Big_Spikeball,0,0),obGfx(a0)
		move.b	#$18,obActWid(a0)
		move.b	#$18,obHeight(a0)
		move.b	#$86,obColType(a0)
		move.b	#$C,obRoutine(a0)		; goto Swing_Action next

.length:
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		bpl.s	.skip
		addq.b	#4,obRoutine(a0)

.skip:
		move.b	d1,d4
		andi.b	#$70,d4	
		andi.w	#$F,d1
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		bsr.w	FindNextFreeObj
		bne.w	.nomore
		move.b	obID(a0),obID(a1)	; load obj15
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	#4,obRender(a1)
		cmpi.b	#$20,d4
		bne.s	.subspr
		move.b	#4,obRoutine(a1)
		move.w	#$200,obPriority(a1)	; RetroKoH S3K Priority Manager
		move.b	#8,obActWid(a1)
		bset	#4,obRender(a1)	
		move.b	#1,obFrame(a1)
		move.w	d2,obX(a1)
		addi.w	#$40,d3
		move.w	d3,obY(a1)
		addi.w	#$48,d3
		move.w	d3,obY(a0)
		bra.w	.skiploop

; ===========================================================================
.subspr:
		bset	#6,obRender(a1)
		move.b	#$48,mainspr_width(a1)
		move.b	d1,mainspr_childsprites(a1)
		subq.b	#1,d1
		lea		sub2_x_pos(a1),a2

.loop:
		move.w	d2,(a2)+	; sub?_x_pos
		move.w	d3,(a2)+	; sub?_y_pos
		move.w	#1,(a2)+	; sub2_mapframe
		addi.w	#$10,d3
		dbf		d1,.loop

		move.b	#2,sub2_mapframe(a1)
		move.w	sub6_x_pos(a1),obX(a1)
		move.w	sub6_y_pos(a1),obY(a1)
		move.w	d2,sub6_x_pos(a1)
		move.w	d3,sub6_y_pos(a1)
		move.b	#1,mainspr_mapframe(a1)
		addi.w	#8,d3
		move.w	d3,obY(a0)
		move.b	#$50,mainspr_height(a1)
		bset	#4,obRender(a1)

.skiploop:
		move.l	a1,objoff_30(a0)

.nomore
		move.w	#$8000,obAngle(a0)
		clr.w	objoff_3E(a0)
		move.b	obSubtype(a0),d1
		andi.w	#$70,d1
		move.b	d1,obSubtype(a0)
		cmpi.b	#$40,d1
		bne.s	Swing_NormalSwing
		move.l	#Map_BBall,obMap(a0);#Obj15_MapUnc_102DE,obMap(a0)
		move.b	#$A7,obColType(a0)

; loc_FE50:
Swing_NormalSwing:
		move.w	obX(a0),-(sp)
		bsr.w	sub_FE70
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		move.w	(sp)+,d4
		jsr		(PlatformObject2).l
		bra.w	Swing_S2ChkDel
		
Swing_SBZ:
		bsr.w	sub_FE70
		bra.w	Swing_S2ChkDel
; ===========================================================================

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


sub_FE70:
		moveq	#0,d0
		moveq	#0,d1
		move.b	(v_oscillate+$1A).w,d0
		move.b	obSubtype(a0),d1
		beq.s	loc_FEC2
		cmpi.b	#$10,d1
		bne.s	++
		cmpi.b	#$3F,d0
		beq.s	+
		bhs.s	loc_FEC2
		moveq	#$40,d0
		bra.s	loc_FEC2
; ===========================================================================
/
		moveq	#$40,d0
		bra.s	loc_FEC2
; ===========================================================================
+
		cmpi.b	#$20,d1
		beq.w	+++	; rts
		cmpi.b	#$30,d1
		bne.s	+
		cmpi.b	#$41,d0
		beq.s	-
		blo.s	loc_FEC2
		moveq	#$40,d0
		bra.s	loc_FEC2
; ===========================================================================
+
		cmpi.b	#$40,d1
		bne.s	loc_FEC2
		bsr.w	loc_FF6E

loc_FEC2:
		move.b	objoff_2E(a0),d1
		cmp.b	d0,d1
		beq.w	++	; rts
		move.b	d0,objoff_2E(a0)
		move.w	#$80,d1
		btst	#0,obStatus(a0)
		beq.s	+
		neg.w	d0
		add.w	d1,d0
+
		jsr		(CalcSine).l
		move.w	objoff_38(a0),d2
		move.w	objoff_3A(a0),d3
		moveq	#0,d6
		movea.l	objoff_30(a0),a1
		move.b	mainspr_childsprites(a1),d6
		subq.w	#1,d6
		bcs.s	+	; rts
		swap	d0
		swap	d1
		asr.l	#4,d0
		asr.l	#4,d1
		moveq	#0,d4
		moveq	#0,d5
		lea		sub2_x_pos(a1),a2

-
		movem.l	d4-d5,-(sp)
		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d5,(a2)+	; sub?_x_pos
		move.w	d4,(a2)+	; sub?_y_pos
		movem.l	(sp)+,d4-d5
		add.l	d0,d4
		add.l	d1,d5
		addq.w	#next_subspr-4,a2
		dbf		d6,-

		movem.l	d4-d5,-(sp)
		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	sub6_x_pos(a1),d2
		move.w	sub6_y_pos(a1),d3
		move.w	d5,sub6_x_pos(a1)
		move.w	d4,sub6_y_pos(a1)
		move.w	d2,obX(a1)
		move.w	d3,obY(a1)
		movem.l	(sp)+,d4-d5
		asr.l	#1,d0
		asr.l	#1,d1
		add.l	d0,d4
		add.l	d1,d5
		swap	d4
		swap	d5
		add.w	objoff_38(a0),d4
		add.w	objoff_3A(a0),d5
		move.w	d4,obY(a0)
		move.w	d5,obX(a0)
+
		rts
; End of function sub_FE70

; ===========================================================================

loc_FF6E:
		tst.w	objoff_36(a0)
		beq.s	+
		subq.w	#1,objoff_36(a0)
		bra.w	loc_10006
; ===========================================================================
+
		tst.b	objoff_34(a0)
		bne.s	+
		move.w	(v_player+obX).w,d0
		sub.w	objoff_3A(a0),d0
		addi.w	#$20,d0
		cmpi.w	#$40,d0
		bhs.s	loc_10006
		tst.w	(v_debuguse).w
		bne.w	loc_10006
		move.b	#1,objoff_34(a0)
+
		tst.b	objoff_3D(a0)
		beq.s	+
		move.w	objoff_3E(a0),d0
		addi.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,obAngle(a0)
		cmpi.w	#$200,d0
		bne.s	loc_10006
		move.w	#0,objoff_3E(a0)
		move.w	#$8000,obAngle(a0)
		move.b	#0,objoff_3D(a0)
		move.w	#60,objoff_36(a0)
		bra.s	loc_10006
; ===========================================================================
+
		move.w	objoff_3E(a0),d0
		subi.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,obAngle(a0)
		cmpi.w	#$FE00,d0
		bne.s	loc_10006
		move.w	#0,objoff_3E(a0)
		move.w	#$4000,obAngle(a0)
		move.b	#1,objoff_3D(a0)
	; loc_10000:
		move.w	#60,objoff_36(a0)

loc_10006:
		move.b	obAngle(a0),d0
		rts
; ===========================================================================

Swing_S2ChkDel: ;Swing_S2ChkDel:
		move.w	objoff_3A(a0),d0
		andi.w	#$FF80,d0
		sub.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0				; d0 = coarse x-position
		cmpi.w	#$280,d0
		bhi.w	++					; if not, branch
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	+					; if it's zero, object was placed in debug mode
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn entry, so object can be loaded again

+		; else, clear respawn table entry
		jmp		(DisplayAndCollision).l
; ===========================================================================
+
		movea.l	objoff_30(a0),a1
		bsr.w	DeleteChild
		jmp		(DeleteObject).l
; ===========================================================================

Swing_Display:
		jmp		(DisplayAndCollision).l
; ===========================================================================

; loc_1003E:
Swing_State4:
		move.w	obX(a0),-(sp)
		bsr.w	sub_FE70
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		move.w	(sp)+,d4
		jsr		PlatformObject2
		btst	#staSonicOnObj,obStatus(a0)
		beq.w	Swing_S2ChkDel
		tst.b	(v_oscillate+$18).w
		bne.w	Swing_S2ChkDel
		jsr		(FindNextFreeObj).l
		bne.s	loc_100E4
		moveq	#0,d0
		move.w	#$F,d1		;#bytesToLcnt(object_size)

.loop:	
		move.l	(a0,d0.w),(a1,d0.w)
		addq.w	#4,d0
		dbf		d1,.loop
		move.b	#$A,obRoutine(a1)
		move.w	#$200,obVelX(a1)
		btst	#staFlipX,obStatus(a0)
		beq.s	+
		neg.w	obVelX(a1)

+
		bset	#staFlipY,obStatus(a1)
		move.w	a0,d0
		subi.w	#v_objspace&$FFFF,d0	
		lea		(v_player).w,a1
		cmp.b	obPlatformAddr(a1),d0
		bne.s	loc_100E4
		move.b	d0,obPlatformAddr(a1)

loc_100E4:
		move.b	#3,obFrame(a0)
		addq.b	#2,obRoutine(a0)
		andi.b	#$E7,obStatus(a0)
		bra.w	Swing_S2ChkDel
; ===========================================================================

; loc_100F8:
Swing_State5:
		bsr.w	sub_FE70
		bra.w	Swing_S2ChkDel
; ===========================================================================
; loc_10100:
Swing_State6:
		move.w	obX(a0),-(sp)
		btst	#1,obStatus(a0)
		beq.s	+
		jsr		(SpeedToPos).l
		addi.w	#$18,obVelY(a0)
		cmpi.w	#$720,obY(a0)
		blo.s	++
		move.w	#$720,obY(a0)
		bclr	#1,obStatus(a0)
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)
		move.w	obY(a0),swing_origY(a0)
		bra.s	++
; ===========================================================================
+
		moveq	#0,d0
		move.b	(v_oscillate+$16).w,d0
		lsr.w	#1,d0
		add.w	swing_origY(a0),d0
		move.w	d0,obY(a0)
		tst.w	obVelX(a0)
		beq.s	+
		moveq	#0,d3
		move.b	obActWid(a0),d3
		jsr		(ObjCheckRightWallDist).l
		tst.w	d1
		bpl.s	+
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
	
+
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		move.w	(sp)+,d4
		jsr		(PlatformObject2).l
		jmp		(RememberState).l

; ===========================================================================
; loc_10166:
Swing_ARZFall:
		move.w	obX(a0),-(sp)
		jsr	SpeedToPos
		btst	#1,obStatus(a0)
		beq.s	+
		addi.w	#$18,obVelY(a0)
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0
		bhi.s	++
		move.w	d0,obY(a0)
		move.w	d0,swing_origY(a0)
		bclr	#1,obStatus(a0)
		move.w	#$100,obVelX(a0)
		move.w	#0,obVelY(a0)
		bra.s	++
; ===========================================================================
+
		moveq	#0,d0
		move.b	(v_oscillate+$20).w,d0
		lsr.w	#1,d0
		add.w	swing_origY(a0),d0
		move.w	d0,obY(a0)
		tst.w	obVelX(a0)
		beq.s	+
		moveq	#0,d3
		move.b	obActWid(a0),d3
		jsr	ObjHitWallRight
		tst.w	d1
		bpl.s	+
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

+
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		move.w	(sp)+,d4
		jsr	PlatformObject2
		jmp	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to collide Sonic/Tails with the top of a platform
; Code ported from Sonic 2
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
;
; input variables:
; d1 = object width
; d3 = object height / 2
; d4 = object x-axis position
;
; address registers:
; a0 = the object to check collision with
; a1 = sonic or tails (set inside these subroutines)
; loc_19C32:
PlatformObject2:
		lea		(v_player).w,a1 ; a1=character
		btst	#staSonicOnObj,obStatus(a0)
		beq.w	PlatformObject2_cont			; Code in Bridge.asm
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	PlatformObject_SingleCharacter2
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	PlatformObject_SingleCharacter2
		cmp.w	d2,d0
		blo.s	loc_19C802

PlatformObject_SingleCharacter2:
		bclr	#3,obStatus(a1)
		bset	#1,obStatus(a1)
		bclr	d6,obStatus(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
loc_19C802:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
; ===========================================================================

Swing_Move:
		move.b	(v_oscillate+$1A).w,d0
		move.w	#$80,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	Swing_Move2
		neg.w	d0
		add.w	d1,d0
		bra.s	Swing_Move2
; End of function Swing_Move


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


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move2:
		bsr.w	CalcSine
		move.w	objoff_38(a0),d2
		move.w	objoff_3A(a0),d3
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
