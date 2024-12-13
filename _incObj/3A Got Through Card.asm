; ---------------------------------------------------------------------------
; Object 3A - "SONIC GOT THROUGH" title	card
; ---------------------------------------------------------------------------

	if (CoolBonusEnabled=0)&(PerfectBonusEnabled=1)
got_pieces = 5
	else
got_pieces = 6	
	endif

GotThroughCard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Got_Index(pc,d0.w),d1
		jmp		Got_Index(pc,d1.w)
; ===========================================================================
Got_Index:	offsetTable
		offsetTableEntry.w Got_ChkPLC
		offsetTableEntry.w Got_Move
		offsetTableEntry.w Got_Wait
		offsetTableEntry.w Got_TimeBonus
		offsetTableEntry.w Got_Wait
		offsetTableEntry.w Got_NextLevel
		offsetTableEntry.w Got_Wait
		offsetTableEntry.w Got_Move2
		offsetTableEntry.w loc_C766

got_mainX = objoff_30		; position for card to display on
got_finalX = objoff_32		; position for card to finish on
; ===========================================================================

Got_ChkPLC:	; Routine 0
		tst.l	(v_plc_buffer).w		; are the pattern load cues empty?
		beq.s	Got_Main				; if yes, branch
		rts	
; ===========================================================================

Got_Main:
		movea.l	a0,a1
		lea		(Got_Config).l,a2
		moveq	#got_pieces,d1
		
	if PerfectBonusEnabled
		tst.w	(v_perfectringsleft).w	; did you score a Perfect?
		bne.s	Got_Loop
		addq.w	#1,d1					; if yes, add 1	to d1 (number of sprites)
	endif

Got_Loop:
		_move.b	#id_GotThroughCard,obID(a1)
		move.w	(a2),obX(a1)			; load start x-position
		move.w	(a2)+,got_finalX(a1)	; load finish x-position (same as start)
		move.w	(a2)+,got_mainX(a1)		; load main x-position
		move.w	(a2)+,obScreenY(a1)		; load y-position
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,d0
		cmpi.b	#got_pieces,d0
		bne.s	loc_C5CA
		add.b	(v_act).w,d0			; add act number to frame number

loc_C5CA:
		move.b	d0,obFrame(a1)
		move.l	#Map_Got,obMap(a1)
		move.w	#make_art_tile(ArtTile_Title_Card,0,1),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		lea		object_size(a1),a1
		dbf		d1,Got_Loop				; repeat [got_pieces] times

Got_Move:	; Routine 2
		moveq	#$10,d1					; set horizontal speed
		move.w	got_mainX(a0),d0
		cmp.w	obX(a0),d0				; has item reached its target position?
		beq.s	loc_C61A				; if yes, branch
		bge.s	Got_ChgPos
		neg.w	d1

Got_ChgPos:
		add.w	d1,obX(a0)				; change item's position

loc_C5FE:
		move.w	obX(a0),d0
		bmi.s	locret_C60E
		cmpi.w	#$200,d0				; has item moved beyond	$200 on	x-axis?
		bhs.s	locret_C60E				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C60E:
		rts	
; ===========================================================================

loc_C610:
		move.b	#$E,obRoutine(a0)
		bra.w	Got_Move2
; ===========================================================================

loc_C61A:
		cmpi.b	#$E,(v_endcardring+obRoutine).w
		beq.s	loc_C610
		cmpi.b	#4,obFrame(a0)
		bne.s	loc_C5FE
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0) ; set time delay to 3 seconds

Got_Wait:	; Routine 4, 8, $C
		subq.w	#1,obTimeFrame(a0) ; subtract 1 from time delay
		bne.s	Got_Display
		addq.b	#2,obRoutine(a0)

Got_Display:
		bra.w	DisplaySprite
; ===========================================================================

	if SpeedUpScoreTally<>2
; ---------------------------------------------------------------------------
	if SpeedUpScoreTally=1	; Mercury Speed Up Score Tally
Got_TimeBonus:	; Routine 6
		bsr.w	DisplaySprite
		moveq	#10,d1					; set score decrement to 10
		move.b	(v_jpadhold1).w,d0
		andi.b	#btnABC,d0				; is A, B or C pressed?
		beq.w	.dontspeedup			; if not, branch
		move.b	#100,d1					; increase score decrement to 100
		
.dontspeedup:
		move.b	#1,(f_endactbonus).w	; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_timebonus).w			; is time bonus	= zero?
		beq.s	Got_RingBonus			; if yes, branch
		cmp.w	(v_timebonus).w,d1		; compare time bonus to score decrement
		blt.s	.skip					; if it's greater or equal, branch
		move.w	(v_timebonus).w,d1		; else, set the decrement to the remaining bonus
.skip:
		add.w	d1,d0					; add decrement to score
		sub.w	d1,(v_timebonus).w		; subtract decrement from time bonus

Got_RingBonus:
		tst.w	(v_ringbonus).w			; is ring bonus	= zero?
		beq.s	.afterrings				; if yes, branch (We must use a temp label to ensure potential mods are branched to)
		cmp.w	(v_ringbonus).w,d1		; compare ring bonus to score decrement
		blt.s	.skip					; if it's greater or equal, branch
		move.w	(v_ringbonus).w,d1		; else, set the decrement to the remaining bonus
.skip:
		add.w	d1,d0					; add decrement to score
		sub.w	d1,(v_ringbonus).w		; subtract decrement from ring bonus
	
.afterrings:
		if CoolBonusEnabled
	Got_CoolBonus:
		tst.w	(v_coolbonus).w			; is cool bonus = zero?
		beq.s	.aftercool				; if yes, branch (We must use a temp label to ensure potential mods are branched to)
		cmp.w	(v_coolbonus).w,d1		; compare cool bonus to score decrement
		blt.s	.skip					; if it's greater or equal, branch
		move.w	(v_coolbonus).w,d1		; else, set the decrement to the remaining bonus
.skip:
		add.w	d1,d0					; add decrement to score
		sub.w	d1,(v_coolbonus).w		; subtract decrement from cool bonus
	.aftercool:
		endif

		if PerfectBonusEnabled
	Got_PerfectBonus:
		tst.w	(v_perfectbonus).w		; is perfect bonus = zero?
		beq.s	Got_ChkBonus			; if yes, branch (We must use a temp label to ensure potential mods are branched to)
		cmp.w	(v_perfectbonus).w,d1	; compare perfect bonus to score decrement
		blt.s	.skip					; if it's greater or equal, branch
		move.w	(v_perfectbonus).w,d1	; else, set the decrement to the remaining bonus
.skip:
		add.w	d1,d0					; add decrement to score
		sub.w	d1,(v_perfectbonus).w	; subtract decrement from perfect bonus
		endif

	else

Got_TimeBonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w	; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_timebonus).w			; is time bonus	= zero?
		beq.s	Got_RingBonus			; if yes, branch
		addi.w	#10,d0					; add 10 to score
		subi.w	#10,(v_timebonus).w		; subtract 10 from time bonus

Got_RingBonus:
		tst.w	(v_ringbonus).w			; is ring bonus	= zero?
		beq.s	.afterrings				; if yes, branch (We must use a temp label to ensure potential mods are branched to)
		addi.w	#10,d0					; add 10 to score
		subi.w	#10,(v_ringbonus).w		; subtract 10 from ring bonus

	.afterrings:
		if CoolBonusEnabled
	Got_CoolBonus:
			tst.w	(v_coolbonus).w			; is cool bonus	= zero?
			beq.s	.aftercool				; if yes, branch (We must use a temp label to ensure potential mods are branched to)
			addi.w	#10,d0					; add 10 to score
			subi.w	#10,(v_coolbonus).w		; subtract 10 from cool bonus
	.aftercool:
		endif

		if PerfectBonusEnabled
	Got_PerfectBonus:
			tst.w	(v_perfectbonus).w		; is perfect bonus = zero?
			beq.s	Got_ChkBonus			; if yes, branch
			addi.w	#10,d0					; add 10 to score
			subi.w	#10,(v_perfectbonus).w	; subtract 10 from perfect bonus
		endif

	endif	; Speed Up Score Tally End
; ---------------------------------------------------------------------------

Got_ChkBonus:
		tst.w	d0						; is there any bonus?
		bne.s	Got_AddBonus			; if yes, branch

	else	; RetroKoH Instant Score Tally
; ---------------------------------------------------------------------------
Got_TimeBonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w	; set time/ring bonus update flag
		moveq	#0,d0
		move.w	(v_timebonus).w,d0		; load time bonus to d0
		clr.w	(v_timebonus).w			; clear time bonus
		add.w	(v_ringbonus).w,d0		; load ring bonus to d0
		clr.w	(v_ringbonus).w			; clear ring bonus
	if CoolBonusEnabled
		add.w	(v_coolbonus).w,d0		; load cool bonus to d0
		clr.w	(v_coolbonus).w			; clear cool bonus
	endif
	if PerfectBonusEnabled
		add.w	(v_perfectbonus).w,d0	; load cool bonus to d0
		clr.w	(v_perfectbonus).w		; clear cool bonus
	endif
		jsr		(AddPoints).l			; add to score

	endif	;end Instant Score Tally
; ---------------------------------------------------------------------------

		move.w	#sfx_Cash,d0
		jsr		(PlaySound_Special).w	; play "ker-ching" sound
		addq.b	#2,obRoutine(a0)
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w
		bne.s	Got_SetDelay
		addq.b	#4,obRoutine(a0)		; SBZ2 specific routine

Got_SetDelay:
		move.w	#180,obTimeFrame(a0)	; set time delay to 3 seconds

locret_C692:
		rts	
; ===========================================================================
	if SpeedUpScoreTally<>2
Got_AddBonus:
		jsr		(AddPoints).l
		move.b	(v_vbla_byte).w,d0
		andi.b	#3,d0
		bne.s	locret_C692
		move.w	#sfx_Switch,d0
		jmp		(PlaySound_Special).w	; play "blip" sound
	endif
; ===========================================================================

Got_NextLevel:	; Routine $A
		move.b	(v_zone).w,d0
		andi.w	#7,d0
		lsl.w	#3,d0
		move.b	(v_act).w,d1
		andi.w	#3,d1
		add.w	d1,d1
		add.w	d1,d0
		move.w	LevelOrder(pc,d0.w),d0		; load level from level order array
		move.w	d0,(v_zone).w				; set level number
		tst.w	d0
		bne.s	Got_ChkSS
		move.b	#id_Sega,(v_gamemode).w		; if no next level is set, return to the SEGA screen
		bra.s	Got_Display2				; display sprite for one more frame before returning to SEGA
; ===========================================================================

Got_ChkSS:
	if CoolBonusEnabled
		move.b	#CoolBonusHits,(v_hitscount).w	; set hits count for next cool bonus
	endif

		clr.b	(v_lastlamp).w				; clear	lamppost counter
		tst.b	(f_bigring).w				; has Sonic jumped into	a giant	ring?
		beq.s	loc_C6EA					; if not, branch
		move.b	#id_Special,(v_gamemode).w	; set game mode to Special Stage (10)
		bra.s	Got_Display2
; ===========================================================================

loc_C6EA:
		move.b	#1,(f_restart).w			; restart level

Got_Display2:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	order array
; ---------------------------------------------------------------------------
LevelOrder:
	if BetaLevelOrder=1
		; Green Hill Zone
		dc.b id_GHZ, 1	; Act 1
		dc.b id_GHZ, 2	; Act 2
		dc.b id_LZ, 0	; Act 3
		dc.b 0, 0

		; Labyrinth Zone
		dc.b id_LZ, 1	; Act 1
		dc.b id_LZ, 2	; Act 2
		dc.b id_MZ, 0	; Act 3
		dc.b id_SBZ, 2	; Scrap Brain Zone Act 3

		; Marble Zone
		dc.b id_MZ, 1	; Act 1
		dc.b id_MZ, 2	; Act 2
		dc.b id_SLZ, 0	; Act 3
		dc.b 0, 0

		; Star Light Zone
		dc.b id_SLZ, 1	; Act 1
		dc.b id_SLZ, 2	; Act 2
		dc.b id_SYZ, 0	; Act 3
		dc.b 0, 0

		; Spring Yard Zone
		dc.b id_SYZ, 1	; Act 1
		dc.b id_SYZ, 2	; Act 2
		dc.b id_SBZ, 0	; Act 3
		dc.b 0, 0

		; Scrap Brain Zone
		dc.b id_SBZ, 1	; Act 1
		dc.b id_LZ, 3	; Act 2
		dc.b 0, 0	; Final Zone
		dc.b 0, 0
		even
		zonewarning LevelOrder,8
	else
		; Green Hill Zone
		dc.b id_GHZ, 1	; Act 1
		dc.b id_GHZ, 2	; Act 2
		dc.b id_MZ, 0	; Act 3
		dc.b 0, 0

		; Labyrinth Zone
		dc.b id_LZ, 1	; Act 1
		dc.b id_LZ, 2	; Act 2
		dc.b id_SLZ, 0	; Act 3
		dc.b id_SBZ, 2	; Scrap Brain Zone Act 3

		; Marble Zone
		dc.b id_MZ, 1	; Act 1
		dc.b id_MZ, 2	; Act 2
		dc.b id_SYZ, 0	; Act 3
		dc.b 0, 0

		; Star Light Zone
		dc.b id_SLZ, 1	; Act 1
		dc.b id_SLZ, 2	; Act 2
		dc.b id_SBZ, 0	; Act 3
		dc.b 0, 0

		; Spring Yard Zone
		dc.b id_SYZ, 1	; Act 1
		dc.b id_SYZ, 2	; Act 2
		dc.b id_LZ, 0	; Act 3
		dc.b 0, 0

		; Scrap Brain Zone
		dc.b id_SBZ, 1	; Act 1
		dc.b id_LZ, 3	; Act 2
		dc.b 0, 0	; Final Zone
		dc.b 0, 0
		even
		zonewarning LevelOrder,8
	endif
; ===========================================================================

Got_Move2:	; Routine $E
		moveq	#$20,d1		; set horizontal speed
		move.w	got_finalX(a0),d0
		cmp.w	obX(a0),d0	; has item reached its finish position?
		beq.s	Got_SBZ2	; if yes, branch
		bge.s	Got_ChgPos2
		neg.w	d1

Got_ChgPos2:
		add.w	d1,obX(a0)	; change item's position
		move.w	obX(a0),d0
		bmi.s	locret_C748
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bhs.s	locret_C748	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C748:
		rts	
; ===========================================================================

Got_SBZ2:
		cmpi.b	#4,obFrame(a0)
		bne.w	DeleteObject
		addq.b	#2,obRoutine(a0)
		clr.b	(f_lockctrl).w			; unlock controls
		move.w	#bgm_FZ,d0
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		jmp		(PlaySound).w			; play FZ music
; ===========================================================================

loc_C766:	; Routine $10
		addq.w	#2,(v_limitright2).w
		cmpi.w	#$2100,(v_limitright2).w
		beq.w	DeleteObject
		rts	
; ===========================================================================
		;    x-start,	x-main,	y-pos,
		;				routine, frame number

Got_Config:
		dc.w 4,		$124,	$BC			; "SONIC HAS"
		dc.b 				2,	0

		dc.w -$120,	$120,	$D0			; "PASSED"
		dc.b 				2,	1

		dc.w $40C,	$14C,	$D6			; "ACT" 1/2/3 -- Modified to accomodate toggles
		dc.b 				2,	got_pieces

; ---------------------------------------------------------------------------
	if ExtraBonuses=0
	
		dc.w $520,	$120,	$EC			; score
		dc.b 				2,	2

		dc.w $540,	$120,	$FC			; time bonus
		dc.b 				2,	3

		dc.w $560,	$120,	$10C		; ring bonus
		dc.b 				2,	4

		dc.w $20C,	$14C,	$CC			; oval -- Modified to accomodate toggles
		dc.b 				2,	(got_pieces-1)

; ---------------------------------------------------------------------------
	else
	
		dc.w $520,	$120,	$EC			; time bonus
		dc.b 				2,	2

		dc.w $540,	$120,	$FC			; ring bonus
		dc.b 				2,	3

		if CoolBonusEnabled
			dc.w $560,	$120,	$10C	; cool bonus
			dc.b 				2,	4
		endif

		dc.w $20C,	$14C,	$CC			; oval -- Modified to accomodate Cool Bonus toggle
		dc.b 				2,	(got_pieces-1)
		
		if PerfectBonusEnabled
			dc.w $560+($20*CoolBonusEnabled),	$120,	$10C+($10*CoolBonusEnabled)		; perfect
			dc.b 				2,	got_pieces+3
		endif

; ---------------------------------------------------------------------------
	endif