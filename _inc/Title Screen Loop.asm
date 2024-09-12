; ---------------------------------------------------------------------------
; Title Screen Main Loop
; ---------------------------------------------------------------------------

	if SaveProgressMod=0

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		bsr.w	PalCycle_Title
		bsr.w	RunPLC
		move.w	(v_player+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_player+obX).w			; move Sonic to the right
		cmpi.w	#$1C00,d0					; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_EnterCheat				; if not, branch

		move.b	#id_Sega,(v_gamemode).w		; go to Sega screen
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select code
; ---------------------------------------------------------------------------
LevSelCode:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even
; ===========================================================================

Tit_EnterCheat:
		lea		LevSelCode(pc),a0			; load level select code
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpress1).w,d0			; get button press
		andi.b	#btnDir,d0					; read only UDLR buttons
		cmp.b	(a0),d0						; does button press match the cheat code?
		bne.s	Tit_ResetCheat				; if not, branch
		addq.w	#1,(v_title_dcount).w		; next button press
		tst.b	d0
		bne.s	Tit_CountC
		lea		(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Tit_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Tit_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)				; cheat depends on how many times C is pressed

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat
		move.b	#sfx_Ring,d0
		bsr.w	PlaySound_Special			; play ring sound when code is entered
		bra.s	Tit_CountC
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0
		beq.s	Tit_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Tit_CountC
		clr.w	(v_title_dcount).w			; reset UDLR counter

Tit_CountC:
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnC,d0					; is C button pressed?
		beq.s	Tit_CheckStartDemo			; if not, branch
		addq.w	#1,(v_title_ccount).w		; increment C counter

Tit_CheckStartDemo:
		tst.w	(v_demolength).w
		beq.w	GotoDemo
		andi.b	#btnStart,(v_jpadpress1).w	; check if Start is pressed
		beq.w	Tit_MainLoop				; if not, branch

Tit_ChkLevSel:
		tst.b	(f_levselcheat).w			; check if level select code is on
		beq.w	PlayLevel					; if not, play level
		btst	#bitA,(v_jpadhold1).w		; check if A is pressed
		beq.w	PlayLevel					; if not, play level

	else

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l
		bsr.w	PalCycle_Title
		bsr.w	RunPLC
		move.w	(v_player+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_player+obX).w			; move Sonic to the right

		cmpi.b	#4,(v_pressstart+obRoutine).w
		beq.w	Tit_NoDemo

		cmpi.w	#$1C00,d0					; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_EnterCheat				; if not, branch

		move.b	#id_Sega,(v_gamemode).w		; go to Sega screen
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select code
; ---------------------------------------------------------------------------
LevSelCode:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even
; ===========================================================================

Tit_EnterCheat:
		lea		LevSelCode(pc),a0			; load level select code
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpress1).w,d0			; get button press
		andi.b	#btnDir,d0					; read only UDLR buttons
		cmp.b	(a0),d0						; does button press match the cheat code?
		bne.s	Tit_ResetCheat				; if not, branch
		addq.w	#1,(v_title_dcount).w		; next button press
		tst.b	d0
		bne.s	Tit_CountC
		lea		(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Tit_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Tit_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)				; cheat depends on how many times C is pressed

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat
		move.b	#sfx_Ring,d0
		bsr.w	PlaySound_Special			; play ring sound when code is entered
		bra.s	Tit_CountC
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0
		beq.s	Tit_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Tit_CountC
		clr.w	(v_title_dcount).w				; reset UDLR counter

Tit_CountC:
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnC,d0						; is C button pressed?
		beq.s	Tit_CheckStartDemo				; if not, branch
		addq.w	#1,(v_title_ccount).w			; increment C counter

Tit_CheckStartDemo:
		tst.w	(v_demolength).w
		beq.w	GotoDemo

Tit_NoDemo:
		andi.b	#btnStart,(v_jpadpress1).w		; check if Start is pressed
		beq.w	Tit_MainLoop					; if not, branch

Tit_ChkLevSel:
		cmpi.b	#4,(v_pressstart+obRoutine).w	; is menu triggered?
		beq.s	Tit_MenuChoice					; if yes, Level Select can't be activated
		tst.b	(f_levselcheat).w				; otherwise, check if level select code is on
		bne.w	Tit_LevSel						; if yes, activate level select
		move.b	#4,(v_pressstart+obRoutine).w	; activate NEW/CONTINUE menu
		move.b	#4,(v_pressstart+obFrame).w
		move.b	#sfx_Lamppost,d0
		jsr		(PlaySound_Special).l			; play sfx
		bra.w	Tit_MainLoop

Tit_MenuChoice:
		moveq	#0,d0
		move.b	(v_pressstart+objoff_30).w,d0
		bne.w	PlayLevel_Load					; load previous game
		bra.w	PlayLevel						; start new game

	endif

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