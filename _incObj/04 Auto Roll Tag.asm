; ----------------------------------------------------------------------------
; Object 04 - Pinball mode enable/disable
; Backported from Sonic 2's Obj84, and rewritten by RetroKoH
; ----------------------------------------------------------------------------

AutoRollTag:
		move.l	#Map_PathSwapper,obMap(a0)
		move.w	#$27B2,obGfx(a0)			; change this
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	ARoll_Init_CheckX

;ARoll_Init_CheckY:
		obj_addr	#ARoll_MainY
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	ARoll_Sizes(pc,d0.w),obARoll_Radius(a0)
		move.w	obY(a0),d1
		lea		(v_player).w,a1
		cmp.w	obY(a1),d1
		bhs.w	ARoll_MainY
		move.b	#1,obARoll_Flag(a0)
		bsr.w	ARoll_MainY
		bra.s	ARoll_ChkDel
; ===========================================================================

ARoll_Sizes:
		dc.w   $20
		dc.w   $40	; 1
		dc.w   $80	; 2
		dc.w  $100	; 3
; ===========================================================================

ARoll_Init_CheckX:
		obj_addr	#ARoll_MainX
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	ARoll_Sizes(pc,d0.w),obARoll_Radius(a0)
		move.w	obX(a0),d1
		lea		(v_player).w,a1
		cmp.w	obX(a1),d1
		bhs.s	ARoll_MainX
		move.b	#1,obARoll_Flag(a0)
		bsr.w	ARoll_MainX
; ----------------------------------------------------------------------------

ARoll_ChkDel:
	if DebugPathSwappers
		tst.w	(f_debugcheat).w
		bne.w	RememberState
	endif

		; like RememberState, but doesn't display (Sonic 2's MarkObjGone3)
		out_of_range.w	.offscreen
		rts

	.offscreen:
	; ProjectFM S3K Objects Manager (RetroKoH additional change)
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.delete						; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
	; S3K Objects Manaager End

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

ARoll_MainX:
		tst.w	(v_debuguse).w
		bne.s	ARoll_Exit
		move.w	obX(a0),d1
		lea		obARoll_Flag(a0),a2			; a2 = obARoll_Flag
		lea		(v_player).w,a1
		tst.b	(a2)						; is obARoll_Flag set?
		bne.s	ARoll_MainX_Alt				; if yes, branch
		cmp.w	obX(a1),d1
		bhi.s	ARoll_Exit
		move.b	#1,(a2)						; set obARoll_Flag
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	ARoll_Exit
		cmp.w	d3,d4
		bge.s	ARoll_Exit
		btst	#0,obRender(a0)
		bne.s	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.s	ARoll_ChkRoll
; ===========================================================================

ARoll_MainX_Alt:
		cmp.w	obX(a1),d1
		bls.s	ARoll_Exit
		clr.b	(a2)						; clear obARoll_Flag
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	ARoll_Exit
		cmp.w	d3,d4
		bge.s	ARoll_Exit
		btst	#0,obRender(a0)
		beq.s	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.s	ARoll_ChkRoll
; ===========================================================================

ARoll_Disable:
		move.b	#0,obAutoRollFlag(a1)		; disable auto roll mode

ARoll_Exit:
		rts
; ===========================================================================

ARoll_ChkRoll:
; the original S2 code had a copy of the Chk Roll code
; I went this route, in case there are modifications to ChkRoll, and to keep code cleaner
		move.l	a0,-(sp)
		movea.l	a1,a0						; move player to a0
		bsr.w	Sonic_ChkRoll
		movea.l	(sp)+,a0					; restore a0 = obj04
		rts
; ===========================================================================

ARoll_MainY:
		tst.w	(v_debuguse).w
		bne.s	ARoll_Exit
		move.w	obY(a0),d1
		lea		obARoll_Flag(a0),a2			; a2 = obARoll_Flag
		lea		(v_player).w,a1
		tst.b	(a2)						; is obARoll_Flag set?
		bne.s	ARoll_MainY_Alt				; if yes, branch
		cmp.w	obY(a1),d1
		bhi.s	ARoll_Exit
		move.b	#1,(a2)						; set obARoll_Flag
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blo.s	ARoll_Exit
		cmp.w	d3,d4
		bhs.s	ARoll_Exit
		btst	#0,obRender(a0)
		bne.s	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.w	ARoll_ChkRoll
; ===========================================================================

ARoll_MainY_Alt:
		cmp.w	obY(a1),d1
		bls.s	ARoll_Exit
		clr.b	(a2)						; clear obARoll_Flag
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blo.s	ARoll_Exit
		cmp.w	d3,d4
		bhs.s	ARoll_Exit
		btst	#0,obRender(a0)
		beq.w	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.w	ARoll_ChkRoll
; ===========================================================================