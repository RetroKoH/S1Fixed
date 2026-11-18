; ---------------------------------------------------------------------------
; Background layer deformation subroutines
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DeformLayers:
		tst.b	(f_nobgscroll).w
		beq.s	.bgscroll

	.noscroll:
		rts
; ===========================================================================

	.bgscroll:
		clr.w	(v_fg_scroll_flags).w
		clr.w	(v_bg1_scroll_flags).w
		clr.w	(v_bg2_scroll_flags).w
		clr.w	(v_bg3_scroll_flags).w

		bsr.w	ScrollHoriz
		bsr.w	ScrollVertical
		bsr.w	DynamicLevelEvents
		move.w	(v_screenposy).w,(v_scrposy_vdp).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

	; ???NOTE???: This can be made dynamic (per act) 
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		move.w	Deform_Index(pc,d0.w),d0
		jmp		Deform_Index(pc,d0.w)
; End of function DeformLayers
; ===========================================================================

; ---------------------------------------------------------------------------
; Offset index for background layer deformation	code
; ---------------------------------------------------------------------------

Deform_Index:	offsetTable
		offsetTableEntry.w	Deform_GHZ
		offsetTableEntry.w	Deform_LZ
		offsetTableEntry.w	Deform_MZ
		offsetTableEntry.w	Deform_SLZ
		offsetTableEntry.w	Deform_SYZ
		offsetTableEntry.w	Deform_SBZ
		zonewarning Deform_Index,2
		offsetTableEntry.w	Deform_GHZ
; ===========================================================================

; ---------------------------------------------------------------------------
; Green	Hill Zone background layer deformation code
; ---------------------------------------------------------------------------

Deform_GHZ:
	; block 3 - distant mountains
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4					; 13.28% scrolling
		moveq	#0,d6
		bsr.w	BGScroll_Block3

	; block 2 - hills & waterfalls
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#0,d6
		bsr.w	BGScroll_Block2

	; calculate Y position
		move.w	(v_screenposy).w,d0		; get screen pos
		andi.w	#$7FF,d0				; maximum $7FF
		lsr.w	#5,d0					; divide by $20
	; OrionNavattan GHZ VScroll Fix
		cmpi.w	#$20,d0
		bls.s	.limitY					; branch if v_screenposy is between 0 and $400
		moveq	#$20,d0					; use $20 if greater
	; GHZ VScroll Fix End

	.limitY:
		move.w	d0,(v_bgscrposy_vdp).w

		; Advance the three fixed-point cloud movement accumulators
		lea		(v_bgscroll_buffer).w,a2
		addi.l	#$10000,(a2)+			; upper clouds, 1 pixel per frame
		addi.l	#$C000,(a2)+			; middle clouds, 0.75 pixels per frame
		addi.l	#$8000,(a2)+			; lower clouds, 0.5 pixels per frame

		; Store band positions after the cloud accumulators
		lea		(v_bgscroll_buffer+$10).w,a1

		move.w	(v_bg3screenposx).w,d0
		add.w	(v_bgscroll_buffer).w,d0
		move.w	d0,(a1)+				; upper clouds

		move.w	(v_bg3screenposx).w,d0
		add.w	(v_bgscroll_buffer+4).w,d0
		move.w	d0,(a1)+				; middle clouds

		move.w	(v_bg3screenposx).w,d0
		add.w	(v_bgscroll_buffer+8).w,d0
		move.w	d0,(a1)+				; lower clouds

		move.w	(v_bg3screenposx).w,d0
		move.w	d0,(a1)+				; distant mountains

		move.w	(v_bg2screenposx).w,d0
		move.w	d0,(a1)+				; hills and waterfalls

; Calculate the water perspective step from the hills' X position
		move.w	(v_screenposx).w,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2					; fixed-point change per water line

		moveq	#0,d3
		move.w	d0,d3					; begin at the hills' X position
		moveq	#$67,d1					; generate 104 water-line positions

	.waterLoop:
		move.w	d3,(a1)+				; pixelwise water scroll
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf		d1,.waterLoop

		; Select the band table and generated positions
		lea		(BGScrollSize_GHZ).l,a4
		lea		(v_bgscroll_buffer+$10).w,a5
		move.w	#224-1,d1

		; Choose the foreground position for this screen
		move.w	(v_screenposx).w,d3
		cmpi.b	#id_Title,(v_gamemode).w
		bne.s	.draw
		moveq	#0,d3					; hold the title banner in place

	.draw:
		jmp		(ProcessBGScroll_CustomFG).l
; End of function Deform_GHZ

; ---------------------------------------------------------------------------
; Labyrinth Zone background layer deformation code
; Optimised by MarkeyJester; Adapted to the modern disassembly by Malachi
; ---------------------------------------------------------------------------

Deform_LZ:
	; plain background scroll
		moveq	#7,d0									; prepare multiplication 100 / 2 for BG scrolling

		move.w	(v_scrshiftx).w,d4						; load horizontal movement distance (Since last frame)
		ext.l	d4										; extend to long-word signed
		asl.l	d0,d4									; align as fixed point 16, but divide by 2 for BG
		move.w	(v_scrshifty).w,d5						; load vertical movement distance (Since last frame)
		ext.l	d5										; extend to long-word signed
		asl.l	d0,d5									; align as fixed point 16, but divide by 2 for BG
		bsr.w	BGScroll_XY								; rev01 scrolling	; ''

		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w	; set BG V-scroll position
		lea		(v_hscrolltablebuffer).w,a1				; load H-scroll buffer
		move.w	(v_screenposx).w,d0						; load FG X position
		add.w	d7,d0
		neg.w	d0										; reverse
		swap	d0										; send to upper word
		move.w	(v_bgscreenposx).w,d0					; load BG X position
		add.w	d7,d0
		neg.w	d0										; reverse
		moveq	#0,d3									; clear d3
		move.b	(v_lz_deform).w,d3						; load wave-scroll timer
		addi.w	#$80,(v_lz_deform).w					; increase wave-scroll timer
		move.w	#224,d2									; prepare water-line count
	; LZ3 Palette Split fix
		bsr.w	LZWaterCameraY
		neg.w	d1
		add.w	(v_waterpos_actual).w,d1				; water Y minus camera Y
	; LZ Palette Split fix end
		bmi.s	.water									; if the screen is already underwater, branch
		cmp.w	d2,d1									; is the water line below the screen?
		ble.s	.nowater								; if not, branch
		move.w	d2,d1									; set at maximum

	.nowater:
		sub.w	d1,d2									; subtract from water-line count
		add.b	d1,d3									; advance scroll wave timer to correct amount
		subq.b	#1,d1									; decrease above water count
		bcs.s	.water									; if finished, branch
		
		move.w	d1,d4
		lsr.w	#3,d1									; additional passes of eight lines
		andi.w	#7,d4									; first pass: 1-8 lines
		neg.w	d4
		add.w	d4,d4									; each move.l instruction is 2 bytes
		jmp		.abovewater_last(pc,d4.w)

	.abovewater:
		rept 7
		move.l	d0,(a1)+								; save scroll position to buffer
		endr

	.abovewater_last:
		move.l	d0,(a1)+								; save scroll position to buffer
		dbf		d1,.abovewater							; repeat for all above water lines

	.water:
		subq.b	#1,d2									; decrease below water count
		bcs.w	.finish									; if finished, branch

		move.w	d0,d1									; copy BG position back to d1
		swap	d0										; move FG position back to lower word in d0
		move.w	d3,d4									; copy sroll timer for BG use
		add.b	(v_screenposy+1).w,d3					; add FG Y position
		add.b	(v_bgscreenposy+1).w,d4					; add BG Y position
		add.w	d3,d3									; multiply by word size (2)
		add.w	d4,d4									; ''

		lea		DLZ_WaveBG(pc),a3						; load beginning of BG wave data
		adda.w	d4,a3									; advance to correct starting point
		move.b	(a3),d4									; get current position byte
		asr.b	#2,d4									; get only the position bits
		ext.w	d4										; extend to word
		add.w	d4,d1									; adjust BG's current position

		lea		DLZ_WaveFG(pc,d3.w),a2					; load correct starting point of FG wave data
		move.b	(a2),d4									; get current position byte
		asr.b	#2,d4									; get only the position bits
		ext.w	d4										; extend to word
		add.w	d4,d0									; adjust FG's current position

		move.w	d2,d4
		lsr.w	#3,d2									; additional passes of eight lines
		andi.w	#7,d4									; first pass contains 1–8 lines
		neg.w	d4
		lsl.w	#3,d4									; each scanline's code is 8 bytes
		jmp		.belowwater_last(pc,d4.w)

	.belowwater:
		rept 7
		add.w	(a2)+,d0								; advance FG distortion
		move.w	d0,(a1)+								; save to FG scroll buffer
		add.w	(a3)+,d1								; advance BG distortion
		move.w	d1,(a1)+								; save to BG scroll buffer
		endr

	.belowwater_last:
		add.w	(a2)+,d0								; advance FG distortion
		move.w	d0,(a1)+								; save to FG scroll buffer
		add.w	(a3)+,d1								; advance BG distortion
		move.w	d1,(a1)+								; save to BG scroll buffer
		dbf		d2,.belowwater

	.finish:
		rts												; return
; ===========================================================================

; ---------------------------------------------------------------------------
; Return the camera's Y position (wrapped)
; ---------------------------------------------------------------------------

LZWaterCameraY:
		move.w	(v_screenposy).w,d1
		cmpi.w	#LevelYWrapTop,(v_limittop).w			; is level vertically wrapped?
		bne.s	.done									; if not, branch
		andi.w	#LevelYWrapMask,d1						; wrap screen Y-pos

	.done:
		rts
; ---------------------------------------------------------------------------
; Deformation conversion documentation and macro
; IIII IIAA AAAA AAAA
; I = initial value
; A = accumulator
.dlzrip_I	:= 0
dlzripple macro data
	if "data"<>""
	dc.w (.dlzrip_I&$3F)<<10|(data-.dlzrip_I)&$3FF
.dlzrip_I	:= data
	shift
	dlzripple ALLARGS
	endif
	endm
; ===========================================================================
; FG ripple data
DLZ_WaveFG:
.dlzrip_I	:= 0
	rept 2
	dlzripple  1, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 1, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple -1,-1,-2,-2,-3,-3,-3,-3,-2,-2,-1,-1, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  1, 1, 2, 2, 3, 3, 3, 3, 2, 2, 1, 1, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	dlzripple  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	endr
; ===========================================================================
; BG ripple data
DLZ_WaveBG:
.dlzrip_I	:= -1
	rept 4
	dlzripple  0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
	dlzripple  2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
	dlzripple  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
	dlzripple  2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
	dlzripple  0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3
	dlzripple -3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
	dlzripple -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3
	dlzripple -3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1
	endr
; ===========================================================================

; ---------------------------------------------------------------------------
; Marble Zone background layer deformation code
; ---------------------------------------------------------------------------

Deform_MZ:
	; block 1 - dungeon interior
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4			; 25.78% scrolling
		moveq	#2,d6
		bsr.w	BGScroll_Block1

	; block 3 - mountains
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4			; 25% scrolling
		moveq	#6,d6
		bsr.w	BGScroll_Block3

	; block 2 - bushes & antique buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4			; 50% scrolling
		moveq	#4,d6
		bsr.w	BGScroll_Block2

	; calculate y-position of background
		move.w	#$200,d0	; start with 512px, ignoring 2 chunks
		move.w	(v_screenposy).w,d1
		subi.w	#$1C8,d1	; 56px before inner sections
		bcs.s	.noYscroll	; 0% scrolling when y <= 56px
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1		; y * 3
		asr.w	#2,d1
		add.w	d1,d0		; 75% scrolling

	.noYscroll:
		move.w	d0,(v_bg2screenposy).w
		move.w	d0,(v_bg3screenposy).w
		bsr.w	BGScroll_YAbsolute
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w
	; do something with redraw flags
		move.b	(v_bg1_scroll_flags).w,d0
		or.b	(v_bg2_scroll_flags).w,d0
		or.b	d0,(v_bg3_scroll_flags).w
		clr.b	(v_bg1_scroll_flags).w
		clr.b	(v_bg2_scroll_flags).w

	; Build one X-position entry for each background band
		lea		(v_bgscroll_buffer).w,a1
		clr.w	(a1)+		; unused 2 chunks

	; calculate background scroll buffer
		move.w	(v_screenposx).w,d2
		neg.w	d2

		move.w	d2,d0		; clouds
		asr.w	#2,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#5,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#6,d0		; fixed-point step between cloud bands

		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		neg.w	d3			; first band uses half the camera X
		moveq	#9,d1		; ten cloud bands

	.cloudLoop:
		move.w	d3,(a1)+	; clouds (8px instead of 16px)
		swap	d3
		sub.l	d0,d3		; advance to the next band's position
		swap	d3
		dbf		d1,.cloudLoop

		; Each remaining region needs one X-position entry
		move.w	(v_bg3screenposx).w,d0
		move.w	d0,(a1)+				; mountains

		move.w	(v_bg2screenposx).w,d0
		move.w	d0,(a1)+				; bushes and buildings

		move.w	(v_bgscreenposx).w,d0
		move.w	d0,(a1)+				; dungeon interior

	; process SLZ scroll
		lea		(BGScrollSize_MZ).l,a4
		lea		(v_bgscroll_buffer).w,a5
		jmp		(ProcessBGScroll).l
; End of function Deform_MZ

; ---------------------------------------------------------------------------
; Star Light Zone background layer deformation code
; ---------------------------------------------------------------------------

Deform_SLZ:
	; move the background vertically at half the camera's speed
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	Bg_Scroll_Y
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w
	
	; Build one X-position entry for each background band
		lea		(v_bgscroll_buffer).w,a1
		clr.w	(a1)+		; unused $C0 pixels

	; calculate background scroll buffer
		move.w	(v_screenposx).w,d2
		neg.w	d2

		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$1C,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0					; fixed-point step between star bands

		moveq	#0,d3
		move.w	d2,d3
		neg.w	d3						; start with 100% scrolling
		moveq	#$1B,d1					; 28 star bands

	.starLoop:
		move.w	d3,(a1)+				; stars
		swap	d3
		sub.l	d0,d3					; advance to the next band's position
		swap	d3
		dbf		d1,.starLoop

	; Upper buildings
		move.w	d2,d0
		asr.w	#3,d0
		move.w	d0,d1
		asr.w	#1,d1
		add.w	d1,d0		; 18.75% horizontal scrolling
		neg.w	d0
		move.w	d0,(a1)+

	; Lower buildings
		move.w	d2,d0
		asr.w	#2,d0		; 25% scrolling
		neg.w	d0
		move.w	d0,(a1)+

	; Lowest large buildings
		move.w	d2,d0
		asr.w	#1,d0		; 50% scrolling
		neg.w	d0
		move.w	d0,(a1)+

	; process SLZ scroll
		lea		(BGScrollSize_SLZ).l,a4
		lea		(v_bgscroll_buffer).w,a5
		jmp		(ProcessBGScroll).l
; ===========================================================================

;----------------------------------------------------------------------------
; S1 Legacy 16px deformation - removed
;----------------------------------------------------------------------------
;Bg_Scroll_X:


; ---------------------------------------------------------------------------
; Spring Yard Zone background layer deformation	code
; ---------------------------------------------------------------------------

Deform_SYZ:
	; Move the background vertically at 3/16 of the camera's speed
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#4,d5
		move.l	d5,d1
		asl.l	#1,d5
		add.l	d1,d5
		bsr.w	Bg_Scroll_Y
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

	; calculate background scroll buffer
		lea	(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2

	; Calculate the gradient across the eight cloud bands
		move.w	d2,d0		; clouds
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		;asr.w	#3,d0		; incorrect
		divs.w	#8,d0		; retain Fixed's division
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0		; fixed-point step between cloud bands

		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3		; start with 50% scrolling
		moveq	#7,d1		; eight cloud bands
		neg.w	d3

	.cloudLoop:		
		move.w	d3,(a1)+	; clouds
		swap	d3
		sub.l	d0,d3
		swap	d3
		dbf		d1,.cloudLoop
		
		move.w	d2,d0
		asr.w	#3,d0		; 12.5% scrolling
		neg.w	d0		; mountains
		move.w	d0,(a1)+

		move.w	d2,d0
		asr.w	#2,d0		; 25% scrolling
		neg.w	d0		; buildings
		move.w	d0,(a1)+

		move.w	d2,d0
		move.w	d2,d1
		asr.w	#1,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$E,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0		; fixed-point step between bush bands

		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3		; start with 50% scrolling
		moveq	#$D,d1		; fourteen bush bands
		neg.w	d3

	.bushLoop:		
		move.w	d3,(a1)+	; bushes
		swap	d3
		sub.l	d0,d3
		swap	d3
		dbf		d1,.bushLoop

	; Extend the lowest bush band's scrolling over the final region
		move.w	-2(a1),d0				; reload the last position written
		move.w	d0,(a1)+				; position for the $7FFF band

	; process SYZ scroll
		lea		(BGScrollSize_SYZ).l,a4
		lea		(v_bgscroll_buffer).w,a5
		jmp		ProcessBGScroll
; End of function Deform_SYZ

; ---------------------------------------------------------------------------
; Scrap	Brain Zone background layer deformation	code
; ---------------------------------------------------------------------------

Deform_SBZ:
		tst.b	(v_act).w				; is it act 1?
		bne.w	Deform_SBZ2				; if not, branch

	; block 1 - lower black buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#7,d4					; 50% scrolling
		moveq	#2,d6
		bsr.w	BGScroll_Block1

	; block 3 - distant brown buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#6,d4					; 25% scrolling
		moveq	#6,d6
		bsr.w	BGScroll_Block3

	; block 2 - upper black buildings
		move.w	(v_scrshiftx).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4					; 13.28% scrolling
		moveq	#4,d6
		bsr.w	BGScroll_Block2

	; vertical scrolling
		moveq	#0,d4
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#5,d5					; 12.5% vertical scrolling
		bsr.w	BGScroll_YRelative

		move.w	(v_bgscreenposy).w,d0
		move.w	d0,(v_bg2screenposy).w
		move.w	d0,(v_bg3screenposy).w
		move.w	d0,(v_bgscrposy_vdp).w
		move.b	(v_bg1_scroll_flags).w,d0
		or.b	(v_bg3_scroll_flags).w,d0
		or.b	d0,(v_bg2_scroll_flags).w
		clr.b	(v_bg1_scroll_flags).w
		clr.b	(v_bg3_scroll_flags).w

	; Build one X-position entry for each background band
		lea		(v_bgscroll_buffer).w,a1
		move.w	(v_screenposx).w,d2
		neg.w	d2
		asr.w	#2,d2

	; Calculate the gradient across the four cloud bands
		move.w	d2,d0
		asr.w	#1,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#4,d0					; retain Fixed's cloud division
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0					; fixed-point step between cloud bands

		moveq	#0,d3
		move.w	d2,d3
		neg.w	d3						; first band uses one quarter of camera X
		moveq	#3,d1					; four cloud bands

	.cloudLoop:
		move.w	d3,(a1)+
		swap	d3
		sub.l	d0,d3
		swap	d3
		dbf		d1,.cloudLoop

 ; Each building region needs one X-position entry
		move.w	(v_bg3screenposx).w,d0
		move.w	d0,(a1)+				; distant brown buildings

		move.w	(v_bg2screenposx).w,d0
		move.w	d0,(a1)+				; upper black buildings

		move.w	(v_bgscreenposx).w,d0
		move.w	d0,(a1)+				; lower black buildings

 ; Expand the band positions into the 224-line scroll table
		lea		(BGScrollSize_SBZ1).l,a4
		lea		(v_bgscroll_buffer).w,a5
		jmp		(ProcessBGScroll).l
;-------------------------------------------------------------------------------

Deform_SBZ2:
	; plain background deformation
		move.w	(v_scrshiftx).w,d4
		ext.l	d4		
		asl.l	#6,d4		; 25% horizontal scrolling
		move.w	(v_scrshifty).w,d5
		ext.l	d5
		asl.l	#5,d5		; 12.5% vertical scrolling
		bsr.w	BGScroll_XY
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

	; copy fg & bg x-position to hscroll table
		lea	(v_hscrolltablebuffer).w,a1	; copy fg and bg positions to hscroll
		move.w	#223,d1
		move.w	(v_screenposx).w,d0
		neg.w	d0
		swap	d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0

	.loop:		
		move.l	d0,(a1)+
		dbf		d1,.loop
		rts
; End of function Deform_SBZ

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level horizontally as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHoriz:
		move.w	(v_screenposx).w,d4 ; save old screen position
		bsr.s	MoveScreenHoriz
		move.w	(v_screenposx).w,d0
		andi.w	#$10,d0
		move.b	(v_fg_xblock).w,d1
		eor.b	d1,d0
		bne.s	.return
		eori.b	#$10,(v_fg_xblock).w
		move.w	(v_screenposx).w,d0
		sub.w	d4,d0		; compare new with old screen position
		bpl.s	.scrollRight

		bset	#2,(v_fg_scroll_flags).w ; screen moves backward
		rts	

	.scrollRight:
		bset	#3,(v_fg_scroll_flags).w ; screen moves forward

	.return:
		rts	
; End of function ScrollHoriz


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MoveScreenHoriz:

	if CameraDashLag	; Camera Lag applied when dashing
		move.b	(v_cameralag).w,d1
		beq.s	.cont1
		tst.w	(v_player+obVelX).w		; is Sonic moving horizontally?
		bne.s	.cont0
		clr.b	(v_cameralag).w			; clear lag
		bra.s	.cont1

	.cont0:
		subq.b	#1,d1
		move.b	d1,(v_cameralag).w
		lsl.b	#2,d1
		addq.b	#4,d1
		move.w	(v_trackpos).w,d0
		sub.b	d1,d0
		lea		(v_tracksonic).w,a1
		move.w	(a1,d0.w),d0
		and.w	#$3FFF,d0
		bra.s	.cont2

	.cont1:
		move.w	(v_player+obX).w,d0

	.cont2:
	else
		move.w	(v_player+obX).w,d0
	endif	; Spin Dash Enabled End

		sub.w	(v_screenposx).w,d0		; Sonic's distance from left edge of screen
		
	if CDCamera
		sub.w	(v_camera_pan).w,d0		; Horizontal camera pan value
		beq.s	SH_ProperlyFramed		; if zero, branch
		bcs.s	SH_BehindMid			; if less than, branch
		bra.s	SH_AheadOfMid			; branch
	else

		; Centered Camera is only possible when CDCamera is disabled
		if CenteredCamera
			subi.w	#320/2,d0				; is distance less than 144px?
			bmi.s	SH_BehindMid			; if yes, branch			<---- cs to mi (for negative)
		else
			subi.w	#144,d0					; is distance less than 144px?
			bmi.s	SH_BehindMid			; if yes, branch	<---- cs to mi (for negative) MarkeyJester Horizontal Screen Scrolling Fix
			subi.w	#16,d0					; is distance more than 160px?
		endif
	
	endif

		bpl.s	SH_AheadOfMid			; if yes, branch	<---- cc to pl (for negative) MarkeyJester Horizontal Screen Scrolling Fix
		clr.w	(v_scrshiftx).w
		rts

	if CDCamera
; ===========================================================================

SH_ProperlyFramed:
		clr.w	(v_scrshiftx).w
		rts
	endif
; ===========================================================================

SH_AheadOfMid:
		cmpi.w	#16,d0					; is Sonic within 16px of middle area?
		blo.s	SH_Ahead16				; if yes, branch
		move.w	#16,d0					; set to 16 if greater

SH_Ahead16:
		add.w	(v_screenposx).w,d0
		cmp.w	(v_limitright).w,d0
		blt.s	SH_SetScreen
		move.w	(v_limitright).w,d0

SH_SetScreen:
		move.w	d0,d1
		sub.w	(v_screenposx).w,d1
		asl.w	#8,d1
		move.w	d0,(v_screenposx).w		; set new screen position
		move.w	d1,(v_scrshiftx).w		; set distance for screen movement
		rts	
; ===========================================================================

SH_BehindMid:
	; MarkeyJester Horizontal Screen Scrolling Fix
		cmpi.w	#-16,d0	; has the screen moved more than 16 pixels left?
		bcc.s	SH_Behind16	; if not, branch
		move.w	#-16,d0	; set the maximum move distance to 16 pixels left

SH_Behind16:
	; Horizontal Screen Scrolling Fix End
		add.w	(v_screenposx).w,d0
		cmp.w	(v_limitleft).w,d0
		bgt.s	SH_SetScreen
		move.w	(v_limitleft).w,d0
		bra.s	SH_SetScreen
; End of function MoveScreenHoriz

; ===========================================================================
		tst.w	d0
		bpl.s	loc_6610
		move.w	#-2,d0
		bra.s	SH_BehindMid

loc_6610:
		move.w	#2,d0
		bra.s	SH_AheadOfMid

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level vertically as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollVertical:
		moveq	#0,d1
		move.w	(v_player+obY).w,d0
		sub.w	(v_screenposy).w,d0				; Sonic's distance from top of screen
        cmpi.w  #LevelYWrapTop,(v_limittop).w
        bne.s   .noWrap
        wrap_y_distance d0						; properly wrap that distance

	.noWrap:
		btst	#staSpin,(v_player+obStatus).w	; is Sonic rolling?
		beq.s	.notRolling						; if not, branch
		subq.w	#5,d0							; subtract difference between standing and rolling heights

	.notRolling:
	; KoH Debug Screen Movement Fix
		tst.b	(v_debuguse).w					; is Debug Mode enabled?
		bne.s	.skipRollCheck					; if yes, branch
	; Debug Screen Movement Fix end
		btst	#staAir,(v_player+obStatus).w	; is Sonic in the air?
		beq.s	.checkBoundaryCrossed_onGround	; if not, branch

	.skipRollCheck:
	; If Sonic's in the air, he has $20 pixels above and below him to move without disturbing the camera.
	; The camera movement is also only capped at $10 pixels.
		addi.w	#32,d0
		sub.w	(v_lookshift).w,d0
		bcs.s	.doScroll_fast				; If Sonic is above the boundary, scroll to catch up to him
		subi.w	#64,d0
		bcc.s	.doScroll_fast				; If Sonic is below the boundary, scroll to catch up to him
		tst.b	(f_bgscrollvert).w			; is the max Y pos changing?
		bne.s	.scrollUpOrDown_maxYPosChanging	; if it is, branch
		bra.s	.doNotScroll
; ===========================================================================

	.checkBoundaryCrossed_onGround:
		sub.w	(v_lookshift).w,d0		; subtract camera bias
		bne.s	.decideScrollType		; If Sonic has moved, scroll to catch up to him
		tst.b	(f_bgscrollvert).w		; is the max Y pos changing?
		bne.s	.scrollUpOrDown_maxYPosChanging	; if it is, branch

	.doNotScroll:
		clr.w	(v_scrshifty).w			; clear Y position difference (Camera_Y_pos_diff)
		rts	
; ===========================================================================

	.decideScrollType:
		cmpi.w	#$60,(v_lookshift).w	; is the camera bias normal?
		bne.s	.doScroll_slow			; if not, branch
		move.w	(v_player+obInertia).w,d1
		bpl.s	.positiveSpeed
		neg.w	d1				; get absolute value of player ground velocity

	.positiveSpeed:
		cmpi.w	#$800,d1		; is the player travelling very fast?
		bhs.s	.doScroll_fast	; if he is, branch
;	.doScroll_medium:
		move.w	#$600,d1		; If player is going too fast, cap camera movement to 6 pixels per frame
		cmpi.w	#6,d0			; is player going down too fast?
		bgt.s	.scrollDown_max	; if so, move camera at capped speed
		cmpi.w	#-6,d0			; is player going up too fast?
		blt.s	.scrollUp_max	; if so, move camera at capped speed
		bra.s	.scrollUpOrDown	; otherwise, move camera at player's speed
; ===========================================================================

.doScroll_slow:
		move.w	#$200,d1		; If player is going too fast, cap camera movement to 2 pixels per frame
		cmpi.w	#2,d0			; is player going down too fast?
		bgt.s	.scrollDown_max	; if so, move camera at capped speed
		cmpi.w	#-2,d0			; is player going up too fast?
		blt.s	.scrollUp_max	; if so, move camera at capped speed
		bra.s	.scrollUpOrDown	; otherwise, move camera at player's speed
; ===========================================================================

.doScroll_fast:
	; related code appears in ScrollBG
	; S3K uses 24 instead of 16
		move.w	#$1000,d1		; If player is going too fast, cap camera movement to 16 pixels per frame
		cmpi.w	#16,d0			; is player going down too fast?
		bgt.s	.scrollDown_max	; if so, move camera at capped speed
		cmpi.w	#-16,d0			; is player going up too fast?
		blt.s	.scrollUp_max	; if so, move camera at capped speed
		bra.s	.scrollUpOrDown	; otherwise, move camera at player's speed
; ===========================================================================

	.scrollUpOrDown_maxYPosChanging:
		moveq	#0,d0			; Distance for camera to move = 0
		move.b	d0,(f_bgscrollvert).w	; clear camera max Y pos changing flag

	.scrollUpOrDown:
		moveq	#0,d1
		move.w	d0,d1			; get position difference
		add.w	(v_screenposy).w,d1	; add old camera Y position
		tst.w	d0				; is the camera to scroll down?
		bpl.w	.scrollDown	; if it is, branch
		bra.w	.scrollUp
; ===========================================================================

	.scrollUp_max:
		neg.w	d1				; make the value negative (since we're going backwards)
		ext.l	d1
		asl.l	#8,d1			; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
		add.l	(v_screenposy).w,d1	; add the two, getting the new Camera_Y_pos value
		swap	d1				; actual Y-coordinate is now the low word

	; Upward wrap
	.scrollUp:
		cmp.w	(v_limittop).w,d1	; is the new position less than the minimum Y pos?
		bgt.s	.doScroll			; if not, branch
		cmpi.w	#LevelYWrapTop,(v_limittop).w
		bne.s	.minYPosReached
		addi.w	#LevelYWrapSize,d1
		addi.w	#LevelYWrapSize,(v_screenposy).w
		bra.s	.doScroll
; ===========================================================================

	.minYPosReached:
		move.w	(v_limittop).w,d1	; prevent camera from going any further up
		bra.s	.doScroll
; ===========================================================================

	.scrollDown_max:
		ext.l	d1
		asl.l	#8,d1		; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
		add.l	(v_screenposy).w,d1	; add the two, getting the new Camera_Y_pos value
		swap	d1			; actual Y-coordinate is now the low word

	; Downward wrap
	.scrollDown:
		cmp.w	(v_limitbtm).w,d1	; is the new position greater than the maximum Y pos?
		blt.s	.doScroll			; if not, branch
		cmpi.w	#LevelYWrapTop,(v_limittop).w	; does the level wrap vertically?
		bne.s	.maxYPosReached					; if not, branch
		cmpi.w	#LevelYWrapSize,d1
		blt.s	.maxYPosReached
		subi.w	#LevelYWrapSize,d1
		subi.w	#LevelYWrapSize,(v_screenposy).w
		bra.s	.doScroll
; ===========================================================================

	.maxYPosReached:
		move.w	(v_limitbtm).w,d1		; prevent camera from going any further down

	.doScroll:
		move.w	(v_screenposy).w,d4		; get old pos (used by SetVertiScrollFlags)
		swap	d1						; actual Y-coordinate is now the high word, as Camera_Y_pos expects it
		move.l	d1,d3
		sub.l	(v_screenposy).w,d3
		ror.l	#8,d3
		move.w	d3,(v_scrshifty).w		; set difference between old and new positions
		move.l	d1,(v_screenposy).w		; set new camera Y pos

	; To-Do: Sonic 2 stops here...
	; It also uses registers. I need to look into what else is different.
		move.w	(v_screenposy).w,d0
		andi.w	#$10,d0
		move.b	(v_fg_yblock).w,d1
		eor.b	d1,d0
		bne.s	.return
		eori.b	#$10,(v_fg_yblock).w
		move.w	(v_screenposy).w,d0
		sub.w	d4,d0
		bpl.s	.scrollBottom
		bset	#0,(v_fg_scroll_flags).w
		rts	
; ===========================================================================

	.scrollBottom:
		bset	#1,(v_fg_scroll_flags).w

	.return:
		rts	
; End of function ScrollVertical


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; Scrolls background and sets redraw flags.
; d4 - background x offset * $10000
; d5 - background y offset * $10000

BGScroll_XY:
		move.l	(v_bgscreenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bgscreenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_xblock).w,d3
		eor.b	d3,d1
		bne.s	BGScroll_YRelative	; no change in Y
		eori.b	#$10,(v_bg1_xblock).w
		sub.l	d2,d0	; new - old
		bpl.s	.scrollRight
		bset	#2,(v_bg1_scroll_flags).w
		bra.s	BGScroll_YRelative
	.scrollRight:
		bset	#3,(v_bg1_scroll_flags).w
BGScroll_YRelative:
		move.l	(v_bgscreenposy).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	.return
		eori.b	#$10,(v_bg1_yblock).w
		sub.l	d3,d0
		bpl.s	.scrollBottom
		bset	#0,(v_bg1_scroll_flags).w
		rts
	.scrollBottom:
		bset	#1,(v_bg1_scroll_flags).w
	.return:
		rts
; End of function BGScroll_XY

Bg_Scroll_Y:
		move.l	(v_bgscreenposy).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(v_bgscreenposy).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	.return
		eori.b	#$10,(v_bg1_yblock).w
		sub.l	d3,d0
		bpl.s	.scrollBottom
		bset	#4,(v_bg1_scroll_flags).w
		rts
	.scrollBottom:
		bset	#5,(v_bg1_scroll_flags).w
	.return:
		rts


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BGScroll_YAbsolute:
		move.w	(v_bgscreenposy).w,d3
		move.w	d0,(v_bgscreenposy).w
		move.w	d0,d1
		andi.w	#$10,d1
		move.b	(v_bg1_yblock).w,d2
		eor.b	d2,d1
		bne.s	.return
		eori.b	#$10,(v_bg1_yblock).w
		sub.w	d3,d0
		bpl.s	.scrollBottom
		bset	#0,(v_bg1_scroll_flags).w
		rts
	.scrollBottom:
		bset	#1,(v_bg1_scroll_flags).w
	.return:
		rts
; End of function BGScroll_YAbsolute


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; d6 - bit to set for redraw

BGScroll_Block1:
		move.l	(v_bgscreenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bgscreenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg1_xblock).w,d3
		eor.b	d3,d1
		bne.s	.return
		eori.b	#$10,(v_bg1_xblock).w
		sub.l	d2,d0
		bpl.s	.scrollRight
		bset	d6,(v_bg1_scroll_flags).w
		bra.s	.return
	.scrollRight:
		addq.b	#1,d6
		bset	d6,(v_bg1_scroll_flags).w
	.return:
		rts
; End of function BGScroll_Block1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BGScroll_Block2:
		move.l	(v_bg2screenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bg2screenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg2_xblock).w,d3
		eor.b	d3,d1
		bne.s	.return
		eori.b	#$10,(v_bg2_xblock).w
		sub.l	d2,d0
		bpl.s	.scrollRight
		bset	d6,(v_bg2_scroll_flags).w
		bra.s	.return
	.scrollRight:
		addq.b	#1,d6
		bset	d6,(v_bg2_scroll_flags).w
	.return:
		rts
;-------------------------------------------------------------------------------
BGScroll_Block3:
		move.l	(v_bg3screenposx).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(v_bg3screenposx).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(v_bg3_xblock).w,d3
		eor.b	d3,d1
		bne.s	.return
		eori.b	#$10,(v_bg3_xblock).w
		sub.l	d2,d0
		bpl.s	.scrollRight
		bset	d6,(v_bg3_scroll_flags).w
		bra.s	.return
	.scrollRight:
		addq.b	#1,d6
		bset	d6,(v_bg3_scroll_flags).w
	.return:
		rts
