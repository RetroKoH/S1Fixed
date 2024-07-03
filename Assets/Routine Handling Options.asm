; ---------------------------------------------------------------------------
; Object 3B - purple rock (GHZ)
; ---------------------------------------------------------------------------

PurpleRock:
	; Original S1 Method
;		moveq	#0,d0						; 4 cycles
;		move.b	obRoutine(a0),d0			; $C cycles
;		move.w	Rock_Index(pc,d0.w),d1		; $E cycles
;		jmp		Rock_Index(pc,d1.w)			; $E cycles = $2C cycles
; ===========================================================================
;Rock_Index:
;		dc.w Rock_Main-Rock_Index
;		dc.w Rock_Solid-Rock_Index
; ===========================================================================


	; Original S3K Method
		; moveq	#0,d0						; 4 cycles
		; move.b	obRoutine(a0),d0			; $C cycles
		; jmp		Rock_Index(pc,d0.w)			; $E cycles
; ; =========================================================================
; Rock_Index:
		; bra.s	Rock_Main					; $A cycles = $28 cycles
		; bra.s	Rock_Solid					; $A cycles = $28 cycles
; ===========================================================================


	; LavaGaming Method
;		tst.b	obRoutine(a0)		; $C cycles
;		bne.s	Rock_Solid			; $A cycles = $16 cycles
; ===========================================================================

Rock_Main:	; Routine 0
		rts

Rock_Solid:	; Routine 2
		rts
