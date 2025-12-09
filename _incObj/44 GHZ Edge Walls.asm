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
; ---------------------------------------------------------------------------

Edge_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Edge_Solid
		move.l	#Map_Edge,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Edge_Wall,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#8,obDispWid(a0)
		move.w	#priority6,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),obFrame(a0)	; copy object type number to frame number
		bclr	#4,obFrame(a0)				; clear	4th bit	(deduct	$10)
		beq.s	Edge_Solid					; branch if already clear (subtype 0/1/2 is solid)

		addq.b	#2,obRoutine(a0)			; -> Edge_Display
		bra.s	Edge_Display				; bit 4 was already set (subtype $10/$11/$12 is not solid)
; ===========================================================================

Edge_Solid:	; Routine 2
		moveq	#19,d1						; width; save 4 cycles -- Filter
		moveq	#40,d2						; height; save 4 cycles -- Filter
		bsr.s	Edge_SolidWall

Edge_Display:	; Routine 4
		offscreen.w	DeleteObject			; ProjectFM S3K Object Manager
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix
; ===========================================================================

Edge_SolidWall:
		bsr.w	Edge_ChkCollision
		beq.s	.no_collision				; branch if no collision
		bmi.w	.topbottom					; branch if top/bottom collision

	if WallJumpEnabled	; Mercury Wall Jump
		moveq	#0,d1
	endif	; Wall Jump end	

		tst.w	d0							; where is Sonic?
		beq.w	.center						; if inside the object, branch
		bmi.s	.right						; if right of the object, branch
		tst.w	obVelX(a1)					; is Sonic moving left?
		bmi.s	.center						; if yes, branch

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnR,d1
	endif	; Wall Jump end	

		bra.s	.left
; ===========================================================================

	.right:
		tst.w	obVelX(a1)					; is Sonic moving right?
		bpl.s	.center						; if yes, branch

	if WallJumpEnabled	; Mercury Wall Jump
		move.b	#btnL,d1
	endif	; Wall Jump end	

	.left:
		sub.w	d0,obX(a1)
		clr.w	obInertia(a1)
		clr.w	obVelX(a1)					; stop Sonic moving

	.center:
		btst	#staAir,obStatus(a1)		; is Sonic in the air?
		bne.s	.air						; if yes, branch
		bset	#staPush,obStatus(a1)		; make Sonic push object
		bset	#staSonicPush,obStatus(a0)	; make object be pushed
		rts	
; ===========================================================================

	.no_collision:
		btst	#staSonicPush,obStatus(a0)	; is Sonic pushing?
		beq.s	.exit						; if not, branch
		; Removed line -- Mercury Walking In Air Fix

	if WallJumpEnabled	; Mercury Wall Jump
		bra.s	.air_PushClear

	.air:
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		Sonic_WallJump
		movea.l	(sp)+,a0

	.air_PushClear:

	else

	.air:

	endif	; Wall Jump end

		bclr	#staSonicPush,obStatus(a0)	; clear pushing flag
		bclr	#staPush,obStatus(a1)		; clear Sonic's pushing flag

	.exit:
		rts	
; ===========================================================================

	.topbottom:
		tst.w	obVelY(a1)					; is Sonic moving downwards?
		bpl.s	.exit2						; if yes, branch
		tst.w	d3							; is Sonic above the object?
		bpl.s	.exit2						; if yes, branch
		sub.w	d3,obY(a1)					; correct Sonic's position
		clr.w	obVelY(a1)					; stop Sonic moving

	.exit2:
		rts	
; End of function Edge_SolidWall
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check for collision with EdgeWall
; ---------------------------------------------------------------------------

Edge_ChkCollision:
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0					; d0: positive if Sonic is right; negative if Sonic is left
		add.w	d1,d0						; add width of object
		bmi.s	.ignore						; branch if Sonic is outside left boundary
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	.ignore						; branch if Sonic is outside right boundary

		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2						; add obHeight to stated height of 40px
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

		sub.w	obY(a0),d3					; d3: positive if Sonic is below; negative if Sonic is above
		add.w	d2,d3						; add total height of object
		bmi.s	.ignore						; branch if Sonic is outside upper boundary
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.s	.ignore						; branch if Sonic is outside lower boundary

		tst.b	obCtrlLock(a1)				; are controls locked (and collisions disabled for Sonic)?
		bmi.s	.ignore						; if yes, branch
		cmpi.b	#6,obRoutine(a1)			; is Sonic dead?
		bhs.s	.ignore						; if yes, branch
		tst.w	(v_debuguse).w				; is debug mode being used?	
		bne.s	.ignore						; if yes, branch
		move.w	d0,d5
		cmp.w	d0,d1						; is Sonic right of centre of object?
		bhs.s	.isright					; if yes, branch
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

	.isright:
		move.w	d3,d1
		cmp.w	d3,d2						; is Sonic below centre of object?
		bhs.s	.isbelow					; if yes, branch
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

	.isbelow:
		cmp.w	d1,d5
		bhi.s	.topbottom
		moveq	#1,d4						; register side collision
		rts	
; ===========================================================================

	.topbottom:
		moveq	#-1,d4						; register top/bottom collision
		rts	
; ===========================================================================

	.ignore:
		moveq	#0,d4						; register no collision
		rts	
; End of function Edge_ChkCollision
; ===========================================================================