; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------
; OST Constants
obSpring_Power:			equ objoff_30		; 2 bytes | power of current spring
; ---------------------------------------------------------------------------

Springs:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Spring_Index(pc,d0.w),d1
		jsr		Spring_Index(pc,d1.w)
	; KoH Animated Spring Solidity fix
		tst.b	ob2ndRout(a0)
		beq.s	.display
		lea		Ani_Spring(pc),a1
		jsr		(AnimateSprite).w

	.display:
	; Animated Spring Solidity fix end
		offscreen.w	DeleteObject
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix	
; ===========================================================================
Spring_Index:	offsetTable
		offsetTableEntry.w Spring_Main
		offsetTableEntry.w Spring_Up
		offsetTableEntry.w Spring_LR
		offsetTableEntry.w Spring_Dwn

obSpring_Powerers:
		dc.w -$1000		; power	of red spring
		dc.w -$A00		; power	of yellow spring
; ===========================================================================

Spring_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Spring_Up
		clr.b	ob2ndRout(a0)
		move.l	#Map_Spring,obMap(a0)
		move.w	#make_art_tile(ArtTile_Spring_Horizontal,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		btst	#4,d0						; is spring type $1x? (horizontal)
		beq.s	.not_horizontal				; if not, branch

		addq.b	#2,obRoutine(a0)			; -> #4: Spring_LR
		move.b	#1,obAnim(a0)
		move.b	#3,obFrame(a0)
		move.w	#make_art_tile(ArtTile_Spring_Vertical,0,0),obGfx(a0)
		move.b	#8,obDispWid(a0)
		bra.s	.not_down

	.not_horizontal:
		btst	#5,d0						; does the spring face downwards?
		beq.s	.not_down					; if not, branch

		addq.b	#4,obRoutine(a0)			; -> #6: "Spring_Dwn" routine
		bset	#staFlipY,obStatus(a0)

	.not_down:
		btst	#1,d0						; is spring subtype $x2?
		beq.s	.not_yellow					; if not, branch
		bset	#5,obGfx(a0)				; use 2nd palette (yellow spring)

	.not_yellow:
		andi.w	#$F,d0						; read only low nybble of subtype (0 or 2)
		move.w	obSpring_Powerers(pc,d0.w),obSpring_Power(a0) ; get power level
		rts	
; ===========================================================================

Spring_Up:	; Routine 2
		moveq	#27,d1						; width; save 4 cycles - Filter
		moveq	#8,d2						; height (jumping); save 4 cycles - Filter
		moveq	#16,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		btst	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bne.s	Spring_BounceUp				; if Sonic is on top of the spring, branch
		rts	
; ===========================================================================

Spring_BounceUp:
		addq.w	#8,obY(a1)
		move.w	obSpring_Power(a0),obVelY(a1)	; move Sonic upwards
		bset	#staAir,obStatus(a1)
		bclr	#staOnObj,obStatus(a1)
		clr.b	obJumping(a1)
		; Clear the spin flag?

	if SpinDashEnabled
		clr.b	obSpinDashFlag(a1)			; clear spin dash flag
	endif

		move.b	#aniID_Spring,obAnim(a1)	; use "bouncing" animation
		move.b	#2,obRoutine(a1)
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	Spring_StartBounce			; perform bounce and play spring sound
; ===========================================================================

Spring_LR:	; Routine 8
		moveq	#19,d1						; width; save 4 cycles - Filter
		moveq	#14,d2						; height (jumping); save 4 cycles - Filter
		moveq	#15,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position

		bsr.w	SolidObject
	; KoH Horizontal Springs fix
		cmpi.w  #1,d4						; is Sonic making side contact (grounded or mid-air)?
		bne.s	.return						; if not, branch
		
		move.w	obX(a1),d0
		cmp.w	obX(a0),d0
		bls.s	.left_side					; if Sonic is on the left side of the spring, branch
		btst	#staFlipX,obStatus(a0)
		beq.s	Spring_BounceLR				; bounce off the right side of a right-facing spring
		rts									; don't bounce off the right side of a left-facing spring

	.left_side:
		btst	#staFlipX,obStatus(a0)
		bne.s	Spring_BounceLR				; bounce off the left side of a left-facing spring
	
	.return:
		rts									; don't bounce off the left side of a right-facing spring
	; Horizontal Springs fix end
; ===========================================================================

Spring_BounceLR:
		move.w	obSpring_Power(a0),obVelX(a1)	; move Sonic to the left
		addq.w	#8,obX(a1)
		bset	#staFacing,obStatus(a1)		; set Sonic facing to the left: RetroKoH Spring Direction Fix
		btst	#staFlipX,obStatus(a0)		; is object flipped?
		bne.s	Spring_Flipped				; if yes, branch
		bclr	#staFacing,obStatus(a1)		; set Sonic facing to the right: RetroKoH Spring Direction Fix
		subi.w	#$10,obX(a1)
		neg.w	obVelX(a1)					; move Sonic to	the right

Spring_Flipped:
		move.b	#$F,obLRLock(a1)			; lock controls for 0.25 seconds
		move.w	obVelX(a1),obInertia(a1)
		;bchg	#staFacing,obStatus(a1)		; Removed: RetroKoH Spring Direction Fix
		btst	#staSpin,obStatus(a1)		; is Sonic jumping/rolling?
		bne.s	.is_rolling					; if yes, branch
		move.b	#aniID_Walk,obAnim(a1)		; use walking animation

	.is_rolling:
		bclr	#staSonicPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)

	if CameraDashLag	; Camera Lag applied when dashing
		clr.b	(v_cameralag).w 			; clear camera lag
	endif

		bra.w	Spring_StartBounce			; perform bounce and play spring sound
; ===========================================================================

Spring_Dwn:	; Routine $E
		moveq	#27,d1						; width; save 4 cycles - Filter
		moveq	#8,d2						; height (jumping); save 4 cycles - Filter
		moveq	#16,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic on top of the spring? (removed obSolid)
		bne.s	.on_top						; if yes, branch
		tst.w	d4
		bmi.s	Spring_BounceDwn			; branch if Sonic hits spring from beneath

	.on_top:
		rts	
; ===========================================================================

Spring_BounceDwn:
		subq.w	#8,obY(a1)
		move.w	obSpring_Power(a0),obVelY(a1)
		neg.w	obVelY(a1)					; move Sonic downwards
		bset	#staAir,obStatus(a1)
		bclr	#staOnObj,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
; ---------------------------------------------------------------------------

Spring_StartBounce:
		move.b	#2,ob2ndRout(a0)			; enable spring animation
		bclr	#7,obAnim(a0)				; restart from the first frame
		move.w	#sfx_Spring,d0
		jmp		(QueueSound2).w				; play spring sound
; ===========================================================================