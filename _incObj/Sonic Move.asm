; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_slidemode).w
		bne.w	loc_12FEE
		tst.b	obLRLock(a0)
		bne.w	Sonic_ResetScr
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	.notleft				; if not, branch
		bsr.w	Sonic_MoveLeft

.notleft:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	.notright				; if not, branch
		bsr.w	Sonic_MoveRight

.notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0					; is Sonic on a	slope?
		bne.w	Sonic_ResetScr			; if yes, branch
		tst.w	obInertia(a0)			; is Sonic moving?
		bne.w	Sonic_ResetScr			; if yes, branch
		bclr	#staPush,obStatus(a0)	; clear push status
		move.b	#aniID_Wait,obAnim(a0)	; use "standing" animation
		btst	#staOnObj,obStatus(a0)	; is Sonic on an object?
		beq.s	Sonic_Balance
		moveq	#0,d0
	; RetroKoH obPlatform SST mod
		move.w	obPlatformAddr(a0),d0
		addi.l	#v_objspace,d0
		movea.l	d0,a1	; a1=object
		; Alt method
;		lea		(v_objspace).w,a1
;		lea		(a1,d0.w),a1
	; obPlatform SST mod end
		tst.b	obStatus(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1

	if CDBalancing=1
		blt.s	Sonic_BalanceLeft
		cmp.w	d2,d1
		bge.s	Sonic_BalanceRight
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr		(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,obFrontAngle(a0)
		beq.s	Sonic_BalanceRight
		cmpi.b	#3,obRearAngle(a0)
		bne.s	Sonic_LookUp

Sonic_BalanceLeft:
		btst	#staFacing,obStatus(a0)		; is Sonic facing left?	;Mercury Constants
		beq.s	Sonic_BalanceBackward		; if not, balance backward
		move.b	#aniID_Balance2,obAnim(a0)	; use forward balancing animation
		bra.w	Sonic_ResetScr				; branch

Sonic_BalanceRight:
		btst	#staFacing,obStatus(a0)	; is Sonic facing left?	;Mercury Constants
		bne.s	Sonic_BalanceBackward	; if so, balance backward
		move.b	#aniID_Balance2,obAnim(a0) ; use forward balancing animation
		bra.w	Sonic_ResetScr	; branch

Sonic_BalanceBackward:
		move.b	#aniID_Balance3,obAnim(a0) ; use backward balancing animation
		bra.w	Sonic_ResetScr

	else

		blt.s	Sonic_BalanceOnObjLeft	;loc_12F6A
		cmp.w	d2,d1
		bge.s	Sonic_BalanceOnObjRight	;loc_12F5A
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr		(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
;Sonic_BalanceRight:
		cmpi.b	#3,obFrontAngle(a0)
		bne.s	Sonic_BalanceLeft

Sonic_BalanceOnObjRight: ;loc_12F5A
		bclr	#staFacing,obStatus(a0)
		bra.s	Sonic_BalanceSetAnim
; ===========================================================================

Sonic_BalanceLeft:
		cmpi.b	#3,obRearAngle(a0)
		bne.s	Sonic_LookUp

Sonic_BalanceOnObjLeft: ;loc_12F6A
		bset	#staFacing,obStatus(a0)

Sonic_BalanceSetAnim:
		move.b	#aniID_Balance,obAnim(a0)	; use "balancing" animation
		bra.w	Sonic_ResetScr
; ===========================================================================
	endif

Sonic_LookUp:
		btst	#bitUp,(v_jpadhold2).w		; is up being pressed?
		beq.s	Sonic_Duck					; if not, branch
		move.b	#aniID_LookUp,obAnim(a0)	; use "looking up" animation

	if SpinDashEnabled=1	; S2 Scroll Delay -- Spin Dash Enabled
		addq.b	#1,(v_scrolldelay).w		; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w		; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset				; if not, skip ahead without looking up
		move.b	#120,(v_scrolldelay).w 		; move the scroll delay value into the scroll timer so it won't continue to count higher
	endif	; S2 Scroll Delay -- Spin Dash Enabled End

		; Mercury Look Shift Fix
		move.w	(v_screenposy).w,d0		; get camera top coordinate
		sub.w	(v_limittop2).w,d0		; subtract zone's top bound from it
		add.w	(v_lookshift).w,d0		; add default offset
		cmpi.w	#$C8,d0					; is offset <= $C8?
		ble.s	.skip					; if so, branch
		move.w	#$C8,d0					; set offset to $C8
		
	.skip:
		cmp.w	(v_lookshift).w,d0
		ble.s	loc_12FC2
		; Look Shift Fix end
		addq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_Duck:
		btst	#bitDn,(v_jpadhold2).w	; is down being pressed?
		beq.s	Sonic_ResetScr			; if not, branch
		move.b	#aniID_Duck,obAnim(a0)		; use "ducking" animation

	if SpinDashEnabled=1	; S2 Scroll Delay -- Spin Dash Enabled
		addq.b	#1,(v_scrolldelay).w		; add 1 to the scroll timer
		cmpi.b	#120,(v_scrolldelay).w		; is it equal to or greater than the scroll delay?
		bcs.s	Sonic_LookReset				; if not, skip ahead without looking down
		move.b	#120,(v_scrolldelay).w 		; move the scroll delay value into the scroll timer so it won't continue to count higher
	endif	; S2 Scroll Delay -- Spin Dash Enabled End

		; Mercury Look Shift Fix
		move.w	(v_screenposy).w,d0		; get camera top coordinate
		sub.w	(v_limitbtm2).w,d0		; subtract zone's bottom bound from it (creating a negative number)
		add.w	(v_lookshift).w,d0		; add default offset
		cmpi.w	#8,d0					; is offset > 8?
		bgt.s	.skip					; if greater than 8, branch
		move.w	#8,d0					; set offset to 8

	.skip:
		cmp.w	(v_lookshift).w,d0
		bge.s	loc_12FC2
		; Look Shift Fix End
		subq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_ResetScr:
	if SpinDashEnabled=1	; S2 Scroll Delay -- Spin Dash Enabled
		move.b	#0,(v_scrolldelay).w	; clear the scroll timer, because up/down are not being held

Sonic_LookReset:	; added branch point that the new scroll delay code skips ahead to
	endif
		cmpi.w	#$60,(v_lookshift).w ; is screen in its default position?
		beq.s	loc_12FC2	; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,(v_lookshift).w ; move screen back to default

loc_12FBE:
		subq.w	#2,(v_lookshift).w ; move screen back to default

loc_12FC2:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right	pressed?
		bne.s	loc_12FEE	; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_12FEE
		bmi.s	loc_12FE2
		sub.w	d5,d0
		bcc.s	loc_12FDC
		clr.w	d0

loc_12FDC:
		move.w	d0,obInertia(a0)
		bra.s	loc_12FEE
; ===========================================================================

loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		clr.w	d0

loc_12FEA:
		move.w	d0,obInertia(a0)

loc_12FEE:
	if SpinDashEnabled=1
		tst.b	obSpinDashFlag(a0) 	
		bne.s	loc_1300C
	endif
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

loc_1300C:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307C
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

loc_13060:
		sub.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_13066:
		sub.w	d1,obVelX(a0)
		bset	#staPush,obStatus(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

loc_13078:
		add.w	d1,obVelY(a0)

locret_1307C:
		rts	
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_13086
		bpl.s	loc_130B2

loc_13086:
		bset	#staFacing,obStatus(a0)
		bne.s	loc_1309A
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obPrevAni(a0) ; restart Sonic's animation

loc_1309A:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6

	if GroundSpeedCapEnabled=0 ; Mercury Disable Ground Speed Cap
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_130A6
	endif	; Disable Ground Speed Cap End

		move.w	d1,d0

loc_130A6:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_130B2:
		sub.w	d4,d0
		bcc.s	loc_130BA
		move.w	#-$80,d0

loc_130BA:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#aniID_Stop,obAnim(a0)	; use "stopping" animation
		bclr	#staFacing,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr		(PlaySound_Special).l	; play stopping sound
	if SkidDustEnabled=1
		cmpi.b	#$C,(v_air)
		bcs.s	locret_130E8			; if he's drowning, branch to not make dust
		move.b	#6,(v_playerdust+obRoutine).w
	endif

locret_130E8:
		rts	
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_13118
		bclr	#staFacing,obStatus(a0)
		beq.s	loc_13104
		bclr	#staPush,obStatus(a0)
		move.b	#aniID_Run,obPrevAni(a0) ; restart Sonic's animation

loc_13104:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310C

	if GroundSpeedCapEnabled=0 ; Mercury Disable Ground Speed Cap
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_1310C
	endif	;end Disable Speed Cap

		move.w	d6,d0

loc_1310C:
		move.w	d0,obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0) ; use walking animation
		rts	
; ===========================================================================

loc_13118:
		add.w	d4,d0
		bcc.s	loc_13120
		move.w	#$80,d0

loc_13120:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#aniID_Stop,obAnim(a0) ; use "stopping" animation
		bset	#staFacing,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr		(PlaySound_Special).l	; play stopping sound
	if SkidDustEnabled=1
		cmpi.b	#$C,(v_air)
		bcs.s	locret_1314E			; if he's drowning, branch to not make dust
		move.b	#6,(v_playerdust+obRoutine).w
	endif

locret_1314E:
		rts	
; End of function Sonic_MoveRight
