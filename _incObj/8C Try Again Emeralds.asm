; ---------------------------------------------------------------------------
; Object 8C - chaos emeralds on	the "TRY AGAIN"	screen
; ---------------------------------------------------------------------------

TryChaos:
		movea.l	a0,a1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#emldCount-1,d1				; d1 = load total emeralds - 1
		sub.b	(v_emeralds).w,d1			; d1 = number of emeralds we don't have - 1

	.makeemerald:
		_move.l	#TCha_Move,obAddr(a1)		; load emerald object
		move.l	#Map_ECha,obMap(a1)
		move.w	#make_art_tile(ArtTile_Try_Again_Emeralds,0,0),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	#$104,obX(a1)
		move.w	#$120,obTChaos_StartX(a1)
		move.w	#$EC,obScreenY(a1)
		move.w	obScreenY(a1),obTChaos_StartY(a1)
		move.b	#$1C,obTChaos_Radius(a1)
		lea		(v_emldlist).w,a3			; a3 = bitfield that tells which emeralds we do/don't have (loading to a3 instead of dx saves 4 cycles)
		moveq	#0,d0
		move.b	(v_emeralds).w,d0			; load # of total emeralds to d0
		beq.s	.doesnt_have				; branch ahead if you have no emeralds

	.chkemerald:
		btst	d2,(a3)						; did you get the emerald? (Using a bitfield saves 8 cycles here)
		beq.s	.doesnt_have				; if not, branch ahead and set the mappings.
		addq.b	#1,d2						; Check for the next emerald.
		bra.s	.chkemerald					; Jump back and check again.
; ===========================================================================

.doesnt_have:
		move.b	d2,obFrame(a1)
		addq.b	#1,obFrame(a1)				; d2 + 1, as the first frame is the null frame. (Should set null frame to #7 to avoid this extra instruction)
		addq.b	#1,d2						; Add 1 to d2, to check for the next missing emerald.
		move.b	#$80,obAngle(a1)
		move.b	d3,obTimeFrame(a1)
		move.b	d3,obTChaos_TimeMaster(a1)
		addi.w	#10,d3
		lea		object_size(a1),a1
		dbf		d1,.makeemerald				; repeat d1 times... for every emerald we don't have
; ---------------------------------------------------------------------------

TCha_Move:
		tst.w	obTChaos_Speed(a0)			; should be 0, 2 or -2 (changed by Eggman object)
		beq.s	.no_move					; branch if 0
		tst.b	obTimeFrame(a0)
		beq.s	.update_angle				; branch if timer is 0
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bne.s	.chk_angle					; branch if not 0

	.update_angle:
		move.w	obTChaos_Speed(a0),d0		; 2 or -2
		add.w	d0,obAngle(a0)				; update angle

	.chk_angle:
		move.b	obAngle(a0),d0				; get angle
		beq.s	.angle_0					; branch if 0
		cmpi.b	#$80,d0
		bne.s	.angle_not_80				; branch if not $80

	.angle_0:
		clr.w	obTChaos_Speed(a0)
		move.b	obTChaos_TimeMaster(a0),obTimeFrame(a0)

	.angle_not_80:
		jsr		(CalcSine).w				; convert angle (d0) to sine (d0) and cosine (d1)
		moveq	#0,d4
		move.b	obTChaos_Radius(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	obTChaos_StartX(a0),d1
		add.w	obTChaos_StartY(a0),d0
		move.w	d1,obX(a0)
		move.w	d0,obScreenY(a0)

	.no_move:
		jmp		(DisplaySprite).l	
; ===========================================================================