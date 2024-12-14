; ---------------------------------------------------------------------------
; Object 0B - pole that	breaks (LZ)
; ---------------------------------------------------------------------------

pole_time = objoff_30		; time between grabbing the pole & breaking
pole_grabbed = objoff_32		; flag set when Sonic grabs the pole

Pole:
	; LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		cmpi.b	#2,d0
		beq.s	Pole_Action
		
		tst.b	d0
		bne.w	RememberState
	; Object Routine Optimization End

Pole_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Pole,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Pole,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#8,obActWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$E1,obColType(a0)
		moveq	#$F,d0
		and.b	obSubtype(a0),d0			; get object type (clamp at 0-F)
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,pole_time(a0)			; set breakage time

Pole_Action:	; Routine 2
		lea		(v_player).w,a1				; to be used in the next block of code
		tst.b	pole_grabbed(a0)			; has pole already been grabbed?
		beq.s	.grab						; if not, branch
		tst.w	pole_time(a0)
		beq.s	.moveup
		subq.w	#1,pole_time(a0)			; decrement time until break
		bne.s	.moveup
		move.b	#1,obFrame(a0)				; break	the pole
		bra.s	.release
; ===========================================================================

.moveup:
		move.w	obY(a0),d0
		subi.w	#$18,d0
		btst	#bitUp,(v_jpadhold1).w	; is "up" pressed?
		beq.s	.movedown				; if not, branch
		subq.w	#1,obY(a1)				; move Sonic up
		cmp.w	obY(a1),d0
		blo.s	.movedown
		move.w	d0,obY(a1)

.movedown:
		addi.w	#$24,d0
		btst	#bitDn,(v_jpadhold1).w	; is "down" pressed?
		beq.s	.letgo					; if not, branch
		addq.w	#1,obY(a1)				; move Sonic down
		cmp.w	obY(a1),d0
		bhs.s	.letgo
		move.w	d0,obY(a1)

.letgo:
		move.b	(v_jpadpress2).w,d0
		andi.w	#btnABC,d0				; is A/B/C pressed?
		beq.w	RememberState			; if not, branch

.release:
		clr.b	obColType(a0)
		addq.b	#2,obRoutine(a0)		; goto RememberState next
		clr.b	obCtrlLock(a1)
		clr.b	(f_wtunnelallow).w
		clr.b	pole_grabbed(a0)
		bra.w	RememberState
; ===========================================================================

.grab:
		tst.b	obColProp(a0)			; has Sonic touched the	pole?
		beq.w	RememberState			; if not, branch
		move.w	obX(a0),d0
		addi.w	#$14,d0
		cmp.w	obX(a1),d0
		bhs.w	RememberState
		clr.b	obColProp(a0)
		cmpi.b	#4,obRoutine(a1)
		bhs.w	RememberState
		clr.w	obVelX(a1)				; stop Sonic moving
		clr.w	obVelY(a1)				; stop Sonic moving
		move.w	obX(a0),d0
		addi.w	#$14,d0
		move.w	d0,obX(a1)
		bclr	#staFacing,obStatus(a1)
		move.b	#aniID_Hang,obAnim(a1)	; set Sonic's animation to "hanging"
		move.b	#1,obCtrlLock(a1)		; lock controls
		move.b	#1,(f_wtunnelallow).w	; disable wind tunnel
		move.b	#1,pole_grabbed(a0)		; begin countdown to breakage
		bra.w	RememberState
; ===========================================================================
