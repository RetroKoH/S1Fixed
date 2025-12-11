; ---------------------------------------------------------------------------
; Object 65 - waterfalls (LZ)
; ---------------------------------------------------------------------------

Waterfall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	WFall_Index(pc,d0.w),d1
		jmp		WFall_Index(pc,d1.w)
; ===========================================================================

WFall_Index:	offsetTable
		offsetTableEntry.w WFall_Main
		offsetTableEntry.w WFall_Animate
		offsetTableEntry.w WFall_ChkDel
		offsetTableEntry.w WFall_OnWater
		offsetTableEntry.w WFall_Priority
; ===========================================================================

WFall_Main:	; Routine 0
		addq.b	#4,obRoutine(a0)			; -> WFall_ChkDel
		move.l	#Map_WFall,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Waterfall,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$18,obDispWid(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0			; get object type
		bpl.s	.under80					; branch if $00-$7F
		bset	#gfxPriority,obGfx(a0)

	.under80:
		andi.b	#$F,d0						; read only the	low nybble
		move.b	d0,obFrame(a0)				; set frame number
		cmpi.b	#9,d0						; is object type $x9 (splash)?
		bne.s	WFall_ChkDel				; if not, branch

		move.w	#priority0,obPriority(a0)	; object is in front of Sonic -- RetroKoH/Devon S3K+ Priority Manager
		subq.b	#2,obRoutine(a0)			; -> WFall_Animate
		btst	#6,obSubtype(a0)			; is object type $49?
		beq.s	.not49						; if not, branch

		move.b	#6,obRoutine(a0)			; -> WFall_OnWater

	.not49:
		btst	#5,obSubtype(a0)			; is object type $A9?
		beq.s	WFall_Animate				; if not, branch
		move.b	#8,obRoutine(a0)			; -> WFall_Priority
; ---------------------------------------------------------------------------

WFall_Animate:	; Routine 2
		lea		Ani_WFall(pc),a1
		jsr		(AnimateSprite).w
; ---------------------------------------------------------------------------

WFall_ChkDel:	; Routine 4
		bra.w	RememberState
; ===========================================================================

WFall_OnWater:	; Routine 6
		move.w	(v_waterpos_actual).w,d0
		subi.w	#$10,d0
		move.w	d0,obY(a0)					; match	object position	to water height
		lea		Ani_WFall(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

WFall_Priority:	; Routine 8
		bclr	#gfxPriority,obGfx(a0)
		cmpi.w	#$1718,(v_lvllayout+$50C).w	; has level been modified by pressing a button? (LZ3 only)
		bne.s	.animate					; if not, branch
		bset	#gfxPriority,obGfx(a0)		; high priority sprite

	.animate:
		lea		Ani_WFall(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================