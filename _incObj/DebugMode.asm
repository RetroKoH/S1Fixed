; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:
	; LavaGaming Object Routine Optimization
		tst.b	(v_debuguse).w
		bne.w	Debug_Action
	; Object Routine Optimization End

Debug_Main:	; Routine 0
		addq.b	#2,(v_debuguse).w
		clr.b	(v_sonicbubbles+objoff_2C).w
		jsr		(ResumeMusic).l						; cancel countdown music
		move.w	(v_limittop2).w,(v_limittopdb).w	; buffer level x-boundary
		move.w	(v_limitbtm1).w,(v_limitbtmdb).w	; buffer level y-boundary
		clr.w	(v_limittop2).w
		move.w	#$720,(v_limitbtm1).w
		andi.w	#$7FF,(v_player+obY).w
		andi.w	#$7FF,(v_screenposy).w
		andi.w	#$3FF,(v_bgscreenposy).w
		clr.b	obFrame(a0)
		move.b	#aniID_Walk,obAnim(a0)

	; Mercury Debug Improvements
		clr.w	obVelX(a0)
		clr.w	obVelY(a0)
		clr.w	obInertia(a0)
	if SpinDashEnabled	
		clr.b	obSpinDashFlag(a0)			; clear spindash flag
	endif	
		btst	#staOnObj,obStatus(a0)		; is Sonic standing on an object?
		beq.s	.setpos						; if not, branch
		bclr	#staOnObj,obStatus(a0)		; clear Sonic's standing flag
		moveq	#0,d0
	; RetroKoH obPlatform SST mod
		movea.w	obPlatformAddr(a0),a2		; get object's SST address
		adda.l	#v_ram_start,a2				; a2 = object
		clr.w	obPlatformAddr(a0)			; clear object's SST address
	; obPlatform SST mod end
		bclr	#staSonicOnObj,obStatus(a2)	; clear object's standing flag -- Removed obSolid

.setpos:
	; Debug Improvements end

		cmpi.b	#id_Special,(v_gamemode).w	; is game mode $10 (special stage)?
		bne.s	.islevel					; if not, branch

		clr.w	(v_ssrotate).w				; stop special stage rotating
		clr.w	(v_ssangle).w				; make special stage "upright"
		moveq	#6,d0						; use 6th debug	item list
		bra.s	.selectlist
; ===========================================================================

.islevel:
		moveq	#0,d0
		move.b	(v_zone).w,d0

.selectlist:
		lea		(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		cmp.b	(v_debugitem).w,d6			; have you gone past the last item?
		bhi.s	.noreset					; if not, branch
		clr.b	(v_debugitem).w				; back to start of list

.noreset:
		bsr.w	Debug_ShowItem
		move.b	#12,(v_debugxspeed).w
		move.b	#1,(v_debugyspeed).w

Debug_Action:	; Routine 2
		moveq	#6,d0
		cmpi.b	#id_Special,(v_gamemode).w
		beq.s	.isntlevel

		moveq	#0,d0
		move.b	(v_zone).w,d0

.isntlevel:
		lea		(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		bsr.w	Debug_Control
		jmp		(DisplaySprite).l

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_Control:
		moveq	#0,d4
		move.w	#1,d1
		move.b	(v_jpadpress1).w,d4
		andi.w	#btnDir,d4	; is up/down/left/right	pressed?
		bne.s	.dirpressed	; if yes, branch

		move.b	(v_jpadhold1).w,d0
		andi.w	#btnDir,d0	; is up/down/left/right	held?
		bne.s	.dirheld	; if yes, branch

		move.b	#12,(v_debugxspeed).w
		move.b	#15,(v_debugyspeed).w
		bra.w	Debug_ChgItem
; ===========================================================================

.dirheld:
		subq.b	#1,(v_debugxspeed).w
		bne.s	loc_1D01C
		move.b	#1,(v_debugxspeed).w
		addq.b	#1,(v_debugyspeed).w
		bne.s	.dirpressed
		move.b	#-1,(v_debugyspeed).w

.dirpressed:
		move.b	(v_jpadhold1).w,d4

loc_1D01C:
		moveq	#0,d1
		move.b	(v_debugyspeed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		btst	#bitUp,d4	; is up	being pressed?
		beq.s	loc_1D03C	; if not, branch
		sub.l	d1,d2
		bcc.s	loc_1D03C
		moveq	#0,d2

loc_1D03C:
		btst	#bitDn,d4	; is down being	pressed?
		beq.s	loc_1D052	; if not, branch
		add.l	d1,d2
		cmpi.l	#$7FF0000,d2
		blo.s	loc_1D052
		move.l	#$7FF0000,d2

loc_1D052:
		btst	#bitL,d4
		beq.s	loc_1D05E
		sub.l	d1,d3
		bcc.s	loc_1D05E
		moveq	#0,d3

loc_1D05E:
		btst	#bitR,d4
		beq.s	loc_1D066
		add.l	d1,d3

loc_1D066:
		move.l	d2,obY(a0)
		move.l	d3,obX(a0)

Debug_ChgItem:
		btst	#bitA,(v_jpadhold1).w	; is button A pressed?
		beq.s	.createitem				; if not, branch
		btst	#bitC,(v_jpadpress1).w	; is button C pressed?
		beq.s	.nextitem				; if not, branch
		subq.b	#1,(v_debugitem).w		; go back 1 item
		bcc.s	.display
		add.b	d6,(v_debugitem).w
		bra.s	.display
; ===========================================================================

.nextitem:
		btst	#bitA,(v_jpadpress1).w	; is button A pressed?
		beq.s	.createitem				; if not, branch
		addq.b	#1,(v_debugitem).w		; go forwards 1 item
		cmp.b	(v_debugitem).w,d6
		bhi.s	.display
		clr.b	(v_debugitem).w			; loop back to first item

.display:
		bra.w	Debug_ShowItem
; ===========================================================================

.createitem:
		btst	#bitC,(v_jpadpress1).w		; is button C pressed?
		beq.s	.backtonormal				; if not, branch
		jsr		(FindFreeObj).l
		bne.s	.backtonormal
		clr.b	(v_objstate+2).w			; Mercury Debug Improvements -- Allows us to place more rings/boxes, etc.
		; The above line causes an issue with certain in-level objects. Check S3K code to fix this.
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		_move.b	obMap(a0),obID(a1)			; create object
		move.b	obRender(a0),obRender(a1)
		move.b	obRender(a0),obStatus(a1)
		andi.b	#$7F,obStatus(a1)			; ensure bit #7 is clear
		moveq	#0,d0
		move.b	(v_debugitem).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0.w),obSubtype(a1)
		rts	
; ===========================================================================

.stayindebug:
		rts

.backtonormal:
	; RetroKoH Debug Mode Fix
		btst	#bitB,(v_jpadpress1).w				; is button B pressed?
		beq.s	.stayindebug						; if not, branch
		clr.w	(v_debuguse).w						; deactivate debug mode
		jsr		(Reset_Sonic_Position_Array).l
		lea		(v_player).w,a1
		cmpi.b	#id_Special,(v_gamemode).w			; are you in the special stage?
		beq.w	.special							; if yes, branch

		move.l	#Map_Sonic,obMap(a1)
		move.w	#ArtTile_Sonic,obGfx(a1)			; Also resets high priority bit in case of drowning
		move.b	#aniID_Walk,obAnim(a1)
		clr.w	obX+2(a1)
		clr.w	obY+2(a1)
		clr.b	obCtrlLock(a1)						; unlock player in case of drowning
		clr.w	obVelX(a1)
		clr.w	obVelY(a1)
		clr.w	obInertia(a1)
		move.b	#maskAir,obStatus(a1)				; set Sonic into the air. all other bits clear.
		move.b	#2,obRoutine(a1)
		move.b	#$13,obHeight(a1)
		move.b	#9,obWidth(a1)

	if SuperMod=1
		btst	#sta2ndSuper,obStatus2nd(a1)		; is player in Super Form?
		beq.s	.notSuper							; if not, branch
		bset	#sta2ndInvinc,obStatus2nd(a1)		; set invincibility again (in case we spawn after death)
.notSuper:
	endif
		bsr.w	Debug_RestartMusic					; fix music bug w/ invincibility

		lea     (v_sonspeedmax).w,a2				; Load Sonic_top_speed into a2
		jsr		(ApplySpeedSettings).l				; Fetch Speed settings
		move.w	(v_limittopdb).w,(v_limittop2).w	; restore level boundaries
		move.w	(v_limitbtmdb).w,(v_limitbtm1).w

; HUD resets
		jsr		(Hud_Base).l						; reload basic HUD gfx	-- RetroKoH Debug Mode Improvement
		move.b	#1,(f_ringcount).w					; update ring counter
		move.b	#1,(f_scorecount).w					; update score counter
		jmp		(HUD_Update.updatetime).l			; directly update timer

.special
		clr.w	(v_ssangle).w
	if S4SpecialStages=0
		move.w	#$40,(v_ssrotate).w					; set new stage rotation speed
	else
		move.w	#$100,(v_ssrotate).w				; set new stage rotation speed
	endif
		move.l	#Map_Sonic,obMap(a1)
		move.w	#ArtTile_Sonic,obGfx(a1)
		move.b	#aniID_Roll,obAnim(a1)
		move.b	#maskAir+maskSpin,obStatus(a1)		; Set spin and in air bits. all other bits clear.

	if HUDInSpecialStage=1
		jsr		(Hud_Base_SS).l						; reload basic HUD gfx	-- RetroKoH Debug Mode Improvement
		move.b	#1,(f_ringcount).w					; update ring counter
		move.b	#1,(f_scorecount).w					; update score counter
		jmp		(HUD_Update_SS.updatetime).l		; directly update timer
	else
		rts
	endif
; End of function Debug_Control


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_ShowItem:
		moveq	#0,d0
		move.b	(v_debugitem).w,d0
		lsl.w	#3,d0
		move.l	(a2,d0.w),obMap(a0)		; load mappings for item
		move.w	6(a2,d0.w),obGfx(a0)	; load VRAM setting for item
		move.b	5(a2,d0.w),obFrame(a0)	; load frame number for item
		rts	
; End of function Debug_ShowItem


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_RestartMusic:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w	; check if level is SBZ3
		bne.s	.music
		move.w	#bgm_SBZ,d0					; play SBZ music

.music:
		lea		(MusicList2).l,a1
		move.b	(a1,d0.w),d0

; checks
	if SuperMod=1
		btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is player in Super Form?
		bne.s	.playinvinc								; if yes, branch
	endif

		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; is Sonic invincible?
		beq.s	.notinvinc								; if not, branch

.playinvinc:
		move.w	#bgm_Invincible,d0

.notinvinc:
		tst.b	(f_lockscreen).w			; is Sonic at a boss?
		beq.s	.playselected				; if not, branch
		move.w	#bgm_Boss,d0

.playselected:
		cmp.b	(v_lastbgmplayed).w,d0		; was this music already playing?
		beq.s	.dontrestart
		move.b	d0,(v_lastbgmplayed).w		; store last played music
		jmp		(PlaySound).w				; restart last played music

.dontrestart:
		rts
; End of function Debug_RestartMusic