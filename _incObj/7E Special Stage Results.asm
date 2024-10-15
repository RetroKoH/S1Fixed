; ---------------------------------------------------------------------------
; Object 7E - special stage results screen
; ---------------------------------------------------------------------------

SSResult:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SSR_Index(pc,d0.w),d1
		jmp		SSR_Index(pc,d1.w)
; ===========================================================================
SSR_Index:	offsetTable
		offsetTableEntry.w SSR_ChkPLC
		offsetTableEntry.w SSR_Move
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_RingBonus
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_Exit
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_Continue
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_Exit
		offsetTableEntry.w loc_C91A

ssr_mainX = objoff_30		; position for card to display on
; ===========================================================================

SSR_ChkPLC:	; Routine 0
		tst.l	(v_plc_buffer).w ; are the pattern load cues empty?
		beq.s	SSR_Main	; if yes, branch
		rts	
; ===========================================================================

SSR_Main:
		movea.l	a0,a1
		lea		(SSR_Config).l,a2
		moveq	#3+(1*PerfectBonusEnabled),d1

	if SpecialStagesWithAllEmeralds=1	; Mercury Special Stages Still Appear With All Emeralds
		btst	#7,(v_continues).w
		beq.s	SSR_Loop				; if no, branch
	else
		cmpi.w	#50,(v_rings).w			; do you have 50 or more rings?
		blo.s	SSR_Loop				; if no, branch
	endif	; Special Stages Still Appear With All Emeralds	End

		addq.w	#1,d1					; if yes, add 1	to d1 (number of sprites)

SSR_Loop:
		_move.b	#id_SSResult,obID(a1)
		move.w	(a2)+,obX(a1)			; load start x-position
		move.w	(a2)+,ssr_mainX(a1)		; load main x-position
		move.w	(a2)+,obScreenY(a1)		; load y-position
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obFrame(a1)
		move.l	#Map_SSR,obMap(a1)
		move.w	#make_art_tile(ArtTile_Title_Card,0,1),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		lea		object_size(a1),a1
		dbf		d1,SSR_Loop				; repeat sequence 3 or 4 times

		moveq	#7,d0
		move.b	(v_emeralds).w,d1
		beq.s	loc_C842
		moveq	#0,d0
		cmpi.b	#emldCount,d1			; do you have all chaos	emeralds?
		bne.s	loc_C842				; if not, branch
		moveq	#8,d0					; load "Got Them All" text
		move.w	#$18,obX(a0)
		move.w	#$118,ssr_mainX(a0) 	; change position of text

loc_C842:
		move.b	d0,obFrame(a0)

SSR_Move:	; Routine 2
		moveq	#$10,d1		; set horizontal speed
		move.w	ssr_mainX(a0),d0
		cmp.w	obX(a0),d0	; has item reached its target position?
		beq.s	loc_C86C	; if yes, branch
		bge.s	SSR_ChgPos
		neg.w	d1

SSR_ChgPos:
		add.w	d1,obX(a0)	; change item's position

loc_C85A:
		move.w	obX(a0),d0
		bmi.s	locret_C86A
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bhs.s	locret_C86A	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C86A:
		rts	
; ===========================================================================

loc_C86C:
		cmpi.b	#2,obFrame(a0)
		bne.s	loc_C85A
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0) ; set time delay to 3 seconds
		move.b	#id_SSRChaos,(v_ssresemeralds).w ; load chaos emerald object

SSR_Wait:	; Routine 4, 8, $C, $10
		subq.w	#1,obTimeFrame(a0) ; subtract 1 from time delay
		bne.s	SSR_Display
		addq.b	#2,obRoutine(a0)

SSR_Display:
		bra.w	DisplaySprite
; ===========================================================================

	if SpeedUpScoreTally<>2
SSR_RingBonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w	; set ring bonus update flag
		tst.w	(v_ringbonus).w			; is ring bonus	= zero?
		beq.s	loc_C8C4				; if yes, branch

	if SpeedUpScoreTally=1	; Mercury Speed Up Score Tally
		moveq	#10,d1			; set score decrement to 10
		move.b	(v_jpadhold1).w,d0
		andi.b	#btnABC,d0		; is A, B or C pressed?
		beq.w	.dontspeedup	; if not, branch
		move.b	#100,d1			; increase score decrement to 100
		
.dontspeedup:
		moveq	#0,d0
		cmp.w	(v_ringbonus).w,d1	; compare ring bonus to score decrement
		blt.s	.skip				; if it's greater or equal, branch
		move.w	(v_ringbonus).w,d1	; else, set the decrement to the remaining bonus
.skip:
		add.w	d1,d0				; add decrement to score
		sub.w	d1,(v_ringbonus).w	; subtract decrement from ring bonus
	else
		subi.w	#10,(v_ringbonus).w	; subtract 10 from ring bonus
		moveq	#10,d0				; add 10 to score
	endif	;end Speed Up Score Tally
; ---------------------------------------------------------------------------

		jsr		(AddPoints).l
		move.b	(v_vbla_byte).w,d0
		andi.b	#3,d0
		bne.s	locret_C8EA
		move.w	#sfx_Switch,d0
		jmp		(PlaySound_Special).w	; play "blip" sound
; ===========================================================================

loc_C8C4:
	else	; RetroKoH Instant Score Tally
; ---------------------------------------------------------------------------
SSR_RingBonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w	; set time/ring bonus update flag
		moveq	#0,d0
		move.w	(v_ringbonus).w,d0		; load ring bonus to d0
		clr.w	(v_ringbonus).w			; clear ring bonus
	
	if PerfectBonusEnabled
		add.w	(v_perfectbonus).w,d0	; add perfect bonus to d0
		clr.w	(v_perfectbonus).w		; clear perfect bonus
	endif

		jsr		(AddPoints).l			; add to score
	endif	;end Instant Score Tally
; ---------------------------------------------------------------------------

		move.w	#sfx_Cash,d0
		jsr		(PlaySound_Special).w	; play "ker-ching" sound
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0) ; set time delay to 3 seconds
		cmpi.w	#50,(v_rings).w	; do you have at least 50 rings?
		blo.s	locret_C8EA	; if not, branch
		move.w	#60,obTimeFrame(a0) ; set time delay to 1 second
		addq.b	#4,obRoutine(a0) ; goto "SSR_Continue" routine

locret_C8EA:
		rts	
; ===========================================================================

SSR_Exit:	; Routine $A, $12
		move.b	#1,(f_restart).w ; restart level
		bra.w	DisplaySprite
; ===========================================================================

SSR_Continue:	; Routine $E
		move.b	#4,(v_ssrescontinue+obFrame).w
		move.b	#$14,(v_ssrescontinue+obRoutine).w
		move.w	#sfx_Continue,d0
		jsr	(PlaySound_Special).w	; play continues jingle
		addq.b	#2,obRoutine(a0)
		move.w	#360,obTimeFrame(a0) ; set time delay to 6 seconds
		bra.w	DisplaySprite
; ===========================================================================

loc_C91A:	; Routine $14
		move.b	(v_vbla_byte).w,d0
		andi.b	#$F,d0
		bne.s	SSR_Display2
		bchg	#0,obFrame(a0)

SSR_Display2:
		bra.w	DisplaySprite
; ===========================================================================
		;    x-start,	x-main,	y-pos,
		;				routine, frame number

SSR_Config:
		dc.w $20,	$120,	$C4		; "CHAOS EMERALDS"
		dc.b 2,	0
		dc.w $320,	$120,	$118	; SCORE
		dc.b 2,	1
		dc.w $360,	$120,	$128	; RING BONUS
		dc.b 2,	2
		dc.w $1EC,	$11C,	$C4		; Oval
		dc.b 2,	3
	if PerfectBonusEnabled
		dc.w $3A0,	$120,	$138	; PERFECT
		dc.b 2,	9
	endif
		dc.w $3A0+($40*PerfectBonusEnabled),	$120,	$138+($10*PerfectBonusEnabled)	; CONTINUE
		dc.b 2,	6
