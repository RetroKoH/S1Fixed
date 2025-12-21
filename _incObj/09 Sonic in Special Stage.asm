; ---------------------------------------------------------------------------
; Object 09 - Sonic (special stage)
; ---------------------------------------------------------------------------

SonicSpecial:
		tst.w	(v_debuguse).w					; is debug mode	being used?
		beq.s	SpSon_Normal					; if not, branch
		bsr.w	SS_FixCamera					; center camera on Sonic
		bra.w	DebugMode_SS
; ===========================================================================

SpSon_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	SpSon_Index(pc,d0.w),d1
		jmp		SpSon_Index(pc,d1.w)
; ===========================================================================
SpSon_Index:	offsetTable
		offsetTableEntry.w	SpSon_Main
		offsetTableEntry.w	SpSon_Action
		offsetTableEntry.w	SpSon_ExitStage
		offsetTableEntry.w	SpSon_ExitWait
; ===========================================================================

SpSon_Main:		; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$E07,obHeight(a0)				; Height and Width
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager (Bumped to 1 to put it behind the cursor in Debug Mode)
		move.b	#aniID_Roll,obAnim(a0)
		bset	#staSpin,obStatus(a0)
		bset	#staAir,obStatus(a0)

SpSon_Action:	; Routine 2
		tst.w	(f_debugmode).w					; is debug mode	cheat enabled?
		beq.s	.not_debug						; if not, branch
		btst	#bitB,(v_jpadpressed_actual).w	; is button B pressed?
		beq.s	.not_debug						; if not, branch
		move.w	#1,(v_debuguse).w				; change Sonic into a special stage block

	.not_debug:
		clr.b	obSSSonic_SSItemID(a0)
	; LavaGaming/RetroKoH Object Routine Optimization
		btst	#staAir,obStatus(a0)			; Use current air state to determine Control Mode
		bne.s	SpSon_InAir
	; Object Routine Optimization End

SpSon_OnWall:
		bclr	#staSSJump,obStatus(a0)			; clear "Sonic has jumped" flag -- Mercury Fixed SS Jumping Physics

	if ~~S4SS_NoJump
		bsr.w	SpSon_Jump
	endif

		bsr.w	SpSon_Move
		bsr.w	SpSon_Fall
		bra.s	SpSon_Display
; ===========================================================================

SpSon_InAir:

	if ~~S4SS_NoJump
		bsr.w	SpSon_JumpHeight				; Mercury Fixed SS Jumping Physics
	endif

		bsr.w	SpSon_Move
		bsr.w	SpSon_Fall

SpSon_Display:
		bsr.w	SpSon_ChkItems_Nonsolid
		bsr.w	SpSon_ChkItems_Solid
		jsr		(SpeedToPos).l
		bsr.w	SS_FixCamera					; centre camera on Sonic

	if ~~S4SpecialStages
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0				; add rotation speed to angle
		move.w	d0,(v_ssangle).w				; update angle
	endif

		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		jmp		(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	move Sonic in the Special Stage by pressing left/right
; ---------------------------------------------------------------------------

SpSon_Move:
		move.b	(v_jpadheld_dup).w,d1
		btst	#bitL,d1						; is left being pressed?
		beq.s	.not_left						; if not, branch
		bsr.w	SpSon_MoveLeft

	.not_left:
		btst	#bitR,d1						; is right being pressed?
		beq.s	.not_right						; if not, branch
		bsr.w	SpSon_MoveRight

	.not_right:

		andi.b	#btnL+btnR,d1					; is left/right being pressed?
		bne.s	SpSon_UpdatePos					; if yes, branch

	; Apply friction
		move.w	obInertia(a0),d0				; get inertia
		beq.s	SpSon_UpdatePos					; branch if inertia == 0
		bmi.s	.is_negative					; branch if inertia < 0
		subi.w	#$C,d0							; decelerate
		bcc.s	.update_inertia					; branch if positive (after deceleration)
		moveq	#0,d0							; clear if negative (after deceleration)
		bra.s	.update_inertia
; ===========================================================================

	.is_negative:
		addi.w	#$C,d0							; decelerate
		bcc.s	.update_inertia					; branch if negative (after deceleration)
		moveq	#0,d0							; clear if positive (after addition)

	.update_inertia:
		move.w	d0,obInertia(a0)				; apply change to inertia

SpSon_UpdatePos:
		move.b	(v_ssangle).w,d0				; get stage angle
		addi.b	#$20,d0							; rotate angle 45 degrees (for wall/floor/ceiling detection)
		andi.b	#$C0,d0							; read only bits 7 and 6
		neg.b	d0
		jsr		(CalcSine).w					; convert to sine/cosine
		muls.w	obInertia(a0),d1
		add.l	d1,obX(a0)						; add (inertia*cosine) to x pos
		muls.w	obInertia(a0),d0
		add.l	d0,obY(a0)						; add (inertia*sine) to y pos
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		bsr.w	SpSon_FindWalls					; detect nearby walls
		beq.s	.no_collide						; if no walls are found, branch
		sub.l	d1,obX(a0)						; cancel position updates
		sub.l	d0,obY(a0)
		clr.w	obInertia(a0)					; stop Sonic

	.no_collide:
		rts	
; End of function SpSon_Move
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	move Sonic to the left in the Special Stage
; ---------------------------------------------------------------------------

SpSon_MoveLeft:
		bset	#staFacing,obStatus(a0)
	if ~~S4SpecialStages
		move.w	obInertia(a0),d0				; get inertia
		beq.s	.inertia_0						; branch if 0
		bpl.s	.inertia_positive				; branch if positive (moving right)

	.inertia_0:
		subi.w	#$C,d0							; accelerate
		cmpi.w	#-$800,d0
		bgt.s	.update_inertia
		move.w	#-$800,d0						; cap inertia

	.update_inertia:
		move.w	d0,obInertia(a0)
		rts
; ===========================================================================

	.inertia_positive:
		subi.w	#$40,d0
		bcc.s	.wait
		nop	

	.wait:
		move.w	d0,obInertia(a0)

	else
		move.w	(v_ssangle).w,d0
		sub.w	(v_ssrotate).w,d0				; subtract rotation speed to angle
		move.w	d0,(v_ssangle).w				; update angle
	endif
		rts
; End of function SpSon_MoveLeft
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	move Sonic to the right in the Special Stage
; ---------------------------------------------------------------------------

SpSon_MoveRight:
		bclr	#staFacing,obStatus(a0)
	if ~~S4SpecialStages
		move.w	obInertia(a0),d0				; get inertia
		bmi.s	.inertia_neg

		addi.w	#$C,d0							; accelerate
		cmpi.w	#$800,d0
		blt.s	.update_inertia
		move.w	#$800,d0						; cap inertia

	.update_inertia:
		move.w	d0,obInertia(a0)
		rts
; ===========================================================================

	.inertia_neg:
		addi.w	#$40,d0
		bcc.s	.wait
		nop	

	.wait:
		move.w	d0,obInertia(a0)

	else
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0				; add rotation speed to angle
		move.w	d0,(v_ssangle).w				; update angle
	endif
		rts
; End of function SpSon_MoveRight
; ===========================================================================

	if ~~S4SS_NoJump
; ---------------------------------------------------------------------------
; Subroutine to make Sonic jump in the Special Stage
; ---------------------------------------------------------------------------

SpSon_Jump:
		move.b	(v_jpadpressed_dup).w,d0
		andi.b	#btnABC,d0						; is A,	B or C pressed?
		beq.s	.no_jump						; if not, branch
		move.b	(v_ssangle).w,d0

	if ~~SmoothSpecialStages	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0							; round down to nearest 4
	endif

		neg.b	d0
		subi.b	#$40,d0
		jsr		(CalcSine).w					; convert to sine/cosine
		muls.w	#$680,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)					; apply jump power (6.5)
		muls.w	#$680,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)					; apply jump power (6.5)
		bset	#staAir,obStatus(a0)
		bset	#staSSJump,obStatus(a0)			; set "Sonic has jumped" flag -- Mercury Fixed SS Jumping Physics
		move.w	#sfx_Jump,d0
		jmp		(QueueSound2).w					; play jumping sound

	.no_jump:
		rts	
; End of function SpSon_Jump
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to limit Sonic's upward vertical speed when jumping
; ---------------------------------------------------------------------------

SpSon_JumpHeight:
	; Mercury Fixed SS Jumping Physics
		move.b	(v_jpadheld_dup).w,d0			; is the jump button up?
		andi.b	#btnABC,d0
		bne.s	.exit					; if not, branch to return
		btst	#staSSJump,obStatus(a0)			; did Sonic jump or is he just falling or hit by a bumper?
		beq.s	.exit					; if not, branch to return
		move.b	(v_ssangle).w,d0				; get SS angle

	if ~~SmoothSpecialStages	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0							; round down to nearest 4
	endif

		neg.b	d0
		subi.b	#$40,d0
		jsr		(CalcSine).w			
		move.w	obVelY(a0),d2					; get Y speed
		muls.w	d2,d0							; multiply Y speed by sin
		asr.l	#8,d0							; find the new Y speed
		move.w	obVelX(a0),d2					; get X speed
		muls.w	d2,d1							; multiply X speed by cos
		asr.l	#8,d1							; find the new X speed
		add.w	d0,d1							; combine the two speeds
		cmpi.w	#$400,d1						; compare the combined speed with the jump release speed
		ble.s	.exit					; if it's less, branch to return
		move.b	(v_ssangle).w,d0

	if ~~SmoothSpecialStages	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0							; round down to nearest 4
	endif

		neg.b	d0
		subi.b	#$40,d0
		jsr		(CalcSine).w
		muls.w	#$400,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#$400,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)					; set the speed to the jump release speed
		bclr	#staSSJump,obStatus(a0)			; clear "Sonic has jumped" flag

	.exit:
		rts
; End of function SpSon_JumpHeight
; ===========================================================================
	endif

; ---------------------------------------------------------------------------
; Subroutine to	fix the	camera on Sonic's position (special stage)
; ---------------------------------------------------------------------------

SS_FixCamera:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		move.w	(v_screenposx).w,d0
		subi.w	#$A0,d3
		bcs.s	.ignore_x						; branch if Sonic is within 160px of left edge
		sub.w	d3,d0
		sub.w	d0,(v_screenposx).w				; fix camera 160px (half screen) left of Sonic

	.ignore_x:
		move.w	(v_screenposy).w,d0
		subi.w	#$70,d2
		bcs.s	.ignore_y						; branch if Sonic is within 112px of top edge
		sub.w	d2,d0
		sub.w	d0,(v_screenposy).w				; fix camera 112px (half screen) above Sonic

	.ignore_y:
		rts	
; End of function SS_FixCamera
; ===========================================================================

SpSon_ExitStage:		; Routine 4
		addi.w	#$40,(v_ssrotate).w				; increase stage rotation speed
		cmpi.w	#$1800,(v_ssrotate).w			; check if it's up to $1800
		bne.s	.not_1800						; if not, branch
		move.b	#id_Level,(v_gamemode).w		; set game mode to normal level

	.not_1800:
		cmpi.w	#$3000,(v_ssrotate).w			; check if it's up to $3000
		blt.s	.not_3000						; if not, branch
		clr.w	(v_ssrotate).w					; stop rotation
		move.w	#$4000,(v_ssangle).w
		addq.b	#2,obRoutine(a0)				; -> SpSon_ExitWait
		move.w	#$3C,obSSSonic_RestartTime(a0)

	.not_3000:
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0				; add rotation speed to angle
		move.w	d0,(v_ssangle).w				; update angle
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		bsr.w	SS_FixCamera
		jmp		(DisplaySprite).l
; ===========================================================================

SpSon_ExitWait:		; Routine 6
		subq.w	#1,obSSSonic_RestartTime(a0)	; decrement timer
		bne.s	.wait							; branch if time remains
		move.b	#id_Level,(v_gamemode).w

	.wait:
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		bsr.w	SS_FixCamera
		jmp		(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic fall in the Special Stage
; ---------------------------------------------------------------------------

SpSon_Fall:
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		move.b	(v_ssangle).w,d0				; get special stage angle

	if ~~SmoothSpecialStages	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0							; round down to nearest 4
	endif

		jsr		(CalcSine).w					; convert to sine/cosine
		move.w	obVelX(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d0
		add.l	d4,d0							; d0 = (VelX*$100)+(sine*$2A)
		move.w	obVelY(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d1
		add.l	d4,d1							; d1 = (VelY*$100)+(cosine*$2A)
		add.l	d0,d3							; d3 = XPos+d0
		bsr.w	SpSon_FindWalls					; detect wall to left/right
		beq.s	.no_wall						; branch if not found

		sub.l	d0,d3							; d3 = XPos
		moveq	#0,d0
		move.w	d0,obVelX(a0)					; stop moving left/right
		bclr	#staAir,obStatus(a0)
		add.l	d1,d2							; d2 = YPos+d1
		bsr.w	SpSon_FindWalls
		beq.s	.no_floor

		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)					; stop falling down
		rts
; ===========================================================================

	.no_wall:
		add.l	d1,d2
		bsr.w	SpSon_FindWalls					; detect wall below
		beq.s	.air							; branch if wall not found
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)					; stop moving down
		bclr	#staAir,obStatus(a0)

	.no_floor:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		rts
; ===========================================================================

	.air:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		bset	#staAir,obStatus(a0)			; Sonic is in the air, touching no walls
		rts	
; End of function SpSon_Fall
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to detect a wall at a given position

; input:
;	d2 = y position (including subpixel)
;	d3 = x position (including subpixel)

; output:
;	d4 = id of wall or item
;	d5 = flag: 0 = no collision (e.g. rings); -1 = collision with solid wall
; TO-DO: Consider replacing the mulu instructions w/ left-shift #7
; ---------------------------------------------------------------------------

SpSon_FindWalls:
		lea		(v_ssbuffer1&$FFFFFF).l,a1		; get layout address
		moveq	#0,d4
		swap	d2
		move.w	d2,d4							; d4 = y pos
		swap	d2
		addi.w	#$44,d4
		divu.w	#$18,d4							; divide by height of SS blocks (24 pixels)
		mulu.w	#$80,d4							; multiply by bytes per SS row ($80)
		adda.l	d4,a1							; jump to row in layout
		moveq	#0,d4
		swap	d3
		move.w	d3,d4							; d4 = x pos
		swap	d3
		addi.w	#$14,d4
		divu.w	#$18,d4							; divide by width of SS blocks (24 pixels)
		adda.w	d4,a1							; jump to exact position in layout

; Using stage coordinates, check whether or not there's a solid block at that location
		moveq	#0,d5
		move.b	(a1)+,d4						; get id of wall/item
		bsr.s	SpSon_ChkForSolids
		move.b	(a1)+,d4						; get id of adjacent wall/item
		bsr.s	SpSon_ChkForSolids
		adda.w	#$7E,a1							; next row
		move.b	(a1)+,d4						; get id of adjacent wall/item
		bsr.s	SpSon_ChkForSolids
		move.b	(a1)+,d4						; get id of adjacent wall/item
		bsr.s	SpSon_ChkForSolids
		tst.b	d5								; test for collision (assumes next instruction will be a conditional branch)
		rts	
; End of function SpSon_FindWalls
; ===========================================================================

SpSon_ChkForSolids: ;sub_1BD30:
		beq.s	.noSolidFound					; if no object detected, branch and exit
		cmpi.b	#SSBlock_1Up,d4					; did Sonic collide w/ a 1-Up icon?
		beq.s	.noSolidFound					; if yes, branch and exit
		cmpi.b	#SSBlock_Ring,d4				; is the object ID < $3A (ring)?
		bcs.s	.solidFound						; if yes, this object was solid.
		cmpi.b	#SSBlock_GlassAni1,d4			; is this object flashing glass?
		bcc.s	.solidFound						; if yes, this object was solid

	.noSolidFound:
		rts	
; ===========================================================================

	.solidFound:
		move.b	d4,obSSSonic_SSItemID(a0)		; get id of wall item
		move.l	a1,obSSSonic_SSItemAddr(a0)		; get address within layout
		moveq	#-1,d5							; set collision flag
		rts	
; End of function SpSon_ChkForSolids
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check for collision with rings/1UPs/emerald/ghost blocks

; output:
;	d4 = -1 if item is a ghost block; 0 otherwise
;
; See Constants.asm for Special Stage block IDs (Adjusted for SuperMod)
; TO-DO: Rework this in a similar manner to the Monitor Icon (Object 2E)???
; ---------------------------------------------------------------------------

SpSon_ChkItems_Nonsolid:
		lea		(v_ssbuffer1&$FFFFFF).l,a1		; get layout address
		moveq	#0,d4
		move.w	obY(a0),d4						; d4 = Sonic's y pos
		addi.w	#$50,d4
		divu.w	#$18,d4							; divide by height of SS blocks (24 pixels)
		mulu.w	#$80,d4							; multiply by bytes per SS row ($80)
		adda.l	d4,a1							; jump to row in layout
		moveq	#0,d4
		move.w	obX(a0),d4						; d4 = Sonic's x pos
		addi.w	#$20,d4
		divu.w	#$18,d4							; divide by width of SS blocks (24 pixels)
		adda.w	d4,a1							; jump to exact position in layout
		move.b	(a1),d4							; get ID of SS item being collided with.
		bne.s	SpSon_ChkRing					; if d4 != 0, check for item type
		tst.b	obSSSonic_GhostStatus(a0)		; check ghost block status
		bne.w	SpSon_MakeGhostSolid			; branch if passed/solid
		moveq	#0,d4
		rts	
; ===========================================================================

SpSon_ChkRing:
		cmpi.b	#SSBlock_Ring,d4				; is the item a	ring?
		bne.s	SpSon_Chk1Up					; if not, branch
		bsr.w	SS_RemoveCollectedItem			; find free item update slot
		bne.s	.no_slot
		move.b	#1,(a2)							; item sparkles and vanishes
		move.l	a1,4(a2)						; address within layout to be updated

	.no_slot:
	if PerfectBonusEnabled
		subq.w	#1,(v_perfectringsleft).w		; decrement perfect ring count
	endif

		moveq	#1,d0
		jsr		(CollectRing).l					; get a ring
		cmpi.w	#50,(v_rings).w					; check if you have 50 rings
		blo.s	.no_continue					; if not, branch
		bset	#0,(v_lifecount).w				; set ring reward flag
		bne.s	.no_continue					; branch if flag was already set
		addq.b	#1,(v_continues).w				; add 1 to number of continues

	if SpecialStagesWithAllEmeralds	; Mercury Special Stages Still Appear With All Emeralds
		bset	#7,(v_continues).w				; set "got continue" flag bit
	endif	; Special Stages Still Appear With All Emeralds	End

		move.w	#sfx_Continue,d0
		jsr		(QueueSound2).w					; play extra continue sound (Other branches use Queue1)

	.no_continue:
	if PerfectBonusEnabled
		tst.w	(v_perfectringsleft).w			; Have we achieved a PERFECT?
		bne.s	.no_perfect						; if not, branch
		move.w	#sfx_Perfect,d0
		jsr		(QueueSound2).w					; play perfect sound

	.no_perfect:
	endif
		moveq	#0,d4
		rts	
; ===========================================================================

SpSon_Chk1Up:
		cmpi.b	#SSBlock_1Up,d4					; is the item an extra life?
		bne.s	SpSon_ChkEmerald
		bsr.w	SS_RemoveCollectedItem			; find free item update slot
		bne.s	.no_slot
		move.b	#3,(a2)							; item sparkles and vanishes
		move.l	a1,4(a2)						; address within layout to be updated

	.no_slot:

	if SpecialStagesWithAllEmeralds		; Mercury Special Stages Still Appear With All Emeralds

	if SpecialStageAdvancementMod		; Mercury Special Stage Index Increases Only If Won
		addq.b	#1,(v_lastspecial).w			; increment SS index
	endif
	
	if HUDInSpecialStage	; Mercury HUD in Special Stage
		clr.b	(f_timecount).w					; stop the time counter
	endif
	
	endif

	; Mercury Lives Over/Underflow Fix
		cmpi.b	#99,(v_lives).w					; are lives at max?
		beq.s	.playbgm
		addq.b	#1,(v_lives).w					; add 1 to number of lives
		addq.b	#1,(f_lifecount).w				; update the lives counter

	.playbgm:
	; Lives Over/Underflow Fix End

	if ~~AmbienceMode
		move.w	#bgm_ExtraLife,d0
		jsr		(QueueSound1).w					; play extra life music
	endif

		moveq	#0,d4
		rts	
; ===========================================================================

SpSon_ChkEmerald:
		cmpi.b	#SSBlock_Emld1,d4				; is the item an emerald?
		blo.s	SpSon_ChkGhost
		cmpi.b	#SSBlock_EmldLast,d4
		bhi.s	SpSon_ChkGhost
		bsr.w	SS_RemoveCollectedItem			; find free item update slot
		bne.s	.no_slot
		move.b	#5,(a2)							; item sparkles and vanishes
		move.l	a1,4(a2)						; address within layout to be updated

	.no_slot:
		cmpi.b	#emldCount,(v_emeralds).w		; do you have all the emeralds?
		beq.s	.no_emerald						; if yes, branch
		subi.b	#SSBlock_Emld1,d4
		bset	d4,(v_emldlist).w				; set the appropriate bit in the emerald bitfield
		bne.s	.already_have					; if this emerald was already collected, branch
		addq.b	#1,(v_emeralds).w				; add 1 to number of emeralds

	.already_have:
	if SpecialStageAdvancementMod	; Mercury Special Stage Index Increases Only If Won
		addq.b	#1,(v_lastspecial).w			; increment SS index
	endif
	
	if HUDInSpecialStage	; Mercury HUD in Special Stage
		clr.b	(f_timecount).w					; stop the time counter
	endif

	.no_emerald:
		move.w	#bgm_Emerald,d0
		jsr		(QueueSound1).w					; play emerald music (other branches use Queue2)

		moveq	#0,d4
		rts	
; ===========================================================================

SpSon_ChkGhost:
		cmpi.b	#SSBlock_Ghost,d4				; is the item a	ghost block?
		bne.s	.chk_ghost_tag					; if not, branch
		move.b	#1,obSSSonic_GhostStatus(a0)	; mark the ghost block as "passed"

	.chk_ghost_tag:
		cmpi.b	#SSBlock_GhostSwitch,d4			; is the item a	switch for ghost blocks?
		bne.s	.no_ghost						; if not, branch
		cmpi.b	#1,obSSSonic_GhostStatus(a0)	; have the ghost blocks	been passed?
		bne.s	.no_ghost						; if not, branch
		move.b	#2,obSSSonic_GhostStatus(a0)	; mark the ghost blocks	as "solid"

	.no_ghost:
		moveq	#-1,d4
		rts	
; ===========================================================================

SpSon_MakeGhostSolid:
		cmpi.b	#2,obSSSonic_GhostStatus(a0)	; is the ghost marked as "solid"?
		bne.s	.not_solid						; if not, branch
		lea		(v_ssblockbuffer&$FFFFFF).l,a1	; get layout address (blocks before $1020 are blank)
		moveq	#(v_ssblockbuffer_end-v_ssblockbuffer)/$80-1,d1

	.loop_row:
		moveq	#$40-1,d2

	.loop_item:
		cmpi.b	#SSBlock_Ghost,(a1)				; is the item a	ghost block?
		bne.s	.no_replace						; if not, branch
		move.b	#SSBlock_GhostSolid,(a1)		; replace ghost	block with a solid block

	.no_replace:
		addq.w	#1,a1							; check next item
		dbf		d2,.loop_item
		lea		$40(a1),a1						; jump to next row
		dbf		d1,.loop_row

	.not_solid:
		clr.b	obSSSonic_GhostStatus(a0)
		moveq	#0,d4
		rts	
; End of function SpSon_ChkItems_Nonsolid
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check for collision with bumper/GOAL/UP/DOWN/R/glass blocks
; ---------------------------------------------------------------------------

SpSon_ChkItems_Solid:
		move.b	obSSSonic_SSItemID(a0),d0		; get item id
		bne.s	SpSon_ChkBumper					; if non-zero, check collisions
		subq.b	#1,obSSSonic_UpDownTime(a0)		; decrement UP/DOWN cooldown timer
		bpl.s	.updown_off						; branch if positive
		clr.b	obSSSonic_UpDownTime(a0)		; clear UP/DOWN timer to 0

	.updown_off:
		subq.b	#1,obSSSonic_ReverseTime(a0)	; decrement R cooldown timer
		bpl.s	.r_off							; branch if positive
		clr.b	obSSSonic_ReverseTime(a0)		; clear R timer to 0

	.r_off:
		rts	
; ===========================================================================

SpSon_ChkBumper:
		cmpi.b	#SSBlock_Bumper,d0				; is the item a	bumper?
		bne.s	SpSon_GOAL						; if not, branch
		move.l	obSSSonic_SSItemAddr(a0),d1		; get address of bumper within layout
		subi.l	#$FF0001,d1
		move.w	d1,d2
		andi.w	#$7F,d1
		mulu.w	#$18,d1
		subi.w	#$14,d1							; d1 = x position of bumper
		lsr.w	#7,d2
		andi.w	#$7F,d2
		mulu.w	#$18,d2
		subi.w	#$44,d2							; d2 = y position of bumper
		sub.w	obX(a0),d1
		sub.w	obY(a0),d2
		jsr		(CalcAngle).w
		jsr		(CalcSine).w
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)					; bounce Sonic away from bumper
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#staAir,obStatus(a0)			; set Sonic's air flag
		bclr	#staSSJump,obStatus(a0)			; clear "Sonic has jumped" flag -- Mercury Fixed SS Jumping Physics
		bsr.w	SS_RemoveCollectedItem
		bne.s	.no_slot						; branch if not found
		move.b	#2,(a2)							; set update type
		move.l	obSSSonic_SSItemAddr(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)						; set address within layout to update

	.no_slot:
		move.w	#sfx_Bumper,d0
		jmp		(QueueSound2).w					; play bumper sound
; ===========================================================================

SpSon_GOAL:
		cmpi.b	#SSBlock_GOAL,d0				; is the item a	"GOAL"?
		bne.s	SpSon_UPblock					; if not, branch
		addq.b	#2,obRoutine(a0)				; -> SpSon_ExitStage

	if HUDInSpecialStage	; Mercury HUD in Special Stage
		clr.b	(f_timecount).w					; stop the time counter
	endIF	; HUD in Special Stage End

		move.w	#sfx_SSGoal,d0
		jmp		(QueueSound2).w					; play "GOAL" sound
; ===========================================================================

SpSon_UPblock:
		cmpi.b	#SSBlock_UP,d0					; is the item an "UP" block?
		bne.s	SpSon_DOWNblock					; if not, branch
		tst.b	obSSSonic_UpDownTime(a0)		; check UP/DOWN cooldown
		bne.w	SpSon_EndChecks					; branch if time remains
		move.b	#$1E,obSSSonic_UpDownTime(a0)	; set UP/DOWN cooldown to half a second
		btst	#6,(v_ssrotate+1).w				; is SS rotation speed $40? (minimum)
		beq.s	.keep_speed						; if not, branch
		asl		(v_ssrotate).w					; increase stage rotation speed
		movea.l	obSSSonic_SSItemAddr(a0),a1
		subq.l	#1,a1
		move.b	#SSBlock_DOWN,(a1)				; change item to a "DOWN" block

	.keep_speed:
		move.w	#sfx_SSItem,d0
		jmp		(QueueSound2).w					; play up/down sound
; ===========================================================================

SpSon_DOWNblock:
		cmpi.b	#SSBlock_DOWN,d0				; is the item a	"DOWN" block?
		bne.s	SpSon_Rblock					; if not, branch
		tst.b	obSSSonic_UpDownTime(a0)		; check UP/DOWN cooldown
		bne.w	SpSon_EndChecks					; branch if time remains
		move.b	#$1E,obSSSonic_UpDownTime(a0)	; set UP/DOWN cooldown to half a second
		btst	#6,(v_ssrotate+1).w				; is SS rotation speed $40? (minimum)
		bne.s	.keep_speed						; if not, branch
		asr		(v_ssrotate).w					; reduce stage rotation speed
		movea.l	obSSSonic_SSItemAddr(a0),a1
		subq.l	#1,a1
		move.b	#SSBlock_UP,(a1)				; change item to an "UP" block

	.keep_speed:
		move.w	#sfx_SSItem,d0
		jmp		(QueueSound2).w					; play up/down sound
; ===========================================================================

SpSon_Rblock:
		cmpi.b	#SSBlock_R,d0					; is the item an "R" block?
		bne.s	SpSon_ChkGlass					; if not, branch
		tst.b	obSSSonic_ReverseTime(a0)		; check R cooldown
		bne.w	SpSon_EndChecks					; branch if time remains
		move.b	#$1E,obSSSonic_ReverseTime(a0)	; set R cooldown to half a second
		bsr.w	SS_RemoveCollectedItem
		bne.s	.no_slot						; branch if not found
		move.b	#4,(a2)
		move.l	obSSSonic_SSItemAddr(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)						; update the stage layout

	.no_slot:
		neg.w	(v_ssrotate).w					; reverse stage rotation
		move.w	#sfx_SSItem,d0
		jmp		(QueueSound2).w					; play sound
; ===========================================================================

SpSon_ChkGlass:
	; Optimized check (RetroKoH)
		cmpi.b	#SSBlock_Glass1,d0				; is the item a	glass block?
		blo.s	SpSon_EndChecks					; if not, branch
		cmpi.b	#SSBlock_Glass4,d0
		bhi.s	SpSon_EndChecks					; if not, branch

	;.glass:
		bsr.w	SS_RemoveCollectedItem
		bne.s	.no_slot
		move.b	#6,(a2)
		movea.l	obSSSonic_SSItemAddr(a0),a1
		subq.l	#1,a1
		move.l	a1,4(a2)
		move.b	(a1),d0
		addq.b	#1,d0							; change glass type when touched
		cmpi.b	#SSBlock_Glass4,d0
		bls.s	.update							; if glass is still there, branch
		clr.b	d0								; remove the glass block when it's destroyed

	.update:
		move.b	d0,4(a2)						; update the stage layout

	.no_slot:
		move.w	#sfx_SSGlass,d0
		jmp		(QueueSound2).w					; play glass block sound
; ===========================================================================

SpSon_EndChecks:
		rts	
; End of function SpSon_ChkItems_Solid
; ===========================================================================