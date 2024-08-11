; ---------------------------------------------------------------------------
; Subroutine to	update the HUD in the Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HUD_Update_SS:
		lea		(vdp_data_port).l,a6
		tst.w	(v_debuguse).w				; is debug mode	on?
		bne.w	HudDebug_SS					; if yes, branch
		tst.b	(f_scorecount).w			; does the score need updating?
		beq.s	.chkrings					; if not, branch

		clr.b	(f_scorecount).w
		locVRAM	(ArtTile_SS_HUD+$18)*tile_size,d0	; ($4220) set VRAM address -- RetroKoH VRAM Overhaul		
		move.l	(v_score).w,d1				; load score
		bsr.w	Hud_Score

.chkrings:
		tst.b	(f_ringcount).w				; does the ring	counter	need updating?
		beq.s	.chktime					; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero_SS				; reset rings count to 0

.notzero:
		clr.b	(f_ringcount).w
		locVRAM	(ArtTile_SS_HUD+$2E)*tile_size,d0	; ($44E0) set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.w	(v_rings).w,d1				; load number of rings
		bsr.w	Hud_Rings

.chktime:
		tst.b	(f_timecount).w				; does the time	need updating?
		beq.w	.chklives					; if not, branch
		tst.b	(f_pause).w					; is the game paused?
		bne.w	.chklives					; if yes, branch
		lea		(v_time).w,a1

	if TimeLimitInSpecialStage=1	; Mercury Time Limit In Special Stage

		if HUDCentiseconds=1	;Mercury HUD Centiseconds
			tst.l	(a1)+					; has the time run out?
			beq.w	TimeOver_SS				; if yes, branch
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
			sub.b	d1,-(a1)
			cmpi.b	#-1,(a1)
			bgt.s	.docent
			move.b	#99,(a1)				; set cent to 59
		else
			tst.l	(a1)+					; has the time run out?
			beq.w	TimeOver_SS				; if yes, branch
			subq.b	#1,-(a1)				; dec jiffy
			cmpi.b	#-1,(a1)				; if -1
			bgt.s	.chklives
			move.b	#59,(a1)				; set jiffy to 59
		endif	; HUD Centiseconds End

		subq.b	#1,-(a1)		; dec sec
		cmpi.b	#-1,(a1)		; if -1
		bgt.s	.updatetime
		move.b	#59,(a1)		; set sec to 59
		subq.b	#1,-(a1)		; dec min
		cmpi.b	#-1,(a1)		; if -1
		bgt.s	.updatetime
		clr.l	(v_time).w		; set time to 0

	else

		if HUDCentiseconds=1	; Mercury HUD Centiseconds
			cmpi.l	#$93B63,(a1)+							; is the time 9'59"99?
			beq.w	TimeOver_SS								; if yes, branch
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
			cmpi.l	#$93B3B,(a1)+							; is the time 9.59?
			beq.s	TimeOver_SS								; if yes, branch
			addq.b	#1,-(a1)								; increment 1/60s counter
			cmpi.b	#60,(a1)								; check if passed 60
			bcs.s	.chklives
		endif	; HUD Centiseconds End
	
		clr.b	(a1)									; clear 1/60s counter
		addq.b	#1,-(a1)								; increment second counter
		cmpi.b	#60,(a1)								; check if passed 60
		bcs.s	.updatetime
		clr.b	(a1)									; clear seconds counter
		addq.b	#1,-(a1)								; increment minute counter
		cmpi.b	#9,(a1)									; check if passed 9
		bcs.s	.updatetime
		move.b	#9,(a1)									; keep to 9
	endif	; Mercury Time Limit In Special Stage End

.updatetime:
		locVRAM	(ArtTile_SS_HUD+$26)*tile_size,d0				; ($43E0) set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.b	(v_timemin).w,d1						; load minutes
		bsr.w	Hud_Mins
		locVRAM	(ArtTile_SS_HUD+$2A)*tile_size,d0				; ($4460) set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.b	(v_timesec).w,d1						; load seconds
		bsr.w	Hud_Secs
		
	if HUDCentiseconds=1	;Mercury HUD Centiseconds
.docent:
		locVRAM	(ArtTile_SS_HUD-4)*tile_size,d0				; Adjust HUD art and set new location
		moveq	#0,d1
		move.b	(v_timecent).w,d1						; load centiseconds
		bsr.w	Hud_Secs
	endif	; HUD Centiseconds End
		

.chklives:
		tst.b	(f_lifecount).w							; does the lives counter need updating?
		beq.s	.finish									; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives_SS

.finish:
		rts	
; ===========================================================================

TimeOver_SS:				; XREF: Hud_ChkTime_SS
		clr.b	(f_timecount).w							; stop the time counter

	if HUDInSpecialStage=1	; Mercury Time Limit In Special Stage
		lea		(v_objspace).w,a0
		movea.l	a0,a2
		bsr.w	KillSonic								; Will run a slightly different routine for SS Sonic.
		move.b	#1,(f_timeover).w						; Set time over flag
	endif	; Time Limit In Special Stage End

		rts	
; ===========================================================================

HudDebug_SS:				; XREF: HUD_Update
		bsr.w	HudDb_XY_SS
		tst.b	(f_ringcount).w							; does the ring	counter	need updating?
		beq.s	.objcounter								; if not, branch
		bpl.s	.notzero
		bsr.w	Hud_LoadZero_SS

.notzero:
		clr.b	(f_ringcount).w
		locVRAM	(ArtTile_SS_HUD+$2E)*tile_size,d0				; ($44E0) set VRAM address -- RetroKoH VRAM Overhaul	
		moveq	#0,d1
		move.w	(v_rings).w,d1							; load number of rings
		bsr.w	Hud_Rings

.objcounter:
		locVRAM	(ArtTile_SS_HUD+$2A)*tile_size,d0				; ($4460) set VRAM address -- RetroKoH VRAM Overhaul
		moveq	#0,d1
		move.b	(v_spritecount).w,d1					; load "number of objects" counter
		bsr.w	Hud_Secs
		tst.b	(f_lifecount).w							; does the lives counter need updating?
		beq.s	.finish									; if not, branch
		clr.b	(f_lifecount).w
		bsr.w	Hud_Lives_SS

.finish:
		rts	
; End of function HUD_Update_SS

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD in the Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadZero_SS:				; XREF: HUD_Update_SS
		locVRAM	(ArtTile_SS_HUD+$32)*tile_size				; ($4560) set VRAM address -- RetroKoH VRAM Overhaul	
		lea		Hud_TilesZero(pc),a2
		moveq	#2,d2									; Optimized from move.w
		bra.w	loc_1C83E
; End of function Hud_LoadZero_SS

	if HUDCentiseconds=1	;Mercury HUD Centiseconds
; ---------------------------------------------------------------------------
; Subroutine to	load " on the HUD in the Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadMarks_SS:				; XREF: HUD_Update_SS
		locVRAM	(ArtTile_SS_HUD-6)*tile_size					; Adjust HUD art and set new location
		lea		Hud_TilesMarks(pc),a2
		moveq	#2,d2									; Optimized from move.w
		bra.w	loc_1C83E
; End of function Hud_LoadMarks_SS
	endif	; HUD Centiseconds End

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon) in Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base_SS:				; XREF: GM_Special
		lea		(vdp_data_port).l,a6
		bsr.w	Hud_Lives_SS
		
	if HUDCentiseconds=1	; Mercury HUD Centiseconds
		bsr.s	Hud_LoadMarks_SS
	endif	; HUD Centiseconds End
		
		locVRAM	(ArtTile_SS_HUD+$16)*tile_size				; ($41E0) set VRAM address -- RetroKoH VRAM Overhaul
		lea		Hud_TilesBase(pc),a2
		moveq	#$E,d2									; Optimized from move.w
		bra.w	loc_1C83E
; End of function Hud_Base_SS

; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns in Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY_SS:				; XREF: HudDebug_SS
		locVRAM	(ArtTile_SS_HUD+$16)*tile_size				; ($41E0) set VRAM address -- RetroKoH VRAM Overhaul
		move.w	(v_screenposx).w,d1 ; load camera x-position
		swap	d1
		move.w	(v_player+obX).w,d1 ; load Sonic's x-position
		bsr.w	HudDb_XY2
		move.w	(v_screenposy).w,d1 ; load camera y-position
		swap	d1
		move.w	(v_player+obY).w,d1 ; load Sonic's y-position
		bra.w	HudDb_XY2
; End of function HudDb_XY_SS

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed lives	counter	patterns in Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Lives_SS:				; XREF: Hud_ChkLives_SS
		locVRAM	(ArtTile_SS_Lives+9)*tile_size,d0		; ($4700) set VRAM address
		moveq	#0,d1
		move.b	(v_lives).w,d1					; load number of lives
		lea		Hud_10(pc),a2					; Optimized from (Hud_10).l
		moveq	#1,d6
		moveq	#0,d4
		lea		Art_LivesNums(pc),a1
		bra.w	Hud_LivesLoop
		;rts
; End of function Hud_Lives_SS