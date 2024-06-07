; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectFall:
	; RHS Optimized Object Movement
		move.w	obVelX(a0),d0	; load horizontal speed
		ext.l	d0
		asl.l	#8,d0			; multiply by $100
		add.l	d0,obX(a0)		; add to x-axis	position
		move.w	obVelY(a0),d0	; load vertical	speed
		addi.w	#$38,obVelY(a0)	; apply gravity (increasing speed)
		ext.l	d0
		asl.l	#8,d0			; multiply by $100
		add.l	d0,obY(a0)		; add to y-axis	position
		rts	

; End of function ObjectFall