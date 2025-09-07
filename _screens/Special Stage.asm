; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

GM_Special:
		move.w	#sfx_EnterSS,d0
		bsr.w	QueueSound2	; play special stage entry sound
		bsr.w	PaletteWhiteOut
		disable_ints
		lea		(vdp_control_port).l,a6
		move.w	#$8B03,(a6)			; line scroll mode
		move.w	#$8004,(a6)			; 8-colour mode
		move.w	#$8A00+175,(v_hbla_hreg).w
		move.w	#$9011,(a6)			; 128-cell hscroll size
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		
		ResetDMAQueue		; Flamewing Ultra DMA Queue

		enable_ints
		fillVRAM	0, ArtTile_SS_Plane_1*tile_size+plane_size_64x32, ArtTile_SS_Plane_5*tile_size
		bsr.w	SS_BGLoad
		moveq	#plcid_SpecialStage,d0
		bsr.w	QuickPLC	; load special stage patterns
		
		bsr.w	LoadSSRingFrame

		clearRAM v_objspace
		clearRAM v_levelvariables
		clearRAM v_timingvariables
		clearRAM v_ngfx_buffer

		moveq	#0,d0
		move.b	d0,(f_wtr_state).w
		move.b	d0,(f_restart).w
		moveq	#palid_Special,d0
		bsr.w	PalLoad_Fade						; load special stage palette
		jsr		(SS_Load).l							; load SS layout data
		moveq	#0,d0
		move.l	d0,(v_screenposx).w
		move.l	d0,(v_screenposy).w
		move.b	#id_SonicSpecial,(v_player).w		; load special stage Sonic object
		move.b	#id_SpecialCursor,(v_playerdust).w	; load new debug cursor object (RetroKoH)

	if DynamicSpecialStageWalls=1	; Mercury Dynamic Special Stage Walls
		move.b	#$FF,(v_ssangleprev).w				; fill previous angle with obviously false value to force an update

	if HUDInSpecialStage=1	; Mercury HUD in Special Stage
		move.b	#1,(f_timecount).w					; update time counter
		move.b	#1,(f_scorecount).w					; update score counter
		move.l	d0,(v_time).w						; reset time

	if TimeLimitInSpecialStage=1	; Mercury Time Limit In Special Stage
		move.b	#1,(v_timemin).w					; start with 1:00 on the clock
	endif	; Time Limit In Special Stage End

		jsr		(Hud_Base_SS).l						; load basic HUD gfx
	endif	; HUD in Special Stage End

	endif	; Dynamic Special Stage Walls End

		bsr.w	PalCycle_SS
	if S4SpecialStages=0
		move.w	#$40,(v_ssrotate).w					; set stage rotation speed
	else
		move.w	#$100,(v_ssrotate).w				; set stage rotation speed
	endif
		moveq	#bgm_SS,d0
		bsr.w	QueueSound1							; play special stage BG	music
		lea		DemoDataPtr(pc),a1
		moveq	#6,d0
		add.w	d0,d0								; Filter: *2 instead of *4
		movea.w	(a1,d0.w),a1						; Filter: Changed from .l to .w
		move.b	1(a1),(v_btnpushtime2).w
		subq.b	#1,(v_btnpushtime2).w
		moveq	#0,d0
		move.w	d0,(v_ssangle).w					; set stage angle to "upright"
		move.w	d0,(v_btnpushtime1).w
		move.w	d0,(v_rings).w
		move.b	d0,(v_lifecount).w
		move.w	d0,(v_debuguse).w
		move.w	#1800,(v_demolength).w
;		tst.b	(f_debugcheat).w					; has debug cheat been entered?
;		beq.s	SS_NoDebug							; if not, branch
;		btst	#bitA,(v_jpadhold1).w				; is A button pressed?
;		beq.s	SS_NoDebug							; if not, branch
		move.b	#1,(f_debugmode).w					; enable debug mode

SS_NoDebug:
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteWhiteIn
	if HUDInSpecialStage=1
		move.b	#2,(f_levelstarted).w				; Mercury HUD In Special Stage
	endif

; ---------------------------------------------------------------------------
; Main Special Stage loop
; ---------------------------------------------------------------------------

SS_MainLoop:
		bsr.w	PauseGame
		move.b	#$A,(v_vbla_routine).w
		bsr.w	WaitForVBla

	if HUDInSpecialStage=1	; Mercury HUD in Special Stage
		addq.w	#1,(v_framecount).w		; add 1 to level timer
	endc	; HUD in Special Stage End

		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr		(SpecialObjects).l

		bsr.w	LoadSSRingFrame

	if (HUDInSpecialStage=1&HUDScrolling=1)
		tst.b	(f_timecount).w
		beq.s	.remove
		cmpi.b	#$90,(v_hudscrollpos).w
		beq.s	SS_SkipHUDScroll
		add.b	#4,(v_hudscrollpos).w
		bra.s	SS_SkipHUDScroll

.remove:
		tst.b	(v_hudscrollpos).w
		beq.s	SS_SkipHUDScroll
		subq.b	#2,(v_hudscrollpos).w

SS_SkipHUDScroll:
	endif

		jsr		(BuildSprites).l
		jsr		(SS_ShowLayout).l
		bsr.w	SS_BGAnimate
		tst.w	(f_demo).w	; is demo mode on?
		beq.s	SS_ChkEnd	; if not, branch
		tst.w	(v_demolength).w ; is there time left on the demo?
		beq.w	SS_ToSegaScreen	; if not, branch

SS_ChkEnd:
		cmpi.b	#id_Special,(v_gamemode).w ; is game mode $10 (special stage)?
		beq.w	SS_MainLoop	; if yes, branch

		tst.w	(f_demo).w	; is demo mode on?
		bne.w	SS_ToLevel
		move.b	#id_Level,(v_gamemode).w ; set screen mode to $0C (level)
		cmpi.w	#(id_SBZ<<8)+3,(v_zone).w ; is level number higher than FZ?
		blo.s	SS_Finish	; if not, branch
		clr.w	(v_zone).w	; set to GHZ1

SS_Finish:
		move.w	#60,(v_demolength).w ; set delay time to 1 second
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

SS_FinLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadhold1).w,(v_jpadhold2).w
		jsr		(SpecialObjects).l
		jsr		(BuildSprites).l
		jsr		(SS_ShowLayout).l
		bsr.w	SS_BGAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	loc_47D4
		move.w	#2,(v_palchgspeed).w
		bsr.w	WhiteOut_ToWhite

loc_47D4:
		tst.w	(v_demolength).w
		bne.s	SS_FinLoop

		disable_ints
		lea		(vdp_control_port).l,a6
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$9001,(a6)		; 64-cell hscroll size
		bsr.w	ClearScreen
		locVRAM	ArtTile_Title_Card*tile_size

	if OptimalTitleCardArt
	; RetroKoH Optimal Title Cards for VRAM/SpritePiece Reduction
		lea		Art_TitCardSpecStage,a0												; load title card patterns
		move.l	#((Art_TitCardSpecStage_End-Art_TitCardSpecStage)/tile_size)-1,d0	; # of tiles
		move.b	(v_emeralds).w,d1	; do you have ANY chaos emeralds?
		beq.s	.load				; if not, branch
		lea		Art_TitCardChaosEmlds,a0											; load title card patterns
		move.l	#((Art_TitCardChaosEmlds_End-Art_TitCardChaosEmlds)/tile_size)-1,d0	; # of tiles
		cmpi.b	#emldCount,d1		; do you have all chaos	emeralds?
		bne.s	.load				; if not, branch
		lea		Art_TitCardSonic,a0													; load title card patterns
		move.l	#((Art_TitCardSonic_End-Art_TitCardSonic)/tile_size)-1,d0			; # of tiles
		jsr		(LoadUncArt).w
		lea		Art_TitCardGotThemAll,a0											; load title card patterns
		move.l	#((Art_TitCardGotThemAll_End-Art_TitCardGotThemAll)/tile_size)-1,d0	; # of tiles
		
.load:
		jsr		(LoadUncArt).w
		locVRAM	(ArtTile_Title_Card+$32)*tile_size									; if we don't call this, locVRAM will pick up where left off.
		lea		Art_TitCardBonuses,a0												; load title card patterns
		move.l	#((Art_TitCardBonuses_End-Art_TitCardBonuses)/tile_size)-1,d0		; # of tiles
		jsr		(LoadUncArt).w
		movea.l	#Art_TitCardOval,a0													; load title card patterns
		move.l	#Art_TitCardOvalCt,d0												; # of tiles
		jsr		(LoadUncArt).w
	
	if PerfectBonusEnabled
		locVRAM ArtTile_Perfect*tile_size
		lea		Art_Perfect,a0									; load title card patterns
		move.l	#((Art_Perfect_End-Art_Perfect)/tile_size)-1,d0	; # of tiles
		jsr		(LoadUncArt).w									; load uncompressed art
	endif
	; Optimal Title Cards End
	else
	; AURORA☆FIELDS Title Card Optimization
		lea		Art_TitleCard,a0									; load title card patterns
		move.l	#((Art_TitleCard_End-Art_TitleCard)/tile_size)-1,d0	; # of tiles
		jsr		(LoadUncArt).w
		
	if PerfectBonusEnabled
		locVRAM	ArtTile_Perfect*tile_size
		lea		Art_Perfect,a0									; load title card patterns
		move.l	#((Art_Perfect_End-Art_Perfect)/tile_size)-1,d0	; # of tiles
		jsr		(LoadUncArt).w									; load uncompressed art
	endif
	; Title Card Optimization End
	endif
		
		jsr		(Hud_Base).l

	; Mercury Use DMA Queue
		ResetDMAQueue
	; Use DMA Queue End

		enable_ints
		moveq	#palid_SSResult,d0
		bsr.w	PalLoad					; load results screen palette
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		moveq	#plcid_SSResult,d0
		bsr.w	AddPLC					; load results screen patterns
		move.b	#1,(f_scorecount).w		; update score counter
		move.b	#1,(f_endactbonus).w	; update ring bonus counter
		move.w	(v_rings).w,d0
		add.w	d0,d0					; multiply by 10
		move.w	d0,d1					; Optimization from S1 in S.C.E.
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(v_ringbonus).w		; set rings bonus
		
	if PerfectBonusEnabled
		tst.w	(v_perfectringsleft).w					; did Sonic get all the rings?
		bne.s	.noperfect
		move.w	#PerfectScore,(v_perfectbonus).w		; set perfect bonus
	.noperfect:
	endif
		
		move.w	#bgm_GotThrough,d0
		bsr.w	QueueSound2	; play end-of-level music

		clearRAM v_objspace

		move.b	#id_SSResult,(v_ssrescard).w	; load results screen object

	if HUDInSpecialStage=1
		clr.b	(f_levelstarted).w				; remove HUD
	endif

SS_NormalExit:
		bsr.w	PauseGame
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	RunPLC
		tst.b	(f_restart).w
		beq.s	SS_NormalExit
		tst.l	(v_plc_buffer).w
		bne.s	SS_NormalExit
		move.w	#sfx_EnterSS,d0
		bsr.w	QueueSound2 ; play special stage exit sound
		bra.w	PaletteWhiteOut
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w ; goto Sega screen
		rts

SS_ToLevel:	; Check if branch to this is needed
		cmpi.b	#id_Level,(v_gamemode).w
		beq.s	SS_ToSegaScreen
		rts

; ---------------------------------------------------------------------------
; Special stage	background loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGLoad:
		lea		(v_ssbuffer1&$FFFFFF).l,a1
		lea		(Eni_SSBg1).l,a0	; load mappings for the birds and fish
		move.w	#make_art_tile(ArtTile_SS_Background_Fish,2,0),d0
		bsr.w	EniDec
		locVRAM	ArtTile_SS_Plane_1*tile_size+plane_size_64x32,d3
		lea		((v_ssbuffer1+$80)&$FFFFFF).l,a2
		moveq	#7-1,d7				; $5000, $6000, $7000, $8000, $9000, $A000, $B000

loc_48BE:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#4-1,d7 ; $8000
		bhs.s	loc_48CC
		moveq	#1,d4

loc_48CC:
		moveq	#8-1,d5

loc_48CE:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_48E2
		cmpi.w	#6,d7
		bne.s	loc_48F2

		lea		(v_ssbuffer1&$FFFFFF).l,a1

loc_48E2:
		movem.l	d0-d4,-(sp)
		moveq	#8-1,d1
		moveq	#8-1,d2
		bsr.w	TilemapToVRAM
		movem.l	(sp)+,d0-d4

loc_48F2:
		addi.l	#$100000,d0
		dbf		d5,loc_48CE

		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf		d6,loc_48CC

		addi.l	#$10000000,d3
		bpl.s	loc_491C
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_491C:
		adda.w	#$80,a2
		dbf		d7,loc_48BE

		lea		(v_ssbuffer1&$FFFFFF).l,a1
		lea		(Eni_SSBg2).l,a0			; load mappings for the clouds
		move.w	#make_art_tile(ArtTile_SS_Background_Clouds,2,0),d0
		bsr.w	EniDec
		copyTilemap	v_ssbuffer1&$FFFFFF,ArtTile_SS_Plane_5*tile_size,64,32
		copyTilemap	v_ssbuffer1&$FFFFFF,ArtTile_SS_Plane_5*tile_size+plane_size_64x32,64,64
		rts	
; End of function SS_BGLoad

; ---------------------------------------------------------------------------
; Palette cycling routine - special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SS:
		tst.b	(f_pause).w
		bne.s	locret_49E6
		subq.w	#1,(v_palss_time).w
		bpl.s	locret_49E6

		lea		(vdp_control_port).l,a6
		move.w	(v_palss_num).w,d0
		addq.w	#1,(v_palss_num).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea		(byte_4A3C).l,a0
		adda.w	d0,a0

	; Time
		move.b	(a0)+,d0
		bpl.s	loc_4992
		move.w	#$1FF,d0

loc_4992:
		move.w	d0,(v_palss_time).w

	; Anim
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,(v_ssbganim).w
		lea		(byte_4ABC).l,a1
		lea		(a1,d0.w),a1

	; FG VRAM
		move.w	#$8200,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		
	; Y coordinate
		move.b	(a1),(v_scrposy_vdp).w

	; BG VRAM
		move.w	#$8400,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l

	; Palette cycle index
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_49E8
		lea		(Pal_SSCyc1).l,a1
		adda.w	d0,a1
		lea		(v_palette+$4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_49E6:
		rts	
; ===========================================================================

loc_49E8:
		move.w	(v_palss_index).w,d1	; Doesn't seem to ever be modified...
		cmpi.w	#$8A,d0
		blo.s	loc_49F4
		addq.w	#1,d1

loc_49F4:
		mulu.w	#$2A,d1
		lea		(Pal_SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0

		bclr	#0,d0
		beq.s	loc_4A18
		lea		(v_palette+$6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_4A18:
		adda.w	#$C,a1
		lea		(v_palette+$5A).w,a2
		cmpi.w	#$A,d0
		blo.s	loc_4A2E
		subi.w	#$A,d0
		lea		(v_palette+$7A).w,a2

loc_4A2E:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts	
; End of function PalCycle_SS

; ===========================================================================

SSBGData:	macro time,anim,vram,index,flag1,flag2
		dc.b	(time), (anim), ((vram)*tile_size)>>13
	if flag1
		dc.b	(index)|$80|(flag2)
	else
		dc.b	(index)*12
	endif
		endm

byte_4A3C:
		; Time, anim, BG VRAM, palette cycle index & flags
		SSBGData  3,  0, ArtTile_SS_Plane_6, 18, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 16, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 14, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 12, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 10, TRUE , TRUE

		SSBGData  3,  0, ArtTile_SS_Plane_6,  0, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  2, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  4, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  6, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  8, TRUE , FALSE


		SSBGData  7,  8, ArtTile_SS_Plane_6,  0, FALSE, FALSE
		SSBGData  7, 10, ArtTile_SS_Plane_6,  1, FALSE, FALSE
		SSBGData -1, 12, ArtTile_SS_Plane_6,  2, FALSE, FALSE
		SSBGData -1, 12, ArtTile_SS_Plane_6,  2, FALSE, FALSE
		SSBGData  7, 10, ArtTile_SS_Plane_6,  1, FALSE, FALSE
		SSBGData  7,  8, ArtTile_SS_Plane_6,  0, FALSE, FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  8, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  6, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  4, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  2, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  0, TRUE , TRUE

		SSBGData  3,  0, ArtTile_SS_Plane_5, 10, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 12, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 14, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 16, TRUE , FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 18, TRUE , FALSE

		SSBGData  7,  2, ArtTile_SS_Plane_5,  3, FALSE, FALSE
		SSBGData  7,  4, ArtTile_SS_Plane_5,  4, FALSE, FALSE
		SSBGData -1,  6, ArtTile_SS_Plane_5,  5, FALSE, FALSE
		SSBGData -1,  6, ArtTile_SS_Plane_5,  5, FALSE, FALSE
		SSBGData  7,  4, ArtTile_SS_Plane_5,  4, FALSE, FALSE
		SSBGData  7,  2, ArtTile_SS_Plane_5,  3, FALSE, FALSE
		even

SSFGData:	macro vram,y
		dc.b ((vram)*tile_size)>>10, (y)>>8
		endm

byte_4ABC:
		; FG VRAM, Y coordinate
		SSFGData ArtTile_SS_Plane_1, $100
		SSFGData ArtTile_SS_Plane_2,    0
		SSFGData ArtTile_SS_Plane_2, $100
		SSFGData ArtTile_SS_Plane_3,    0
		SSFGData ArtTile_SS_Plane_3, $100
		SSFGData ArtTile_SS_Plane_4,    0
		SSFGData ArtTile_SS_Plane_4, $100
		even

; ===========================================================================

Pal_SSCyc1:	binclude	"palette/Cycle - Special Stage 1.bin"
		even
Pal_SSCyc2:	binclude	"palette/Cycle - Special Stage 2.bin"
		even

; ---------------------------------------------------------------------------
; Subroutine to	make the special stage background animated
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_BGAnimate:
		move.w	(v_ssbganim).w,d0
		bne.s	loc_4BF6
		clr.w	(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

loc_4BF6:
		cmpi.w	#8,d0
		bhs.s	loc_4C4E
		cmpi.w	#6,d0
		bne.s	loc_4C10
		addq.w	#1,(v_bg3screenposx).w
		addq.w	#1,(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

loc_4C10:
		moveq	#0,d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_4CCC).l,a1
		lea	(v_ngfx_buffer).w,a3
		moveq	#9,d3

loc_4C26:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_4C26
		lea	(v_ngfx_buffer).w,a3
		lea	(byte_4CB8).l,a2
		bra.s	loc_4C7E
; ===========================================================================

loc_4C4E:
		cmpi.w	#$C,d0
		bne.s	loc_4C74
		subq.w	#1,(v_bg3screenposx).w
		lea	(v_ssscroll_buffer).w,a3
		move.l	#$18000,d2
		moveq	#7-1,d1

loc_4C64:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_4C64

loc_4C74:
		lea	(v_ssscroll_buffer).w,a3
		lea	(byte_4CC4).l,a2

loc_4C7E:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	(v_bgscreenposy).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_4C9A:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_4CA4:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_4CA4
		dbf	d3,loc_4C9A
		rts	
; End of function SS_BGAnimate

; ===========================================================================
byte_4CB8:	dc.b 9,	$28, $18, $10, $28, $18, $10, $30, $18,	8, $10,	0
		even
byte_4CC4:	dc.b 6,	$30, $30, $30, $28, $18, $18, $18
		even
byte_4CCC:	dc.b 8,	2, 4, $FF, 2, 3, 8, $FF, 4, 2, 2, 3, 8,	$FD, 4,	2, 2, 3, 2, $FF
		even

; ===========================================================================