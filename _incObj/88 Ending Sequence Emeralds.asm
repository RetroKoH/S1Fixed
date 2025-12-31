; ---------------------------------------------------------------------------
; Object 88 - chaos emeralds on	the ending sequence
; ---------------------------------------------------------------------------

EndChaos:
		cmpi.b	#2,(v_player+obFrame).w		; Note: `v_player` is Object 88, which has its own frames
		beq.s	ECha_CreateEms
		jmp		(DisplaySprite).l	
; ===========================================================================

ECha_CreateEms:
		move.w	(v_player+obX).w,obX(a0)	; match X position with Sonic
		move.w	(v_player+obY).w,obY(a0)	; match Y position with Sonic
		movea.l	a0,a1
		moveq	#0,d3
		moveq	#1,d2
		moveq	#emldCount-1,d1				; 5 (or 6 if SuperMod is on).

	.loop:
		_move.l	#ECha_Move,obAddr(a1)		; load chaos emerald object
		move.l	#Map_ECha,obMap(a1)
		move.w	#make_art_tile(ArtTile_Ending_Emeralds,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),obEChaos_StartX(a1)
		move.w	obY(a0),obEChaos_StartY(a1)
		move.b	d2,obAnim(a1)
		move.b	d2,obFrame(a1)
		addq.b	#1,d2
		move.b	d3,obAngle(a1)
		addi.b	#$100/emldCount,d3			; angle between each emerald
		lea		object_size(a1),a1
		dbf		d1,.loop					; repeat for each emerald
; ---------------------------------------------------------------------------

ECha_Move:
		move.w	obEChaos_Angle(a0),d0
		add.w	d0,obAngle(a0)
		move.b	obAngle(a0),d0

		calcsine_direct

		moveq	#0,d4
		move.b	obEChaos_Radius(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	obEChaos_StartX(a0),d1
		add.w	obEChaos_StartY(a0),d0
		move.w	d1,obX(a0)
		move.w	d0,obY(a0)

	.expand:
		cmpi.w	#$2000,obEChaos_Radius(a0)
		beq.s	.rotate
		addi.w	#$20,obEChaos_Radius(a0)	; expand circle of emeralds

	.rotate:
		cmpi.w	#$2000,obEChaos_Angle(a0)
		beq.s	.rise
		addi.w	#$20,obEChaos_Angle(a0)		; move emeralds around the centre

	.rise:
		cmpi.w	#$140,obEChaos_StartY(a0)
		beq.s	.end
		subq.w	#1,obEChaos_StartY(a0)		; make circle rise

	.end:
		jmp		(DisplaySprite).l	
; ===========================================================================