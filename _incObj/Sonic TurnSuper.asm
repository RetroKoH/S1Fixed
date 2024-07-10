; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_TurnSuper: ;loc_11A16:
		move.b	#1,(f_super_palette).w
		move.b	#$F,(v_palette_timer).w
		bset	#sta2ndSuper,obStatus2nd(a0)
		move.b	#60,(v_supersonic_frame).w		; set timer
		;move.l	#Map_SuperSonic,obMap(a0)
		move.b	#$81,obLRLock(a0)
		move.b	#aniID_Transform,obAnim(a0)
		;move.b	#id_SuperSonicStars,(v_starspace).w ; load super sonic stars object
		lea		(v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		jsr		(ApplySpeedSettings).l
		clr.b	obInvinc(a0)
		bset	#sta2ndInvinc,obStatus2nd(a0)	; make Sonic invincible
		move.w	#sfx_GiantRing,d0
		jsr		(PlaySound_Special).l
		move.w	#bgm_Invincible,d0
		jmp		(PlaySound).l
; End of function Sonic_Water
; ===========================================================================