; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6

	; MoDule Super Sonic Roll Speed fix
		moveq	#6,d5	; natural roll deceleration = 1/2 normal acceleration
		btst    #staWater,obStatus(a0)				; Is the character underwater?
		beq.s   .nowater							; If not, branch
		moveq	#3,d5
;		move.w	(v_sonspeedacc).w,d5
;		asr.w	#1,d5
	; This will also make roll decel the same when using speed shoes
	; if you have another character with different acceleration, adjust accordingly
	; I'll consider changing ApplySpeedSettings to add a value for roll deceleration

.nowater:
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_131CC
		tst.b	obLRLock(a0)
		bne.s	.notright
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_RollLeft

.notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_RollRight

.notright:
		move.w	obInertia(a0),d0
		beq.s	loc_131AA
		bmi.s	loc_1319E
		sub.w	d5,d0
		bcc.s	loc_13198
		clr.w	d0

loc_13198:
		move.w	d0,obInertia(a0)
		bra.s	loc_131AA
; ===========================================================================

loc_1319E:
		add.w	d5,d0
		bcc.s	loc_131A6
		clr.w	d0

loc_131A6:
		move.w	d0,obInertia(a0)

loc_131AA:
		tst.w	obInertia(a0)		; is Sonic moving?
		bne.s	loc_131CC			; if yes, branch

	if SpinDashEnabled=1
		tst.b	obSpinDashFlag(a0)
		bne.s	Sonic_KeepRolling
	endif

		bclr	#staSpin,obStatus(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.b	#aniID_Wait,obAnim(a0)	; use "standing" animation
		subq.w	#5,obY(a0)

	if SpinDashEnabled=1
		bra.s	loc_131CC

; ---------------------------------------------------------------------------
; DeltaWooloo: This part is from Sonic 2
Sonic_KeepRolling:
		move.w	#$400,obInertia(a0)
		btst	#staFacing,obStatus(a0)
		beq.s	loc_131CC
		neg.w	obInertia(a0)
	endif

loc_131CC:
	; Mercury Screen Scroll While Rolling Fix
		cmpi.w	#$60,(v_lookshift).w
		beq.s	.cont2
		bcc.s	.cont1
		addq.w	#4,(v_lookshift).w

.cont1:
		subq.w	#2,(v_lookshift).w

.cont2:
	; Screen Scroll While Rolling Fix End

		move.b	obAngle(a0),d0
		jsr		(CalcSine).w

	; Devon Rolling speed cap fix
		move.w  obInertia(a0),d2
		muls.w  d2,d0
		asr.l   #8,d0
	if RollSpeedCapEnabled=1 ; RetroKoH Disable Rolling Speed Cap
		cmpi.w  #$1000,d0
		ble.s   .checkNegY
		move.w  #$1000,d0

.checkNegY:
		cmpi.w  #-$1000,d0
		bge.s   .setVelocityY
		move.w  #-$1000,d0
	endif

.setVelocityY:
		move.w  d0,obVelY(a0)			; store velocity Y
		
		muls.w  d2,d1
		asr.l   #8,d1
	
	if RollSpeedCapEnabled=1 ; RetroKoH Disable Rolling Speed Cap
		cmpi.w  #$1000,d1
		ble.s   .checkNegX
		move.w  #$1000,d1

.checkNegX:
		cmpi.w  #-$1000,d1
		bge.s   .setVelocityX
		move.w  #-$1000,d1
	endif

.setVelocityX:
		move.w  d1,obVelX(a0)
	; Devon Rolling speed cap fix End

		bra.w	loc_1300C
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_1320A
		bpl.s	loc_13218

loc_1320A:
		bset	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0)	; use "rolling" animation
		rts	
; ===========================================================================

loc_13218:
		sub.w	d4,d0
		bcc.s	loc_13220
		clr.w	d0				; Mercury Rolling Turn Around Fix

loc_13220:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_1323A
		bclr	#staFacing,obStatus(a0)
		move.b	#aniID_Roll,obAnim(a0) ; use "rolling" animation
		rts	
; ===========================================================================

loc_1323A:
		add.w	d4,d0
		bcc.s	loc_13242
		clr.w	d0				; Mercury Rolling Turn Around Fix

loc_13242:
		move.w	d0,obInertia(a0)
		rts	
; End of function Sonic_RollRight
