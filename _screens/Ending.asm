; ---------------------------------------------------------------------------
; Ending sequence in Green Hill	Zone
; ---------------------------------------------------------------------------

GM_Ending:
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound1		; stop music
		bsr.w	PaletteFadeOut

		clearRAM v_objspace
		clearRAM v_misc_variables
		clearRAM v_levelvariables
		clearRAM v_timingandscreenvariables

		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		lea		(vdp_control_port).l,a6
		move.w	#$8B03,(a6)	; line scroll mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8500+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		move.w	#$8004,(a6)		; 8-colour mode
		move.w	#$8720,(a6)		; set background colour (line 3; colour 0)
		move.w	#$8A00+223,(v_hbla_hreg).w ; set palette change position (for water)
		move.w	(v_hbla_hreg).w,(a6)
		move.b	#30,(v_air).w
		move.w	#id_EndZ<<8,(v_zone).w ; set level number to 0600 (extra flowers)
		cmpi.b	#emldCount,(v_emeralds).w ; do you have all emeralds?
		beq.s	End_LoadData	; if yes, branch
		move.w	#(id_EndZ<<8)+1,(v_zone).w ; set level number to 0601 (no flowers)

End_LoadData:
		jsr		(AnimateLevelGfx_Init).l
		moveq	#plcid_Ending,d0
		bsr.w	QuickPLC							; load ending sequence patterns
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_fg_scroll_flags).w
		move.w	#End_Header,(v_levelheader_id).w	; hardset Ending header
		bsr.w	LevelDataLoad						; load level art -- Clownacy Level Art Loading + load block mappings and palettes
		bsr.w	LoadTilesFromStart
		lea		(Col_End_1).l,a0					; MJ: Set first collision for ending
		lea		(v_collision1).w,a1
		bsr.w	KosDec
		lea		(Col_End_2).l,a0					; MJ: Set second collision for ending
		lea		(v_collision2).w,a1
		bsr.w	KosDec
		enable_ints
		lea		(Kos_EndFlowers).l,a0				; load extra flower patterns
		lea		((v_128x128+$1000)&$FFFFFF).l,a1	; RAM address to buffer the patterns
		bsr.w	KosDec
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad_Fade						; load Sonic's palette
		move.w	#bgm_Ending,d0
		bsr.w	QueueSound1							; play ending sequence music
		move.b	d0,(v_lastbgmplayed).w				; store last played music

End_LoadSonic:
		move.b	#id_SonicPlayer,(v_player).w		; load Sonic object
		bset	#staFacing,(v_player+obStatus).w	; make Sonic face left
		move.b	#1,(f_lockctrl).w					; lock controls
		move.w	#(btnL<<8),(v_jpadhold2).w			; move Sonic to the left
		move.w	#$F800,(v_player+obInertia).w		; set Sonic's speed
		jsr		(ObjPosLoad).l
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		moveq	#0,d0
		move.w	d0,(v_rings).w
		move.l	d0,(v_time).w
		move.b	d0,(v_lifecount).w
		move.w	d0,(v_debuguse).w
		move.b	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		move.w	d0,(f_debugmode).w					; disable debug mode
		bsr.w	OscillateNumInit
		move.w	#1800,(v_demolength).w
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		move.w	#$3F,(v_pfade_start).w
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Main ending sequence loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		jsr		(AnimateLevelGfx).l
		bsr.w	PaletteCycle
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		cmpi.b	#id_Ending,(v_gamemode).w	; is game mode $18 (ending)?
		beq.s	End_ChkEmerald				; if yes, branch

		move.b	#id_Credits,(v_gamemode).w	; goto credits
		clr.w	(v_creditsnum).w			; set credits index number to 0
		move.b	#bgm_Credits,d0
		bra.w	QueueSound1					; play credits music
; ===========================================================================

End_ChkEmerald:
		tst.b	(f_restart).w				; has Sonic released the emeralds?
		beq.w	End_MainLoop				; if not, branch

		clr.b	(f_restart).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

End_AllEmlds:
		bsr.w	PauseGame
		move.b	#$18,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w
		bsr.w	End_MoveSonic
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	End_SlowFade
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

End_SlowFade:
		tst.b	(f_restart).w
		beq.w	End_AllEmlds
		clr.b	(f_restart).w
		move.l	#$AAABAE9A,(v_lvllayout+$200).w	; MJ: modify level layout
		move.l	#$ACADAFB0,(v_lvllayout+$300).w
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
		lea		(v_screenposx).w,a3
		lea		(v_lvllayout).w,a4
		move.w	#$4000,d2
		bsr.w	DrawChunks
		moveq	#palid_Ending,d0
		bsr.w	PalLoad_Fade					; load ending palette

	if SuperMod
		bsr.w	PalLoad_EndFlowers
	endif

		bsr.w	PaletteWhiteIn
		bra.w	End_MainLoop

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


End_MoveSonic:
		move.b	(v_sonicend).w,d0
		bne.s	End_MoveSon2
		cmpi.w	#$90,(v_player+obX).w ; has Sonic passed $90 on x-axis?
		bhs.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_sonicend).w
		move.b	#1,(f_lockctrl).w ; lock player's controls
		move.w	#(btnR<<8),(v_jpadhold2).w ; move Sonic to the right
		rts	
; ===========================================================================

End_MoveSon2:
		subq.b	#2,d0
		bne.s	End_MoveSon3
		cmpi.w	#$A0,(v_player+obX).w ; has Sonic passed $A0 on x-axis?
		blo.s	End_MoveSonExit	; if not, branch

		addq.b	#2,(v_sonicend).w
		moveq	#0,d0
		move.b	d0,(f_lockctrl).w
		move.w	d0,(v_jpadhold2).w ; stop Sonic moving
		move.w	d0,(v_player+obInertia).w
		move.b	#$81,(v_player+obCtrlLock).w ; lock controls and disable object interaction
		move.b	#fr_SonWait2,(v_player+obFrame).w
		move.w	#(aniID_Wait<<8)+aniID_Wait,(v_player+obAnim).w ; use "standing" animation
		move.b	#3,(v_player+obTimeFrame).w
		rts	
; ===========================================================================

End_MoveSon3:
		subq.b	#2,d0
		bne.s	End_MoveSonExit
		addq.b	#2,(v_sonicend).w
		move.w	#$A0,(v_player+obX).w
		move.b	#id_EndSonic,(v_player).w ; load Sonic ending sequence object
		clr.w	(v_player+obRoutine).w

End_MoveSonExit:
		rts	
; End of function End_MoveSonic

; ===========================================================================