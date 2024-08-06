; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Super:				; XREF: Obj01_MdNormal
		btst	#sta2ndSuper,obStatus2nd(a0)
		beq.s	.return						; Ignore all this code if not Super Sonic
		tst.b	(f_timecount).w
		beq.s	Sonic_RevertToNormal		; If time is stopped, revert to normal
		subq.b	#1,(v_supersonic_frame).w
		bhi.s	.return						; Changed from bpl to bhi to ensure once every 60 frames, not 61 (MoDule)

	; Only run the below code once every second.
		move.b	#60,(v_supersonic_frame).w	; Reset frame counter to 60
		tst.w	(v_rings).w
		beq.s	Sonic_RevertToNormal		; if no rings, revert to normal
		ori.b	#1,(f_ringcount).w
		cmpi.w	#1,(v_rings).w
		beq.s	.onering
		cmpi.w	#10,(v_rings).w
		beq.s	.onering
		cmpi.w	#100,(v_rings).w
		bne.s	.subtractring

.onering:
		ori.b	#$80,(f_ringcount).w

.subtractring:
		subq.w	#1,(v_rings).w
		beq.s	Sonic_RevertToNormal

.return:
		rts

Sonic_RevertToNormal:
		move.b	#2,(f_super_palette).w		; Remove rotating palette
		move.w	#$28,(v_palette_frame).w
		bclr	#sta2ndSuper,obStatus2nd(a0)
		move.b	#aniID_Run,obPrevAni(a0)	; Change animation back to normal
		clr.b	obInvinc(a0)				; Remove invincibility
		lea     (v_sonspeedmax).w,a2    	; Load Sonic_top_speed into a2
		bra.w   ApplySpeedSettings			; Fetch Speed settings