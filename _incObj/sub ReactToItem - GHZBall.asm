; ---------------------------------------------------------------------------
; Subroutine for GHZ Ball ($19) to react to obColType(a0)
; Simply an abbreviated version of ReactToItem
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GHZBall_ReactToItem:
		nop	
		move.w	obX(a0),d2				; load ball's x-axis position
		move.w	obY(a0),d3				; load ball's y-axis position
		subq.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5			; load ball's height
		subq.b	#3,d5
		sub.w	d5,d3
		move.w	#$10,d4
		add.w	d5,d5

.chkobjecttype:
		lea		(v_col_response_list).w,a4
		move.w	(a4)+,d6				; Get number of objects queued
		beq.s	.end					; If there are none, return

.loop:
		movea.w	(a4)+,a1				; Get address of first object's RAM
		move.b	obColType(a1),d0		; Get its collision_flags

		bne.s	.proximity				; If it actually has collision, branch

.next:
		subq.w	#2,d6					; Count the object as done
		bne.s	.loop					; If there are still objects left, loop

		moveq	#0,d0
.end
		rts	
; ===========================================================================

.proximity:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea		Touch_Sizes-2,a2
		lea		(a2,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obX(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	.outsidex			; branch if not touching
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	.withinx			; branch if touching
		bra.s	.next
; ===========================================================================
.outsidex:
		cmp.w	d4,d0
		bhi.s	.next

.withinx:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obY(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	.outsidey			; branch if not touching
		add.w	d1,d1
		add.w	d0,d1
		bcs.s	TouchBall_ChkValue	; branch if touching
		bra.s	.next
; ===========================================================================

.outsidey:
		cmp.w	d5,d0
		bhi.s	.next	

TouchBall_ChkValue:
		move.b	obColType(a1),d0	; load collision type
		cmpi.b	#$46,d0				; is collision type $46?
		beq.s	BallReact_Monitor	; if yes, branch
		
		andi.b	#$C0,d1				; is obColType $40 or higher?
		beq.w	BallReact_Enemy		; if not, branch
		rts
; ===========================================================================

BallReact_Monitor:
		addq.b	#2,obRoutine(a1)	; advance the monitor's routine counter
		rts	
; ===========================================================================

BallReact_Enemy:
		bset	#7,obStatus(a1)
		moveq	#0,d0
		move.w	(v_itembonus).w,d0
		addq.w	#2,(v_itembonus).w			; add 2 to item bonus counter
		cmpi.w	#6,d0
		blo.s	.bonusokay
		moveq	#6,d0						; max bonus is lvl6

.bonusokay:
		move.w	d0,objoff_3E(a1)
		move.w	.points(pc,d0.w),d0
		cmpi.w	#$20,(v_itembonus).w		; have 16 enemies been destroyed?
		blo.s	.lessthan16					; if not, branch
		move.w	#1000,d0					; fix bonus to 10000
		move.w	#$A,objoff_3E(a1)

.lessthan16:
		jsr		(AddPoints).l
		_move.b	#id_ExplosionItem,obID(a1)	; change object to explosion
		clr.b	obRoutine(a1)
		rts
; End of function GHZBall_ReactToItem
; ===========================================================================

.points:	dc.w 10, 20, 50, 100	; points awarded div 10
; ===========================================================================
