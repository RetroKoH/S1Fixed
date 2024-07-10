; ---------------------------------------------------------------------------
; Subroutine to check for starting to perform a peelout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChkPeelout:
		btst	#1,obSpinDashFlag(a0) ; obSpinDashFlag is also used for Peelout
		bne.s	Sonic_DashLaunch
		cmpi.b	#aniID_LookUp,obAnim(a0)
		bne.s	.return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	.return
		move.b	#aniID_Run,obAnim(a0)
		clr.w	obSpinDashCounter(a0)
		move.w	#sfx_Charge,d0
		jsr		(PlaySound_Special).l
		addq.l	#4,sp
		bset	#1,obSpinDashFlag(a0)

		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos

.return:
		rts
; ---------------------------------------------------------------------------

Sonic_DashLaunch:
		move.b	#aniID_Peelout,obAnim(a0)
		move.b	(v_jpadhold2).w,d0
		btst	#bitUp,d0
		bne.w	Sonic_DashCharge

		clr.b	obSpinDashFlag(a0)			; stop Dashing
		cmpi.w	#$1E,obSpinDashCounter(a0)	; have we been charging long enough?
		bne.s	Sonic_DashStopSound
		move.b	#aniID_Dash,obAnim(a0)		; launches here
		move.w	#1,obVelX(a0)				; force X speed to nonzero for camera lag's benefit
		move.w	#$C00,obInertia(a0)			; set running speed
	if SuperMod=1
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.notSuper
		move.w	#$F00,obInertia(a0)			; set running speed
.notSuper:
	endif
		move.w	obInertia(a0),d0
		subq.b	#$8,d0
		add.b	d0,d0
		andi.b	#$1F,d0
		neg.b	d0
		addi.b	#$20,d0
		move.b	d0,(v_cameralag).w			; use it to set the camera lag
		btst	#staFacing,obStatus(a0)
		beq.s	.dontflip
		neg.w	obInertia(a0)

.dontflip:
	; Improved section by DeltaWooloo
		move.w	#sfx_Release,d0
		jsr		(PlaySound_Special).l
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bra.w	Sonic_DashResetScr
; ---------------------------------------------------------------------------

Sonic_DashCharge:				; If still charging the dash...
		cmpi.w	#$1E,obSpinDashCounter(a0)
		beq.s	Sonic_DashResetScr
		addi.w	#1,obSpinDashCounter(a0)
		bra.s	Sonic_DashResetScr

Sonic_DashStopSound:
		move.w	#sfx_Stop,d0
		jsr		(PlaySound_Special).l
		clr.w	obInertia(a0)

Sonic_DashResetScr:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.finish
		bcc.s	.skip
		addq.w	#4,(v_lookshift).w

.skip:
		subq.w	#2,(v_lookshift).w

.finish:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos
