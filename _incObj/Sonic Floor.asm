; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Floor:
		move.l	#v_collision1&$FFFFFF,(v_collindex).w	; MJ: load first collision data location
		cmpi.b	#$C,(v_top_solid_bit).w					; MJ: is second collision set to be used?
		beq.s	.first									; MJ: if not, branch
		move.l	#v_collision2&$FFFFFF,(v_collindex).w	; MJ: load second collision data location
.first:
		move.b	(v_lrb_solid_bit).w,d5					; MJ: load L/R/B soldity bit
	; Devon Air Collision Improvement
	; Avoiding CalcAngle When Performing Collision in the Air
		move.w	obVelX(a0),d0
		move.w	obVelY(a0),d1
		bpl.s	.airCol_PositiveY			; If it's positive, branch
		cmp.w	d0,d1						; Are we moving towards the left?
		bgt.w	Sonic_AirMode_LeftWall		; If so, branch
		neg.w	d0							; Are we moving towards the right?
		cmp.w	d0,d1
		bge.w	Sonic_AirMode_RightWall		; If so, branch
		bra.w	Sonic_AirMode_Ceiling		; We are moving upwards
 
.airCol_PositiveY:
		cmp.w	d0,d1						; Are we moving towards the right?
		blt.w	Sonic_AirMode_RightWall		; If so, branch
		neg.w	d0
		cmp.w	d0,d1						; Are we moving towards the left?
		ble.w	Sonic_AirMode_LeftWall		; If so, branch
		; fallthrough if moving downward
	; Air Collision Improvement End

; ---------------------------------------------------------------------------
; Floor Mode if moving downward
; ---------------------------------------------------------------------------
;Sonic_AirMode_Floor:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkRightWall
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkRightWall:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkFloor
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkFloor:
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_1367E
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361E
		cmp.b	d2,d0
		blt.s	locret_1367E

loc_1361E:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		;bsr.w	Sonic_ResetOnFloor		; Moved to loc_1364E -- Fix Bubble Bounce
		move.b	#aniID_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr		obVelY(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor		; Moved from loc_1361E -- Fix Bubble Bounce
; ===========================================================================

loc_1365C:
		clr.w	obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670
		move.w	#$FC0,obVelY(a0)

loc_13670:
	; This might need to be fixed
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	.reset
		neg.w	obInertia(a0)
	
	.reset:
		bsr.w	Sonic_ResetOnFloor			; Added -- Fix Bubble Bounce

locret_1367E:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Left Wall Mode if moving mostly left
; ---------------------------------------------------------------------------

Sonic_AirMode_LeftWall: ;loc_13680:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkCeiling
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.chkFloor
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	.ret
		clr.w	obVelY(a0)

	.ret:
		rts	
; ===========================================================================

.chkFloor:
		tst.w	obVelY(a0)
		bmi.s	.end
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.end
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		;bsr.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce

	.end:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Ceiling Mode if moving upwards
; ---------------------------------------------------------------------------

Sonic_AirMode_Ceiling: ;loc_136E2:
		bsr.w	Sonic_CheckLeftWallDist
		tst.w	d1
		bpl.s	.chkRightWall
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkRightWall:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkCeiling
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.ret
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	.latchToCeiling
		clr.w	obVelY(a0)
		rts	
; ===========================================================================

	.latchToCeiling:
	; Might need to be fixed
		move.b	d3,obAngle(a0)
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	.reset
		neg.w	obInertia(a0)
	
	.reset:
		bra.w	Sonic_ResetOnFloor

	.ret:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Right Wall Mode if moving mostly right
; ---------------------------------------------------------------------------

Sonic_AirMode_RightWall: ;loc_1373E:
		bsr.w	Sonic_CheckRightWallDist
		tst.w	d1
		bpl.s	.chkCeiling
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

	.chkCeiling:
		bsr.w	Sonic_CheckCeilingDist
		tst.w	d1
		bpl.s	.chkFloor
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	.ret
		clr.w	obVelY(a0)

	.ret:
		rts	
; ===========================================================================

	.chkFloor:
		tst.w	obVelY(a0)
		bmi.s	.end
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	.end
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		;bsr.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce
		move.b	#aniID_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		bra.w	Sonic_ResetOnFloor			; Moved -- Fix Bubble Bounce

	.end:
		rts	
; End of function Sonic_Floor
