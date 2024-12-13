; ---------------------------------------------------------------------------
; Object 0A - drowning countdown numbers and small bubbles that float out of
; Sonic's mouth (LZ)
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

drown_origX = objoff_30		; original x-axis position
drown_time = objoff_38		; time between each number changes

id_Drown_Main = ptr_Drown_Main-Drown_Index				; 0
id_Drown_Animate = ptr_Drown_Animate-Drown_Index		; 2
id_Drown_ChkWater = ptr_Drown_ChkWater-Drown_Index		; 4
id_Drown_Display = ptr_Drown_Display-Drown_Index		; 6
id_Drown_Delete = ptr_Drown_Delete-Drown_Index			; 8
id_Drown_Countdown = ptr_Drown_Countdown-Drown_Index	; $A
id_Drown_AirLeft = ptr_Drown_AirLeft-Drown_Index		; $C
; ===========================================================================

Drown_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bub,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Bubbles,0,1),obGfx(a0)
		move.b	#$84,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0			; get bubble type
		bpl.s	.smallbubble				; branch if $00-$7F

		addq.b	#8,obRoutine(a0)			; goto Drown_Countdown next
		move.l	#Map_Drown,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Sonic_Drowning,0,0),obGfx(a0)
		andi.w	#$7F,d0
		move.b	d0,objoff_33(a0)
		bra.w	Drown_Countdown
; ===========================================================================

.smallbubble:
		move.b	d0,obAnim(a0)
		move.w	obX(a0),drown_origX(a0)
		move.w	#-$88,obVelY(a0)

Drown_Animate:	; Routine 2
		lea		Ani_Drown(pc),a1
		jsr		(AnimateSprite).w

Drown_ChkWater:	; Routine 4
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; has bubble reached the water surface?
		blo.s	.wobble		; if not, branch

		move.b	#id_Drown_Display,obRoutine(a0)	; goto Drown_Display next
		addq.b	#7,obAnim(a0)
		cmpi.b	#$D,obAnim(a0)
		beq.s	Drown_Display
		blo.s	Drown_Display
		move.b	#$D,obAnim(a0)
		bra.s	Drown_Display
; ===========================================================================

.wobble:
		tst.b	(f_wtunnelmode).w	; is Sonic in a water tunnel?
		beq.s	.notunnel			; if not, branch
		addq.w	#4,drown_origX(a0)

.notunnel:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea		Drown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	drown_origX(a0),d0
		move.w	d0,obX(a0)
		bsr.s	Drown_ShowNumber
		jsr		(SpeedToPos_YOnly).l	; Horizontal movement is NOT applied by VelX
		tst.b	obRender(a0)
		bpl.s	.delete
		jmp		(DisplaySprite).l

.delete:
		jmp		(DeleteObject).l
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
		bhi.s	Drown_AirLeft_Delete				; if higher than $C, branch
		subq.w	#1,drown_time(a0)
		bne.s	.display
		move.b	#id_Drown_Display+8,obRoutine(a0)	; goto Drown_Display next
		addq.b	#7,obAnim(a0)
		bra.s	Drown_Display
; ===========================================================================

.display:
		lea		Ani_Drown(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obRender(a0)
		bpl.s	Drown_AirLeft_Delete
		jmp		(DisplaySprite).l

Drown_AirLeft_Delete:	
		jmp		(DeleteObject).l
; ===========================================================================

Drown_ShowNumber:
		tst.w	drown_time(a0)
		beq.s	.nonumber
		subq.w	#1,drown_time(a0)				; decrement timer
		bne.s	.nonumber						; if time remains, branch
		cmpi.b	#7,obAnim(a0)
		bhs.s	.nonumber

		move.w	#15,drown_time(a0)
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
		move.b	#id_Drown_AirLeft,obRoutine(a0)	; goto Drown_AirLeft next

.nonumber:
		rts	
; ===========================================================================
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
		tst.w	objoff_2C(a0)
		bne.w	.loc_13F86
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

		subq.w	#1,drown_time(a0)				; decrement timer
		bpl.w	.nochange						; branch if time remains
		move.w	#59,drown_time(a0)
		move.w	#1,objoff_36(a0)
		jsr		(RandomNumber).w
		andi.w	#1,d0
		move.b	d0,objoff_34(a0)
		move.b	(v_air).w,d0					; check air remaining
		cmpi.b	#25,d0
		beq.s	.warnsound						; play sound if	air is 25
		cmpi.b	#20,d0
		beq.s	.warnsound
		cmpi.b	#15,d0
		beq.s	.warnsound
		cmpi.b	#12,d0
		bhi.s	.reduceair						; if air is above 12, branch

		bne.s	.skipmusic						; if air is less than 12, branch
		move.b	#bgm_Drowning,d0
		jsr		(PlaySound).w					; play countdown music
		clr.b	(v_lastbgmplayed).w				; clear last played music

.skipmusic:
		subq.b	#1,objoff_32(a0)
		bpl.s	.reduceair
		move.b	objoff_33(a0),objoff_32(a0)
		bset	#7,objoff_36(a0)
		bra.s	.reduceair

.cantdrown:
		rts
; ===========================================================================

.warnsound:
		move.b	#sfx_Warning,d0
		jsr		(PlaySound_Special).w		; play "ding-ding" warning sound

.reduceair:
		subq.b	#1,(v_air).w			; subtract 1 from air remaining
		bcc.w	.makenum				; if air is above 0, branch

		; Sonic drowns here
		bsr.w	ResumeMusic
		move.b	#$81,obCtrlLock(a2)		; lock controls and disable object interaction
		move.b	#sfx_Drown,d0
		jsr		(PlaySound_Special).w	; play drowning sound
		move.b	#$A,objoff_34(a0)
		move.w	#1,objoff_36(a0)
		move.w	#$78,objoff_2C(a0)
		move.l	a0,-(sp)
		movea.l	a2,a0					; instruction changed due to S2 optimization
		bsr.w	Sonic_ResetOnFloor
		move.b	#aniID_Drown,obAnim(a0)	; use Sonic's drowning animation
		bset	#staAir,obStatus(a0)
		bset	#7,obGfx(a0)			; set high priority bit
		clr.w	obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.b	#$A,obRoutine(a0)		; Force the character to drown -- RHS Drowning Fix
		move.b	#1,(f_nobgscroll).w
		movea.l	(sp)+,a0				; restore a0 = obj0A
		rts	
; ===========================================================================
.loc_13F86:
	; RHS Drowning Fix
		subq.w	#1,objoff_2C(a0)
		bne.s	.nochange				; Make it jump straight to this location
		cmpi.b	#$A,obRoutine(a2)		; is Sonic drowning (won't be if Debug was used)
		bne.s	.noDeath
		move.b	#6,obRoutine(a2)		; kill Sonic
.noDeath:
		rts
	; Drowning Fix End
; ===========================================================================

.nochange:
		tst.w	objoff_36(a0)
		beq.w	.nocountdown
		subq.w	#1,objoff_3A(a0)
		bpl.w	.nocountdown

.makenum:
		jsr		(RandomNumber).w
		andi.w	#$F,d0
		move.w	d0,objoff_3A(a0)
		jsr		(FindFreeObj).l
		bne.w	.nocountdown
		_move.b	#id_DrownCount,obID(a1)		; load object
		move.w	obX(a2),obX(a1)	; match X position to Sonic
		moveq	#6,d0
		btst	#staFacing,obStatus(a2)
		beq.s	.noflip
		neg.w	d0
		move.b	#$40,obAngle(a1)

.noflip:
		add.w	d0,obX(a1)
		move.w	obY(a2),obY(a1)
		move.b	#6,obSubtype(a1)
		tst.w	objoff_2C(a0)
		beq.w	.loc_1403E
		andi.w	#7,objoff_3A(a0)
		addi.w	#0,objoff_3A(a0)
		move.w	obY(a2),d0
		subi.w	#$C,d0
		move.w	d0,obY(a1)
		jsr		(RandomNumber).w
		move.b	d0,obAngle(a1)
		move.w	(v_framecount).w,d0
		andi.b	#3,d0
		bne.s	.loc_14082
		move.b	#$E,obSubtype(a1)
		bra.s	.loc_14082
; ===========================================================================

.loc_1403E:
		btst	#7,objoff_36(a0)
		beq.s	.loc_14082
		move.b	(v_air).w,d2
		lsr.b	#1,d2
		jsr		(RandomNumber).w
		andi.w	#3,d0
		bne.s	.loc_1406A
		bset	#6,objoff_36(a0)
		bne.s	.loc_14082
		move.b	d2,obSubtype(a1)
		move.w	#$1C,drown_time(a1)

.loc_1406A:
		tst.b	objoff_34(a0)
		bne.s	.loc_14082
		bset	#6,objoff_36(a0)
		bne.s	.loc_14082
		move.b	d2,obSubtype(a1)
		move.w	#$1C,drown_time(a1)

.loc_14082:
		subq.b	#1,objoff_34(a0)
		bpl.s	.nocountdown
		clr.w	objoff_36(a0)

.nocountdown:
		rts	
