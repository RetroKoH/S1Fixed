; ---------------------------------------------------------------------------
; SRAM Error screen
; Based on the SRAM Error Screen from Super Challenges
; ---------------------------------------------------------------------------

GM_SRAMError:
		move.b	#bgm_Stop,d0
		bsr.w	QueueSound2 ; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)	; use 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6) ; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6) ; set background nametable address
		move.w	#$8700,(a6)	; set background colour (palette entry 0)
		move.w	#$8B00,(a6)	; full-screen vertical scrolling
		clr.b	(f_wtr_state).w
		bsr.w	ClearScreen

; load ment text font
		lea		(vdp_data_port).l,a6
		locVRAM	ArtTile_Level_Select_Font*tile_size,4(a6)
		lea		(Art_Text).l,a5	; load level select font
		move.w	#(Art_Text_End-Art_Text)/2-1,d1

.loadfont:
		move.w	(a5)+,(a6)
		dbf		d1,.loadfont	; load level select font

		moveq	#0,d1
		lea		TextData_ErrorHeading(pc),a1 ; where to fetch the lines from
		move.l	#$41060003,4(a6)	; starting screen position 

	; Set palette line based on menu style option
	if NewLevelSelect
		move.w	#$A680,d3	; which palette the font should use and where it is in VRAM
	else
		move.w	#$E680,d3	; which palette the font should use and where it is in VRAM
	endif

		moveq	#33,d2		; number of characters to be rendered in a line -1
		bsr.w	ASCText_RenderLine

		moveq	#0,d1
		lea		TextData_ErrorBody(pc),a1 ; where to fetch the lines from
		move.l	#$43060003,d4	; starting screen position 

		moveq	#18,d1		; number of lines of text to be displayed -1

.nextline:
		move.l	d4,4(a6)
		moveq	#33,d2		; number of characters to be rendered in a line -1
		bsr.w	ASCText_RenderLine
		addi.l	#(1*$800000),d4  ; replace number to the left with desired distance between each line
		dbf		d1,.nextline

.loadpal:
		moveq	#palid_LevelSel,d0
		bsr.w	PalLoad_Fade	; load level select palette

		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn

SRAMError_Main:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla

		move.b	(v_jpadpress1).w,d0 ; fetch commands
		andi.b	#btnStart,d0
		beq.s	SRAMError_Main

        move.b	#id_Title,(v_gamemode).w ; => Title Screen		
		rts

		bra.s	SRAMError_Main	
; ===========================================================================

TextData_ErrorHeading:
		dc.b	"   WARNING - NO SRAM DETECTED!!   "
		
TextData_ErrorBody:
		dc.b	"IT HAS BEEN DETECTED THAT SRAM    "
		dc.b	"(BATTERY BACKUP TO SAVE YOUR DATA)"
		dc.b	"ISN'T INITIALIZED.                "
		dc.b	"                                  "
		dc.b	"THIS ROM HACK RELIES ON IT TO SAVE"
		dc.b	"YOUR CURRENT PROGRESS. GIVEN THAT "
		dc.b	"IT'S NOT LOADED PROPERLY, PROGRESS"
		dc.b	"AND DATA WILL NOT BE SAVED UPON   "
		dc.b	"RESET.                            "
		dc.b	"                                  "
		dc.b	"PLEASE CHECK YOUR EMULATOR'S      "
		dc.b	"SETTINGS TO SEE IF SRAM IS ENABLED"
		dc.b	"AND WORKING, OR CHECK THE MANUAL  "
		dc.b	"OF YOUR FLASHCART TO SEE IF IT    "
		dc.b	"SUPPORTS SRAM.                    "
		dc.b	"                                  "
		dc.b	"           0123456789             "
		dc.b	"                                  "
		dc.b	"     PRESS START TO CONTINUE      "
; ===========================================================================