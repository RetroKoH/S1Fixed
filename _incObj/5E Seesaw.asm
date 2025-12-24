; ---------------------------------------------------------------------------
; Object 5E - seesaws (SLZ)
; ---------------------------------------------------------------------------

Seesaw:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	See_Index(pc,d0.w),d1
		jsr		See_Index(pc,d1.w)
		move.w	obSeesaw_StartX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		; Deleted first call to DeleteObject
		cmpi.w	#$280,d0
		bls.w	SBall_Display				; branch to here for S3K TouchResponse
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.w	DeleteObject				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject				; and delete object	
; ===========================================================================

See_Index:	offsetTable
		offsetTableEntry.w See_Main
		offsetTableEntry.w See_Slope
		offsetTableEntry.w See_StoodOn
		offsetTableEntry.w See_Spikeball
		offsetTableEntry.w See_SpikeAction
		offsetTableEntry.w See_SpikeFall
; ===========================================================================

See_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> See_Slope
		move.l	#Map_Seesaw,obMap(a0)
		move.w	#make_art_tile(ArtTile_SLZ_Seesaw,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$30,obDispWid(a0)
		move.w	obX(a0),obSeesaw_StartX(a0)
		tst.b	obSubtype(a0)				; is object type 00?
		bne.s	.noball						; if not, branch

		bsr.w	FindNextFreeObj
		bne.s	.noball
		_move.l	#Seesaw,obAddr(a1)			; load spikeball object
		addq.b	#6,obRoutine(a1)			; -> See_Spikeball
		move.w	obX(a0),obX(a1)				; spikeball position is updated later
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.w	a0,obSeesaw_Parent(a1)		; save address of OST of parent (seesaw)

	.noball:
		btst	#staFlipX,obStatus(a0)		; is seesaw flipped?
		beq.s	.noflip						; if not, branch
		move.b	#2,obFrame(a0)				; use different frame (right-side up)

	.noflip:
		move.b	obFrame(a0),obSeesaw_State(a0)	; set state to 0 or 2
; ---------------------------------------------------------------------------

See_Slope:	; Routine 2
		move.b	obSeesaw_State(a0),d1		; get state
		bsr.w	See_ChgFrame				; update frame if needed
		lea		(See_DataSlope).l,a2		; heightmap for sloped seesaw
		btst	#0,obFrame(a0)				; is seesaw flat?
		beq.s	.notflat					; if not, branch
		lea		(See_DataFlat).l,a2			; heightmap for flat seesaw (TO-DO: do we need this???)

	.notflat:
		lea		(v_player).w,a1
		move.w	obVelY(a1),obSeesaw_HitSpeed(a0)	; save speed at which Sonic landed on the seesaw
		moveq	#$30,d1						; moveq saves 4 cycles
		jmp		(SlopeObject).l				; detect collision and goto See_StoodOn next if true
; ===========================================================================

See_StoodOn:	; Routine 4
		bsr.w	See_ChkSide					; check where Sonic is on seesaw and update frame
		lea		(See_DataSlope).l,a2
		btst	#0,obFrame(a0)				; is seesaw flat?
		beq.s	.notflat					; if not, branch
		lea		(See_DataFlat).l,a2

	.notflat:
		moveq	#$30,d1						; moveq saves 4 cycles
		jsr		(ExitPlatform).l			; goto See_Slope next if Sonic leaves seesaw
		moveq	#$30,d1						; moveq saves 4 cycles
		move.w	obX(a0),d2
		jmp		(SlopeObject2).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check which side Sonic is on, and update its frame
;
; input:
;	d1 = ost_seesaw_state (See_ChgFrame only)
;
; output:
;	d1 = ost_seesaw_state
;	uses d0
; ---------------------------------------------------------------------------

See_ChkSide:
		moveq	#2,d1						; right side is raised by default (2)
		lea		(v_player).w,a1
		move.w	obX(a0),d0
		sub.w	obX(a1),d0					; is Sonic on the left side of the seesaw?
		bcc.s	.leftside					; if yes, branch
		neg.w	d0
		moveq	#0,d1						; left side is raised (0)

	.leftside:
		cmpi.w	#8,d0						; is Sonic more than 8px from centre?
		bhs.s	See_ChgFrame				; if yes, branch
		moveq	#1,d1						; seesaw is flat (1)

See_ChgFrame:
		move.b	obFrame(a0),d0
		cmp.b	d1,d0						; does frame need to change?
		beq.s	.noflip						; if not, branch
		bcc.s	.reduce_frame				; branch if previous frame is > new frame
		addq.b	#2,d0

	.reduce_frame:
		subq.b	#1,d0
		move.b	d0,obFrame(a0)				; update frame
		move.b	d1,obSeesaw_State(a0)
		bclr	#0,obRender(a0)
		btst	#1,obFrame(a0)				; is frame 2 or 3?
		beq.s	.noflip						; if not, branch
		bset	#0,obRender(a0)

	.noflip:
		rts	
; ===========================================================================

See_Spikeball:	; Routine 6
		addq.b	#2,obRoutine(a0)			; goto See_SpikeAction
		move.l	#Map_SSawBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_SLZ_Spikeball,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_8x8),obColType(a0)
		move.b	#$C,obDispWid(a0)
		move.w	obX(a0),obSeesaw_StartX(a0)
		addi.w	#$28,obX(a0)				; move spikeball to right side
		move.w	obY(a0),obSeesaw_StartY(a0)
		move.b	#1,obFrame(a0)
		btst	#staFlipX,obStatus(a0)		; is seesaw flipped?
		beq.s	See_SpikeAction				; if not, branch
		subi.w	#$50,obX(a0)				; move spikeball to the left side
		move.b	#2,obSeesaw_State(a0)		; spikeball is on left side
; ---------------------------------------------------------------------------

See_SpikeAction:	; Routine 8
		movea.w	obSeesaw_Parent(a0),a1		; get parent seesaw's address
		moveq	#0,d0
		move.b	obSeesaw_State(a0),d0
		sub.b	obSeesaw_State(a1),d0		; d0 = seesaw/spikeball state difference
		beq.s	.align_spike				; branch if same
		bcc.s	.spike_from_left			; branch if spikeball is launched from left
		neg.b	d0

	.spike_from_left:
		move.w	#-$818,d1					; spikeball speed from flat seesaw
		move.w	#-$114,d2
		cmpi.b	#1,d0						; is seesaw flat?
		beq.s	.launch_spikeball			; if yes, branch
		move.w	#-$AF0,d1					; moderate spikeball speed
		move.w	#-$CC,d2
		cmpi.w	#$A00,obSeesaw_HitSpeed(a1)	; has Sonic landed on seesaw with > $A00 force?
		blt.s	.launch_spikeball			; if yes, branch
		move.w	#-$E00,d1					; max spikeball speed
		move.w	#-$A0,d2

	.launch_spikeball:
		move.w	d1,obVelY(a0)				; set spikeball speed (TO-DO: is there a way to use movem here?)
		move.w	d2,obVelX(a0)
		move.w	obX(a0),d0
		sub.w	obSeesaw_StartX(a0),d0
		bcc.s	.from_x_start				; branch if spikeball is in its starting position
		neg.w	obVelX(a0)					; launch in opposite direction

	.from_x_start:
		addq.b	#2,obRoutine(a0)			; -> See_SpikeFall
		bra.s	See_SpikeFall
; ===========================================================================

	.align_spike:
		lea		(obSeesaw_YPos).l,a2		; address for list of relative y positions
		moveq	#0,d0
		move.b	obFrame(a1),d0				; get frame of parent seesaw
		moveq	#$28,d2						; x distance from center
		move.w	obX(a0),d1
		sub.w	obSeesaw_StartX(a0),d1
		bcc.s	.spike_from_left2			; branch if spikeball is left of its start position
		neg.w	d2
		addq.w	#2,d0

	.spike_from_left2:
		add.w	d0,d0
		move.w	obSeesaw_StartY(a0),d1		; get initial y position
		add.w	(a2,d0.w),d1				; add relative position
		move.w	d1,obY(a0)					; update position
		add.w	obSeesaw_StartX(a0),d2
		move.w	d2,obX(a0)
		clr.w	obYSub(a0)
		clr.w	obXSub(a0)
		rts	
; ===========================================================================

See_SpikeFall:	; Routine $A
		tst.w	obVelY(a0)					; is spikeball falling down?
		bpl.s	.downwards					; if yes, branch
		bsr.w	ObjectFall					; apply gravity and update position
		move.w	obSeesaw_StartY(a0),d0
		subi.w	#47,d0
		cmp.w	obY(a0),d0					; is spikeball more than 47 ($2F) px above seesaw?
		bgt.s	.no_double_grav	
		bra.w	ObjectFall					; apply more gravity (is there a better way to do this)?

	.no_double_grav:
		rts	
; ===========================================================================

	.downwards:
		bsr.w	ObjectFall
		movea.w	obSeesaw_Parent(a0),a1		; get parent seesaw's RAM address
		lea		(obSeesaw_YPos).l,a2		; address for list of relative y positions
		moveq	#0,d0
		move.b	obFrame(a1),d0				; get frame of parent seesaw
		move.w	obX(a0),d1
		sub.w	obSeesaw_StartX(a0),d1
		bcc.s	.spike_from_left			; branch if spikeball is left of its start position
		addq.w	#2,d0

	.spike_from_left:
		add.w	d0,d0
		move.w	obSeesaw_StartY(a0),d1		; get initial y position
		add.w	(a2,d0.w),d1				; add relative position
		cmp.w	obY(a0),d1					; has spikeball reached that position?
		bgt.s	.exit						; if not, branch

		movea.w	obSeesaw_Parent(a0),a1
		moveq	#2,d1
		tst.w	obVelX(a0)					; is spikeball moving left?
		bmi.s	.moving_left				; if yes, branch
		moveq	#0,d1

.moving_left:
		move.b	d1,obSeesaw_State(a1)		; update state for seesaw and spikeball
		move.b	d1,obSeesaw_State(a0)
		cmp.b	obFrame(a1),d1				; get seesaw frame
		beq.s	.skip_spring				; branch if 0 (left side raised)
		bclr	#staSonicOnObj,obStatus(a1)	; clear flag for Sonic standing on seesaw
		beq.s	.skip_spring				; branch if already clear

		clr.b	ob2ndRout(a1)
		move.b	#2,obRoutine(a1)
		lea		(v_player).w,a2
		
	if SpinDashEnabled
		clr.b	obSpinDashFlag(a2)
	endif

		move.w	obVelY(a0),obVelY(a2)		; bounce Sonic with same speed the spikeball fell
		neg.w	obVelY(a2)					; spikeball down, Sonic up
		bset	#staAir,obStatus(a2)
		bclr	#staOnObj,obStatus(a2)
		clr.b	obJumping(a2)
		move.b	#aniID_Spring,obAnim(a2)	; change Sonic's animation to "spring"
		move.b	#2,obRoutine(a2)
		move.w	#sfx_Spring,d0
		jsr		(QueueSound2).w				; play spring sound

	.skip_spring:
		clr.l	obVelX(a0)					; stop x/y speeds
		subq.b	#2,obRoutine(a0)			; -> See_SpikeAction

	.exit:
		rts	
; ===========================================================================

obSeesaw_YPos:
		dc.w -8						; on raised side
		dc.w -$1C					; on flat
		dc.w -$2F					; on low side
		dc.w -$1C
		dc.w -8
; ===========================================================================

See_DataSlope:	binclude	"misc/slzssaw1.bin"
		even
See_DataFlat:	binclude	"misc/slzssaw2.bin"
		even
; ===========================================================================