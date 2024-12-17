; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

	; flamewing Left Boundary Zip Fix
Sonic_LevelBound:
		moveq	#0,d2			; +++ clear d2 for use
		move.l	obX(a0),d1
		smi.b	d2				; +++ set d2 if player on position > 32767
		add.w	d2,d2			; +++ move bit up
		move.w	obVelX(a0),d0
		spl.b	d2				; +++ set if speed is positive
		add.w	d2,d2			; +++ move bit up
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		spl.b	d2				; +++ set if position+speed is < 32768
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		tst.w	d2				; +++ if d2 is zero, we had an underflow of position
		beq.s	.sides
		cmp.w	d1,d0			; has Sonic touched the left side boundary?
		bhi.s	.sides			; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	.screenlocked
		addi.w	#$40,d0

.screenlocked:
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.s	.sides		; if yes, branch

.chkbottom:
		move.w	(v_limitbtm2).w,d0
	; RetroKoH Bottom Boundary Fix
		cmp.w	(v_limitbtm1).w,d0	; is the intended bottom boundary lower than the current one?
		bcc.s	.notlower			; if not, branch
		move.w	(v_limitbtm1).w,d0	; d0 = intended bottom boundary
.notlower:
	; Bottom Boundary Fix End
		addi.w	#224,d0
		cmp.w	obY(a0),d0	; has Sonic touched the	bottom boundary?
		blt.s	.bottom		; if yes, branch
		rts	
; ===========================================================================

.bottom:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2 ?
		bne.s	.killsonic	; if not, kill Sonic	; MJ: Fix out-of-range branch
		cmpi.w	#$2000,(v_player+obX).w
		bcs.s	.killsonic				; MJ: Fix out-of-range branch
		clr.b	(v_lastlamp).w	; clear	lamppost counter
		move.b	#1,(f_restart).w ; restart the level
		move.w	#(id_LZ<<8)+3,(v_zone).w ; set level to SBZ3 (LZ4)
		rts	
; ===========================================================================

.sides:
		move.w	d0,obX(a0)
		clr.w	obX+2(a0)		; clear subpixel (for alignment)
		clr.w	obVelX(a0)		; stop Sonic moving
		clr.w	obInertia(a0)	; clear ground inertia
		bra.s	.chkbottom
; ===========================================================================

.killsonic:
		jmp	(KillSonic).l	; MJ: Fix out-of-range branch
; End of function Sonic_LevelBound
