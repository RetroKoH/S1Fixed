; ---------------------------------------------------------------------------
; Object 7B - exploding	spikeys	that Eggman drops (SLZ)
; ---------------------------------------------------------------------------

BossSpikeball:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossSpikeball_Index(pc,d0.w),d0
		jsr		BossSpikeball_Index(pc,d0.w)
		move.w	obBossSpike_StartX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		; Removed first call to _Delete
		cmpi.w	#$280,d0
		bls.s	.display
		move.w	obRespawnAddr(a0),d0			; get address in respawn table
		beq.s	BossSLZ_Delete					; if it's zero, don't remember object
		movea.w	d0,a2							; load address into a2
		bclr	#7,(a2)							; clear respawn table entry, so object can be loaded again
		jmp		DeleteObject					; and delete object

	.display:
		jmp		(DisplayAndCollision).l			; S3K TouchResponse
; ===========================================================================

BossSpikeball_Index:	offsetTable
		offsetTableEntry.w BossSpikeball_Main
		offsetTableEntry.w BossSpikeball_Fall
		offsetTableEntry.w BossSpikeball_Bounce
		offsetTableEntry.w BossSpikeball_HitBoss
		offsetTableEntry.w BossSpikeball_Explode
		offsetTableEntry.w BossSpikeball_MoveFrag
; ===========================================================================

BossSpikeball_Main:	; Routine 0
		move.l	#Map_SSawBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_SLZ_Spikeball,0,0),obGfx(a0)
		move.b	#1,obFrame(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_8x8),obColType(a0)
		move.b	#$C,obDispWid(a0)
		movea.w	obBossSpike_Seesaw(a0),a1		; get object RAM address of seesaw below
		move.w	obX(a1),obBossSpike_StartX(a0)
		move.w	obY(a1),obBossSpike_StartY(a0)
		bset	#staFlipX,obStatus(a0)
		move.w	obX(a0),d0
		cmp.w	obX(a1),d0						; is spikeball on right side of seesaw?
		bgt.s	.on_right						; if yes, branch
		bclr	#staFlipX,obStatus(a0)
		move.b	#2,obBossSpike_State(a0)

	.on_right:
		addq.b	#2,obRoutine(a0)				; -> BSpike_Fall
; ---------------------------------------------------------------------------

BossSpikeball_Fall:	; Routine 2
		jsr		(ObjectFall_YOnly).l
		movea.w	obBossSpike_Seesaw(a0),a1		; get object RAM address of seesaw below
		lea		BossSpike_YPos(pc),a2
		moveq	#0,d0
		move.b	obFrame(a1),d0					; get seesaw frame
		move.w	obX(a0),d1
		sub.w	obBossSpike_StartX(a0),d1
		bcc.s	.on_right						; branch if spikeball is on right side of seesaw
		addq.w	#2,d0

	.on_right:
		add.w	d0,d0
		move.w	obBossSpike_StartY(a0),d1
		add.w	(a2,d0.w),d1					; d1 = expected y pos for spikeball
		cmp.w	obY(a0),d1
		bgt.s	.exit							; branch if spikeball is above d1
		movea.w	obBossSpike_Seesaw(a0),a1		; get object RAM address of seesaw below
		moveq	#2,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		moveq	#0,d1

	.no_xflip:
		move.w	#$F0,obSubtype(a0)
		move.b	#10,obDelayAni(a0)				; set frame duration to	10 frames
		move.b	obDelayAni(a0),obTimeFrame(a0)
		bra.w	BossSpikeball_Update
; ===========================================================================

	.exit:
		rts	
; ===========================================================================

BossSpikeball_Bounce:	; Routine 4
		movea.w	obBossSpike_Seesaw(a0),a1		; get object RAM address of seesaw below
		moveq	#0,d0
		move.b	obBossSpike_State(a0),d0
		sub.b	obSeesaw_State(a1),d0
		beq.s	.no_change						; branch if seesaw and spikeball have same state
		bcc.s	.on_left						; branch if spikeball lands on left side
		neg.b	d0								; make d0 positive

	.on_left:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0							; was seesaw flat?
		beq.s	.weaker							; if yes, branch
		move.w	#-$960,d1
		move.w	#-$F4,d2
		cmpi.w	#$9C0,obSeesaw_HitSpeed(a1)
		blt.s	.weaker							; branch if Sonic landed on seesaw below given speed
		move.w	#-$A20,d1
		move.w	#-$80,d2

	.weaker:
		move.w	d1,obVelY(a0)					; set bounce speed for spikeball
		move.w	d2,obVelX(a0)
		move.w	obX(a0),d0
		sub.w	obBossSpike_StartX(a0),d0
		bcc.s	.on_right						; branch if spikeball was on right side
		neg.w	obVelX(a0)						; move in correct direction

	.on_right:
		move.b	#1,obFrame(a0)
		move.w	#$20,obSubtype(a0)				; set timer
		addq.b	#2,obRoutine(a0)				; -> BossSpikeball_HitBoss
		bra.w	BossSpikeball_HitBoss
; ===========================================================================

	.no_change:
		lea		BossSpike_YPos(pc),a2
		moveq	#0,d0
		move.b	obFrame(a1),d0					; get seesaw frame
		moveq	#$28,d2							; dist from seesaw center to edge
		move.w	obX(a0),d1
		sub.w	obBossSpike_StartX(a0),d1
		bcc.s	.on_right2						; branch if spikeball is on right side
		neg.w	d2
		addq.w	#2,d0

	.on_right2:
		add.w	d0,d0
		move.w	obBossSpike_StartY(a0),d1
		add.w	(a2,d0.w),d1					; add relative y pos to initial y pos
		move.w	d1,obY(a0)						; update y pos
		add.w	obBossSpike_StartX(a0),d2		; add width to initial x pos
		move.w	d2,obX(a0)						; update x pos
		clr.w	obYSub(a0)
		clr.w	obXSub(a0)
		subq.w	#1,obSubtype(a0)				; decrement timer
		bne.s	BossSpikeball_Animate			; branch if time remains
		move.w	#$20,obSubtype(a0)				; set subtype to allow spawning of shrapnel objects
		move.b	#8,obRoutine(a0)				; -> BSpike_Explode
		rts	
; ===========================================================================

BossSpikeball_Animate:
		cmpi.w	#$78,obSubtype(a0)				; subtype decrements like a timer
		bne.s	.not_fast						; branch if not at specified value
		move.b	#5,obDelayAni(a0)				; use faster animation speed

	.not_fast:
		cmpi.w	#$3C,obSubtype(a0)
		bne.s	.not_faster
		move.b	#2,obDelayAni(a0)				; use fastest animation speed

	.not_faster:
		subq.b	#1,obTimeFrame(a0)				; decrement animation timer
		bgt.s	.wait							; branch if time remains
		bchg	#0,obFrame(a0)					; change frame
		move.b	obDelayAni(a0),obTimeFrame(a0)

	.wait:
		rts	
; ===========================================================================

BossSpikeball_HitBoss:	; Routine 6
		movea.w	obBossSpike_Parent(a0),a1		; get object RAM address of boss -- KoH Optimization
		move.w	obX(a1),d0						; position of boss
		move.w	obY(a1),d1
		move.w	obX(a0),d2						; position of spikeball
		move.w	obY(a0),d3
		lea		BossSpikeball_BossHitbox(pc),a2
		lea		BossSpikeball_BallHitbox(pc),a3
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d0,d2
		bcs.s	.boss_missed
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d2,d0
		bcs.s	.boss_missed
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d1,d3
		bcs.s	.boss_missed
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d3,d1
		bcs.s	.boss_missed

		addq.b	#2,obRoutine(a0)			; -> BSpike_Explode
		clr.w	obSubtype(a0)
		clr.b	obColType(a1)				; make boss harmless
		subq.b	#1,obColProp(a1)			; deduct hit point from boss
		bne.s	.boss_missed				; branch if not 0
		bset	#7,obStatus(a1)				; flag boss as beaten
		clr.l	obVelX(a0)					; stop spikeball moving (x/y speeds)

	.boss_missed:
		tst.w	obVelY(a0)					; is spikeball moving upwards?
		bpl.s	.downwards					; if not, branch
		jsr		(ObjectFall).l
		move.w	obBossSpike_StartY(a0),d0
		subi.w	#$2F,d0
		cmp.w	obY(a0),d0					; is spikeball within 48px of seesaw?
		bgt.w	BossSpikeball_Animate		; if yes, branch
		jsr		(ObjectFall).l
		bra.w	BossSpikeball_Animate
; ===========================================================================

	.downwards:
		jsr		(ObjectFall).l
		movea.w	obBossSpike_Seesaw(a0),a1	; get object RAM address of seesaw below
		lea		BossSpike_YPos(pc),a2
		moveq	#0,d0
		move.b	obFrame(a1),d0				; get seesaw frame
		move.w	obX(a0),d1
		sub.w	obBossSpike_StartX(a0),d1
		bcc.s	.on_right					; branch if spikeball is on right side of seesaw
		addq.w	#2,d0

	.on_right:
		add.w	d0,d0
		move.w	obBossSpike_StartY(a0),d1
		add.w	(a2,d0.w),d1				; d1 = expected y pos for spikeball
		cmp.w	obY(a0),d1
		bgt.w	BossSpikeball_Animate		; branch if spikeball is above d1
		movea.w	obBossSpike_Seesaw(a0),a1	; get object RAM address of seesaw below
		moveq	#2,d1
		tst.w	obVelX(a0)
		bmi.s	.moving_left
		moveq	#0,d1

	.moving_left:
		clr.w	obSubtype(a0)
; ---------------------------------------------------------------------------

BossSpikeball_Update:
		move.b	d1,obSeesaw_State(a1)		; set new state for seesaw (0 or 2)
		move.b	d1,obBossSpike_State(a0)
		cmp.b	obFrame(a1),d1				; was seesaw in a different state previously?
		beq.s	.no_change					; if not, branch
		bclr	#staSonicOnObj,obStatus(a1)
		beq.s	.no_change					; branch if Sonic wasn't on the seesaw

		clr.b	ob2ndRout(a1)
		move.b	#2,obRoutine(a1)			; reset seesaw routine
		lea		(v_player).w,a2
		move.w	obVelY(a0),obVelY(a2)
		neg.w	obVelY(a2)					; launch Sonic into air
		cmpi.b	#1,obFrame(a1)				; was seesaw flat?
		bne.s	.not_flat					; if not, branch
		asr		obVelY(a2)

	.not_flat:
		bset	#staAir,obStatus(a2)
		bclr	#staOnObj,obStatus(a2)
		clr.b	obJumping(a2)				; set Sonic's jumping flag
		move.l	a0,-(sp)					; save spikeball's RAM address to stack
		lea		(a2),a0						; temporarily load Sonic to a0
		jsr		(Sonic_ChkRoll).l			; allow Sonic to bounce-roll off seesaw
		movea.l	(sp)+,a0					; restore spikeball OST to a0
		move.b	#2,obRoutine(a2)			; set Sonic to his standard routine
		move.w	#sfx_Spring,d0
		jsr		(QueueSound2).w				; play "spring" sound

.no_change:
		clr.l	obVelX(a0)					; clear x/y speeds
		addq.b	#2,obRoutine(a0)			; -> BossSpikeball_Bounce
		bra.w	BossSpikeball_Animate
; ===========================================================================

BossSpike_YPos:
		dc.w -8								; on raised side
		dc.w -$1C							; on flat
		dc.w -$2F							; on low side
		dc.w -$1C
		dc.w -8
		even

BossSpikeball_BossHitbox:
	; half width, full width
		dc.b -$18, $30						; left to right
		dc.b -$18, $30						; top to bottom
		even

BossSpikeball_BallHitbox:
	; half width, full width
		dc.b 8,	-$10						; right to left
		dc.b 8, -$10						; bottom to top
		even
; ===========================================================================

BossSpikeball_Explode:	; Routine 8
		move.b	#id_ExplosionBomb,obID(a0)	; turn object into explosion
		clr.b	obRoutine(a0)
		cmpi.w	#$20,obSubtype(a0)			; is shrapnel flag set?
		beq.s	.make_frags					; if yes, branch
		rts	
; ===========================================================================

	.make_frags:
		move.w	obBossSpike_StartY(a0),obY(a0)
		moveq	#3,d1
		lea		BossSpikeball_FragSpeed(pc),a2

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindFreeObj/SingleObjLoad. It'll be quicker to loop through here.
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d0

	.loop:
		; REMOVE FindFreeObj. It's the routine that causes such slowdown
		tst.b	obID(a1)							; is object RAM	slot empty?
		beq.s	.makeshrapnel						; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		object_size(a1),a1
		dbf		d0,.loop							; Branch correction again.
		bne.s	.end

	.makeshrapnel:
		move.b	#id_BossSpikeball,obID(a1)			; load shrapnel object
		move.b	#$A,obRoutine(a1)					; -> BSpike_MoveFrag
		move.l	#Map_BSBall,obMap(a1)
		move.w	#priority3,obPriority(a1)			; RetroKoH/Devon S3K+ Priority Manager
		move.w	#make_art_tile(ArtTile_SLZ_Shrapnel,0,0),obGfx(a1)	; RetroKoH VRAM Overhaul	
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	(a2)+,obVelX(a1)					; move the data contained in the array to obVelX and obVelY, and increment the address in a2
		move.b	#(colHarmful|colSz_4x4),obColType(a1)

		bset	#shPropReflect,obShieldProp(a1)		; Reflected by Elemental Shields

		ori.b	#4,obRender(a1)
		bset	#7,obRender(a1)
		move.b	#$C,obDispWid(a1)
		dbf		d1,.loop							; repeat sequence 3 more times

	.end:
		rts	
; ===========================================================================
BossSpikeball_FragSpeed:
		dc.w -$100, -$340	; horizontal, vertical
		dc.w -$A0, -$240
		dc.w $100, -$340
		dc.w $A0, -$240
; ===========================================================================

BossSpikeball_MoveFrag:	; Routine $A
		jsr		(SpeedToPos).l
		move.w	obX(a0),obBossSpike_StartX(a0)
		move.w	obY(a0),obBossSpike_StartY(a0)
		addi.w	#$18,obVelY(a0)				; apply gravity
		moveq	#4,d0
		and.w	(v_vbla_word).w,d0
		lsr.w	#2,d0						; d0 = bit that changed every 4th frame
		move.b	d0,obFrame(a0)				; set as frame
		tst.b	obRender(a0)				; is object on-screen?
	; Clownacy DisplaySprite Fix
		bpl.s   .delete						; if not, branch
		rts
; ===========================================================================

	.delete:
        addq.l  #4,sp
		jmp		(DeleteObject).l
; ===========================================================================