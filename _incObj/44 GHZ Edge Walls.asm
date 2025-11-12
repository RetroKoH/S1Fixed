; ---------------------------------------------------------------------------
; Object 44 - edge walls (GHZ)
; ---------------------------------------------------------------------------

EdgeWalls:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.s	Edge_Solid
		bpl.w	Edge_Display
	; Object Routine Optimization End

Edge_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Edge,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Edge_Wall,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#8,obDispWid(a0)
		move.w	#priority6,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),obFrame(a0)	; copy object type number to frame number
		bclr	#4,obFrame(a0)				; clear	4th bit	(deduct	$10)
		beq.s	Edge_Solid					; make object solid if 4th bit = 0
		addq.b	#2,obRoutine(a0)
		bra.s	Edge_Display				; don't make it solid if 4th bit = 1
; ===========================================================================

Edge_Solid:	; Routine 2
		move.w	#$13,d1
		move.w	#$28,d2
		bsr.s	Obj44_SolidWall

Edge_Display:	; Routine 4
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
; ===========================================================================

Obj44_SolidWall:
		bsr.w	Obj44_SolidWall2
		beq.s	loc_8AA8
		bmi.w	loc_8AC4

	if WallJumpEnabled	; Mercury Wall Jump
		moveq	#0,d1
	endif	; Wall Jump end	

		tst.w	d0
		beq.w	loc_8A92
		bmi.s	loc_8A7C
		tst.w	obVelX(a1)
		bmi.s	loc_8A92

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnR,d1
	endif	; Wall Jump end	

		bra.s	loc_8A82
; ===========================================================================

loc_8A7C:
		tst.w	obVelX(a1)
		bpl.s	loc_8A92

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnL,d1
	endif	; Wall Jump end	

loc_8A82:
		sub.w	d0,obX(a1)
		clr.w	obInertia(a1)
		clr.w	obVelX(a1)

loc_8A92:
		btst	#staAir,obStatus(a1)
		bne.s	loc_8AB6
		bset	#staPush,obStatus(a1)
		bset	#staSonicPush,obStatus(a0)
		rts	
; ===========================================================================

loc_8AA8:
		btst	#staSonicPush,obStatus(a0)
		beq.s	locret_8AC2
		; Removed line -- Mercury Walking In Air Fix

	if WallJumpEnabled	; Mercury Wall Jump
		bra.s	loc_8AB6_PushClear

loc_8AB6:
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		Sonic_WallJump
		movea.l	(sp)+,a0

loc_8AB6_PushClear:

	else

	loc_8AB6:

	endif	; Wall Jump end

		bclr	#staSonicPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)

locret_8AC2:
		rts	
; ===========================================================================

loc_8AC4:
		tst.w	obVelY(a1)
		bpl.s	locret_8AD8
		tst.w	d3
		bpl.s	locret_8AD8
		sub.w	d3,obY(a1)
		clr.w	obVelY(a1)

locret_8AD8:
		rts	
; End of function Obj44_SolidWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall2:
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	loc_8B48
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_8B48
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3

	; Mercury Ducking Size Fix	
	if SpinDashEnabled==1
		cmpi.b	#aniID_SpinDash,obAnim(a1)
		beq.s	.short
	endif
		cmpi.b	#aniID_Duck,obAnim(a1)
		bne.s	.skip
		
.short:
		subq.w	#5,d2
		addq.w	#5,d3

.skip:
	; Ducking Size Fix end

		sub.w	obY(a0),d3
		add.w	d2,d3
		bmi.s	loc_8B48
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.s	loc_8B48
		tst.b	obCtrlLock(a1)		; are collisions disabled for Sonic?
		bmi.s	loc_8B48			; if yes, branch
		cmpi.b	#6,obRoutine(a1)	; is Sonic dead?
		bhs.s	loc_8B48			; if yes, branch
		tst.w	(v_debuguse).w		; is debug mode being used?	
		bne.s	loc_8B48			; if yes, branch
		move.w	d0,d5
		cmp.w	d0,d1
		bhs.s	loc_8B30
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_8B30:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	loc_8B3C
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_8B3C:
		cmp.w	d1,d5
		bhi.s	loc_8B44
		moveq	#1,d4
		rts	
; ===========================================================================

loc_8B44:
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_8B48:
		moveq	#0,d4
		rts	
; End of function Obj44_SolidWall2
; ===========================================================================