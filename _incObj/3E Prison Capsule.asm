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
		offsetTableEntry.w Pri_Body
		offsetTableEntry.w Pri_Switch
		offsetTableEntry.w Pri_Switch2
		offsetTableEntry.w Pri_Panel
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
		dc.b 	8,			$10,	5,0		; $C+6=$12 (subtype 3: unused panel)
		dc.w	priority3
; ===========================================================================

Pri_Main:	; Routine 0
		move.l	#Map_Pri,obMap(a0)
		move.w	#make_art_tile(ArtTile_Prison_Capsule,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	obY(a0),pri_origY(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0		; get subtype (0 or 1)
		move.b	d0,d1
		lsl.w	#2,d0
		lsl.b	#1,d1
		add.b	d1,d0
		lea		Pri_Var(pc,d0.w),a1
		move.b	(a1)+,obRoutine(a0)		; goto Pri_Body/Pri_Switch next
		move.b	(a1)+,obDispWid(a0)
		move.b	(a1)+,obFrame(a0)
		lea		1(a1),a1				; increment a1 to skip 00
		move.w	(a1)+,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.w	#8,d0					; is subtype == 2?
		bne.s	.not02					; if not, branch

		move.b	#(colEnemy|colSz_16x16),obColType(a0)
		move.b	#8,obColProp(a0)

	.not02:
		rts	
; ===========================================================================

Pri_Body:	; Routine 2
		cmpi.b	#2,(v_bossstatus).w		; has prison been opened?
		beq.s	.is_open				; if yes, branch

		moveq	#43,d1					; width; save 4 cycles -- Filter
		moveq	#24,d2					; height (jumping); save 4 cycles -- Filter
		moveq	#24,d3					; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4				; axis position
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		jsr		(SolidObject).l
		offscreen.s	.delete
		jmp		(DisplaySprite).l
; ===========================================================================

	.is_open:
		btst	#staSonicOnObj,obStatus(a0)		; is Sonic on top of the prison?
		beq.s	.not_on_top						; if not, branch
		bclr	#staSonicOnObj,obStatus(a0)
		bclr	#staOnObj,(v_player+obStatus).w
		bset	#staAir,(v_player+obStatus).w

	.not_on_top:
		move.b	#2,obFrame(a0)					; use frame number 2 (destroyed	prison)
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.s	.delete
		jmp		(DisplaySprite).l

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Pri_Switch:	; Routine 4
		moveq	#23,d1							; width; save 4 cycles -- Filter
		moveq	#8,d2							; height (jumping); save 4 cycles -- Filter
		moveq	#8,d3							; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4						; axis position
		jsr		(SolidObject).l
		lea		Ani_Pri(pc),a1
		jsr		(AnimateSprite).w
		move.w	pri_origY(a0),obY(a0)
		btst	#staSonicOnObj,obStatus(a0)		; is Sonic on top of the switch?
		beq.s	.not_on_top						; if not, branch

		addq.w	#8,obY(a0)						; move switch down 8px
		move.b	#$A,obRoutine(a0)				; -> Pri_Explosion
		move.b	#60,obTimeFrame(a0)				; set time for explosions to 1 sec
		clr.b	(f_timecount).w					; stop time counter
		clr.b	(f_lockscreen).w				; lock screen position
		move.b	#1,(f_lockctrl).w				; lock controls
		move.w	#(btnR<<8),(v_jpadheld_dup).w	; make Sonic run to the right
		bclr	#staSonicOnObj,obStatus(a0)
		bclr	#staOnObj,(v_player+obStatus).w
		bset	#staAir,(v_player+obStatus).w

	.not_on_top:
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.s	.delete
		jmp		(DisplaySprite).l

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Pri_Switch2:	; Routine 6
Pri_Panel:		; Routine 8
Pri_Explosion:	; Routine $A
		moveq	#7,d0
		and.b	(v_vbla_byte).w,d0			; byte that increments every frame
		bne.s	.noexplosion				; branch if any of bits 0-2 are set

		jsr		(FindFreeObj).l
		bne.s	.noexplosion				; branch if object slot not found
		_move.l	#ExplosionBomb,obAddr(a1)	; load explosion object every 8 frames
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		jsr		(RandomNumber).w
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,obX(a1)					; pseudorandom position
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,obY(a1)

	.noexplosion:
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		beq.s	.makeanimal					; branch if 0
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.s	.delete
		jmp		(DisplaySprite).l

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

	.makeanimal:
		move.b	#2,(v_bossstatus).w			; set flag for prison open
		move.b	#$C,obRoutine(a0)			; -> Pri_Animals
		move.b	#6,obFrame(a0)				; make switch invisible
		move.b	#150,obTimeFrame(a0)		; set time for additional animals to load to 2.5 secs
		addi.w	#$20,obY(a0)
		moveq	#7,d6						; number of animals to load (8)
		move.w	#$9A,d5						; animal jumping queue start
		moveq	#-$1C,d4					; relative x position

	.loop:
		jsr		(FindFreeObj).l
		bne.s	.fail						; branch if object slot not found
		_move.l	#Animals,obAddr(a1)		; load animal object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		add.w	d4,obX(a1)
		addq.w	#7,d4						; next animal loads 7px right
		move.w	d5,obAnimal_PrisonNum(a1)	; give each animal a num so it jumps at a different time
		subq.w	#8,d5						; decrement queue number
; RetroKoH End-of-Level optimization
		move.w	a0,obAnimal_CapsuleAddr(a1)	; set capsule as parent
		addq.b	#1,pri_animalCt(a0)			; increment animal counter
; End-of-Level optimization end
		dbf		d6,.loop					; repeat 7 more	times

	.fail:
	; Clownacy DisplaySprite Fix (Alt method by RetroKoH)
		offscreen.w	.delete2
		jmp		(DisplaySprite).l

	.delete2:
		jmp		(DeleteObject).l
; ===========================================================================

Pri_Animals:	; Routine $C
		moveq	#7,d0
		and.b	(v_vbla_byte).w,d0			; byte that increments every frame
		bne.s	.noanimal					; branch if any of bits 0-2 are set

		jsr		(FindFreeObj).l
		bne.s	.noanimal					; branch if object slot not found
		_move.l	#Animals,obAddr(a1)		; load animal object every 8 frames
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
; RetroKoH End-of-Level optimization
		move.w	a0,obAnimal_CapsuleAddr(a1)	; set capsule as parent
		addq.b	#1,pri_animalCt(a0)			; increment animal counter
; End-of-Level optimization end
		jsr		(RandomNumber).w
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	.ispositive
		neg.w	d0

	.ispositive:
		add.w	d0,obX(a1)					; pseudorandom position
		move.w	#$C,obAnimal_PrisonNum(a1)	; set time for animal to jump out

	.noanimal:
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bne.s	.wait						; branch if time remains

	if EndLevelFadeMusic
		move.b	#bgm_Fade,d0
		jsr		(QueueSound2).w				; fade out music (RetroKoH)
	endif

		addq.b	#2,obRoutine(a0)			; -> Pri_EndAct
		; removed useless obTimeFrame set

	.wait:
		rts	
; ===========================================================================

Pri_EndAct:	; Routine $E
; RetroKoH End-of-Level optimization
		tst.b	pri_animalCt(a0)			; are any object $28 (animal) loaded?
		bne.s	.found						; if yes, branch
; End-of-Level optimization end

		jsr		(GotThroughAct).l
		jmp		(DeleteObject).l

	.found:
		rts	
; ===========================================================================