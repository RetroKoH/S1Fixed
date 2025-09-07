; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound2 ; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		disable_ints
		; Removed call to old Sound Driver (This call was redundant anyway)
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)					; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#$9001,(a6)					; 64-cell hscroll size
		move.w	#$9200,(a6)					; window vertical position
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)					; set background colour (palette line 2, entry 0)
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

	if HUDScrolling=1
		clr.w	(f_levelstarted).w		; clear flag AND HUD scrolling byte -- RetroKoH S3K Rings Manager
	else
		clr.b	(f_levelstarted).w		; clear flag -- RetroKoH S3K Rings Manager
	endif

	if SaveProgressMod=1
		clr.b	(f_levsel_active).w
	endif

		clearRAM v_ringpos,v_ringspace_end	; clear ring RAM -- RetroKoH S3K Rings Manager
		clearRAM v_objspace					; clear object RAM

		locVRAM	ArtTile_Title_Japanese_Text*tile_size
		lea		(Nem_JapNames).l,a0			; load Japanese credits
		bsr.w	NemDec
		locVRAM	ArtTile_Sonic_Team_Font*tile_size
		lea		(Nem_CreditText).l,a0		; load alphabet
		bsr.w	NemDec
		lea		(v_128x128&$FFFFFF).l,a1
		lea		(Eni_JapNames).l,a0			; load mappings for Japanese credits
		move.w	#make_art_tile(ArtTile_Title_Japanese_Text,0,FALSE),d0
		bsr.w	EniDec

		copyTilemap	v_128x128&$FFFFFF,vram_fg,40,28

		clearRAM v_palette_fading

		moveq	#palid_Sonic,d0					; load Sonic's palette
		bsr.w	PalLoad_Fade
		move.b	#id_CreditsText,(v_sonicteam).w	; load "SONIC TEAM PRESENTS" object
		jsr		(ExecuteObjects).l
		jsr		(BuildSprites).l
		bsr.w	PaletteFadeIn
		disable_ints
		locVRAM	ArtTile_Title_Foreground*tile_size
		lea		(Nem_TitleFg).l,a0				; load title screen patterns
		bsr.w	NemDec
		; Removed Title Sonic Decompression (now loads via DPLCs)
		locVRAM	ArtTile_Title_Trademark*tile_size
		lea		(Nem_TitleTM).l,a0				; load "TM" patterns
		bsr.w	NemDec

	if NewLevelSelect=0
		lea		(vdp_data_port).l,a6
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6)
		lea		(Art_Text).l,a5					; load level select font
		move.w	#(Art_Text_End-Art_Text)/2-1,d1

Tit_LoadText:
		move.w	(a5)+,(a6)
		dbf		d1,Tit_LoadText				; load level select font
	endif
		
		; Due to removing part of the pattern loading process, we should
		; add a timer to wait out the SONIC TEAM PRESENTS TEXT

		moveq	#0,d0
		move.b	d0,(f_nobgscroll).w			; Mercury Game Over When Drowning Fix
		move.b	d0,(v_lastlamp).w			; clear lamppost counter
		move.w	d0,(v_debuguse).w			; disable debug item placement mode
		move.w	d0,(f_demo).w				; disable debug mode
		move.w	d0,(v_zone).w				; set zone/act to GHZ (00)
		move.w	d0,(v_pcyc_time).w			; disable palette cycling
		bsr.w	LevelSizeLoad
		bsr.w	DeformLayers

	if BlocksInROM=1	;Mercury Blocks In ROM
		move.l	#Blk16_GHZ,(v_16x16).l		; store the ROM address for the block mappings
	else
		lea		(v_16x16).w,a1				; address to load decompressed blocks to
		lea		(Blk16_GHZ).l,a0			; load GHZ 16x16 mappings
		move.w	#make_art_tile(ArtTile_Level,0,FALSE),d0
		bsr.w	EniDec
	endif

	if ChunksInROM=1	;Mercury Chunks In ROM
		move.l	#Blk128_GHZ,(v_128x128).l	; store the ROM address for the chunk mappings
	else
		lea		(Blk128_GHZ).l,a0			; load GHZ 128x128 mappings
		lea		(v_128x128&$FFFFFF).l,a1	; address to load decompressed chunks to
		bsr.w	KosDec
	endif

		bsr.w	LevelLayoutLoad
		bsr.w	PaletteFadeOut
		disable_ints
		bsr.w	ClearScreen
		lea		(vdp_control_port).l,a5
		lea		(vdp_data_port).l,a6
		lea		(v_bgscreenposx).w,a3
		lea		(v_lvllayout+$80).w,a4		; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	DrawChunks

	if ChunksInROM=1	;Mercury Chunks In ROM
		copyTilemap	Eni_Title,vram_fg+$208,34,22			; RetroKoH Title Screen Adjustment
	else
		lea		(v_128x128&$FFFFFF).l,a1					; address to load decompressed chunks to
		lea		(Eni_Title).l,a0							; load title screen mappings
		clr.w	d0
		bsr.w	EniDec

		copyTilemap	v_128x128&$FFFFFF,vram_fg+$208,34,22	; RetroKoH Title Screen Adjustment
	endif

		locVRAM	ArtTile_Level*tile_size
		lea		(Nem_Title).l,a0						; load Title Screen patterns -- Clownacy S2 Level Art Loading
		bsr.w	NemDec
		moveq	#palid_GHZ,d0							; load GHZ palette first -- RetroKoH Title Screen Adjustment
		bsr.w	PalLoad_Fade
		moveq	#palid_Title,d0							; overwrite first 2 lines w/ title screen palette
		bsr.w	PalLoad_Fade

	if ~~AmbienceMode
		move.b	#bgm_Title,d0
		bsr.w	QueueSound2								; play title screen music
	endif

		clr.b	(f_debugmode).w							; disable debug mode
		move.w	#$178,(v_demolength).w					; run title screen for $178 frames

		clearRAM v_sonicteam,v_sonicteam+object_size	; PRESS START BUTTON Fix (Quickman)
		move.b	#id_TitleSonic,(v_titlesonic).w			; load big Sonic object
		move.b	#id_PSBTM,(v_pressstart).w				; load "PRESS START BUTTON" object

		tst.b   (v_megadrive).w							; is console Japanese?
		bpl.s   .isjap									; if yes, branch
		move.b	#id_PSBTM,(v_titletm).w					; load "TM" object
		move.b	#3,(v_titletm+obFrame).w
.isjap:
		move.b	#id_PSBTM,(v_ttlsonichide).w			; load object which hides part of Sonic
		move.b	#2,(v_ttlsonichide+obFrame).w
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		moveq	#plcid_Main,d0
		bsr.w	NewPLC
		clr.w	(v_title_dcount).w
		clr.w	(v_title_ccount).w
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

		include	"_screens/Title Screen Loop.asm"

	if NewLevelSelect
		include "_screens/Level Select (S2).asm"
	else
		include "_screens/Level Select (S1).asm"
	endif

		include "_inc/ASCII Render Text.asm"

PlayLevel:
		move.b	#id_Level,(v_gamemode).w	; set screen mode to $0C (level)
		bsr.s	ResetLevel					; Reset level variables

	if SaveProgressMod=1
		tst.b	(f_levsel_active).w
		bne.s	.nosaving

		gotoSRAM							; Enable SRAM writing
	if AddressSRAM=3
		; no need to change this by yourself anymore -- Starleaf
		lea 	($200009).l,a1				; Base of usable SRAM
	else
		lea		($200008).l,a1				; Base of usable SRAM
	endif

	; reset stored values (cannot do directly) -- d0 was zeroed out in ResetLevel
		move.b	#1,sram_init(a1) 		; init SRAM data
		movep.w	d0,sram_zone(a1)		; clear saved zone and act
		movep.l	d0,sram_score(a1)		; clear saved score
		move.b	d0,sram_lastspecial(a1)	; clear saved special stage number
		movep.w	d0,sram_emeralds(a1)	; clear saved emerald count and bitfield
		move.b	d0,sram_continues(a1)	; clear saved continues

		move.b	(v_lives).w,d0
		move.b	d0,sram_lives(a1)		; reset saved lives count
		move.l	(v_scorelife).w,d0
		movep.l	d0,sram_scorelife(a1)	; reset saved extra life target score
	
		move.b	d0,(sram_port).l		; Disable SRAM writing

	.nosaving:
	endif

		move.b	#bgm_Fade,d0
		bra.w	QueueSound2				; fade out music	
; ===========================================================================

ResetLevel:
		moveq	#0,d0
		move.b	#3,(v_lives).w			; set lives to 3
		move.w	d0,(v_rings).w			; clear rings
		move.l	d0,(v_time).w			; clear time
		move.l	d0,(v_score).w			; clear score
		move.b	d0,(v_lastspecial).w	; clear special stage number
		move.b	d0,(v_emeralds).w		; clear emerald count
		move.b	d0,(v_emldlist).w		; clear emerald array
		move.b	d0,(v_continues).w		; clear continues
		move.l	#5000,(v_scorelife).w	; extra life is awarded at 50000 points

	if CoolBonusEnabled
		move.b	#10,(v_hitscount).w			; set hits count for cool bonus
	endif

		rts
; ===========================================================================

	if SaveProgressMod=1
PlayLevel_Load:
		gotoSRAM							; Enable SRAM writing
	if AddressSRAM=3
		; no need to change this by yourself anymore -- Starleaf
		lea 	($200009).l,a1				; Base of usable SRAM
	else
		lea		($200008).l,a1				; Base of usable SRAM
	endif

		movep.w	sram_zone(a1),d0
		move.w	d0,(v_zone).w				; load saved zone and act
		move.b	sram_lives(a1),d0
		move.b	d0,(v_lives).w				; load saved lives count
		movep.l	sram_score(a1),d0
		move.l	d0,(v_score).w				; load score
		movep.l	sram_scorelife(a1),d0
		move.l	d0,(v_scorelife).w			; load extra life target score
		move.b	sram_lastspecial(a1),d0
		move.b	d0,(v_lastspecial).w		; load special stage number
		movep.w	sram_emeralds(a1),d0
		move.w	d0,(v_emeralds).w			; load emerald count and bitfield
		move.b	sram_continues(a1),d0
		move.b	d0,(v_continues).w			; load continues
		
		moveq	#0,d0
		move.b	d0,(sram_port).l			; Disable SRAM writing

	; everything else can be reset like normal
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		
		move.b	#id_Level,(v_gamemode).w	; set screen mode to $0C (level)
	
	if CoolBonusEnabled
		move.b	#10,(v_hitscount).w			; set hits count for cool bonus
	endif

		move.b	#bgm_Fade,d0
		bra.w	QueueSound2					; fade out music
	endif

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

GotoDemo:
		move.w	#$1E,(v_demolength).w

loc_33B6:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	DeformLayers
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		move.w	(v_player+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_player+obX).w
		cmpi.w	#$1C00,d0
		blo.s	loc_33E4
		move.b	#id_Sega,(v_gamemode).w
		rts	
; ===========================================================================

loc_33E4:
		andi.b	#btnStart,(v_jpadpress1).w	; is Start button pressed?
		bne.w	Tit_ChkLevSel				; if yes, branch
		tst.w	(v_demolength).w
		bne.w	loc_33B6
		move.b	#bgm_Fade,d0
		bsr.w	QueueSound2					; fade out music
		move.w	(v_demonum).w,d0			; load demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0		; load level number for	demo
		move.w	d0,(v_zone).w
		moveq	#0,d1						; use d1 for optimal clearing
		addq.w	#1,(v_demonum).w			; add 1 to demo number
		cmpi.w	#4,(v_demonum).w			; is demo number less than 4?
		blo.s	loc_3422					; if yes, branch
		move.w	d1,(v_demonum).w			; reset demo number to 0

loc_3422:
		move.w	#1,(f_demo).w				; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w		; set screen mode to 08 (demo)
		cmpi.w	#$600,d0					; is level number 0600 (special	stage)?
		bne.s	Demo_Level					; if not, branch
		move.b	#id_Special,(v_gamemode).w	; set screen mode to $10 (Special Stage)
		move.w	d1,(v_zone).w				; clear	level number
		move.b	d1,(v_lastspecial).w		; clear special stage number

Demo_Level:
		move.b	#3,(v_lives).w				; set lives to 3
		move.w	d1,(v_rings).w				; clear rings
		move.l	d1,(v_time).w				; clear time
		move.l	d1,(v_score).w				; clear score
		move.l	#5000,(v_scorelife).w		; extra life is awarded at 50000 points
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------
Demo_Levels:	binclude	"misc/Demo Level Order - Intro.bin"
		even