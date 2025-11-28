; ---------------------------------------------------------------------------
; Object 67 - disc that	you run	around (SBZ)
; Optimizations based on S1Squared and Sonic Clean Engine
;
; subtypes:
;	%SSSSRRRR
;	SSSS - rotation speed (1-7 = clockwise; 8-$F = anticlockwise)
;	RRRR - radius (see Disc_Radii)
; ---------------------------------------------------------------------------

; ===========================================================================

Disc_Radii:
		dc.b $18, $48
		dc.b $10, $38
; ===========================================================================

RunningDisc:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Disc_Action
	; Object Routine Optimization End

Disc_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)					; -> Disc_Action
		move.l	#Map_Disc,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Disc,2,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		move.w	obX(a0),obDisc_StartX(a0)
		move.w	obY(a0),obDisc_StartY(a0)

		moveq	#0,d0
		move.b	obSubtype(a0),d0					; get object subtype
		moveq	#$F,d1
		and.b	d0,d1								; read only the low nybble
		add.b	d1,d1
		lea		Disc_Radii(pc,d1.w),a2
		move.b	(a2)+,obDisc_RadiusInner(a0)		; unused smaller disc
		move.b	(a2)+,obDisc_RadiusOuter(a0)

		andi.b	#$F0,d0								; read only the	high nybble
		ext.w	d0
		asl.w	#3,d0								; multiply by 8
		move.w	d0,obDisc_Rotation(a0)				; set rotation speed (only $200 is used)
		move.b	obStatus(a0),d0						; get object status
		ror.b	#2,d0								; move x/yflip bits to top
		andi.b	#$C0,d0								; read only those
		move.b	d0,obAngle(a0)						; use as starting angle

Disc_Action:	; Routine 2
		bsr.s	Disc_MoveSonic
		move.w	obDisc_Rotation(a0),d1
		add.w	d1,obAngle(a0)						; update angle (d1 is obDisc_Rotation)
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w						; convert to sine/cosine
		move.w	obDisc_StartY(a0),d2
		move.w	obDisc_StartX(a0),d3
		moveq	#0,d4
		move.b	obDisc_RadiusInner(a0),d4
		lsl.w	#8,d4
		move.l	d4,d5
		muls.w	d0,d4
		swap	d4
		muls.w	d1,d5
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a0)							; update position
		move.w	d5,obX(a0)

Disc_ChkDel:
		offscreen.s	.delete,obDisc_StartX(a0)
		jmp	(DisplaySprite).l

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to detect collision with disc and set Sonic's inertia
; ---------------------------------------------------------------------------

Disc_MoveSonic:
		moveq	#0,d2
		move.b	obDisc_RadiusOuter(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea		(v_player).w,a1						; a1 = object RAM of Sonic
		move.w	obX(a1),d0
		sub.w	obDisc_StartX(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bhs.s	.detach
		move.w	obY(a1),d1
		sub.w	obDisc_StartY(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bhs.s	.detach								; branch if Sonic is outside the range of the disc
		btst	#staAir,obStatus(a1)				; is Sonic in the air?
		beq.s	.attach								; if not, branch
		clr.b	obDisc_SonicAttached(a0)
		rts	
; ===========================================================================

	.detach:
		tst.b	obDisc_SonicAttached(a0)			; was Sonic on the disc last frame?
		beq.s	.skip_clear							; if not, branch
		clr.b	obOnWheel(a1)
		clr.b	obDisc_SonicAttached(a0)

	.skip_clear:
		rts	
; ===========================================================================

	.attach:
		tst.b	obDisc_SonicAttached(a0)			; was Sonic on the disc last frame?
		bne.s	.skip_init							; if yes, branch
		move.b	#1,obDisc_SonicAttached(a0)			; set flag for Sonic being on the disc
		btst	#staSpin,obStatus(a1)				; is Sonic jumping?
		bne.s	.jumping							; if yes, branch
		move.b	#aniID_Walk,obAnim(a1)				; use walking animation

	.jumping:
		bclr	#staPush,obStatus(a1)
		move.b	#aniID_Run,obPrevAni(a1)			; restart Sonic's animation
		move.b	#1,obOnWheel(a1)					; keep Sonic stuck to disc until he jumps

	.skip_init:
		move.w	obInertia(a1),d0
		tst.w	obDisc_Rotation(a0)					; check rotation direction (only $200 is used)
		bpl.s	.clockwise							; branch if positive

		cmpi.w	#-$400,d0
		ble.s	.chk_max_neg
		move.w	#-$400,obInertia(a1)				; set minimum inertia on disc
		rts	
; ===========================================================================

	.chk_max_neg:
		cmpi.w	#-$F00,d0
		bge.s	.exit
		move.w	#-$F00,obInertia(a1)				; set maximum inertia on disc

	.exit:
		rts	
; ===========================================================================

	.clockwise:
		cmpi.w	#$400,d0
		bge.s	.chk_max
		move.w	#$400,obInertia(a1)					; set minimum inertia on disc
		rts	
; ===========================================================================

	.chk_max:
		cmpi.w	#$F00,d0
		ble.s	.exit2
		move.w	#$F00,obInertia(a1)					; set maximum inertia on disc

	.exit2:
		rts	
; ===========================================================================