; ---------------------------------------------------------------------------
; Subroutine for Sonic to transform in Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_TurnSuper:
		move.b	#1,(f_super_palette).w
		move.b	#$F,(v_palette_timer).w
		bset	#sta2ndSuper,obStatus2nd(a0)
		move.b	#60,(v_supersonic_frame).w		; set timer
		move.l	#Map_SuperSonic,obMap(a0)		; change mappings
		move.b	#$81,obCtrlLock(a0)
		move.b	#aniID_Transform,obAnim(a0)
		move.b	#id_SuperStars,(v_sstarsobj).w	; load super sonic stars object
		lea		(v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		jsr		(ApplySpeedSettings).l
		clr.b	obInvinc(a0)
		bset	#sta2ndInvinc,obStatus2nd(a0)	; make Sonic invincible
		move.w	#sfx_GiantRing,d0

	if AmbienceMode
		jmp		(QueueSound2).w					; play giant ring sound
	else
		jsr		(QueueSound2).w					; play giant ring sound first
		move.w	#bgm_Invincible,d0
		move.b	d0,(v_lastbgmplayed).w			; store last played music
		jmp		(QueueSound1).w					; play invincibility music
	endif

; End of function Sonic_TurnSuper
; ===========================================================================