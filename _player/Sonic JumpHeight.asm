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
	if SpinDashEnabled
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
		
	if S3KDoubleJump
		include "_player/Sonic DoubleJump - Shields.asm"	; Use if elemental shields and/or the Instashield are enabled
	else
		include "_player/Sonic DoubleJump - NoShield.asm"	; Use if elemental shields or the Instashield are disabled
	endif

	if DropDashEnabled
		include "_player/Sonic DropDash.asm"
	endif
	
	if SuperMod
		include "_player/Sonic TurnSuper.asm"
	endif

	if (ShieldsMode|DropDashEnabled)
; Added for S3K Shields and Drop Dash
Reset_Sonic_Position_Array:
		move.w	obX(a0),d1
		swap	d1						; move obX to the upper word -- RetroKoH optimization
		move.w	obY(a0),d1				; move obY to the lower word -- RetroKoH optimization
		lea		(v_tracksonic).w,a1
		move.w	#$3F,d0

loc_10DEC:
		move.l	d1,(a1)+				; move obX and obY to v_tracksonic -- RetroKoH optimization
		dbf		d0,loc_10DEC
		clr.w	(v_trackpos).w
		rts
; End of function Reset_Sonic_Position_Array
	endif
