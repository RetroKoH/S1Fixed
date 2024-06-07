; ---------------------------------------------------------------------------
; Sonic	graphics loading subroutine (Mercury Use DMA Queue)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		cmp.b	(v_sonframenum).w,d0	; has frame changed?
		beq.s	.nochange				; if not, branch

		move.b	d0,(v_sonframenum).w
		lea		(SonicDynPLC).l,a2		; load PLC script
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5				; read "number of entries" value
		subq.w	#1,d5
		bmi.s	.nochange				; if zero, branch
		move.w	#$F000,d4
		move.l	#Art_Sonic,d6

.readentry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1				; clear the counter to remove # of tiles from far left nybble
		lsl.l	#5,d1					; changed to .l (more than FFFF bytes)
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,.readentry			; repeat for number of entries

.nochange:
		rts	

; End of function Sonic_LoadGfx

