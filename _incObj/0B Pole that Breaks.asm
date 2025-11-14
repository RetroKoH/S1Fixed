; ---------------------------------------------------------------------------
; Object 0B - pole that	breaks (LZ)
; Optimized by Hivebrain (S1Squared)
; ---------------------------------------------------------------------------

Pole:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pole_Index(pc,d0.w),d1
		jmp		Pole_Index(pc,d1.w)
; ===========================================================================

Pole_Index:	offsetTable
		offsetTableEntry.w Pole_Main
		offsetTableEntry.w Pole_Action
		offsetTableEntry.w Pole_Grab		; +++ Hivebrain added routine
		offsetTableEntry.w Pole_Hang		; +++ Hivebrain added routine
		offsetTableEntry.w Pole_Display
; ===========================================================================

Pole_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Pole,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Pole,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#8,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colSpecial|colSz_4x32),obColType(a0)
		moveq	#$F,d0
		and.b	obSubtype(a0),d0			; get object type (clamp at 0-F)
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,obPole_GrabTime(a0)		; set breakage time

Pole_Action:	; Routine 2
		bra.w	RememberState
; ===========================================================================

Pole_Grab:	; Routine 4
		clr.b	obColType(a0)
		lea		(v_player).w,a1
		cmpi.b	#4,obRoutine(a1)		; is Sonic hurt or dead?
		bhs.w	RememberState			; if yes, branch
		clr.l	obVelX(a1)				; stop all movement (obVelX and obVelY)
		move.w	obX(a0),d0
		addi.w	#$14,d0
		move.w	d0,obX(a1)				; align Sonic to pole
		bclr	#staFacing,obStatus(a1)
		move.b	#aniID_Hang,obAnim(a1)	; set Sonic's animation to "hanging"
		move.b	#1,obCtrlLock(a1)		; lock controls
		move.b	#1,(f_wtunnelallow).w	; disable wind tunnel
		addq.b	#2,obRoutine(a0)		; -> Pole_Hang
	; begin countdown to breakage

Pole_Hang:	; Routine 6
		lea		(v_player).w,a1
		subq.w	#1,obPole_GrabTime(a0)	; decrement time until break
		bmi.s	Pole_Break

; .moveup:
		move.w	obY(a0),d0
		subi.w	#$18,d0					; d0 = y position for top of pole
		move.b	(v_jpadheld_actual).w,d2
		btst	#bitUp,d2				; is "up" pressed?
		beq.s	.movedown				; if not, branch
		subq.w	#1,obY(a1)				; move Sonic up
		cmp.w	obY(a1),d0
		blo.s	.movedown
		move.w	d0,obY(a1)				; keep Sonic from moving beyond top of pole

.movedown:
		btst	#bitDn,d2				; is "down" pressed?
		beq.s	.letgo					; if not, branch
		addi.w	#$24,d0					; d0 = y position for bottom of pole
		addq.w	#1,obY(a1)				; move Sonic down
		cmp.w	obY(a1),d0
		bhs.s	.letgo
		move.w	d0,obY(a1)				; keep Sonic from moving beyond bottom of pole

.letgo:
		move.b	(v_jpadpressed_dup).w,d0
		andi.w	#btnABC,d0				; is A/B/C pressed?
		bne.s	Pole_Release			; if yes, branch
		bra.w	RememberState
; ===========================================================================

Pole_Break:
		move.b	#1,obFrame(a0)			; break	the pole

Pole_Release:
		addq.b	#2,obRoutine(a0)		; -> Pole_Display
		clr.b	obCtrlLock(a1)			; enable controls
		clr.b	(f_wtunnelallow).w		; enable water tunnel

Pole_Display:	; Routine 8
		bra.w	RememberState
; ===========================================================================