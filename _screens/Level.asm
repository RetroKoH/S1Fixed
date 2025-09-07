; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

GM_Level:
		bset	#7,(v_gamemode).w			; add $80 to screen mode (for pre level sequence)
		tst.w	(f_demo).w
		bmi.s	Level_NoMusicFade

	if AmbienceMode
		move.w	#bgm_Stop,d0
	else
		move.w	#bgm_Fade,d0
	endif

		bsr.w	QueueSound2					; fade out music

Level_NoMusicFade:
	if SaveProgressMod=1
		cmpi.b	#$8C,(v_gamemode).w			; is game mode = $0C (standard level)?
		bne.s	.noSRAM						; if not, branch
		tst.b	(f_levsel_active).w
		bne.s	.noSRAM

		gotoSRAM							; Enable SRAM writing
	if AddressSRAM=3
		; no need to change this by yourself anymore -- Starleaf
		lea 	($200009).l,a1				; Base of usable SRAM
	else
		lea		($200008).l,a1				; Base of usable SRAM
	endif

		move.w	(v_zone).w,d0				; move zone and act number to d0 (we can't do it directly)
		movep.w	d0,sram_zone(a1)			; save zone and act to SRAM	
		move.b	(v_lives).w,d0
		move.b	d0,sram_lives(a1)
		move.l	(v_score).w,d0
		movep.l	d0,sram_score(a1)
		move.l	(v_scorelife).w,d0
		movep.l	d0,sram_scorelife(a1)
		move.b	(v_lastspecial).w,d0
		move.b	d0,sram_lastspecial(a1)
		move.w	(v_emeralds).w,d0
		movep.w	d0,sram_emeralds(a1)
		move.b	(v_continues).w,d0
		move.b	d0,sram_continues(a1)

        gotoROM								; Disable SRAM writing

	.noSRAM:
	endif

		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		tst.w	(f_demo).w					; is an ending sequence demo running?
		bmi.w	Level_ClrRam				; if yes, branch
		disable_ints
		locVRAM	ArtTile_Title_Card*tile_size

	if OptimalTitleCardArt
	; RetroKoH Optimal Title Cards for VRAM/SpritePiece Reduction
		moveq	#0,d0
		move.b	(v_zone).w,d0

		cmpi.w	#(id_LZ<<8)+3,(v_zone).w	; check if level is SBZ3
		bne.s	.chkFinal
		moveq	#$28,d0						; load title card art for SBZ
		bra.s	.cont

.chkFinal:
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w	; check if level is FZ
		bne.s	.normalLoad
		lea		Art_TitCardFZ,a0									; load title card patterns
		move.l	#((Art_TitCardFZ_End-Art_TitCardFZ)/tile_size)-1,d0	; # of tiles
		bra.s	.load

.normalLoad:
		lsl.w	#3,d0						; zone * 8
.cont:
		lea		(Art_TitleCardZones).l,a2	; a2 = Art_TitleCardZones address
		lea		(a2,d0.w),a2				; a2 = Art_TitleCardZones + zone offset
		movea.l	(a2)+,a0					; a0 = zone's art file movea.l?
		move.l	(a2),d0						; # of tiles
.load:
		jsr		(LoadUncArt).w
		locVRAM	(ArtTile_Title_Card+$22)*tile_size							; if we don't call this, locVRAM will pick up where left off.
		lea		Art_TitCardZone,a0											; load title card patterns
		move.l	#((Art_TitCardZone_End-Art_TitCardZone)/tile_size)-1,d0		; # of tiles
		jsr		(LoadUncArt).w
		lea		Art_TitCardItems,a0											; load title card patterns
		move.l	#((Art_TitCardItems_End-Art_TitCardItems)/tile_size)-1,d0	; # of tiles
		jsr		(LoadUncArt).w
	; Optimal Title Cards End
	else
	; AURORA☆FIELDS Title Card Optimization
		lea		Art_TitleCard,a0									; load title card patterns
		move.l	#((Art_TitleCard_End-Art_TitleCard)/tile_size)-1,d0	; # of tiles
		jsr		(LoadUncArt).w
	; Title Card Optimization End
	endif

	if DynamicArt
; -----------------------------------------------------------------------

			enable_ints
			moveq	#0,d0
			move.b	(v_zone).w,d0				; load zone to d0
			move.l	d0,d1						; copy to d1
			add.b	d0,d0
			add.b	d0,d0						; multiply by 4
			sub.b	d1,d0						; the result is zone*3
			add.b	(v_act).w,d0				; add act

			cmpi.w	#(id_LZ<<8)+3,(v_zone).w	; is level SBZ3 (LZ4) ?
			bne.s	.notSBZ3					; if not, branch
			moveq	#SBZ3_Art,d0				; use SBZ3 art

	.notSBZ3:

; -----------------------------------------------------------------------
	else
; -----------------------------------------------------------------------

			enable_ints
			moveq	#0,d0
			move.b	(v_zone).w,d0				; load zone to d0

		if NewSBZ3LevelArt
			cmpi.w	#(id_LZ<<8)+3,(v_zone).w	; is level SBZ3 (LZ4) ?
			bne.s	.notSBZ3					; if not, branch
			moveq	#SBZ3_Art,d0				; use SBZ3 art

	.notSBZ3:
		endif

; -----------------------------------------------------------------------
	endif

		lsl.w	#4,d0
		move.w	d0,(v_levelheader_id).w			; store level header ID (reduce calculations w/ Level Loading -- RetroKoH)
		lea		(LevelHeaders).l,a2				; a2 = LevelHeaders address
		lea		(a2,d0.w),a2					; a2 = LevelHeaders + zone offset
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_37FC
		bsr.w	AddPLC				; load level patterns

loc_37FC:
		moveq	#plcid_Main2,d0
		bsr.w	AddPLC				; load standard	patterns

Level_ClrRam:
		clearRAM v_ringpos,v_ringspace_end				; clear ring RAM -- RetroKoH S3K Rings Manager
		clearRAM v_objspace								; clear object RAM
		clearRAM v_misc_variables
		clearRAM v_levelvariables						; f_levelstarted should clear here
		clearRAM v_timingandscreenvariables

		disable_ints
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

		ResetDMAQueue	; Mercury Use DMA Queue

		cmpi.b	#id_LZ,(v_zone).w		; is level LZ?
		bne.s	Level_LoadPal			; if not, branch

		move.w	#$8014,(a6)				; enable H-interrupts
		moveq	#0,d0
		move.b	(v_act).w,d0
		add.w	d0,d0
		lea		(WaterHeight).l,a1		; load water height array
		move.w	(a1,d0.w),d0
		move.w	d0,(v_waterpos1).w		; set water heights
		move.w	d0,(v_waterpos2).w
		move.w	d0,(v_waterpos3).w
		moveq	#0,d0
		move.b	d0,(v_wtr_routine).w	; clear water routine counter
		move.b	d0,(f_wtr_state).w		; clear	water state
		move.b	#1,(f_water).w			; enable water

Level_LoadPal:
		move.b	#30,(v_air).w
		enable_ints
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad					; load Sonic's palette
		cmpi.b	#id_LZ,(v_zone).w		; is level LZ?
		bne.s	Level_GetBgm			; if not, branch

		moveq	#palid_LZSonWater,d0	; LZ Water Sonic
	if DynamicPalettes
		add.b	(v_act).w,d0			; Adjust for act
	endif
		cmpi.b	#3,(v_act).w			; is act number 3?
		bne.s	Level_WaterPal			; if not, branch
		moveq	#palid_SBZ3SonWat,d0	; SBZ3 Water Sonic

Level_WaterPal:
		bsr.w	PalLoad_Fade_Water		; load underwater palette
		tst.b	(v_lastlamp).w
		beq.s	Level_GetBgm
		move.b	(v_lamp_wtrstat).w,(f_wtr_state).w

Level_GetBgm:
		tst.w	(f_demo).w
		bmi.s	Level_SkipTtlCard

	if ~~AmbienceMode
		if DynamicBGMs
	; -----------------------------------------------------------------------
			moveq	#0,d0
			move.b	(v_zone).w,d0
			add.b	d0,d0
			add.b	d0,d0							; multiply by 4
			add.b	(v_act).w,d0					; add the act value
			lea		(MusicList).l,a1				; load music playlist
			move.b	(a1,d0.w),d0
			bsr.w	QueueSound1						; play music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	; -----------------------------------------------------------------------
		else
	; -----------------------------------------------------------------------
			moveq	#0,d0
			move.b	(v_zone).w,d0
			cmpi.w	#(id_LZ<<8)+3,(v_zone).w		; is level SBZ3?
			bne.s	Level_BgmNotLZ4					; if not, branch
			moveq	#5,d0							; use 5th music (SBZ)

	Level_BgmNotLZ4:
			cmpi.w	#(id_SBZ<<8)+2,(v_zone).w		; is level FZ?
			bne.s	Level_PlayBgm					; if not, branch
			moveq	#6,d0							; use 6th music (FZ)

	Level_PlayBgm:
			lea		(MusicList).l,a1				; load music playlist
			move.b	(a1,d0.w),d0
			bsr.w	QueueSound1						; play music
			move.b	d0,(v_lastbgmplayed).w			; store last played music
	; ------------------------------------------------------------------------
		endif
	endif

		move.b	#id_TitleCard,(v_titlecard).w	; load title card object

		move.b  #3,(v_carddelay).w				; set the delay timer -- Fixes bug w/ HUD elements not appearing

Level_TtlCardLoop:
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	RunPLC
		move.w	(v_ttlcardact+obX).w,d0
		cmp.w	(v_ttlcardact+card_mainX).w,d0	; has title card sequence finished?
		bne.s	Level_TtlCardLoop				; if not, branch
		tst.l	(v_plc_buffer).w				; are there any items in the pattern load cue?
		bne.s	Level_TtlCardLoop				; if yes, branch
		subq.b  #1,(v_carddelay).w				; substract 1 from timer
        bne.s   Level_TtlCardLoop				; if timer is not 0, branch
		jsr		(Hud_Base).l					; load basic HUD gfx

Level_SkipTtlCard:
	if RandomMonitors
		locVRAM	(ArtTile_Monitor+$14)*tile_size
		lea		Art_Mon_Rand,a0					; load random monitor patterns
		move.l	#3,d0							; # of tiles
		jsr		(LoadUncArt).w
	endif

		bsr.w	LoadRingFrame					; DeltaW/Malachi Optimized Rings
		moveq	#palid_Sonic,d0
		bsr.w	PalLoad_Fade					; load Sonic's palette
		jsr		(AnimateLevelGfx_Init).l
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers
		bset	#2,(v_fg_scroll_flags).w
		bsr.w	LevelDataLoad					; load level art -- Clownacy Level Art Loading + load block mappings and palettes
		bsr.w	LoadTilesFromStart
		jsr		(ConvertCollisionArray).l
		bsr.w	ColIndexLoad
		bsr.w	LZWaterFeatures
		move.b	#id_SonicPlayer,(v_player).w	; load Sonic object

	if InstashieldEnabled
		move.b	#id_ShieldItem,(v_shieldobj).w	; load instashield object
		move.b	#shTypeInsta,(v_shieldobj+obSubtype).w
	endif

Level_ChkWater:
		moveq	#0,d0
		move.w	d0,(v_jpadhold2).w
		move.w	d0,(v_jpadhold1).w
		cmpi.b	#id_LZ,(v_zone).w						; is level LZ?
		bne.s	Level_LoadObj							; if not, branch
		move.b	#id_WaterSurface,(v_watersurface1).w	; load water surface object
		move.w	#$60,(v_watersurface1+obX).w
		move.b	#id_WaterSurface,(v_watersurface2).w
		move.w	#$120,(v_watersurface2+obX).w

Level_LoadObj:
		jsr		(ObjPosLoad).l
		jsr		(RingsManager).l		; RetroKoH S3K Rings Manager
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		moveq	#0,d0
		tst.b	(v_lastlamp).w			; are you starting from	a lamppost?
		bne.s	Level_SkipClr			; if yes, branch
		move.w	d0,(v_rings).w			; clear rings
		move.l	d0,(v_time).w			; clear time

	if HUDCentiseconds=1	; Mercury HUD Centiseconds
		move.b	d0,(v_centstep).w
	endif	; HUD Centiseconds end

		move.b	d0,(v_lifecount).w		; clear lives counter

Level_SkipClr:
		move.b	d0,(f_timeover).w
		move.w	d0,(v_debuguse).w
		move.b	d0,(f_restart).w
		move.w	d0,(v_framecount).w
		bsr.w	OscillateNumInit
		moveq	#1,d0
		move.b	d0,(f_scorecount).w		; update score counter
		move.b	d0,(f_ringcount).w		; update rings counter

	if HUDCentiseconds=0	; Mercury HUD Centiseconds
		move.b	d0,(f_timecount).w		; update time counter
	endif	; HUD Centiseconds end

		clr.w	(v_btnpushtime1).w
		lea		DemoDataPtr(pc),a1		; load demo data
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0					; Filter: *2 instead of *4
		movea.w	(a1,d0.w),a1			; Filter: Changed from .l to .w
		tst.w	(f_demo).w				; is this an ending sequence demo?
		bpl.s	Level_Demo				; if not, branch
		lea		DemoEndDataPtr(pc),a1	; load ending demo data
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		add.w	d0,d0					; Filter: *2 instead of *4
		movea.w	(a1,d0.w),a1			; Filter: Changed from .l to .w

Level_Demo:
		move.b	1(a1),(v_btnpushtime2).w	; load key press duration
		subq.b	#1,(v_btnpushtime2).w		; subtract 1 from duration
		move.w	#1800,(v_demolength).w
		tst.w	(f_demo).w
		bpl.s	Level_ChkWaterPal
		move.w	#540,(v_demolength).w
		cmpi.w	#4,(v_creditsnum).w
		bne.s	Level_ChkWaterPal
		move.w	#510,(v_demolength).w

Level_ChkWaterPal:
		cmpi.b	#id_LZ,(v_zone).w	; is level LZ/SBZ3?
		bne.s	Level_Delay			; if not, branch
		moveq	#palid_LZWater,d0	; palette: LZ underwater
	if DynamicPalettes
		add.b	(v_act).w,d0		; Adjust for act
	endif
		cmpi.b	#3,(v_act).w		; is level SBZ3?
		bne.s	Level_WtrNotSbz		; if not, branch
		moveq	#palid_SBZ3Water,d0	; palette: SBZ3 underwater

Level_WtrNotSbz:
		bsr.w	PalLoad_Water

Level_Delay:
		move.w	#3,d1

Level_DelayLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		dbf	d1,Level_DelayLoop

		move.w	#$202F,(v_pfade_start).w ; fade in 2nd, 3rd & 4th palette lines
		bsr.w	PalFadeIn_Alt
		tst.w	(f_demo).w	; is an ending sequence demo running?
		bmi.s	Level_ClrCardArt ; if yes, branch
		addq.b	#2,(v_ttlcardname+obRoutine).w ; make title card move
		addq.b	#4,(v_ttlcardzone+obRoutine).w
		addq.b	#4,(v_ttlcardact+obRoutine).w
		addq.b	#4,(v_ttlcardoval+obRoutine).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		moveq	#plcid_Explode,d0
		jsr		(AddPLC).w	; load explosion gfx
		moveq	#0,d0
		move.b	(v_zone).w,d0
		addi.w	#plcid_GHZAnimals,d0
		jsr		(AddPLC).w	; load animal gfx (level no. + $15)

Level_StartGame:
		; The above check is for the S2 HUD Manager (RetroKoH)
		; This also removes rings from the end demos. Need to fix this another way.
		tst.w	(f_demo).w
		bmi.s	.demo					; Branch if End Credits Demo
		move.b	#1,(f_levelstarted).w	; RetroKoH S3K Rings Manager
.demo:

	if HUDCentiseconds=1	;Mercury HUD Centiseconds
		move.b	#1,(f_timecount).w ; update time counter
	endif	;end HUD Centiseconds

		bclr	#7,(v_gamemode).w ; subtract $80 from mode to end pre-level stuff

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w			; add 1 to level timer
		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterFeatures
		jsr		(ExecuteObjects).l
		tst.b	(f_restart).w
		bne.w	GM_Level
		jsr		(RingsManager).l			; RetroKoH S3K Rings Manager

	if ~~ActiveDeathSequence				; RetroKoH Active Death Sequence Mod
		cmpi.b	#6,(v_player+obRoutine).w	; has Sonic just died?
		bhs.s	Level_SkipDeform			; if yes, branch
	endif
		bsr.w	DeformLayers

Level_SkipDeform:
	if HUDScrolling=1
		cmpi.b	#128+16,(v_hudscrollpos).w
		beq.s	Level_SkipHUDScroll
		add.b	#4,(v_hudscrollpos).w

Level_SkipHUDScroll:
	endif
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		bsr.w	SignpostArtLoad
		jsr		(AnimateLevelGfx).l
		clr.b	(f_gfxbigring).w

		cmpi.b	#id_Demo,(v_gamemode).w
		beq.s	Level_ChkDemo				; if mode is 8 (demo), branch
		cmpi.b	#id_Level,(v_gamemode).w
		beq.w	Level_MainLoop				; if mode is $C (level), branch
		rts	
; ===========================================================================

Level_ChkDemo:
		tst.b	(f_restart).w	; is level set to restart?
		bne.s	Level_EndDemo	; if yes, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.s	Level_EndDemo	; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w
		beq.w	Level_MainLoop	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		rts	
; ===========================================================================

Level_EndDemo:
		cmpi.b	#id_Demo,(v_gamemode).w
		bne.s	Level_FadeDemo	; if mode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w ; go to Sega screen
		tst.w	(f_demo).w	; is demo mode on & not ending sequence?
		bpl.s	Level_FadeDemo	; if yes, branch
		move.b	#id_Credits,(v_gamemode).w ; go to credits

Level_FadeDemo:
		move.w	#$3C,(v_demolength).w
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

Level_FDLoop:
		move.b	#8,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		jsr		(ObjPosLoad).l
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_3BC8
		move.w	#2,(v_palchgspeed).w
		bsr.w	FadeOut_ToBlack

loc_3BC8:
		tst.w	(v_demolength).w
		bne.s	Level_FDLoop
		rts	
; ===========================================================================