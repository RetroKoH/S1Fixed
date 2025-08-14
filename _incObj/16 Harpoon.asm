; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)
; ---------------------------------------------------------------------------

harp_time = objoff_30		; time between stabbing/retracting

Harpoon:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.s	Harp_Move
		bpl.s	Harp_Wait
	; Object Routine Optimization End

Harp_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Harp,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Harpoon,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),obAnim(a0)		; get type (vert/horiz)
		move.b	#$14,obActWid(a0)
		move.w	#60,harp_time(a0)				; set time to 1 second

Harp_Move:	; Routine 2
		lea		Ani_Harp(pc),a1
		jsr		(AnimateSprite).w
		moveq	#0,d0
		move.b	obFrame(a0),d0					; get frame number
		move.b	.types(pc,d0.w),obColType(a0)	; get collision type
		bra.w	RememberState

.types:
		dc.b	(colHarmful|colSz_8x4), (colHarmful|colSz_24x4), (colHarmful|colSz_40x4)	; Horizontal Harpoons
		dc.b	(colHarmful|colSz_4x8), (colHarmful|colSz_4x24), (colHarmful|colSz_4x40)	; Vertical Harpoons
		even

Harp_Wait:	; Routine 4
		subq.w	#1,harp_time(a0)	; decrement timer
		bpl.w	RememberState		; branch if time remains
		move.w	#60,harp_time(a0)	; reset timer
		subq.b	#2,obRoutine(a0)	; run "Harp_Move" subroutine
		bchg	#0,obAnim(a0)		; reverse animation
		bra.w	RememberState