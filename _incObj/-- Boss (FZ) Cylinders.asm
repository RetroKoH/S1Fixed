; ---------------------------------------------------------------------------
; Object - cylinder Eggman hides in (FZ)
; ---------------------------------------------------------------------------

ECyl_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

ECyl_PosData:
		dc.w boss_fz_x+$80,  boss_fz_y+$110		; bottom left
		dc.w boss_fz_x+$100, boss_fz_y+$110		; bottom right
		dc.w boss_fz_x+$40,  boss_fz_y-$50		; top left
		dc.w boss_fz_x+$C0,  boss_fz_y-$50		; top right
; ===========================================================================

EggmanCylinder:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.w	ECyl_Action
		bpl.w	ECyl_Move
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

ECyl_Main:	; Routine 0
		lea		ECyl_PosData(pc),a1
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype (0/2/4/6)
		add.w	d0,d0
		adda.w	d0,a1						; jump to relevant address for x/y pos data
		move.b	#4,obRender(a0)
		bset	#renVisible,obRender(a0)	; set object as visible
		bset	#renUseHeight,obRender(a0)	; set height flag, as this is a larger object
		move.w	#make_art_tile(ArtTile_FZ_Boss,0,0),obGfx(a0)
		move.l	#Map_EggCyl,obMap(a0)
		move.w	(a1)+,obX(a0)
		move.w	(a1),obY(a0)
		move.w	(a1)+,obECyl_StartY(a0)
		move.w	#$6060,obHeight(a0)			; Height and Width (Height was set to $20, then to $60)
		move.b	#$20,obDispWid(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		addq.b	#2,obRoutine(a0)			; -> ECyl_Action
; ---------------------------------------------------------------------------

ECyl_Action:	; Routine 2
		cmpi.b	#2,obSubtype(a0)			; is cylinder on ceiling?
		ble.s	.not_ceiling				; if not, branch
		bset	#renYFlip,obRender(a0)		; flip sprite vertically

	.not_ceiling:
		clr.l	obECyl_MoveY(a0)
		tst.b	obECyl_ExtendFlag(a0)		; is cylinder set to move?
		beq.s	Cyl_Update					; if not, branch
		addq.b	#2,obRoutine(a0)			; -> Cyl_Move
; ---------------------------------------------------------------------------

Cyl_Update:
		move.l	obECyl_MoveY(a0),d0
		move.l	obECyl_StartY(a0),d1
		add.l	d0,d1						; add y diff to start position
		swap	d1							; get upper word
		move.w	d1,obY(a0)					; update y position
		cmpi.b	#4,obRoutine(a0)			; is cylinder active (Cyl_Move)?
		bne.s	.skip_eggman				; if not, branch
		tst.w	obECyl_EggFlag(a0)			; does cylinder contain Eggman?
		bpl.s	.skip_eggman				; if not, branch
		moveq	#-$A,d0
		cmpi.b	#2,obSubtype(a0)			; is cylinder on ceiling?
		ble.s	.not_ceiling				; if not, branch
		moveq	#$E,d0

	.not_ceiling:
		add.w	d0,d1
		movea.w	obECyl_Parent(a0),a1		; get RAM address of parent object (Eggman)
		move.w	d1,obY(a1)					; update Eggman position
		move.w	obX(a0),obX(a1)

	.skip_eggman:
		moveq	#43,d1						; width; save 4 cycles -- Filter
		moveq	#96,d2						; height (jumping); save 4 cycles -- Filter
		moveq	#97,d3						; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4					; axis position
		jsr		(SolidObject).l
		moveq	#0,d0
		move.w	obECyl_MoveY(a0),d1			; distance cylinder has moved
		bpl.s	.moved_down					; branch if 0 or positive
		neg.w	d1							; get absolute value
		subq.w	#8,d1
		bcs.s	.update_frame				; branch if it was more than 8px
		addq.b	#1,d0
		asr.w	#4,d1						; divide by 16
		add.w	d1,d0
		bra.s	.update_frame
; ===========================================================================

	.moved_down:
		subi.w	#39,d1
		bcs.s	.update_frame				; branch if cylinder moved more than 39px
		addq.b	#1,d0
		asr.w	#4,d1						; divide by 16
		add.w	d1,d0

	.update_frame:
		move.b	d0,obFrame(a0)				; set frame
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bmi.s	.display					; branch if Sonic is left of cylinder
		subi.w	#320,d0
		bmi.s	.display					; branch if Sonic is within 320px of cylinder
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	ECyl_Delete					; if not, branch

	.display:
		jmp		(DisplaySprite).l
; ===========================================================================

ECyl_Move:	; Routine 4
	; LavaGaming Object Routine Optimization
		cmpi.b	#2,obSubtype(a0)
		bgt.s	Cyl_Top
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

; Subtypes 00 (bottom left) and 02 (bottom right)
Cyl_Bottom:
		tst.b	obECyl_ExtendFlag(a0)			; is cylinder extending?
		bne.s	.extend							; if yes, branch
		movea.w	obECyl_Parent(a0),a1			; get RAM address of parent object (Eggman)
		tst.b	obColProp(a1)					; has boss been beaten?
		bne.s	.not_beaten						; if not, branch
		bsr.w	BossDefeated					; spawn explosions
		subi.l	#$10000,obECyl_MoveY(a0)

	.not_beaten:
		addi.l	#$20000,obECyl_MoveY(a0)		; retract downward by 2px
		bcc.w	Cyl_Update						; branch if not fully retracted
		clr.l	obECyl_MoveY(a0)				; reset to 0
		movea.w	obECyl_Parent(a0),a1			; get RAM address of parent object (Eggman)
		subq.w	#1,obBFZ_PhaseState(a1)
		clr.w	obBFZ_CylFlag(a1)
		subq.b	#2,obRoutine(a0)				; -> Cyl_Action
		bra.w	Cyl_Update	
; ===========================================================================

	.extend:
		cmpi.w	#-16,obECyl_MoveY(a0)			; has cylinder moved at least 16px?
		bge.s	.after_16px						; if yes, branch
		subi.l	#$28000,obECyl_MoveY(a0)		; move up by 2.5px

	.after_16px:
		subi.l	#$8000,obECyl_MoveY(a0)			; move up by 0.5px
		cmpi.w	#-160,obECyl_MoveY(a0)			; has cylinder moved 160px?
		bgt.w	Cyl_Update						; if yes, branch
		clr.w	obECyl_MoveY+2(a0)				; clear subpixel
		move.w	#-160,obECyl_MoveY(a0)			; align to 160px
		clr.b	obECyl_ExtendFlag(a0)			; clear extending flag
		bra.w	Cyl_Update	
; ===========================================================================

Cyl_Top:	; Subtypes 04 (top left) and 06 (top right)
		bset	#renYFlip,obRender(a0)			; flip sprite vertically
		tst.b	obECyl_ExtendFlag(a0)			; is cylinder extending?
		bne.s	.extend							; if yes, branch
		movea.w	obECyl_Parent(a0),a1			; get RAM address of parent object (Eggman)
		tst.b	obColProp(a1)					; has boss been beaten?
		bne.s	.not_beaten						; if not, branch
		bsr.w	BossDefeated					; spawn explosion
		addi.l	#$10000,obECyl_MoveY(a0)

	.not_beaten:
		subi.l	#$20000,obECyl_MoveY(a0)		; retract upward by 2px
		bcc.w	Cyl_Update						; branch if not fully retracted
		clr.l	obECyl_MoveY(a0)				; reset to 0
		movea.w	obECyl_Parent(a0),a1			; get RAM address of parent object (Eggman)
		subq.w	#1,obBFZ_PhaseState(a1)
		clr.w	obBFZ_CylFlag(a1)
		subq.b	#2,obRoutine(a0)				; -> Cyl_Action
		bra.w	Cyl_Update	
; ===========================================================================

	.extend:
		cmpi.w	#$10,obECyl_MoveY(a0)			; has cylinder moved at least 16px?
		blt.s	.after_16px						; if yes, branch
		addi.l	#$28000,obECyl_MoveY(a0)		; move down by 2.5px

	.after_16px:
		addi.l	#$8000,obECyl_MoveY(a0)			; move down by 0.5px
		cmpi.w	#160,obECyl_MoveY(a0)			; has cylinder moved 160px?
		blt.w	Cyl_Update						; if yes, branch
		clr.w	obECyl_MoveY+2(a0)				; clear subpixel
		move.w	#160,obECyl_MoveY(a0)			; align to 160px
		clr.b	obECyl_ExtendFlag(a0)			; clear extending flag
		bra.w	Cyl_Update	
; ===========================================================================