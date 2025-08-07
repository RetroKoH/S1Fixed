
	if DynamicCollision

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:
	; This first part can be optimized, surely
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#5,d0
		move.b	(v_act).w,d1
		add.b	d1,d1
		add.b	d1,d1
		add.b	d1,d0
		move.l	#v_collision1&$FFFFFF,(v_collindex).w
		move.w	d0,-(sp)
		movea.l	ColPointers(pc,d0.w),a0		; MJ: get first collision set
		lea		(v_collision1).w,a1
		bsr.w	KosDec
		move.w	(sp)+,d0
		movea.l	ColPointers+4(pc,d0.w),a0	; MJ: get second collision set
		lea		(v_collision2).w,a1
		bra.w	KosDec
; End of function ColIndexLoad
; ===========================================================================

; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:
		dc.l Col_GHZ1_1		; MJ: each act now has two entries (8 per zone)
		dc.l Col_GHZ1_2
		dc.l Col_GHZ2_1
		dc.l Col_GHZ2_2
		dc.l Col_GHZ3_1
		dc.l Col_GHZ3_2
		dc.l Col_GHZ1_1
		dc.l Col_GHZ1_2
		dc.l Col_LZ1_1
		dc.l Col_LZ1_2
		dc.l Col_LZ2_1
		dc.l Col_LZ2_2
		dc.l Col_LZ3_1
		dc.l Col_LZ3_2
		dc.l Col_SBZ3_1		; Technically LZ4
		dc.l Col_SBZ3_2
		dc.l Col_MZ1_1
		dc.l Col_MZ1_2
		dc.l Col_MZ2_1
		dc.l Col_MZ2_2
		dc.l Col_MZ3_1
		dc.l Col_MZ3_2
		dc.l Col_MZ1_1
		dc.l Col_MZ1_2
		dc.l Col_SLZ1_1
		dc.l Col_SLZ1_2
		dc.l Col_SLZ2_1
		dc.l Col_SLZ2_2
		dc.l Col_SLZ3_1
		dc.l Col_SLZ3_2
		dc.l Col_SLZ1_1
		dc.l Col_SLZ1_2
		dc.l Col_SYZ1_1
		dc.l Col_SYZ1_2
		dc.l Col_SYZ2_1
		dc.l Col_SYZ2_2
		dc.l Col_SYZ3_1
		dc.l Col_SYZ3_2
		dc.l Col_SYZ1_1
		dc.l Col_SYZ1_2
		dc.l Col_SBZ1_1
		dc.l Col_SBZ1_2
		dc.l Col_SBZ2_1
		dc.l Col_SBZ2_2
		dc.l Col_FZ_1		; Technically SBZ3
		dc.l Col_FZ_2
		dc.l Col_SBZ1_1
		dc.l Col_SBZ1_2
		zonewarning ColPointers,$20
;		dc.l Col_GHZ_1 ; Pointers for Ending are missing by default.
;		dc.l Col_GHZ_2
; ===========================================================================

	else

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lsl.w	#3,d0				; MJ: multiply by 8 not 4
		move.l	#v_collision1&$FFFFFF,(v_collindex).w
		move.w	d0,-(sp)
		movea.l	ColPointers(pc,d0.w),a0		; MJ: get first collision set
		lea	(v_collision1).w,a1
		bsr.w	KosDec
		move.w	(sp)+,d0
		movea.l	ColPointers+4(pc,d0.w),a0	; MJ: get second collision set
		lea	(v_collision2).w,a1
		bra.w	KosDec
; End of function ColIndexLoad
; ===========================================================================

; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:
		dc.l Col_GHZ_1	; MJ: each zone now has two entries
		dc.l Col_GHZ_2
		dc.l Col_LZ_1
		dc.l Col_LZ_2
		dc.l Col_MZ_1
		dc.l Col_MZ_2
		dc.l Col_SLZ_1
		dc.l Col_SLZ_2
		dc.l Col_SYZ_1
		dc.l Col_SYZ_2
		dc.l Col_SBZ_1
		dc.l Col_SBZ_2
		zonewarning ColPointers,8
;		dc.l Col_GHZ_1 ; Pointers for Ending are missing by default.
;		dc.l Col_GHZ_2
; ===========================================================================

	endif