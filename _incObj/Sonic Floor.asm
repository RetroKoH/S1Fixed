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
		bpl.s	.airCol_PosY			; If it's positive, branch
		cmp.w	d0,d1					; Are we moving towards the left?
		bgt.w	loc_13680				; If so, branch
		neg.w	d0						; Are we moving towards the right?
		cmp.w	d0,d1
		bge.w	loc_1373E				; If so, branch
		bra.w	loc_136E2				; We are moving upwards
 
.airCol_PosY:
		cmp.w	d0,d1					; Are we moving towards the right?
		blt.w	loc_1373E				; If so, branch
		neg.w	d0						; Are we moving towards the left?
		cmp.w	d0,d1
		ble.w	loc_13680				; If so, branch
	; Air Collision Improvement End
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_135F0
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

loc_135F0:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13602
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

loc_13602:
		bsr.w	Sonic_HitFloor
		move.b	d1,(v_unused6).w
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
		bsr.w	Sonic_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr	obVelY(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		rts	
; ===========================================================================

loc_1365C:
		clr.w	obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670
		move.w	#$FC0,obVelY(a0)

loc_13670:
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1367E
		neg.w	obInertia(a0)

locret_1367E:
		rts	
; ===========================================================================

loc_13680:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_1369A
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

loc_1369A:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_136B4
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_136B2
		clr.w	obVelY(a0)

locret_136B2:
		rts	
; ===========================================================================

loc_136B4:
		tst.w	obVelY(a0)
		bmi.s	locret_136E0
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_136E0
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_136E0:
		rts	
; ===========================================================================

loc_136E2:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_136F4
		sub.w	d1,obX(a0)
		clr.w	obVelX(a0)

loc_136F4:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13706
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)

loc_13706:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_1373C
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_13726
		clr.w	obVelY(a0)
		rts	
; ===========================================================================

loc_13726:
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1373C
		neg.w	obInertia(a0)

locret_1373C:
		rts	
; ===========================================================================

loc_1373E:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13758
		add.w	d1,obX(a0)
		clr.w	obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts	
; ===========================================================================

loc_13758:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_13772
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_13770
		clr.w	obVelY(a0)

locret_13770:
		rts	
; ===========================================================================

loc_13772:
		tst.w	obVelY(a0)
		bmi.s	locret_1379E
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_1379E
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		clr.w	obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_1379E:
		rts	
; End of function Sonic_Floor
