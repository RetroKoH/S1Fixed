; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)
; Rewritten by Hivebrain to now have customisable stab rate
;
; subtypes:
;	%S0RR 00AA
;	S - 1 for forced synchronisation (ignores RR, changes every 64 frames instead)
;	RR - time between animations (+1, *30 for ost_obHarpoon_TimeMaster)
;	AA - starting animation (0/1 = horizontal; 2/3 = vertical)
;
; TO-DO: Allow RR to dictate how many frames in sequence, OR use RR to determine a timing offset
; for sync movement, so we can have sequential Harpoons.
; ALSO: Can we fix collision to only run from the base to the point? if placed in air, on on thin ground,
; it can hurt Sonic from the opposite end.
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
		offsetTableEntry.w Harp_Wait2	; +++
; ===========================================================================

Harp_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> Harp_Move
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

		tst.b	d1								; is harpoon on synchronized time?
		bpl.s	.no_sync						; if not, branch
		addq.b	#4,obRoutine(a0)				; -> Harp_Move2
		bra.s	Harp_Move2
		
	.no_sync:
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
Harp_Move2:	; Routine 6
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
		bclr	#7,obAnim(a0)							; clear restart flag
		bra.w	RememberState
; ===========================================================================

Harp_Wait2:	; Routine 8
		move.b	(v_framebyte).w,d0
		move.b	d0,d2
		andi.b	#%00111111,d0
		bne.w	RememberState				; branch if not on 64th frame
		subq.b	#2,obRoutine(a0)			; -> Harp_Move2
		btst	#0,obSubtype(a0)
		beq.s	.not_inverted
		not.b	d2							; stab/retract are reversed
		
	.not_inverted:
		andi.b	#%01000000,d2
		lsr.b	#6,d2						; get bit 6 from frame counter
		move.b	obAnim(a0),d0
		andi.b	#%01111110,d0				; clear bits 0 and 7 of anim id
		or.b	d2,d0						; combine with bit from frame counter
		move.b	d0,obAnim(a0)				; next animation
		bra.w	RememberState
; ===========================================================================