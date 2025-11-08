; ---------------------------------------------------------------------------
; Object 01 - Sonic
;
; spawned by:
;	GM_Level, GM_Ending, VanishSonic
;
; 9 OST bytes free
; $14, $15, $27, $2B-2E, $33, $34 
; ---------------------------------------------------------------------------

SonicPlayer:
		tst.w	(v_debuguse).w				; is debug mode	being used?
		beq.s	Sonic_Normal				; if not, branch
		jmp		(DebugMode).l
; ===========================================================================

Sonic_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sonic_Index(pc,d0.w),d1
		jsr		Sonic_Index(pc,d1.w)
		clr.w	(v_col_response_list).w		; reset collsion response list
		rts
; ===========================================================================
Sonic_Index:	offsetTable
		offsetTableEntry.w	Sonic_Main
		offsetTableEntry.w	Sonic_Control
		offsetTableEntry.w	Sonic_Hurt
		offsetTableEntry.w	Sonic_Death
		offsetTableEntry.w	Sonic_ResetLevel
		offsetTableEntry.w	Sonic_Drowned	; RHS Drowning Fix
; ===========================================================================

Sonic_Main:	; Routine 0
		move.w	#$0C0D,(v_top_solid_bit).w		; MJ: set top/lrb collision to 1st
		addq.b	#2,obRoutine(a0)
		move.w	#$1309,obHeight(a0)				; Height and Width
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.w	#priority2,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		lea     (v_sonspeedmax).w,a2			; load Sonic's top speed into a2
		bsr.w   ApplySpeedSettings				; fetch Speed settings

	if (SpinDashEnabled|SkidDustEnabled)
		move.b	#id_Effects,(v_playerdust).w	; load object for dust effects
	endif

Sonic_Control:	; Routine 2

	if CDCamera
		bsr.w	Sonic_PanCamera					; handle CD Camera panning
	endif

	if WallJumpEnabled	; Mercury Wall Jump
		tst.b	obWallJump(a0)					; is Sonic latched to a wall for a Wall Jump?
		beq		.nodec							; if not, branch
		subq.b	#1,obWallJump(a0)				; decrement latch time
		bne.s	.chkLR							; if time remains, branch
		bra.s	.nowalljump						; if not, jump to cancelling wall jump

	.chkLR:
		move.b	(v_jpadheld_dup).w,d0			; get jpad input
		and.b	obWallJump+1(a0),d0				; is Sonic still holding the required directional input?
		bne.s	.skip							; if yes, branch

	.nowalljump:
		clr.w	obWallJump(a0)					; clear wall latch flag and saved directional input state
		move.b	#aniID_Roll,obAnim(a0) 			; switch to rolling animation

		if ReusableDropDash		; fall from wall into drop dash (toggle)
			move.b	#$FF,obJumping(a0)				; set jumping flag for proper control (Drop Dash but not Wall re-latch)
			cmpi.b	#$15,obDoubleJumpProp(a0)		; did Sonic have a Drop Dash revved before the wall jump attempt?
			blt.s	.nodropdash						; if not, branch
			move.b	#aniID_DropDash,obAnim(a0)		; switch to drop dash animation
			move.w	#sfx_DropDash,d0
			jsr		(QueueSound2).w					; play charge sound

		.nodropdash:
		endif		; fall from wall into drop dash end
		
		if WallDustEnabled	; Mercury Wall Jump Smoke Puff
			bra.s	.nodec						; skip dust generation

		.skip:
			move.b	(v_framebyte).w,d0
			andi.b	#7,d0
			bne.s	.nodec

			bsr.w	FindFreeObj
			bne.s	.nodec
			move.b	#id_Effects,obID(a1)		; create puff
			move.w	obX(a0),obX(a1)
			move.w	obY(a0),obY(a1)
			addi.w	#$A,obX(a1)

			btst	#staFacing,obStatus(a0)		; is Sonic facing left?
			beq.s	.notleft					; if not, branch
			subi.w	#$14,obX(a1)				; adjust positioning

		.notleft:
			addi.w	#$11,obY(a1)
			clr.b	obStatus(a1)
			move.b	#2,obAnim(a1)
			addq.b	#2,obRoutine(a1)
			move.l	#Map_Effects,obMap(a1)
			ori.b	#4,obRender(a1)
			move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
			move.b	#4,obActWid(a1)
			move.w	#ArtTile_Dust,obGfx(a1)
		else

		.skip:

		endif	; Wall Jump Smoke Puff end
		
	.nodec:
	endif	; Wall Jump end

		tst.w	(f_debugmode).w					; is debug cheat enabled?
		beq.s	.no_debug						; if not, branch
		btst	#bitB,(v_jpadpressed_actual).w	; is button B pressed?
		beq.s	.no_debug						; if not, branch
		move.w	#1,(v_debuguse).w				; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

	.no_debug:
		tst.b	(f_lockctrl).w					; are controls locked?
		bne.s	.locked							; if yes, branch
		move.w	(v_jpadheld_actual).w,(v_jpadheld_dup).w	; enable joypad control

	.locked:
		btst	#0,obCtrlLock(a0)				; are controls and position locked?
		bne.s	.player_locked					; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#maskAir+maskSpin,d0			; player's air and spin states determine Control Mode
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr		Sonic_Modes(pc,d1.w)			; handle player control, physics, etc.

	.player_locked:
		bsr		Sonic_Display					; display sprite, update invincibility/speed shoes

	if SuperMod
		bsr.s	Sonic_Super						; handle Super Sonic logic
	endif

		bsr.w	Sonic_RecordPosition			; save position for invincibility stars
		bsr.w	Sonic_Water						; underwater physics, splashing, drowning
		move.w	(v_anglebuffer_right).w,obFrontAngle(a0)	; move both angle buffers to Sonic's OSTs
		tst.b	(f_wtunnelmode).w				; is Sonic in a water/air tunnel?
		beq.s	.animate						; if not, branch
		cmpi.b	#aniID_Walk,obAnim(a0)			; changed instruction because Walk is no longer #0
		bne.s	.animate						; if not, branch
		move.b	obPrevAni(a0),obAnim(a0)		; update animation

	.animate:
		bsr.w	Sonic_Animate					; handle Sonic's animations
		tst.b	obCtrlLock(a0)					; is object collision disabled?
		bmi.w	Sonic_LoadGfx					; if yes, branch
		jsr		(ReactToItem).l					; run collisions with other objects
	; removed old loop/tunnel handlers
		bra.w	Sonic_LoadGfx					; load new gfx when Sonic's frame changes
; ===========================================================================

Sonic_Modes:	offsetTable
		offsetTableEntry.w 	Sonic_MdNormal
		offsetTableEntry.w 	Sonic_MdAir
		offsetTableEntry.w 	Sonic_MdRoll
		offsetTableEntry.w 	Sonic_MdJump
; ===========================================================================

	if SuperMod
; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Sonic
; ---------------------------------------------------------------------------

Sonic_Super:				; XREF: Obj01_MdNormal
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic in his Super form?
		beq.s	.return							; if not, branch and exit
		tst.b	(f_timecount).w					; is HUD timer active?
		beq.s	Sonic_RevertToNormal			; if not, branch and revert to normal
		subq.b	#1,(v_supersonic_frame).w		; decrement frame timer
		bhi.s	.return							; changed from bpl to bhi to ensure once every 60 frames, not 61 (MoDule)

	; Only run the below code once every second.
		move.b	#60,(v_supersonic_frame).w		; reset frame counter to 60
		tst.w	(v_rings).w						; does Sonic have rings?
		beq.s	Sonic_RevertToNormal			; if not, branch and revert to normal
		ori.b	#1,(f_ringcount).w				; update the rings counter
		move.w	(v_rings).w,d0
		cmpi.w	#1,d0							; does Sonic have only 1 ring left?
		beq.s	.reset_counter					; if yes, branch
		cmpi.w	#10,d0							; does Sonic have exactly 10 rings left?
		beq.s	.reset_counter					; if yes, branch
		cmpi.w	#100,d0							; does Sonic have exactly 100 rings left?
		bne.s	.subtractring					; if not, branch

	.reset_counter:
		ori.b	#$80,(f_ringcount).w			; update + reset the rings counter

	.subtractring:
		subq.w	#1,(v_rings).w					; decrement ring count by 1
		beq.s	Sonic_RevertToNormal			; if no rings remain, branch and revert to normal

	.return:
		rts
; ===========================================================================

Sonic_RevertToNormal:
		move.b	#2,(f_super_palette).w			; Remove rotating palette
		move.w	#$28,(v_palette_frame).w
		bclr	#sta2ndSuper,obStatus2nd(a0)	; remove Super status
		move.b	#aniID_Run,obPrevAni(a0)		; change animation back to normal
		clr.b	obInvinc(a0)					; remove invincibility
		move.l	#Map_Sonic,obMap(a0)			; load Sonic's normal mappings
		lea     (v_sonspeedmax).w,a2			; load Sonic's top speed into a2
		bra.w   ApplySpeedSettings				; fetch Speed settings
; ===========================================================================
	endif

; ---------------------------------------------------------------------------
; Subroutine to display Sonic, update powerups, and set music
; ---------------------------------------------------------------------------

Sonic_Display:
	; Check hurt frames (now byte-length: RetroKoH Sonic SST Compaction)
		move.b	obInvuln(a0),d0					; is Sonic flashing (likely due to being hurt)
		beq.s	.display						; if not, branch
		subq.b	#1,obInvuln(a0)					; decrement timer
		lsr.w	#3,d0							; are any of bits 0-2 set?
		bcc.s	.chkinvincible					; if not, branch (Sonic is invisible every 8th frame)

	.display:
		jsr		(DisplaySprite).l

	.chkinvincible:
	; Check for 8th frame (invinc/Shoes are now byte-length: RetroKoH Sonic SST Compaction)
		move.b	(v_framebyte).w,d1				; RetroKoH Sonic_Display Optimization
		andi.b	#7,d1							; if d1 == 0, we will decrement shoes/invinc on this frame
		bne.w	.exit							; if not, we will skip this logic on this frame

		btst	#sta2ndInvinc,obStatus2nd(a0)	; does Sonic have invincibility?
		beq.s	.chkshoes						; if not, branch

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic Super?
		bne.s	.chkshoes						; if yes, don't check to remove invincibility
	endif

		tst.b	obInvinc(a0)					; check	time remaining for invinciblity -- RetroKoH Sonic SST Compaction
		beq.s	.chkremoveinvinc				; if we have the powerup but no time remains, remove the powerup (RetroKoH Bugfix)
		
		subq.b	#1,obInvinc(a0)					; subtract 1 from time every 8 frames
		bne.s	.chkshoes						; if time still remains, branch

	.chkremoveinvinc:

	if ~~AmbienceMode
		tst.b	(f_lockscreen).w
		bne.s	.removeinvincible
		cmpi.b	#$C,(v_air).w
		blo.s	.removeinvincible

		if DynamicBGMs
	; -----------------------------------------------------------------------
			moveq	#0,d0
			move.b	(v_zone).w,d0
			add.b	d0,d0
			add.b	d0,d0							; multiply by 4
			add.b	(v_act).w,d0					; add the act value
			lea		(MusicList).l,a1
			move.b	(a1,d0.w),d0
			cmp.b	(v_lastbgmplayed).w,d0
			beq.s	.removeinvincible
			jsr		(QueueSound1).w					; play normal music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	; -----------------------------------------------------------------------
		else
	; -----------------------------------------------------------------------
			moveq	#0,d0
			move.b	(v_zone).w,d0
			cmpi.w	#(id_LZ<<8)+3,(v_zone).w		; check if level is SBZ3
			bne.s	.notSBZ3
			move.b	#id_SBZ,d0						; play SBZ music instead

		.notSBZ3:
			cmpi.w	#(id_SBZ<<8)+2,(v_zone).w		; check if level is FZ
			bne.s	.music
			move.b	#6,d0							; play FZ music instead

		.music:
			lea		(MusicList).l,a1
			move.b	(a1,d0.w),d0
			cmp.b	(v_lastbgmplayed).w,d0
			beq.s	.removeinvincible
			jsr		(QueueSound1).w					; play normal music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	; ------------------------------------------------------------------------
		endif
	endif

	.removeinvincible:
		bclr	#sta2ndInvinc,obStatus2nd(a0)	; cancel invincibility
		
	if InvincBuffer
		move.b	#$3C,obInvuln(a0)				; set invulnerability briefly after stars expire
	endif

	.chkshoes:
		btst	#sta2ndShoes,obStatus2nd(a0)	; does Sonic have speed	shoes?
		beq.s	.exit							; if not, branch
		tst.b	obShoes(a0)						; check	time remaining for speed shoes -- RetroKoH Sonic SST Compaction
		beq.s	.exit							; if we have the powerup but no time remains, remove the powerup (RetroKoH Bugfix)
		
		subq.b	#1,obShoes(a0)					; subtract 1 from time every 8 frames
		bne.s	.exit							; if time still remains, branch

	.removeshoes:
		lea     (v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings				; Fetch Speed settings
		bclr	#sta2ndShoes,obStatus2nd(a0)	; cancel speed shoes

	if ~~AmbienceMode
		move.w	#bgm_Slowdown,d0
		jmp		(QueueSound3).w					; run music at normal speed
	endif

	.exit:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	record Sonic's previous positions for invincibility stars
; ---------------------------------------------------------------------------

Sonic_RecordPosition:
		move.w	(v_trackpos).w,d0		; position tracker index
		lea		(v_tracksonic).w,a1		; address to record data to
		lea		(a1,d0.w),a1			; jump to current index
		move.w	obX(a0),(a1)+			; save Sonic's x position
		move.w	obY(a0),(a1)+			; save Sonic's y position
		addq.b	#4,(v_trackbyte).w		; next index (wraps to 0 after $FC)
		rts	
; End of function Sonic_RecordPosition
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

Sonic_Water:
		cmpi.b	#id_LZ,(v_zone).w					; is level LZ?
		beq.s	.islabyrinth						; if yes, branch

	.exit:
		rts	
; ===========================================================================

	.islabyrinth:
		move.w	(v_waterpos_actual).w,d0
		cmp.w	obY(a0),d0							; is Sonic above the water?
		bge.s	.abovewater							; if yes, branch
		bset	#staWater,obStatus(a0)				; set underwater status flag
		bne.s	.exit								; branch if this was already set

		bsr.w	ResumeMusic
		move.b	#id_DrownCount,(v_sonicbubbles).w	; load bubbles object from Sonic's mouth
		move.b	#$81,(v_sonicbubbles+obSubtype).w
		lea     (v_sonspeedmax).w,a2				; load Sonic's top speed into a2
		bsr.w   ApplySpeedSettings					; fetch speed settings
		asr		obVelX(a0)
		asr		obVelY(a0)
		asr		obVelY(a0)							; slow Sonic
		beq.s	.exit								; branch if Sonic stops moving
		move.b	#id_Splash,(v_splash).w				; load splash object
		move.w	#sfx_Splash,d0
		jmp		(QueueSound2).w						; play splash sound
; ===========================================================================

	.abovewater:
		bclr	#staWater,obStatus(a0)				; clear underwater status flag
		beq.s	.exit								; branch if this was already clear

		bsr.w	ResumeMusic
		lea     (v_sonspeedmax).w,a2				; load Sonic's top speed into a2
		bsr.w   ApplySpeedSettings					; fetch speed settings
		asl		obVelY(a0)
		beq.w	.exit								; if we aren't moving vertically, branch
		move.b	#id_Splash,(v_splash).w				; load splash object
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	.belowmaxspeed
		move.w	#-$1000,obVelY(a0)					; set maximum speed on leaving water

	.belowmaxspeed:
		move.w	#sfx_Splash,d0
		jmp		(QueueSound2).w						; play splash sound
; End of function Sonic_Water
; ===========================================================================

; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Sonic_MdNormal:
	; Neither in air or rolling
	if PeeloutEnabled
		bsr.w	Sonic_ChkPeelout
	endif
	
	if SpinDashEnabled
		bsr.w	Sonic_ChkSpinDash
	endif

		bsr.w	Sonic_Jump
		bsr.w	Sonic_SlopeResist
		bsr.w	Sonic_Move
		bsr.w	Sonic_Roll
		bsr.w	Sonic_LevelBound
		jsr		(SpeedToPos).l
		bsr.w	Sonic_AnglePos
		bra.w	Sonic_SlopeRepel
; ===========================================================================

Sonic_MdAir:
	; in the air, not in a ball (thus, not jumping)
	if AirRollEnabled
		bsr.w	Sonic_ChkAirRoll
	else
		cmpi.w	#-$FC0,obVelY(a0)		; is Sonic moving up really fast?
		bge.s	.no_cap					; if not, return
		move.w	#-$FC0,obVelY(a0)		; cap upward speed

	.no_cap:
	endif

		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr		(ObjectFall).l

	if WallJumpEnabled
		tst.b	obWallJump(a0)
		beq.s	.nowalljump
		subi.w	#$30,obVelY(a0)
		bra.s	.notunderwater
		
	.nowalljump:
	endif

		btst	#staWater,obStatus(a0)	; is Sonic underwater?
		beq.s	.notunderwater			; if not, branch
		subi.w	#$28,obVelY(a0)			; apply upward force

	.notunderwater:
		bra.w	Sonic_AirCollision		; (JumpAngle fallthrough to JumpCollision)
; ===========================================================================

Sonic_MdRoll:
	; in a ball, not in the air
		tst.b	obAutoRollFlag(a0)		; is Sonic being forced to roll?
		bne.s	.no_jumps				; if yes, branch and don't allow jumping
		bsr.w	Sonic_Jump

	.no_jumps:
		bsr.w	Sonic_RollRepel
		bsr.w	Sonic_RollSpeed
		bsr.w	Sonic_LevelBound
		jsr		(SpeedToPos).l
		bsr.w	Sonic_AnglePos
		bra.w	Sonic_SlopeRepel
; ===========================================================================

Sonic_MdJump:
	; in the air, in a ball (jumping or falling mid-roll)
		bsr.w	Sonic_JumpHeight
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr		(ObjectFall).l

	if WallJumpEnabled
		tst.b	obWallJump(a0)
		beq.s	.nowalljump
		subi.w	#$30,obVelY(a0)
		bra.s	.notunderwater
		
	.nowalljump:
	endif

		btst	#staWater,obStatus(a0)	; is Sonic underwater?
		beq.s	.notunderwater			; if not, branch
		subi.w	#$28,obVelY(a0)			; apply upward force

	.notunderwater:
		bra.w	Sonic_JumpCollision
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

Sonic_Move:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_slidemode).w				; is d-pad control disabled?
		bne.w	Sonic_Traction				; if yes, branch
		tst.b	obLRLock(a0)				; are controls locked?
		bne.w	Sonic_ResetScr				; if yes, branch
		btst	#bitL,(v_jpadheld_dup).w	; is left being pressed?
		beq.s	.notleft					; if not, branch
		bsr.w	Sonic_MoveLeft

	.notleft:
		btst	#bitR,(v_jpadheld_dup).w	; is right being pressed?
		beq.s	.notright					; if not, branch
		bsr.w	Sonic_MoveRight

	.notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0					; is Sonic on a	slope?
		bne.w	Sonic_ResetScr			; if yes, branch
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.w	Sonic_ResetScr			; if yes, branch
		bclr	#staPush,obStatus(a0)	; clear push status
		move.b	#aniID_Wait,obAnim(a0)	; use "standing" animation
		btst	#staOnObj,obStatus(a0)	; is Sonic on a platform/object?
		beq.s	Sonic_Balance			; if not, branch
		movea.w	obPlatformAddr(a0),a1	; a1 = object being stood upon (RetroKoH obPlatform SST mod)
		tst.b	obStatus(a1)			; has object been broken?
		bmi.w	Sonic_LookUp			; if yes, branch

		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2					; d2 = width of platform -4
		add.w	obX(a0),d1
		sub.w	obX(a1),d1				; d1 = Sonic's position - object's position + half object's width

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.w	SuperSonic_Balance
	endif

		cmpi.w	#4,d1					; is Sonic within 4px of left edge?

	if CDBalancing
		blt.s	Sonic_BalanceLeft		; if yes, branch
		cmp.w	d2,d1					; is Sonic within 4px of right edge?
		bge.s	Sonic_BalanceRight		; if yes, branch
		bra.w	Sonic_LookUp
; ===========================================================================

	if SuperMod
SuperSonic_Balance:
		cmpi.w	#4,d1
		blt.w	SuperSonic_BalanceOnObjLeft
		cmp.w	d2,d1
		bge.w	SuperSonic_BalanceOnObjRight
		bra.w	Sonic_LookUp
; ===========================================================================
	endif

Sonic_Balance:
		jsr		(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.w	SuperSonic_Balance2
	endif

		cmpi.b	#3,obFrontAngle(a0)
		beq.s	Sonic_BalanceRight
		cmpi.b	#3,obRearAngle(a0)
		bne.s	Sonic_LookUp

Sonic_BalanceLeft:
		btst	#staFacing,obStatus(a0)			; is Sonic facing left?	;Mercury Constants
		beq.s	Sonic_BalanceBackward			; if not, balance backward
		move.b	#aniID_Balance2,obAnim(a0)		; use forward balancing animation
		bra.w	Sonic_ResetScr					; branch

Sonic_BalanceRight:
		btst	#staFacing,obStatus(a0)			; is Sonic facing left?	;Mercury Constants
		bne.s	Sonic_BalanceBackward			; if so, balance backward
		move.b	#aniID_Balance2,obAnim(a0)		; use forward balancing animation
		bra.w	Sonic_ResetScr					; branch

Sonic_BalanceBackward:
		move.b	#aniID_Balance3,obAnim(a0)		; use backward balancing animation
		bra.w	Sonic_ResetScr

	else

		blt.s	Sonic_BalanceOnObjLeft
		cmp.w	d2,d1
		bge.s	Sonic_BalanceOnObjRight
		bra.s	Sonic_LookUp
; ===========================================================================

	if SuperMod
SuperSonic_Balance:
		cmpi.w	#4,d1
		blt.w	SuperSonic_BalanceOnObjLeft
		cmp.w	d2,d1
		bge.w	SuperSonic_BalanceOnObjRight
		bra		Sonic_LookUp
; ===========================================================================
	endif

Sonic_Balance:
		jsr		(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp					; branch if drop is not found

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.w	SuperSonic_Balance2
	endif

;Sonic_BalanceRight:
		cmpi.b	#3,obFrontAngle(a0)				; check for edge to the right
		bne.s	Sonic_BalanceLeft				; branch if not found

Sonic_BalanceOnObjRight: ;loc_12F5A
		bclr	#staFacing,obStatus(a0)
		bra.s	Sonic_BalanceSetAnim
; ===========================================================================

Sonic_BalanceLeft:
		cmpi.b	#3,obRearAngle(a0)				; check for edge to the left
		bne.s	Sonic_LookUp					; branch if not found

Sonic_BalanceOnObjLeft: ;loc_12F6A
		bset	#staFacing,obStatus(a0)

Sonic_BalanceSetAnim:
		move.b	#aniID_Balance,obAnim(a0)		; use "balancing" animation
		bra.w	Sonic_ResetScr
; ===========================================================================
	endif

	if SuperMod
SuperSonic_Balance2:
		cmpi.b	#3,obFrontAngle(a0)
		bne.s	SuperSonic_BalanceChkRear

SuperSonic_BalanceOnObjRight:
		bclr	#staFacing,obStatus(a0)
		bra		SuperSonic_BalanceSetAnim
; ===========================================================================
SuperSonic_BalanceChkRear:
		cmpi.b	#3,obRearAngle(a0)
		bne.s	Sonic_LookUp

SuperSonic_BalanceOnObjLeft:
		bset	#staFacing,obStatus(a0)

SuperSonic_BalanceSetAnim:
		move.b	#aniID_Balance,obAnim(a0)
		bra		Sonic_ResetScr
; ===========================================================================
	endif

Sonic_LookUp:
		btst	#bitUp,(v_jpadheld_dup).w		; is up being pressed?
		beq.s	Sonic_Duck						; if not, branch
		move.b	#aniID_LookUp,obAnim(a0)		; use "looking up" animation

	if (SpinDashEnabled|ScrollDelay)		; S2 Scroll Delay (Automatically on when Spin Dash is enabled)
		addq.b	#1,(v_scrolldelay).w				; add 1 to the scroll timer
		cmpi.b	#ScrollDelayTime,(v_scrolldelay).w	; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset						; if not, skip ahead without looking up
		move.b	#ScrollDelayTime,(v_scrolldelay).w	; move the scroll delay value into the scroll timer so it won't continue to count higher
	endif	; S2 Scroll Delay end

		; Mercury Look Shift Fix
		move.w	(v_screenposy).w,d0				; get camera top coordinate
		sub.w	(v_limittop).w,d0				; subtract zone's top bound from it
		add.w	(v_lookshift).w,d0				; add default offset
		cmpi.w	#$C8,d0							; is offset <= $C8?
		ble.s	.skip							; if so, branch
		move.w	#$C8,d0							; set offset to $C8
		
	.skip:
		cmp.w	(v_lookshift).w,d0
		ble.s	Sonic_UpdateSpeedOnGround
		; Look Shift Fix end
		addq.w	#2,(v_lookshift).w				; scroll up 2px
		bra.s	Sonic_UpdateSpeedOnGround
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_jpadheld_dup).w		; is down being pressed?
		beq.s	Sonic_ResetScr					; if not, branch
		move.b	#aniID_Duck,obAnim(a0)			; use "ducking" animation

	if (SpinDashEnabled|ScrollDelay)		; S2 Scroll Delay (Automatically on when Spin Dash is enabled)
		addq.b	#1,(v_scrolldelay).w				; add 1 to the scroll timer
		cmpi.b	#ScrollDelayTime,(v_scrolldelay).w	; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset						; if not, skip ahead without looking down
		move.b	#ScrollDelayTime,(v_scrolldelay).w	; move the scroll delay value into the scroll timer so it won't continue to count higher
	endif	; S2 Scroll Delay end

		; Mercury Look Shift Fix
		move.w	(v_screenposy).w,d0				; get camera top coordinate
		sub.w	(v_limitbtm).w,d0				; subtract zone's bottom bound from it (creating a negative number)
		add.w	(v_lookshift).w,d0				; add default offset
		cmpi.w	#8,d0							; is offset > 8?
		bgt.s	.skip							; if greater than 8, branch
		move.w	#8,d0							; set offset to 8

	.skip:
		cmp.w	(v_lookshift).w,d0
		bge.s	Sonic_UpdateSpeedOnGround
		; Look Shift Fix End
		subq.w	#2,(v_lookshift).w				; scroll up 2px
		bra.s	Sonic_UpdateSpeedOnGround
; ===========================================================================

Sonic_ResetScr:
	if (SpinDashEnabled|ScrollDelay)		; S2 Scroll Delay (Automatically on when Spin Dash is enabled)
		clr.b	(v_scrolldelay).w			; clear the scroll timer, because up/down are not being held

Sonic_LookReset:	; added branch point that the new scroll delay code skips ahead to
	endif	; S2 Scroll Delay end

		cmpi.w	#$60,(v_lookshift).w		; is screen in its default position?
		beq.s	Sonic_UpdateSpeedOnGround	; if yes, branch
		bcc.s	.screen_high				; branch if screen is higher
		addq.w	#4,(v_lookshift).w			; move screen back to default

	.screen_high:
		subq.w	#2,(v_lookshift).w			; move screen back to default

Sonic_UpdateSpeedOnGround: ;loc_12FC2:
; No need to update Super Sonic's d5 value here due to ApplySpeedSettings.
		move.b	(v_jpadheld_dup).w,d0
		andi.b	#btnL+btnR,d0				; is left/right	pressed?
		bne.s	Sonic_Traction				; if yes, branch
		move.w	obInertia(a0),d0			; get Sonic's inertia
		beq.s	Sonic_Traction				; if 0, branch
		bmi.s	.settle_left				; if negative, branch
		sub.w	d5,d0						; slow down when facing right and not pressing a direction
		bcc.s	.settle
		clr.w	d0
		bra.s	.settle
; ===========================================================================

	.settle_left:
		add.w	d5,d0						; slow down when facing left and not pressing a direction
		bcc.s	.settle
		clr.w	d0

	.settle:
		move.w	d0,obInertia(a0)			; update inertia

; increase or decrease speed on the ground
Sonic_Traction:
		tst.b	obAutoRollFlag(a0) 	
		bne.s	Sonic_StopAtWall
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

; stops Sonic from running through walls that meet the ground
Sonic_StopAtWall:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0				; d3 = angle with clockwise 90-degree rotation
		bmi.s	.exit				; branch if angle was $40-$BF (upper semicircle of angles)
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	.exit				; branch if inertia is 0
		bmi.s	.negative			; branch if negative
		neg.w	d1

	.negative:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	.exit
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.wall_below			; branch if wall is below
		cmpi.b	#$40,d0
		beq.s	.wall_left
		cmpi.b	#$80,d0
		beq.s	.wall_above

	.wall_right:
		add.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

	.wall_above:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

	.wall_left:
		sub.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

	.wall_below:
		add.w	d1,obVelY(a0)

	.exit:
		rts	
; End of function Sonic_Move
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk to the left
; ---------------------------------------------------------------------------

Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	.inertia_zero				; branch if inertia is 0
		bpl.s	.inertia_positive			; branch if inertia is positive

	.inertia_zero:
		bset	#staFacing,obStatus(a0)		; make Sonic face left
		bne.s	.already_left				; branch if already facing left
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obPrevAni(a0)	; restart Sonic's animation

	.already_left:
		sub.w	d5,d0						; d0 = inertia minus acceleration
		move.w	d6,d1						; d1 = top speed
		neg.w	d1							; negate for left direction
		cmp.w	d1,d0						; is Sonic is moving below max speed?
		bgt.s	.below_max					; if yes, branch

	if ~~GroundSpeedCapEnabled ; Mercury Disable Ground Speed Cap
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	.below_max
	endif	; Disable Ground Speed Cap End

		move.w	d1,d0						; limit movement speed

	.below_max:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0)		; use walking animation
		rts	
; ===========================================================================

	.inertia_positive:
		sub.w	d4,d0						; d0 = inertia minus deceleration
		bcc.s	.still_positive				; branch if inertia is still positive
		move.w	#-$80,d0

	.still_positive:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	.exit						; branch if Sonic is running on a wall or ceiling
		cmpi.w	#$400,d0
		blt.s	.exit
		move.b	#aniID_Stop,obAnim(a0)		; use "stopping" animation
		bclr	#staFacing,obStatus(a0)		; make Sonic face right
		move.w	#sfx_Skid,d0
		jsr		(QueueSound2).w				; play stopping sound

	if SkidDustEnabled
		cmpi.b	#$C,(v_air)
		bcs.s	.exit						; if he's drowning, branch to not make dust
		move.b	#6,(v_playerdust+obRoutine).w
	endif

	.exit:
		rts	
; End of function Sonic_MoveLeft
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk to the right
; ---------------------------------------------------------------------------

Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	.inertia_negative			; branch if inertia is negative
		bclr	#staFacing,obStatus(a0)		; make Sonic face right
		beq.s	.already_right				; branch if already facing right
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obPrevAni(a0)	; restart Sonic's animation

	.already_right:
		add.w	d5,d0						; d0 = inertia plus acceleration
		cmp.w	d6,d0						; is Sonic is moving below max speed?
		blt.s	.below_max					; if yes, branch

	if ~~GroundSpeedCapEnabled ; Mercury Disable Ground Speed Cap
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	.below_max
	endif	;end Disable Ground Speed Cap

		move.w	d6,d0						; limit movement speed

	.below_max:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0)		; use walking animation
		rts	
; ===========================================================================

	.inertia_negative:
		add.w	d4,d0						; d0 = inertia minus deceleration
		bcc.s	.still_negative				; branch if inertia is still positive
		move.w	#$80,d0

	.still_negative:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	.exit						; branch if Sonic is running on a wall or ceiling
		cmpi.w	#-$400,d0
		bgt.s	.exit
		move.b	#aniID_Stop,obAnim(a0)		; use "stopping" animation
		bset	#staFacing,obStatus(a0)		; make Sonic face left
		move.w	#sfx_Skid,d0
		jsr		(QueueSound2).w				; play stopping sound

	if SkidDustEnabled
		cmpi.b	#$C,(v_air)
		bcs.s	.exit						; if he's drowning, branch to not make dust
		move.b	#6,(v_playerdust+obRoutine).w
	endif

	.exit:
		rts	
; End of function Sonic_MoveRight
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

Sonic_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6

	; MoDule Super Sonic Roll Speed fix
		moveq	#6,d5								; natural roll deceleration = 1/2 normal acceleration
		btst    #staWater,obStatus(a0)				; Is the character underwater?
		beq.s   .nowater							; If not, branch
		moveq	#3,d5
;		move.w	(v_sonspeedacc).w,d5
;		asr.w	#1,d5
	; This will also make roll decel the same when using speed shoes
	; if you have another character with different acceleration, adjust accordingly
	; I'll consider changing ApplySpeedSettings to add a value for roll deceleration

.nowater:
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4								; controlled roll deceleration
		tst.b	(f_slidemode).w						; are controls except jump locked?
		bne.w	.reset_screen					; if yes, branch
		tst.b	obLRLock(a0)						; are controls temporarily locked?
		bne.s	.apply_roll_speed					; if yes, branch

		btst	#bitL,(v_jpadheld_dup).w			; is left being pressed?
		beq.s	.notleft							; if not, branch
		bsr.w	Sonic_RollLeft

	.notleft:
		btst	#bitR,(v_jpadheld_dup).w			; is right being pressed?
		beq.s	.apply_roll_speed					; if not, branch
		bsr.w	Sonic_RollRight

	.apply_roll_speed:
		move.w	obInertia(a0),d0
		beq.s	.chk_rollstop						; branch if inertia == 0
		bmi.s	.rollspeed_left						; branch if inertia is negative

; .rollspeed_right:
		sub.w	d5,d0								; d0 = inertia minus acceleration
		bcc.s	.setinertia							; branch if inertia is still positive
		moveq	#0,d0
		bra.s	.setinertia
; ===========================================================================

	.rollspeed_left:
		add.w	d5,d0								; d0 = inertia plus acceleration
		bcc.s	.setinertia							; branch if inertia is still negative
		moveq	#0,d0

	.setinertia:
		move.w	d0,obInertia(a0)					; update inertia

	.chk_rollstop:
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.s	.reset_screen			; if yes, branch
		tst.b	obAutoRollFlag(a0)		; NOTE: the spindash flag has a different meaning when Sonic's already rolling -- it's used to mean he's not allowed to stop rolling
		bne.s	.forced_roll			; branch if forced rolling
		bclr	#staSpin,obStatus(a0)
		move.w	#$1309,obHeight(a0)		; Height and Width
		move.b	#aniID_Wait,obAnim(a0)	; use "standing" animation
		subq.w	#5,obY(a0)
		bra.s	.reset_screen
; ===========================================================================
; gives Sonic an extra push if he's going to stop rolling where it's not allowed
; (such as in an S-tunnel in GHZ)
	.forced_roll:
		move.w	#$400,obInertia(a0)
		btst	#staFacing,obStatus(a0)
		beq.s	.reset_screen
		neg.w	obInertia(a0)

	; Mercury Screen Scroll While Rolling Fix
	.reset_screen:
		cmpi.w	#$60,(v_lookshift).w		; is the screen in its default position?
		beq.s	.screen_ok					; if yes, branch
		bcc.s	.screen_high				; branch if higher
		addq.w	#4,(v_lookshift).w

	.screen_high:
		subq.w	#2,(v_lookshift).w

	.screen_ok:
	; Screen Scroll While Rolling Fix End

		move.b	obAngle(a0),d0
		jsr		(CalcSine).w

	; Devon Rolling speed cap fix
		move.w  obInertia(a0),d2
		muls.w  d2,d0
		asr.l   #8,d0
	if RollSpeedCapEnabled ; RetroKoH Disable Rolling Speed Cap
		cmpi.w  #$1000,d0
		ble.s   .checkNegY
		move.w  #$1000,d0

	.checkNegY:
		cmpi.w  #-$1000,d0
		bge.s   .setVelocityY
		move.w  #-$1000,d0
	endif ; Disable Rolling Speed Cap end

	.setVelocityY:
		move.w  d0,obVelY(a0)			; store velocity Y
		
		muls.w  d2,d1
		asr.l   #8,d1
	
	if RollSpeedCapEnabled ; RetroKoH Disable Rolling Speed Cap
		cmpi.w  #$1000,d1
		ble.s   .checkNegX
		move.w  #$1000,d1

	.checkNegX:
		cmpi.w  #-$1000,d1
		bge.s   .setVelocityX
		move.w  #-$1000,d1
	endif

	.setVelocityX:
		move.w  d1,obVelX(a0)
	; Devon Rolling speed cap fix End

		bra.w	Sonic_StopAtWall
; End of function Sonic_RollSpeed
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's speed when rolling and moving left
; ---------------------------------------------------------------------------

Sonic_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	.no_change				; branch if inertia is 0
		bpl.s	.positive				; branch if inertia is positive

	.no_change:
		bset	#staFacing,obStatus(a0)	; face Sonic left
		move.b	#aniID_Roll,obAnim(a0)	; use "rolling" animation
		rts	
; ===========================================================================

	.positive:
		sub.w	d4,d0					; d0 = inertia minus deceleration
		bcc.s	.still_positive			; branch if inertia is still positive
		moveq	#0,d0					; Mercury Rolling Turn Around Fix

	.still_positive:
		move.w	d0,obInertia(a0)		; update inertia
		rts	
; End of function Sonic_RollLeft
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	update Sonic's speed when rolling and moving right
; ---------------------------------------------------------------------------

Sonic_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	.negative				; branch if inertia is negative
		bclr	#staFacing,obStatus(a0)	; face Sonic right
		move.b	#aniID_Roll,obAnim(a0)	; use "rolling" animation
		rts	
; ===========================================================================

	.negative:
		add.w	d4,d0					; d0 = inertia plus deceleration
		bcc.s	.still_negative			; branch if inertia is still negative
		moveq	#0,d0					; Mercury Rolling Turn Around Fix

	.still_negative:
		move.w	d0,obInertia(a0)		; update inertia
		rts	
; End of function Sonic_RollRight
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's direction while jumping
; ---------------------------------------------------------------------------

Sonic_JumpDirection:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		asl.w	#1,d5
		btst	#staRollJump,obStatus(a0)	; is Sonic locked by a rolling jump?
		bne.s	.reset_screen				; if yes, branch
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadheld_dup).w	; is left being pressed?
		beq.s	.not_left					; if not, branch
		bset	#staFacing,obStatus(a0)		; face Sonic left
		sub.w	d5,d0						; d0 = speed minus acceleration
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0						; does new speed exceed max?
		bgt.s	.not_left					; if not, branch

	if ~~AirSpeedCapEnabled		; Mercury Disable Air Speed Cap
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	.not_left
	endif	; Disable Air Speed Cap End

		move.w	d1,d0						; set max speed

	.not_left:
		btst	#bitR,(v_jpadheld_dup).w	; is right being pressed?
		beq.s	.update_speed				; if not, branch

		bclr	#staFacing,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0						; does new speed exceed max?
		blt.s	.update_speed				; if not, branch

	if ~~AirSpeedCapEnabled ; Mercury Disable Air Speed Cap
		sub.w d5,d0
		cmp.w d6,d0
		bge.s .update_speed
	endif	; Disable Air Speed Cap End

		move.w	d6,d0						; set max speed

	.update_speed:
		move.w	d0,obVelX(a0)				; update horizontal speed

	.reset_screen:
		cmpi.w	#$60,(v_lookshift).w		; is the screen in its default position?
		beq.s	.screen_ok					; if yes, branch
		bcc.s	.screen_high				; branch if higher
		addq.w	#4,(v_lookshift).w

	.screen_high:
		subq.w	#2,(v_lookshift).w

	.screen_ok:
		cmpi.w	#-$400,obVelY(a0)			; is Sonic moving faster than -$400 upwards?
		blo.s	.exit						; if yes, branch
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1						; d1 = x speed / 32
		beq.s	.exit						; branch if 0
		bmi.s	.moving_left				; branch if moving left
		sub.w	d1,d0						; subtract d1 from x speed
		bcc.s	.air_drag
		moveq	#0,d0

	.air_drag:
		move.w	d0,obVelX(a0)				; apply air drag
		rts	
; ===========================================================================

	.moving_left:
		sub.w	d1,d0
		bcs.s	.air_drag_
		moveq	#0,d0

	.air_drag_:
		move.w	d0,obVelX(a0)				; apply air drag

	.exit:
		rts	
; End of function Sonic_JumpDirection
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

	; flamewing Left Boundary Zip Fix
Sonic_LevelBound:
		moveq	#0,d2						; +++ clear d2 for use
		move.l	obX(a0),d1
		smi.b	d2							; +++ set d2 if player on position > 32767
		add.w	d2,d2						; +++ move bit up
		move.w	obVelX(a0),d0
		spl.b	d2							; +++ set if speed is positive
		add.w	d2,d2						; +++ move bit up
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		spl.b	d2							; +++ set if position+speed is < 32768
		swap	d1
		move.w	(v_limitleft).w,d0
		addi.w	#16,d0
		tst.w	d2							; +++ if d2 is zero, we had an underflow of position
		beq.s	.sides
	; Left Boundary Zip Fix end

		cmp.w	d1,d0						; has Sonic touched the left-side boundary?
		bhi.s	.sides						; if yes, branch
		move.w	(v_limitright).w,d0
		addi.w	#296,d0
		tst.b	(f_lockscreen).w
		bne.s	.screenlocked
		addi.w	#64,d0

	.screenlocked:
		cmp.w	d1,d0						; has Sonic touched the	right-side boundary?
		bhi.s	.chkbottom					; if not, branch

	.sides:
		move.w	d0,obX(a0)					; align to boundary
		moveq	#0,d3
		move.w	d3,obX+2(a0)				; clear subpixel (for alignment)
		move.w	d3,obVelX(a0)				; stop Sonic moving
		move.w	d3,obInertia(a0)			; clear ground inertia

	.chkbottom:
		move.w	(v_limitbtm).w,d0

	; RetroKoH Bottom Boundary Fix
		cmp.w	(v_limitbtm_target).w,d0	; is the intended bottom boundary lower than the current one?
		bcc.s	.notlower					; if not, branch
		move.w	(v_limitbtm_target).w,d0	; d0 = intended bottom boundary

	.notlower:
	; Bottom Boundary Fix End

		addi.w	#224,d0
		cmp.w	obY(a0),d0					; has Sonic touched the	bottom boundary?
		blt.s	.bottom						; if yes, branch
		rts

	.bottom:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w	; is level SBZ2 ?
		bne.s	.jmpto_killsonic			; if not, kill Sonic
		cmpi.w	#$2000,(v_player+obX).w		; has Sonic reached $2000 (or further) on x-axis in SBZ2?
		bcs.s	.jmpto_killsonic			; if not, branch
		clr.b	(v_lastlamp).w				; clear	lamppost counter
		move.b	#1,(f_restart).w			; restart the level
		move.w	#(id_LZ<<8)+3,(v_zone).w	; set level to SBZ3 (LZ4)
		rts
; ===========================================================================

	.jmpto_killsonic:
		jmp		(KillSonic).l
; End of function Sonic_LevelBound
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

Sonic_Roll:
		tst.b	(f_slidemode).w			; are all controls except jump locked?
		bne.s	.noroll					; if yes, branch and exit
		tst.b	(f_wtunnelmode).w		; are we in a wind tunnel?
		bne.s	.noroll					; if yes, branch and exit

; Rewritten to match S3K
	; Check controls first
		move.b	(v_jpadheld_dup).w,d0
		btst	#bitDn,d0				; is down being pressed?
		beq.s	Sonic_ChkWalk			; if not, branch and exit
		andi.b	#btnL+btnR,d0			; is left/right	being pressed?
		bne.s	.noroll					; if yes, branch

		move.w	obInertia(a0),d0		; Check speed and roll if fast enough
		bpl.s	.ispositive
		neg.w	d0						; get absolute value

	.ispositive:

	if SpinDashEnabled	; Mercury Spin Dash
		cmpi.w	#$100,d0				; is Sonic moving at $100 speed or faster?
	else
		cmpi.w	#$80,d0					; is Sonic moving at $80 speed or faster?
	endif	; Spin Dash End

		bhs.s	Sonic_ChkRoll			; if so, branch
		move.b	#aniID_Duck,obAnim(a0) 	; use "ducking" animation

	.noroll:
		rts	
; ===========================================================================

Sonic_ChkWalk:
		cmpi.b	#aniID_Duck,obAnim(a0)	; is Sonic ducking?
		bne.s	.exit
		move.b	#aniID_Walk,obAnim(a0)	; if so, enter walking animation

	.exit:
		rts
; ===========================================================================
; S3K Rewrite End

Sonic_ChkRoll:
		btst	#staSpin,obStatus(a0)	; is Sonic already rolling?
		beq.s	.roll					; if not, branch
		rts	
; ===========================================================================

	.roll:
		bset	#staSpin,obStatus(a0)
		move.w	#$E07,obHeight(a0)		; Height and Width
		move.b	#aniID_Roll,obAnim(a0)	; use "rolling" animation
	; Removed Mercury frame set fix, as it's no longer needed, and actually causes a bug in the new system
		addq.w	#5,obY(a0)				; Add to y-pos the difference in height radius
		move.w	#sfx_Roll,d0
		jsr		(QueueSound2).w			; play rolling sound
		tst.w	obInertia(a0)
		bne.s	.ismoving
		move.w	#$200,obInertia(a0) 	; set inertia if 0

	.ismoving:
		rts	
; End of function Sonic_Roll
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; TO-DO: Rewrite based on S1Squared (Compare to S2/S3K)
; ---------------------------------------------------------------------------

Sonic_Jump:
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0					; is A, B or C pressed?
		beq.w	.exit						; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0				; get floor angle
		addi.b	#$80,d0						; invert it
		bsr.w	Sonic_CalcHeadRoom
		cmpi.w	#6,d1						; does Sonic have enough room to jump?
		blt.w	.exit						; if not, branch
		move.w	#$680,d2					; jump strength

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	#$800,d2					; set higher jump strength if super

	.notSuper:
	endif

		btst	#staWater,obStatus(a0)
		beq.s	.notinwater
		move.w	#$380,d2					; set lower jump strength if underwater

	.notinwater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		(CalcSine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)				; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)				; make Sonic jump
		bset	#staAir,obStatus(a0)
		bclr	#staPush,obStatus(a0)
		addq.l	#4,sp
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		clr.b	obLRLock(a0)				; Mercury Clear Control Lock When Jump
		move.w	#sfx_Jump,d0
		jsr		(QueueSound2).w				; play jumping sound
	; Removed code expanding Sonic's radius -- RetroKoH Rolling Jump Fix

	if ProtoVictoryLeap
		tst.b	(f_victory).w				; has the victory animation flag been set?
		bne.s	.victoryleap				; if yes, branch
	endif

		btst	#staSpin,obStatus(a0)		; Is Sonic already in a ball?
		bne.s	.rolljumplock
	; If not already in a ball, convert Sonic into a ball
		move.w	#$E07,obHeight(a0)			; Height and Width
		move.b	#aniID_Roll,obAnim(a0)		; use "jumping" animation
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)

	.exit:
		rts	
; ===========================================================================
	if ProtoVictoryLeap
	.victoryleap:
		move.b	#aniID_VictoryLeap,obAnim(a0)	; use the "victory leaping" animation
		rts
; ===========================================================================
	endif

.rolljumplock:
	if RollJumpLockActive	; Mercury Rolling Jump Lock Toggle
		bset	#staRollJump,obStatus(a0)	; set the roll jump lock.
	endif

		rts	
; End of function Sonic_Jump
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

Sonic_JumpHeight:

	if WallJumpEnabled	; Mercury Wall Jump
		tst.b	obWallJump(a0)			; is Sonic latched to a wall for a Wall Jump?
		beq.s	.skip					; if not, branch
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0				; is A, B or C pressed?
		beq.s	.skip					; if not, branch
		clr.w	obWallJump(a0)			; clear Wall Jump data
		move.b	#1,obJumping(a0)
		move.b	#aniID_Roll,obAnim(a0) 	; use "jumping" animation
		move.w	#-$600,d0
		btst	#bitUp,(v_jpadheld_dup).w
		bne.s	.uponly
		move.w	#-$580,d0
		move.w	#-$400,obVelX(a0)
		btst	#staFacing,obStatus(a0)
		beq.s	.uponly
		neg.w	obVelX(a0)
		
	.uponly:
		btst	#staWater,obStatus(a0)
		beq.s	.notinwater
		addi.w	#$280,d0
		
	.notinwater:
		move.w	d0,obVelY(a0)
		move.w	#sfx_Jump,d0
		jsr		(QueueSound2).w			; play jumping sound
		
	.skip:
	endif	;end Wall Jump

		tst.b	obJumping(a0)			; is Sonic jumping?
		beq.s	.not_jumping			; if not, branch
		move.w	#-$400,d1				; jump power after ABC is released
		btst	#staWater,obStatus(a0)
		beq.s	.not_underwater
		move.w	#-$200,d1				; reduce power if underwater

	.not_underwater:
		cmp.w	obVelY(a0),d1
		ble.s	Sonic_DoubleJump
		move.b	(v_jpadheld_dup).w,d0
		andi.b	#btnABC,d0				; is A, B or C pressed/held?
		bne.s	.keep_speed				; if yes, branch
		move.w	d1,obVelY(a0)

	.keep_speed:
		rts	
; ===========================================================================
; Is this now unused?
	.not_jumping:
		tst.b	obAutoRollFlag(a0)		; is Sonic charging a spindash or in a rolling-only area?
		bne.w	.exit					; if yes, branch
		cmpi.w	#-$FC0,obVelY(a0)		; is Sonic moving up really fast?
		bge.s	.exit					; if not, return
		move.w	#-$FC0,obVelY(a0)		; cap upward speed

	.exit:
		rts	
; End of function Sonic_JumpHeight
; ===========================================================================


; Files for Double Jump Techniques; Isolated to keep things readable.
	if S3KDoubleJump
		include "_incObj/sub Sonic DoubleJump - Shields.asm"	; Use if elemental shields and/or the Instashield are enabled
	else
		include "_incObj/sub Sonic DoubleJump - NoShield.asm"	; Use if elemental shields or the Instashield are disabled
	endif


	if DropDashEnabled
; ---------------------------------------------------------------------------
; Subroutine enabling Sonic's Drop Dash
; ---------------------------------------------------------------------------

Sonic_ChkDropDash:
	if ~~ReusableDropDash
		cmpi.b	#3,obDoubleJumpFlag(a0)		; was the Drop Dash cancelled?
		beq.s	.exit						; if yes, branch
	endif

		move.b	obStatus2nd(a0),d0
		btst	#sta2ndInvinc,d0			; is Sonic invincible OR Super?
		bne.s	.skipshieldcheck			; if yes, enable Drop Dash
		andi.b	#mask2ndChkElement,d0		; does Sonic have any elemental shields?
		bne.s	.exit						; if yes, exit

	.skipshieldcheck:
		move.b	(v_jpadheld_dup).w,d0
		andi.b	#btnABC,d0					; is A, B or C held down?
		beq.s	.reset						; if no, branch
		addq.b	#1,obDoubleJumpProp(a0)		; increment charge timer
		cmpi.b	#$14,obDoubleJumpProp(a0)	; is the Drop Dash fully charged? (20 frames)
		blt.s	.exit						; if not yet, exit
		bgt.s	.skipsound					; if yes, and sound has played, skip ahead
		move.b	#aniID_DropDash,obAnim(a0)	; Set new animation
		move.w	#sfx_DropDash,d0
		jsr		(QueueSound2).w				; play charge sound

	.skipsound:
		move.b	#$15,obDoubleJumpProp(a0)	; set to cap + 1 so we only play the sound once
		rts

	.reset:
	if ~~ReusableDropDash
		move.b	#3,obDoubleJumpFlag(a0)		; disable attempting the Drop Dash
	endif

		clr.b	obDoubleJumpProp(a0)
		move.b	#aniID_Roll,obAnim(a0)		; reset to rolling animation

	.exit:
		rts
; End of function Sonic_ChkDropDash
; ===========================================================================
	endif
	
	if SuperMod
; ---------------------------------------------------------------------------
; Subroutine for Sonic to transform in Super Sonic
; ---------------------------------------------------------------------------

Sonic_TurnSuper:
		move.b	#1,(f_super_palette).w
		move.b	#$F,(v_palette_timer).w
		bset	#sta2ndSuper,obStatus2nd(a0)
		move.b	#60,(v_supersonic_frame).w		; set timer
		move.l	#Map_SuperSonic,obMap(a0)		; change mappings
		move.b	#$81,obCtrlLock(a0)
		move.b	#aniID_Transform,obAnim(a0)
		move.b	#id_SuperStars,(v_sstarsobj).w	; load super sonic stars object
		lea		(v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		jsr		(ApplySpeedSettings).l
		clr.b	obInvinc(a0)
		bset	#sta2ndInvinc,obStatus2nd(a0)	; make Sonic invincible
		move.w	#sfx_GiantRing,d0

	if AmbienceMode
		jmp		(QueueSound2).w					; play giant ring sound
	else
		jsr		(QueueSound2).w					; play giant ring sound first
		move.w	#bgm_Invincible,d0
		move.b	d0,(v_lastbgmplayed).w			; store last played music
		jmp		(QueueSound1).w					; play invincibility music
	endif
; End of function Sonic_TurnSuper
; ===========================================================================
	endif

	if (ShieldsMode|DropDashEnabled)
; ---------------------------------------------------------------------------
; Subroutine to reset Sonic's position array
; Added for S3K Shields and Drop Dash; Also used in Debug Mode.
; ---------------------------------------------------------------------------

Reset_Sonic_Position_Array:
		move.w	obX(a0),d1
		swap	d1						; move obX to the upper word -- RetroKoH optimization
		move.w	obY(a0),d1				; move obY to the lower word -- RetroKoH optimization
		lea		(v_tracksonic).w,a1
		move.w	#$3F,d0

	.loop:
		move.l	d1,(a1)+				; move obX and obY to v_tracksonic -- RetroKoH optimization
		dbf		d0,.loop				; loop through the tracking table

		clr.w	(v_trackpos).w
		rts
; End of function Reset_Sonic_Position_Array
; ===========================================================================
	endif
		
	if AirRollEnabled
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to curl up in the air
; ---------------------------------------------------------------------------

Sonic_ChkAirRoll:
	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0)		; is Sonic charging his spin dash?
		bne.s	.exit					; if yes, branch and exit
	endif

	if ProtoVictoryLeap
		tst.b	(f_victory).w			; has the victory animation flag been set?
		bne.s	.exit					; if yes, branch and exit
	endif

		tst.b	(f_wtunnelmode).w		; are we in a wind tunnel?
		bne.s	.exit					; if yes, branch and exit

	if AutoAirRoll
		tst.w	obVelY(a0)				; is Sonic moving upward?
		ble.s	.exit					; if yes, don't curl yet
	else
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0				; are buttons A, B, or C being pressed?
		beq.s	.noAirRoll				; if not, branch
	endif

	; Air Roll starts here
		bset	#staSpin,obStatus(a0)	; set spin status
		move.w	#$E07,obHeight(a0)		; Height and Width
		move.b	#aniID_Roll,obAnim(a0)	; enter rolling animation

	if (S3KDoubleJump|AirRollIntoDropDash)
		move.b	#2,obDoubleJumpFlag(a0)	; disable shield abilities and/or enable Drop Dash transition

	if AirRollIntoDropDash
		; Drop Dash transition doesn't work with auto Air Roll
		move.b	#1,obJumping(a0)		; enable this for potential drop dash transition
	endif

	endif

		move.w	#sfx_Roll,d0
		jsr		(QueueSound2).w			; play rolling sound

	.noAirRoll:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	.exit
		move.w	#-$FC0,obVelY(a0)

	.exit:
		rts	
; End of function Sonic_ChkAirRoll
; ===========================================================================
	endif
	
	if PeeloutEnabled
; ---------------------------------------------------------------------------
; Subroutine to check for starting to perform a peelout
; ---------------------------------------------------------------------------

Sonic_ChkPeelout:
		btst	#1,obSpinDashFlag(a0) ; obSpinDashFlag is also used for Peelout
		bne.s	Sonic_DashLaunch
		cmpi.b	#aniID_LookUp,obAnim(a0)
		bne.s	.exit
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0
		beq.w	.exit
		move.b	#aniID_Run,obAnim(a0)
		clr.w	obSpinDashCounter(a0)
		move.w	#sfx_Charge,d0
		jsr		(QueueSound2).w
		addq.l	#4,sp
		bset	#1,obSpinDashFlag(a0)

		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos

	.exit:
		rts
; ===========================================================================

Sonic_DashLaunch:
		move.b	#aniID_Peelout,obAnim(a0)
		move.b	(v_jpadheld_dup).w,d0
		btst	#bitUp,d0
		bne.w	.charge_dash

		clr.b	obSpinDashFlag(a0)			; stop Dashing
		cmpi.w	#$1E,obSpinDashCounter(a0)	; have we been charging long enough?
		bne.s	.stop_sound
		move.b	#aniID_Dash,obAnim(a0)		; launches here
		move.w	#1,obVelX(a0)				; force X speed to nonzero for camera lag's benefit
		move.w	#$C00,obInertia(a0)			; set running speed

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	#$F00,obInertia(a0)			; set running speed

	.notSuper:
	endif

		move.w	obInertia(a0),d0
		subq.b	#$8,d0
		add.b	d0,d0
		andi.b	#$1F,d0
		neg.b	d0
		addi.b	#$20,d0
		move.b	d0,(v_cameralag).w			; use it to set the camera lag
		btst	#staFacing,obStatus(a0)
		beq.s	.dontflip
		neg.w	obInertia(a0)

	.dontflip:
	; Improved section by DeltaWooloo
		move.w	#sfx_Release,d0
		jsr		(QueueSound2).w
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bra.w	.reset_screen
; ===========================================================================

	.charge_dash:				; If still charging the dash...
		cmpi.w	#$1E,obSpinDashCounter(a0)
		beq.s	.reset_screen
		addq.w	#1,obSpinDashCounter(a0)
		bra.s	.reset_screen

	.stop_sound:
		move.w	#sfx_Stop,d0
		jsr		(QueueSound2).w
		clr.w	obInertia(a0)

	.reset_screen:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.screen_ok
		bcc.s	.screen_high
		addq.w	#4,(v_lookshift).w

	.screen_high:
		subq.w	#2,(v_lookshift).w

	.screen_ok:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos
; ===========================================================================
	endif
	
	if SpinDashEnabled==1
; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash (Standard Version)
; ---------------------------------------------------------------------------

Sonic_ChkSpinDash:
		btst	#0,obSpinDashFlag(a0)	; already Spin Dashing?
		bne.s	Sonic_UpdateSpinDash	; if yes, branch to updating spin dash
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	.return					; if not ducking down, return
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0
		beq.w	.return					; if not pressing ABC, return
		move.b	#aniID_SpinDash,obAnim(a0)
		move.w	#sfx_SpinDash,d0
		jsr		(QueueSound2).w
		addq.l	#4,sp
		bset	#0,obSpinDashFlag(a0)

	if SpinDashCancel	; Mercury Spin Dash Cancel
		move.w	#$80,obSpinDashCounter(a0)
	else
		clr.w	obSpinDashCounter(a0)
	endc	; Spin Dash Cancel End

		cmpi.b	#$C,(v_air).w			; if he's drowning, branch to not make dust
		bcs.s	.nodust
		move.b	#1,(v_playerdust+obAnim).w

	.nodust:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos

	.return:
		rts
; ===========================================================================

Sonic_UpdateSpinDash:
		move.b	#aniID_SpinDash,obAnim(a0)
		move.b	(v_jpadheld_dup).w,d0
		btst	#bitDn,d0
		bne.w	.charge_spindash

		; unleash the charged spin dash and start rolling quickly:
		move.w	#$E07,obHeight(a0)			; Height and Width
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
		clr.b	obSpinDashFlag(a0)
		moveq	#0,d0
		move.b	obSpinDashCounter(a0),d0
		add.w	d0,d0
		move.w	#1,obVelX(a0)				; force X speed to nonzero for camera lag's benefit
		move.w	SpinDashSpeeds(pc,d0.w),obInertia(a0)

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	SpindashSpeedsSuper(pc,d0.w),obInertia(a0)

	.notSuper:
	endif

	; Use inertia to set camera lag effect
		move.b	obInertia(a0),d0
		subq.b	#$8,d0
		add.b	d0,d0
		andi.b	#$1F,d0
		neg.b	d0
		addi.b	#$20,d0
		move.b	d0,(v_cameralag).w
	; Camera lag effect end
		btst	#staFacing,obStatus(a0)
		beq.s	.dontflip
		neg.w	obInertia(a0)

	.dontflip:
		bset	#staSpin,obStatus(a0)		; Sonic is now spinning
		clr.b	(v_playerdust+obAnim).w
		move.w	#sfx_Teleport,d0
		jsr		(QueueSound2).w
	; flamewing Boundary Spindash bugfix: https://info.sonicretro.org/SCHG_How-to:Fix_screen_boundary_spindash_bug
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
	; Boundary Spindash bugfix end
		bra.w	.reset_screen
; ===========================================================================

SpinDashSpeeds:
		dc.w  $800		; 0
		dc.w  $880		; 1
		dc.w  $900		; 2
		dc.w  $980		; 3
		dc.w  $A00		; 4
		dc.w  $A80		; 5
		dc.w  $B00		; 6
		dc.w  $B80		; 7
		dc.w  $C00		; 8
; ===========================================================================

	if SuperMod
SpindashSpeedsSuper:
		dc.w  $B00		; 0
		dc.w  $B80		; 1
		dc.w  $C00		; 2
		dc.w  $C80		; 3
		dc.w  $D00		; 4
		dc.w  $D80		; 5
		dc.w  $E00		; 6
		dc.w  $E80		; 7
		dc.w  $F00		; 8
; ===========================================================================
	endif

	.charge_spindash:				; If still charging the dash...
		tst.w	obSpinDashCounter(a0)
		beq.s	.rev_up
		
	if SpinDashNoRevDown ; Mercury Spin Dash No Rev Down
		move.b	(v_jpadheld_dup).w,d0
		andi.b	#btnABC,d0
		bne.s	.rev_up	
	endif	; Spin Dash No Rev Down end

		move.w	obSpinDashCounter(a0),d0
		lsr.w	#5,d0
		sub.w	d0,obSpinDashCounter(a0)	; SpinDash rev down effect applied
		
	if SpinDashCancel	; Mercury Spin Dash Cancel
		cmpi.w	#$1F,obSpinDashCounter(a0)
		bne.s	.skip
		clr.w	obSpinDashCounter(a0)		; clear SpinDash Counter
		clr.b	obSpinDashFlag(a0)			; cancel SpinDash
		bra.s	.reset_screen			; branch

	.skip:
	endif	; Spin Dash Cancel End	

		bcc.s	.rev_up
		clr.w	obSpinDashCounter(a0)

	.rev_up:
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0
		beq.w	.reset_screen
		;move.w	#(id_SpinDash<<8),obAnim(a0)	; id_SpinDash
		addi.w	#$200,obSpinDashCounter(a0)
		cmpi.w	#$800,obSpinDashCounter(a0)
		bcs.s	.sound
		move.w	#$800,obSpinDashCounter(a0)

	.sound:
		move.w	#sfx_SpinDash,d0				; sfx_SpinDash
		jsr		(QueueSound2).w

	.reset_screen:
		addq.l	#4,sp							; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.screen_ok
		bcc.s	.screen_high
		addq.w	#4,(v_lookshift).w

	.screen_high:
		subq.w	#2,(v_lookshift).w

	.screen_ok:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos
; ===========================================================================

	elseif SpinDashEnabled==2

; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash (CD Variant)
; I based this largely off of the ReadySonic Peelout, but credit to LuigiXHero's
; CD Art Test disassembly for the reference.
; ---------------------------------------------------------------------------

Sonic_ChkSpinDash:
		btst	#1,obSpinDashFlag(a0)	; obSpinDashFlag is also used for Peelout
		bne.s	Sonic_SpinDashLaunch
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	.return
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0
		beq.w	.return
		move.w	#$0E07,obHeight(a0)		; Height and Width
		move.b	#aniID_Roll,obAnim(a0)	; should I use a new animation here?
		addq.w	#5,obY(a0)
		clr.w	obSpinDashCounter(a0)
		move.w	#sfx_Charge,d0
		jsr		(QueueSound2).w
		addq.l	#4,sp
		bset	#1,obSpinDashFlag(a0)

		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos

	.return:
		rts
; ===========================================================================

Sonic_SpinDashLaunch:
		move.b	(v_jpadheld_dup).w,d0
		btst	#bitDn,d0
		bne.w	Sonic_SpinDashCharge

		clr.b	obSpinDashFlag(a0)			; stop Dashing
		cmpi.w	#$1E,obSpinDashCounter(a0)	; have we been charging long enough?
		bne.s	Sonic_SpinDashStopSound		; if not, branch
		move.b	#aniID_Roll,obAnim(a0)		; launches here
		bset	#staSpin,obStatus(a0)		; Sonic is now spinning
		move.w	#1,obVelX(a0)				; force X speed to nonzero for camera lag's benefit
		move.w	#$C00,obInertia(a0)			; set speed

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	#$F00,obInertia(a0)			; set speed
.notSuper:
	endif

; This part copied from the Peelout code 1:1
		move.w	obInertia(a0),d0
		subq.b	#$8,d0
		add.b	d0,d0
		andi.b	#$1F,d0
		neg.b	d0
		addi.b	#$20,d0
		move.b	d0,(v_cameralag).w			; use it to set the camera lag
		btst	#staFacing,obStatus(a0)
		beq.s	.dontflip
		neg.w	obInertia(a0)

.dontflip:
	; Improved section by DeltaWooloo
		move.w	#sfx_Release,d0
		jsr		(QueueSound2).w
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bra.w	.reset_screen
; ===========================================================================

Sonic_SpinDashCharge:				; If still charging the dash...
		cmpi.w	#$1E,obSpinDashCounter(a0)
		beq.s	.reset_screen
		addq.w	#1,obSpinDashCounter(a0)
		bra.s	.reset_screen

Sonic_SpinDashStopSound:
		move.w	#sfx_Stop,d0
		jsr		(QueueSound2).w
		clr.w	obInertia(a0)
		move.w	#$1309,obHeight(a0)		; Height and Width
		move.b	#aniID_Wait,obAnim(a0)
		subq.w	#5,obY(a0)

	.reset_screen:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.finish
		bcc.s	.skip
		addq.w	#4,(v_lookshift).w

	.skip:
		subq.w	#2,(v_lookshift).w

	.finish:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos
; ===========================================================================
	endif

; ---------------------------------------------------------------------------
; Subroutine to	slow Sonic walking up a	slope (Optimized by Hivebrain)
; ---------------------------------------------------------------------------

Sonic_SlopeResist:
		move.b	obAngle(a0),d0
		move.b	d0,d1				; copy to d1 so we don't need to load obAngle twice (Saves 8(2/0))
		addi.b	#$60,d1
		cmpi.b	#$C0,d1
		bhs.s	.no_change			; branch if Sonic is on ceiling
		jsr		(CalcSine).w		; convert angle to sine
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	.no_change			; branch if inertia == 0
		bmi.s	.set_inertia		; branch if negative
		tst.w	d0
		beq.s	.no_change

.set_inertia:
		add.w	d0,obInertia(a0)	; update Sonic's inertia

.no_change:
		rts
; End of function Sonic_SlopeResist
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope	while he's rolling (Optimized by Hivebrain)
; ---------------------------------------------------------------------------

Sonic_RollRepel:
		move.b	obAngle(a0),d0
		move.b	d0,d1				; copy to d1 so we don't need to load obAngle twice (Saves 8(2/0))
		addi.b	#$60,d1
		cmpi.b	#$C0,d1
		bhs.s	.no_change
		move.b	obAngle(a0),d0		; branch if Sonic is on ceiling
		jsr		(CalcSine).w		; convert angle to sine
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	.inertia_neg		; branch if negative
		tst.w	d0
		bpl.s	.sine_pos			; branch if sine is positive
		asr.l	#2,d0

	.sine_pos:
		add.w	d0,obInertia(a0)	; update Sonic's inertia
		rts	
; ===========================================================================

	.inertia_neg:
		tst.w	d0
		bmi.s	.sine_neg			; branch if sine is negative
		asr.l	#2,d0

	.sine_neg:
		add.w	d0,obInertia(a0)	; update Sonic's inertia

	.no_change:
		rts	
; End of function Sonic_RollRepel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

Sonic_SlopeRepel:
		nop	
		tst.b	obOnWheel(a0)		; is Sonic on a convex wheel?
		bne.s	.exit				; if yes, branch
		tst.b	obLRLock(a0)		; are controls temporarily locked?
		bne.s	.locked				; if yes, branch
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.exit				; branch if slope is 0 +-$20
		move.w	obInertia(a0),d0
		bpl.s	.inertia_pos		; branch if inertia is positive
		neg.w	d0

	.inertia_pos:
		cmpi.w	#$280,d0
		bhs.s	.exit				; branch if inertia is at least $280
		clr.w	obInertia(a0)		; set Sonic's inertia to 0
		bset	#staAir,obStatus(a0)
		move.b	#$1E,obLRLock(a0) ; lock controls for half a second

	.exit:
		rts	
; ===========================================================================

	.locked:
		subq.b	#1,obLRLock(a0)		; decrement lock timer
		rts	
; End of function Sonic_SlopeRepel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

;Sonic_JumpAngle:
Sonic_AirCollision:
		move.b	obAngle(a0),d0		; get Sonic's angle
		beq.s	Sonic_JumpCollision	; if 0, branch
		bpl.s	.angle_pos			; if 1-$7F, branch

		addq.b	#2,d0				; increase angle
		bcc.s	.set_angle
		moveq	#0,d0
		bra.s	.set_angle
; ===========================================================================

	.angle_pos:
		subq.b	#2,d0				; decrease angle
		bcc.s	.set_angle
		moveq	#0,d0

	.set_angle:
		move.b	d0,obAngle(a0)

; End of function Sonic_AirCollision
; fallthrough

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; Sonic_Floor: Sonic_DoLevelCollision:
Sonic_JumpCollision:
		move.l	#v_collision1&$FFFFFF,(v_collindex).w	; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w					; MJ: is second collision set to be used?
		beq.s	.first									; MJ: if not, branch
		move.l	#v_collision2&$FFFFFF,(v_collindex).w	; MJ: load second collision data location

	.first:
		move.b	(v_lrb_solid_bit).w,d5					; MJ: load L/R/B soldity bit

	; Devon Air Collision Improvement
	; Avoiding CalcAngle When Performing Collision in the Air
		move.w	obVelX(a0),d0
		move.w	obVelY(a0),d1
		bpl.s	.down									; If it's positive, branch
		cmp.w	d0,d1									; Are we moving towards the left?
		bgt.w	Sonic_AirMode_LeftWall					; If so, branch
		neg.w	d0										; Are we moving towards the right?
		cmp.w	d0,d1
		bge.w	Sonic_AirMode_RightWall					; If so, branch
		bra.w	Sonic_AirMode_Ceiling					; We are moving upwards
 
	.down:
		cmp.w	d0,d1									; Are we moving towards the right?
		blt.w	Sonic_AirMode_RightWall					; If so, branch
		neg.w	d0
		cmp.w	d0,d1									; Are we moving towards the left?
		ble.w	Sonic_AirMode_LeftWall					; If so, branch
		; fallthrough if moving downward
	; Air Collision Improvement End

; ---------------------------------------------------------------------------
; Floor Mode if moving downward
; ---------------------------------------------------------------------------
;Sonic_AirMode_Floor:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkRightWall
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)								; stop Sonic since he hit a wall on his left

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnL,d1								; store left button for directional input check
		bsr.w	Sonic_WallJump
	endc	; Wall Jump end

	.chkRightWall:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkFloor
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)								; stop Sonic since he hit a wall on his right

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnR,d1								; store right button for directional input check
		bsr.w	Sonic_WallJump
	endc	; Wall Jump end

	.chkFloor:
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.exit						; branch if Sonic hasn't hit floor
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	.on_floor
		cmp.b	d2,d0
		blt.s	.exit

	.on_floor:
		add.w	d1,obY(a0)					; align to floor
		move.b	d3,obAngle(a0)				; set angle
		;bsr.w	Sonic_ResetOnFloor			; Moved to .flat -- Fix Bubble Bounce
		;move.b	#aniID_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	.steep						; branch if floor is steep slope (over 45 degrees)
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	.flat						; branch if floor is flat (or almost)
		asr		obVelY(a0)
		bra.s	.y_to_inertia
; ===========================================================================

	.flat:
		clr.w	obVelY(a0)					; stop Sonic falling since he hit a floor
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved from .on_floor -- Fix Bubble Bounce
; ===========================================================================

	.steep:
		clr.w	obVelX(a0)					; stop Sonic moving left/right since he hit a wall
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	.y_to_inertia				; branch if y speed is below max
		move.w	#$FC0,obVelY(a0)			; set max speed

	.y_to_inertia:
	; This might need to be fixed
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.w	Sonic_ResetOnFloor
		neg.w	obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Added -- Fix Bubble Bounce

	.exit:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Left Wall Mode if moving mostly left
; ---------------------------------------------------------------------------

Sonic_AirMode_LeftWall: ;loc_13680:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkCeiling					; branch if distance is positive (not inside wall)
		sub.w	d1,obX(a0)					; align to wall
		clr.w	obVelX(a0)					; stop Sonic moving left since he hit a wall on his left
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.chkFloor					; branch if distance is positive (not inside ceiling)
		sub.w	d1,obY(a0)					; align to ceiling
		tst.w	obVelY(a0)
		bpl.s	.moving_down				; branch if Sonic is moving down
		clr.w	obVelY(a0)					; stop Sonic moving up since he hit a ceiling

	.moving_down:
		rts	
; ===========================================================================

	.chkFloor:
		tst.w	obVelY(a0)
		bmi.s	.exit						; branch if Sonic is moving up
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.exit
		add.w	d1,obY(a0)					; align to floor
		move.b	d3,obAngle(a0)				; save floor angle
	;	bsr.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce
	;	move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)					; stop Sonic falling since he hit a floor
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce

	.exit:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Ceiling Mode if moving upwards
; ---------------------------------------------------------------------------

Sonic_AirMode_Ceiling: ;loc_136E2:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkRightWall				; branch if Sonic hasn't hit left wall
		sub.w	d1,obX(a0)					; align to wall
		clr.w	obVelX(a0)					; stop Sonic moving left since he hit a wall

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnL,d1					; store left button for directional input check
		bsr.w	Sonic_WallJump
	endc	; Wall Jump end

	.chkRightWall:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkCeiling					; branch if Sonic hasn't hit right wall
		add.w	d1,obX(a0)					; align to wall
		clr.w	obVelX(a0)					; stop Sonic moving right since he hit a wall

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnR,d1					; store right button for directional input check
		bsr.w	Sonic_WallJump
	endc	; Wall Jump end

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.exit						; branch if Sonic hasn't hit ceiling
		sub.w	d1,obY(a0)					; align to ceiling
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	.steep						; branch if ceiling is almost-vertical slope
		clr.w	obVelY(a0)					; stop Sonic in y since he hit a ceiling
		rts	
; ===========================================================================

	.steep:
	; This might need to be fixed
		move.b	d3,obAngle(a0)				; save floor angle
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.w	Sonic_ResetOnFloor
		neg.w	obInertia(a0)
		bra.w	Sonic_ResetOnFloor

	.exit:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Right Wall Mode if moving mostly right
; ---------------------------------------------------------------------------

Sonic_AirMode_RightWall: ;loc_1373E:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkCeiling					; branch if Sonic hasn't hit right wall
		add.w	d1,obX(a0)					; align to wall
		clr.w	obVelX(a0)					; stop Sonic moving right since he hit a wall
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.chkFloor					; branch if Sonic hasn't hit ceiling
		sub.w	d1,obY(a0)					; align to ceiling
		tst.w	obVelY(a0)
		bpl.s	.moving_down				; branch if Sonic is moving down
		clr.w	obVelY(a0)					; stop Sonic moving up since he hit a ceiling

	.moving_down:
		rts	
; ===========================================================================

	.chkFloor:
		tst.w	obVelY(a0)
		bmi.s	.exit						; branch if Sonic is moving up
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.exit						; branch if Sonic hasn't hit the floor
		add.w	d1,obY(a0)					; align to floor
		move.b	d3,obAngle(a0)				; Moved
	;	bsr.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce
	;	move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)					; stop Sonic falling since he hit a floor
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce

	.exit:
		rts	
; End of function Sonic_JumpCollision
; ===========================================================================

	if WallJumpEnabled	; Mercury Wall Jump
Sonic_WallJump:
		tst.b	obJumping(a0)				; is Sonic jumping?
		beq.s	.return						; if not, branch and exit (fail)
		bmi.s	.return						; if yes, but we fell from wall, branch and exit (fail)

	; Removing this check makes it feel more intuitive, but it causes unwanted wall jumps EVERYWHERE
		tst.b	obVelY(a0)					; is Sonic moving upward?
		bmi.s	.return						; if yes, branch and exit (fail)

		move.b	(v_jpadheld_dup).w,d0
		andi.b	#(btnL|btnR),d0				; are left or right held?
		beq.s	.return						; if not, branch and exit (fail)
		cmpi.b	#(btnL|btnR),d0				; are both being pressed together?
		beq.s	.return						; if yes, branch and exit (fail)
		and.b	d1,d0						; is the player holding the necessary directional (left or right)?
		beq.s	.return						; if not, branch and exit (fail)
		move.b	d0,(obWallJump+1)(a0)		; store input direction
		clr.w	obVelY(a0)					; stop vertical movement
		move.b	#40,obWallJump(a0)			; latch onto the wall for 40 frames
		clr.b	obJumping(a0)				; clear jumping flag
		move.b	#aniID_WallJump,obAnim(a0)	; set animation

	if ~~ReusableDropDash
		move.b	#3,obDoubleJumpFlag(a0)		; cancel out Drop Dash
		clr.b	obDoubleJumpProp(a0)
	endif
		
	.return:
		rts
	endif	; Wall Jump end

	if CDCamera
; ---------------------------------------------------------------------------
; Subroutine to horizontally pan the camera view ahead of the player
; (Ported from the US version of Sonic CD's "R11A__.MMD" by Naoto)
; Credit: Wooloo Engine
; ---------------------------------------------------------------------------

Sonic_PanCamera:
		move.w	(v_camera_pan).w,d1		; get the current camera pan value
		move.w	obInertia(a0),d0		; get sonic's inertia
		bpl.s	.abs_inertia			; if sonic's inertia is positive, branch ahead
		neg.w	d0						; otherwise, we negate it to get the absolute value

	.abs_inertia:

	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0)		; is sonic charging up a spin dash?
		beq.s	.skip					; if not, branch
		btst	#0,obStatus(a0)			; check the direction that sonic is facing
		bne.s	.pan_right				; if he's facing right, pan the camera to the right
		bra.s	.pan_left				; otherwise, pan the camera to the left

	.skip:
	endif

		cmpi.w	#$600,d0				; is sonic's inertia greater than $600
		bcs.s	.reset_pan				; if not, recenter the screen (if needed)
		tst.w	obInertia(a0)			; otherwise, check the direction of inertia (by subtracting it from 0)
		bpl.s	.pan_left				; if the result was positive, then inertia was negative, so we pan the screen left

	.pan_right:
		addq.w	#2,d1					; add 2 to the pan value
		cmpi.w	#224,d1					; is the pan value greater than 224 pixels?
		bcs.s	.update_pan				; if not, branch
		move.w	#224,d1					; otherwise, cap the value at the maximum of 224 pixels
		bra.s	.update_pan				; branch
; ===========================================================================

	.pan_left:
        subq.w	#2,d1					; subtract 2 from the pan value
        cmpi.w	#96,d1					; is the pan value less than 96 pixels?
        bcc.s	.update_pan				; if not, branch
        move.w	#96,d1					; otherwise, cap the value at the minimum of 96 pixels
        bra.s	.update_pan				; branch
; ===========================================================================

	.reset_pan:
		cmpi.w	#160,d1					; is the pan value 160 pixels?
		beq.s	.update_pan				; if so, branch
		bcc.s	.reset_left				; otherwise, branch if it greater than 160
     
	.reset_right:
		addq.w	#2,d1					; add 2 to the pan value
		bra.s	.update_pan				; branch
; ===========================================================================

	.reset_left:
		subq.w	#2,d1					; subtract 2 from the pan value

	.update_pan:
		move.w	d1,(v_camera_pan).w		; update the camera pan value
		rts								; return
; End of function Sonic_PanCamera
; ===========================================================================
	endif

; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

Sonic_ResetOnFloor:
		tst.b	obAutoRollFlag(a0)
		bne.s	.skippart
		move.b	#aniID_Walk,obAnim(a0)			; use running/walking animation -- Hame Animation Reset Fix

;Part2
		btst	#staSpin,obStatus(a0)			; is Sonic spinning?
		beq.s	.skippart						; if not, branch
	; if Sonic is spinning upon landing
		bclr	#staSpin,obStatus(a0)
		move.w	#$1309,obHeight(a0)				; Height and Width
		move.b	#aniID_Walk,obAnim(a0)			; use running/walking animation
		subq.w	#5,obY(a0)						; move Sonic up 5 pixels so the increased height doesn't push him into the ground

;Part3
	.skippart:
		andi.b	#~(maskAir+maskRollJump+maskPush),obStatus(a0)	; Should clear Air, RollJump and Push bits ($CD)
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w

	if WallJumpEnabled	; Mercury Wall Jump
		clr.w	obWallJump(a0)					; clear wall latch flag and saved directional input state
	endif	; Wall Jump end

	if ~~ShieldsMode

		if DropDashEnabled
			tst.b	obDoubleJumpFlag(a0)
			beq.s	.ret
			cmpi.b	#$14,obDoubleJumpProp(a0)	; is it fully revved up?
			blt.s	.noability					; if not, exit
			bra.w	DropDash_Release

		.noability:
			clr.b	obDoubleJumpFlag(a0)
			clr.b	obDoubleJumpProp(a0)
		endif

		.ret:
			rts
; End of function Sonic_ResetOnFloor
; ===========================================================================
	else				; Mode 2+

		tst.b	obDoubleJumpFlag(a0)
		beq.s	.ret
		move.b	obStatus2nd(a0),d0
		btst	#sta2ndInvinc,d0		; is Sonic invincible OR Super?
		bne.s	.nobubble				; if yes, don't bubble bounce
		btst	#sta2ndBShield,d0		; does Sonic have a Bubble Shield?
		beq.s	.nobubble
		bra.s	BubbleShield_Bounce

		.nobubble:

		if DropDashEnabled
			btst	#sta2ndInvinc,d0			; is Sonic invincible OR Super?
			bne.s	.skipshieldcheck			; if yes, enable Drop Dash
			andi.b	#mask2ndChkElement,d0		; Check for any elemental shields
			bne.s	.noability					; if he has, we will exit
		.skipshieldcheck:
			cmpi.b	#$14,obDoubleJumpProp(a0)	; is it fully revved up?
			blt.s	.noability					; if not, exit
			bra.w	DropDash_Release

		.noability:
			; This should fix a bug w/ unusual looking Flame Shield Animating (RetroKoH)
			btst	#sta2ndFShield,obStatus2nd(a0)	; does Sonic have a Flame Shield?
			beq.s	.noflame
			move.b	#aniID_FlameShield,(v_shieldobj+obAnim).w	; reset animation upon landing

		.noflame:
		endif

		clr.b	obDoubleJumpFlag(a0)
		clr.b	obDoubleJumpProp(a0)

		.ret:
			rts	
	; End of function Sonic_ResetOnFloor
; ===========================================================================
	endif				; Mode 1+


	if ShieldsMode
; ---------------------------------------------------------------------------
; Subroutine to	bounce Sonic in the air when he has a bubble shield
; ---------------------------------------------------------------------------

BubbleShield_Bounce:
		movem.l	d1-d2,-(sp)
		move.w	#$780,d2
		btst	#staWater,obStatus(a0)
		beq.s	.nowater
		move.w	#$400,d2

	.nowater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr		(CalcSine).w
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,obVelX(a0)
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,obVelY(a0)
		movem.l	(sp)+,d1-d2
		bset	#staAir,obStatus(a0)
		bclr	#staPush,obStatus(a0)
		move.b	#1,obJumping(a0)
		clr.b	obOnWheel(a0)
		move.w	#$E07,obHeight(a0)			; Height and Width
		move.b	#aniID_Roll,obAnim(a0)
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)
		move.b	#aniID_BubbleBounceUp,(v_shieldobj+obAnim).w
		clr.b	obDoubleJumpFlag(a0)
		move.w	#sfx_BShieldAtk,d0
		jmp		(QueueSound2).w
; End of function BubbleShield_Bounce
	endif
; ===========================================================================

	if DropDashEnabled
; ---------------------------------------------------------------------------
; Subroutine to	allow Sonic to perform the Drop Dash
; Modified (possibly fixed) thanks to Gio.vanni
; ---------------------------------------------------------------------------

DropDash_Release:
		move.w	#$800,d2						; minimum speed
		move.w	#$C00,d3						; maximum speed

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is player super?
		beq.s	.notSuper						; if not, branch
		move.w	#$C00,d2						; else, use alt values
		move.w	#$D00,d3

	.notSuper:
	endif

		move.w	obInertia(a0),d4
		btst	#bitL,(v_jpadheld_dup).w	; is left being pressed?
		bne.s	.dropLeft				; if yes, branch	
		btst	#bitR,(v_jpadheld_dup).w	; is right being pressed?
		bne.s	.dropRight				; if yes, branch		
		btst	#staFacing,obStatus(a0)	; if neither are being pressed, check orientation
		beq.s	.dropRight

	.dropLeft:
		neg.w	d2						; negate base value
		neg.w	d3						; negate base value

		bset	#staFacing,obStatus(a0)	; force orientation to correct one
		tst.w	obVelX(a0)				; check if speed is greater than 0
		bgt.s	.dropSlopeLeft			; if yes, branch
		asr.w	#2,d4           		; divide ground speed by 4
		add.w	d2,d4           		; add speed base to ground speed
		cmp.w	d3,d4           		; check if current speed is lower than speed cap
		bgt.s	.setspeed				; if not, branch
		move.w	d3,d4					; if yes, cap speed
		bra.s	.setspeed

	.dropSlopeLeft:
		tst.b	obAngle(a0)				; check if Sonic is on a flat surface
		beq.s	.dropBackLeft			; if yes, branch
		asr.w	#1,d4					; divide ground speed by 2
		add.w	d2,d4					; add speed base to ground speed
		bra.s	.setspeed

	.dropBackLeft:
		move.w	d2,d4					; move speed base to ground speed
		bra.s	.setspeed
		
	.dropMaxLeft:
		move.w	d3,d4					; grant sonic the highest possible speed
		bra.s	.setspeed

	.dropRight:
		bclr	#staFacing,obStatus(a0)	; force orientation to correct one			
		tst.w	obVelX(a0)				; check if speed is lower than 0
		blt.s	.dropSlopeRight			; if yes, branch
		asr.w	#2,d4           		; divide ground speed by 4
		add.w	d2,d4           		; add speed base to ground speed
		cmp.w	d3,d4           		; check if current speed is lower than speed cap
		blt.s	.setspeed				; if not, branch
		move.w	d3,d4			  		; if yes, cap speed
		bra.s	.setspeed
		
	.dropSlopeRight:
		tst.b	obAngle(a0)				; check if Sonic is on a flat surface
		beq.s	.dropBackRight			; if yes, branch
		asr.w	#1,d4					; divide ground speed by 2
		add.w	d2,d4					; add speed base to ground speed
		bra.s	.setspeed
	
	.dropBackRight:
		move.w	d2,d4					; move speed base to ground speed 
		bra.s	.setspeed
	
	.dropMaxRight:
		move.w	d3,d4
		
	.setspeed:	
		move.w	d4,obInertia(a0)			; move dash speed into inertia	

		move.b	#$10,(v_cameralag).w
		bsr.w	Reset_Sonic_Position_Array
		move.w	#$E07,obHeight(a0)			; Height and Width
		move.b	#aniID_Roll,obAnim(a0)
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)					; add the difference between Sonic's rolling and standing heights
		clr.b	obDoubleJumpFlag(a0)
		clr.b	obDoubleJumpProp(a0)

	if DropDustEnabled
	; Create drop dash dust
		jsr		(FindFreeObj).l
		bne.s	.noDust
		_move.b	#id_Effects,obID(a1)		; load obj07
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)	; match Player's x orientation
		andi.b	#maskFacing,obStatus(a1)	; only retain staFacing (staFlipX)
		move.b	#3,obAnim(a1)
		move.b	#2,obRoutine(a1)
		move.l	#Map_Effects,obMap(a1)
		ori.b	#4,obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obActWid(a1)
		move.w	#ArtTile_Dust,obGfx(a1)
	endif

		movea.l	a0,a1

		move.w	#sfx_Teleport,d0
		jmp		(QueueSound2).w				; play spindash release sfx

	.noDust:
		movea.l	a0,a1
		rts
	endif
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic	when he	gets hurt
; ---------------------------------------------------------------------------

Sonic_Hurt:	; Routine 4
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w					; is debug cheat enabled?
		beq.s	Sonic_Hurt_Normal				; if not, branch
		btst	#bitB,(v_jpadpressed_actual).w	; is button B pressed?
		beq.s	Sonic_Hurt_Normal				; if not, branch
		move.w	#1,(v_debuguse).w				; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Hurt_Normal:
	; Debug Mode Addition End

	if SpinDashEnabled
		clr.b	(v_cameralag).w			; Spin Dash Enabled
	endif

	if WallJumpEnabled	; Mercury Wall Jump
		clr.w	obWallJump(a0)			; clear wall latch flag and saved directional input state
	endif	; Wall Jump end

		jsr		(SpeedToPos).l
		addi.w	#$30,obVelY(a0)			; apply gravity
		btst	#staWater,obStatus(a0)
		beq.s	.not_underwater			; branch if Sonic isn't underwater
		subi.w	#$20,obVelY(a0)			; apply less gravity

	.not_underwater:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Water				; Mercury Hurt Splash Fix
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp		(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

Sonic_HurtStop:
		; Lines omitted -- Mercury Top Boundary Fix
		bsr.w	Sonic_JumpCollision		; floor/wall collision
		btst	#staAir,obStatus(a0)
		bne.s	.no_floor
		moveq	#0,d0
		move.l	d0,obVelX(a0)			; stop moving
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,obInvuln(a0)		; RetroKoH Sonic SST Compaction

	.no_floor:
		rts	
; End of function Sonic_HurtStop
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Sonic_Death:	; Routine 6
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w					; is debug cheat enabled?
		beq.s	Sonic_Death_Normal				; if not, branch
		btst	#bitB,(v_jpadpressed_actual).w	; is button B pressed?
		beq.s	Sonic_Death_Normal				; if not, branch
		move.w	#1,(v_debuguse).w				; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Death_Normal:
	; Debug Mode Addition End

	if SpinDashEnabled
		clr.b	(v_cameralag).w					; Spin Dash Enabled
	endif

		bsr.w	GameOver
		bsr.w	ObjectFall_YOnly
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp		(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Game/Time Over subroutine
; ---------------------------------------------------------------------------

GameOver:
		move.w	(v_screenposy).w,d0	; MarkeyJester Game/Time Over Timing Fix
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	.end				; MarkeyJester Game/Time Over Timing Fix
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w		; stop time counter

	if QuickRestart
		st.b	(f_deathflag).w		; set flag noting we are restarting the level from death
	endif

	; Mercury Lives Over/Underflow Fix
		tst.b	(v_lives).w			; are lives already at 0?
		beq.s	.skip
		addq.b	#1,(f_lifecount).w	; update lives counter
		subq.b	#1,(v_lives).w		; subtract 1 from number of lives
		bne.s	.chkTimeOver
.skip:
	; Lives Over/Underflow Fix End

		clr.b	obRestartTimer(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w	; load GAME object
		move.b	#id_GameOverCard,(v_gameovertext2).w	; load OVER object
		move.b	#1,(v_gameovertext2+obFrame).w			; set OVER object to correct frame
		clr.b	(f_timeover).w
		bra.s	.playmusic
; ===========================================================================

.chkTimeOver:
		move.b	#60,obRestartTimer(a0)					; set time delay to 1 second
		tst.b	(f_timeover).w							; is TIME OVER tag set?
		beq.s	.end									; if not, branch

		clr.b	obRestartTimer(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w	; load TIME object
		move.b	#id_GameOverCard,(v_gameovertext2).w	; load OVER object
		move.b	#2,(v_gameovertext1+obFrame).w			; set TIME object to correct frame
		move.b	#3,(v_gameovertext2+obFrame).w			; set OVER object to correct frame

.playmusic:
		moveq	#plcid_GameOver,d0
		
	if AmbienceMode
		jmp		(AddPLC).w			; load game over patterns
	else
		jsr		(AddPLC).w			; load game over patterns

		move.w	#bgm_GameOver,d0
		jmp		(QueueSound1).w		; play game over music
	endif
; ===========================================================================

.end:
		rts	
; End of function GameOver
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic	when the level is restarted
; ---------------------------------------------------------------------------

Sonic_ResetLevel:; Routine 8
		tst.b	obRestartTimer(a0)
		beq.s	.exit
		subq.b	#1,obRestartTimer(a0)	; subtract 1 from time delay
		bne.s	.exit
		move.b	#1,(f_restart).w		; restart the level

	.exit:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic when he's drowning -- RHS Drowning Fix
; ---------------------------------------------------------------------------

Sonic_Drowned:
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Drowned_Normal	; if not, branch
		btst	#bitB,(v_jpadpressed_actual).w	; is button B pressed?
		beq.s	Sonic_Drowned_Normal	; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		clr.b	(f_nobgscroll).w  		; unlock the screen to reacquire control
		movea.l	a0,a1
		bra.w	ResumeMusic

Sonic_Drowned_Normal:
	; Debug Mode Addition End

		bsr.w	SpeedToPos_YOnly		; Make Sonic able to move
		addi.w	#$10,obVelY(a0)			; Apply gravity
		bsr.w	Sonic_RecordPosition	; Record position
		bsr.s	Sonic_Animate			; Animate Sonic
		bsr.w	Sonic_LoadGfx			; Load Sonic's DPLCs
		bra.w	DisplaySprite			; And finally, display Sonic
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

Sonic_Animate:
		lea		Ani_Sonic(pc),a1

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.notsuper
		lea		Ani_SuperSonic(pc),a1
	endif

	.notsuper:
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obPrevAni(a0),d0		; has animation changed?
		beq.s	.do						; if not, branch
		move.b	d0,obPrevAni(a0)		; set to "no restart"
		clr.b	obAniFrame(a0)			; reset animation
		clr.b	obTimeFrame(a0)			; reset frame duration
		bclr	#staPush,obStatus(a0)	; clear pushing flag -- Mercury Pushing While Walking Fix

	.do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1			; jump to appropriate animation	script
		move.b	(a1),d0					; get frame duration (or special $Fx flag)
		bmi.s	.walkrunroll			; if animation is walk/run/roll/jump, branch
		moveq	#maskFacing,d1
		and.b	obStatus(a0),d1			; read facing bit from status
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)			; apply facing status to render flags
		subq.b	#1,obTimeFrame(a0)		; subtract 1 from frame duration
		bpl.s	.delay					; if time remains, branch
		move.b	d0,obTimeFrame(a0)		; load frame duration

	.loadframe:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1		; load current frame number
		move.b	1(a1,d1.w),d0			; read sprite number from script

		; MarkeyJester Art Limit Extensions
		; Animations extended from [$00 - $7F] to [$00 - $FC]
		cmpi.b	#$FD,d0					; is it a flag from FD to FF?
		bhs.s	.end_FF					; if so, branch to flag routines
		; Art Limit Extensions End

		move.b	d0,obFrame(a0)			; load sprite number
		addq.b	#1,obAniFrame(a0)		; next frame number

	.delay:
		rts	
; ===========================================================================

	.end_FF:
		addq.b	#1,d0					; is the end flag = $FF	?
		bne.s	.end_FE					; if not, branch
		clr.b	obAniFrame(a0)			; restart the animation
		move.b	1(a1),obFrame(a0)		; read and load sprite number
		addq.b	#1,obAniFrame(a0)		; next frame number
		rts
; ===========================================================================

	.end_FE:
		addq.b	#1,d0					; is the end flag = $FE	?
		bne.s	.end_FD					; if not, branch
		move.b	2(a1,d1.w),d0			; read the next	byte in	the script
		sub.b	d0,obAniFrame(a0)		; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),obFrame(a0)	; read and load sprite number
		addq.b	#1,obAniFrame(a0)		; next frame number
		rts
; ===========================================================================

	.end_FD:
		addq.b	#1,d0					; is the end flag = $FD	?
		bne.s	.end					; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)	; read next byte, run that animation

	.end:
		rts	
; ===========================================================================

	.walkrunroll:
		subq.b	#1,obTimeFrame(a0)		; subtract 1 from frame duration
		bpl.s	.delay					; if time remains, branch
		addq.b	#1,d0					; is animation walking/running?
		bne.w	.rolljump				; if not, branch
		moveq	#0,d1
		move.b	obAngle(a0),d0			; get Sonic's angle

 	; Mercury Better handling of angles
		bmi.s	.ble
		beq.s	.ble
		subq.b	#1,d0

	.ble:
	; Better handling of angles end

		moveq	#maskFacing,d2
		and.b	obStatus(a0),d2			; is Sonic mirrored horizontally?
		bne.s	.flip					; if yes, branch
		not.b	d0						; reverse angle

	.flip:
		addi.b	#$10,d0					; add $10 to angle
		bpl.s	.noinvert				; if angle is $0-$7F, branch
		moveq	#3,d1

	.noinvert:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#staPush,obStatus(a0)	; is Sonic pushing something?
		bne.w	.push					; if yes, branch
		lsr.b	#4,d0					; divide angle by $10
		andi.b	#6,d0					; angle	must be	0, 2, 4	or 6
		move.w	obInertia(a0),d2		; get Sonic's speed
		bpl.s	.nomodspeed
		neg.w	d2						; modulus speed

	.nomodspeed:

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.walknotsuper
		
		lea		SupSonAni_Run(pc),a1	; use running animation
		cmpi.w	#$800,d2				; is Sonic at running speed?
		bhs.s	.running				; if yes, branch

		lea		SupSonAni_Walk(pc),a1	; use walking animation
		bra.s	.walking

	.walknotsuper:
	endif

	if PeeloutEnabled
		lea		SonAni_Dash(pc),a1		; use Dashing animation
		cmpi.w	#$A00,d2				; is Sonic at Dashing speed?
		bhs.s	.running				; if yes, branch
	endif

		lea		SonAni_Run(pc),a1		; use running animation
		cmpi.w	#$600,d2				; is Sonic at running speed?
		bhs.s	.running				; if yes, branch

		lea		SonAni_Walk(pc),a1		; use walking animation

; Get correct walking frame.
	;	move.b	d0,d1
	;	lsr.b	#1,d1
	;	add.b	d1,d0					; Angle 0 = 0; Angle 2 = 3 (+6 frames); Angle 4 = 6 (+12 frames); Angle 6 = 9 (+18 frames).
	.walking:
		; Sonic 2 method for 8 frames
		add.b	d0,d0					; Angle 0 = 0; Angle 2 = 4 (+8 frames); Angle 4 = 8 (+16 frames); Angle 6 = 12 (+24 frames).

	.running:
		add.b	d0,d0					; Angle 0 = 0; Angle 2 = +4 frames; Angle 4 = (+8 frames); Angle 6 = (+12 frames).
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	.belowmax
		moveq	#0,d2					; max animation speed

	.belowmax:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)		; modify frame duration
		bsr.w	.loadframe
		add.b	d3,obFrame(a0)			; modify frame number
		rts
; ===========================================================================

	.rolljump:
		addq.b	#1,d0					; is animation rolling/jumping?
		bne.s	.push					; if not, branch
		move.w	obInertia(a0),d2		; get Sonic's speed
		bpl.s	.nomodspeed2
		neg.w	d2

	.nomodspeed2:

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.rollnotsuper

		lea		SupSonAni_Roll2(pc),a1	; use fast animation
		cmpi.w	#$600,d2				; is Sonic moving fast?
		bhs.s	.rolling				; if yes, branch
		lea		SupSonAni_Roll(pc),a1	; use slower animation
		bra.s	.rolling
	
	.rollnotsuper:
	endif

		lea		SonAni_Roll2(pc),a1		; use fast animation
		cmpi.w	#$600,d2				; is Sonic moving fast?
		bhs.s	.rolling				; if yes, branch
		lea		SonAni_Roll(pc),a1		; use slower animation

	.rolling:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	.belowmax2
		moveq	#0,d2

	.belowmax2:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)		; modify frame duration
		moveq	#maskFacing,d1
		and.b	obStatus(a0),d1			; read facing bit from status
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)			; apply facing status to render flags
		bra.w	.loadframe
; ===========================================================================

	.push:
		subq.b	#1,obTimeFrame(a0)		; subtract 1 from frame duration
		bpl.w	.delay					; if time remains, branch
		move.w	obInertia(a0),d2		; get Sonic's speed
		bmi.s	.negspeed
		neg.w	d2

	.negspeed:
		addi.w	#$800,d2
		bpl.s	.belowmax3	
		moveq	#0,d2

	.belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)		; modify frame duration
		lea		SonAni_Push(pc),a1

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.notsuperpush
		lea		SupSonAni_Push(pc),a1

	.notsuperpush:
	endif

		moveq	#maskFacing,d1
		and.b	obStatus(a0),d1			; read facing bit from status
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)			; apply facing status to render flags
		bra.w	.loadframe				; run animation
; End of function Sonic_Animate
; ===========================================================================

; ---------------------------------------------------------------------------
; Animation Scripts
; ---------------------------------------------------------------------------

		include	"_anim/Sonic.asm"

	if SuperMod
		include	"_anim/Super Sonic.asm"
	endif

; ---------------------------------------------------------------------------
; Subroutine to load Sonic's graphics to RAM (Mercury Use DMA Queue)
; ---------------------------------------------------------------------------

Sonic_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load Sonic's current frame number
		cmp.b	(v_sonframenum).w,d0	; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,(v_sonframenum).w	; update frame number for next check
		lea		SonicDynPLC(pc),a2		; a2 = PLC script

	if SuperMod
		move.l	#Art_Sonic,d6
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.notsuper						; if not, branch
		move.l	#Art_SuperSonic,d6
		lea		SuperSonicDynPLC(pc),a2
	
	.notsuper:
	endif

		add.w	d0,d0					; multiply current frame number by 2
		adda.w	(a2,d0.w),a2			; a2 = corresponding PLC
		moveq	#0,d5
		move.w	(a2)+,d5				; read "number of PLC entries" value -- S3K Changed from .b to .w
		subq.w	#1,d5					; decrement for .readentry loop
		bmi.s	.nochange				; if there are no entries, branch and exit
		move.w	#ArtTile_Sonic*tile_size,d4	; load Sonic's VRAM location

	.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1				; d1 = (number of tiles to load - 1)*$10; aka "tile count"	; S3K Changed from .b to .w
		move.w	d1,d3
		lsr.w	#8,d3					; d3 = (tile count-1)*$10
		andi.w	#$F0,d3
		addi.w	#$10,d3					; get actual tile count*$10				-- DMATransfer Length
		andi.w	#$FFF,d1				; clear the counter to remove tile count from the far left nybble
		lsl.l	#5,d1					; changed to .l (allows for more than $FFFF bytes)

	if SuperMod
		add.l	d6,d1					; d1 = Sonic or Super Sonic's art file + tile offset) -- DMATransfer Source 
	else
		add.l	#Art_Sonic,d1			; d1 = (Sonic's art file + tile offset) -- DMATransfer Source
	endif

		move.w	d4,d2					; d2 = Sonic's VRAM location			-- DMATransfer Destination
		add.w	d3,d4
		add.w	d3,d4					; d4 = Sonic's VRAM loc + (tile count * 2)
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry			; repeat for number of entries

	.nochange:
		rts
; End of function Sonic_LoadGfx
; ===========================================================================