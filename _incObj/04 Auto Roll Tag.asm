; ----------------------------------------------------------------------------
; Object 04 - Pinball mode enable/disable
; Backported from Sonic 2's Obj84 by RetroKoH
; ----------------------------------------------------------------------------

AutoRollTag:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	AutoRoll_Index(pc,d0.w),d1
		jsr		AutoRoll_Index(pc,d1.w)

	if DebugPathSwappers
		tst.w	(f_debugcheat).w
		bne.w	RememberState
	endif

		; like RememberState, but doesn't display (Sonic 2's MarkObjGone3)
		out_of_range.w	.offscreen
		rts

.offscreen:
	; ProjectFM S3K Objects Manager (RetroKoH additional change)
		move.w	obRespawnAddr(a0),d0	; get address in respawn table
		beq.s	.delete				; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
	; S3K Objects Manaager End

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

AutoRoll_Index:	offsetTable
		offsetTableEntry.w AutoRoll_Init	; 0
		offsetTableEntry.w AutoRoll_MainX	; 2
		offsetTableEntry.w AutoRoll_MainY	; 4
; ===========================================================================

AutoRoll_Init:
		addq.b	#2,obRoutine(a0) ; => AutoRoll_MainX
		move.l	#Map_PathSwapper,obMap(a0)
		move.w	#$27B2,obGfx(a0)			; change this
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	AutoRoll_Init_CheckX
;AutoRoll_Init_CheckY:
		addq.b	#2,obRoutine(a0) ; => AutoRoll_MainY
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_211E8(pc,d0.w),objoff_32(a0)
		move.w	obY(a0),d1
		lea		(v_player).w,a1 ; a1=character
		cmp.w	obY(a1),d1
		bhs.w	AutoRoll_MainY
		move.b	#1,objoff_34(a0)
		bra.w	AutoRoll_MainY
; ===========================================================================

word_211E8:
		dc.w   $20
		dc.w   $40	; 1
		dc.w   $80	; 2
		dc.w  $100	; 3
; ===========================================================================

AutoRoll_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	word_211E8(pc,d0.w),objoff_32(a0)
		move.w	obX(a0),d1
		lea		(v_player).w,a1		; a1=character
		cmp.w	obX(a1),d1
		bhs.s	AutoRoll_MainX
		move.b	#1,objoff_34(a0)

AutoRoll_MainX:
		tst.w	(v_debuguse).w
		bne.s	.locret
		move.w	obX(a0),d1
		lea		objoff_34(a0),a2	; a2=$34(a0)
		lea		(v_player).w,a1		; a1=character
		tst.b	(a2)+				; test $34(a0); a2=$35(a0)
		bne.s	AutoRoll_MainX_Alt
		cmp.w	obX(a1),d1
		bhi.s	.locret
		move.b	#1,-1(a2)			; load to $34(a0)
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		btst	#0,obRender(a0)
		bne.s	.jump
		move.b	#1,obAutoRollFlag(a1) ; enable must-roll "pinball mode"
		bra.s	AutoRoll_ChkRoll
; ---------------------------------------------------------------------------

	.jump:
		move.b	#0,obAutoRollFlag(a1) ; disable pinball mode

	.locret:
		rts
; ===========================================================================

AutoRoll_MainX_Alt:
		cmp.w	obX(a1),d1
		bls.s	.locret
		clr.b	-1(a2)				; clear $34(a0)
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		btst	#0,obRender(a0)
		beq.s	.jump
		move.b	#1,obAutoRollFlag(a1) ; enable must-roll "pinball mode"
		bra.s	AutoRoll_ChkRoll
; ---------------------------------------------------------------------------

	.jump:
		move.b	#0,obAutoRollFlag(a1) ; disable pinball mode

	.locret:
		rts
; ===========================================================================

AutoRoll_ChkRoll:
; the original S2 code had a copy of the Chk Roll code
; I went this route, in case there are modifications to ChkRoll, and to keep code cleaner
		move.l	a0,-(sp)
		movea.l	a1,a0			; move player to a0
		bsr.w	Sonic_ChkRoll
		movea.l	(sp)+,a0		; restore a0 = obj04
		rts
; ===========================================================================

AutoRoll_MainY:
		tst.w	(v_debuguse).w
		bne.s	.ret
		move.w	obY(a0),d1
		lea		objoff_34(a0),a2		; a2=object
		lea		(v_player).w,a1			; a1=character
		tst.b	(a2)+
		bne.s	AutoRoll_MainY_Alt
		cmp.w	obY(a1),d1
		bhi.s	.ret
		move.b	#1,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blo.s	.ret
		cmp.w	d3,d4
		bhs.s	.ret
		btst	#0,obRender(a0)
		bne.s	.jump
		move.b	#1,obAutoRollFlag(a1)
		bra.w	AutoRoll_ChkRoll
; ---------------------------------------------------------------------------

	.jump:
		move.b	#0,obAutoRollFlag(a1)

	.ret:
		rts
; ===========================================================================

AutoRoll_MainY_Alt:
		cmp.w	obY(a1),d1
		bls.s	.ret
		move.b	#0,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blo.s	.ret
		cmp.w	d3,d4
		bhs.s	.ret
		btst	#0,obRender(a0)
		beq.s	.jump
		move.b	#1,obAutoRollFlag(a1)
		bra.w	AutoRoll_ChkRoll
; ---------------------------------------------------------------------------

	.jump:
		move.b	#0,obAutoRollFlag(a1)

	.ret:
		rts