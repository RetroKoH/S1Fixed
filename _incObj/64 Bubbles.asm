; ---------------------------------------------------------------------------
; Object 64 - bubbles (LZ)
;
; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes $80/$81/$82
;	Bubble - subtypes 0/1/2
; ---------------------------------------------------------------------------

Bubble:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Bub_Index(pc,d0.w),d1
		jmp		Bub_Index(pc,d1.w)
; ===========================================================================

Bub_Index:	offsetTable
		offsetTableEntry.w Bub_Main
		offsetTableEntry.w Bub_Animate
		offsetTableEntry.w Bub_ChkWater
		offsetTableEntry.w Bub_Display
		offsetTableEntry.w Bub_Delete
		offsetTableEntry.w Bub_BblMaker
; ===========================================================================

Bub_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bub,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Bubbles,0,1),obGfx(a0)
		move.b	#$84,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority1,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0				; get bubble type
		bpl.s	.bubble							; if type is $0-$7F, branch

		addq.b	#8,obRoutine(a0)				; goto Bub_BblMaker next
		andi.w	#$7F,d0							; read only last 7 bits	(deduct	$80)
		move.b	d0,obBubble_WaitTime(a0)
		move.b	d0,obBubble_WaitMaster(a0)		; set bubble frequency
		move.b	#6,obAnim(a0)
		bra.w	Bub_BblMaker
; ===========================================================================

	.bubble:
		move.b	d0,obAnim(a0)					; use animation 0/1/2 (small/medium/large)
		move.w	obX(a0),obBubble_StartX(a0)
		move.w	#-$88,obVelY(a0)				; float bubble upwards
		jsr		(RandomNumber).w
		move.b	d0,obAngle(a0)					; set high byte of ost_angle as random number
; ---------------------------------------------------------------------------

Bub_Animate:	; Routine 2
		lea		Ani_Bub(pc),a1
		jsr		(AnimateSprite).w				; run animation and goto Bub_ChkWater next
		cmpi.b	#6,obFrame(a0)					; is bubble full-size?
		bne.s	Bub_ChkWater					; if not, branch

		move.b	#1,obBubble_Inhalable(a0)		; set "inhalable" flag
; ---------------------------------------------------------------------------

Bub_ChkWater:	; Routine 4
		move.w	(v_waterpos_actual).w,d0
		cmp.w	obY(a0),d0						; is bubble underwater?
		blo.s	.wobble							; if yes, branch

	.burst:
		move.b	#6,obRoutine(a0)				; goto Bub_Display next
		addq.b	#3,obAnim(a0)					; run "bursting" animation
		bra.w	Bub_Display
; ===========================================================================

	.wobble:
		move.b	obAngle(a0),d0
		addq.b	#1,obAngle(a0)
		andi.w	#$7F,d0
		lea		(Drown_WobbleData).l,a1
		move.b	(a1,d0.w),d0					; get byte from wobble array (see "Objects\LZ Drowning Numbers.asm")
		ext.w	d0
		add.w	obBubble_StartX(a0),d0
		move.w	d0,obX(a0)						; change bubble's x-axis position
		tst.b	obBubble_Inhalable(a0)			; can bubble be inhaled?
		beq.s	.display						; if not, branch
		bsr.w	Bub_ChkSonic					; has Sonic touched the	bubble?
		beq.s	.display						; if not, branch
		
	if SpinDashEnabled==1	; Mercury Spin Dash
		cmpi.b	#aniID_SpinDash,obAnim(a1)
		beq.s	.display
	endif	; Spin Dash End

		bsr.w	ResumeMusic						; cancel countdown music
		move.w	#sfx_Bubble,d0
		jsr		(QueueSound2).w					; play collecting bubble sound
		lea		(v_player).w,a1
		moveq	#0,d0
		move.l	d0,obVelX(a1)
		move.w	d0,obInertia(a1)				; stop Sonic
		move.b	#aniID_GetAir,obAnim(a1)		; use bubble-collecting animation

		; Mercury Standing Bubble Animation
		btst	#staAir,obStatus(a1)			; is Sonic in the air?
		bne.s	.in_air							; if yes, branch
		move.b	#aniID_GetAirStand,obAnim(a1)	; use bubble-collecting while standing animation

	.in_air:
		; Standing Bubble Animation End

		move.b	#35,obLRLock(a1)				; lock controls for 35 frames
		move.b	d0,obJumping(a1)				; cancel jump
		andi.b	#~(maskRollJump+maskPush),obStatus(a1)	; clear RollJump and Push flags ($CF)
		btst	#staSpin,obStatus(a1)
		beq.w	.burst
		bclr	#staSpin,obStatus(a1)
		move.w	#$1309,obHeight(a1)				; Height and Width
		subq.w	#5,obY(a1)
		bra.w	.burst
; ===========================================================================

	.display:
		bsr.w	SpeedToPos_YOnly				; horizontal movement is NOT applied by VelX
		tst.b	obRender(a0)					; is bubble on-screen?
		bpl.w	DeleteObject					; if not, branch
		jmp		(DisplaySprite).l
; ===========================================================================

Bub_Display:	; Routine 6
		lea		Ani_Bub(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obRender(a0)					; is object on-screen?
		bpl.w	DeleteObject					; if not, branch
		jmp		(DisplaySprite).l
; ===========================================================================

Bub_Delete:	; Routine 8
		bra.w	DeleteObject
; ===========================================================================

Bub_BblMaker:	; Routine $A
		tst.w	obBubble_Flag(a0)				; any flags set?
		bne.s	.chk_time						; if yes, branch
		move.w	(v_waterpos_actual).w,d0
		cmp.w	obY(a0),d0						; is bubble maker underwater?
		bhs.w	.chkdel							; if not, branch
		tst.b	obRender(a0)					; is bubble maker on-screen?
		bpl.w	.chkdel							; if not, branch
		subq.w	#1,obBubble_RandomTime(a0)		; decrement timer
		bpl.w	.animate						; branch if time remains
		move.w	#1,obBubble_Flag(a0)			; set flag for bubble spawn

	.tryagain:
		jsr		(RandomNumber).w
		move.w	d0,d1
		andi.w	#7,d0							; read only bits 0-2 of random number
		cmpi.w	#6,d0							; random number over 6?
		bhs.s	.tryagain						; if yes, branch and loop back

		move.b	d0,obBubble_MiniCount(a0)		; set number of small/medium bubbles to spawn (0-5)
		andi.w	#$C,d1							; read only bits 2-3 of random number
		lea		(Bub_BblTypes).l,a1
		adda.w	d1,a1							; jump to multiple of 4 within type array
		move.l	a1,obBubble_TypeList(a0)
		subq.b	#1,obBubble_WaitTime(a0)		; decrement timer
		bpl.s	.spawn_bubble					; branch if time remains
		move.b	obBubble_WaitMaster(a0),obBubble_WaitTime(a0)	; reset timer (based on original subtype)
		bset	#7,obBubble_Flag(a0)			; allow large bubble in current sequence
		bra.s	.spawn_bubble
; ===========================================================================

	.chk_time:
		subq.w	#1,obBubble_RandomTime(a0)		; decrement timer
		bpl.w	.animate						; branch if time remains

	.spawn_bubble:
		jsr		(RandomNumber).w
		andi.w	#$1F,d0
		move.w	d0,obBubble_RandomTime(a0)		; set next random time (max 32 frames)
		bsr.w	FindFreeObj
		bne.s	.fail							; branch if obj slot not found
		_move.b	#id_Bubble,obID(a1)				; load bubble object
		move.w	obX(a0),obX(a1)
		jsr		(RandomNumber).w
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,obX(a1)						; randomise initial x pos
		move.w	obY(a0),obY(a1)
		moveq	#0,d0
		move.b	obBubble_MiniCount(a0),d0		; get number of bubbles to spawn
		movea.l	obBubble_TypeList(a0),a2		; get address of type array
		move.b	(a2,d0.w),obSubtype(a1)			; load type from array
		btst	#7,obBubble_Flag(a0)
		beq.s	.fail
		jsr		(RandomNumber).w
		andi.w	#3,d0							; are either lowest 2 bits of random number set?
		bne.s	.skip_large						; if yes, branch
		bset	#6,obBubble_Flag(a0)			; set large bubble flag
		bne.s	.fail							; branch if already set
		move.b	#2,obSubtype(a1)				; make bubble large

	.skip_large:
		tst.b	obBubble_MiniCount(a0)			; is this the last bubble in the current sequence?
		bne.s	.fail							; if not, branch
		bset	#6,obBubble_Flag(a0)			; set large bubble flag
		bne.s	.fail							; branch if already set
		move.b	#2,obSubtype(a1)				; make bubble large

	.fail:
		subq.b	#1,obBubble_MiniCount(a0)		; decrement bubble count
		bpl.s	.animate						; branch if positive
		jsr		(RandomNumber).w
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,obBubble_RandomTime(a0)		; set timer for next sequence
		clr.w	obBubble_Flag(a0)				; clear all flags

	.animate:
		lea		Ani_Bub(pc),a1
		jsr		(AnimateSprite).w

	.chkdel:
		offscreen.w	DeleteObject				; PFM S3K OBJ
		move.w	(v_waterpos_actual).w,d0
		cmp.w	obY(a0),d0
		blo.w	DisplaySprite					; display if below water
		rts	
; ===========================================================================
; bubble production sequence

; 0 = small bubble, 1 =	large bubble

Bub_BblTypes:	dc.b 0,	1, 0, 0, 0, 0, 1, 0, 0,	0, 0, 1, 0, 1, 0, 0, 1,	0

; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check large bubble's collision with Sonic
; ---------------------------------------------------------------------------

Bub_ChkSonic:
		tst.b	(v_debuguse).w			; don't interact w/ Bubbles in Debug mode
		bne.s	.no_collision
		lea		(v_player).w,a1			; moved to the front to call obCtrlLock directly from a1

	if ShieldsMode
		btst	#sta2ndBShield,obStatus2nd(a1)
		bne.s	.no_collision
	endif

		tst.b	obCtrlLock(a1)			; is object collision disabled?
		bmi.s	.no_collision			; if yes, branch
		move.w	obX(a1),d0
		move.w	obX(a0),d1
		subi.w	#$10,d1
		cmp.w	d0,d1
		bhs.s	.no_collision			; branch if Sonic is left of bubble
		addi.w	#$20,d1
		cmp.w	d0,d1
		blo.s	.no_collision			; branch if Sonic is right of bubble
		move.w	obY(a1),d0
		move.w	obY(a0),d1
		cmp.w	d0,d1
		bhs.s	.no_collision			; branch if Sonic is above bubble
		addi.w	#$10,d1
		cmp.w	d0,d1
		blo.s	.no_collision			; branch if Sonic is below bubble
		moveq	#1,d0					; return collision
		rts	
; ===========================================================================

	.no_collision:
		moveq	#0,d0					; return no collision
		rts	
; ===========================================================================