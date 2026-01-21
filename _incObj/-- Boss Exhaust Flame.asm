; ---------------------------------------------------------------------------
; Sub-Object -- Boss Exhaust Flame
; ---------------------------------------------------------------------------
; OST Constants
obBossFlame_Escape:		equ objoff_3C		; 2 bytes | escape speed of ship
obBossFlame_Parent:		equ objoff_3E		; 2 bytes | parent address (Eggman's ship)
; ---------------------------------------------------------------------------

BossFlame:
		movea.w	obBossFlame_Parent(a0),a2			; get address of parent object (ship)

	; Devon Boss Object Fix
		tst.l	obAddr(a2)
		beq.s	.delete								; branch if parent has been deleted
	; Boss Object Fix End

		tst.w	obVelX(a2)
		beq.s	.exit								; branch if ship isn't moving

		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Exhaust_Index(pc,d0.w),d1
		jsr		Exhaust_Index(pc,d1.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w

		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)
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
		addq.b	#2,obRoutine(a0)			; goto Exhaust_Chk next
		move.l	#Map_Eggman,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.w	#priority3,obPriority(a0)
		move.b	#aniID_Flame1,obAnim(a0)	; use small flame
		bclr	#7,obAnim(a0)
; ---------------------------------------------------------------------------

Exhaust_Chk:	; Routine 2
		move.w	obBossFlame_Escape(a0),d0
		cmp.w	obVelX(a2),d0
		bgt.s	.exit							; branch if ship is moving slowly
		move.b	#aniID_EscapeFlame,obAnim(a0)	; use large flame when ship escapes
		addq.b	#2,obRoutine(a0)				; goto Exhaust_Big next
		
	.exit:
		rts
; ===========================================================================

Exhaust_Big:	; Routine 4
		move.w	obBossFlame_Escape(a0),d0
		cmp.w	obVelX(a2),d0
		bls.s	.exit						; branch if ship is moving fast
		move.b	#aniID_Flame1,obAnim(a0)	; use small flame otherwise
		subq.b	#2,obRoutine(a0)			; goto Exhaust_Chk next
		
	.exit:
		rts
; ===========================================================================