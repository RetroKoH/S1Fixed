; ---------------------------------------------------------------------------
; Subroutine to display Sonic and set music
; ---------------------------------------------------------------------------

Sonic_Display:
	; Check for 8th frame 
		move.b	(v_framebyte).w,d1	; RetroKoH Sonic_Display Optimization
		andi.b	#7,d1				; if d1 == 0, we will decrement shoes/invinc on this frame

	; Check hurt frames
		move.b	obInvuln(a0),d0		; RetroKoH Sonic SST Compaction
		beq.s	.display
		subq.b	#1,obInvuln(a0)		; RetroKoH Sonic SST Compaction
		lsr.w	#3,d0
		bcc.s	.chkinvincible

.display:
		jsr		(DisplaySprite).l

.chkinvincible:
		btst	#sta2ndInvinc,obStatus2nd(a0)	; does Sonic have invincibility?
		beq.s	.chkshoes						; if not, branch
	if SuperMod=1
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic Super?
		bne.s	.chkshoes						; if yes, don't check to remove invincibility
	endif
		tst.b	obInvinc(a0)					; check	time remaining for invinciblity -- RetroKoH Sonic SST Compaction
		beq.s	.chkremoveinvinc				; if we have the powerup but no time remains, remove the powerup (RetroKoH Bugfix)
		
	; RetroKoH Sonic SST Compaction
		tst.b	d1
		bne.s	.chkshoes						; if it's not the 8th frame, branch
		subq.b	#1,obInvinc(a0)					; subtract 1 from time every 8 frames (only if d1 == 0)
	; End
		
		bne.s	.chkshoes						; if time still remains, branch

.chkremoveinvinc:
		tst.b	(f_lockscreen).w
		bne.s	.removeinvincible
		cmpi.b	#$C,(v_air).w
		blo.s	.removeinvincible
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w		; check if level is SBZ3
		bne.s	.music
		moveq	#5,d0							; play SBZ music

.music:
		lea		(MusicList2).l,a1
		move.b	(a1,d0.w),d0
		jsr		(PlaySound).w					; play normal music

.removeinvincible:
		bclr	#sta2ndInvinc,obStatus2nd(a0)	; cancel invincibility

.chkshoes:
		btst	#sta2ndShoes,obStatus2nd(a0)	; does Sonic have speed	shoes?
		beq.s	.exit							; if not, branch
		tst.b	obShoes(a0)						; check	time remaining for speed shoes -- RetroKoH Sonic SST Compaction
		beq.s	.exit							; if we have the powerup but no time remains, remove the powerup (RetroKoH Bugfix)
		
	; RetroKoH Sonic SST Compaction
		tst.b	d1
		bne.s	.exit							; if it's not the 8th frame, branch
		subq.b	#1,obShoes(a0)					; subtract 1 from time every 8 frames (only if d1 == 0)
	; End
		
		bne.s	.exit							; if time still remains, branch

.removeshoes:
		lea     (v_sonspeedmax).w,a2			; Load Sonic_top_speed into a2
		bsr.w   ApplySpeedSettings				; Fetch Speed settings
		bclr	#sta2ndShoes,obStatus2nd(a0)	; cancel speed shoes
		move.w	#bgm_Slowdown,d0
		jmp		(PlaySound).w					; run music at normal speed

.exit:
		rts	