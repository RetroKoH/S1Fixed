; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

GM_Special:
		move.w	#sfx_EnterSS,d0
		bsr.w	QueueSound2							; play special stage entry sound
		bsr.w	PaletteWhiteOut						; fade to white from previous gamemode
		disable_ints
		lea		(vdp_control_port).l,a6
		move.w	#$8B03,(a6)							; 1-pixel line scroll mode
		move.w	#$8004,(a6)							; normal (8-color) mode
		move.w	#$8A00+175,(v_hbla_hreg).w
		move.w	#$9011,(a6)							; 64x64 cell plane size
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		
		ResetDMAQueue								; Flamewing Ultra DMA Queue

		enable_ints
		fillVRAM	0, ArtTile_SS_Plane_1*tile_size+plane_size_64x32, ArtTile_SS_Plane_5*tile_size
		bsr.w	SS_BGLoad
		moveq	#plcid_SpecialStage,d0
		bsr.w	QuickPLC							; load special stage patterns
		
		bsr.w	LoadSSRingFrame

		clearRAM v_objspace
		clearRAM v_levelvariables
		clearRAM v_timingvariables
		clearRAM v_ngfx_buffer

		moveq	#0,d0
		move.b	d0,(f_water_pal_full).w
		move.b	d0,(f_restart).w
		moveq	#palid_Special,d0
		bsr.w	PalLoad_Fade						; load special stage palette
		jsr		(SS_Load).l							; load SS layout data
		moveq	#0,d0
		move.l	d0,(v_screenposx).w
		move.l	d0,(v_screenposy).w
		_move.l	#SonicSpecial,(v_player+obAddr).w		; load special stage Sonic object
		_move.l	#SpecialCursor,(v_playerdust+obAddr).w	; load new debug cursor object (RetroKoH)

	if DynamicSpecialStageWalls	; Mercury Dynamic Special Stage Walls
		move.b	#$FF,(v_ssangleprev).w				; fill previous angle with obviously false value to force an update

	if HUDInSpecialStage	; Mercury HUD in Special Stage
		move.b	#1,(f_timecount).w					; update time counter
		move.b	#1,(f_scorecount).w					; update score counter
		move.l	d0,(v_time).w						; reset time

	if TimeLimitInSpecialStage	; Mercury Time Limit In Special Stage
		move.b	#1,(v_timemin).w					; start with 1:00 on the clock
	endif	; Time Limit In Special Stage End

		jsr		(Hud_Base_SS).l						; load basic HUD gfx
	endif	; HUD in Special Stage End

	endif	; Dynamic Special Stage Walls End

		bsr.w	PalCycle_SS

	if S4SpecialStages
		move.w	#$100,(v_ssrotate).w				; set stage rotation speed
	else
		move.w	#$40,(v_ssrotate).w					; set stage rotation speed
	endif

	if ~~AmbienceMode
		moveq	#bgm_SpecialStage,d0
		bsr.w	QueueSound1							; play special stage BG	music
	endif

		lea		DemoDataPtr(pc),a1
		moveq	#6,d0								; use demo #6
		add.w	d0,d0								; Filter: *2 instead of *4
		movea.w	(a1,d0.w),a1						; Filter: Changed from .l to .w
		move.b	1(a1),(v_btnpushtime2).w			; load 1st button press duration (v_demo_input_time)
		subq.b	#1,(v_btnpushtime2).w
		moveq	#0,d0
		move.w	d0,(v_ssangle).w					; set stage angle to "upright"
		move.w	d0,(v_btnpushtime1).w
		move.w	d0,(v_rings).w
		move.b	d0,(v_lifecount).w
		move.w	#RingsLivesFactor,(v_ringlife).w
		move.w	d0,(v_debuguse).w
		move.w	#1800,(v_countdown).w				; set timer to 30 seconds (used for demo)
;		tst.b	(f_debugcheat).w					; has debug cheat been entered?
;		beq.s	SS_NoDebug							; if not, branch
;		btst	#bitA,(v_jpadheld_actual).w			; is A button pressed?
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
		addq.w	#1,(v_framecount).w					; add 1 to level timer
	endc	; HUD in Special Stage End

		bsr.w	MoveSonicInDemo
		move.w	(v_jpadheld_actual).w,(v_jpadheld_dup).w
		jsr		(SpecialObjects).l					; run SS Sonic and Debug Cursor objects only

		bsr.w	LoadSSRingFrame

	if (HUDInSpecialStage&HUDScrolling)
		tst.b	(f_timecount).w
		beq.s	.remove
		cmpi.b	#$90,(v_hudscrollpos).w
		beq.s	SS_SkipHUDScroll
		addq.b	#4,(v_hudscrollpos).w
		bra.s	SS_SkipHUDScroll

	.remove:
		tst.b	(v_hudscrollpos).w
		beq.s	SS_SkipHUDScroll
		subq.b	#2,(v_hudscrollpos).w

SS_SkipHUDScroll:
	endif

		jsr		(BuildSprites).l
		jsr		(SS_ShowLayout).l					; display layout
		bsr.w	SS_BGAnimate						; animate background
		tst.w	(f_demo).w							; is demo mode on?
		beq.s	.not_demo							; if not, branch
		tst.w	(v_countdown).w						; is there time left on the demo?
		beq.w	SS_ToSegaScreen						; if not, branch

	.not_demo:
		cmpi.b	#id_Special,(v_gamemode).w			; is game mode $10 (special stage)?
		beq.w	SS_MainLoop							; if yes, branch

		tst.w	(f_demo).w							; is demo mode on?
		bne.w	SS_ToLevel							; if yes, branch
		move.b	#id_Level,(v_gamemode).w			; set screen mode to $0C (level)
		cmpi.w	#(id_SBZ<<8)+3,(v_zone).w			; is level number higher than FZ?
		blo.s	.level_ok							; if not, branch
		clr.w	(v_zone).w							; set to GHZ1

	.level_ok:
		move.w	#60,(v_countdown).w					; set delay time to 1 second
		move.w	#$3F,(v_pfade_start).w
		clr.w	(v_palchgspeed).w

SS_FinishLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	MoveSonicInDemo
		move.w	(v_jpadheld_actual).w,(v_jpadheld_dup).w
		jsr		(SpecialObjects).l
		jsr		(BuildSprites).l
		jsr		(SS_ShowLayout).l
		bsr.w	SS_BGAnimate
		subq.w	#1,(v_palchgspeed).w
		bpl.s	.leave_palette						; branch if palette timer is 0 or higher
		move.w	#2,(v_palchgspeed).w				; set palette update delay to 2 frames
		bsr.w	WhiteOut_ToWhite					; fade to white in increments

	.leave_palette:
		tst.w	(v_countdown).w						; has timer hit 0?
		bne.s	SS_FinishLoop						; if not, branch

		disable_ints
		lea		(vdp_control_port).l,a6
		move.w	#$8200+(vram_fg>>10),(a6)			; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)			; set background nametable address
		move.w	#$9001,(a6)							; 64x32 cell plane size
		bsr.w	ClearScreen

	; RetroKoH Optimal Title Cards for VRAM/SpritePiece Reduction
		locVRAM	ArtTile_Title_Card*tile_size,d1

		lea		Art_TitCardSpecStage,a0												; load title card patterns
		move.l	#((Art_TitCardSpecStage_End-Art_TitCardSpecStage)/tile_size)-1,d0	; # of tiles
		move.b	(v_emeralds).w,d2	; do you have ANY chaos emeralds?
		beq.s	.load				; if not, branch
		lea		Art_TitCardChaosEmlds,a0											; load title card patterns
		move.l	#((Art_TitCardChaosEmlds_End-Art_TitCardChaosEmlds)/tile_size)-1,d0	; # of tiles
		cmpi.b	#emldCount,d2		; do you have all chaos	emeralds?
		bne.s	.load				; if not, branch
		lea		Art_TitCardSonic,a0													; load title card patterns
		move.l	#((Art_TitCardSonic_End-Art_TitCardSonic)/tile_size)-1,d0			; # of tiles
		jsr		(LoadUncArt).w
		lea		Art_TitCardGotThemAll,a0											; load title card patterns
		move.l	#((Art_TitCardGotThemAll_End-Art_TitCardGotThemAll)/tile_size)-1,d0	; # of tiles
		
	.load:
		jsr		(LoadUncArt).w

	; TheBlad768/AURORA☆FIELDS/RetroKoH Title Card Optimization
        lea    SSResults_UncList(pc),a1
		locVRAM	(ArtTile_Title_Card+$32)*tile_size,d1
        jsr    (LoadUncArt2).w
	; Title Card Optimization End
	
	if PerfectBonusEnabled
		lea		Art_Perfect,a0									; load title card patterns
		move.l	#((Art_Perfect_End-Art_Perfect)/tile_size)-1,d0	; # of tiles
		locVRAM ArtTile_Perfect*tile_size,d1
		jsr		(LoadUncArt).w									; load uncompressed art
	endif
	; Optimal Title Cards End

		bra.s	LoadSSBase							; Added a short branch so I could include the table below
; ===========================================================================

SSResults_UncList:
		dc.w 2-1

		dc.l Art_TitCardBonuses
		dc.w ((Art_TitCardBonuses_End-Art_TitCardBonuses)/tile_size)-1
		dc.l Art_TitCardOval
		dc.w Art_TitCardOvalCt
; ===========================================================================

LoadSSBase:
		jsr		(Hud_Base).l

	; Mercury Use DMA Queue
		ResetDMAQueue
	; Use DMA Queue End

		enable_ints
		moveq	#palid_SSResult,d0
		bsr.w	PalLoad								; load results screen palette
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		moveq	#plcid_SSResult,d0
		bsr.w	AddPLC								; load results screen patterns
		move.b	#1,(f_scorecount).w					; update score counter
		move.b	#1,(f_endactbonus).w				; update ring bonus counter
		move.w	(v_rings).w,d0
		add.w	d0,d0								; multiply by 10
		move.w	d0,d1								; Optimization from S1 in S.C.E.
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(v_ringbonus).w					; set rings bonus
		
	if PerfectBonusEnabled
		tst.w	(v_perfectringsleft).w				; did Sonic get all the rings?
		bne.s	.noperfect
		move.w	#PerfectScore,(v_perfectbonus).w	; set perfect bonus
	.noperfect:
	endif

	if ~~AmbienceMode
		move.w	#bgm_GotThrough,d0
		bsr.w	QueueSound2							; play end-of-level music
	endif

		clearRAM v_objspace							; clear object RAM

		_move.l	#SSResult,(v_ssrescard+obAddr).w	; load results screen object

	if HUDInSpecialStage
		clr.b	(f_levelstarted).w					; remove HUD
	endif

SS_NormalExit:
		bsr.w	PauseGame
		move.b	#$C,(v_vbla_routine).w
		bsr.w	WaitForVBla
		addq.w	#1,(v_framecount).w					; add 1 to level timer (now used for emerald flickering)
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	RunPLC
		tst.b	(f_restart).w
		beq.s	SS_NormalExit
		tst.l	(v_plc_buffer).w
		bne.s	SS_NormalExit
		move.w	#sfx_EnterSS,d0
		bsr.w	QueueSound2							; play special stage exit sound
		bra.w	PaletteWhiteOut
; ===========================================================================

SS_ToSegaScreen:
		move.b	#id_Sega,(v_gamemode).w				; goto Sega screen
		rts

SS_ToLevel:	; Check if branch to this is needed
		cmpi.b	#id_Level,(v_gamemode).w
		beq.s	SS_ToSegaScreen
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Special stage	background loading subroutine
; ---------------------------------------------------------------------------

; Fish/bird dimensions in cells
fish_width:		equ 8
fish_height:	equ 8
sizeof_fish:	equ fish_width*fish_height*2

SS_BGLoad:
		lea		(v_ssbuffer1&$FFFFFF).l,a1			; buffer
		lea		(Eni_SSBg1).l,a0					; load mappings for the birds and fish
		move.w	#make_art_tile(ArtTile_SS_Background_Fish,2,0),d0	; add this to each tile
		bsr.w	EniDec								; decompress fish/bird mappings to RAM

		locVRAM	ArtTile_SS_Plane_1*tile_size+plane_size_64x32,d3	; d3 = VDP address in VRAM
		lea		((v_ssbuffer1+$80)&$FFFFFF).l,a2
		moveq	#7-1,d7								; $5000, $6000, $7000, $8000, $9000, $A000, $B000

; Each frame of bird/fish animation is stored as a canvas in VRAM. The game switches between them by changing the bg nametable register.
	.loop_canvas:
		move.l	d3,d0								; copy VDP command
		moveq	#3,d6								; number of rows visible
		moveq	#0,d4								; first square is blank (i.e. blank-bird-blank-bird-etc.)
		cmpi.w	#3,d7								; $8000
		bhs.s	.loop_rows							; branch if canvas is bird
		moveq	#1,d4								; first square is fish (i.e. fish-blank-fish-blank-etc.)

	.loop_rows:
		moveq	#7,d5								; number of squares in a row (8)

	.loop_birdfish:
		movea.l	a2,a1								; get address of tilemap as stored in RAM
		eori.b	#1,d4								; switch between blank square and bird/fish
		bne.s	.is_birdfish						; branch if set to bird/fish
		cmpi.w	#6,d7
		bne.s	.skip_birdfish						; branch if not first frame

		lea		(v_ssbuffer1&$FFFFFF).l,a1			; use tilemap for checkerboard pattern

	.is_birdfish:
		movem.l	d0-d4,-(sp)
		moveq	#8-1,d1
		moveq	#8-1,d2
		bsr.w	TilemapToVRAM						; copy tilemap for 1 bird or fish from RAM to VRAM
		movem.l	(sp)+,d0-d4

	.skip_birdfish:
		addi.l	#(fish_width*2)<<16,d0				; skip 8 cells ($10 bytes)
		dbf		d5,.loop_birdfish					; repeat for all squares in 1 row

		addi.l	#((fish_height-1)*$80)<<16,d0		; skip 7 rows ($380 byes)
		eori.b	#1,d4								; stagger blank/birdfish pattern
		dbf		d6,.loop_rows						; repeat for all rows (4 in total)

		addi.l	#$1000<<16,d3						; add $1000 to VRAM address
		bpl.s	.vdp_ok								; branch if valid VDP command
		swap	d3
		addi.l	#$C000,d3							; fix VDP command
		swap	d3

	.vdp_ok:
		adda.w	#sizeof_fish,a2						; read from next tilemap
		dbf		d7,.loop_canvas						; repeat for all canvases

		lea		(v_ssbuffer1&$FFFFFF).l,a1
		lea		(Eni_SSBg2).l,a0					; load mappings for clouds/bubbles
		move.w	#make_art_tile(ArtTile_SS_Background_Clouds,2,0),d0
		bsr.w	EniDec								; decompress to buffer in RAM

		; copy tilemap for bubbles to VRAM
		copyTilemap	v_ssbuffer1&$FFFFFF,ArtTile_SS_Plane_5*tile_size,64,32

		; copy tilemap for clouds to VRAM
		copyTilemap	v_ssbuffer1&$FFFFFF,ArtTile_SS_Plane_5*tile_size+plane_size_64x32,64,64
		rts	
; End of function SS_BGLoad
; ===========================================================================

; ---------------------------------------------------------------------------
; Special Stage palette cycling and background animation routine
; ---------------------------------------------------------------------------

PalCycle_SS:
		tst.b	(f_pause).w							; is game paused?
		bne.s	.exit								; if yes, branch
		subq.w	#1,(v_palss_time).w					; decrement timer
		bpl.s	.exit								; branch if time remains

		lea		(vdp_control_port).l,a6
		move.w	(v_palss_num).w,d0					; get cycle index counter
		addq.w	#1,(v_palss_num).w					; increment
		andi.w	#$1F,d0								; read only bits 0-4
		lsl.w	#2,d0								; multiply by 4
		lea		SS_Timing_Values(pc),a0
		adda.w	d0,a0

	; Time
		move.b	(a0)+,d0
		bpl.s	.use_time
		move.w	#$1FF,d0

	.use_time:
		move.w	d0,(v_palss_time).w					; set time until next palette change

	; Anim
		moveq	#0,d0
		move.b	(a0)+,d0							; get bg mode byte
		move.w	d0,(v_ssbganim).w
		lea		(SS_BG_Modes).l,a1
		adda.w	d0,a1								; jump to mode data (HAME: Replace lea instruction)

	; FG VRAM
		move.w	#$8200,d0							; VDP register - fg nametable address (vdp_fg_nametable)
		move.b	(a1)+,d0							; apply address from mode data
		move.w	d0,(a6)								; send VDP instruction
		
	; Y coordinate
		move.b	(a1),(v_scrposy_vdp).w				; get byte to send to VSRAM

	; BG VRAM
		move.w	#$8400,d0							; VDP register - bg nametable address (vdp_bg_nametable)
		move.b	(a0)+,d0							; apply address from list
		move.w	d0,(a6)								; send VDP instruction
		move.l	#$40000010,(vdp_control_port).l		; set VDP to VSRAM write mode
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l	; update VSRAM

	; Palette cycle index
		moveq	#0,d0
		move.b	(a0)+,d0							; get palette offset
		bmi.s	PalCycle_SS_2						; branch if $80+
		lea		(Pal_SSCyc1).l,a1					; use palette cycle set 1
		adda.w	d0,a1
		lea		(v_palette+$4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+							; write palette

.exit:
		rts	
; ===========================================================================

PalCycle_SS_2:
		move.w	(v_palss_index).w,d1				; Doesn't seem to ever be modified... this is always 0
		cmpi.w	#$8A,d0								; is offset $80-$89?
		blo.s	.offset_80_89
		addq.w	#1,d1

	.offset_80_89:
		mulu.w	#$2A,d1								; d1 = always 0 or $2A
		lea		(Pal_SSCyc2).l,a1					; use palette cycle set 2
		adda.w	d1,a1
		andi.w	#$7F,d0								; ignore bit 7

		bclr	#0,d0								; clear bit 0
		beq.s	.offset_even						; branch if already clear
		lea		(v_palette+$6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+							; write palette

	.offset_even:
		adda.w	#$C,a1
		lea		(v_palette+$5A).w,a2
		cmpi.w	#$A,d0								; is offset 0-8?
		blo.s	.offset_0_8							; if yes, branch
		subi.w	#$A,d0
		lea		(v_palette+$7A).w,a2

	.offset_0_8:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0								; multiply d0 by 3
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+							; write palette
		rts	
; End of function PalCycle_SS
; ===========================================================================

; time until next, bg mode, bg namespace address in VRAM, palette offset & flags
SSBGData:	macro time,anim,vram,index,flag1,flag2
		dc.b	(time), (anim), ((vram)*tile_size)>>13
	if flag1
		dc.b	(index)|$80|(flag2)
	else
		dc.b	(index)*12
	endif
		endm

SS_Timing_Values:
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

SS_BG_Modes:
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

SS_BGAnimate:
		move.w	(v_ssbganim).w,d0					; get frame for fish/bird animation
		bne.s	.not_0								; branch if not 0
		clr.w	(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w	; reset vertical scroll for bubble/cloud layer

	.not_0:
		cmpi.w	#8,d0
		bhs.s	SS_BGBirdCloud						; branch if d0 is 8-$C (birds and clouds)
		cmpi.w	#6,d0
		bne.s	.not_6								; branch if d0 isn't 6
		addq.w	#1,(v_bg3screenposx).w
		addq.w	#1,(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w	; scroll bubble layer

	.not_6:
		moveq	#0,d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
		swap	d0
		lea		(SS_Bubble_WobbleData).l,a1
		lea		(v_ngfx_buffer).w,a3				; v_ss_bubble_x_pos
		moveq	#9,d3

SS_BGWobbleLoop:
		move.w	2(a3),d0							; get next value from buffer
		bsr.w	CalcSine							; convert to sine
		moveq	#0,d2
		move.b	(a1)+,d2							; read 1st byte
		muls.w	d2,d0								; multiply by sine
		asr.l	#8,d0								; divide by $10
		move.w	d0,(a3)+							; write to 1st word of buffer
		move.b	(a1)+,d2							; read 2nd byte
		ext.w	d2
		add.w	d2,(a3)+							; add to 2nd word of buffer
		dbf		d3,SS_BGWobbleLoop

		lea		(v_ngfx_buffer).w,a3				; v_ss_bubble_x_pos
		lea		(SS_Bubble_ScrollBlocks).l,a2
		bra.s	SS_Scroll_CloudsBubbles
; ===========================================================================

SS_BGBirdCloud:
		cmpi.w	#$C,d0
		bne.s	.not_C								; branch if d0 isn't $C
		subq.w	#1,(v_bg3screenposx).w
		lea		(v_ssscroll_buffer).w,a3			; v_ss_cloud_x_pos
		move.l	#$18000,d2
		moveq	#7-1,d1

	.loop:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf		d1,.loop

	.not_C:
		lea		(v_ssscroll_buffer).w,a3			; v_ss_cloud_x_pos
		lea		(SS_Cloud_ScrollBlocks).l,a2

SS_Scroll_CloudsBubbles:
		lea		(v_hscrolltablebuffer).w,a1
		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	(v_bgscreenposy).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

	.loop_block:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

	.loop_line:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf		d1,.loop_line
		dbf		d3,.loop_block
		rts	
; End of function SS_BGAnimate
; ===========================================================================

SS_Bubble_ScrollBlocks:	dc.b 9,	$28, $18, $10, $28, $18, $10, $30, $18,	8, $10,	0
		even
SS_Cloud_ScrollBlocks:	dc.b 6,	$30, $30, $30, $28, $18, $18, $18
		even
SS_Bubble_WobbleData:	dc.b 8,	2, 4, $FF, 2, 3, 8, $FF, 4, 2, 2, 3, 8,	$FD, 4,	2, 2, 3, 2, $FF
		even
; ===========================================================================