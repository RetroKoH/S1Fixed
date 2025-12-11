; ---------------------------------------------------------------------------
; Object 5A - platforms	moving in circles (SLZ)
; ---------------------------------------------------------------------------

CirclingPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jsr		Circ_Index(pc,d0.w)
		offscreen.w	DeleteObject,obCirc_StartX(a0)	; PFM S3K Obj
		bra.w	DisplaySprite
; ===========================================================================
Circ_Index:
		bra.s	Circ_Main
		bra.s	Circ_Platform
		bra.s	Circ_Action
; ===========================================================================

Circ_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Circ_Platform
		move.l	#Map_Circ,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obDispWid(a0)
		move.w	obX(a0),obCirc_StartX(a0)
		move.w	obY(a0),obCirc_StartY(a0)
; ---------------------------------------------------------------------------

Circ_Platform:	; Routine 2
		moveq	#0,d1
		move.b	obDispWid(a0),d1			; width
		jsr		(PlatformObject).l			; check for collision & goto Circ_Action next if stood on
		bra.w	Circ_Types
; ===========================================================================

Circ_Action:	; Routine 4
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		jsr		(ExitPlatform).l			; goto Circ_Platform next if Sonic leaves platform
		move.w	obX(a0),-(sp)
		bsr.w	Circ_Types
		move.w	(sp)+,d2
		jmp		(MvSonicOnPtfm2).l			; update Sonic's position
; ===========================================================================

Circ_Types:
	; LavaGaming/RetroKoH optimization
		moveq	#$C,d0
		and.b	obSubtype(a0),d0
		lsr.w	#1,d0
		tst.b	d0
		bne.s	Circ_Clockwise
; ---------------------------------------------------------------------------

; types 0-3
Circ_Anticlockwise:
		move.b	(v_oscillate+$22).w,d1		; get rotating value
		subi.b	#$50,d1						; set radius of circle
		ext.w	d1
		move.b	(v_oscillate+$26).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,obSubtype(a0)			; is type 1 or 3?
		beq.s	.not_1_or_3					; if not, branch
		neg.w	d1
		neg.w	d2

	.not_1_or_3:
		btst	#1,obSubtype(a0)			; is type 2 or 3?
		beq.s	.not_2_or_3					; if not, branch
		neg.w	d1
		exg		d1,d2

	.not_2_or_3:
		add.w	obCirc_StartX(a0),d1
		move.w	d1,obX(a0)
		add.w	obCirc_StartY(a0),d2
		move.w	d2,obY(a0)
		rts	
; ===========================================================================

; types 4-7
Circ_Clockwise:
		move.b	(v_oscillate+$22).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	(v_oscillate+$26).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,obSubtype(a0)			; is type 1 or 3?
		beq.s	.not_1_or_3					; if not, branch
		neg.w	d1
		neg.w	d2

	.not_1_or_3:
		btst	#1,obSubtype(a0)			; is type 2 or 3?
		beq.s	.not_2_or_3					; if not, branch
		neg.w	d1
		exg		d1,d2

	.not_2_or_3:
		neg.w	d1							; reverse x position delta
		add.w	obCirc_StartX(a0),d1
		move.w	d1,obX(a0)
		add.w	obCirc_StartY(a0),d2
		move.w	d2,obY(a0)
		rts	
; ===========================================================================