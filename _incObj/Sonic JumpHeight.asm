; ---------------------------------------------------------------------------
; Subroutine controlling Sonic's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpHeight:
		tst.b	obJumping(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#staWater,obStatus(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	obVelY(a0),d1
		ble.s	Sonic_DoubleJump
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0			; is A, B or C pressed?
		bne.s	locret_134C2		; if yes, branch
		move.w	d1,obVelY(a0)

locret_134C2:
		rts	
; ===========================================================================

loc_134C4:
	if SpinDashEnabled=1
		tst.b	obSpinDashFlag(a0)	; is Sonic charging his spin dash?
		bne.w	locret_134D2		; if yes, branch
	endif
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,obVelY(a0)

locret_134D2:
		rts	
; End of function Sonic_JumpHeight
; ===========================================================================

; Files for Double Jump Techniques
		
	if S3KDoubleJump=0
		include "_incObj/Sonic DoubleJump - NoShield.asm"	; Use if there are NO elemental shields or instashield
	else
		include "_incObj/Sonic DoubleJump - Shields.asm"	; Use when in S3K mode (Shields and Insta)
	endif

	if DropDashEnabled
		include "_incObj/Sonic DropDash.asm"
	endif
	
	if SuperMod
		include "_incObj/Sonic TurnSuper.asm"
	endif

; Added for S3K Shields and Drop Dash
Reset_Sonic_Position_Array:
		lea		(v_tracksonic).w,a1
		move.w	#$3F,d0

loc_10DEC:
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		dbf		d0,loc_10DEC
		clr.w	(v_trackpos).w
		rts
; End of function Reset_Sonic_Position_Array
