; ---------------------------------------------------------------------------
; Object - special stage results screen
; ---------------------------------------------------------------------------

SSResult:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SSR_Index(pc,d0.w),d1
		jmp		SSR_Index(pc,d1.w)
; ===========================================================================

SSR_Index:	offsetTable
		offsetTableEntry.w SSR_Main
		offsetTableEntry.w SSR_Move
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_RingBonus
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_Exit
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_Continue
		offsetTableEntry.w SSR_Wait
		offsetTableEntry.w SSR_Exit
		offsetTableEntry.w SSR_ContAni
; ===========================================================================

SSR_Main:	; Routine 0
		tst.l	(v_plc_buffer).w			; are the pattern load cues empty?
		beq.s	.plc_free					; if yes, branch
		rts	
; ===========================================================================

	.plc_free:
		movea.l	a0,a1						; replace current object with 1st from list
		lea		(SSR_Config).l,a2			; position, routine & frame settings
		moveq	#3+(1*PerfectBonusEnabled),d1	; 3 (or 4) additional items

	if SpecialStagesWithAllEmeralds	; Mercury Special Stages Still Appear With All Emeralds
		btst	#7,(v_continues).w
		beq.s	.loop						; if no, branch
	else
		cmpi.w	#50,(v_rings).w				; do you have 50 or more rings?
		blo.s	.loop						; if no, branch
	endif	; Special Stages Still Appear With All Emeralds	End

		addq.w	#1,d1						; if yes, add 1	to d1 (number of sprites)

	.loop:
		_move.l	#SSResult,obAddr(a1)
		move.w	(a2)+,obX(a1)				; load start x-position
		move.w	(a2)+,obSSR_DisplayX(a1)	; load main x-position
		move.w	(a2)+,obScreenY(a1)			; load y-position
		move.b	(a2)+,obRoutine(a1)			; -> SSR_Move
		move.b	(a2)+,obFrame(a1)			; set frame number
		move.l	#Map_SSR,obMap(a1)
		move.w	#make_art_tile(ArtTile_Title_Card,0,1),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		lea		object_size(a1),a1
		dbf		d1,.loop					; repeat sequence 3 or 4 times

		moveq	#7,d0
		move.b	(v_emeralds).w,d1
		beq.s	.skip_emeralds				; branch if you have no chaos emeralds
		moveq	#0,d0						; use "CHAOS EMERALDS" text
		cmpi.b	#emldCount,d1				; do you have all chaos	emeralds?
		bne.s	.skip_emeralds				; if not, branch
		moveq	#8,d0						; use "SONIC GOT THEM ALL" text
		move.w	#$18,obX(a0)
		move.w	#$118,obSSR_DisplayX(a0) 	; change position of text

	.skip_emeralds:
		move.b	d0,obFrame(a0)				; set frame for 1st object
; ---------------------------------------------------------------------------

SSR_Move:	; Routine 2
		moveq	#$10,d1						; set horizontal speed
		move.w	obSSR_DisplayX(a0),d0
		cmp.w	obX(a0),d0					; has item reached its target position?
		beq.s	.at_target					; if yes, branch
		bge.s	.is_left					; branch if object is left of target position
		neg.w	d1							; move left instead

	.is_left:
		add.w	d1,obX(a0)					; change item's position

	.chk_visible:
		move.w	obX(a0),d0
		bmi.s	.exit						; branch if object is at negative x pos
		cmpi.w	#$200,d0					; has item moved beyond	$200 on	x-axis?
		bhs.s	.exit						; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

	.exit:
		rts	
; ===========================================================================

	.at_target:
		cmpi.b	#2,obFrame(a0)				; is object the ring bonus?
		bne.s	.chk_visible				; if not, branch

		addq.b	#2,obRoutine(a0)			; goto SSR_Wait next, and then SSR_RingBonus
		move.w	#180,obSSR_Timer(a0)		; set time delay to 3 seconds
		_move.l	#SSRChaos,(v_ssresemeralds+obAddr).w	; load chaos emerald object

SSR_Wait:	; Routine 4, 8, $C, $10
		subq.w	#1,obSSR_Timer(a0)			; decrement timer
		bne.w	DisplaySprite				; branch if time remains
		addq.b	#2,obRoutine(a0)			; goto SSR_RingBonus/SSR_Exit/SSR_Continue next
		bra.w	DisplaySprite
; ===========================================================================

SSR_RingBonus:	; Routine 6

	switch SpeedUpScoreTally
	case 2
; ---------------------------------------------------------------------------
; INSTANT SCORE TALLY
; ---------------------------------------------------------------------------
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w		; set time/ring bonus update flag
		moveq	#0,d0
		move.w	(v_ringbonus).w,d0			; load ring bonus to d0
		clr.w	(v_ringbonus).w				; clear ring bonus
	
		if PerfectBonusEnabled
			add.w	(v_perfectbonus).w,d0		; add perfect bonus to d0
			clr.w	(v_perfectbonus).w			; clear perfect bonus
		endif

		jsr		(AddPoints).l				; add to score
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
	case 1
; ---------------------------------------------------------------------------
; FASTER SCORE TALLY
; ---------------------------------------------------------------------------
		bsr.w	DisplaySprite
		moveq	#10,d1						; set score decrement to 10
		move.b	(v_jpadheld_actual).w,d0
		andi.b	#btnABC,d0					; is A, B or C pressed?
		beq.w	.dontspeedup				; if not, branch
		move.b	#100,d1						; increase score decrement to 100
		
	.dontspeedup:
		move.b	#1,(f_endactbonus).w		; set bonus update flag
		moveq	#0,d0
		tst.w	(v_ringbonus).w				; is ring bonus	= zero?
		beq.s	.no_ringbonus				; if yes, branch
		cmp.w	(v_ringbonus).w,d1			; compare ring bonus to score decrement
		blt.s	.skip_rings					; if it's greater or equal, branch
		move.w	(v_ringbonus).w,d1			; else, set the decrement to the remaining bonus

	.skip_rings:
		add.w	d1,d0						; add decrement to score
		sub.w	d1,(v_ringbonus).w			; subtract decrement from ring bonus

	.no_ringbonus:
		if PerfectBonusEnabled
			tst.w	(v_perfectbonus).w		; is perfect bonus = zero?
			beq.s	.no_perfectbonus		; if yes, branch (We must use a temp label to ensure potential mods are branched to)
			cmp.w	(v_perfectbonus).w,d1	; compare perfect bonus to score decrement
			blt.s	.skip_perfect			; if it's greater or equal, branch
			move.w	(v_perfectbonus).w,d1	; else, set the decrement to the remaining bonus

	.skip_perfect:
			add.w	d1,d0					; add decrement to score
			sub.w	d1,(v_perfectbonus).w	; subtract decrement from perfect bonus

	.no_perfectbonus:
		endif

		tst.w	d0							; is there any bonus?
		beq.s	.finish_bonus				; if not, branch

	.add_bonus:
		jsr		(AddPoints).l				; add d0 to score and update counter			
		moveq	#3,d0
		and.b	(v_vbla_byte).w,d0			; read bits 0-1 of VBla byte -- SCE Optimization
		bne.s	.exit

		move.w	#sfx_Switch,d0
		jmp		(QueueSound2).w				; play "blip" sound
; ===========================================================================

	.finish_bonus:
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
	elsecase
; ---------------------------------------------------------------------------
; NORMAL SCORE TALLY
; ---------------------------------------------------------------------------
		bsr.w	DisplaySprite
		move.b	#1,(f_endactbonus).w		; set ring bonus update flag
		moveq	#0,d0
		tst.w	(v_ringbonus).w				; is ring bonus	= zero?
		beq.s	.no_ringbonus				; if yes, branch
		addi.w	#10,d0						; add 10 to score
		subi.w	#10,(v_ringbonus).w			; subtract 10 from ring bonus

	.no_ringbonus:
		if PerfectBonusEnabled
			tst.w	(v_perfectbonus).w		; is perfect bonus = zero?
			beq.s	.no_perfectbonus		; if yes, branch
			addi.w	#10,d0					; add 10 to score
			subi.w	#10,(v_perfectbonus).w	; subtract 10 from perfect bonus

	.no_perfectbonus:
		endif

		tst.w	d0							; is there any bonus?
		beq.s	.finish_bonus				; if not, branch

	.add_bonus:
		jsr		(AddPoints).l				; add d0 to score and update counter			
		moveq	#3,d0
		and.b	(v_vbla_byte).w,d0			; read bits 0-1 of VBla byte -- SCE Optimization
		bne.s	.exit

		move.w	#sfx_Switch,d0
		jmp		(QueueSound2).w				; play "blip" sound
; ===========================================================================

	.finish_bonus:
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
	endcase

		move.w	#sfx_Cash,d0
		jsr		(QueueSound2).w				; play "ker-ching" sound
		addq.b	#2,obRoutine(a0)
		move.w	#180,obSSR_Timer(a0)		; set time delay to 3 seconds
		cmpi.w	#50,(v_rings).w				; do you have at least 50 rings?
		blo.s	.exit						; if not, branch
		move.w	#60,obSSR_Timer(a0)			; set time delay to 1 second
		addq.b	#4,obRoutine(a0)			; goto "SSR_Continue" routine

	.exit:
		rts	
; ===========================================================================

SSR_Exit:	; Routine $A, $12
		move.b	#1,(f_restart).w			; set level restart flag
		bra.w	DisplaySprite
; ===========================================================================

SSR_Continue:	; Routine $E
		move.b	#4,(v_ssrescontinue+obFrame).w	; make mini-Sonic sprite appear
		move.b	#$14,(v_ssrescontinue+obRoutine).w	; "CONTINUE" object goto SSR_ContAni next
		move.w	#sfx_Continue,d0
		jsr	(QueueSound2).w					; play continues jingle
		addq.b	#2,obRoutine(a0)			; goto SSR_Wait next, and then SSR_Exit
		move.w	#360,obSSR_Timer(a0)		; set time delay to 6 seconds
		bra.w	DisplaySprite
; ===========================================================================

SSR_ContAni:	; Routine $14
		moveq	#$F,d0						; SCE Optimization
		and.b	(v_vbla_byte).w,d0			; get bits 0-3 of byte that increments every frame
		bne.w	DisplaySprite				; branch if any bits are set
		bchg	#0,obFrame(a0)				; Sonic moves his foot every 16th frame
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
; ===========================================================================

; ---------------------------------------------------------------------------
; X-axis positions for chaos emeralds
; ---------------------------------------------------------------------------

	if ~~SuperMod
SSRC_PosData:
	; 6 emeralds
		dc.w $110	; blue
		dc.w $128	; yellow
		dc.w $F8	; pink
		dc.w $140	; green
		dc.w $E0	; red
		dc.w $158	; gray
	else
SSRC_PosData:
	; 7 emeralds
		dc.w $120	; blue
		dc.w $138	; yellow
		dc.w $108	; pink
		dc.w $150	; green
		dc.w $F0	; red
		dc.w $168	; gray
		dc.w $D8	; cyan
	endif
; ===========================================================================

; ---------------------------------------------------------------------------
; Object - chaos emeralds from the special stage results screen
; ---------------------------------------------------------------------------

SSRChaos:
		movea.l	a0,a1						; replace current object with 1st emerald
		lea		SSRC_PosData(pc),a2
		moveq	#0,d1
		moveq	#0,d2
		move.b	(v_emeralds).w,d1			; d1 is number of emeralds
		subq.b	#1,d1						; subtract 1 from d1
		bcs.w	DeleteObject				; if you have 0	emeralds, branch
		lea		(v_emldlist).w,a3			; a3 = bitfield that tells which emeralds we do/don't have (loading to a3 instead of dx saves 4 cycles)

	.loop:
		btst	d2,(a3)						; did you get the emerald? (Using a bitfield saves 8 cycles here)
		beq.s   .noemerald					; if not, skip and check for the next emerald

		_move.l	#SSRChaos,obAddr(a1)
		move.w	(a2)+,obX(a1)				; set x-position
		move.w	#$F0,obScreenY(a1)			; set y-position
		move.b	d2,obFrame(a1)				; get list of individual emeralds (numbered 0 to 5/6)
		move.b	d2,obAnim(a1)				; read value of current emerald
		_move.l	#SSRC_Flash,obAddr(a1)
		move.l	#Map_SSRC,obMap(a1)
		move.w	#make_art_tile(ArtTile_SS_Results_Emeralds,0,1),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		lea		object_size(a1),a1			; next object
		addq.b  #1,d2						; check for the next emerald
		dbf		d1,.loop					; loop for d1 number of	emeralds

		bra.s	SSRC_Flash
; ===========================================================================

	.noemerald:
		addq.b	#1,d2						; check for the next emerald
		addq.b  #1,d1						; +1 to the loop, to continue checking for the rest of the emeralds
		dbf		d1,.loop					; loop for d1 number of	emeralds
; ---------------------------------------------------------------------------

SSRC_Flash:
		move.b	obFrame(a0),d0				; get previous frame
		move.b	#emldCount,obFrame(a0)		; load 6th/7th frame (blank)
		cmpi.b	#emldCount,d0				; was previous frame blank?
		bne.w	DisplaySprite				; if not, branch
		move.b	obAnim(a0),obFrame(a0)		; load visible frame
		bra.w	DisplaySprite
; ===========================================================================