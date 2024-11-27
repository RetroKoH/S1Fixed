; ---------------------------------------------------------------------------
; Object 3E - prison capsule
; ---------------------------------------------------------------------------

Prison:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pri_Index(pc,d0.w),d1
		jmp		Pri_Index(pc,d1.w)
; ===========================================================================
Pri_Index:	offsetTable
		offsetTableEntry.w Pri_Main
		offsetTableEntry.w Pri_BodyMain
		offsetTableEntry.w Pri_Switched
		offsetTableEntry.w Pri_Explosion
		offsetTableEntry.w Pri_Explosion
		offsetTableEntry.w Pri_Explosion
		offsetTableEntry.w Pri_Animals
		offsetTableEntry.w Pri_EndAct

pri_origY 		= objoff_30		; original y-axis position
pri_animalCt	= objoff_3F		; number of animals spawned from the prison

Pri_Var:
		; 		routine,	width,	frame,	priority
		dc.b 	2,			$20,	0,0		; 0 (subtype 0: body)
		dc.w	priority4
		dc.b 	4,			$C,		1,0		; 4+2=6 (subtype 1: button)
		dc.w	priority5
		dc.b 	6,			$10,	3,0		; 8+4=$C (subtype 2: button 2)
		dc.w	priority4
		dc.b 	8,			$10,	5,0		; $C+6=$12 (subtype 3: ???)
		dc.w	priority3
; ===========================================================================

Pri_Main:	; Routine 0
		move.l	#Map_Pri,obMap(a0)
		move.w	#make_art_tile(ArtTile_Prison_Capsule,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	obY(a0),pri_origY(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	d0,d1
		lsl.w	#2,d0
		lsl.b	#1,d1
		add.b	d1,d0
		lea		Pri_Var(pc,d0.w),a1
		move.b	(a1)+,obRoutine(a0)
		move.b	(a1)+,obActWid(a0)
		move.b	(a1)+,obFrame(a0)
		lea		1(a1),a1				; increment a1 to skip 00
		move.w	(a1)+,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.w	#8,d0					; is object type number	02?
		bne.s	.not02					; if not, branch

		move.b	#6,obColType(a0)
		move.b	#8,obColProp(a0)

.not02:
		rts	
; ===========================================================================

Pri_BodyMain:	; Routine 2
		cmpi.b	#2,(v_bossstatus).w
		beq.s	.chkopened
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	#$18,d3
		move.w	obX(a0),d4
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		jsr		(SolidObject).l
		offscreen.s	.delete
		jmp		(DisplaySprite).l
; ===========================================================================

.chkopened:
		btst	#staSonicOnObj,obStatus(a0)	; has the prison been opened?
		beq.s	.open						; if yes, branch
		bclr	#staSonicOnObj,obStatus(a0)
		bclr	#staOnObj,(v_player+obStatus).w
		bset	#staAir,(v_player+obStatus).w

.open:
		move.b	#2,obFrame(a0)		; use frame number 2 (destroyed	prison)
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.s	.delete
		jmp		(DisplaySprite).l

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Pri_Switched:	; Routine 4
		move.w	#$17,d1
		move.w	#8,d2
		move.w	#8,d3
		move.w	obX(a0),d4
		jsr		(SolidObject).l
		lea		Ani_Pri(pc),a1
		jsr		(AnimateSprite).w
		move.w	pri_origY(a0),obY(a0)
		btst	#staSonicOnObj,obStatus(a0)		; has prison already been opened?
		beq.s	.open2							; if yes, branch

		addq.w	#8,obY(a0)
		move.b	#$A,obRoutine(a0)
		move.w	#60,obTimeFrame(a0)				; set time between animal spawns
		clr.b	(f_timecount).w					; stop time counter
		clr.b	(f_lockscreen).w				; lock screen position
		move.b	#1,(f_lockctrl).w				; lock controls
		move.w	#(btnR<<8),(v_jpadhold2).w		; make Sonic run to the right
		bclr	#staSonicOnObj,obStatus(a0)
		bclr	#staOnObj,(v_player+obStatus).w
		bset	#staAir,(v_player+obStatus).w

.open2:
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.s	.delete2
		jmp		(DisplaySprite).l

.delete2:
		jmp		(DeleteObject).l
; ===========================================================================

Pri_Explosion:	; Routine 6, 8, $A
		moveq	#7,d0
		and.b	(v_vbla_byte).w,d0
		bne.s	.noexplosion
		jsr		(FindFreeObj).l
		bne.s	.noexplosion
		_move.b	#id_ExplosionBomb,obID(a1)	; load explosion object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr		(RandomNumber).w
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

.noexplosion:
		subq.w	#1,obTimeFrame(a0)
		beq.s	.makeanimal
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.s	.delete2
		jmp		(DisplaySprite).l

.delete2:
		jmp		(DeleteObject).l
; ===========================================================================

.makeanimal:
		move.b	#2,(v_bossstatus).w
		move.b	#$C,obRoutine(a0)		; replace explosions with animals
		move.b	#6,obFrame(a0)
		move.w	#150,obTimeFrame(a0)
		addi.w	#$20,obY(a0)
		moveq	#7,d6
		move.w	#$9A,d5
		moveq	#-$1C,d4

.loop:
		jsr		(FindFreeObj).l
		bne.s	.fail
		_move.b	#id_Animals,obID(a1)	; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		add.w	d4,obX(a1)
		addq.w	#7,d4
		move.w	d5,objoff_36(a1)
		subq.w	#8,d5
; RetroKoH End-of-Level optimization
		move.w	a0,anml_capsule(a1)	; set capsule as parent
		addq.b	#1,pri_animalCt(a0)		; increment animal counter
; End-of-Level optimization end
		dbf		d6,.loop				; repeat 7 more	times

.fail:
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.w	.delete2
		jmp		(DisplaySprite).l	
; ===========================================================================

Pri_Animals:	; Routine $C
		moveq	#7,d0
		and.b	(v_vbla_byte).w,d0
		bne.s	.noanimal
		jsr		(FindFreeObj).l
		bne.s	.noanimal
		_move.b	#id_Animals,obID(a1)	; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
; RetroKoH End-of-Level optimization
		move.w	a0,anml_capsule(a1)	; set capsule as parent
		addq.b	#1,pri_animalCt(a0)		; increment animal counter
; End-of-Level optimization end
		jsr		(RandomNumber).w
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	.ispositive
		neg.w	d0

.ispositive:
		add.w	d0,obX(a1)
		move.w	#$C,objoff_36(a1)

.noanimal:
		subq.w	#1,obTimeFrame(a0)
		bne.s	.wait
	if EndLevelFadeMusic=1
		move.b	#mus_Fade,d0
		jsr		PlaySound_Special	; fade out music (RetroKoH)
	endif
		addq.b	#2,obRoutine(a0)
		move.w	#180,obTimeFrame(a0)

.wait:
		rts	
; ===========================================================================

Pri_EndAct:	; Routine $E
; RetroKoH End-of-Level optimization
		tst.b	pri_animalCt(a0)	; are any object $28 (animal) loaded?
		bne.s	.found				; if yes, branch
; End-of-Level optimization end

		jsr		(GotThroughAct).l
		jmp		(DeleteObject).l

.found:
		rts	
