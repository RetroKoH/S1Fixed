; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

	if ShieldsMode>1
monLastID: = $C
	else
monLastID: = 9
	endif

Monitor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp		Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:		offsetTable
		offsetTableEntry.w Mon_Main
		offsetTableEntry.w Mon_Solid
		offsetTableEntry.w Mon_BreakOpen
		offsetTableEntry.w Mon_Animate
		offsetTableEntry.w Mon_Display
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#$E,d0						; load to d0 to save cycles
		move.b	d0,obHeight(a0)
		move.b	d0,obWidth(a0)
		move.l	#Map_Monitor,obMap(a0)
		move.w	#make_art_tile(ArtTile_Monitor,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$F,obActWid(a0)

	; ProjectFM S3K Objects Manager
		move.w	obRespawnNo(a0),d0			; get address in respawn table
		movea.w	d0,a2						; load address into a2
		;bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)						; has monitor been broken?
	; S3K Objects Manager End

		beq.s	.notbroken					; if not, branch
		move.b	#8,obRoutine(a0)			; run "Mon_Display" routine
		move.b	#monLastID+2,obFrame(a0)	; use broken monitor frame
		rts	
; ===========================================================================

.notbroken:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)

Mon_Solid:	; Routine 2
	if ShieldsMode=2
		move.b	obSubtype(a0),d0
		cmpi.b	#7,d0					; is this a flame shield?
		blt.s	.skipcheck
		cmpi.b	#9,d0					; is this a lightning shield?
		bgt.s	.skipcheck
	; if we reached this point, this is an elemental shield...
		move.b	obSubtype(a0),obAnim(a0)
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have a shield?
		bne.s	.skipcheck								; if yes, don't change it.
		move.b	#4,obAnim(a0)							; reset to blue shield.

.skipcheck:
	endif
		move.b	ob2ndRout(a0),d0		; is monitor set to fall?
		beq.s	.normal					; if not, branch
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l
		tst.w	d1						; is monitor in the ground?
		bpl.w	.normal					; if not, branch
		add.w	d1,obY(a0)				; move monitor out of the ground
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)			; stop monitor from falling

.normal:
		move.w	#$1A,d1
		move.w	#$F,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	Mon_Solidity

Mon_Animate:	; Routine 6
		lea		Ani_Monitor(pc),a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
		bra.w	RememberState	; ProjectFM S3K Objects Manager
; ===========================================================================

Mon_Solidity:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic on top of the monitor?
		bne.s	.chkOverEdge				; if yes, branch
		cmpi.b	#aniID_Roll,obAnim(a1)		; is Sonic spinning?
		bne.w	Mon_SolidSides				; if not, branch (Solid_ChkEnter)
		rts
; ===========================================================================

.chkOverEdge:
		move.w	d1,d2
		add.w	d2,d2
		btst	#staAir,obStatus(a1)		; is the character in the air?
		bne.s	+							; if yes, branch
		; check, if character is standing on
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	+				; branch, if character is behind the left edge of the monitor
		cmp.w	d2,d0
		blo.s	.standOn		; branch, if character is not beyond the right edge of the monitor
+
		; if the character isn't standing on the monitor
		bclr	#staOnObj,obStatus(a1)		; clear 'on object' bit
		bset	#staAir,obStatus(a1)		; set 'in air' bit
		bclr	#staSonicOnObj,obStatus(a0)	; clear monitor's 'stood on' bit
		moveq	#0,d4
		rts
; ===========================================================================
;loc_127B2:
.standOn:
		move.w	d4,d2			; d4 should be obX(a0)
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts
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
		_move.b	#id_ExplosionItem,obID(a1)	; load explosion object
		addq.b	#2,obRoutine(a1)			; don't create an animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

.fail:
	; ProjectFM S3K Objects Manager
		move.w	obRespawnNo(a0),d0			; get address in respawn table
		movea.w	d0,a2						; load address into a2
		bset	#0,(a2)
	; S3K Objects Manager End

		move.b	#monLastID,obAnim(a0)		; set monitor type to broken
		bra.w	DisplaySprite
