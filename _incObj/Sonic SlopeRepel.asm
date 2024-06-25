; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeRepel:
		nop	
		tst.b	obOnWheel(a0)
		bne.s	.return
		tst.w	obLRLock(a0)
		bne.s	.locked
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	.return
		move.w	obInertia(a0),d0
		bpl.s	.noflip
		neg.w	d0

.noflip:
		cmpi.w	#$280,d0
		bhs.s	.return
		clr.w	obInertia(a0)
		bset	#staAir,obStatus(a0)
		move.w	#$1E,obLRLock(a0)

.return:
		rts	
; ===========================================================================

.locked:
		subq.w	#1,obLRLock(a0)
		rts	
; End of function Sonic_SlopeRepel