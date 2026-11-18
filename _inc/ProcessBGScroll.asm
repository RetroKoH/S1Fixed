; Background Scroll Deformation - ported from S3&K by Stardust Gear
; Input:	a4 - block size specification
;			a5 - block position buffer
; Block Size Format: Each word is Size, if bit 15 set - then force 1px scroll

ProcessBGScroll:
		move.w	#224-1,d1	; draw 224 screen lines

ProcessBGScroll_ParamSize:	; for custom screen heights
		move.w	(v_screenposx).w,d3

ProcessBGScroll_CustomFG:
; d1 = number of screen lines minus 1
; d3 = foreground camera X position
; a4 = band size table
; a5 = band position buffer
		lea		(v_hscrolltablebuffer).w,a1
		move.w	(v_bgscrposy_vdp).w,d0

	.skipLoop:
		move.w	(a4)+,d2	; load next block-size
		smi	d4				; bit 15 set = pixelwise scroll
		bpl.s	.positive
		andi.w	#$7FFF,d2	; when negative, wrap position

	.positive:
		sub.w	d2,d0		; y-pos -= block-size
		bmi.s	.deform	; if negative, it means block should be drawn
		addq.w	#2,a5		; skip block entry
		tst.b	d4			; is it pixelwise scroll?
		beq.s	.skipLoop
		subq.w	#2,a5
		add.w	d2,d2		; ptrBuffer += blockSize*2
		adda.w	d2,a5
		bra.s	.skipLoop
; ---------------------------------------------------------------------------

	.deform:
		tst.b	d4
		beq.s	.blockwise
		add.w	d0,d2	; block-size = y-position
		add.w	d2,d2
		adda.w	d2,a5	; ptrBuffer += blockSize * 2

	.blockwise:
		neg.w	d0		; 
		move.w	d1,d2	; load y-size - y-position
		sub.w	d0,d2
		bcc.s	.notOverflow
		move.w	d1,d0	; y-position = y-size + 1
		addq.w	#1,d0

	.notOverflow:
		neg.w	d3		; h-scroll is negative
		swap	d3

	.entireBlock:
		subq.w	#1,d0

	.processBlock:
		tst.b	d4		; is it end mark?
		beq.s	.doBlockLoop
		lsr.w	#1,d0
		bcc.s	.pixelLoop_Unroll

	.pixelLoop:
		move.w	(a5)+,d3	; load position
		neg.w	d3			; hscroll is negative...
		move.l	d3,(a1)+	; save to hscroll buffer

	.pixelLoop_Unroll:
		move.w	(a5)+,d3	; 2x loop unrolling
		neg.w	d3
		move.l	d3,(a1)+
		dbf	d0,	.pixelLoop
		bra.s	.finally
; ---------------------------------------------------------------------------

	.doBlockLoop:
		move.w	(a5)+,d3	; set buffer-pos to x-position
		neg.w	d3			; hscroll is negative
		lsr.w	#1,d0
		bcc.s	.blockLoop_Unroll

	.blockLoop:
		move.l	d3,(a1)+	; copy n pixels for block

	.blockLoop_Unroll:
		move.l	d3,(a1)+
		dbf	d0,	.blockLoop

	.finally:
		tst.w	d2			; has y reached end?
		bmi.s	.return
		move.w	(a4)+,d0	; load next block size
		smi	d4				; pixelwise scroll marker
		bpl.s	.isBlock
		andi.w	#$7FFF,d0

	.isBlock:
		move.w	d2,d3
		sub.w	d0,d2		; subtract block size from y position
		bpl.s	.entireBlock
		move.w	d3,d0
		bra.s	.processBlock
; ---------------------------------------------------------------------------

	.return:
		rts
; End of function ProcessBGScroll