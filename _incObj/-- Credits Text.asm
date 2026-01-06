; ---------------------------------------------------------------------------
; Object - "SONIC TEAM PRESENTS" and credits
; ---------------------------------------------------------------------------

CreditsText:
		_move.l	#DisplaySprite,obAddr(a0)
		move.w	#$120,obX(a0)
		move.w	#$F0,obScreenY(a0)
		move.l	#Map_Cred,obMap(a0)
		move.w	#make_art_tile(ArtTile_Credits_Font,0,0),obGfx(a0)
		move.w	(v_creditsnum).w,d0					; load credits index number
		move.b	d0,obFrame(a0)						; display appropriate sprite
		clr.b	obRender(a0)
		move.w	#priority0,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager

		cmpi.b	#id_Title,(v_gamemode).w			; is the mode #4 (title screen)?
		bne.s	.display							; if not, branch

		move.w	#make_art_tile(ArtTile_Sonic_Team_Font,0,0),obGfx(a0)
		move.b	#$A,obFrame(a0)						; display "SONIC TEAM PRESENTS"
		tst.b	(f_creditscheat).w					; is hidden credits cheat on?
		beq.s	.display							; if not, branch
		cmpi.b	#btnABC+btnDn,(v_jpadheld_actual).w		; is A+B+C+Down being pressed? ($72)
		bne.s	.display							; if not, branch
		move.w	#cWhite,(v_palette_fading+$40).w	; 3rd palette, 1st entry = white
		move.w	#$880,(v_palette_fading+$42).w		; 3rd palette, 2nd entry = cyan
		jmp		(DeleteObject).l
; ===========================================================================

	.display:
		jmp		(DisplaySprite).l
; ===========================================================================