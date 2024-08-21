; ---------------------------------------------------------------------------
; Subroutine to	make the sides of a monitor solid
; Now Sonic 2's SolidObject_cont
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Mon_SolidSides:
		move.w	obX(a1),d0				; load Sonic's X position...
		sub.w	obX(a0),d0				; ...and calculate his x position relative to the object.
		add.w	d1,d0					; Put object's left edge at (0,0).  This is also Sonic's distance to the object's left edge.
		bmi.w	MonSolid_TestClrPush	; Branch if Sonic is outside the object's left edge.
		move.w	d1,d3
		add.w	d3,d3					; Calculate object's width.
		cmp.w	d3,d0
		bhi.w	MonSolid_TestClrPush	; Branch if Sonic is outside the object's right edge.
		move.b	obHeight(a1),d3			; load Sonic's Y radius.
		ext.w	d3
		add.w	d3,d2					; Calculate maximum distance for a top collision.
		move.w	obY(a1),d3				; load Sonic's y position...

		sub.w	obY(a0),d3				; ...and calculate his y position relative to the object.
		addq.w	#4,d3					; Assume a slightly lower position for Sonic.
		add.w	d2,d3					; Make the highest position where Sonic would still be colliding with the object (0,0).
		bmi.w	MonSolid_TestClrPush	; Branch if Sonic is above this point.
		move.w	d2,d4
		add.w	d4,d4					; Calculate minimum distance for a bottom collision.
		cmp.w	d4,d3
		bhs.w	MonSolid_TestClrPush	; Branch if Sonic is below this point.
		tst.b	obCtrlLock(a1)
		bmi.w	MonSolid_TestClrPush	; Branch if object collisions are disabled for Sonic.
		cmpi.b	#6,obRoutine(a1)
		bhs.w	MonSolid_NoCollision	; Branch if Sonic is dead/drowning
		tst.w	(v_debuguse).w
		bne.w	MonSolid_NoCollision	; Branch if in Debug Mode.
		
		move.w	d0,d5
		cmp.w	d0,d1
		bhs.s	.toTheLeft				; Branch if Sonic is to the object's left.

;.toTheRight:
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5					; Calculate Sonic's distance to the object's right edge...
		neg.w	d5						; ...and calculate the absolute value.

.toTheLeft:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	.isAbove

;.isBelow:
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

.isAbove:
		; Now...
		; 'd0' contains Sonic's distance to the nearest object horizontal edge.
		; 'd5' contains the absolute version of 'd0'.
		; 'd3' contains Sonic's distance to the nearest object vertical edge.
		; 'd1' contains the absolute version of 'd3'.
		cmp.w	d1,d5
		bhi.w	MonSolid_TopBottom		; Branch, if horizontal distance is greater than vertical distance.

MonSolid_LeftRight:
		; If Sonic is extremely close to the top or bottom, then branch.
		; I guess the point of this is to let Sonic walk over objects that
		; are barely poking out of the ground?
		cmpi.w	#4,d1
		bls.s	MonSolid_SideAir

		tst.w	d0						; Where is Sonic?
		beq.s	MonSolid_AtEdge			; If at the object's edge, branch
		bmi.s	MonSolid_InsideRight	; If in the right side of the object, branch

;MonSolid_InsideLeft:
		tst.w	obVelX(a1)				; Is Sonic moving left?
		bmi.s	MonSolid_AtEdge			; If yes, branch
		bra.s	MonSolid_StopCharacter
; ===========================================================================

MonSolid_InsideRight:
		tst.w	obVelX(a1)					; is Sonic moving right?
		bpl.s	MonSolid_AtEdge				; if yes, branch

MonSolid_StopCharacter:
		clr.w	obInertia(a1)
		clr.w	obVelX(a1)					; stop Sonic moving

MonSolid_AtEdge:
		sub.w	d0,obX(a1)					; correct Sonic's position
		btst	#staAir,obStatus(a1)		; is Sonic in the air?
		bne.s	MonSolid_SideAir			; if yes, branch
		bset	#staPush,obStatus(a1)		; make Sonic push object
		bset	#staSonicPush,obStatus(a0)	; make object be pushed
		moveq	#1,d4						; return side collision
		rts
; ===========================================================================

MonSolid_SideAir:
		bsr.s	MonSolid_NotPushing
		moveq	#1,d4	; return side collision
		rts
; ===========================================================================

MonSolid_TestClrPush:
		btst	#staSonicPush,obStatus(a0)		; is Sonic pushing?
		beq.s	MonSolid_NoCollision			; if not, branch

MonSolid_NotPushing:
		bclr	#staSonicPush,obStatus(a0)	; clear pushing flag
		bclr	#staPush,obStatus(a1)		; clear Sonic's pushing flag

MonSolid_NoCollision:
		moveq	#0,d1
		rts	
; ===========================================================================

MonSolid_TopBottom:
		tst.w	d3						; is Sonic below the object?
		bmi.s	MonSolid_InsideBottom	; if yes, branch

;MonSolid_InsideTop:
		cmpi.w	#$10,d3					; has Sonic landed on the object?
		blo.s	MonSolid_Landed			; if yes, branch
		bra.s	MonSolid_TestClrPush
; ===========================================================================
; loc_19B06:
MonSolid_InsideBottom:
		tst.w	obVelY(a1)		; is Sonic moving vertically?
		beq.s	MonSolid_Squash	; if not, branch
		bpl.s	loc_19B1C		; if moving downwards, branch
		tst.w	d3				; is Sonic above the object?
		bpl.s	loc_19B1C		; if yes, branch (this will never be true)
		clr.w	obVelY(a1)		; Stop Sonic from moving.

loc_19B1C:
		sub.w	d3,obY(a1)		; Push Sonic out of the object.
		moveq	#-1,d4			; Return bottom collision.
		rts
; ===========================================================================
; loc_19B28:
MonSolid_Squash:
		btst	#staAir,obStatus(a1)	; is Sonic in the air?
		bne.s	loc_19B1C			; if yes, branch
		move.w	d0,d4
		bpl.s	.skip
		neg.w	d4					; absolute value

.skip:
		; If Sonic is near the left or right edge of the object, then don't
		; kill him, instead just push him away horizontally.
		cmpi.w	#$10,d4
		blo.w	MonSolid_LeftRight

		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		(KillSonic).l	; kill Sonic
		movea.l	(sp)+,a0
		moveq	#-1,d4			; Return bottom collision.
		rts
; ===========================================================================
; loc_19B56:
MonSolid_Landed:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	MonSolid_Miss	; if Sonic is right of object, branch
		cmp.w	d2,d1			; is Sonic left of object?
		bhs.s	MonSolid_Miss	; if yes, branch
		tst.w	obVelY(a1)		; is Sonic moving upwards?
		bmi.s	MonSolid_Miss	; if yes, branch
		sub.w	d3,obY(a1)		; correct Sonic's position
		subq.w	#1,obY(a1)
		bsr.w	Solid_ResetFloor
		bset	#staSonicOnObj,obStatus(a0)
		moveq	#-1,d4			; return top collision
		rts
; ===========================================================================
; loc_19B8E:
MonSolid_Miss:
		moveq	#0,d4	; return no collision
		rts
; ===========================================================================
; End of function Mon_SolidSides
