; ----------------------------------------------------------------------------
; Object 03 - Collision plane/layer switcher
; ----------------------------------------------------------------------------

PathSwapper:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	PSwapper_Index(pc,d0.w),d1
		jsr		PSwapper_Index(pc,d1.w)

	if DebugPathSwappers
		tst.w	(f_debugcheat).w
		bne.w	RememberState
	endif

		; like RememberState, but doesn't display (Sonic 2's MarkObjGone3)
		out_of_range.w	.offscreen
		rts

.offscreen:
	; ProjectFM S3K Objects Manager (RetroKoH additional change)
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	.delete				; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
	; S3K Objects Manaager End

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

PSwapper_Index:		offsetTable
		offsetTableEntry.w	PSwapper_Init	; 0
		offsetTableEntry.w	PSwapper_MainX	; 2
		offsetTableEntry.w	PSwapper_MainY	; 4
; ===========================================================================

PSwapper_Init:
		addq.b	#2,obRoutine(a0) ; => PSwapper_MainX
		move.l	#Map_PathSwapper,obMap(a0)
		move.w	#$27B2,obGfx(a0)			; change this
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		btst	#2,d0
		beq.s	PSwapper_Init_CheckX
;PSwapper_Init_CheckY:
		addq.b	#2,obRoutine(a0) ; => PSwapper_MainY
		andi.w	#7,d0
		move.b	d0,obFrame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1FD68(pc,d0.w),objoff_32(a0)
		move.w	obY(a0),d1
		lea		(v_player).w,a1 ; a1=character
		cmp.w	obY(a1),d1
		bhs.w	PSwapper_MainY
		move.b	#1,objoff_34(a0)
		bra.w	PSwapper_MainY
; ===========================================================================
word_1FD68:
		dc.w   $20
		dc.w   $40	; 1
		dc.w   $80	; 2
		dc.w  $100	; 3
; ===========================================================================

PSwapper_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,obFrame(a0)
		add.w	d0,d0
		move.w	word_1FD68(pc,d0.w),objoff_32(a0)
		move.w	obX(a0),d1
		lea		(v_player).w,a1		; a1=character
		cmp.w	obX(a1),d1
		bhs.s	PSwapper_MainX
		move.b	#1,objoff_34(a0)

PSwapper_MainX:
		tst.w	(v_debuguse).w
		bne.w	.locret
		move.w	obX(a0),d1
		lea		objoff_34(a0),a2	; a2=$34(a0)
		lea		(v_player).w,a1		; a1=character
		tst.b	(a2)+				; test $34(a0); a2=$35(a0)
		bne.w	PSwapper_MainX_Alt
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
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#staAir,obStatus(a1)
		bne.s	.locret

.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		btst	#3,d0
		beq.s	.jump2
		move.b	#$E,(v_top_solid_bit).w	; MJ: set collision to 2nd
		move.b	#$F,(v_lrb_solid_bit).w	; MJ: set collision to 2nd

.jump2:
		andi.w	#maskDrawing,obGfx(a1)
		btst	#5,d0
		beq.s	.jump3
		ori.w	#maskHighPriority,obGfx(a1)

.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp		(QueueSound2).w
	endif

.locret:
		rts
; ===========================================================================
; loc_1FE38:
PSwapper_MainX_Alt:
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
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#staAir,obStatus(a1)
		bne.s	.locret

.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		btst	#4,d0
		beq.s	.jump2
		move.b	#$E,(v_top_solid_bit).w	; MJ: set collision to 2nd
		move.b	#$F,(v_lrb_solid_bit).w	; MJ: set collision to 2nd

.jump2:
		andi.w	#maskDrawing,obGfx(a1)
		btst	#6,d0
		beq.s	.jump3
		ori.w	#maskHighPriority,obGfx(a1)

.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp		(QueueSound2).w
	endif

.locret:
		rts
; ===========================================================================

PSwapper_MainY:
		tst.w	(v_debuguse).w
		bne.w	.locret
		move.w	obY(a0),d1
		lea		objoff_34(a0),a2
		lea		(v_player).w,a1 ; a1=character
		tst.b	(a2)+
		bne.s	PSwapper_MainY_Alt
		cmp.w	obY(a1),d1
		bhi.s	.locret
		move.b	#1,-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#staAir,obStatus(a1)
		bne.s	.locret

.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		btst	#3,d0
		beq.s	.jump2
		move.b	#$E,(v_top_solid_bit).w	; MJ: set collision to 2nd
		move.b	#$F,(v_lrb_solid_bit).w	; MJ: set collision to 2nd

.jump2:
		andi.w	#maskDrawing,obGfx(a1)
		btst	#5,d0
		beq.s	.jump3
		ori.w	#maskHighPriority,obGfx(a1)

.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp		(QueueSound2).w
	endif

.locret:
		rts
; ===========================================================================

PSwapper_MainY_Alt:
		cmp.w	obY(a1),d1
		bls.s	.locret
		clr.b	-1(a2)
		move.w	obX(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	obX(a1),d4
		cmp.w	d2,d4
		blt.s	.locret
		cmp.w	d3,d4
		bge.s	.locret
		move.b	obSubtype(a0),d0
		bpl.s	.jump
		btst	#staAir,obStatus(a1)
		bne.s	.locret

.jump:
		btst	#0,obRender(a0)
		bne.s	.jump2
		move.b	#$C,(v_top_solid_bit).w	; MJ: set collision to 1st
		move.b	#$D,(v_lrb_solid_bit).w	; MJ: set collision to 1st
		btst	#4,d0
		beq.s	.jump2
		move.b	#$E,(v_top_solid_bit).w	; MJ: set collision to 2nd
		move.b	#$F,(v_lrb_solid_bit).w	; MJ: set collision to 2nd

.jump2:
		andi.w	#maskDrawing,obGfx(a1)
		btst	#6,d0
		beq.s	.jump3
		ori.w	#maskHighPriority,obGfx(a1)

.jump3:
	if DebugPathSwappers
		tst.b	(f_debugcheat).w
		beq.s	.locret
		move.b	#sfx_Lamppost,d0
		jmp		(QueueSound2).w
	endif

.locret:
		rts
