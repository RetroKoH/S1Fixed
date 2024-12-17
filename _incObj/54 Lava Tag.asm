; ---------------------------------------------------------------------------
; Object 54 - invisible	lava tag (MZ)
; ---------------------------------------------------------------------------

; ===========================================================================
LTag_ColTypes:	dc.b (colHarmful|colSz_32x32), (colHarmful|colSz_64x32), (colHarmful|$15)
		even
; ===========================================================================

LavaTag:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	LTag_ChkDel
	; Object Routine Optimization End

LTag_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	LTag_ColTypes(pc,d0.w),obColType(a0)
		move.l	#Map_LTag,obMap(a0)
		move.b	#$84,obRender(a0)

		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield

LTag_ChkDel:	; Routine 2
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		; Removed first DeleteObject conditional branch
		cmpi.w	#$280,d0
		bls.s	LTag_NoDel
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.w	DeleteObject		; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject		; and delete object

LTag_NoDel:
		jmp  	Add_SpriteToCollisionResponseList	; S3K TouchResponse