; ---------------------------------------------------------------------------
; Subroutine to	update the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

HUD_Update:
		moveq	#0,d7						; reserve a data register for clearing
		tst.w	(v_debuguse).w				; is debug mode	on?
		bne.w	HudDebug					; if yes, branch
		tst.b	(f_scorecount).w			; does the score need updating?
		beq.s	.chkrings					; if not, branch

		move.b	d7,(f_scorecount).w
		locVRAM	(ArtTile_HUD+$18)*tile_size,d0	; set VRAM address -- RetroKoH VRAM Overhaul
		move.l	(v_score).w,d1				; load score
		bsr.w	Hud_Score

.chkrings:
		tst.b	(f_ringcount).w				; does the ring	counter	need updating?
		beq.s	.chktime					; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero				; reset rings to 0 if Sonic is hit

.notzero:
		move.b	d7,(f_ringcount).w
		locVRAM	(ArtTile_HUD+$2E)*tile_size,d0	; set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.w	(v_rings).w,d1				; load number of rings
		bsr.w	Hud_Rings

.chktime:
		tst.b	(f_timecount).w				; does the time	need updating?
		beq.w	.chklives					; if not, branch
		tst.b	(f_pause).w					; is the game paused?
		bne.s	.chklives					; if yes, branch
		lea		(v_time).w,a1

	if HUDCentiseconds=1	; Mercury HUD Centiseconds
		cmpi.l	#(9*$10000)+(59*$100)+59,(a1)+	; is the time 9:59:59?
		beq.w	TimeOver						; if yes, branch

		move.b	(v_centstep).w,d1
		addi.b	#1,d1
		cmpi.b	#3,d1
		bne.s	.skip
		clr.b	d1
		
.skip:
		move.b	d1,(v_centstep).w
		cmpi.b	#2,d1
		beq.s	.skip2
		addi.b	#1,d1

.skip2:
		add.b	d1,-(a1)
		cmpi.b	#100,(a1)
		bcs.s	.docent

	else

		cmpi.l	#(9*$10000)+(59*$100)+59,(a1)+	; is the time 9:59:59?
		beq.s	TimeOver						; if yes, branch

		addq.b	#1,-(a1)						; increment 1/60s counter
		cmpi.b	#60,(a1)						; check if passed 60
		blo.s	.chklives
	endif	; HUD Centiseconds End

		move.b	d7,(a1)							; clear 1/60s counter
		addq.b	#1,-(a1)						; increment second counter
		cmpi.b	#60,(a1)						; check if passed 60
		blo.s	.updatetime
		move.b	d7,(a1)							; clear seconds counter
		addq.b	#1,-(a1)						; increment minute counter
		cmpi.b	#9,(a1)							; check if passed 9
		blo.s	.updatetime
		move.b	#9,(a1)							; keep as 9

.updatetime:
		locVRAM	(ArtTile_HUD+$26)*tile_size,d0	; set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.b	(v_timemin).w,d1 			; load minutes
		bsr.w	Hud_Mins
		locVRAM	(ArtTile_HUD+$2A)*tile_size,d0	; set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.b	(v_timesec).w,d1 			; load seconds
		bsr.w	Hud_Secs

	if HUDCentiseconds=1	; Mercury HUD Centiseconds
.docent:
		locVRAM	$F440,d0					; Temporary location
		moveq	#0,d1
		move.b	(v_timecent).w,d1			; load centiseconds
		bsr.w	Hud_Secs
	endif	; HUD Centiseconds End

.chklives:
		tst.b	(f_lifecount).w				; does the lives counter need updating?
		beq.s	.chkbonus					; if not, branch
		move.b	d7,(f_lifecount).w
		bsr.w	Hud_Lives

.chkbonus:
		tst.b	(f_endactbonus).w			; do the bonus counters need updating?
		beq.s	.finish						; if not, branch
		move.b	d7,(f_endactbonus).w
		locVRAM	ArtTile_Bonuses*tile_size
		moveq	#0,d1
		move.w	(v_timebonus).w,d1			; load time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1			; load ring bonus

	if CoolBonusEnabled
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_coolbonus).w,d1			; load cool bonus
	endif

	if PerfectBonusEnabled
		bsr.w	Hud_TimeRingBonus
		locVRAM	(ArtTile_Bonuses-8)*tile_size
		moveq	#0,d1
		move.w	(v_perfectbonus).w,d1		; load perfect bonus
	endif

		bra.w	Hud_TimeRingBonus

.finish:
		rts	
; ===========================================================================

TimeOver:
		move.b	d7,(f_timecount).w
		lea		(v_player).w,a0
		cmpi.b	#6,obRoutine(a0)
		bhs.s	.noTimeOver					; don't trigger if already dying/drowning
		movea.l	a0,a2
		bsr.w	KillSonic
		move.b	#1,(f_timeover).w

.noTimeOver:
		rts	
; ===========================================================================

HudDebug:
		bsr.w	HudDb_XY
		tst.b	(f_ringcount).w				; does the ring	counter	need updating?
		beq.s	.objcounter					; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero				; reset rings to 0 if Sonic is hit

.notzero:
		move.b	d7,(f_ringcount).w
		locVRAM	(ArtTile_HUD+$2E)*tile_size,d0	; set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.w	(v_rings).w,d1				; load number of rings
		bsr.w	Hud_Rings

.objcounter:
		locVRAM	(ArtTile_HUD+$2A)*tile_size,d0	; set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.b	(v_spritecount).w,d1		; load "number of objects" counter
		bsr.w	Hud_Secs
		tst.b	(f_lifecount).w				; does the lives counter need updating?
		beq.s	.chkbonus					; if not, branch
		move.b	d7,(f_lifecount).w
		bsr.w	Hud_Lives

.chkbonus:
		tst.b	(f_endactbonus).w			; does the ring/time bonus counter need updating?
		beq.s	.finish						; if not, branch
		move.b	d7,(f_endactbonus).w
		locVRAM	ArtTile_Bonuses*tile_size	; set VRAM address
		moveq	#0,d1
		move.w	(v_timebonus).w,d1			; load time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(v_ringbonus).w,d1			; load ring bonus
		bra.w	Hud_TimeRingBonus

.finish:
		rts	
; End of function HUD_Update

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadZero:
		locVRAM	(ArtTile_HUD+$2E)*tile_size	; set VRAM address -- RetroKoH VRAM Overhaul
		lea		Hud_TilesZero(pc),a2
		moveq	#2,d2					; Optimized from move.w
		bra.s	loc_1C83E
; End of function Hud_LoadZero

	if HUDCentiseconds=1	;Mercury HUD Centiseconds
; ---------------------------------------------------------------------------
; Subroutine to	load " on the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadMarks:				; XREF: HUD_Update
		locVRAM	$F400					; Temporary location
		lea		Hud_TilesMarks(pc),a2
		moveq	#2,d2					; Optimized from move.w
		bra.s	loc_1C83E
; End of function Hud_LoadMarks
	endif	; HUD Centiseconds End

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon or ')
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base:
		lea		(vdp_data_port).l,a6
		bsr.w	Hud_Lives

	if HUDCentiseconds=1	; Mercury HUD Centiseconds
		bsr.s	Hud_LoadMarks
	endif	; HUD Centiseconds End

		locVRAM	(ArtTile_HUD+$16)*tile_size	; set VRAM address -- RetroKoH VRAM Overhaul
		lea		Hud_TilesBase(pc),a2
		moveq	#$E,d2					; Optimized from move.w

loc_1C83E:
		lea		Art_Hud(pc),a1

loc_1C842:
		moveq	#$F,d1					; Optimized from move.w
		move.b	(a2)+,d0
		bmi.s	loc_1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea		(a1,d0.w),a3

loc_1C852:
		move.l	(a3)+,(a6)
		dbf		d1,loc_1C852

loc_1C858:
		dbf		d2,loc_1C842

		rts	
; ===========================================================================

loc_1C85E:
		move.l	#0,(a6)
		dbf		d1,loc_1C85E

		bra.s	loc_1C858
; End of function Hud_Base

; ===========================================================================
	if HUDCentiseconds=1	;Mercury HUD Centiseconds
Hud_TilesMarks:	dc.b $1A, 0, 0, 0
Hud_TilesBase:	dc.b $16, $FF, $FF, $FF, $FF, $FF, $FF,	0, 0, $18, 0, 0
	else
Hud_TilesBase:	dc.b $16, $FF, $FF, $FF, $FF, $FF, $FF,	0, 0, $14, 0, 0
	endif	; HUD Centiseconds End

Hud_TilesZero:	dc.b $FF, $FF, 0, 0
; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY:
		locVRAM	(ArtTile_HUD+$16)*tile_size	; set VRAM address -- RetroKoH VRAM Overhaul
		move.w	(v_screenposx).w,d1 ; load camera x-position
		swap	d1
		move.w	(v_player+obX).w,d1 ; load Sonic's x-position
		bsr.s	HudDb_XY2
		move.w	(v_screenposy).w,d1 ; load camera y-position
		swap	d1
		move.w	(v_player+obY).w,d1 ; load Sonic's y-position
; End of function HudDb_XY


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY2:
		moveq	#7,d6
		lea		(Art_Text).l,a1

HudDb_XYLoop:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		bcs.s	loc_1C8B2
		addq.w	#4,d2			; Accomodate new text art for ASCII text

loc_1C8B2:
		lsl.w	#5,d2
		lea		(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf		d6,HudDb_XYLoop	; repeat 7 more times

		rts	
; End of function HudDb_XY2

; ---------------------------------------------------------------------------
; Subroutine to	load rings numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Rings:
		lea		Hud_100(pc),a2	; Optimized from (Hud_100).l
		moveq	#2,d6
		bra.s	Hud_LoadArt
; End of function Hud_Rings

; ---------------------------------------------------------------------------
; Subroutine to	load score numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Score:
		lea		Hud_100000(pc),a2	; Optimized from (Hud_100000).l
		moveq	#5,d6

Hud_LoadArt:
		moveq	#0,d4
		lea		Art_Hud(pc),a1

Hud_ScoreLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C8EC:
		sub.l	d3,d1
		bcs.s	loc_1C8F4
		addq.w	#1,d2
		bra.s	loc_1C8EC
; ===========================================================================

loc_1C8F4:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C8FE
		moveq	#1,d4					; Optimized from move.w

loc_1C8FE:
	if HUDHasLeadingZeroes=0	;Mercury HUD Has Leading Zeroes
		tst.w	d4
		beq.s	loc_1C92C
	endif	; HUD Has Leading Zeroes End
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea		(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1C92C:
		addi.l	#$400000,d0
		dbf		d6,Hud_ScoreLoop

		rts	
; End of function Hud_Score
