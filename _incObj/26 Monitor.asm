; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp	Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index
		dc.w Mon_Solid-Mon_Index
		dc.w Mon_BreakOpen-Mon_Index
		dc.w Mon_Animate-Mon_Index
		dc.w Mon_Display-Mon_Index
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#$E,obWidth(a0)
		move.l	#Map_Monitor,obMap(a0)
		move.w	#make_art_tile(ArtTile_Monitor,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#$F,obActWid(a0)

	; ProjectFM S3K Objects Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		movea.w	d0,a2				; load address into a2
		;bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)				; has monitor been broken?
	; S3K Objects Manager End

		beq.s	.notbroken			; if not, branch
		move.b	#8,obRoutine(a0)	; run "Mon_Display" routine
	if ShieldsMode>1
		move.b	#$E,obFrame(a0)		; use new broken monitor frame
	else
		move.b	#$B,obFrame(a0)		; use original broken monitor frame
	endif
		rts	
; ===========================================================================

.notbroken:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)

Mon_Solid:	; Routine 2
		move.b	ob2ndRout(a0),d0		; is monitor set to fall?
		beq.s	.normal					; if not, branch
		subq.b	#2,d0
		bne.s	.fall

		; 2nd Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#staOnObj,obStatus(a1)	; is Sonic on top of the monitor?
		bne.w	.ontop					; if yes, branch
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

.ontop:
		move.w	#$10,d3
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Mon_Animate
; ===========================================================================

.fall:		; 2nd Routine 4
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.w	Mon_Animate
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

.normal:	; 2nd Routine 0
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Mon_SolidSides
		beq.w	loc_A25C
		tst.w	obVelY(a1)
		bmi.s	loc_A20A
		cmpi.b	#aniID_Roll,obAnim(a1)	; is Sonic rolling?
		beq.s	loc_A25C				; if yes, branch

loc_A20A:
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,obY(a1)
		bsr.w	loc_74AE
		move.b	#2,ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

loc_A220:
		tst.w	d0
		beq.w	loc_A246
		bmi.s	loc_A230
		tst.w	obVelX(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	obVelX(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,obX(a1)
		clr.w	obInertia(a1)
		clr.w	obVelX(a1)

loc_A246:
		btst	#staAir,obStatus(a1)
		bne.s	loc_A26A
		bset	#staPush,obStatus(a1)
		bset	#staSonicPush,obStatus(a0)
		bra.s	Mon_Animate
; ===========================================================================

loc_A25C:
		btst	#staSonicPush,obStatus(a0)
		beq.s	Mon_Animate
		; Removed line -- Mercury Walking In Air Fix

loc_A26A:
		bclr	#staSonicPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)

Mon_Animate:	; Routine 6
		lea		(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
		bra.w	RememberState	; ProjectFM S3K Objects Manager	
; ===========================================================================

Mon_BreakOpen:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		bsr.w	FindFreeObj
		bne.s	Mon_Explode
		_move.b	#id_PowerUp,obID(a1) ; load monitor contents object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obAnim(a0),obAnim(a1)

Mon_Explode:
		bsr.w	FindFreeObj
		bne.s	.fail
		_move.b	#id_ExplosionItem,obID(a1) ; load explosion object
		addq.b	#2,obRoutine(a1) ; don't create an animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

.fail:
	; ProjectFM S3K Objects Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		movea.w	d0,a2				; load address into a2
		bset	#0,(a2)
	; S3K Objects Manager End

	if ShieldsMode>1
		move.b	#$C,obAnim(a0)	; set monitor type to broken
	else
		move.b	#9,obAnim(a0)	; set monitor type to broken
	endif
		bra.w	DisplaySprite
