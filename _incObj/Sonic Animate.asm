; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Animate:
		lea		(Ani_Sonic).l,a1
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
		adda.w	(a1,d0.w),a1		; jump to appropriate animation	script
		move.b	(a1),d0
		bmi.s	.walkrunroll		; if animation is walk/run/roll/jump, branch
		move.b	obStatus(a0),d1
		andi.b	#maskFacing,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0)	; subtract 1 from frame duration
		bpl.s	.delay				; if time remains, branch
		move.b	d0,obTimeFrame(a0)	; load frame duration

.loadframe:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1	; load current frame number
		move.b	1(a1,d1.w),d0		; read sprite number from script
		; MarkeyJester Art Limit Extensions
		; Animations extended from [$00 - $7F] to [$00 - $FC]
		cmpi.b	#$FD,d0				; is it a flag from FD to FF?
		bhs.s	.end_FF				; if so, branch to flag routines
		; Art Limit Extensions End

.next:
		move.b	d0,obFrame(a0)		; load sprite number
		addq.b	#1,obAniFrame(a0)	; next frame number

.delay:
		rts	
; ===========================================================================

.end_FF:
		addq.b	#1,d0			; is the end flag = $FF	?
		bne.s	.end_FE			; if not, branch
		clr.b	obAniFrame(a0)	; restart the animation
		move.b	1(a1),d0		; read sprite number
		bra.s	.next
; ===========================================================================

.end_FE:
		addq.b	#1,d0				; is the end flag = $FE	?
		bne.s	.end_FD				; if not, branch
		move.b	2(a1,d1.w),d0		; read the next	byte in	the script
		sub.b	d0,obAniFrame(a0)	; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0		; read sprite number
		bra.s	.next
; ===========================================================================

.end_FD:
		addq.b	#1,d0					; is the end flag = $FD	?
		bne.s	.end					; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)	; read next byte, run that animation

.end:
		rts	
; ===========================================================================

.walkrunroll:
		subq.b	#1,obTimeFrame(a0)	; subtract 1 from frame duration
		bpl.s	.delay				; if time remains, branch
		addq.b	#1,d0				; is animation walking/running?
		bne.w	.rolljump			; if not, branch
		moveq	#0,d1
		move.b	obAngle(a0),d0		; get Sonic's angle
 	; Mercury Better handling of angles
		bmi.s	.ble
		beq.s	.ble
		subq.b	#1,d0

.ble:
	; Better handling of angles end
		move.b	obStatus(a0),d2
		andi.b	#maskFacing,d2		; is Sonic mirrored horizontally?
		bne.s	.flip				; if yes, branch
		not.b	d0					; reverse angle

.flip:
		addi.b	#$10,d0				; add $10 to angle
		bpl.s	.noinvert			; if angle is $0-$7F, branch
		moveq	#3,d1

.noinvert:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)

	if SpinDashEnabled=1
	; DeltaWooloo/Gio Spindash check
		tst.b   obSpinDashFlag(a0)		; GIO: Check if the Spin Dash is being charged
		bne.s   .skip					; GIO: If yes, skip the check for the pushing status.
	; Spindash check end
		btst	#staPush,obStatus(a0)	; is Sonic pushing something?
		bne.w	.push					; if yes, branch

.skip:
	else
		btst	#staPush,obStatus(a0)	; is Sonic pushing something?
		bne.w	.push					; if yes, branch
	endif

		lsr.b	#4,d0				; divide angle by $10
		andi.b	#6,d0				; angle	must be	0, 2, 4	or 6
		moveq	#0,d2
		move.w	obInertia(a0),d2	; get Sonic's speed
		bpl.s	.nomodspeed
		neg.w	d2					; modulus speed

.nomodspeed:
	if PeeloutEnabled=1
		lea		(SonAni_Dash).l,a1	; use Dashing animation
		cmpi.w	#$A00,d2			; is Sonic at Dashing speed?
		bhs.s	.running			; if yes, branch
	endif

		lea		(SonAni_Run).l,a1	; use running animation
		cmpi.w	#$600,d2			; is Sonic at running speed?
		bhs.s	.running			; if yes, branch

		lea		(SonAni_Walk).l,a1	; use walking animation

; Get correct walking frame.
	;	move.b	d0,d1
	;	lsr.b	#1,d1
	;	add.b	d1,d0				; Angle 0 = 0; Angle 2 = 3 (+6 frames); Angle 4 = 6 (+12 frames); Angle 6 = 9 (+18 frames).
.walking:
		; Sonic 2 method for 8 frames (Sometimes accesses Dash frames when running)
		add.b	d0,d0				; Angle 0 = 0; Angle 2 = 4 (+8 frames); Angle 4 = 8 (+16 frames); Angle 6 = 12 (+24 frames).

.running:
		add.b	d0,d0				; Angle 0 = 0; Angle 2 = +4 frames; Angle 4 = (+8 frames); Angle 6 = (+12 frames).
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	.belowmax
		moveq	#0,d2				; max animation speed

.belowmax:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)	; modify frame duration
		bsr.w	.loadframe
		add.b	d3,obFrame(a0)		; modify frame number
		cmpi.b	#fr_SonRun44,d3
		bgt.s	.softlock
		rts

.softlock:
		nop
		bra.s	.softlock
; ===========================================================================

.rolljump:
		addq.b	#1,d0				; is animation rolling/jumping?
		bne.s	.push				; if not, branch
		move.w	obInertia(a0),d2	; get Sonic's speed
		bpl.s	.nomodspeed2
		neg.w	d2

.nomodspeed2:
		lea		(SonAni_Roll2).l,a1	; use fast animation
		cmpi.w	#$600,d2			; is Sonic moving fast?
		bhs.s	.rollfast			; if yes, branch
		lea		(SonAni_Roll).l,a1	; use slower animation

.rollfast:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	.belowmax2
		moveq	#0,d2

.belowmax2:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0)	; modify frame duration
		move.b	obStatus(a0),d1
		andi.b	#maskFacing,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	.loadframe
; ===========================================================================

.push:
		move.w	obInertia(a0),d2	; get Sonic's speed
		bmi.s	.negspeed
		neg.w	d2

.negspeed:
		addi.w	#$800,d2
		bpl.s	.belowmax3	
		moveq	#0,d2

.belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0)	; modify frame duration
		lea		(SonAni_Push).l,a1
		move.b	obStatus(a0),d1
		andi.b	#maskFacing,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	.loadframe

; End of function Sonic_Animate
