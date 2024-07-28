; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)
; ---------------------------------------------------------------------------

Harpoon:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		Harp_Index(pc,d0.w)	; RetroKoH Object Routine Optimization
; ===========================================================================
Harp_Index:
		bra.s	Harp_Main
		bra.s	Harp_Move
		bra.s	Harp_Wait

harp_time = objoff_30		; time between stabbing/retracting
; ===========================================================================

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
		dc.b $9B, $9C, $9D, $9E, $9F, $A0
		even

Harp_Wait:	; Routine 4
		subq.w	#1,harp_time(a0)	; decrement timer
		bpl.w	RememberState		; branch if time remains
		move.w	#60,harp_time(a0)	; reset timer
		subq.b	#2,obRoutine(a0)	; run "Harp_Move" subroutine
		bchg	#0,obAnim(a0)		; reverse animation
		bra.w	RememberState