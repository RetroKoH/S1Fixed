; ---------------------------------------------------------------------------
; Object 8C - chaos emeralds on	the "TRY AGAIN"	screen
; ---------------------------------------------------------------------------

TryChaos:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	TCha_Move
	; Object Routine Optimization End

TCha_Main:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#emldCount-1,d1			; d1 = load total emeralds - 1
		sub.b	(v_emeralds).w,d1		; d1 = number of emeralds we don't have - 1

.makeemerald:
		move.b	#id_TryChaos,obID(a1)	; load emerald object
		addq.b	#2,obRoutine(a1)
		move.l	#Map_ECha,obMap(a1)
		move.w	#make_art_tile(ArtTile_Try_Again_Emeralds,0,0),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#$80,obPriority(a1)		; RetroKoH S2 Priority Manager
		move.w	#$104,obX(a1)
		move.w	#$120,objoff_38(a1)
		move.w	#$EC,obScreenY(a1)
		move.w	obScreenY(a1),objoff_3A(a1)
		move.b	#$1C,objoff_3C(a1)
		move.b	(v_emldlist).w,d4		; d4 = bit field that tells which emeralds we do/don't have
		moveq	#0,d0
		move.b	(v_emeralds).w,d0		; load # of total emeralds to d0
		beq.s	.loc_5B42				; branch ahead if you have no emeralds

	.chkemerald:
		btst	d2,d4			; Did you get the emerald?
		beq.s	.loc_5B42		; if not, branch ahead and set the mappings.
		addq.b	#1,d2			; Check for the next emerald.
		bra.s	.chkemerald		; Jump back and check again.
; ===========================================================================

.loc_5B42:
		move.b	d2,obFrame(a1)
		addq.b	#1,obFrame(a1)		; d2 + 1, as the first frame is the null frame. (Should set null frame to #7 to avoid this extra instruction)
		addq.b	#1,d2				; Add 1 to d2, to check for the next missing emerald.
		move.b	#$80,obAngle(a1)
		move.b	d3,obTimeFrame(a1)
		move.b	d3,obDelayAni(a1)
		addi.w	#10,d3
		lea		object_size(a1),a1
		dbf		d1,.makeemerald		; repeat d1 times... for every emerald we don't have

TCha_Move:	; Routine 2
		tst.w	objoff_3E(a0)
		beq.s	loc_5BBA
		tst.b	obTimeFrame(a0)
		beq.s	loc_5B78
		subq.b	#1,obTimeFrame(a0)
		bne.s	loc_5B80

loc_5B78:
		move.w	objoff_3E(a0),d0
		add.w	d0,obAngle(a0)

loc_5B80:
		move.b	obAngle(a0),d0
		beq.s	loc_5B8C
		cmpi.b	#$80,d0
		bne.s	loc_5B96

loc_5B8C:
		clr.w	objoff_3E(a0)
		move.b	obDelayAni(a0),obTimeFrame(a0)

loc_5B96:
		jsr		(CalcSine).l
		moveq	#0,d4
		move.b	objoff_3C(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	objoff_38(a0),d1
		add.w	objoff_3A(a0),d0
		move.w	d1,obX(a0)
		move.w	d0,obScreenY(a0)

loc_5BBA:
		jmp		(DisplaySprite).l	
