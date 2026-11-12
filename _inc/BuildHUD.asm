; ---------------------------------------------------------------------------
; Subroutine to draw the HUD
; Blinking function refactored by RetroKoH
; ---------------------------------------------------------------------------

BuildHUD:
		moveq	#0,d4
		tst.w	(v_rings).w
		bne.s	.chktime					; if Sonic has rings, branch
		btst	#3,(v_framebyte).w
		bne.s	.chktime					; only blink on certain frames
		addq.w	#1,d4						; set mapping frame for ring count blink

	.chktime:
	if TimeLimitInSpecialStage
		cmpi.b	#id_Special,(v_gamemode).w	; is this the Special Stage?
		bne.s	.countup					; if no, behave like normal

	; blink at under 30 seconds
		cmpi.l	#$1E00,(v_time).w			; under 30 seconds remaining?
		bcc.s	.goahead
		btst	#3,(v_framebyte).w
		bne.s	.goahead					; only blink on certain frames
		addq.w	#2,d4						; set mapping frame time counter blink
		bra.s	.goahead

	.countup:
	endif
	; Blink at 9 minutes
		btst	#3,(v_framebyte).w
		bne.s	.goahead					; only blink on certain frames
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		bne.s	.goahead					; if not, branch
		addq.w	#2,d4						; set mapping frame time counter blink (double if ring blink was set)

	.goahead:
	if HUDScrolling
		moveq	#0,d0
		move.b	(v_hudscrollpos).w,d0		; set X pos. Will scroll to $90.
	else
		move.w	#128+16,d0					; set X pos
	endif

		move.w	#128+136,d1					; set Y pos
		lea		(Map_HUD).l,a1
		move.w	#make_art_tile(ArtTile_HUD,0,0),d5	; set art tile and flags
	
	if HUDInSpecialStage	; Mercury HUD in Special Stage
		cmpi.b	#2,(f_levelstarted).w		; are we building the Sp. Stage HUD?
		bne.s	.notSS						; if not, branch ahead
		lea		(Map_HUD_SS).l,a1
		move.w	#ArtTile_SS_HUD,d5				; set art tile and flags

	.notSS:
	endif	; HUD in Special Stage End

		add.w	d4,d4
		adda.w	(a1,d4.w),a1				; load frame
		move.w	(a1)+,d4					; load # of pieces in frame ; S3K BuildSprites .b > .w
		subq.w	#1,d4						; S3K BuildSprites .b > .w
		bmi.s	.end
		bra.w	BuildSpr_Normal				; draw frame

	.end:
		rts
; End of function BuildHUD
; ===========================================================================