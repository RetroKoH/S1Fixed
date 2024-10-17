; ---------------------------------------------------------------------------
; NEW Menu Screen for S2 Level Select
; ---------------------------------------------------------------------------
GM_MenuScreen:
		bsr.w	PaletteFadeOut
		disable_ints
		move.w	(v_vdp_buffer1).w,d0
		andi.b	#$BF,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	ClearScreen
		lea		(vdp_control_port).l,a6
		move.w	#$8004,(a6)		; H-INT disabled
		move.w	#$8230,(a6)		; PNT A base: $C000
		move.w	#$8407,(a6)		; PNT B base: $E000
		move.w	#$8230,(a6)		; PNT A base: $C000
		move.w	#$8700,(a6)		; Background palette/color: 0/0
		move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
		move.w	#$9001,(a6)		; Scroll table size: 64x32

		ResetDMAQueue			; Mercury Use DMA Queue

		; Level Select Menu Font and other related art
		locVRAM	$200
		lea	(Nem_MenuStuff).l,a0
		bsr.w	NemDec

        ; Level Select Icons - Custom for Sonic 1 Zones
		locVRAM	$1200
		lea		(Nem_LevSelIcons).l,a0
		bsr.w	NemDec

		; Background - Load mappings first, tiles will be dynamically loaded
		lea		($FF0000).l,a1
		lea		(Eni_MenuBack).l,a0 ; load SONIC/MILES mappings
		move.w	#$6000,d0
		bsr.w	EniDec
		copyTilemap	$FF0000,$E000,$28,$1C

		; Level Select Menu Tilemap (Loads text for levels to select)
		lea		($FF0000).l,a1
		lea		(Eni_LevSel).l,a0	; Level Select mappings, 2 bytes per tile
		moveq	#0,d0
		bsr.w	EniDec
		copyTilemap	$FF0000,$C000,$28,$1C

		moveq	#0,d3
		bsr.w	LevelSelect_DrawSoundNumber

		lea		($FF08C0).l,a1
		lea		(Eni_LevSelIcons).l,a0	; Level Select Icon Mappings
		move.w	#$90,d0			; Art Location of Level Select Icons
		bsr.w	EniDec
		bsr.w	LevelSelect_DrawIcon

		clr.w	(v_menuanimtimer).w
		lea		(Anim_SonicMilesBG).l,a2
		jsr		Dynamic_Menu	; background
		moveq	#palid_LevelSel,d0
		bsr.w	PalLoad_Fade
		lea		(v_palette+$40).w,a1
		lea		(v_palette_fading+$40).w,a2
		moveq	#7,d1

	.loop:
		move.l	(a1),(a2)+
		clr.l	(a1)+
		dbf		d1,.loop

		move.b	#bgm_MZ,d0
		bsr.w	PlaySound				; play Level Select Menu sound (placeholder)
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		move.w	(v_vdp_buffer1).w,d0
		ori.b	#$40,d0
		move.w	d0,(vdp_control_port).l
		bsr.w	PaletteFadeIn
		
	if SaveProgressMod=1
		move.b	#1,(f_levsel_active).w
	endif
		
LevelSelect_MainLoop:
		move.b	#$16,(v_vbla_routine).w
		bsr.w	WaitForVBla
		disable_ints
		moveq	#0,d3					; palette line << 13
		bsr.w	LevelSelect_MarkFields	; unmark fields
		bsr.w	LevSelControls			; Check to change between items
		move.w	#$6000,d3				; palette line << 13
		bsr.w	LevelSelect_MarkFields	; mark fields
		bsr.w	LevelSelect_DrawIcon
		enable_ints
		lea		(Anim_SonicMilesBG).l,a2
		jsr		Dynamic_Menu	; background
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnStart,d0	; start pressed?
		bne.s	LevelSelect_PressStart	; yes
		bra.w	LevelSelect_MainLoop	; no

LevelSelect_PressStart:
		move.w	(v_levselzone).w,d0
		add.w	d0,d0
		move.w	LevSel_Ptrs(pc,d0.w),d0
		bmi.w	LevelSelect_Return			; sound test
		cmpi.w	#(id_EndZ<<8),d0
		beq.s	LevelSelect_Ending
		cmpi.w	#(id_SS<<8),d0
		bne.w	LevelSelect_StartZone
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
LevelSelect_Return:
		move.b	#id_Sega,(v_gamemode).w ; => SegaScreen
		rts
; ===========================================================================
LevelSelect_Ending:
		move.b	#id_Ending,(v_gamemode).w
		move.w	d0,(v_zone).w	; set level to 0600 (Ending)
		rts
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
		dc.b id_EndZ, 0		; Ending
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
		dc.b id_EndZ, 0		; Ending
		dc.w $8000			; Sound Test
		even
	endif
; ===========================================================================
LevelSelect_StartZone:
		andi.w	#$3FFF,d0
		move.w	d0,(v_zone).w
	;	tst.b	(f_debugcheat).w		; has debug cheat been entered?
	;	beq.s	PlayLevel				; if not, branch
	;	btst	#bitA,(v_jpadhold1).w	; is A button held?
	;	beq.s	PlayLevel				; if not, branch
		move.b	#1,(f_debugmode).w		; enable debug mode
		bra.w	PlayLevel				; added branch because I consolidated all level select code/data to this file
; ===========================================================================
; ---------------------------------------------------------------------------
; Change what you're selecting in the level select
; ---------------------------------------------------------------------------
; loc_94DC:
LevSelControls:
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnUp|btnDn,d1
		bne.s	.ChkUpDown	; up/down pressed
		subq.w	#1,(v_levseldelay).w
		bpl.s	LevSelControls_CheckLR

	.ChkUpDown:
		move.w	#$B,(v_levseldelay).w
		move.b	(v_jpadhold1).w,d1
		andi.b	#btnUp|btnDn,d1
		beq.s	LevSelControls_CheckLR	; up/down not pressed, check for left & right
		move.w	(v_levselzone).w,d0
		btst	#bitUp,d1
		beq.s	.ChkDown
		subq.w	#1,d0	; decrease by 1
		bcc.s	.ChkDown; >= 0?
		moveq	#$15,d0 ; set to sound test

	.ChkDown:
		btst	#bitDn,d1
		beq.s	.ChkUp
		addq.w	#1,d0	; yes, add 1
		cmpi.w	#$15,d0
		ble.s	.ChkUp	; less than or equal to $15 (sound test)?
		moveq	#0,d0	; if not, set to 0

	.ChkUp:
		move.w	d0,(v_levselzone).w
		rts
; ===========================================================================
LevSelControls_CheckLR:
		cmpi.w	#$15,(v_levselzone).w		; are we in the sound test?
		bne.s	LevSelControls_SwitchSide	; if not, branch
		move.w	(v_levselsound).w,d0
		move.b	(v_jpadpress1).w,d1
		btst	#bitL,d1
		beq.s	.chkright
		subq.b	#1,d0
		bcc.s	.chkright
		moveq	#$7F,d0

	.chkright:
		btst	#bitR,d1
		beq.s	.chkA
		addq.b	#1,d0
		cmpi.w	#$80,d0
		blo.s	.chkA
		moveq	#0,d0

	.chkA:
		btst	#bitA,d1
		beq.s	.changesound
		addi.b	#$10,d0
		andi.b	#$7F,d0

	.changesound:
		move.w	d0,(v_levselsound).w
		andi.w	#btnBC,d1
		beq.s	.rts	; rts
		move.w	(v_levselsound).w,d0
		; temp. bandaid fix for crashes when playing these sounds in particular.
        	cmpi.w  #$5D,d0
        	beq.s   .rts
        	cmpi.w  #$5F,d0
      		beq.s   .rts
		addi.w	#$80,d0
		bra.w	PlaySound
		addi.w	#$80,d0
		bra.w	PlaySound
		;lea	(debug_cheat).l,a0
		;lea	(super_sonic_cheat).l,a2
		;lea	(Night_mode_flag).w,a1
		;moveq	#1,d2	; flag to tell the routine to enable the Super Sonic cheat
		;bsr.w	CheckCheats

	.rts:
		rts
; ===========================================================================
LevSelControls_SwitchSide:	; not in soundtest, not up/down pressed
		move.b	(v_jpadpress1).w,d1
		andi.b	#btnL|btnR,d1
		beq.s	.rts				; no direction key pressed
		move.w	(v_levselzone).w,d0	; left or right pressed
		move.b	LevelSelect_SwitchTable(pc,d0.w),d0 ; set selected zone according to table
		move.w	d0,(v_levselzone).w
	.rts:
		rts
; ===========================================================================
LevelSelect_SwitchTable:
	dc.b $F		; 0
	dc.b $10	; 1
	dc.b $11	; 2
	dc.b $12	; 3
	dc.b $12	; 4
	dc.b $12	; 5
	dc.b $13	; 6
	dc.b $13	; 7
	dc.b $13	; 8
	dc.b $14	; 9
	dc.b $14	; $A
	dc.b $14	; $B
	dc.b $15	; $C
	dc.b $15	; $D
	dc.b $15	; $E
	dc.b 0		; $F
	dc.b 1		; $10
	dc.b 2		; $11
	dc.b 3		; $12
	dc.b 6		; $13
	dc.b 9		; $14
	dc.b $C		; $15 - CURRENT END (SOUND TEST)
	even
; ===========================================================================
;loc_95B8:
LevelSelect_MarkFields:
		lea		($FF0000).l,a4
		lea		(LevSel_MarkTable).l,a5
		lea		(vdp_data_port).l,a6
		moveq	#0,d0
		move.w	(v_levselzone).w,d0
		lsl.w	#2,d0
		lea		(a5,d0.w),a3
		moveq	#0,d0
		move.b	(a3),d0
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea		(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#-$4000,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#$4000,d1
		swap	d1
		move.l	d1,4(a6)
		moveq	#$D,d2

	.loop:
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a6)
		dbf		d2,.loop

		addq.w	#2,a3
		moveq	#0,d0
		move.b	(a3),d0
		beq.s	.chkitem
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea		(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#-$4000,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#$4000,d1
		swap	d1
		move.l	d1,4(a6)
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a6)

	.chkitem:
		cmpi.w	#$15,(v_levselzone).w
		bne.s	.rts
		bra.w	LevelSelect_DrawSoundNumber

	.rts:
		rts
; ===========================================================================
LevelSelect_DrawSoundNumber:
		move.l	#$49C40003,(vdp_control_port).l
		move.w	(v_levselsound).w,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.s	.bra1
		move.b	d2,d0

.bra1:
		andi.w	#$F,d0
		cmpi.b	#$A,d0
		blo.s	.bra2
		addi.b	#4,d0

.bra2:
		addi.b	#$10,d0
		add.w	d3,d0
		move.w	d0,(a6)
		rts
; ===========================================================================
LevelSelect_DrawIcon:
		move.w	(v_levselzone).w,d0		; Get selected zone/menu option
		lea		(LevSel_IconTable).l,a3
		lea		(a3,d0.w),a3			; Get respective icon frame
		lea		($FF08C0).l,a1			; Chunk_Table + $C80
		moveq	#0,d0
		move.b	(a3),d0					; load icon frame # to d0
		lsl.w	#3,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0					; d0=(d0<<3)*3;
;		copyTilemap (a1,d0.w), $4B360003, 3, 2
		lea		(a1,d0.w),a1			; Go to respective area in Chunk table
		move.l	#$4BB60003,d0
		moveq	#3,d1
		moveq	#2,d2
		bsr.w	TilemapToVRAM			; Apply tilemap to VRAM
		lea		(Pal_LevSelIcons).l,a1
		moveq	#0,d0
		move.b	(a3),d0					; Get respective icon frame
		lsl.w	#5,d0
		lea		(a1,d0.w),a1
		lea		(v_palette+$40).w,a2
		moveq	#7,d1

	.loop:
		move.l	(a1)+,(a2)+
		dbf		d1,.loop
		rts
; ===========================================================================
LevSel_IconTable:
		dc.b	0,0,0	;	GHZ
	if BetaLevelOrder
		dc.b	1,1,1	;	LZ
		dc.b	2,2,2	;	MZ
		dc.b	3,3,3	;	SLZ
		dc.b	4,4,4	;	SYZ
	else
		dc.b	2,2,2	;	MZ
		dc.b	4,4,4	;	SYZ
		dc.b	1,1,1	;	LZ
		dc.b	3,3,3	;	SLZ
	endif
		dc.b	5,6,7	;	SBZ
		dc.b	8		;	FZ
		dc.b	9		;	Special Stage
		dc.b	0		;	Ending
		dc.b	10		;	Sound Test
		even
; ===========================================================================
; DATA STRUCTURE NOTING WHICH LINES TO HIGHLIGHT FOR EACH SELECTION
LevSel_MarkTable:	; 4 bytes per level select entry

; line primary, 2*column ($E fields), line secondary, 2*column secondary (1 field)
		dc.b   3,  6,  3,$24	; 0 GHZ1
		dc.b   3,  6,  4,$24	; 1 GHZ2
		dc.b   3,  6,  5,$24	; 2 GHZ3

		dc.b   7,  6,  7,$24	; 3 MZ1
		dc.b   7,  6,  8,$24	; 4 MZ2
		dc.b   7,  6,  9,$24	; 5 MZ3

		dc.b  $B,  6, $B,$24	; 6 SYZ1
		dc.b  $B,  6, $C,$24	; 7 SYZ2
		dc.b  $B,  6, $D,$24	; 8 SYZ3

		dc.b  $F,  6, $F,$24	; 9  LZ1
		dc.b  $F,  6,$10,$24	; $A LZ2
		dc.b  $F,  6,$11,$24	; $B LZ3

		dc.b $13,  6,$13,$24	; $C SLZ1
		dc.b $13,  6,$14,$24	; $D SLZ2
		dc.b $13,  6,$15,$24	; $E SLZ3
	; --- second column ---
		dc.b   3,$2C,  3,$48	; $F SBZ1
		dc.b   3,$2C,  4,$48	; $10 SBZ2
		dc.b   3,$2C,  5,$48	; $11 SBZ3

		dc.b   7,$2C,  7,$48	; $12 FINAL

		dc.b  $B,$2C,  $B,$48	; $13 SPECIAL
		dc.b $F,$2C,   $F,$48	; $14 ENDING
		dc.b $13,$2C,  $13,$48	; $15 SOUND TEST
; ===========================================================================

Dynamic_Menu:
		lea	(v_menuanimtimer).w,a3
loc_3FF30:
		move.w	(a2)+,d6	; loop counter. We start off with 00 the first time.
loc_3FF32:
		subq.b	#1,(a3)		; decrement timer
		bcc.s	loc_3FF78	; if time remains, branch ahead
		moveq	#0,d0
		move.b	1(a3),d0	; load animation counter from animation data table
		cmp.b	6(a2),d0
		blo.s	loc_3FF48
		moveq	#0,d0
		move.b	d0,1(a3)	; set animation counter
loc_3FF48:
		addq.b	#1,1(a3)	; increment animation counter
		move.b	(a2),(a3)	; set timer
		bpl.s	loc_3FF56
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)
loc_3FF56:
		move.b	8(a2,d0.w),d0
		lsl.w	#5,d0
		move.w	4(a2),d2
		move.l	(a2),d1
		andi.l	#$FFFFFF,d1		; Filter out the first byte, which contains the first PLC ID, leaving the address of the zone's art in d0
		add.l	d0,d1
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3
		jsr		(QueueDMATransfer).l	; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM
loc_3FF78:
		move.b	6(a2),d0
		tst.b	(a2)
		bpl.s	loc_3FF82
		add.b	d0,d0
loc_3FF82:
		addq.b	#1,d0
		andi.w	#$FE,d0
		lea		8(a2,d0.w),a2
		addq.w	#2,a3
		dbf		d6,loc_3FF32
		rts
; ===========================================================================

; ------------------------------------------------------------------------
; MENU ANIMATION SCRIPT
; ------------------------------------------------------------------------
;word_87C6:
Anim_SonicMilesBG:
		dc.w   0
	; Sonic/Miles animated background
		dc.l $FF<<24|Art_MenuBack
		dc.w $20
		dc.b 6
		dc.b $A
		dc.b   0,$C7    ; "SONIC"
		dc.b  $A,  5	; 2
		dc.b $14,  5	; 4
		dc.b $1E,$C7	; "TAILS"
		dc.b $14,  5	; 8
		dc.b  $A,  5	; 10
; ===========================================================================
