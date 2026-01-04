; ----------------------------------------------------------------------------
; Object 04 - Pinball mode enable/disable
; Backported from Sonic 2's Obj84; rewritten by RetroKoH
; ----------------------------------------------------------------------------

AutoRollTag:
		move.l	#Map_PathSwapper,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ring,0,0),obGfx(a0)	; Like Pathswapper, but red
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	ARoll_Init_CheckX

;ARoll_Init_CheckY:
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	ARoll_Sizes(pc,d0.w),obARoll_Radius(a0)
		obj_addr	#ARoll_MainY
		move.w	obY(a0),d1
		lea		(v_player).w,a1
		cmp.w	obY(a1),d1
		bhs.w	ARoll_MainY
		move.b	#1,obARoll_Flag(a0)
		bra.w	ARoll_MainY
; ===========================================================================

ARoll_Sizes:
		dc.w   $20
		dc.w   $40	; 1
		dc.w   $80	; 2
		dc.w  $100	; 3
; ===========================================================================

ARoll_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	ARoll_Sizes(pc,d0.w),obARoll_Radius(a0)
		obj_addr	#ARoll_MainX
		move.w	obX(a0),d1
		lea		(v_player).w,a1
		cmp.w	obX(a1),d1
		bhs.s	ARoll_MainX
		move.b	#1,obARoll_Flag(a0)
		bra.s	ARoll_MainX
; ===========================================================================

ARoll_Disable:
		move.b	#0,obAutoRollFlag(a1)		; disable auto roll mode
		bra.w	ARoll_ChkDel
; ===========================================================================

ARoll_ChkRoll:
; the original S2 code had a copy of the Chk Roll code
; I went this route, in case there are modifications to ChkRoll, and to keep code cleaner
		move.l	a0,-(sp)
		movea.l	a1,a0						; move player to a0
		bsr.w	Sonic_ChkRoll
		movea.l	(sp)+,a0					; restore a0 = obj04
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
		bne.s	ARoll_ChkDel
		move.w	obX(a0),d1
		lea		obARoll_Flag(a0),a2			; a2 = obARoll_Flag
		lea		(v_player).w,a1
		tst.b	(a2)						; is obARoll_Flag set?
		bne.s	ARoll_MainX_Alt				; if yes, branch
		cmp.w	obX(a1),d1
		bhi.s	ARoll_ChkDel
		move.b	#1,(a2)						; set obARoll_Flag
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	ARoll_ChkDel
		cmp.w	d3,d4
		bge.s	ARoll_ChkDel
		btst	#0,obRender(a0)
		bne.w	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.w	ARoll_ChkRoll
; ===========================================================================

ARoll_MainX_Alt:
		cmp.w	obX(a1),d1
		bls.w	ARoll_ChkDel
		clr.b	(a2)						; clear obARoll_Flag
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.w	ARoll_ChkDel
		cmp.w	d3,d4
		bge.w	ARoll_ChkDel
		btst	#0,obRender(a0)
		beq.w	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.w	ARoll_ChkRoll
; ===========================================================================

ARoll_MainY:
		tst.w	(v_debuguse).w
		bne.w	ARoll_ChkDel
		move.w	obY(a0),d1
		lea		obARoll_Flag(a0),a2			; a2 = obARoll_Flag
		lea		(v_player).w,a1
		tst.b	(a2)						; is obARoll_Flag set?
		bne.s	ARoll_MainY_Alt				; if yes, branch
		cmp.w	obY(a1),d1
		bhi.w	ARoll_ChkDel
		move.b	#1,(a2)						; set obARoll_Flag
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blo.w	ARoll_ChkDel
		cmp.w	d3,d4
		bhs.w	ARoll_ChkDel
		btst	#0,obRender(a0)
		bne.w	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.w	ARoll_ChkRoll
; ===========================================================================

ARoll_MainY_Alt:
		cmp.w	obY(a1),d1
		bls.w	ARoll_ChkDel
		clr.b	(a2)						; clear obARoll_Flag
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	obARoll_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blo.w	ARoll_ChkDel
		cmp.w	d3,d4
		bhs.w	ARoll_ChkDel
		btst	#0,obRender(a0)
		beq.w	ARoll_Disable
		move.b	#1,obAutoRollFlag(a1)		; enable auto roll mode
		bra.w	ARoll_ChkRoll
; ===========================================================================