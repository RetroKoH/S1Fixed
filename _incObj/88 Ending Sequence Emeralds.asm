; ---------------------------------------------------------------------------
; Object 88 - chaos emeralds on	the ending sequence
; ---------------------------------------------------------------------------

echa_origX = objoff_38	; x-axis centre of emerald circle (2 bytes)
echa_origY = objoff_3A	; y-axis centre of emerald circle (2 bytes)
echa_radius = objoff_3C	; radius (2 bytes)
echa_angle = objoff_3E	; angle for rotation (2 bytes)

EndChaos:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	ECha_Move
	; Object Routine Optimization End

ECha_Main:	; Routine 0
		cmpi.b	#2,(v_player+obFrame).w ; Note: `v_player` is Object 88, which has its own frames
		beq.s	ECha_CreateEms
		addq.l	#4,sp
		jmp		(DisplaySprite).l	
; ===========================================================================

ECha_CreateEms:
		move.w	(v_player+obX).w,obX(a0) ; match X position with Sonic
		move.w	(v_player+obY).w,obY(a0) ; match Y position with Sonic
		movea.l	a0,a1
		moveq	#0,d3
		moveq	#1,d2
		moveq	#emldCount-1,d1			; 5 (or 6 if SuperMod is on).

ECha_LoadLoop:
		move.b	#id_EndChaos,obID(a1)	; load chaos emerald object
		addq.b	#2,obRoutine(a1)
		move.l	#Map_ECha,obMap(a1)
		move.w	#make_art_tile(ArtTile_Ending_Emeralds,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),echa_origX(a1)
		move.w	obY(a0),echa_origY(a1)
		move.b	d2,obAnim(a1)
		move.b	d2,obFrame(a1)
		addq.b	#1,d2
		move.b	d3,obAngle(a1)
		addi.b	#$100/emldCount,d3		; angle between each emerald
		lea		object_size(a1),a1
		dbf		d1,ECha_LoadLoop		; repeat for each emerald

ECha_Move:	; Routine 2
		move.w	echa_angle(a0),d0
		add.w	d0,obAngle(a0)
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		moveq	#0,d4
		move.b	echa_radius(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	echa_origX(a0),d1
		add.w	echa_origY(a0),d0
		move.w	d1,obX(a0)
		move.w	d0,obY(a0)

ECha_Expand:
		cmpi.w	#$2000,echa_radius(a0)
		beq.s	ECha_Rotate
		addi.w	#$20,echa_radius(a0) ; expand circle of emeralds

ECha_Rotate:
		cmpi.w	#$2000,echa_angle(a0)
		beq.s	ECha_Rise
		addi.w	#$20,echa_angle(a0) ; move emeralds around the centre

ECha_Rise:
		cmpi.w	#$140,echa_origY(a0)
		beq.s	ECha_End
		subq.w	#1,echa_origY(a0) ; make circle rise

ECha_End:
		jmp		(DisplaySprite).l	
