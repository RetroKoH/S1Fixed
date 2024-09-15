; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectFall:
	; RHS/DeltaW Optimized Object Movement
		movem.w	obVelX(a0),d0/d2
		lsl.l	#8,d0
		add.l	d0,obX(a0)	
		addi.w	#$38,obVelY(a0)
		lsl.l	#8,d2
		add.l	d2,obY(a0)
		rts	

; End of function ObjectFall