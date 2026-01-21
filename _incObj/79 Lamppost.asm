; ---------------------------------------------------------------------------
; Object 79 - lamppost
; ---------------------------------------------------------------------------
; OST Constants
obLamp_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obLamp_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obLamp_SpinTime:		equ objoff_34		; 2 bytes | length of time to twirl the lamp
; ---------------------------------------------------------------------------

Lamppost:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Lamp_Index(pc,d0.w),d1
		jmp		Lamp_Index(pc,d1.w)
; ===========================================================================

Lamp_Index:	offsetTable
		offsetTableEntry.w Lamp_Main
		offsetTableEntry.w Lamp_Blue
		offsetTableEntry.w Lamp_Red
		offsetTableEntry.w Lamp_Twirl
; ===========================================================================

Lamp_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Lamp,obMap(a0)
		move.w	#make_art_tile(ArtTile_Lamppost,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#8,obDispWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table --  ProjectFM
		movea.w	d0,a2						; load address into a2 -- ProjectFM
		btst	#0,(a2)						; has lamppost been hit? -- ProjectFM
		bne.s	.red						; if yes, branch

		moveq	#$7F,d1
		move.l	d1,d2
		and.b	(v_lastlamp).w,d1			; get number of last lamppost hit (SCE Optimization)
		and.b	obSubtype(a0),d2			; get lamppost number (SCE Optimization)
		cmp.b	d2,d1						; is this a "new" lamppost?
		bcs.s	Lamp_Blue					; if yes, branch

	.red:
		bset	#0,(a2)						; remember lamppost as red - ProjectFM S3K Object Manager
		move.b	#4,obRoutine(a0)			; -> Lamp_Red
		move.b	#3,obFrame(a0)				; use red lamppost frame
		jmp		(RememberState).l
; ===========================================================================

Lamp_Blue:	; Routine 2
		tst.w	(v_debuguse).w				; is debug mode	being used?
		bne.w	Lamp_Red					; if yes, branch
		tst.b	(v_player+obCtrlLock).w
		bmi.w	Lamp_Red

		moveq	#$7F,d1
		move.l	d1,d2
		and.b	(v_lastlamp).w,d1			; get number of last lamppost hit (SCE Optimization)
		and.b	obSubtype(a0),d2			; get lamppost number (SCE Optimization)
		cmp.b	d2,d1						; is this a "new" lamppost?
		bcs.s	.chkhit						; if yes, branch

		move.w	obRespawnAddr(a0),d0		; get address in respawn table -- ProjectFM
		movea.w	d0,a2						; load address into a2 -- ProjectFM
		bset	#0,(a2)						; remember lamppost as red - ProjectFM
		move.b	#4,obRoutine(a0)			; -> Lamp_Red
		move.b	#3,obFrame(a0)				; use red lamppost frame
		jmp		(RememberState).l
; ===========================================================================

	.chkhit:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		addq.w	#8,d0
		cmpi.w	#$10,d0
		bhs.w	Lamp_Red
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		addi.w	#$40,d0
		cmpi.w	#$68,d0
		bhs.s	Lamp_Red

		move.w	#sfx_Lamppost,d0
		jsr		(QueueSound2).w				; play lamppost sound
		addq.b	#2,obRoutine(a0)
		jsr		(FindFreeObj).l
		bne.s	.fail

		_move.l	#Lamppost,obAddr(a1)		; load twirling	lamp bulb object
		move.b	#6,obRoutine(a1)			; -> Lamp_Twirl
		move.w	obX(a0),obLamp_StartX(a1)
		move.w	obY(a0),obLamp_StartY(a1)
		subi.w	#$18,obLamp_StartY(a1)
		move.l	#Map_Lamp,obMap(a1)
		move.w	#make_art_tile(ArtTile_Lamppost,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#8,obDispWid(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#2,obFrame(a1)				; use "bulb only" frame
		move.w	#32,obLamp_SpinTime(a1)

	.fail:
		move.b	#1,obFrame(a0)				; use "post only" frame
		bsr.w	Lamp_StoreInfo
	; ProjectFM
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		movea.w	d0,a2						; load address into a2
		bset	#0,(a2)						; remember lamppost as red
	; ProjectFM

;Lamp_Finish:
Lamp_Red:	; Routine 4
		jmp		(RememberState).l	
; ===========================================================================

Lamp_Twirl:	; Routine 6
		subq.w	#1,obLamp_SpinTime(a0)		; decrement timer
		bpl.s	.continue					; if time remains, keep twirling
		move.b	#4,obRoutine(a0)			; -> Lamp_Red

.continue:
		move.b	obAngle(a0),d0
		subi.b	#$10,obAngle(a0)
		subi.b	#$40,d0
		jsr		(CalcSine).w
		muls.w	#$C00,d1
		swap	d1
		add.w	obLamp_StartX(a0),d1
		move.w	d1,obX(a0)
		muls.w	#$C00,d0
		swap	d0
		add.w	obLamp_StartY(a0),d0
		move.w	d0,obY(a0)
		jmp		(RememberState).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	store information when you hit a lamppost
; ---------------------------------------------------------------------------

Lamp_StoreInfo:
		move.b	obSubtype(a0),(v_lastlamp).w 			; lamppost number
		move.b	(v_lastlamp).w,(v_lastlamp+1).w
		move.w	obX(a0),(v_lamp_xpos).w					; x-position
		move.w	obY(a0),(v_lamp_ypos).w					; y-position
		move.w	(v_rings).w,(v_lamp_rings).w 			; rings
		move.b	(v_lifecount).w,(v_lamp_lives).w 		; lives
		move.l	(v_time).w,(v_lamp_time).w 				; time
		move.w	(v_dle_routine).w,(v_lamp_dle).w		; routine counter for dynamic level events -- Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		move.w	(v_limitbtm).w,(v_lamp_limitbtm).w 		; lower y-boundary of level
		move.w	(v_screenposx).w,(v_lamp_scrx).w 		; screen x-position
		move.w	(v_screenposy).w,(v_lamp_scry).w 		; screen y-position
		move.w	(v_bgscreenposx).w,(v_lamp_bgscrx).w	; bg position
		move.w	(v_bgscreenposy).w,(v_lamp_bgscry).w 	; bg position
		move.w	(v_bg2screenposx).w,(v_lamp_bg2scrx).w 	; bg position
		move.w	(v_bg2screenposy).w,(v_lamp_bg2scry).w 	; bg position
		move.w	(v_bg3screenposx).w,(v_lamp_bg3scrx).w 	; bg position
		move.w	(v_bg3screenposy).w,(v_lamp_bg3scry).w 	; bg position
		move.w	(v_waterpos_base).w,(v_lamp_wtrpos).w	; water height
		move.b	(v_water_routine).w,(v_lamp_wtrrout).w	; rountine counter for water
		move.b	(f_water_pal_full).w,(v_lamp_wtrstat).w	; water direction
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	load stored info when you start	a level	from a lamppost
; ---------------------------------------------------------------------------

Lamp_LoadInfo:
		move.b	(v_lastlamp+1).w,(v_lastlamp).w
		move.w	(v_lamp_xpos).w,(v_player+obX).w
		move.w	(v_lamp_ypos).w,(v_player+obY).w
		move.w	(v_lamp_rings).w,(v_rings).w
		move.b	(v_lamp_lives).w,(v_lifecount).w
		clr.w	(v_rings).w
		clr.b	(v_lifecount).w
		move.l	(v_lamp_time).w,(v_time).w
		move.b	#59,(v_timecent).w						; second counter ticks at next frame
		subq.b	#1,(v_timesec).w
		move.w	(v_lamp_dle).w,(v_dle_routine).w		; Now word-length so we don't need to clear d0 elsewhere -- Filter Optimized DLE Manager
		move.b	(v_lamp_wtrrout).w,(v_water_routine).w
		move.w	(v_lamp_limitbtm).w,(v_limitbtm).w
		move.w	(v_lamp_limitbtm).w,(v_limitbtm_target).w
		move.w	(v_lamp_scrx).w,(v_screenposx).w
		move.w	(v_lamp_scry).w,(v_screenposy).w
		move.w	(v_lamp_bgscrx).w,(v_bgscreenposx).w
		move.w	(v_lamp_bgscry).w,(v_bgscreenposy).w
		move.w	(v_lamp_bg2scrx).w,(v_bg2screenposx).w
		move.w	(v_lamp_bg2scry).w,(v_bg2screenposy).w
		move.w	(v_lamp_bg3scrx).w,(v_bg3screenposx).w
		move.w	(v_lamp_bg3scry).w,(v_bg3screenposy).w
		cmpi.b	#id_LZ,(v_zone).w						; is this Labyrinth Zone?
		bne.s	.notlabyrinth							; if not, branch

		move.w	(v_lamp_wtrpos).w,(v_waterpos_base).w
		move.b	(v_lamp_wtrrout).w,(v_water_routine).w
		move.b	(v_lamp_wtrstat).w,(f_water_pal_full).w

	.notlabyrinth:
	; This unused feature locks the area behind the lamppost if you respawn at it.
;		tst.b	(v_lastlamp).w							; is last lamppost negative? (it never is)
;		bpl.s	.exit									; if not, branch
;		move.w	(v_lamp_xpos).w,d0
;		subi.w	#160,d0
;		move.w	d0,(v_limitleft).w						; set left boundary to half a screen to Sonic's left

	.exit:
		rts	
; ===========================================================================