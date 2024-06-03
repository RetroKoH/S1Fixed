; ---------------------------------------------------------------------------
; Object 7B - exploding	spikeys	that Eggman drops (SLZ)
; ---------------------------------------------------------------------------

BossSpikeball:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossSpikeball_Index(pc,d0.w),d0
		jsr	BossSpikeball_Index(pc,d0.w)
		move.w	objoff_30(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	BossStarLight_Delete
		cmpi.w	#$280,d0
		bhi.w	BossStarLight_Delete
		jmp	(DisplaySprite).l
; ===========================================================================
BossSpikeball_Index:
		dc.w BossSpikeball_Main-BossSpikeball_Index
		dc.w BossSpikeball_Fall-BossSpikeball_Index
		dc.w loc_18DC6-BossSpikeball_Index
		dc.w loc_18EAA-BossSpikeball_Index
		dc.w BossSpikeball_Explode-BossSpikeball_Index
		dc.w BossSpikeball_MoveFrag-BossSpikeball_Index
; ===========================================================================

BossSpikeball_Main:	; Routine 0
		move.l	#Map_SSawBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Spikeball,0,0),obGfx(a0)
		move.b	#1,obFrame(a0)
		ori.b	#4,obRender(a0)
		move.b	#4,obPriority(a0)
		move.b	#$8B,obColType(a0)
		move.b	#$C,obActWid(a0)
		movea.l	objoff_3C(a0),a1
		move.w	obX(a1),objoff_30(a0)
		move.w	obY(a1),objoff_34(a0)
		bset	#0,obStatus(a0)
		move.w	obX(a0),d0
		cmp.w	obX(a1),d0
		bgt.s	loc_18D68
		bclr	#0,obStatus(a0)
		move.b	#2,objoff_3A(a0)

loc_18D68:
		addq.b	#2,obRoutine(a0)

BossSpikeball_Fall:	; Routine 2
		jsr	(ObjectFall).l
		movea.l	objoff_3C(a0),a1
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	obX(a0),d1
		sub.w	objoff_30(a0),d1
		bcc.s	loc_18D8E
		addq.w	#2,d0

loc_18D8E:
		add.w	d0,d0
		move.w	objoff_34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	obY(a0),d1
		bgt.s	locret_18DC4
		movea.l	objoff_3C(a0),a1
		moveq	#2,d1
		btst	#0,obStatus(a0)
		beq.s	loc_18DAE
		moveq	#0,d1

loc_18DAE:
		move.w	#$F0,obSubtype(a0)
		move.b	#10,obDelayAni(a0)	; set frame duration to	10 frames
		move.b	obDelayAni(a0),obTimeFrame(a0)
		bra.w	loc_18FA2
; ===========================================================================

locret_18DC4:
		rts	
; ===========================================================================

loc_18DC6:	; Routine 4
		movea.l	objoff_3C(a0),a1
		moveq	#0,d0
		move.b	objoff_3A(a0),d0
		sub.b	objoff_3A(a1),d0
		beq.s	loc_18E2A
		bcc.s	loc_18DDA
		neg.b	d0

loc_18DDA:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0
		beq.s	loc_18E00
		move.w	#-$960,d1
		move.w	#-$F4,d2
		cmpi.w	#$9C0,objoff_38(a1)
		blt.s	loc_18E00
		move.w	#-$A20,d1
		move.w	#-$80,d2

loc_18E00:
		move.w	d1,obVelY(a0)
		move.w	d2,obVelX(a0)
		move.w	obX(a0),d0
		sub.w	objoff_30(a0),d0
		bcc.s	loc_18E16
		neg.w	obVelX(a0)

loc_18E16:
		move.b	#1,obFrame(a0)
		move.w	#$20,obSubtype(a0)
		addq.b	#2,obRoutine(a0)
		bra.w	loc_18EAA
; ===========================================================================

loc_18E2A:
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	#$28,d2
		move.w	obX(a0),d1
		sub.w	objoff_30(a0),d1
		bcc.s	loc_18E48
		neg.w	d2
		addq.w	#2,d0

loc_18E48:
		add.w	d0,d0
		move.w	objoff_34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,obY(a0)
		add.w	objoff_30(a0),d2
		move.w	d2,obX(a0)
		clr.w	obY+2(a0)
		clr.w	obX+2(a0)
		subq.w	#1,obSubtype(a0)
		bne.s	loc_18E7A
		move.w	#$20,obSubtype(a0)
		move.b	#8,obRoutine(a0)
		rts	
; ===========================================================================

loc_18E7A:
		cmpi.w	#$78,obSubtype(a0)
		bne.s	loc_18E88
		move.b	#5,obDelayAni(a0)

loc_18E88:
		cmpi.w	#$3C,obSubtype(a0)
		bne.s	loc_18E96
		move.b	#2,obDelayAni(a0)

loc_18E96:
		subq.b	#1,obTimeFrame(a0)
		bgt.s	locret_18EA8
		bchg	#0,obFrame(a0)
		move.b	obDelayAni(a0),obTimeFrame(a0)

locret_18EA8:
		rts	
; ===========================================================================

loc_18EAA:	; Routine 6
	if FixBugs
		lea	(v_lvlobjspace).w,a1
	else
		lea	(v_objspace+object_size*1).w,a1 ; Nonsensical starting point, since dynamic object allocations begin at v_lvlobjspace.
	endif
		moveq	#id_BossStarLight,d0
		moveq	#object_size,d1
	if FixBugs
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d2
	else
		moveq	#(v_objend-(v_objspace+object_size*1))/object_size/2-1,d2	; Nonsensical length, it only covers the first half of object RAM.
	endif

loc_18EB4:
		cmp.b	obID(a1),d0
		beq.s	loc_18EC0
		adda.w	d1,a1
		dbf	d2,loc_18EB4

		bra.s	loc_18F38
; ===========================================================================

loc_18EC0:
		move.w	obX(a1),d0
		move.w	obY(a1),d1
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		lea	BossSpikeball_BossHitbox(pc),a2
		lea	BossSpikeball_BallHitbox(pc),a3
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d0,d2
		blo.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d2,d0
		blo.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d1,d3
		blo.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d3,d1
		blo.s	loc_18F38
		addq.b	#2,obRoutine(a0)
		clr.w	obSubtype(a0)
		clr.b	obColType(a1)
		subq.b	#1,obColProp(a1)
		bne.s	loc_18F38
		bset	#7,obStatus(a1)
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)

loc_18F38:
		tst.w	obVelY(a0)
		bpl.s	loc_18F5C
		jsr	(ObjectFall).l
		move.w	objoff_34(a0),d0
		subi.w	#$2F,d0
		cmp.w	obY(a0),d0
		bgt.s	loc_18F58
		jsr	(ObjectFall).l

loc_18F58:
		bra.w	loc_18E7A
; ===========================================================================

loc_18F5C:
		jsr	(ObjectFall).l
		movea.l	objoff_3C(a0),a1
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	obFrame(a1),d0
		move.w	obX(a0),d1
		sub.w	objoff_30(a0),d1
		bcc.s	loc_18F7E
		addq.w	#2,d0

loc_18F7E:
		add.w	d0,d0
		move.w	objoff_34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	obY(a0),d1
		bgt.s	loc_18F58
		movea.l	objoff_3C(a0),a1
		moveq	#2,d1
		tst.w	obVelX(a0)
		bmi.s	loc_18F9C
		moveq	#0,d1

loc_18F9C:
		move.w	#0,obSubtype(a0)

loc_18FA2:
		move.b	d1,objoff_3A(a1)
		move.b	d1,objoff_3A(a0)
		cmp.b	obFrame(a1),d1
		beq.s	loc_19008
		bclr	#3,obStatus(a1)
		beq.s	loc_19008
		clr.b	ob2ndRout(a1)
		move.b	#2,obRoutine(a1)
		lea	(v_player).w,a2
		move.w	obVelY(a0),obVelY(a2)
		neg.w	obVelY(a2)
		cmpi.b	#1,obFrame(a1)
		bne.s	loc_18FDC
		asr	obVelY(a2)

loc_18FDC:
		bset	#1,obStatus(a2)
		bclr	#3,obStatus(a2)
		clr.b	objoff_3C(a2)
		move.l	a0,-(sp)
		lea	(a2),a0
		jsr	(Sonic_ChkRoll).l
		movea.l	(sp)+,a0
		move.b	#2,obRoutine(a2)
		move.w	#sfx_Spring,d0
		jsr	(PlaySound_Special).l	; play "spring" sound

loc_19008:
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)
		bra.w	loc_18E7A
; ===========================================================================
word_19018:	dc.w -8, -$1C, -$2F, -$1C, -8
		even
BossSpikeball_BossHitbox:
		dc.b -$18, $18+$18		; left to right
		dc.b -$18, $18+$18		; top to bottom
		even
BossSpikeball_BallHitbox:
		dc.b 8,	-8-8			; right to left
		dc.b 8, -8-8			; bottom to top
		even
; ===========================================================================

BossSpikeball_Explode:	; Routine 8
		move.b	#id_ExplosionBomb,obID(a0)
		clr.b	obRoutine(a0)
		cmpi.w	#$20,obSubtype(a0)
		beq.s	BossSpikeball_MakeFrag
		rts	
; ===========================================================================

BossSpikeball_MakeFrag:
		move.w	objoff_34(a0),obY(a0)
		moveq	#3,d1
		lea	BossSpikeball_FragSpeed(pc),a2

BossSpikeball_Loop:
		jsr	(FindFreeObj).l
		bne.s	loc_1909A
		move.b	#id_BossSpikeball,obID(a1) ; load shrapnel object
		move.b	#$A,obRoutine(a1)
		move.l	#Map_BSBall,obMap(a1)
		move.b	#3,obPriority(a1)
		move.w	#make_art_tile(ArtTile_Eggman_Spikeball,0,0),obGfx(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	(a2)+,obVelX(a1)
		move.w	(a2)+,obVelY(a1)
		move.b	#$98,obColType(a1)
		ori.b	#4,obRender(a1)
		bset	#7,obRender(a1)
		move.b	#$C,obActWid(a1)

loc_1909A:
		dbf	d1,BossSpikeball_Loop	; repeat sequence 3 more times

		rts	
; ===========================================================================
BossSpikeball_FragSpeed:
		dc.w -$100, -$340	; horizontal, vertical
		dc.w -$A0, -$240
		dc.w $100, -$340
		dc.w $A0, -$240
; ===========================================================================

BossSpikeball_MoveFrag:	; Routine $A
		jsr	(SpeedToPos).l
		move.w	obX(a0),objoff_30(a0)
		move.w	obY(a0),objoff_34(a0)
		addi.w	#$18,obVelY(a0)
		moveq	#4,d0
		and.w	(v_vbla_word).w,d0
		lsr.w	#2,d0
		move.b	d0,obFrame(a0)
		tst.b	obRender(a0)
		bpl.w	BossStarLight_Delete
		rts	
