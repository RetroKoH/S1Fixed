; ---------------------------------------------------------------------------
; Object 0A - drowning countdown numbers and small bubbles that float out of
; Sonic's mouth (LZ)
;
; spawned by:
;	SonicPlayer - subtype $81
;	DrownCount - subtypes 6 (small), $E (medium), 0-5 (numbers)
; To-Do: (Does S1Squared change how these are spawned in)?
; ---------------------------------------------------------------------------

DrownCount:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Drown_Index(pc,d0.w),d1
		jmp		Drown_Index(pc,d1.w)
; ===========================================================================
Drown_Index:	offsetTable
ptr_Drown_Main:			offsetTableEntry.w Drown_Main
ptr_Drown_Animate:		offsetTableEntry.w Drown_Animate
ptr_Drown_ChkWater:		offsetTableEntry.w Drown_ChkWater
ptr_Drown_Display:		offsetTableEntry.w Drown_Display
ptr_Drown_Delete:		offsetTableEntry.w Drown_Delete
ptr_Drown_Countdown:	offsetTableEntry.w Drown_Countdown
ptr_Drown_AirLeft:		offsetTableEntry.w Drown_AirLeft
						offsetTableEntry.w Drown_Display
						offsetTableEntry.w Drown_Delete

id_Drown_Main = ptr_Drown_Main-Drown_Index				; 0
id_Drown_Animate = ptr_Drown_Animate-Drown_Index		; 2
id_Drown_ChkWater = ptr_Drown_ChkWater-Drown_Index		; 4
id_Drown_Display = ptr_Drown_Display-Drown_Index		; 6
id_Drown_Delete = ptr_Drown_Delete-Drown_Index			; 8
id_Drown_Countdown = ptr_Drown_Countdown-Drown_Index	; $A
id_Drown_AirLeft = ptr_Drown_AirLeft-Drown_Index		; $C
; ===========================================================================

Drown_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Drown_Animate
		move.l	#Map_Bub,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Bubbles,0,1),obGfx(a0)
		move.b	#$84,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0			; get bubble type (first bubble is $81)
		bpl.s	.smallbubble				; branch if $00-$7F

		addq.b	#8,obRoutine(a0)			; goto Drown_Countdown next
		move.l	#Map_Drown,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Sonic_Drowning,0,0),obGfx(a0)
		andi.w	#$7F,d0						; ignore high bit of type
		move.b	d0,obDrown_BubbleType(a0)	; type should be 1
		bra.w	Drown_Countdown
; ===========================================================================

.smallbubble:
		jsr		(NewAnim).w					; use animation from subtype (0-5 = nums; 6 = small bubble; $E = medium)
		move.w	obX(a0),obDrown_StartX(a0)
		move.w	#-$88,obVelY(a0)
; ---------------------------------------------------------------------------

Drown_Animate:	; Routine 2
		lea		Ani_Drown(pc),a1
		jsr		(AnimateSprite).w			; run animation and goto Drown_ChkWater next

Drown_ChkWater:	; Routine 4
		move.w	(v_waterpos_actual).w,d0
		cmp.w	obY(a0),d0					; has bubble reached the water surface?
		blo.s	.wobble						; if not, branch

		move.b	#id_Drown_Display,obRoutine(a0)	; -> Drown_Display
		addq.b	#7,obAnim(a0)
		bclr	#7,obAnim(a0)				; clear restart flag
		cmpi.b	#$D,obAnim(a0)				; blank animation?
		beq.s	Drown_Display				; if yes, branch
		blt.s	Drown_Display
		moveq	#$D,d0						; if higher than the last animation, hard-set it to blank
		jsr		(NewAnim).w
		bra.s	Drown_Display
; ===========================================================================

	.wobble:
		tst.b	(f_wtunnelmode).w			; is Sonic in a water tunnel?
		beq.s	.notunnel					; if not, branch
		addq.w	#4,obDrown_StartX(a0)

	.notunnel:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea		Drown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0				; get byte from wobble data array based on angle value
		ext.w	d0
		add.w	obDrown_StartX(a0),d0
		move.w	d0,obX(a0)					; update position
		bsr.s	Drown_ShowNumber
		jsr		(SpeedToPos_YOnly).l		; horizontal movement is NOT applied by obVelX
		tst.b	obRender(a0)				; is object on-screen?
		bpl.s	Drown_Delete				; if not, branch
		jmp		(DisplaySprite).l
; ===========================================================================

Drown_Display:	; Routine 6, Routine $E
		bsr.s	Drown_ShowNumber
		lea		Ani_Drown(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

Drown_Delete:	; Routine 8, Routine $10
		jmp		(DeleteObject).l
; ===========================================================================

Drown_AirLeft:	; Routine $C
		cmpi.b	#$C,(v_air).w						; check air remaining
		bhi.s	.delete								; if higher than $C, branch
		subq.w	#1,obDrown_NumberTime(a0)
		bne.s	.display
		move.b	#id_Drown_Display+8,obRoutine(a0)	; goto Drown_Display next
		addq.b	#7,obAnim(a0)						; use flashing number animation
		bclr	#7,obAnim(a0)				; clear restart flag
		bra.s	Drown_Display
; ===========================================================================

	.display:
		lea		Ani_Drown(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obRender(a0)
		bpl.s	.delete
		jmp		(DisplaySprite).l

	.delete:	
		jmp		(DeleteObject).l
; ===========================================================================

Drown_ShowNumber:
		tst.w	obDrown_NumberTime(a0)
		beq.s	.nonumber
		subq.w	#1,obDrown_NumberTime(a0)	; decrement timer
		bne.s	.nonumber					; if time remains, branch
		moveq	#$7F,d0
		and.b	obAnim(a0),d0
		cmpi.b	#7,d0
		bhs.s	.nonumber

		move.w	#15,obDrown_NumberTime(a0)
		clr.w	obVelY(a0)
		move.b	#$80,obRender(a0)
		move.w	obX(a0),d0
		sub.w	(v_screenposx).w,d0
		addi.w	#$80,d0
		move.w	d0,obX(a0)
		move.w	obY(a0),d0
		sub.w	(v_screenposy).w,d0
		addi.w	#$80,d0
		move.w	d0,obScreenY(a0)
		move.b	#id_Drown_AirLeft,obRoutine(a0)	; -> Drown_AirLeft

	.nonumber:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Data for a bubble's side-to-side wobble (also used by REV01's underwater
; background ripple effect)
; ---------------------------------------------------------------------------

Drown_WobbleData:
		dc.b 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3
		dc.b -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3
		dc.b -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1
		dc.b 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3
		dc.b -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4
		dc.b -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3
		dc.b -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1
; ===========================================================================

Drown_Countdown:; Routine $A
		lea		(v_player).w,a2					; S2 Optimization (RetroKoH)

	; If Sonic has drowned, and the object is waiting until the
	; world should pause, then go deal with that.
		tst.w	obDrown_RestartTime(a0)			; has Sonic drowned?
		bne.w	.kill_sonic						; if yes, branch
		tst.b	(v_debuguse).w					; is debug mode active?
		bne.s	.cantdrown						; if yes, branch
		cmpi.b	#6,obRoutine(a2)				; is Sonic dead?
		bhs.s	.cantdrown						; if yes, branch

	if ShieldsMode	; RetroKoH S3K Elemental Shields
		btst	#sta2ndBShield,obStatus2nd(a2)	; does the player have the Bubble Shield?
		bne.s   .cantdrown
	endif

		btst	#staWater,obStatus(a2)			; is Sonic underwater?
		beq.s	.cantdrown						; if not, branch

		subq.w	#1,obDrown_NumberTime(a0)		; decrement timer between countdown number changes
		bpl.w	.create_bubble					; branch if time remains
		move.w	#59,obDrown_NumberTime(a0)		; set timer to 1 second
		move.w	#1,obDrown_ExtraFlag(a0)
		jsr		(RandomNumber).w
		andi.w	#1,d0							; random number 0 or 1
		move.b	d0,obDrown_ExtraBubbles(a0)
		move.b	(v_air).w,d0					; check air remaining
		cmpi.b	#25,d0
		beq.s	.warnsound						; play sound if	air is 25
		cmpi.b	#20,d0
		beq.s	.warnsound						; play sound if	air is 20
		cmpi.b	#15,d0
		beq.s	.warnsound						; play sound if	air is 15
		cmpi.b	#12,d0
		bhi.s	.reduceair						; if air is above 12, branch

	if ~~AmbienceMode
		bne.s	.skipmusic						; if air is less than 12, branch

		move.b	#bgm_Drowning,d0
		jsr		(QueueSound1).w					; play countdown music
		clr.b	(v_lastbgmplayed).w				; clear last played music
	endif

	.skipmusic:
		subq.b	#1,obDrown_DisplayTime(a0)		; decrement display timer
		bpl.s	.reduceair						; branch if time remains
		move.b	obDrown_BubbleType(a0),obDrown_DisplayTime(a0)	; reset timer (1)
		bset	#7,obDrown_ExtraFlag(a0)
		bra.s	.reduceair

	.cantdrown:
		rts
; ===========================================================================

	.warnsound:
		move.b	#sfx_Warning,d0
		jsr		(QueueSound2).w					; play "ding-ding" warning sound

	.reduceair:
		subq.b	#1,(v_air).w					; subtract 1 from air remaining
		bcc.w	.makenum						; if air is above 0, branch

		; Sonic drowns here
		bsr.w	ResumeMusic
		move.b	#$81,obCtrlLock(a2)				; lock controls and disable object interaction
		move.b	#sfx_Drown,d0
		jsr		(QueueSound2).w					; play drowning sound
		move.b	#$A,obDrown_ExtraBubbles(a0)
		move.w	#1,obDrown_ExtraFlag(a0)
		move.w	#$78,obDrown_RestartTime(a0)	; restart after 2 seconds
		move.l	a0,-(sp)
		movea.l	a2,a0							; instruction changed due to S2 optimization
		bsr.w	Sonic_ResetOnFloor
		move.b	#aniID_Drown,obAnim(a0)			; use Sonic's drowning animation
		bset	#staAir,obStatus(a0)
		bset	#gfxPriority,obGfx(a0)			; set high priority bit
		moveq	#0,d0
		move.l	d0,obVelX(a0)					; stop all movement (obVelX and obVelY)
		move.w	d0,obInertia(a0)
		move.b	#$A,obRoutine(a0)				; Force the character to drown -- RHS Drowning Fix
		move.b	#1,(f_nobgscroll).w
		movea.l	(sp)+,a0						; restore a0 = obj0A
		rts	
; ===========================================================================
	.kill_sonic:
	; RHS Drowning Fix
		subq.w	#1,obDrown_RestartTime(a0)		; decrement delay timer after drowning
		bne.s	.create_bubble					; branch if time remains
		cmpi.b	#$A,obRoutine(a2)				; is Sonic drowning (won't be if Debug was used)
		bne.s	.noDeath						; if not, branch
		move.b	#6,obRoutine(a2)				; kill Sonic

	.noDeath:
		rts
	; Drowning Fix End
; ===========================================================================

	.create_bubble:
		tst.w	obDrown_ExtraFlag(a0)			; should bubbles/numbers be spawned?
		beq.w	.nocountdown					; if not, branch
		subq.w	#1,obDrown_DelayTime(a0)		; decrement timer between bubble spawning
		bpl.w	.nocountdown					; branch if time remains

	.makenum:
		jsr		(RandomNumber).w
		andi.w	#$F,d0
		move.w	d0,obDrown_DelayTime(a0)		; set timer as random 0-15 frames
		jsr		(FindFreeObj).l
		bne.w	.nocountdown					; branch if object slot not found
		_move.b	#id_DrownCount,obID(a1)			; load object
		move.w	obX(a2),obX(a1)					; match X position to Sonic
		moveq	#6,d0							; 6 pixels to right
		btst	#staFacing,obStatus(a2)			; is Sonic facing left?
		beq.s	.noflip							; if not, branch
		neg.w	d0								; 6 pixels to left
		move.b	#$40,obAngle(a1)

	.noflip:
		add.w	d0,obX(a1)						; adjust X position to in front of Sonic's face
		move.w	obY(a2),obY(a1)
		move.b	#6,obSubtype(a1)				; object is small bubble (6)
		tst.w	obDrown_RestartTime(a0)			; has Sonic drowned?
		beq.w	.not_dead						; if not, branch
		andi.w	#7,obDrown_DelayTime(a0)		; cut time between bubbles to 7 frames or less
		move.w	obY(a2),d0						; match Y position to Sonic
		subi.w	#$C,d0							; 12 pixels up
		move.w	d0,obY(a1)						; adjust Y position to in front of Sonic's face
		jsr		(RandomNumber).w
		move.b	d0,obAngle(a1)
		move.w	(v_framecount).w,d0
		andi.b	#3,d0
		bne.s	.loc_14082
		move.b	#$E,obSubtype(a1)				; object is medium bubble ($E)
		bra.s	.loc_14082
; ===========================================================================

	.not_dead:
		btst	#7,obDrown_ExtraFlag(a0)
		beq.s	.loc_14082
		move.b	(v_air).w,d2					; get air remaining
		lsr.b	#1,d2							; divide by 2
		jsr		(RandomNumber).w
		andi.w	#3,d0
		bne.s	.loc_1406A
		bset	#6,obDrown_ExtraFlag(a0)
		bne.s	.loc_14082
		move.b	d2,obSubtype(a1)				; object is a number (0-5)
		move.w	#$1C,obDrown_NumberTime(a1)

	.loc_1406A:
		tst.b	obDrown_ExtraBubbles(a0)
		bne.s	.loc_14082
		bset	#6,obDrown_ExtraFlag(a0)
		bne.s	.loc_14082
		move.b	d2,obSubtype(a1)
		move.w	#$1C,obDrown_NumberTime(a1)

	.loc_14082:
		subq.b	#1,obDrown_ExtraBubbles(a0)
		bpl.s	.nocountdown
		clr.w	obDrown_ExtraFlag(a0)

	.nocountdown:
		rts	
; ===========================================================================