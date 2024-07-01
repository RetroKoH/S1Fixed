; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to curl up in the air
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_ChkAirRoll:
	if SpinDashEnabled=1
		tst.b	obSpinDashFlag(a0)		; is Sonic charging his spin dash?
		bne.w	.end					; if yes, branch
	endif
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0				; are buttons A, B, or C being pressed?
		beq.s	.noAirRoll				; if not, branch
		
; Air Roll
		move.b	#aniID_Roll,obAnim(a0)	; enter rolling animation
		bset	#staSpin,obStatus(a0)	; set spin status
	if ShieldsMode>0
		move.b	#2,obDoubleJumpFlag(a0)	; disable shield abilities
	endif
		move.w	#sfx_Roll,d0
		jsr		(PlaySound_Special).l	; play rolling sound

.noAirRoll:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	.end
		move.w	#-$FC0,obVelY(a0)

.end:
		rts	
; End of function Sonic_ChkAirRoll
; ===========================================================================
