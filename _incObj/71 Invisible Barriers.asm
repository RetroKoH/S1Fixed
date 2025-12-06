; ---------------------------------------------------------------------------
; Object 71 - invisible	solid barriers
; ---------------------------------------------------------------------------

Invisibarrier:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Invis_Solid
	; Object Routine Optimization End

Invis_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Invis_Solid
		move.l	#Map_Invis,obMap(a0)
		move.w	#make_art_tile(ArtTile_Monitor,0,1),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0			; get object subtype
		move.b	d0,d1
		andi.w	#$F0,d0						; read only the	high nybble
		addi.w	#$10,d0						; add $10
		lsr.w	#1,d0						; divide by 2
		move.b	d0,obDispWid(a0)			; set object width
		andi.w	#$F,d1						; read only the	low nybble
		addq.w	#1,d1						; add 1
		lsl.w	#3,d1						; multiply by 8
		move.b	d1,obHeight(a0)				; set object height
; ---------------------------------------------------------------------------

Invis_Solid:	; Routine 2
		bsr.w	ChkSizedObjVisible			; is object off screen? (Devon Checking For Solids Fix)
		bne.s	.chkdel						; if yes, branch
		moveq	#11,d1
		add.b	obDispWid(a0),d1			; width; save 8 cycles
		moveq	#0,d2
		move.b	obHeight(a0),d2				; height (jumping)
		move.w	d2,d3
		addq.w	#1,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject71				; SolidObject_NoRenderChk

	.chkdel:
		offscreen.s	.delete					; ProjectFM S3K Object Manager
		tst.w	(v_debuguse).w				; are you using	debug mode?
		beq.s	.nodisplay					; if not, branch
		jmp		(DisplaySprite).l			; if yes, display the object
; ===========================================================================

	.nodisplay:
		rts	
; ===========================================================================

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================