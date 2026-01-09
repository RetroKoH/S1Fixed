; ---------------------------------------------------------------------------
; Object 6B - stomper (SBZ)
;
; Subtype xxDDxxxB
; ---------------------------------------------------------------------------

; ===========================================================================
Sto_MoveDist:
		dc.b	$38
		dc.b	$40
		dc.b	$60
		dc.b	$80		; unused
; ===========================================================================

ScrapStomp:
		_move.l	#Sto_Action,obAddr(a0)
		move.b	#$1C,obDispWid(a0)
		move.b	#$20,obHeight(a0)
		move.l	#Map_Stomp,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),obStomp_StartY(a0)
		moveq	#$30,d0
		and.b	obSubtype(a0),d0
		lsr.w	#4,d0
		lea		Sto_MoveDist(pc,d0.w),a3
		move.b	(a3)+,d0
		move.w	d0,obStomp_DistToMove(a0)	; set distance to move
		moveq	#1,d0
		and.b	obSubtype(a0),d0			; get least significant bit
		add.b	d0,d0						; multiply by 2
		move.b	d0,obStomp_Behavior(a0)

Sto_Action:	; Routine 2
		moveq	#0,d0
		move.b	obStomp_Behavior(a0),d0
		move.w	Sto_Index(pc,d0.w),d1
		jsr		Sto_Index(pc,d1.w)

		tst.b	obRender(a0)				; is object on-screen?
		bpl.s	.chkdel						; if not, branch

		; solidity
		moveq	#39,d1						; width
		moveq	#32,d2						; height (jumping)
		moveq	#33,d3						; height (walking)
		move.w	obX(a0),d4					; axis position
		jsr		(SolidObject).l

	.chkdel:
		offscreen.s	.delete
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================

Sto_Index:	offsetTable
		offsetTableEntry.w Sto_Drop_RiseSlow
		offsetTableEntry.w Sto_Drop_RiseFast
; ===========================================================================

; Type 1/3
; Stomper, drops quickly and rises slowly
Sto_Drop_RiseSlow:
		tst.b	obStomp_MoveFlag(a0)
		bne.s	.isactive03
		tst.w	obStomp_DistMoved(a0)		; has stomper started moving?
		beq.s	.wait						; if not, branch
		subq.w	#1,obStomp_DistMoved(a0)	; move up 1px
		bra.s	.update_pos
; ===========================================================================

	.wait:
		subq.b	#1,obStomp_WaitTime(a0)		; decrement wait time
		bpl.s	.update_pos					; branch if time remains
		move.b	#60,obStomp_WaitTime(a0)	; set wait time to 1 second
		move.b	#1,obStomp_MoveFlag(a0)

	.isactive03:
		addq.w	#8,obStomp_DistMoved(a0)	; move down 8px
		move.w	obStomp_DistMoved(a0),d0
		cmp.w	obStomp_DistToMove(a0),d0	; has stomper reached maximum distance?
		bne.s	.update_pos					; if not, branch
		clr.b	obStomp_MoveFlag(a0)

	.update_pos:
		move.w	obStomp_DistMoved(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip03
		neg.w	d0
		addi.w	#$38,d0

	.noflip03:
		move.w	obStomp_StartY(a0),d1		; get initial y pos
		add.w	d0,d1						; apply difference
		move.w	d1,obY(a0)					; update position
		rts	
; ===========================================================================

; Type 2/4
; Stomper, drops quickly and rises quickly
Sto_Drop_RiseFast:
		tst.b	obStomp_MoveFlag(a0)
		bne.s	.isactive04
		tst.w	obStomp_DistMoved(a0)		; has stomper started moving?
		beq.s	.wait						; if not, branch
		subq.w	#8,obStomp_DistMoved(a0)	; move up 8px
		bra.s	.update_pos
; ===========================================================================

	.wait:
		subq.b	#1,obStomp_WaitTime(a0)		; decrement wait time
		bpl.s	.update_pos					; branch if time remains
		move.b	#60,obStomp_WaitTime(a0)	; set wait time to 1 second
		move.b	#1,obStomp_MoveFlag(a0)

	.isactive04:
		move.w	obStomp_DistMoved(a0),d0
		cmp.w	obStomp_DistToMove(a0),d0	; has stomper reached maximum distance?
		beq.s	.wait2						; if not, branch
		addq.w	#8,obStomp_DistMoved(a0)	; move down 8px
		bra.s	.update_pos
; ===========================================================================

	.wait2:
		subq.b	#1,obStomp_WaitTime(a0)		; decrement wait time
		bpl.s	.update_pos					; branch if time remains
		move.b	#60,obStomp_WaitTime(a0)	; set wait time to 1 second
		clr.b	obStomp_MoveFlag(a0)

	.update_pos:
		move.w	obStomp_DistMoved(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip04
		neg.w	d0
		addi.w	#$38,d0

	.noflip04:
		move.w	obStomp_StartY(a0),d1		; get initial y pos
		add.w	d0,d1						; apply difference
		move.w	d1,obY(a0)					; update position
		rts	
; ===========================================================================