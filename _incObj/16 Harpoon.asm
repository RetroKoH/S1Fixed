; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)
; Rewritten by Hivebrain to now have customisable stab rate
;
; subtypes:
;	%00RR 00AA
;	RR - time between animations (+1, *30 for ost_obHarpoon_TimeMaster)
;	AA - starting animation (0/1 = horizontal; 2/3 = vertical)
; ---------------------------------------------------------------------------

Harpoon:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Harp_Index(pc,d0.w),d1
		jmp		Harp_Index(pc,d1.w)
; ===========================================================================

Harp_Index:	offsetTable
		offsetTableEntry.w Harp_Main
		offsetTableEntry.w Harp_Move
		offsetTableEntry.w Harp_Wait
		offsetTableEntry.w Harp_Move2	; +++
		offsetTableEntry.w Harp_Wait	; +++
; ===========================================================================

Harp_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Harp,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Harpoon,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.w	d0,d1
		andi.b	#%11,d0							; read bits 0-1 of subtype
		move.b	d0,obAnim(a0)					; get type (vert/horiz)
		move.b	#$14,obDispWid(a0)
		lsr.b	#4,d1							; read high nybble of subtype
		andi.b	#3,d1							; cap value at 0-3
		addq.b	#1,d1							; (1-4; max duration = 120 fr)

;		mulu.w	#30,d1 (The below method uses 26(4/0) instead of 50(2/0)
		add.b    d1,d1    ; multiply by 2
		move.b   d1,d2    ; d2 = (n << 1)
		lsl.b    #4,d1    ; d1 = (n << 5; or n * 32)
		sub.b    d2,d1    ; n*32 - n*2 = n*30

		move.w	d1,obHarp_Time(a0)				; set timer dynamically
		move.w	d1,obHarp_TimeMaster(a0)

Harp_Move:	; Routine 2
		lea		Ani_Harp(pc),a1
		jsr		(AnimateSprite).w				; animate and goto Harp_Wait next
		cmpi.b	#3,obTimeFrame(a0)
		bne.w	RememberState					; branch if frame hasn't updated
		moveq	#0,d0
		move.b	obFrame(a0),d0					; get frame number
		move.b	Harp_Hitbox_List(pc,d0.w),obColType(a0)	; get collision type
		bra.w	RememberState
; ===========================================================================

Harp_Hitbox_List:
		dc.b	(colHarmful|colSz_8x4)	; Horizontal (short)
		dc.b	(colHarmful|colSz_24x4)	; Horizontal (middle)
		dc.b	(colHarmful|colSz_40x4)	; Horizontal (extended)
		dc.b	(colHarmful|colSz_4x8)	; Vertical (short)
		dc.b	(colHarmful|colSz_4x24)	; Vertical (middle)
		dc.b	(colHarmful|colSz_4x40)	; Vertical (extended)
		even
; ===========================================================================

Harp_Wait:	; Routine 4
		subq.w	#1,obHarp_Time(a0)						; decrement timer
		bpl.w	RememberState							; branch if time remains
		move.w	obHarp_TimeMaster(a0),obHarp_Time(a0)	; reset timer
		subq.b	#2,obRoutine(a0)						; run "Harp_Move" subroutine
		bchg	#0,obAnim(a0)							; reverse animation
		bra.w	RememberState
; ===========================================================================