; ---------------------------------------------------------------------------
; Object 2A - small vertical door (SBZ)
; ---------------------------------------------------------------------------

AutoDoor:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	ADoor_OpenShut
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

ADoor_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_ADoor,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Door,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#8,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

ADoor_OpenShut:	; Routine 2
		move.w	#64,d1					; set range for door detection
		clr.b	obAnim(a0)				; use "closing"	animation
		move.w	(v_player+obX).w,d0
		add.w	d1,d0					; d0 = 64px right of Sonic
		cmp.w	obX(a0),d0				; is Sonic > 64px left of door?
		blo.s	ADoor_Animate			; if yes, branch
		sub.w	d1,d0
		sub.w	d1,d0					; d0 = 64px left of Sonic
		cmp.w	obX(a0),d0				; is Sonic > 64px right of door?
		bhs.s	ADoor_Animate			; if yes, branch

		add.w	d1,d0					; d0 = Sonic's x position
		cmp.w	obX(a0),d0				; is Sonic left of the door?
		bhs.s	.sonic_is_left			; if yes, branch
		btst	#staFlipX,obStatus(a0)
		bne.s	ADoor_Animate
		bra.s	ADoor_Open
; ===========================================================================

	.sonic_is_left:
		btst	#staFlipX,obStatus(a0)
		beq.s	ADoor_Animate
; ---------------------------------------------------------------------------

ADoor_Open:
		move.b	#1,obAnim(a0)			; use "opening" animation if Sonic is on active side of door

ADoor_Animate:
		lea		Ani_ADoor(pc),a1
		bsr.w	AnimateSprite
		tst.b	obFrame(a0)				; is the door open?
		bne.w	RememberState			; if yes, branch
		move.w	#$11,d1
		move.w	#$20,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================
