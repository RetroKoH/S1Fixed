; ---------------------------------------------------------------------------
; Object 36 - spikes
; ---------------------------------------------------------------------------

; ===========================================================================
spik_origX = objoff_30		; start X position
spik_origY = objoff_32		; start Y position

Spik_Var:
		dc.b 0,	$14		; frame	number,	object width
		dc.b 1,	$10
		dc.b 2,	4
		dc.b 3,	$1C
		dc.b 4,	$40
		dc.b 5,	$10
; ===========================================================================

Spikes:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Spik_Solid
	; Object Routine Optimization End

Spik_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Spike,obMap(a0)
		move.w	#make_art_tile(ArtTile_Spikes,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		andi.b	#$F,obSubtype(a0)
		andi.w	#$F0,d0
		lea		(Spik_Var).l,a1
		lsr.w	#3,d0
		adda.w	d0,a1
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obActWid(a0)
		move.w	obX(a0),spik_origX(a0)
		move.w	obY(a0),spik_origY(a0)

Spik_Solid:	; Routine 2
		bsr.w	Spik_Type0x	; make the object move
		move.w	#4,d2
		cmpi.b	#5,obFrame(a0)	; is object type $5x ?
		beq.s	Spik_SideWays	; if yes, branch
		cmpi.b	#1,obFrame(a0)	; is object type $1x ?
		bne.s	Spik_Upright	; if not, branch
		move.w	#$14,d2

; Spikes types $1x and $5x face	sideways

Spik_SideWays:
		move.w	#$1B,d1
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#staSonicOnObj,obStatus(a0)
		bne.s	Spik_Display
		cmpi.w	#1,d4
		beq.s	Spik_Hurt
		bra.s	Spik_Display
; ===========================================================================

; Spikes types $0x, $2x, $3x and $4x face up or	down

Spik_Upright:
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#staSonicOnObj,obStatus(a0)
		bne.s	Spik_Hurt
		tst.w	d4
		bpl.s	Spik_Display

Spik_Hurt:
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; is Sonic invincible?
		bne.s	Spik_Display							; if yes, branch
	if SpikeBugFix=1	; Mercury Spike Bug Fix
		tst.b	(v_player+obInvuln).w					; is Sonic invulnerable? -- RetroKoH Sonic SST Compaction
		bne.s	Spik_Display							; if yes, branch
	endif	; Spike Bug Fix End
		move.l	a0,-(sp)
		movea.l	a0,a2
		lea		(v_player).w,a0
		cmpi.b	#4,obRoutine(a0)
		bhs.s	loc_CF20
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)
		jsr		(HurtSonic).l

loc_CF20:
		movea.l	(sp)+,a0

Spik_Display:
		offscreen.w	DeleteObject,spik_origX(a0)	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite					; Clownacy DisplaySprite Fix
; ===========================================================================

Spik_Type0x:
	; LavaGaming Object Routine Optimization
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		subq.b	#1,d0
		tst.b	d0
		beq.s	Spik_Type01
		bgt.s	Spik_Type02
Spik_Type00:
		rts					; don't move the object
	; Object Routine Optimization End
; ===========================================================================

Spik_Type01:
		bsr.w	Spik_Wait
		moveq	#0,d0
		move.b	objoff_34(a0),d0
		add.w	spik_origY(a0),d0
		move.w	d0,obY(a0)	; move the object vertically
		rts	
; ===========================================================================

Spik_Type02:
		bsr.w	Spik_Wait
		moveq	#0,d0
		move.b	objoff_34(a0),d0
		add.w	spik_origX(a0),d0
		move.w	d0,obX(a0)	; move the object horizontally
		rts	
; ===========================================================================

Spik_Wait:
		tst.w	objoff_38(a0)		; is time delay	= zero?
		beq.s	loc_CFA4	; if yes, branch
		subq.w	#1,objoff_38(a0)	; subtract 1 from time delay
		bne.s	locret_CFE6
		tst.b	obRender(a0)
		bpl.s	locret_CFE6
		move.w	#sfx_SpikesMove,d0
		jsr		(PlaySound_Special).w	; play "spikes moving" sound
		bra.s	locret_CFE6
; ===========================================================================

loc_CFA4:
		tst.w	objoff_36(a0)
		beq.s	loc_CFC6
		subi.w	#$800,objoff_34(a0)
		bcc.s	locret_CFE6
		clr.w	objoff_34(a0)
		clr.w	objoff_36(a0)
		move.w	#60,objoff_38(a0)	; set time delay to 1 second
		bra.s	locret_CFE6
; ===========================================================================

loc_CFC6:
		addi.w	#$800,objoff_34(a0)
		cmpi.w	#$2000,objoff_34(a0)
		blo.s	locret_CFE6
		move.w	#$2000,objoff_34(a0)
		move.w	#1,objoff_36(a0)
		move.w	#60,objoff_38(a0)	; set time delay to 1 second

locret_CFE6:
		rts	
