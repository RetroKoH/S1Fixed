; ---------------------------------------------------------------------------
; Object 81 - Sonic on the continue screen
; ---------------------------------------------------------------------------

ContSonic:
		_move.l	#CSon_ChkLand,obAddr(a0)
		move.w	#$A0,obX(a0)
		move.w	#$C0,obY(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#aniID_Float3,obAnim(a0)	; use "floating" animation
		move.w	#$400,obVelY(a0)			; make Sonic fall from above
; ---------------------------------------------------------------------------

CSon_ChkLand:
		cmpi.w	#$1A0,obY(a0)				; has Sonic landed yet?
		bne.s	.keep_falling				; if not, branch

		_move.l	#CSon_Animate,obAddr(a0)
		clr.w	obVelY(a0)					; stop Sonic falling
		move.l	#Map_ContScr,obMap(a0)
		move.w	#make_art_tile(ArtTile_Continue_Sonic,0,1),obGfx(a0)
		clr.b	obAnim(a0)
		bra.s	CSon_Animate
; ===========================================================================

	.keep_falling:
		jsr		(SpeedToPos_YOnly).l
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		jmp		(DisplaySprite).l
; ===========================================================================

CSon_Animate:
		tst.b	(v_jpadpressed_actual).w	; is Start button pressed?
		bmi.s	.start_pressed				; if yes, branch
		lea		AniScript_CSon(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l

	.start_pressed:
		_move.l	#CSon_Run,obAddr(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#aniID_Float4,obAnim(a0)	; use "getting up" animation
		clr.w	obInertia(a0)
		subq.w	#8,obY(a0)
		move.b	#bgm_Fade,d0
		bsr.w	QueueSound2					; fade out music
; ---------------------------------------------------------------------------

CSon_Run:
		cmpi.w	#$800,obInertia(a0)			; check Sonic's inertia
		bne.s	.add_inertia				; if too low, branch
		move.w	#$1000,obVelX(a0)			; move Sonic to the right
		bra.s	.show_run
; ===========================================================================

	.add_inertia:
		addi.w	#$20,obInertia(a0)			; increase inertia

	.show_run:
		jsr		(SpeedToPos_XOnly).l
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		jmp		(DisplaySprite).l
; ===========================================================================