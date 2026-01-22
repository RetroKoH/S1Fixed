; ---------------------------------------------------------------------------
; Sub-Object -- Boss Exhaust Flame
; ---------------------------------------------------------------------------
; OST Constants
obBossFlame_PrevFrame:	equ	objoff_3B		; 1 byte  |
obBossFlame_Escape:		equ objoff_3C		; 2 bytes | escape speed of ship
obBossFlame_Parent:		equ objoff_3E		; 2 bytes | parent address (Eggman's ship)
; ---------------------------------------------------------------------------

BossFlame:
		movea.w	obBossFlame_Parent(a0),a3			; get address of parent object (ship)

	; Devon Boss Object Fix
		tst.l	obAddr(a3)
		beq.s	.delete								; branch if parent has been deleted
	; Boss Object Fix End

		tst.w	obVelX(a3)
		beq.s	.exit								; branch if ship isn't moving

		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Exhaust_Index(pc,d0.w),d1
		jsr		Exhaust_Index(pc,d1.w)
		lea		(Ani_Exhaust).l,a1
		jsr		(AnimateSprite).w
		bsr.w	Exhaust_LoadGfx
		move.w	obX(a3),obX(a0)
		move.w	obY(a3),obY(a0)
		move.b	obStatus(a3),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		jmp		(DisplaySprite).l
; ===========================================================================

	.exit:
		rts
; ===========================================================================

	.delete:
		jmp	DeleteObject
; ===========================================================================

Exhaust_Index:	offsetTable
		offsetTableEntry.w Exhaust_Main
		offsetTableEntry.w Exhaust_Chk
		offsetTableEntry.w Exhaust_Big
; ===========================================================================

Exhaust_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; goto Exhaust_Chk next
		move.l	#Map_Exhaust,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Exhaust,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.w	#priority3,obPriority(a0)
		move.b	#aniID_Flame1,obAnim(a0)		; use small flame
		bclr	#7,obAnim(a0)
; ---------------------------------------------------------------------------

Exhaust_Chk:	; Routine 2
		move.w	obBossFlame_Escape(a0),d0
		cmp.w	obVelX(a3),d0
		bgt.s	.exit							; branch if ship is moving slowly
		move.b	#aniID_EscapeFlame,obAnim(a0)	; use large flame when ship escapes
		bclr	#7,obAnim(a0)
		addq.b	#2,obRoutine(a0)				; goto Exhaust_Big next
		
	.exit:
		rts
; ===========================================================================

Exhaust_Big:	; Routine 4
		move.w	obBossFlame_Escape(a0),d0
		cmp.w	obVelX(a3),d0
		bls.s	.exit						; branch if ship is moving fast
		move.b	#aniID_Flame1,obAnim(a0)	; use small flame otherwise
		bclr	#7,obAnim(a0)
		subq.b	#2,obRoutine(a0)			; goto Exhaust_Chk next
		
	.exit:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Exhaust Flame dynamic pattern loading subroutine -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

Exhaust_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0					; load frame number
		cmp.b	obBossFlame_PrevFrame(a0),d0	; has frame changed?
		beq.s	.nochange						; if not, branch and exit

		move.b	d0,obBossFlame_PrevFrame(a0)	; update frame number for next check
		lea		DynPLC_Exhaust(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Eggman_Exhaust*tile_size),d4

	.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1					; S3K .b to .w
		move.w	d1,d3						; S3K
		lsr.w	#8,d3						; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_BossFlame,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry				; repeat for number of entries

	.nochange:
		rts
; ===========================================================================