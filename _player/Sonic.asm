; ===========================================================================
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
Sonic_Modes:
		dc.w Sonic_MdNormal-Sonic_Modes
		dc.w Sonic_MdAir-Sonic_Modes
		dc.w Sonic_MdRoll-Sonic_Modes
		dc.w Sonic_MdJump-Sonic_Modes

	if SuperMod
		include	"_player/Sonic Super.asm"
	endif
		include	"_player/Sonic Display.asm"
		include	"_player/Sonic RecordPosition.asm"
		include	"_player/Sonic Water.asm"

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