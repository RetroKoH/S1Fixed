; ---------------------------------------------------------------------------
; Subroutine to	animate	level graphics
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateLevelGfx:
		tst.b	(f_pause).w				; is the game paused?
		bne.s	.ispaused				; if yes, branch
		lea		(vdp_data_port).l,a6
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		move.w	AniArt_Index(pc,d0.w),d0
		jmp		AniArt_Index(pc,d0.w)

.ispaused:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Offset index for animated art routines
; ---------------------------------------------------------------------------
; ===========================================================================
AniArt_Index:	offsetTable
		offsetTableEntry.w	AniArt_GHZ		; Flowers
		offsetTableEntry.w	AniArt_LZ		; Conveyor Wheels (New)
		offsetTableEntry.w	AniArt_MZ		; Lava and Background Torches
		offsetTableEntry.w	AniArt_none
		offsetTableEntry.w	AniArt_none
		offsetTableEntry.w	AniArt_SBZ		; Background Smoke Clouds in Act 1
		zonewarning AniArt_Index,2
		offsetTableEntry.w	AniArt_Ending
; ===========================================================================

; ---------------------------------------------------------------------------
; Animated pattern routine - Green Hill
; ---------------------------------------------------------------------------

AniArt_GHZ:

AniArt_GHZ_Waterfall:

.size		= 8		; number of tiles per frame

		subq.b	#1,(v_lani0_time).w				; decrement timer
		bpl.s	AniArt_GHZ_Bigflower			; branch if not 0

		move.b	#5,(v_lani0_time).w				; time to display each frame
		lea		(Art_GhzWater).l,a1				; load waterfall patterns
		move.b	(v_lani0_frame).w,d0
		addq.b	#1,(v_lani0_frame).w			; increment frame counter
		andi.w	#1,d0							; there are only 2 frames
		beq.s	.isframe0						; branch if frame 0
		lea		.size*tile_size(a1),a1			; use graphics for frame 1

.isframe0:
		locVRAM	ArtTile_GHZ_Waterfall*tile_size	; VRAM address
		move.w	#.size-1,d1						; number of 8x8	tiles
		bra.w	LoadTiles
; ===========================================================================

; Sunflower -- Increase from 2 to 4 frames
AniArt_GHZ_Bigflower:

.size		= 16	; number of tiles per frame

		subq.b	#1,(v_lani1_time).w				; decrement timer
		bpl.s	AniArt_GHZ_Smallflower			; branch if not 0

		move.b	#$F,(v_lani1_time).w			; time to display each frame
		lea		(Art_GhzFlower1).l,a1			; load big flower patterns
		move.b	(v_lani1_frame).w,d0
		addq.b	#1,(v_lani1_frame).w			; increment frame counter
		andi.w	#1,d0							; there are only 2 frames
		beq.s	.isframe0						; branch if frame 0
		lea		.size*tile_size(a1),a1			; use graphics for frame 1

.isframe0:
		locVRAM	ArtTile_GHZ_Sunflower*tile_size	; VRAM address
		move.w	#.size-1,d1						; number of 8x8	tiles
		bra.w	LoadTiles
; ===========================================================================

; Purple flower -- Increase frames
AniArt_GHZ_Smallflower:

.size		= 12	; number of tiles per frame

		subq.b	#1,(v_lani2_time).w		; decrement timer
		bpl.s	.end					; branch if not 0

		move.b	#7,(v_lani2_time).w		; time to display each frame
		move.b	(v_lani2_frame).w,d0
		addq.b	#1,(v_lani2_frame).w	; increment frame counter
		andi.w	#3,d0					; there are 4 frames
		move.b	.sequence(pc,d0.w),d0
		btst	#0,d0					; is frame 0 or 2? (actual frame, not frame counter)
		bne.s	.isframe1				; if not, branch
		move.b	#$7F,(v_lani2_time).w	; set longer duration for frames 0 and 2

.isframe1:
		lsl.w	#7,d0					; multiply frame num by $80
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0					; multiply that by 3 (i.e. frame num times 12 * $20)
		locVRAM	ArtTile_GHZ_Purple_Flower*tile_size
		lea		(Art_GhzFlower2).l,a1	; load small flower patterns
		lea		(a1,d0.w),a1			; jump to appropriate tile
		move.w	#.size-1,d1				; number of 8x8	tiles
		bsr.w	LoadTiles

.end:
		rts	

.sequence:	dc.b 0,	1, 2, 1
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Labyrinth
; ---------------------------------------------------------------------------

AniArt_LZ:

; Conveyor Wheels
AniArt_LZ_Wheel:

.size		= $10	; number of tiles per frame

		moveq	#0,d0
		move.w	(v_framecount).w,d0
		andi.w	#3,d0
		bne.s	.dontchange
		lea		(Art_LzWheel).l,a1		; load wheel patterns
		moveq	#1,d1
		tst.b	(f_conveyrev).w			; have conveyors been reversed?
		beq.s	.notreverse				; if not, branch
		neg.b	d1

.notreverse:
		add.b	d1,(v_lani0_frame).w
		andi.b	#3,(v_lani0_frame).w
		
		move.b	(v_lani0_frame).w,d0
		mulu.w	#.size*tile_size,d0
		adda.w	d0,a1					; jump to appropriate tile
		locVRAM	ArtTile_LZ_Conveyor_Wheel*tile_size
		move.w	#.size-1,d1
		bsr.w	LoadTiles

.dontchange:
		rts
; ; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Marble
; ---------------------------------------------------------------------------

AniArt_MZ:

; Lava Surface
AniArt_MZ_Lava:

.size		= 8	; number of tiles per frame

		subq.b	#1,(v_lani0_time).w		; decrement timer
		bpl.s	AniArt_MZ_Magma			; branch if not 0

		move.b	#$13,(v_lani0_time).w	; time to display each frame
		lea		(Art_MzLava1).l,a1		; load lava surface patterns
		moveq	#0,d0
		move.b	(v_lani0_frame).w,d0
		addq.b	#1,d0					; increment frame counter
		cmpi.b	#3,d0					; there are 3 frames
		bne.s	.frame01or2				; branch if frame 0, 1 or 2
		moveq	#0,d0

.frame01or2:
		move.b	d0,(v_lani0_frame).w
		mulu.w	#.size*tile_size,d0
		adda.w	d0,a1					; jump to appropriate tile
		locVRAM	ArtTile_MZ_Animated_Lava*tile_size
		move.w	#.size-1,d1
		bsr.w	LoadTiles

; Flowing Lava
AniArt_MZ_Magma:
		subq.b	#1,(v_lani1_time).w		; decrement timer
		bpl.s	AniArt_MZ_Torch			; branch if not 0
		
		move.b	#1,(v_lani1_time).w		; time between each gfx change
		moveq	#0,d0
		move.b	(v_lani0_frame).w,d0	; get surface lava frame number
		lea		(Art_MzLava2).l,a4		; load magma gfx
		ror.w	#7,d0					; multiply frame num by $200 to get tile offset
		adda.w	d0,a4					; magma gfx + tile offset
		locVRAM	ArtTile_MZ_Animated_Magma*tile_size
		moveq	#0,d3
		move.b	(v_oscillate+$A).w,d3	; d3 = oscillating value
		move.w	#3,d2					; iterate 4 times, filling 4 tile spaces each time.

.loop:
		move.w	d3,d0					; d0 = tile offset + osc value
		add.w	d0,d0					; multiply by 2
		andi.w	#$1E,d0					; cap value at $1E
		lea		(AniArt_MZextra).l,a3
		move.w	(a3,d0.w),d0
		lea		(a3,d0.w),a3
		movea.l	a4,a1
		move.w	#$1F,d1
		jsr		(a3)
		addq.w	#4,d3
		dbf		d2,.loop
		rts	
; ===========================================================================

; Torch
AniArt_MZ_Torch:

.size		= 6	; number of tiles per frame

		subq.b	#1,(v_lani2_time).w		; decrement timer
		bpl.w	.end					; branch if not 0
		
		move.b	#7,(v_lani2_time).w		; time to display each frame
		lea		(Art_MzTorch).l,a1		; load torch patterns
		moveq	#0,d0
		move.b	(v_lani3_frame).w,d0
		addq.b	#1,(v_lani3_frame).w	; increment frame counter
		andi.b	#3,(v_lani3_frame).w	; there are 3 frames
		mulu.w	#.size*tile_size,d0
		adda.w	d0,a1					; jump to appropriate tile
		locVRAM	ArtTile_MZ_Torch*tile_size
		move.w	#.size-1,d1
		bra.w	LoadTiles

.end:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Scrap Brain
; ---------------------------------------------------------------------------

AniArt_SBZ:

.size		= 12	; number of tiles per frame

		tst.b	(v_lani2_frame).w
		beq.s	.smokepuff				; branch if counter hits 0
		
		subq.b	#1,(v_lani2_frame).w	; decrement counter
		bra.s	.chk_smokepuff2
; ===========================================================================

.smokepuff:
		subq.b	#1,(v_lani0_time).w		; decrement timer
		bpl.s	.chk_smokepuff2			; branch if not 0
		
		move.b	#7,(v_lani0_time).w		; time to display each frame
		lea		(Art_SbzSmoke).l,a1		; load smoke patterns
		locVRAM	ArtTile_SBZ_Smoke_Puff_1*tile_size
		move.b	(v_lani0_frame).w,d0
		addq.b	#1,(v_lani0_frame).w	; increment frame counter
		andi.w	#7,d0
		beq.s	.untilnextpuff			; branch if frame 0
		subq.w	#1,d0
		mulu.w	#.size*tile_size,d0
		lea		(a1,d0.w),a1
		move.w	#.size-1,d1
		bra.w	LoadTiles
; ===========================================================================

.untilnextpuff:
		move.b	#180,(v_lani2_frame).w	; time between smoke puffs (3 seconds)

.clearsky:
		move.w	#(.size/2)-1,d1
		bsr.w	LoadTiles
		lea		(Art_SbzSmoke).l,a1
		move.w	#(.size/2)-1,d1
		bra.w	LoadTiles				; load blank tiles for no smoke puff
; ===========================================================================

.chk_smokepuff2:
		tst.b	(v_lani2_time).w
		beq.s	.smokepuff2				; branch if counter hits 0
		
		subq.b	#1,(v_lani2_time).w		; decrement counter
		bra.s	.end
; ===========================================================================

.smokepuff2:
		subq.b	#1,(v_lani1_time).w		; decrement timer
		bpl.s	.end					; branch if not 0
		
		move.b	#7,(v_lani1_time).w		; time to display each frame
		lea		(Art_SbzSmoke).l,a1		; load smoke patterns
		locVRAM	ArtTile_SBZ_Smoke_Puff_2*tile_size
		move.b	(v_lani1_frame).w,d0
		addq.b	#1,(v_lani1_frame).w	; increment frame counter
		andi.w	#7,d0
		beq.s	.untilnextpuff2			; branch if frame 0
		subq.w	#1,d0
		mulu.w	#.size*tile_size,d0
		lea		(a1,d0.w),a1
		move.w	#.size-1,d1
		bra.w	LoadTiles
; ===========================================================================

.untilnextpuff2:
		move.b	#120,(v_lani2_time).w ; time between smoke puffs (2 seconds)
		bra.s	.clearsky
; ===========================================================================

.end:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - ending sequence
; ---------------------------------------------------------------------------

AniArt_Ending:

AniArt_Ending_BigFlower:

.size		= 16	; number of tiles per frame

		subq.b	#1,(v_lani1_time).w					; decrement timer
		bpl.s	AniArt_Ending_SmallFlower			; branch if not 0
		
		move.b	#7,(v_lani1_time).w
		lea		(Art_GhzFlower1).l,a1				; load big flower patterns
		lea		((v_128x128+$1000)&$FFFFFF).l,a2	; load 2nd big flower from RAM
		move.b	(v_lani1_frame).w,d0
		addq.b	#1,(v_lani1_frame).w				; increment frame counter
		andi.w	#1,d0								; only 2 frames
		beq.s	.isframe0							; branch if frame 0
		lea		.size*tile_size(a1),a1
		lea		.size*tile_size(a2),a2

.isframe0:
		locVRAM	ArtTile_GHZ_Sunflower*tile_size		; VRAM address
		move.w	#.size-1,d1							; number of 8x8	tiles
		bsr.w	LoadTiles
		movea.l	a2,a1
		locVRAM	ArtTile_GHZ_Big_Flower_2*tile_size	; VRAM address
		move.w	#.size-1,d1							; number of 8x8	tiles
		bra.w	LoadTiles
; ===========================================================================

AniArt_Ending_SmallFlower:

.size		= 12	; number of tiles per frame

		subq.b	#1,(v_lani2_time).w				; decrement timer
		bpl.s	AniArt_Ending_Flower3			; branch if not 0
		
		move.b	#7,(v_lani2_time).w
		move.b	(v_lani2_frame).w,d0
		addq.b	#1,(v_lani2_frame).w			; increment frame counter
		andi.w	#7,d0							; max 8 frames
		move.b	.sequence(pc,d0.w),d0			; get actual frame num from sequence data
		lsl.w	#7,d0							; multiply by $80
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0							; multiply by 3
		locVRAM	ArtTile_GHZ_Purple_Flower*tile_size
		lea		(Art_GhzFlower2).l,a1			; load small flower patterns
		lea		(a1,d0.w),a1					; jump to appropriate tile
		move.w	#.size-1,d1						; number of 8x8	tiles
		bra.w	LoadTiles
; ===========================================================================
.sequence:	dc.b 0,	0, 0, 1, 2, 2, 2, 1
; ===========================================================================

AniArt_Ending_Flower3:

.size		= 16	; number of tiles per frame

		subq.b	#1,(v_lani4_time).w 					; decrement timer
		bpl.s	AniArt_Ending_Flower4 					; branch if not 0
		
		move.b	#$E,(v_lani4_time).w
		move.b	(v_lani4_frame).w,d0
		addq.b	#1,(v_lani4_frame).w					; increment frame counter
		andi.w	#3,d0									; max 4 frames
		move.b	AniArt_Ending_Flower3_sequence(pc,d0.w),d0 ; get actual frame num from sequence data
		lsl.w	#8,d0									; multiply by $100
		add.w	d0,d0									; multiply by 2
		locVRAM	ArtTile_GHZ_Flower_3*tile_size
		lea		((v_128x128+$1000+$400)&$FFFFFF).l,a1	; load special flower patterns (from RAM)
		lea		(a1,d0.w),a1							; jump to appropriate tile
		move.w	#.size-1,d1
		bra.w	LoadTiles
; ===========================================================================
AniArt_Ending_Flower3_sequence:	dc.b 0,	1, 2, 1
; ===========================================================================

AniArt_Ending_Flower4:

.size		= 16	; number of tiles per frame

		subq.b	#1,(v_lani5_time).w						; decrement timer
		bpl.s	.end									; branch if not 0
		
		move.b	#$B,(v_lani5_time).w
		move.b	(v_lani5_frame).w,d0
		addq.b	#1,(v_lani5_frame).w					; increment frame counter
		andi.w	#3,d0
		move.b	AniArt_Ending_Flower3_sequence(pc,d0.w),d0 ; get actual frame num from sequence data
		lsl.w	#8,d0									; multiply by $100
		add.w	d0,d0									; multiply by 2
		locVRAM	ArtTile_GHZ_Flower_4*tile_size
		lea		((v_128x128+$1000+$A00)&$FFFFFF).l,a1	; load special flower patterns (from RAM)
		lea		(a1,d0.w),a1							; jump to appropriate tile
		move.w	#.size-1,d1
		bra.w	LoadTiles
; ===========================================================================

.end:
		rts	
; ===========================================================================

AniArt_none:
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	transfer graphics to VRAM

; input:
;	a1 = source address
;	a6 = vdp_data_port ($C00000)
;	d1 = number of tiles to load (minus one)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTiles:
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		dbf		d1,LoadTiles
		rts	
; End of function LoadTiles

; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - more Marble Zone
; ---------------------------------------------------------------------------
AniArt_MZextra:
		dc.w loc_1C3EE-AniArt_MZextra, loc_1C3FA-AniArt_MZextra
		dc.w loc_1C410-AniArt_MZextra, loc_1C41E-AniArt_MZextra
		dc.w loc_1C434-AniArt_MZextra, loc_1C442-AniArt_MZextra
		dc.w loc_1C458-AniArt_MZextra, loc_1C466-AniArt_MZextra
		dc.w loc_1C47C-AniArt_MZextra, loc_1C48A-AniArt_MZextra
		dc.w loc_1C4A0-AniArt_MZextra, loc_1C4AE-AniArt_MZextra
		dc.w loc_1C4C4-AniArt_MZextra, loc_1C4D2-AniArt_MZextra
		dc.w loc_1C4E8-AniArt_MZextra, loc_1C4FA-AniArt_MZextra
; ===========================================================================

loc_1C3EE:
		move.l	(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C3EE
		rts	
; ===========================================================================

loc_1C3FA:
		move.l	2(a1),d0
		move.b	1(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C3FA
		rts	
; ===========================================================================

loc_1C410:
		move.l	2(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C410
		rts	
; ===========================================================================

loc_1C41E:
		move.l	4(a1),d0
		move.b	3(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C41E
		rts	
; ===========================================================================

loc_1C434:
		move.l	4(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C434
		rts	
; ===========================================================================

loc_1C442:
		move.l	6(a1),d0
		move.b	5(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C442
		rts	
; ===========================================================================

loc_1C458:
		move.l	6(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C458
		rts	
; ===========================================================================

loc_1C466:
		move.l	8(a1),d0
		move.b	7(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C466
		rts	
; ===========================================================================

loc_1C47C:
		move.l	8(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C47C
		rts	
; ===========================================================================

loc_1C48A:
		move.l	$A(a1),d0
		move.b	9(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C48A
		rts	
; ===========================================================================

loc_1C4A0:
		move.l	$A(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C4A0
		rts	
; ===========================================================================

loc_1C4AE:
		move.l	$C(a1),d0
		move.b	$B(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C4AE
		rts	
; ===========================================================================

loc_1C4C4:
		move.l	$C(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C4C4
		rts	
; ===========================================================================

loc_1C4D2:
		move.l	$C(a1),d0
		rol.l	#8,d0
		_move.b	0(a1),d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C4D2
		rts	
; ===========================================================================

loc_1C4E8:
		move.w	$E(a1),(a6)
		_move.w	0(a1),(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C4E8
		rts	
; ===========================================================================

loc_1C4FA:
		_move.l	0(a1),d0
		move.b	$F(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea		$10(a1),a1
		dbf		d1,loc_1C4FA
		rts
