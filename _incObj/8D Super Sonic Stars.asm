; ---------------------------------------------------------------------------
; Object 8D - Super Sonic's stars (Ported from S2 - Obj7E)
; ---------------------------------------------------------------------------

SuperStars:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	SStars_Next
	; Object Routine Optimization End

SStars_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_SStars,obMap(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)

SStars_Next:	; Routine 2
		btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
		beq.s	SStars_Delete							; if not, branch and delete
		tst.b	objoff_30(a0)
		beq.s	loc_1E188
		subq.b	#1,obTimeFrame(a0)						; decrement frame timer
		bpl.s	loc_1E170								; branch if time remains
		move.b	#1,obTimeFrame(a0)						; reset timer
		addq.b	#1,obFrame(a0)							; next animation frame
		cmpi.b	#6,obFrame(a0)							; have we reached the end of animation?
		blo.s	loc_1E170								; if not, branch
		clr.b	obFrame(a0)								
		clr.b	objoff_30(a0)
		move.b	#1,objoff_31(a0)						; 
		rts
; ===========================================================================

loc_1E170:
		tst.b	objoff_31(a0)
		bne.s	SStars_Display

loc_1E176:
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)

SStars_Display
		jmp		(DisplaySprite).l
; ===========================================================================

loc_1E188:
		tst.b	(v_player+obCtrlLock).w		; is control lock on? (ie when first turning Super)
		bne.s	loc_1E1AA					; if yes, branch
		move.w	(v_player+obInertia).w,d0	; get Sonic's speed
		bpl.s	.notnegative
		neg.w	d0							; get absolute value

.notnegative:
		cmpi.w	#$800,d0
		blo.s	loc_1E1AA
		clr.b	obFrame(a0)
		move.b	#1,objoff_30(a0)
		bra.s	loc_1E176					; branch to moving the star to Sonic
; ===========================================================================

loc_1E1AA:
		clr.w	objoff_30(a0)				; clear $30 and $31
		rts
; ===========================================================================

SStars_Delete:
		jmp		(DeleteObject).l
; ===========================================================================
