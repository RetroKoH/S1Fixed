; ---------------------------------------------------------------------------
; Object 68 - conveyor belts (SBZ)
; Optimizations based on S1Squared and Sonic Clean Engine
;
; subtypes:
;	%SSSS000W
;	SSSS - speed/direction (0-7 = positive/right; 8-$F = negative/left)
;	000W - width (see Conv_Widths; Only supports 2; but this can be expanded)
; ---------------------------------------------------------------------------
; OST Constants
obConv_Speed:			equ objoff_30		; 2 bytes | speed - can also be negative
; ---------------------------------------------------------------------------

; ===========================================================================

Conv_Widths:
		dc.b 128, 56
; ===========================================================================

Conveyor:
		_move.l	#Conv_Action,obAddr(a0)

		moveq	#0,d0
		move.b	obSubtype(a0),d0		; get object subtype
		moveq	#1,d1
		and.b	d0,d1					; read only the low nybble
		move.b	Conv_Widths(pc,d1.w),obWidth(a0)	; set width from list

		andi.b	#$F0,d0					; read only the	upper nybble
		ext.w	d0
		asr.w	#4,d0					; divide by $10
		move.w	d0,obConv_Speed(a0)		; set belt speed
; ---------------------------------------------------------------------------

Conv_Action:	; Routine 2
		tst.b	(v_debuguse).w			; is debug mode in use?
		bne.s	.chkdel					; if yes, branch

		moveq	#0,d2
		move.b	obWidth(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bhs.s	.chkdel					; branch if Sonic is outside x range
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		addi.w	#$30,d1
		cmpi.w	#$30,d1
		bhs.s	.chkdel					; branch if not in range on y axis
		btst	#staAir,obStatus(a1)
		bne.s	.chkdel
		move.w	obConv_Speed(a0),d0
		add.w	d0,obX(a1)				; apply conveyor speed/direction to Sonic

;DespawnQuick_NoDisplay
	.chkdel:
		offscreen.s	.delete				; PFM S3K OBJ
		rts	
; ===========================================================================

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================