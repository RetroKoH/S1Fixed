; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Water:
		cmpi.b	#id_LZ,(v_zone).w	; is level LZ?
		beq.s	.islabyrinth		; if yes, branch

.exit:
		rts	
; ===========================================================================

.islabyrinth:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0							; is Sonic above the water?
		bge.s	.abovewater							; if yes, branch
		bset	#staWater,obStatus(a0)
		bne.s	.exit
		bsr.w	ResumeMusic
		move.b	#id_DrownCount,(v_sonicbubbles).w	; load bubbles object from Sonic's mouth
		move.b	#$81,(v_sonicbubbles+obSubtype).w
		lea     (v_sonspeedmax).w,a2				; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings					; Fetch Speed settings
		asr		obVelX(a0)
		asr		obVelY(a0)
		asr		obVelY(a0)							; slow Sonic
		beq.s	.exit								; branch if Sonic stops moving
		move.b	#id_Splash,(v_splash).w				; load splash object
		move.w	#sfx_Splash,d0
		jmp		(PlaySound_Special).l				; play splash sound
; ===========================================================================

.abovewater:
		bclr	#staWater,obStatus(a0)
		beq.s	.exit
		bsr.w	ResumeMusic
		lea     (v_sonspeedmax).w,a2				; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings					; Fetch Speed settings
		asl		obVelY(a0)
		beq.w	.exit
		move.b	#id_Splash,(v_splash).w				; load splash object
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	.belowmaxspeed
		move.w	#-$1000,obVelY(a0)					; set maximum speed on leaving water

.belowmaxspeed:
		move.w	#sfx_Splash,d0
		jmp		(PlaySound_Special).l				; play splash sound
; End of function Sonic_Water