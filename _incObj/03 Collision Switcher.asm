; ----------------------------------------------------------------------------
; Object 03 - Collision plane/layer switcher
; Backported from Sonic 2's object for Sonic 1: Two-Eight; rewritten by RetroKoH
; ----------------------------------------------------------------------------
; OST constants
obPSwap_Radius:			equ objoff_30		; 2 bytes | width/height of the tag
obPSwap_Flag:			equ objoff_32		; 1 byte  | flag utilized during handling
; ----------------------------------------------------------------------------

PathSwapper:
		move.l	#Map_PathSwapper,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ring,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	PSwapper_Init_CheckX

;PSwapper_Init_CheckY:
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	PathSwap_Sizes(pc,d0.w),obPSwap_Radius(a0)
		obj_addr	#PSwapper_MainY
		move.w	obY(a0),d1
		lea		(v_player).w,a1
		cmp.w	obY(a1),d1
		bhs.w	PSwapper_MainY
		move.b	#1,obPSwap_Flag(a0)
		bra.w	PSwapper_MainY
; ===========================================================================

PathSwap_Sizes:
		dc.w   $20
		dc.w   $40	; 1
		dc.w   $80	; 2
		dc.w  $100	; 3
; ===========================================================================

PSwapper_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	PathSwap_Sizes(pc,d0.w),obPSwap_Radius(a0)
		obj_addr	#PSwapper_MainX
		move.w	obX(a0),d1
		lea		(v_player).w,a1
		cmp.w	obX(a1),d1
		bhs.s	PSwapper_MainX
		move.b	#1,obPSwap_Flag(a0)
		bra.s	PSwapper_MainX
; ===========================================================================

PSwapper_Handle:
		btst	#renXFlip,obRender(a0)		; is the object flipped horizontally?
		bne.s	.jump2						; if yes, branch
		move.w	#$0C0D,(v_top_solid_bit).w	; MJ: set collision to 1st
		btst	d5,d0
		beq.s	.jump2
		move.w	#$0E0F,(v_top_solid_bit).w	; MJ: set collision to 2nd

	.jump2:
		andi.w	#maskDrawing,obGfx(a1)
		btst	d6,d0
		beq.s	.jump3
		ori.w	#maskHighPriority,obGfx(a1)

	.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.w	PSwapper_ChkDel
		move.b	#sfx_Lamppost,d0
		jmp		(QueueSound2).w
	endif
; ----------------------------------------------------------------------------

PSwapper_ChkDel:
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

PSwapper_MainX:
		tst.w	(v_debuguse).w
		bne.s	PSwapper_ChkDel
		moveq	#3,d5
		moveq	#5,d6
		move.w	obX(a0),d1
		lea		obPSwap_Flag(a0),a2			; a2 = obPSwap_Flag
		lea		(v_player).w,a1
		tst.b	(a2)						; is obPSwap_Flag set?
		bne.w	PSwapper_MainX_Alt

		cmp.w	obX(a1),d1
		bhi.s	PSwapper_ChkDel
		move.b	#1,(a2)						; set obPSwap_Flag
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	obPSwap_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.s	PSwapper_ChkDel
		cmp.w	d3,d4
		bge.s	PSwapper_ChkDel
		move.b	obSubtype(a0),d0
		bpl.w	PSwapper_Handle
		btst	#staAir,obStatus(a1)
		bne.w	PSwapper_ChkDel
		bra.w	PSwapper_Handle
; ===========================================================================
; loc_1FE38:
PSwapper_MainX_Alt:
		moveq	#4,d5
		moveq	#6,d6

		cmp.w	obX(a1),d1
		bls.w	PSwapper_ChkDel
		clr.b	(a2)						; clear obPSwap_Flag
		move.w	obY(a0),d2
		move.w	d2,d3
		move.w	obPSwap_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obY(a1),d4
		cmp.w	d2,d4
		blt.w	PSwapper_ChkDel
		cmp.w	d3,d4
		bge.w	PSwapper_ChkDel
		move.b	obSubtype(a0),d0
		bpl.w	PSwapper_Handle
		btst	#staAir,obStatus(a1)
		bne.w	PSwapper_ChkDel
		bra.w	PSwapper_Handle
; ===========================================================================

PSwapper_MainY:
		tst.w	(v_debuguse).w
		bne.w	PSwapper_ChkDel
		moveq	#3,d5
		moveq	#5,d6
		move.w	obY(a0),d1
		lea		obPSwap_Flag(a0),a2			; a2 = obPSwap_Flag
		lea		(v_player).w,a1
		tst.b	(a2)						; is obPSwap_Flag set?
		bne.s	PSwapper_MainY_Alt

		cmp.w	obY(a1),d1
		bhi.w	PSwapper_ChkDel
		move.b	#1,(a2)						; set obPSwap_Flag
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	obPSwap_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.w	PSwapper_ChkDel
		cmp.w	d3,d4
		bge.w	PSwapper_ChkDel
		move.b	obSubtype(a0),d0
		bpl.w	PSwapper_Handle
		btst	#staAir,obStatus(a1)
		bne.w	PSwapper_ChkDel
		bra.w	PSwapper_Handle
; ===========================================================================

PSwapper_MainY_Alt:
		moveq	#4,d5
		moveq	#6,d6

		cmp.w	obY(a1),d1
		bls.w	PSwapper_ChkDel
		clr.b	(a2)						; clear obPSwap_Flag
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	obPSwap_Radius(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.w	PSwapper_ChkDel
		cmp.w	d3,d4
		bge.w	PSwapper_ChkDel
		move.b	obSubtype(a0),d0
		bpl.w	PSwapper_Handle
		btst	#staAir,obStatus(a1)
		bne.w	PSwapper_ChkDel
		bra.w	PSwapper_Handle
; ===========================================================================