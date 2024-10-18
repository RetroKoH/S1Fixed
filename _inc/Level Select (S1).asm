; ---------------------------------------------------------------------------
; Level	Select
; ---------------------------------------------------------------------------

; Activate Level Select
Tit_LevSel:
; (MarkeyJester) https://info.sonicretro.org/SCHG_How-to:Fix_the_Level_Select_graphics_bug
		move.b	#4,(v_vbla_routine).w		; This should fix the Level Select strip glitch
		bsr.w	WaitForVBla
; I go with this, instead of the "proper" fix, because I plan to add an option to change the backgrounds on the title screen

		moveq	#palid_LevelSel,d0
		bsr.w	PalLoad						; load level select palette

		clearRAM v_hscrolltablebuffer

		move.l	d0,(v_scrposy_vdp).w
		disable_ints
		lea		(vdp_data_port).l,a6
		locVRAM	vram_bg
		move.w	#plane_size_64x32/4-1,d1

Tit_ClrScroll2:
		move.l	d0,(a6)
		dbf		d1,Tit_ClrScroll2			; clear scroll data (in VRAM)

		bsr.w	LevSelTextLoad

	if SaveProgressMod=1
		move.b	#1,(f_levsel_active).w
	endif

LevelSelect:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.w	LevSelControls
		bsr.w	RunPLC
		tst.l	(v_plc_buffer).w
		bne.s	LevelSelect
		andi.b	#btnABC+btnStart,(v_jpadpress1).w	; is A, B, C, or Start pressed?
		beq.s	LevelSelect							; if not, branch
		move.w	(v_levselitem).w,d0
		cmpi.w	#$14,d0								; have you selected item $14 (sound test)?
		bne.s	LevSel_Level						; if not, go to	Level/SS subroutine
		move.w	(v_levselsound).w,d0
		tst.b	(f_creditscheat).w					; is Japanese Credits cheat on?
		beq.s	LevSel_PlaySnd						; if not, branch
		cmpi.w	#$9F,d0								; is sound $9F being played?
		beq.s	LevSel_Ending						; if yes, branch
		cmpi.w	#$9E,d0								; is sound $9E being played?
		beq.s	LevSel_Credits						; if yes, branch

; Error check removed following bugfix
LevSel_PlaySnd:
		bsr.w	PlaySound_Special
		bra.s	LevelSelect
; ===========================================================================

LevSel_Ending:
		move.b	#id_Ending,(v_gamemode).w	; set screen mode to $18 (Ending)
		move.w	#(id_EndZ<<8),(v_zone).w	; set level to 0600 (Ending)
		rts	
; ===========================================================================

LevSel_Credits:
		move.b	#id_Credits,(v_gamemode).w ; set screen mode to $1C (Credits)
		move.b	#mus_Credits,d0
		bsr.w	PlaySound_Special ; play credits music
		clr.w	(v_creditsnum).w
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select - level pointers
; ---------------------------------------------------------------------------
LevSel_Ptrs:
	if BetaLevelOrder=1
		dc.b id_GHZ, 0
		dc.b id_GHZ, 1
		dc.b id_GHZ, 2
		dc.b id_LZ, 0
		dc.b id_LZ, 1
		dc.b id_LZ, 2
		dc.b id_MZ, 0
		dc.b id_MZ, 1
		dc.b id_MZ, 2
		dc.b id_SLZ, 0
		dc.b id_SLZ, 1
		dc.b id_SLZ, 2
		dc.b id_SYZ, 0
		dc.b id_SYZ, 1
		dc.b id_SYZ, 2
		dc.b id_SBZ, 0
		dc.b id_SBZ, 1
		dc.b id_LZ, 3
		dc.b id_SBZ, 2
		dc.b id_SS, 0		; Special Stage
		dc.w $8000			; Sound Test
		even
	else
		dc.b id_GHZ, 0
		dc.b id_GHZ, 1
		dc.b id_GHZ, 2
		dc.b id_MZ, 0
		dc.b id_MZ, 1
		dc.b id_MZ, 2
		dc.b id_SYZ, 0
		dc.b id_SYZ, 1
		dc.b id_SYZ, 2
		dc.b id_LZ, 0
		dc.b id_LZ, 1
		dc.b id_LZ, 2
		dc.b id_SLZ, 0
		dc.b id_SLZ, 1
		dc.b id_SLZ, 2
		dc.b id_SBZ, 0
		dc.b id_SBZ, 1
		dc.b id_LZ, 3
		dc.b id_SBZ, 2
		dc.b id_SS, 0		; Special Stage
		dc.w $8000			; Sound Test
		even
	endif
; ===========================================================================

LevSel_Level:
		add.w	d0,d0
		move.w	LevSel_Ptrs(pc,d0.w),d0		; load level number
		bmi.w	LevelSelect
		cmpi.w	#id_SS*$100,d0				; check	if level is 0700 (Special Stage)
		bne.s	LevSel_NotSpecial			; if not, branch
		move.b	#id_Special,(v_gamemode).w	; set screen mode to $10 (Special Stage)
	;	tst.b	(f_debugcheat).w			; has debug cheat been entered?
	;	beq.s	.nodebug					; if not, branch
	;	btst	#bitA,(v_jpadhold1).w		; is A button held?
	;	beq.s	.nodebug					; if not, branch
		move.b	#1,(f_debugmode).w			; enable debug mode
.nodebug:
		bsr.w	ResetLevel					; reset level variables
		move.w	d0,(v_zone).w				; also clear current zone (start at GHZ 1 after the Special Stage)
		rts	
; ===========================================================================

LevSel_NotSpecial:
		andi.w	#$3FFF,d0
		move.w	d0,(v_zone).w			; set level number
	;	tst.b	(f_debugcheat).w		; has debug cheat been entered?
	;	beq.s	PlayLevel				; if not, branch
	;	btst	#bitA,(v_jpadhold1).w	; is A button held?
	;	beq.s	PlayLevel				; if not, branch
		move.b	#1,(f_debugmode).w		; enable debug mode
		bra.w	PlayLevel				; added branch because I consolidated all level select code/data to this file
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	change what you're selecting in the level select
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSelControls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnUp+btnDn,d1	; is up/down pressed and held?
		bne.s	LevSel_UpDown	; if yes, branch
		subq.w	#1,(v_levseldelay).w ; subtract 1 from time to next move
		bpl.s	LevSel_SndTest	; if time remains, branch

LevSel_UpDown:
		move.w	#$B,(v_levseldelay).w ; reset time delay
		move.b	(v_jpadhold1).w,d1
		andi.b	#btnUp+btnDn,d1	; is up/down pressed?
		beq.s	LevSel_SndTest	; if not, branch
		move.w	(v_levselitem).w,d0
		btst	#bitUp,d1	; is up	pressed?
		beq.s	LevSel_Down	; if not, branch
		subq.w	#1,d0		; move up 1 selection
		bhs.s	LevSel_Down
		moveq	#$14,d0		; if selection moves below 0, jump to selection	$14

LevSel_Down:
		btst	#bitDn,d1	; is down pressed?
		beq.s	LevSel_Refresh	; if not, branch
		addq.w	#1,d0		; move down 1 selection
		cmpi.w	#$15,d0
		blo.s	LevSel_Refresh
		moveq	#0,d0		; if selection moves above $14,	jump to	selection 0

LevSel_Refresh:
		move.w	d0,(v_levselitem).w ; set new selection
		bra.s	LevSelTextLoad	; refresh text
; ===========================================================================

LevSel_SndTest:
		cmpi.w	#$14,(v_levselitem).w	; is item $14 selected?
		bne.s	LevSel_NoMove			; if not, branch
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnR+btnL,d1			; is left/right	pressed?
		beq.s	LevSel_NoMove			; if not, branch
		move.w	(v_levselsound).w,d0
		btst	#bitL,d1				; is left pressed?
		beq.s	LevSel_Right			; if not, branch
		subq.w	#1,d0					; subtract 1 from sound	test
		bhs.s	LevSel_Right
		moveq	#$4F,d0					; if sound test	moves below 0, set to $4F

LevSel_Right:
		btst	#bitR,d1				; is right pressed?
		beq.s	LevSel_Refresh2			; if not, branch
		addq.w	#1,d0					; add 1	to sound test
		cmpi.w	#$50,d0
		blo.s	LevSel_Refresh2
		moveq	#0,d0					; if sound test	moves above $4F, set to	0

LevSel_Refresh2:
		move.w	d0,(v_levselsound).w	; set sound test number
		bra.s	LevSelTextLoad			; refresh text

LevSel_NoMove:
		rts	
; End of function LevSelControls

; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSelTextLoad:

textpos:	= ($40000000+(($E210&$3FFF)<<16)+(($E210&$C000)>>14))
					; $E210 is a VRAM address

		lea		(LevelMenuText).l,a1
		lea		(vdp_data_port).l,a6
		move.l	#textpos,d4	; text position on screen
		move.w	#$E680,d3	; VRAM setting (4th palette, $680th tile)
		moveq	#$14,d1		; number of lines of text

LevSel_DrawAll:
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine	; draw line of text
		addi.l	#$800000,d4	; jump to next line
		dbf		d1,LevSel_DrawAll

		moveq	#0,d0
		move.w	(v_levselitem).w,d0
		move.w	d0,d1
		move.l	#textpos,d4
		lsl.w	#7,d0
		swap	d0
		add.l	d0,d4
		lea		(LevelMenuText).l,a1
		lsl.w	#3,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		adda.w	d1,a1
		move.w	#$C680,d3		; VRAM setting (3rd palette, $680th tile)
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine	; recolour selected line
		move.w	#$E680,d3
		cmpi.w	#$14,(v_levselitem).w
		bne.s	LevSel_DrawSnd
		move.w	#$C680,d3

LevSel_DrawSnd:
		locVRAM	vram_bg+$C30			; sound test position on screen
		move.w	(v_levselsound).w,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.w	LevSel_ChgSnd			; draw 1st digit
		move.b	d2,d0
		bra.w	LevSel_ChgSnd			; draw 2nd digit
; End of function LevSelTextLoad


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSel_ChgSnd:
		andi.w	#$F,d0
		cmpi.b	#$A,d0		; is digit $A-$F?
		blo.s	LevSel_Numb	; if not, branch
		addq.b	#4,d0		; use alpha characters (was 7) -- Soulless Sentinel Level Select ASCII Mod

LevSel_Numb:
		add.w	d3,d0
		move.w	d0,(a6)
		rts	
; End of function LevSel_ChgSnd


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSel_ChgLine:
		moveq	#$17,d2			; number of characters per line

LevSel_LineLoop:
		moveq	#0,d0
		move.b	(a1)+,d0		; get character
		bpl.s	LevSel_CharOk	; branch if valid
		move.w	#0,(a6)			; use blank character
		dbf		d2,LevSel_LineLoop
		rts	

; Soulless Sentinel Level Select ASCII Mod
LevSel_CharOk:
		cmpi.w	#$40,d0		; Check for $40 (End of ASCII number area)
		blt.s	.notText	; If this is not an ASCII text character, branch
		subq.w	#3,d0		; Subtract an extra 3 (Compensate for missing characters in the font)
.notText:
		subi.w	#$30,d0		; Subtract #$33 (Convert to S2 font from ASCII)
		add.w	d3,d0		; combine char with VRAM setting
		move.w	d0,(a6)		; send to VRAM
		dbf		d2,LevSel_LineLoop
		rts
; End of function LevSel_ChgLine

; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select menu text -- Soulless Sentinel Level Select ASCII Mod
; ---------------------------------------------------------------------------
LevelMenuText:
	if BetaLevelOrder=1
		dc.b    "GREEN HILL ZONE  STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "LABYRINTH ZONE   STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "MARBLE ZONE      STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "STAR LIGHT ZONE  STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "SPRING YARD ZONE STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "SCRAP BRAIN ZONE STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "FINAL ZONE              "
		dc.b    "SPECIAL STAGE           "
		dc.b    "SOUND SELECT            "
		even
	else
		dc.b    "GREEN HILL ZONE  STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "MARBLE ZONE      STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "SPRING YARD ZONE STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "LABYRINTH ZONE   STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "STAR LIGHT ZONE  STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "SCRAP BRAIN ZONE STAGE 1"
		dc.b    "                 STAGE 2"
		dc.b    "                 STAGE 3"
		dc.b    "FINAL ZONE              "
		dc.b    "SPECIAL STAGE           "
		dc.b    "SOUND SELECT            "
		even
	endif
