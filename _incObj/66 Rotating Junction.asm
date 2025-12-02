; ---------------------------------------------------------------------------
; Object 66 - rotating disc junction that grabs Sonic (SBZ)
; ---------------------------------------------------------------------------

Junction:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Jun_Index(pc,d0.w),d1
		jmp		Jun_Index(pc,d1.w)
; ===========================================================================
Jun_Index:		offsetTable
		offsetTableEntry.w Jun_Main
		offsetTableEntry.w Jun_Action
		offsetTableEntry.w Jun_Display
		offsetTableEntry.w Jun_Release
; ===========================================================================

Jun_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#1,d1
		movea.l	a0,a1
		bra.s	.makeitem
; ===========================================================================

	.repeat:
	; This could be optimized
		jsr		(FindFreeObj).l				; find free object RAM slot
		bne.s	.fail						; branch if not found
		_move.b	#id_Junction,obID(a1)		; load 2nd junction object
		addq.b	#4,obRoutine(a1)			; -> Jun_Display
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obFrame(a1)			; use large circular sprite

	.makeitem:
		move.l	#Map_Jun,obMap(a1)
		move.w	#make_art_tile(ArtTile_SBZ_Junction,2,0),obGfx(a1)
		ori.b	#4,obRender(a1)
		move.b	#$38,obDispWid(a1)

	.fail:
		dbf		d1,.repeat					; repeat once for large background circle

		move.b	#$30,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#1,obJun_Direction(a0)		; set default direction (anticlockwise)
		move.b	obSubtype(a0),obJun_ButtonNum(a0)

Jun_Action:	; Routine 2
		bsr.w	Jun_Update					; check if button is pressed and animate the junction
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	Jun_Display					; if not, branch
		move.w	#$30,d1
		move.w	d1,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		btst	#staSonicPush,obStatus(a0)	; is Sonic pushing against the disc?
		beq.w	Jun_Display					; if not, branch

		lea		(v_player).w,a1
		moveq	#$E,d1						; d1 = frame $E
		move.w	obX(a1),d0
		cmp.w	obX(a0),d0					; is Sonic to the left of the disc?
		blo.s	.isleft						; if yes, branch
		moveq	#7,d1						; d1 = frame 7	

	.isleft:
		cmp.b	obFrame(a0),d1				; is the gap next to Sonic?
		bne.s	Jun_Display					; if not, branch

		move.b	d1,obJun_GrabFrame(a0)
		addq.b	#4,obRoutine(a0)			; -> Jun_Release
		move.b	#1,obCtrlLock(a1)			; lock controls
		move.b	#aniID_Roll,obAnim(a1)		; make Sonic use "rolling" animation

	if SpinDashEnabled
		clr.b	obSpinDashFlag(a1)
		clr.w	obSpinDashCounter(a1)
		clr.b	(v_playerdust+obAnim).w
	endif

		move.w	#$800,obInertia(a1)
		clr.w	obVelX(a1)
		clr.w	obVelY(a1)
		bclr	#staSonicPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)
		bset	#staAir,obStatus(a1)
		move.w	obX(a1),d2
		move.w	obY(a1),d3
		bsr.w	Jun_MoveSonic				; update Sonic's position within the junction
		add.w	d2,obX(a1)
		add.w	d3,obY(a1)
		asr		obX(a1)
		asr		obY(a1)

Jun_Display:	; Routine 4
		bra.w	RememberState
; ===========================================================================

Jun_Release:	; Routine 6
		move.b	obFrame(a0),d0
		cmpi.b	#4,d0					; is gap pointing down (frame == 4)?
		beq.s	.release				; if yes, branch
		cmpi.b	#7,d0					; is gap pointing right (frame == 7)?
		bne.s	.dontrelease			; if not, branch

.release:
		cmp.b	obJun_GrabFrame(a0),d0	; is gap on the frame Sonic was grabbed on?
		beq.s	.dontrelease			; if yes, branch
		lea		(v_player).w,a1
		clr.w	obVelX(a1)
		move.w	#$800,obVelY(a1)		; drop Sonic straight down
		cmpi.b	#4,d0					; is gap pointing down (frame == 4)?
		beq.s	.isdown					; if yes, branch
		move.l	#$08000800,obVelX(a1)	; launch Sonic diagonally down-right (set both speeds to $800)

.isdown:
		clr.b	obCtrlLock(a1)			; unlock controls
		subq.b	#4,obRoutine(a0)		; -> Jun_Action
; TO-DO: (Add optional dash sfx here)

.dontrelease:
		bsr.s	Jun_Update				; check if button is pressed and animate the junction
		bsr.s	Jun_MoveSonic			; update Sonic's position within the junction
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update direction when button is pressed and animate
; ---------------------------------------------------------------------------

;Jun_ChkSwitch:
Jun_Update:
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obJun_ButtonNum(a0),d0
		btst	#0,(a2,d0.w)			; is switch pressed?
		beq.s	.unpressed				; if not, branch

		tst.b	obJun_ButtonFlag(a0)	; has switch previously	been pressed?
		bne.s	.animate				; if yes, branch
		neg.b	obJun_Direction(a0)		; reverse direction
		move.b	#1,obJun_ButtonFlag(a0)	; set to "previously pressed"
		bra.s	.animate
; ===========================================================================

	.unpressed:
		clr.b	obJun_ButtonFlag(a0)	; set to "not yet pressed"

	.animate:
		subq.b	#1,obTimeFrame(a0)		; decrement frame timer
		bpl.s	.nochange				; if time remains, branch
		move.b	#7,obTimeFrame(a0)		; 7 frames until next update
		move.b	obJun_Direction(a0),d1
		move.b	obFrame(a0),d0
		add.b	d1,d0					; add direction (1 or -1) to frame
		andi.b	#$F,d0
		move.b	d0,obFrame(a0)			; update frame

	.nochange:
		rts	
; End of function Jun_Update
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to move Sonic while he's in the junction
; Slightly optimized to take word-values, removing the need for the ext
; ---------------------------------------------------------------------------

;Jun_ChgPos:
Jun_MoveSonic:
		lea		(v_player).w,a1
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		add.w	d0,d0					; d0 = current frame * 4
		lea		.data(pc,d0.w),a2		; jump to relevant position data

		; set x-offset
		move.w	(a2)+,d0
		add.w	obX(a0),d0				; get x pos relative to junction
		move.w	d0,obX(a1)				; update Sonic's x pos

		; set y-offset
		move.w	(a2)+,d0
		add.w	obY(a0),d0				; get y pos relative to junction
		move.w	d0,obY(a1)				; update Sonic's y pos
		rts
; End of function Jun_MoveSonic
; ===========================================================================

; Now word-length (It's only slightly faster)
.data:		; x pos, y pos
		dc.w -$20,    0					; w
		dc.w -$1E,   $E					; wsw
		dc.w -$18,  $18					; sw
		dc.w  -$E,  $1E					; ssw
		dc.w    0,  $20					; s
		dc.w   $E,  $1E					; sse
		dc.w  $18,  $18					; se
		dc.w  $1E,   $E					; ese
		dc.w  $20,    0					; e
		dc.w  $1E,  -$E					; ene
		dc.w  $18, -$18					; ne
		dc.w   $E, -$1E					; nne
		dc.w    0, -$20					; n
		dc.w  -$E, -$1E					; nnw
		dc.w -$18, -$18					; nw
		dc.w -$1E,  -$E					; wnw
; ===========================================================================