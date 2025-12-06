; ---------------------------------------------------------------------------
; Object 3A - "SONIC HAS PASSED" title card (Really need to rename all of this)
; ---------------------------------------------------------------------------

	if (~~CoolBonusEnabled)&(PerfectBonusEnabled)
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
		offsetTableEntry.w Got_Main
		offsetTableEntry.w Got_Move
		offsetTableEntry.w Got_Wait
		offsetTableEntry.w Got_Bonus
		offsetTableEntry.w Got_Wait
		offsetTableEntry.w Got_NextLevel
		offsetTableEntry.w Got_Wait
		offsetTableEntry.w Got_MoveBack
		offsetTableEntry.w Got_Boundary
; ===========================================================================

Got_Main:	; Routine 0
		tst.l	(v_plc_buffer).w				; are the pattern load cues empty?
		beq.s	.plc_free						; if yes, branch
		rts	
; ===========================================================================

	.plc_free:
		movea.l	a0,a1
		lea		(Got_Config).l,a2
		moveq	#got_pieces,d1
		
	if PerfectBonusEnabled
		tst.w	(v_perfectringsleft).w			; did you score a Perfect?
		bne.s	.loop
		addq.w	#1,d1							; if yes, add 1	to d1 (number of sprites)
	endif

	.loop:
		_move.b	#id_GotThroughCard,obID(a1)
		move.w	(a2),obX(a1)					; load start x-position
		move.w	(a2)+,obEoLCard_FinalX(a1)		; load finish x-position (same as start)
		move.w	(a2)+,obEoLCard_DisplayX(a1)	; load main x-position
		move.w	(a2)+,obScreenY(a1)				; load y-position
		move.b	(a2)+,obRoutine(a1)				; -> Has_Move
		move.b	(a2)+,d0						; get frame number
		cmpi.b	#got_pieces,d0					; is object the act number?
		bne.s	.not_act						; if not, branch
		add.b	(v_act).w,d0					; add act number to frame number

	.not_act:
		move.b	d0,obFrame(a1)					; set frame number
		move.l	#Map_Got,obMap(a1)
		move.w	#make_art_tile(ArtTile_Title_Card,0,1),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		lea		object_size(a1),a1
		dbf		d1,.loop						; repeat [got_pieces] times
; ---------------------------------------------------------------------------

Got_Move:	; Routine 2
		moveq	#16,d1							; set horizontal speed
		move.w	obEoLCard_DisplayX(a0),d0
		cmp.w	obX(a0),d0						; has item reached its target position?
		beq.s	.at_target						; if yes, branch
		bge.s	.is_left						; branch if object is left of target position
		neg.w	d1								; move left instead

	.is_left:
		add.w	d1,obX(a0)						; change item's position

	.chk_visible:
		move.w	obX(a0),d0
		bmi.s	.exit							; branch if object is at -ve x pos
		cmpi.w	#$200,d0						; has item moved beyond	$200 on	x-axis?
		bhs.s	.exit							; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

	.exit:
		rts	
; ===========================================================================

	.sbz2_ending:
		move.b	#$E,obRoutine(a0)				; -> Got_MoveBack
		bra.w	Got_MoveBack
; ===========================================================================

	.at_target:
		cmpi.b	#$E,(v_endcardring+obRoutine).w	; is ring bonus object on routine Has_MoveBack?
		beq.s	.sbz2_ending					; if yes, branch
		cmpi.b	#4,obFrame(a0)					; is object the ring bonus?
		bne.s	.chk_visible					; if not, branch

		addq.b	#2,obRoutine(a0)				; goto Has_Wait next, and then Has_Bonus
		move.w	#180,obTimeFrame(a0)			; set time delay to 3 seconds
; ---------------------------------------------------------------------------

Got_Wait:	; Routine 4, 8, $C
		subq.w	#1,obTimeFrame(a0)				; decrement timer
		bne.w	DisplaySprite					; branch if time remains
		addq.b	#2,obRoutine(a0)				; goto Has_Bonus/Has_NextLevel/Has_MoveBack next
		bra.w	DisplaySprite
; ===========================================================================

	switch SpeedUpScoreTally
	case 2
; ---------------------------------------------------------------------------
; INSTANT SCORE TALLY
; ---------------------------------------------------------------------------

Got_Bonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w		; set time/ring bonus update flag
		moveq	#0,d0
		move.w	(v_timebonus).w,d0			; load time bonus to d0
		clr.w	(v_timebonus).w				; clear time bonus
		add.w	(v_ringbonus).w,d0			; load ring bonus to d0
		clr.w	(v_ringbonus).w				; clear ring bonus
	if CoolBonusEnabled
		add.w	(v_coolbonus).w,d0			; load cool bonus to d0
		clr.w	(v_coolbonus).w				; clear cool bonus
	endif
	if PerfectBonusEnabled
		add.w	(v_perfectbonus).w,d0		; load cool bonus to d0
		clr.w	(v_perfectbonus).w			; clear cool bonus
	endif
		jsr		(AddPoints).l				; add to score
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
	case 1
; ---------------------------------------------------------------------------
; FASTER SCORE TALLY
; ---------------------------------------------------------------------------

Got_Bonus:	; Routine 6
		bsr.w	DisplaySprite
		moveq	#10,d1						; set score decrement to 10
		move.b	(v_jpadheld_actual).w,d0
		andi.b	#btnABC,d0					; is A, B or C pressed?
		beq.w	.dontspeedup				; if not, branch
		move.b	#100,d1						; increase score decrement to 100
		
	.dontspeedup:
		move.b	#1,(f_endactbonus).w		; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_timebonus).w				; is time bonus	= zero?
		beq.s	.no_timebonus				; if yes, branch
		cmp.w	(v_timebonus).w,d1			; compare time bonus to score decrement
		blt.s	.skip_time					; if it's greater or equal, branch
		move.w	(v_timebonus).w,d1			; else, set the decrement to the remaining bonus

	.skip_time:
		add.w	d1,d0						; add decrement to score
		sub.w	d1,(v_timebonus).w			; subtract decrement from time bonus

	.no_timebonus:
		tst.w	(v_ringbonus).w				; is ring bonus	= zero?
		beq.s	.afterrings					; if yes, branch (We must use a temp label to ensure potential mods are branched to)
		cmp.w	(v_ringbonus).w,d1			; compare ring bonus to score decrement
		blt.s	.skip_rings					; if it's greater or equal, branch
		move.w	(v_ringbonus).w,d1			; else, set the decrement to the remaining bonus

	.skip_rings:
		add.w	d1,d0						; add decrement to score
		sub.w	d1,(v_ringbonus).w			; subtract decrement from ring bonus
	
	.no_ringbonus:
		if CoolBonusEnabled
			tst.w	(v_coolbonus).w			; is cool bonus = zero?
			beq.s	.no_coolbonus			; if yes, branch (We must use a temp label to ensure potential mods are branched to)
			cmp.w	(v_coolbonus).w,d1		; compare cool bonus to score decrement
			blt.s	.skip_cool				; if it's greater or equal, branch
			move.w	(v_coolbonus).w,d1		; else, set the decrement to the remaining bonus

		.skip_cool:
			add.w	d1,d0					; add decrement to score
			sub.w	d1,(v_coolbonus).w		; subtract decrement from cool bonus

		.no_coolbonus:
		endif

		if PerfectBonusEnabled
			tst.w	(v_perfectbonus).w		; is perfect bonus = zero?
			beq.s	.no_perfectbonus		; if yes, branch (We must use a temp label to ensure potential mods are branched to)
			cmp.w	(v_perfectbonus).w,d1	; compare perfect bonus to score decrement
			blt.s	.skip					; if it's greater or equal, branch
			move.w	(v_perfectbonus).w,d1	; else, set the decrement to the remaining bonus

	.skip_perfect:
			add.w	d1,d0					; add decrement to score
			sub.w	d1,(v_perfectbonus).w	; subtract decrement from perfect bonus

		.no_perfectbonus:
		endif

		tst.w	d0							; is there any bonus?
		bne.s	Got_AddBonus				; if yes, branch
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
	elsecase
; ---------------------------------------------------------------------------
; NORMAL SCORE TALLY
; ---------------------------------------------------------------------------

Got_Bonus:	; Routine 6
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w		; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_timebonus).w				; is time bonus	= zero?
		beq.s	.no_timebonus				; if yes, branch
		addi.w	#10,d0						; add 10 to score
		subi.w	#10,(v_timebonus).w			; subtract 10 from time bonus

	.no_timebonus:
		tst.w	(v_ringbonus).w				; is ring bonus	= zero?
		beq.s	.no_ringbonus				; if yes, branch
		addi.w	#10,d0						; add 10 to score
		subi.w	#10,(v_ringbonus).w			; subtract 10 from ring bonus

	.no_ringbonus:
		if CoolBonusEnabled
			tst.w	(v_coolbonus).w			; is cool bonus	= zero?
			beq.s	.no_coolbonus			; if yes, branch
			addi.w	#10,d0					; add 10 to score
			subi.w	#10,(v_coolbonus).w		; subtract 10 from cool bonus

	.no_coolbonus:
		endif

		if PerfectBonusEnabled
			tst.w	(v_perfectbonus).w		; is perfect bonus = zero?
			beq.s	.no_perfectbonus		; if yes, branch
			addi.w	#10,d0					; add 10 to score
			subi.w	#10,(v_perfectbonus).w	; subtract 10 from perfect bonus

	.no_perfectbonus:
		endif

		tst.w	d0							; is there any bonus?
		bne.s	.add_bonus					; if yes, branch
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
	endcase

		move.w	#sfx_Cash,d0
		jsr		(QueueSound2).w				; play "ker-ching" sound
		addq.b	#2,obRoutine(a0)			; goto Has_Wait next, and then Has_NextLevel
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w	; is current level SBZ2?
		bne.s	.not_sbz2					; if not, branch
		addq.b	#4,obRoutine(a0)			; if yes, goto Has_Wait next, and then Has_MoveBack for SBZ2

	.not_sbz2:
		move.w	#180,obTimeFrame(a0)		; set time delay to 3 seconds

	.exit:
		rts	
; ===========================================================================

	if SpeedUpScoreTally<>2
	.add_bonus:
		jsr		(AddPoints).l				; add d0 to score and update counter
		move.b	(v_vbla_byte).w,d0			; get byte that increments every frame
		andi.b	#3,d0						; read bits 0-1
		bne.s	.exit						; branch if either are set
		move.w	#sfx_Switch,d0
		jmp		(QueueSound2).w				; play "blip" sound
	endif
; ===========================================================================

Got_NextLevel:	; Routine $A
		move.b	(v_zone).w,d0
		andi.w	#7,d0
		lsl.w	#3,d0
		move.b	(v_act).w,d1
		andi.w	#3,d1
		add.w	d1,d1
		add.w	d1,d0						; combine zone/act numbers into single value
		move.w	LevelOrder(pc,d0.w),d0		; load level from level order array
		move.w	d0,(v_zone).w				; set level number
		tst.w	d0
		bne.s	.valid_level				; branch if not 0
		move.b	#id_Sega,(v_gamemode).w		; if no next level is set, return to the SEGA screen
		bra.w	DisplaySprite				; display sprite for one more frame before returning to SEGA
; ===========================================================================

	.valid_level:
	if CoolBonusEnabled
		move.b	#CoolBonusHits,(v_hitscount).w	; set hits count for next cool bonus
	endif

		clr.b	(v_lastlamp).w				; clear	lamppost counter
		tst.b	(f_bigring).w				; has Sonic jumped into	a giant	ring?
		beq.s	.restart					; if not, branch
		move.b	#id_Special,(v_gamemode).w	; set game mode to Special Stage (10)
		bra.w	DisplaySprite
; ===========================================================================

	.restart:
		move.b	#1,(f_restart).w			; restart level
		bra.w	DisplaySprite
; ===========================================================================

; ---------------------------------------------------------------------------
; Level	order array
; ---------------------------------------------------------------------------
LevelOrder:
	if OriginalLevelOrder
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

Got_MoveBack:	; Routine $E
		moveq	#$20,d1		; set horizontal speed
		move.w	obEoLCard_FinalX(a0),d0
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
		
	if AmbienceMode
		rts
	else
		move.w	#bgm_FZ,d0
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		jmp		(QueueSound1).w			; play FZ music
	endif
; ===========================================================================

Got_Boundary:	; Routine $10
		addq.w	#2,(v_limitright).w
		cmpi.w	#$2100,(v_limitright).w
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
	if ~~ExtraBonuses
	
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