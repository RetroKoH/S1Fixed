; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------

SonicPlayer:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Sonic_Normal	; if not, branch
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
		offsetTableEntry.w	Sonic_Drowned		; RHS Drowning Fix
; ===========================================================================

Sonic_Main:	; Routine 0
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		addq.b	#2,obRoutine(a0)
		move.w	#$1309,obHeight(a0)			; Height and Width
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		lea     (v_sonspeedmax).w,a2		; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings			; Fetch Speed settings

	if (SpinDashEnabled|SkidDustEnabled)
		move.b	#id_Effects,(v_playerdust).w
	endif

Sonic_Control:	; Routine 2
	if CDCamera
		bsr.w	Sonic_PanCamera
	endif
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	loc_12C58				; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	loc_12C58				; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts	
; ===========================================================================

loc_12C58:
		tst.b	(f_lockctrl).w					; are controls locked?
		bne.s	loc_12C64						; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w	; enable joypad control

loc_12C64:
		btst	#0,obCtrlLock(a0)				; are controls locked somehow?
		bne.s	loc_12C7E						; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#(maskAir+maskSpin),d0			; Use current air and spin states to determine Control Mode
		move.w	Sonic_Modes(pc,d0.w),d1
		jsr		Sonic_Modes(pc,d1.w)

loc_12C7E:
	if SuperMod
		bsr.w	Sonic_Display
		bsr.s	Sonic_Super
	else
		bsr.s	Sonic_Display
	endif
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Water
		move.b	(v_anglebuffer).w,obFrontAngle(a0)
		move.b	(v_anglebuffer2).w,obRearAngle(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	loc_12CA6
		cmpi.b	#aniID_Walk,obAnim(a0)			; changed instruction because Walk is no longer #0
		bne.s	loc_12CA6
		move.b	obPrevAni(a0),obAnim(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	obCtrlLock(a0)
		bmi.s	loc_12CB6
		jsr		(ReactToItem).l

loc_12CB6:
		bsr.w	Sonic_Loops
		bra.w	Sonic_LoadGfx	
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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Super:				; XREF: Obj01_MdNormal
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.return						; Ignore all this code if not Super Sonic
		tst.b	(f_timecount).w
		beq.s	Sonic_RevertToNormal		; If time is stopped, revert to normal
		subq.b	#1,(v_supersonic_frame).w
		bhi.s	.return						; Changed from bpl to bhi to ensure once every 60 frames, not 61 (MoDule)

	; Only run the below code once every second.
		move.b	#60,(v_supersonic_frame).w	; Reset frame counter to 60
		tst.w	(v_rings).w
		beq.s	Sonic_RevertToNormal		; if no rings, revert to normal
		ori.b	#1,(f_ringcount).w
		cmpi.w	#1,(v_rings).w
		beq.s	.onering
		cmpi.w	#10,(v_rings).w
		beq.s	.onering
		cmpi.w	#100,(v_rings).w
		bne.s	.subtractring

	.onering:
		ori.b	#$80,(f_ringcount).w

	.subtractring:
		subq.w	#1,(v_rings).w
		beq.s	Sonic_RevertToNormal

	.return:
		rts

Sonic_RevertToNormal:
		move.b	#2,(f_super_palette).w		; Remove rotating palette
		move.w	#$28,(v_palette_frame).w
		bclr	#sta2ndSuper,obStatus2nd(a0)
		move.b	#aniID_Run,obPrevAni(a0)	; Change animation back to normal
		clr.b	obInvinc(a0)				; Remove invincibility
		move.l	#Map_Sonic,obMap(a0)		; load Sonic's normal mappings
		lea     (v_sonspeedmax).w,a2    	; Load Sonic_top_speed into a2
		bra.w   ApplySpeedSettings			; Fetch Speed settings
	endif
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to display Sonic and set music
; ---------------------------------------------------------------------------

Sonic_Display:
	; Check for 8th frame 
		move.b	(v_framebyte).w,d1				; RetroKoH Sonic_Display Optimization
		andi.b	#7,d1							; if d1 == 0, we will decrement shoes/invinc on this frame

	; Check hurt frames
		move.b	obInvuln(a0),d0					; RetroKoH Sonic SST Compaction
		beq.s	.display
		subq.b	#1,obInvuln(a0)					; RetroKoH Sonic SST Compaction
		lsr.w	#3,d0
		bcc.s	.chkinvincible

	.display:
		jsr		(DisplaySprite).l

	.chkinvincible:
		btst	#sta2ndInvinc,obStatus2nd(a0)	; does Sonic have invincibility?
		beq.s	.chkshoes						; if not, branch

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic Super?
		bne.s	.chkshoes						; if yes, don't check to remove invincibility
	endif

		tst.b	obInvinc(a0)					; check	time remaining for invinciblity -- RetroKoH Sonic SST Compaction
		beq.s	.chkremoveinvinc				; if we have the powerup but no time remains, remove the powerup (RetroKoH Bugfix)
		
	; RetroKoH Sonic SST Compaction
		tst.b	d1
		bne.s	.chkshoes						; if it's not the 8th frame, branch
		subq.b	#1,obInvinc(a0)					; subtract 1 from time every 8 frames (only if d1 == 0)
	; End
		
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
	; Set invulnerability briefly after stars expire
		move.b	#$3C,obInvuln(a0)				; RetroKoH Sonic SST Compaction
	endif

	.chkshoes:
		btst	#sta2ndShoes,obStatus2nd(a0)	; does Sonic have speed	shoes?
		beq.s	.exit							; if not, branch
		tst.b	obShoes(a0)						; check	time remaining for speed shoes -- RetroKoH Sonic SST Compaction
		beq.s	.exit							; if we have the powerup but no time remains, remove the powerup (RetroKoH Bugfix)
		
	; RetroKoH Sonic SST Compaction
		tst.b	d1
		bne.s	.exit							; if it's not the 8th frame, branch
		subq.b	#1,obShoes(a0)					; subtract 1 from time every 8 frames (only if d1 == 0)
	; End
		
		bne.s	.exit							; if time still remains, branch

	.removeshoes:
		lea     (v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings				; Fetch Speed settings
		bclr	#sta2ndShoes,obStatus2nd(a0)	; cancel speed shoes

	if ~~AmbienceMode
		moveq	#0,d0
		jmp		(Change_Music_Tempo).w			; run music at normal speed (flamedriver change)
	endif

	.exit:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	record Sonic's previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RecordPosition:
		move.w	(v_trackpos).w,d0
		lea		(v_tracksonic).w,a1
		lea		(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,(v_trackbyte).w
		rts	
; End of function Sonic_RecordPosition
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Water:
		cmpi.b	#id_LZ,(v_zone).w					; is level LZ?
		beq.s	.islabyrinth						; if yes, branch

.exit:
		rts	
; ===========================================================================

.islabyrinth:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0							; is Sonic above the water?
		bge.s	.abovewater							; if yes, branch
		bset	#staWater,obStatus(a0)
		bne.s	.exit
		bsr.w	ResumeMusic
		move.b	#id_DrownCount,(v_sonicbubbles).w	; load bubbles object from Sonic's mouth
		move.b	#$81,(v_sonicbubbles+obSubtype).w
		lea     (v_sonspeedmax).w,a2				; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings					; Fetch Speed settings
		asr		obVelX(a0)
		asr		obVelY(a0)
		asr		obVelY(a0)							; slow Sonic
		beq.s	.exit								; branch if Sonic stops moving
		move.b	#id_Splash,(v_splash).w				; load splash object
		move.w	#sfx_Splash,d0
		jmp		(QueueSound2).w						; play splash sound
; ===========================================================================

.abovewater:
		bclr	#staWater,obStatus(a0)
		beq.s	.exit
		bsr.w	ResumeMusic
		lea     (v_sonspeedmax).w,a2				; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings					; Fetch Speed settings
		asl		obVelY(a0)
		beq.w	.exit
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
		bsr.w	Sonic_ChkAirRoll		; Contains truncated JumpHeight code
	else
		bsr.w	Sonic_JumpHeight
	endif
		bsr.w	Sonic_JumpDirection
		bsr.w	Sonic_LevelBound
		jsr		(ObjectFall).l
		btst	#staWater,obStatus(a0)
		beq.s	loc_12E5C
		subi.w	#$28,obVelY(a0)

loc_12E5C:
		bsr.w	Sonic_JumpAngle
		bra.w	Sonic_Floor
; ===========================================================================

Sonic_MdRoll:
	; in a ball, not in the air
	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0)
		bne.s	.skip
		bsr.w	Sonic_Jump

.skip:
	else
		bsr.w	Sonic_Jump
	endif
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
		btst	#staWater,obStatus(a0)
		beq.s	loc_12EA6
		subi.w	#$28,obVelY(a0)

loc_12EA6:
		bsr.w	Sonic_JumpAngle
		bra.w	Sonic_Floor
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_slidemode).w
		bne.w	Sonic_Traction
		tst.b	obLRLock(a0)
		bne.w	Sonic_ResetScr
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_MoveLeft

.notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	.notright				; if not, branch
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
		btst	#staOnObj,obStatus(a0)	; is Sonic on an object?
		beq.s	Sonic_Balance
	; RetroKoH obPlatform SST mod
		movea.w	obPlatformAddr(a0),a1
		adda.l	#v_ram_start,a1			; a1 = object being stood upon
	; obPlatform SST mod end
		tst.b	obStatus(a1)
		bmi.w	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.w	SuperSonic_Balance
	endif

		cmpi.w	#4,d1

	if CDBalancing
		blt.s	Sonic_BalanceLeft
		cmp.w	d2,d1
		bge.s	Sonic_BalanceRight
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
		btst	#staFacing,obStatus(a0)		; is Sonic facing left?	;Mercury Constants
		beq.s	Sonic_BalanceBackward		; if not, balance backward
		move.b	#aniID_Balance2,obAnim(a0)	; use forward balancing animation
		bra.w	Sonic_ResetScr				; branch

Sonic_BalanceRight:
		btst	#staFacing,obStatus(a0)		; is Sonic facing left?	;Mercury Constants
		bne.s	Sonic_BalanceBackward		; if so, balance backward
		move.b	#aniID_Balance2,obAnim(a0)	; use forward balancing animation
		bra.w	Sonic_ResetScr				; branch

Sonic_BalanceBackward:
		move.b	#aniID_Balance3,obAnim(a0)	; use backward balancing animation
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
		bra.w	Sonic_Lookup
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

;Sonic_BalanceRight:
		cmpi.b	#3,obFrontAngle(a0)
		bne.s	Sonic_BalanceLeft

Sonic_BalanceOnObjRight: ;loc_12F5A
		bclr	#staFacing,obStatus(a0)
		bra.s	Sonic_BalanceSetAnim
; ===========================================================================

Sonic_BalanceLeft:
		cmpi.b	#3,obRearAngle(a0)
		bne.s	Sonic_LookUp

Sonic_BalanceOnObjLeft: ;loc_12F6A
		bset	#staFacing,obStatus(a0)

Sonic_BalanceSetAnim:
		move.b	#aniID_Balance,obAnim(a0)	; use "balancing" animation
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
		btst	#bitUp,(v_jpadhold2).w		; is up being pressed?
		beq.s	Sonic_Duck					; if not, branch
		move.b	#aniID_LookUp,obAnim(a0)	; use "looking up" animation

	if SpinDashEnabled		; S2 Scroll Delay -- Spin Dash Enabled
		addq.b	#1,(v_scrolldelay).w		; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w		; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset				; if not, skip ahead without looking up
		move.b	#120,(v_scrolldelay).w 		; move the scroll delay value into the scroll timer so it won't continue to count higher
	endif	; S2 Scroll Delay -- Spin Dash Enabled End

		; Mercury Look Shift Fix
		move.w	(v_screenposy).w,d0		; get camera top coordinate
		sub.w	(v_limittop2).w,d0		; subtract zone's top bound from it
		add.w	(v_lookshift).w,d0		; add default offset
		cmpi.w	#$C8,d0					; is offset <= $C8?
		ble.s	.skip					; if so, branch
		move.w	#$C8,d0					; set offset to $C8
		
	.skip:
		cmp.w	(v_lookshift).w,d0
		ble.s	Sonic_UpdateSpeedOnGround
		; Look Shift Fix end
		addq.w	#2,(v_lookshift).w
		bra.s	Sonic_UpdateSpeedOnGround
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s	Sonic_ResetScr			; if not, branch
		move.b	#aniID_Duck,obAnim(a0)		; use "ducking" animation

	if SpinDashEnabled		; S2 Scroll Delay -- Spin Dash Enabled
		addq.b	#1,(v_scrolldelay).w		; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w		; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset				; if not, skip ahead without looking down
		move.b	#120,(v_scrolldelay).w 		; move the scroll delay value into the scroll timer so it won't continue to count higher
	endif	; S2 Scroll Delay -- Spin Dash Enabled End

		; Mercury Look Shift Fix
		move.w	(v_screenposy).w,d0		; get camera top coordinate
		sub.w	(v_limitbtm2).w,d0		; subtract zone's bottom bound from it (creating a negative number)
		add.w	(v_lookshift).w,d0		; add default offset
		cmpi.w	#8,d0					; is offset > 8?
		bgt.s	.skip					; if greater than 8, branch
		move.w	#8,d0					; set offset to 8

	.skip:
		cmp.w	(v_lookshift).w,d0
		bge.s	Sonic_UpdateSpeedOnGround
		; Look Shift Fix End
		subq.w	#2,(v_lookshift).w
		bra.s	Sonic_UpdateSpeedOnGround
; ===========================================================================

Sonic_ResetScr:
	if SpinDashEnabled		; S2 Scroll Delay -- Spin Dash Enabled
		move.b	#0,(v_scrolldelay).w	; clear the scroll timer, because up/down are not being held

Sonic_LookReset:	; added branch point that the new scroll delay code skips ahead to
	endif
		cmpi.w	#$60,(v_lookshift).w		; is screen in its default position?
		beq.s	Sonic_UpdateSpeedOnGround	; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,(v_lookshift).w			; move screen back to default

loc_12FBE:
		subq.w	#2,(v_lookshift).w			; move screen back to default

Sonic_UpdateSpeedOnGround: ;loc_12FC2:
; No need to update Super Sonic's d5 value here due to ApplySpeedSettings.
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0				; is left/right	pressed?
		bne.s	Sonic_Traction				; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	Sonic_Traction
		bmi.s	Sonic_SettleLeft

; slow down when facing right and not pressing a direction
		sub.w	d5,d0
		bcc.s	loc_12FDC
		clr.w	d0

loc_12FDC:
		move.w	d0,obInertia(a0)
		bra.s	Sonic_Traction
; ===========================================================================
; slow down when facing left and not pressing a direction
Sonic_SettleLeft: ;loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		clr.w	d0

loc_12FEA:
		move.w	d0,obInertia(a0)

; increase or decrease speed on the ground
Sonic_Traction: ;loc_12FEE:

	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0) 	
		bne.s	loc_1300C
	endif

		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

; stops Sonic from running through walls that meet the ground
loc_1300C:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307C
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

loc_13060:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_13066:
		sub.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

loc_13078:
		add.w	d1,obVelY(a0)

locret_1307C:
		rts	
; End of function Sonic_Move
; ===========================================================================

Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_13086
		bpl.s	loc_130B2

loc_13086:
		bset	#staFacing,obStatus(a0)
		bne.s	loc_1309A
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obPrevAni(a0) ; restart Sonic's animation

loc_1309A:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6

	if ~~GroundSpeedCapEnabled ; Mercury Disable Ground Speed Cap
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_130A6
	endif	; Disable Ground Speed Cap End

		move.w	d1,d0

loc_130A6:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_130B2:
		sub.w	d4,d0
		bcc.s	loc_130BA
		move.w	#-$80,d0

loc_130BA:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#aniID_Stop,obAnim(a0)	; use "stopping" animation
		bclr	#staFacing,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr		(QueueSound2).w	; play stopping sound

	if SkidDustEnabled
		cmpi.b	#$C,(v_air)
		bcs.s	locret_130E8			; if he's drowning, branch to not make dust
		move.b	#6,(v_playerdust+obRoutine).w
	endif

locret_130E8:
		rts	
; End of function Sonic_MoveLeft
; ===========================================================================

Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_13118
		bclr	#staFacing,obStatus(a0)
		beq.s	loc_13104
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obPrevAni(a0) ; restart Sonic's animation

loc_13104:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310C

	if ~~GroundSpeedCapEnabled ; Mercury Disable Ground Speed Cap
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_1310C
	endif	;end Disable Ground Speed Cap

		move.w	d6,d0

loc_1310C:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_13118:
		add.w	d4,d0
		bcc.s	loc_13120
		move.w	#$80,d0

loc_13120:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#aniID_Stop,obAnim(a0) ; use "stopping" animation
		bset	#staFacing,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr		(QueueSound2).w	; play stopping sound

	if SkidDustEnabled
		cmpi.b	#$C,(v_air)
		bcs.s	locret_1314E			; if he's drowning, branch to not make dust
		move.b	#6,(v_playerdust+obRoutine).w
	endif

locret_1314E:
		rts	
; End of function Sonic_MoveRight
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6

	; MoDule Super Sonic Roll Speed fix
		moveq	#6,d5	; natural roll deceleration = 1/2 normal acceleration
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
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_131CC
		tst.b	obLRLock(a0)
		bne.s	.notright
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_RollLeft

.notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_RollRight

.notright:
		move.w	obInertia(a0),d0
		beq.s	loc_131AA
		bmi.s	loc_1319E
		sub.w	d5,d0
		bcc.s	loc_13198
		clr.w	d0

loc_13198:
		move.w	d0,obInertia(a0)
		bra.s	loc_131AA
; ===========================================================================

loc_1319E:
		add.w	d5,d0
		bcc.s	loc_131A6
		clr.w	d0

loc_131A6:
		move.w	d0,obInertia(a0)

loc_131AA:
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.s	loc_131CC				; if yes, branch

	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0)
		bne.s	Sonic_KeepRolling
	endif

		bclr	#staSpin,obStatus(a0)
		move.w	#$1309,obHeight(a0)		; Height and Width
		move.b	#aniID_Wait,obAnim(a0)	; use "standing" animation
		subq.w	#5,obY(a0)

	if SpinDashEnabled
		bra.s	loc_131CC
; ===========================================================================

; DeltaWooloo: This part is from Sonic 2
Sonic_KeepRolling:
		move.w	#$400,obInertia(a0)
		btst	#staFacing,obStatus(a0)
		beq.s	loc_131CC
		neg.w	obInertia(a0)
	endif

loc_131CC:
	; Mercury Screen Scroll While Rolling Fix
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.cont2
		bcc.s	.cont1
		addq.w	#4,(v_lookshift).w

.cont1:
		subq.w	#2,(v_lookshift).w

.cont2:
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
	endif

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

		bra.w	loc_1300C
; End of function Sonic_RollSpeed
; ===========================================================================

Sonic_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_1320A
		bpl.s	loc_13218

loc_1320A:
		bset	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0)	; use "rolling" animation
		rts	
; ===========================================================================

loc_13218:
		sub.w	d4,d0
		bcc.s	loc_13220
		clr.w	d0				; Mercury Rolling Turn Around Fix

loc_13220:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollLeft
; ===========================================================================

Sonic_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_1323A
		bclr	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

loc_1323A:
		add.w	d4,d0
		bcc.s	loc_13242
		clr.w	d0				; Mercury Rolling Turn Around Fix

loc_13242:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollRight
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpDirection:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		asl.w	#1,d5
		btst	#staRollJump,obStatus(a0)	; is Sonic locked by a rolling jump?
		bne.s	Obj01_ResetScr2				; if yes, branch
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadhold2).w		; is left being pressed?
		beq.s	loc_13278					; if not, branch
		bset	#staFacing,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_13278

	if ~~AirSpeedCapEnabled ; Mercury Disable Air Speed Cap
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_13278
	endif	; Disable Air Speed Cap End

		move.w	d1,d0

loc_13278:
		btst	#bitR,(v_jpadhold2).w		; is right being pressed?
		beq.s	Obj01_JumpMove				; if not, branch
		bclr	#staFacing,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	Obj01_JumpMove

	if ~~AirSpeedCapEnabled ; Mercury Disable Air Speed Cap
		sub.w d5,d0
		cmp.w d6,d0
		bge.s Obj01_JumpMove
	endif	; Disable Air Speed Cap End

		move.w	d6,d0

Obj01_JumpMove:
		move.w	d0,obVelX(a0)				; change Sonic's horizontal speed

Obj01_ResetScr2:
		cmpi.w	#$60,(v_lookshift).w		; is the screen in its default position?
		beq.s	loc_132A4					; if yes, branch
		bcc.s	loc_132A0
		addq.w	#4,(v_lookshift).w

loc_132A0:
		subq.w	#2,(v_lookshift).w

loc_132A4:
		cmpi.w	#-$400,obVelY(a0)			; is Sonic moving faster than -$400 upwards?
		blo.s	locret_132D2				; if yes, branch
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_132D2
		bmi.s	loc_132C6
		sub.w	d1,d0
		bcc.s	loc_132C0
		clr.w	d0

loc_132C0:
		move.w	d0,obVelX(a0)
		rts	
; ===========================================================================

loc_132C6:
		sub.w	d1,d0
		bcs.s	loc_132CE
		clr.w	d0

loc_132CE:
		move.w	d0,obVelX(a0)

locret_132D2:
		rts	
; End of function Sonic_JumpDirection
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

	; flamewing Left Boundary Zip Fix
Sonic_LevelBound:
		moveq	#0,d2			; +++ clear d2 for use
		move.l	obX(a0),d1
		smi.b	d2				; +++ set d2 if player on position > 32767
		add.w	d2,d2			; +++ move bit up
		move.w	obVelX(a0),d0
		spl.b	d2				; +++ set if speed is positive
		add.w	d2,d2			; +++ move bit up
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		spl.b	d2				; +++ set if position+speed is < 32768
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		tst.w	d2				; +++ if d2 is zero, we had an underflow of position
		beq.s	.sides
		cmp.w	d1,d0			; has Sonic touched the left side boundary?
		bhi.s	.sides			; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	.screenlocked
		addi.w	#$40,d0

.screenlocked:
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.s	.sides		; if yes, branch

.chkbottom:
		move.w	(v_limitbtm2).w,d0
	; RetroKoH Bottom Boundary Fix
		cmp.w	(v_limitbtm1).w,d0	; is the intended bottom boundary lower than the current one?
		bcc.s	.notlower			; if not, branch
		move.w	(v_limitbtm1).w,d0	; d0 = intended bottom boundary
.notlower:
	; Bottom Boundary Fix End
		addi.w	#224,d0
		cmp.w	obY(a0),d0	; has Sonic touched the	bottom boundary?
		blt.s	.bottom		; if yes, branch
		rts	
; ===========================================================================

.bottom:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w	; is level SBZ2 ?
		bne.s	.killsonic					; if not, kill Sonic	; MJ: Fix out-of-range branch
		cmpi.w	#$2000,(v_player+obX).w
		bcs.s	.killsonic					; MJ: Fix out-of-range branch
		clr.b	(v_lastlamp).w				; clear	lamppost counter
		move.b	#1,(f_restart).w			; restart the level
		move.w	#(id_LZ<<8)+3,(v_zone).w	; set level to SBZ3 (LZ4)
		rts	
; ===========================================================================

.sides:
		move.w	d0,obX(a0)
		moveq	#0,d3
		move.w	d3,obX+2(a0)				; clear subpixel (for alignment)
		move.w	d3,obVelX(a0)				; stop Sonic moving
		move.w	d3,obInertia(a0)			; clear ground inertia
		bra.s	.chkbottom
; ===========================================================================

.killsonic:
		jmp		(KillSonic).l
; End of function Sonic_LevelBound
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Roll:
		tst.b	(f_slidemode).w
		bne.s	.noroll

; Rewritten to match S3K
	; Check controls first
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0			; is left/right	being pressed?
		bne.s	.noroll					; if yes, branch
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s	Sonic_ChkWalk			; if not, branch and exit

	; Check speeds and roll if fast enough
		move.w	obInertia(a0),d0
		bpl.s	.ispositive
		neg.w	d0

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
		bne.s	.ret
		move.b	#aniID_Walk,obAnim(a0)	; if so, enter walking animation
.ret
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
		move.w	#$E07,obHeight(a0)				; Height and Width
		move.b	#aniID_Roll,obAnim(a0)			; use "rolling" animation
		move.b	#fr_SonRoll1,obFrame(a0)		; hard sets frame so no flicker when roll in tunnels - Mercury Roll Frame Fix

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.notsuper
		move.b	#fr_SupSonRoll1,obFrame(a0)		; hard sets frame so no flicker when roll in tunnels - Mercury Roll Frame Fix

	.notsuper:
	endif

		addq.w	#5,obY(a0)						; Add to y-pos the difference in height radius
		move.w	#sfx_Roll,d0
		jsr		(QueueSound2).w					; play rolling sound
		tst.w	obInertia(a0)
		bne.s	.ismoving
		move.w	#$200,obInertia(a0) 			; set inertia if 0

.ismoving:
		rts	
; End of function Sonic_Roll
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0				; is A, B or C pressed?
		beq.w	.end			; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1					; does Sonic have enough room to jump?
		blt.w	.end			; if not, branch
		move.w	#$680,d2

	if SuperMod
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	#$800,d2				; set higher jump speed if super

	.notSuper:
	endif

		btst	#staWater,obStatus(a0)
		beq.s	.notinwater
		move.w	#$380,d2

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
		jsr		(QueueSound2).w		; play jumping sound
	; Removed code expanding Sonic's radius -- RetroKoH Rolling Jump Fix
		tst.b	(f_victory).w				; has the victory animation flag been set?
		bne.s	.victoryleap				; if yes, branch

		btst	#staSpin,obStatus(a0)		; Is Sonic already in a ball?
		bne.s	.rolljumplock
	; If not already in a ball, convert Sonic into a ball
		move.w	#$E07,obHeight(a0)			; Height and Width
		move.b	#aniID_Roll,obAnim(a0)		; use "jumping" animation
		bset	#staSpin,obStatus(a0)
		addq.w	#5,obY(a0)

	.end:
		rts	
; ===========================================================================

	.victoryleap:
		move.b	#aniID_VictoryLeap,obAnim(a0)	; use the "victory leaping" animation
		rts
; ===========================================================================

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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:
		tst.b	obJumping(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#staWater,obStatus(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	obVelY(a0),d1
		ble.s	Sonic_DoubleJump
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		bne.s	locret_134C2		; if yes, branch
		move.w	d1,obVelY(a0)

locret_134C2:
		rts	
; ===========================================================================

loc_134C4:
	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0)	; is Sonic charging his spin dash?
		bne.w	locret_134D2		; if yes, branch
	endif
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,obVelY(a0)

locret_134D2:
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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChkDropDash:
		cmpi.b	#3,obDoubleJumpFlag(a0)		; was the Drop Dash cancelled?
		beq.s	.ret						; if yes, branch
		move.b	obStatus2nd(a0),d0
		btst	#sta2ndInvinc,d0			; is Sonic invincible OR Super?
		bne.s	.skipshieldcheck			; if yes, enable Drop Dash
		andi.b	#mask2ndChkElement,d0		; does Sonic have any elemental shields?
		bne.s	.ret						; if yes, exit

.skipshieldcheck:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0					; is A, B or C held down?
		beq.s	.reset						; if no, branch
		addq.b	#1,obDoubleJumpProp(a0)		; increment charge timer
		cmpi.b	#$14,obDoubleJumpProp(a0)	; is the Drop Dash fully charged? (20 frames)
		blt.s	.ret						; if not yet, exit
		bgt.s	.skipsound					; if yes, and sound has played, skip ahead
		move.b	#aniID_DropDash,obAnim(a0)	; Set new animation
		move.w	#sfx_DropDash,d0
		jsr		(QueueSound2).w				; play charge sound

.skipsound:
		move.b	#$15,obDoubleJumpProp(a0)	; set to cap + 1 so we only play the sound once
		rts

.reset:
		move.b	#3,obDoubleJumpFlag(a0)		; disable attempting the Drop Dash (Remove this to allow repeated attempts (toggle?)
		clr.b	obDoubleJumpProp(a0)
		move.b	#aniID_Roll,obAnim(a0)		; reset to rolling animation

.ret:
		rts
; End of function Sonic_ChkDropDash
; ===========================================================================
	endif
	
	if SuperMod
; ---------------------------------------------------------------------------
; Subroutine for Sonic to transform in Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


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
; Added for S3K Shields and Drop Dash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Reset_Sonic_Position_Array:
		move.w	obX(a0),d1
		swap	d1						; move obX to the upper word -- RetroKoH optimization
		move.w	obY(a0),d1				; move obY to the lower word -- RetroKoH optimization
		lea		(v_tracksonic).w,a1
		move.w	#$3F,d0

loc_10DEC:
		move.l	d1,(a1)+				; move obX and obY to v_tracksonic -- RetroKoH optimization
		dbf		d0,loc_10DEC
		clr.w	(v_trackpos).w
		rts
; End of function Reset_Sonic_Position_Array
; ===========================================================================
	endif
		
	if AirRollEnabled
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to curl up in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_ChkAirRoll:
	if SpinDashEnabled
		tst.b	obSpinDashFlag(a0)		; is Sonic charging his spin dash?
		bne.w	.end					; if yes, branch
	endif

		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0				; are buttons A, B, or C being pressed?
		beq.s	.noAirRoll				; if not, branch
		
; Air Roll
		bset	#staSpin,obStatus(a0)	; set spin status
		move.w	#$E07,obHeight(a0)		; Height and Width
		move.b	#aniID_Roll,obAnim(a0)	; enter rolling animation

	if (S3KDoubleJump|AirRollIntoDropDash)
		move.b	#2,obDoubleJumpFlag(a0)	; disable shield abilities and/or enable Drop Dash transition

	if AirRollIntoDropDash
		move.b	#1,obJumping(a0)		; enable this for potential drop dash transition
	endif

	endif

		move.w	#sfx_Roll,d0
		jsr		(QueueSound2).w			; play rolling sound

.noAirRoll:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	.end
		move.w	#-$FC0,obVelY(a0)

.end:
		rts	
; End of function Sonic_ChkAirRoll
; ===========================================================================
	endif
	
	if PeeloutEnabled
; ---------------------------------------------------------------------------
; Subroutine to check for starting to perform a peelout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChkPeelout:
		btst	#1,obSpinDashFlag(a0) ; obSpinDashFlag is also used for Peelout
		bne.s	Sonic_DashLaunch
		cmpi.b	#aniID_LookUp,obAnim(a0)
		bne.s	.return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	.return
		move.b	#aniID_Run,obAnim(a0)
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

Sonic_DashLaunch:
		move.b	#aniID_Peelout,obAnim(a0)
		move.b	(v_jpadhold2).w,d0
		btst	#bitUp,d0
		bne.w	Sonic_DashCharge

		clr.b	obSpinDashFlag(a0)			; stop Dashing
		cmpi.w	#$1E,obSpinDashCounter(a0)	; have we been charging long enough?
		bne.s	Sonic_DashStopSound
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
		bra.w	Sonic_DashResetScr
; ===========================================================================

Sonic_DashCharge:				; If still charging the dash...
		cmpi.w	#$1E,obSpinDashCounter(a0)
		beq.s	Sonic_DashResetScr
		addi.w	#1,obSpinDashCounter(a0)
		bra.s	Sonic_DashResetScr

Sonic_DashStopSound:
		move.w	#sfx_Stop,d0
		jsr		(QueueSound2).w
		clr.w	obInertia(a0)

Sonic_DashResetScr:
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
	
	if SpinDashEnabled
; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChkSpinDash:
		btst	#0,obSpinDashFlag(a0)	; already Spin Dashing?
		bne.s	Sonic_UpdateSpinDash	; if yes, branch to updating spin dash
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	.return					; if not ducking down, return
		move.b	(v_jpadpress2).w,d0
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
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.w	Sonic_ChargingSpinDash

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
	; RHS/Esrael Boundary Spindash bugfix
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
	; Boundary Spindash bugfix end
		bra.w	SpinDash_ResetScr
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

Sonic_ChargingSpinDash:				; If still charging the dash...
		tst.w	obSpinDashCounter(a0)
		beq.s	loc_1AD48
		
	if SpinDashNoRevDown ; Mercury Spin Dash No Rev Down
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0
		bne.s	loc_1AD48	
	endif	; Spin Dash No Rev Down end

		move.w	obSpinDashCounter(a0),d0
		lsr.w	#5,d0
		sub.w	d0,obSpinDashCounter(a0)	; SpinDash rev down effect applied
		
	if SpinDashCancel	; Mercury Spin Dash Cancel
		cmpi.w	#$1F,obSpinDashCounter(a0)
		bne.s	.skip
		clr.w	obSpinDashCounter(a0)		; clear SpinDash Counter
		clr.b	obSpinDashFlag(a0)			; cancel SpinDash
		bra.s	SpinDash_ResetScr					; branch
		
.skip:
	endif	; Spin Dash Cancel End	

		bcc.s	loc_1AD48
		clr.w	obSpinDashCounter(a0)

loc_1AD48:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	SpinDash_ResetScr
		;move.w	#(id_SpinDash<<8),obAnim(a0)	; id_SpinDash
		addi.w	#$200,obSpinDashCounter(a0)
		cmpi.w	#$800,obSpinDashCounter(a0)
		bcs.s	.sound
		move.w	#$800,obSpinDashCounter(a0)
.sound:
		move.w	#sfx_SpinDash,d0				; sfx_SpinDash
		jsr		(QueueSound2).w

SpinDash_ResetScr:
		addq.l	#4,sp							; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	loc_1AD8C
		bcc.s	loc_1AD88
		addq.w	#4,(v_lookshift).w

loc_1AD88:
		subq.w	#2,(v_lookshift).w

loc_1AD8C:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos
; ===========================================================================
	endif

; ---------------------------------------------------------------------------
; Subroutine to	slow Sonic walking up a	slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bhs.s	locret_13508
		move.b	obAngle(a0),d0
		jsr	(CalcSine).w
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	locret_13508
		bmi.s	loc_13504
		tst.w	d0
		beq.s	locret_13502
		add.w	d0,obInertia(a0) ; change Sonic's inertia

locret_13502:
		rts	
; ===========================================================================

loc_13504:
		add.w	d0,obInertia(a0)

locret_13508:
		rts
; End of function Sonic_SlopeResist
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope	while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#-$40,d0
		bhs.s	locret_13544
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	loc_1353A
		tst.w	d0
		bpl.s	loc_13534
		asr.l	#2,d0

loc_13534:
		add.w	d0,obInertia(a0)
		rts	
; ===========================================================================

loc_1353A:
		tst.w	d0
		bmi.s	loc_13540
		asr.l	#2,d0

loc_13540:
		add.w	d0,obInertia(a0)

locret_13544:
		rts	
; End of function Sonic_RollRepel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeRepel:
		nop	
		tst.b	obOnWheel(a0)
		bne.s	.return
		tst.b	obLRLock(a0)
		bne.s	.locked
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.return
		move.w	obInertia(a0),d0
		bpl.s	.noflip
		neg.w	d0

.noflip:
		cmpi.w	#$280,d0
		bhs.s	.return
		clr.w	obInertia(a0)
		bset	#staAir,obStatus(a0)
		move.b	#$1E,obLRLock(a0)

.return:
		rts	
; ===========================================================================

.locked:
		subq.b	#1,obLRLock(a0)
		rts	
; End of function Sonic_SlopeRepel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAngle:
		move.b	obAngle(a0),d0	; get Sonic's angle
		beq.s	locret_135A2	; if already 0,	branch
		bpl.s	loc_13598		; if higher than 0, branch

		addq.b	#2,d0			; increase angle
		bcc.s	loc_13596
		moveq	#0,d0

loc_13596:
		bra.s	loc_1359E
; ===========================================================================

loc_13598:
		subq.b	#2,d0			; decrease angle
		bcc.s	loc_1359E
		moveq	#0,d0

loc_1359E:
		move.b	d0,obAngle(a0)

locret_135A2:
		rts	
; End of function Sonic_JumpAngle
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Floor:
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
		bpl.s	.airCol_PositiveY						; If it's positive, branch
		cmp.w	d0,d1									; Are we moving towards the left?
		bgt.w	Sonic_AirMode_LeftWall					; If so, branch
		neg.w	d0										; Are we moving towards the right?
		cmp.w	d0,d1
		bge.w	Sonic_AirMode_RightWall					; If so, branch
		bra.w	Sonic_AirMode_Ceiling					; We are moving upwards
 
.airCol_PositiveY:
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
		clr.w	obVelX(a0)

	.chkRightWall:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkFloor
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkFloor:
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_1367E
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361E
		cmp.b	d2,d0
		blt.s	locret_1367E

loc_1361E:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		;bsr.w	Sonic_ResetOnFloor			; Moved to loc_1364E -- Fix Bubble Bounce
		move.b	#aniID_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr		obVelY(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved from loc_1361E -- Fix Bubble Bounce
; ===========================================================================

loc_1365C:
		clr.w	obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670
		move.w	#$FC0,obVelY(a0)

loc_13670:
	; This might need to be fixed
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	.reset
		neg.w	obInertia(a0)
	
	.reset:
		bra.w	Sonic_ResetOnFloor			; Added -- Fix Bubble Bounce

locret_1367E:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Left Wall Mode if moving mostly left
; ---------------------------------------------------------------------------

Sonic_AirMode_LeftWall: ;loc_13680:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkCeiling
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.chkFloor
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	.ret
		clr.w	obVelY(a0)

	.ret:
		rts	
; ===========================================================================

.chkFloor:
		tst.w	obVelY(a0)
		bmi.s	.end
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.end
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		;bsr.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce

	.end:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Ceiling Mode if moving upwards
; ---------------------------------------------------------------------------

Sonic_AirMode_Ceiling: ;loc_136E2:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkRightWall
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkRightWall:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkCeiling
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.ret
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	.latchToCeiling
		clr.w	obVelY(a0)
		rts	
; ===========================================================================

	.latchToCeiling:
	; Might need to be fixed
		move.b	d3,obAngle(a0)
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	.reset
		neg.w	obInertia(a0)
	
	.reset:
		bra.w	Sonic_ResetOnFloor

	.ret:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Right Wall Mode if moving mostly right
; ---------------------------------------------------------------------------

Sonic_AirMode_RightWall: ;loc_1373E:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkCeiling
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.chkFloor
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	.ret
		clr.w	obVelY(a0)

	.ret:
		rts	
; ===========================================================================

	.chkFloor:
		tst.w	obVelY(a0)
		bmi.s	.end
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.end
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		;bsr.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce

	.end:
		rts	
; End of function Sonic_Floor
; ===========================================================================

	if CDCamera
; ---------------------------------------------------------------------------
; Subroutine to horizontally pan the camera view ahead of the player
; (Ported from the US version of Sonic CD's "R11A__.MMD" by Naoto)
; Credit: Wooloo Engine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:
		andi.b	#~(maskAir+maskRollJump+maskPush),obStatus(a0)	; Should clear Air, RollJump and Push bits ($CD)
		move.b	#aniID_Walk,obAnim(a0)			; use running/walking animation -- Hame Animation Reset Fix
		clr.b	obJumping(a0)
		clr.w	(v_itembonus).w
		btst	#staSpin,obStatus(a0)			; is Sonic spinning?
		beq.s	.ret							; if not, branch
	; If Sonic is spinning upon landing
		move.w	#$1309,obHeight(a0)				; Height and Width
		bclr	#staSpin,obStatus(a0)
		subq.w	#5,obY(a0)						; move Sonic up 5 pixels so the increased height doesn't push him into the ground

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

; =============== S U B R O U T I N E =======================================


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
		jsr		CalcSine
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
; Modified (possibly fixed) thanks to Giovanni
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================


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
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		bne.s	.dropLeft				; if yes, branch	
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
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
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Hurt_Normal		; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Sonic_Hurt_Normal		; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Hurt_Normal:
	; Debug Mode Addition End

	if SpinDashEnabled
		clr.b	(v_cameralag).w			; Spin Dash Enabled
	endif

		jsr		(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#staWater,obStatus(a0)
		beq.s	loc_1380C
		subi.w	#$20,obVelY(a0)

loc_1380C:
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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HurtStop:
		; Lines omitted -- Mercury Top Boundary Fix
		bsr.w	Sonic_Floor
		btst	#staAir,obStatus(a0)
		bne.s	locret_13860
		clr.w	obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,obInvuln(a0)	; RetroKoH Sonic SST Compaction

locret_13860:
		rts	
; End of function Sonic_HurtStop
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Sonic_Death:	; Routine 6
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Death_Normal		; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Sonic_Death_Normal		; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Death_Normal:
	; Debug Mode Addition End

	if SpinDashEnabled
		clr.b	(v_cameralag).w			; Spin Dash Enabled
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

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GameOver:
		move.w	(v_screenposy).w,d0	; MarkeyJester Game/Time Over Timing Fix
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	.end				; MarkeyJester Game/Time Over Timing Fix
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w		; stop time counter

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
		beq.s	locret_13914
		subq.b	#1,obRestartTimer(a0)	; subtract 1 from time delay
		bne.s	locret_13914
		move.b	#1,(f_restart).w ; restart the level

locret_13914:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Sonic when he's drowning -- RHS Drowning Fix
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Drowned:
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Drowned_Normal	; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
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
; Subroutine to	make Sonic spin in tunnels (GHZ/SLZ)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Loops:
	; Loops are no longer handled here, only the windtunnels. Loops are now handled by pathswappers.
	; To-Do: Add Forced Roll object from Sonic 2, and remove this subroutine entirely.
		tst.b	(v_zone).w			; is level GHZ ?
		bne.w	.noloops			; if not, branch

;.isstarlight:
		move.w	obY(a0),d0			; MJ: Load Y position
		move.w	obX(a0),d1			; MJ: Load X position
		andi.w	#$780,d0			; MJ: keep Y position within 800 pixels (in multiples of 80)
		add.w	d0,d0				; MJ: multiply by 2 (Because every 80 bytes switch from FG to BG..)
		lsr.w	#7,d1				; MJ: divide X position by 80 (00 = 0, 80 = 1, etc)
		andi.w	#$7F,d1				; MJ: keep within 4000 pixels (4000 / 80 = 80)
		add.w	d1,d0				; MJ: add together
		lea		(v_lvllayout).w,a1	; MJ: Load address of layout
		move.b	(a1,d0.w),d1		; MJ: collect correct 128x128 chunk ID based on the position of Sonic

		lea		STunnel_Chunks_End(pc),a2					; MJ: lead list of S-Tunnel chunks
		moveq	#(STunnel_Chunks_End-STunnel_Chunks)-1,d2	; MJ: get size of list

	.loop:
		cmp.b	-(a2),d1			; MJ: is the chunk an S-Tunnel chunk?
		dbeq	d2,.loop			; MJ: check for each listed S-Tunnel chunk
		beq.w	Sonic_ChkRoll		; MJ: if so, branch

	.noloops:
		rts	
; End of function Sonic_Loops

; ===========================================================================

STunnel_Chunks:		; MJ: list of S-Tunnel chunks
		dc.b	$75,$76,$77,$78
		dc.b	$79,$7A,$7B,$7C
STunnel_Chunks_End
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


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
		move.b	d0,obPrevAni(a0)
		clr.b	obAniFrame(a0)			; reset animation
		clr.b	obTimeFrame(a0)			; reset frame duration
		bclr	#staPush,obStatus(a0)	; clear pushing flag -- Mercury Pushing While Walking Fix

	.do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1			; jump to appropriate animation	script
		move.b	(a1),d0
		bmi.s	.walkrunroll			; if animation is walk/run/roll/jump, branch
		moveq	#maskFacing,d1
		and.b	obStatus(a0),d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
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
		and.b	obStatus(a0),d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
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
		and.b	obStatus(a0),d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	.loadframe
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
; Sonic	graphics loading subroutine (Mercury Use DMA Queue)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; d0 = Sonic's current frame number
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
		move.w	(a2)+,d5				; read "number of PLC entries" value						; S3K Changed from .b to .w
		subq.w	#1,d5					; decrement for .readentry loop
		bmi.s	.nochange				; if there are no entries, branch and exit
		move.w	#(ArtTile_Sonic*$20),d4	; d4 = Sonic's VRAM location

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