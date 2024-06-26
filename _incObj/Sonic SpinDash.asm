; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChkSpinDash:
		btst	#0,obSpinDashFlag(a0)	; already Spin Dashing?
		bne.s	Sonic_UpdateSpinDash	; if yes, branch to updating spin dash
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	.return					; if not ducking down, return
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	.return					; if not pressing ABC, return
		move.b	#aniID_SpinDash,obAnim(a0)
		move.w	#sfx_SpinDash,d0
		jsr		(PlaySound_Special).l
		addq.l	#4,sp
		bset	#0,obSpinDashFlag(a0)

	if SpinDashCancel=1	; Mercury Spin Dash Cancel
		move.w	#$80,obSpinDashCounter(a0)
	else
		clr.w	obSpinDashCounter(a0)
	endc	; Spin Dash Cancel End

		cmpi.b	#$C,(v_air).w			; if he's drowning, branch to not make dust
		bcs.s	.nodust
		move.b	#1,(v_playerdust+obAnim).w
.nodust:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos

.return:
		rts
; ---------------------------------------------------------------------------

Sonic_UpdateSpinDash:
		move.b	#aniID_SpinDash,obAnim(a0)
		move.b	(v_jpadhold2).w,d0
		btst	#bitDn,d0
		bne.w	Sonic_ChargingSpinDash

		; unleash the charged spin dash and start rolling quickly:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#aniID_Roll,obAnim(a0)
		addq.w	#5,obY(a0)
		clr.b	obSpinDashFlag(a0)
		moveq	#0,d0
		move.b	obSpinDashCounter(a0),d0
		add.w	d0,d0
		move.w	#1,obVelX(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	SpinDashSpeeds(pc,d0.w),obInertia(a0)
	; Use inertia to set camera lag effect
		move.b	obInertia(a0),d0
		subq.b	#$8,d0
		add.b	d0,d0
		andi.b	#$1F,d0
		neg.b	d0
		addi.b	#$20,d0
		move.b	d0,(v_cameralag).w
	; Camera lag effect end
		btst	#staFacing,obStatus(a0)
		beq.s	.dontflip
		neg.w	obInertia(a0)

.dontflip:
		bset	#staSpin,obStatus(a0)		; Sonic is now spinning
		clr.b	(v_playerdust+obAnim).w
		move.w	#sfx_Teleport,d0
		jsr		(PlaySound_Special).l
		bra.w	loc_1AD78
; ---------------------------------------------------------------------------
SpinDashSpeeds:
		dc.w  $800		; 0
		dc.w  $880		; 1
		dc.w  $900		; 2
		dc.w  $980		; 3
		dc.w  $A00		; 4
		dc.w  $A80		; 5
		dc.w  $B00		; 6
		dc.w  $B80		; 7
		dc.w  $C00		; 8
; ---------------------------------------------------------------------------

Sonic_ChargingSpinDash:				; If still charging the dash...
		tst.w	obSpinDashCounter(a0)
		beq.s	loc_1AD48
		
	if SpinDashNoRevDown=1 ; Mercury Spin Dash No Rev Down
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0
		bne.s	loc_1AD48	
	endif	; Spin Dash No Rev Down end

		move.w	obSpinDashCounter(a0),d0
		lsr.w	#5,d0
		sub.w	d0,obSpinDashCounter(a0)	; SpinDash rev down effect applied
		
	if SpinDashCancel=1	; Mercury Spin Dash Cancel
		cmpi.w	#$1F,obSpinDashCounter(a0)
		bne.s	.skip
		clr.w	obSpinDashCounter(a0)		; clear SpinDash Counter
		clr.b	obSpinDashFlag(a0)			; cancel SpinDash
		bra.s	loc_1AD78					; branch
		
.skip:
	endif	; Spin Dash Cancel End	

		bcc.s	loc_1AD48
		clr.w	obSpinDashCounter(a0)

loc_1AD48:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0
		beq.w	loc_1AD78
		;move.w	#(id_SpinDash<<8),obAnim(a0)	; id_SpinDash
		addi.w	#$200,obSpinDashCounter(a0)
		cmpi.w	#$800,obSpinDashCounter(a0)
		bcs.s	.sound
		move.w	#$800,obSpinDashCounter(a0)
.sound:
		move.w	#sfx_SpinDash,d0				; sfx_SpinDash
		jsr		(PlaySound_Special).l

loc_1AD78:
		addq.l	#4,sp							; increase stack ptr
		cmpi.w	#$60,(v_lookshift).w
		beq.s	loc_1AD8C
		bcc.s	loc_1AD88
		addq.w	#4,(v_lookshift).w

loc_1AD88:
		subq.w	#2,(v_lookshift).w

loc_1AD8C:
		bsr.w	Sonic_LevelBound
		bra.w	Sonic_AnglePos
