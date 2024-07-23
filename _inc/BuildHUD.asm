; ---------------------------------------------------------------------------
; Subroutine to draw the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_17178:
BuildHUD:
		moveq	#0,d1
		tst.w	(v_rings).w
		beq.s	.norings					; blink ring counter if 0
		cmpi.b	#id_Special,(v_gamemode).w	; is this the Special Stage?
		beq.s	.goahead					; if yes, branch ahead
		btst	#3,(v_framebyte).w
		bne.s	.skip						; only blink on certain frames
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		bne.s	.skip						; if not, branch
		addq.w	#2,d1						; set mapping frame time counter blink

.skip:
		bra.s	.goahead

.norings:
		moveq	#0,d1
		btst	#3,(v_framebyte).w
		bne.s	.skip						; only blink on certain frames
		addq.w	#1,d1						; set mapping frame for ring count blink
		
		cmpi.b	#9,(v_timemin).w			; have 9 minutes elapsed?
		bne.s	.skip						; if not, branch
		addq.w	#2,d1						; set mapping frame for double blink

.goahead:

	if HUDScrolling=1
		moveq	#0,d3
		move.b	(v_hudscrollpos).w,d3		; set X pos. Will scroll to $90.
	else
		move.w	#128+16,d3					; set X pos
	endif

		move.w	#128+136,d2					; set Y pos
		lea		(Map_HUD).l,a1
		movea.w	#make_art_tile(ArtTile_HUD,0,0),a3	; set art tile and flags
	
	if HUDInSpecialStage=1	; Mercury HUD in Special Stage
		cmpi.b	#2,(f_levelstarted).w		; are we building the Sp. Stage HUD?
		bne.s	.notSS						; if not, branch ahead
		lea		(Map_HUD_SS).l,a1
		movea.w	#ArtTile_SS_HUD,a3			; set art tile and flags

.notSS:
	endif	; HUD in Special Stage End

		add.w	d1,d1
		adda.w	(a1,d1.w),a1				; load frame
		move.b	(a1)+,d1					; load # of pieces in frame
		subq.w	#1,d1
		bmi.s	.end
		bsr.w	BuildSpr_Normal				; draw frame
.end:
		rts
; End of function BuildHUD

