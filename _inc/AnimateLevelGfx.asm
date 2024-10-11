; ---------------------------------------------------------------------------
; Subroutine to animate level graphics
; Credit: Selbi (EraZor)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateLevelGfx_Init:
		; Clear animated art slot RAM
		lea		(Anim_Counters).w,a1
		moveq	#0,d0
		move.l	d0,(a1)+
		move.l	d0,(a1)+

		; Setup animated art update pointer
		move.b	(v_zone).w,d0				; d0 = zone
		lsl.w	#3,d0						; d0 = zone * 8
		lea		AniArt_Index(pc,d0),a0
		movea.l	(a0)+,a1					; a1 = "initial draw" routine
		move.l	(a0)+,(v_lani_updateproc).w	; set "update" routine
		jmp		(a1)						; run "initial draw" routine
; ===========================================================================

; --------------------------------------------------------------
; Subroutine to update animated art during gameplay
; --------------------------------------------------------------

AnimateLevelGfx:
		tst.b	(f_pause).w					; is the game paused?
		bne.s	.ispaused					; if yes, branch
		movea.l	(v_lani_updateproc).w,a0
		jmp		(a0)

.ispaused:
		rts

; ---------------------------------------------------------------------------
; Offset index for animated art routines
; ---------------------------------------------------------------------------

AniArt_Index:
		dc.l	AniArt_GHZ_InitDraw,	AniArt_GHZ		; Waterfall/Flowers
		dc.l	AniArt_LZ_InitDraw,		AniArt_LZ		; Conveyor Wheels (New)
		dc.l	AniArt_MZ_InitDraw,		AniArt_MZ		; Lava and Background Torches
		dc.l	AniArt_Null,			AniArt_Null
		dc.l	AniArt_Null,			AniArt_Null
		dc.l	AniArt_SBZ_InitDraw,	AniArt_SBZ		; Background Smoke Clouds in Act 1
		zonewarning AniArt_Index,8
		dc.l	AniArt_Ending_InitDraw,	AniArt_Ending
; ===========================================================================

AniArt_Null:
		rts
; ===========================================================================

; --------------------------------------------------------------
; Animated art routines : GHZ
; --------------------------------------------------------------

AniArt_GHZ:
		add.b	#$2A,(v_lani0_time).w
		bcs.s	AniArt_GHZ_Waterfall

		add.b	#$10,(v_lani1_time).w
		bcs.s	AniArt_GHZ_Flower1

		add.b	#$20,(v_lani2_time).w 
		bcs.s	AniArt_GHZ_Flower2
		rts
; ===========================================================================

AniArt_GHZ_Waterfall:
		eor.b	#1,(v_lani0_frame).w
	
AniArt_GHZ_Waterfall_Draw:
		move.w	(v_lani0_frame).w,d0
		clr.b	d0
		lea		(Art_GhzWater).l,a0
		adda.w	d0,a0
		move.l	a0,d1								; d1 = transfer source
		move.w	#ArtTile_GHZ_Waterfall*tile_size,d2	; d2 = transfer destination
		move.w	#$100/2,d3							; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

AniArt_GHZ_Flower1:
		eor.b	#2,(v_lani1_frame).w

AniArt_GHZ_Flower1_Draw:
		move.w	(v_lani1_frame).w,d0
		clr.b	d0   
		lea		(Art_GhzFlower1).l,a0
		adda.w	d0,a0
		move.l	a0,d1								; d1 = transfer source
		move.w	#ArtTile_GHZ_Sunflower*tile_size,d2	; d2 = transfer destination
		move.w	#$200/2,d3							; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================
AniArt_GHZ_InitDraw:
		bsr.s	AniArt_GHZ_Waterfall_Draw   
		bsr.s	AniArt_GHZ_Flower1_Draw
		;bra.s	AniArt_GHZ_Flower2_Draw
; ===========================================================================

AniArt_GHZ_Flower2_Draw:
		moveq	#32*2-1,d0
		and.b	(v_lani2_frame).w,d0
		move.w	AniArt_GHZ_Flower2_FrameOffsets(pc,d0),d0
		and.w	#$7FFF,d0
		bra.s	AniArt_GHZ_Flower2_Render	
; ===========================================================================

AniArt_GHZ_Flower2:
		addq.b	#2,(v_lani2_frame).w
		moveq	#32*2-1,d0
		and.b	(v_lani2_frame).w,d0
		move.w	AniArt_GHZ_Flower2_FrameOffsets(pc,d0),d0
		bmi.s	AniArt_GHZ_Flower2_Skip					; if frame is the same as the previous one, skip

AniArt_GHZ_Flower2_Render:
		lea 	(Art_GhzFlower2).l,a0
		adda.w	d0,a0
		move.l	a0,d1									; d1 = transfer source
		move.w	#ArtTile_GHZ_Purple_Flower*tile_size,d2	; d2 = transfer destination
		move.w	#$180/2,d3								; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l	

AniArt_GHZ_Flower2_Skip:
		rts
; ===========================================================================

AniArt_GHZ_Flower2_FrameOffsets:
		dc.w 	$0000, $8000, $8000, $8000
		dc.w	$8000, $8000, $8000, $8000
		dc.w	$8000, $8000, $8000, $8000
		dc.w	$8000, $8000, $8000

		dc.w	$0180, $0300, $8300, $8300
		dc.w	$8300, $8300, $8300, $8300
		dc.w	$8300, $8300, $8300, $8300
		dc.w	$8300, $8300, $8300, $8300

		dc.w	$0180
; ===========================================================================

; --------------------------------------------------------------
; Animated art routines : LZ
; --------------------------------------------------------------

AniArt_LZ:
		moveq	#0,d0
		move.w	(v_framecount).w,d0
		andi.w	#3,d0
		beq.s	AniArt_LZ_Wheels
		rts
; ===========================================================================

AniArt_LZ_InitDraw:
		;bra.s	AniArt_LZ_Wheels
; ===========================================================================

AniArt_LZ_Wheels_Draw:
		moveq	#4*2-1,d0
		and.b	(v_lani0_frame).w,d0
		move.w	AniArt_LZ_Wheels_FrameOffsets(pc,d0),d0
		and.w	#$7FFF,d0
		bra.s	AniArt_LZ_Wheels_Render	
; ===========================================================================

AniArt_LZ_Wheels:
		moveq	#2,d1
		tst.b	(f_conveyrev).w			; have conveyors been reversed?
		beq.s	.notreverse				; if not, branch
		neg.b	d1

.notreverse:
		add.b	d1,(v_lani0_frame).w
		moveq	#4*2-1,d0
		and.b	(v_lani0_frame).w,d0
		move.w	AniArt_LZ_Wheels_FrameOffsets(pc,d0),d0
		bmi.s	AniArt_LZ_Wheels_Skip					; if frame is the same as the previous one, skip

AniArt_LZ_Wheels_Render:
		lea		(Art_LzWheel).l,a0
		adda.w	d0,a0
		move.l	a0,d1									; d1 = transfer source
		move.w	#ArtTile_LZ_Conveyor_Wheel*tile_size,d2	; d2 = transfer destintation
		move.w	#$200/2,d3								; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l

AniArt_LZ_Wheels_Skip:
		rts
; ===========================================================================

AniArt_LZ_Wheels_FrameOffsets:
		dc.w 	$0000, $0200, $0400, $0600
; ===========================================================================

; --------------------------------------------------------------
; Animated art routines : MZ
; --------------------------------------------------------------

AniArt_MZ:
		subq.b	#1,(v_lani0_time).w
		bpl.s	.lava_surface_done
		move.b	#$13,(v_lani0_time).w
		bra.s	AniArt_MZ_LavaSurface

.lava_surface_done:
		add.b	#$80,(v_lani1_time).w
		bcs.s	AniArt_MZ_LavaMain

		add.b	#$20,(v_lani2_time).w
		bcs.w	AniArt_MZ_Torch
		rts
; ===========================================================================

AniArt_MZ_InitDraw:
		bsr.s	AniArt_MZ_LavaSurface_Draw
		bsr.s	AniArt_MZ_LavaMain
		bra.s	AniArt_MZ_Torch_Draw
; ===========================================================================

AniArt_MZ_LavaSurface:
		addq.b	#1,(v_lani0_frame).w
		cmp.b	#3,(v_lani0_frame).w
		blo.s	AniArt_MZ_LavaSurface_Draw
		clr.b	(v_lani0_frame).w	
	
AniArt_MZ_LavaSurface_Draw:
		move.w	(v_lani0_frame).w,d0
		andi.w	#$300,d0
		lea		(Art_MzLava1).l,a0
		adda.w	d0,a0
		move.l	a0,d1									; d1 = transfer source
		move.w	#ArtTile_MZ_Animated_Lava*tile_size,d2	; d2 = transfer destintation
		move.w	#$100/2,d3								; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

AniArt_MZ_LavaMain:
		move.w	(v_lani0_frame).w,d0	; get surface lava frame number
		lea		(Art_MzLava2).l,a4		; a4 = lava 16x32 blocks base offset
		lea		$FFFFA200,a0			; a0 = art buffer (WARNING! Overlaps with the end of chunks data, but it should be unused in MZ)
		add.w	d0,d0
		andi.w	#$600,d0
		adda.w	d0,a4					; magma gfx + tile offset
		moveq	#0,d3
		move.b	(v_oscillate+$A).w,d3	; d3 = oscillating value
		moveq	#4-1,d2					; iterate 4 times, filling 4 tile spaces each time.

.render_loop:
		moveq	#$F,d0
		and.w	d3,d0
		add.w	d0,d0                                  
		lea 	AniArt_MZ_LavaRenderers(pc),a3
		add.w	(a3,d0),a3                        
		movea.l a4,a1					; a1 = art ptr
		jsr 	(a3)
		addq.w	#4,d3					; do next 8 pixels
		dbf 	d2,.render_loop

		move.l	#$FFA200,d1				; d1 = art buffer (WARNING! Overlaps with the end of chunks data, but it should be unused in MZ)
		move.w	#ArtTile_MZ_Animated_Magma*tile_size,d2
		move.w	#$200/2,d3
		jmp		(QueueDMATransfer).l
; ===========================================================================

AniArt_MZ_Torch:
		addq.b	#1,(v_lani3_frame).w
	
AniArt_MZ_Torch_Draw:
		lea		(Art_MzTorch).l,a0
		move.w	(v_lani3_frame).w,d0
		and.w	#$300,d0
		move.w	d0,d1
		lsr.w	#2,d1
		sub.w	d1,d0
		adda.w	d0,a0
		move.l	a0,d1							; d1 = transfer source
		move.w	#ArtTile_MZ_Torch*tile_size,d2	; d2 = transfer destintation
		move.w	#$C0/2,d3						; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

; ---------------------------------------------------------------------------
; MZ lava renderers
; Each routine handles the art starting at a different pixel offset
; ---------------------------------------------------------------------------
AniArt_MZ_LavaRenderers:	offsetTable
		offsetTableEntry.w	MZMagma_RendOffset0
		offsetTableEntry.w	MZMagma_RendOffset2
		offsetTableEntry.w	MZMagma_RendOffset4
		offsetTableEntry.w	MZMagma_RendOffset6
		offsetTableEntry.w	MZMagma_RendOffset8
		offsetTableEntry.w	MZMagma_RendOffset10
		offsetTableEntry.w	MZMagma_RendOffset12
		offsetTableEntry.w	MZMagma_RendOffset14
		offsetTableEntry.w	MZMagma_RendOffset16
		offsetTableEntry.w	MZMagma_RendOffset18
		offsetTableEntry.w	MZMagma_RendOffset20
		offsetTableEntry.w	MZMagma_RendOffset22
		offsetTableEntry.w	MZMagma_RendOffset24
		offsetTableEntry.w	MZMagma_RendOffset26
		offsetTableEntry.w	MZMagma_RendOffset28
		offsetTableEntry.w	MZMagma_RendOffset30
; ===========================================================================

MZMagma_RendOffset28:
	rept	$20
		move.w	$E(a1),(a0)+
		move.w	(a1),(a0)+
		lea		$10(a1),a1
	endr
		rts
; ===========================================================================

MZMagma_RendOffset24:
		lea		$C(a1),a1     
		bra.s	MZMagma_RenderTransDirect
; ===========================================================================

MZMagma_RendOffset20:
		addq.w	#2,a1

MZMagma_RendOffset16:
		addq.w	#8,a1
		bra.s	MZMagma_RenderTransDirect	
; ===========================================================================

MZMagma_RendOffset12:
		addq.w	#2,a1

MZMagma_RendOffset8:
		addq.w	#2,a1

MZMagma_RendOffset4:
		addq.w	#2,a1

MZMagma_RendOffset0:    
MZMagma_RenderTransDirect:
	rept	$20
		move.l	(a1),(a0)+
		lea		$10(a1),a1
	endr
		rts	
; ===========================================================================

MZMagma_RendOffset30:   	
	rept $20
		move.b	$F(a1),(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		lea		$10-3(a1),a1
	endr
		rts
; ===========================================================================

MZMagma_RendOffset26:
		lea		$D(a1),a1
	
	rept $20
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	-$10(a1),(a0)+
		lea		$10-3(a1),a1
	endr
		rts
; ===========================================================================

MZMagma_RendOffset22:
	lea		$B(a1),a1     
	bra.s	MZMagma_RenderTransDirectOdd
; ===========================================================================

MZMagma_RendOffset18:
		addq.w	#2,a1
	
MZMagma_RendOffset14:
		addq.w	#7,a1  
		bra.s	MZMagma_RenderTransDirectOdd		 
; ===========================================================================

MZMagma_RendOffset10:
		addq.w	#2,a1

MZMagma_RendOffset6:
		addq.w	#2,a1

MZMagma_RendOffset2:
		addq.w	#1,a1
		 
MZMagma_RenderTransDirectOdd:
	rept	$20
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		move.b	(a1)+,(a0)+
		lea		$C(a1),a1
	endr  
		rts			 
; ===========================================================================

; --------------------------------------------------------------
; Animated art routines : SBZ
; --------------------------------------------------------------

AniArt_SBZ_InitDraw:
		tst.b	(v_act).w								; only run on Act 1
		bne.s	.skip
		lea		(Art_SbzSmoke).l,a0						; load smoke patterns
		move.w	#ArtTile_SBZ_Smoke_Puff_1*tile_size,d2	; d2 = transfer destination
		bsr.s	AniArt_SBZ.clearsky
		lea		(Art_SbzSmoke).l,a0						; load smoke patterns
		move.w	#ArtTile_SBZ_Smoke_Puff_2*tile_size,d2	; d2 = transfer destination
		bra.s	AniArt_SBZ.clearsky

.skip:
		rts

AniArt_SBZ:
		tst.b	(v_act).w						; only run on Act 1
		bne.s	.skip
		tst.b	(v_lani2_frame).w
		beq.s	.smokepuff						; branch if counter hits 0
		
		subq.b	#1,(v_lani2_frame).w			; decrement counter
		bra.s	.chk_smokepuff2

.skip:
		rts
; ===========================================================================

.smokepuff:
		subq.b	#1,(v_lani0_time).w				; decrement timer
		bpl.s	.chk_smokepuff2					; branch if not 0

		move.b	#7,(v_lani0_time).w				; time to display each frame
		lea		(Art_SbzSmoke).l,a0				; load smoke patterns
		move.w	#ArtTile_SBZ_Smoke_Puff_1*tile_size,d2	; d2 = transfer destination
		move.w	(v_lani0_frame).w,d0			; d0 = current frame
		clr.b	d0
		addq.b	#1,(v_lani0_frame).w			; increment frame counter
		andi.w	#$700,d0						; cap at 7
		beq.s	.untilnextpuff					; branch if frame 0
		subi.w	#$100,d0						; frame - 1 (range: 0-6)
		adda.w	d0,a0
		move.l	a0,d1							; d1 = transfer source
												; d2 is already set up
		move.w	#$180/2,d3						; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

.untilnextpuff:
		move.b	#180,(v_lani2_frame).w			; time between smoke puffs (3 seconds)

.clearsky:
		move.l	a0,d1							; d1 = transfer source
												; d2 is already set up
		move.w	#$C0/2,d3						; d3 = transfer size (words)
		jsr		(QueueDMATransfer).l

	; reestablish values
		move.l	a0,d1							; d1 = transfer source
		move.w	#(ArtTile_SBZ_Smoke_Puff_1+6)*tile_size,d2	; d2 = next transfer destination
		move.w	#$C0/2,d3						; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l			; load blank tiles for no smoke puff
; ===========================================================================

.chk_smokepuff2:
		tst.b	(v_lani2_time).w
		beq.s	.smokepuff2						; branch if counter hits 0
		
		subq.b	#1,(v_lani2_time).w				; decrement counter
		bra.s	.end
; ===========================================================================

.smokepuff2:
		subq.b	#1,(v_lani1_time).w				; decrement timer
		bpl.s	.end							; branch if not 0
		
		move.b	#7,(v_lani1_time).w				; time to display each frame
		lea		(Art_SbzSmoke).l,a0				; load smoke patterns
		move.w	#ArtTile_SBZ_Smoke_Puff_2*tile_size,d2	; d2 = transfer destination
		move.w	(v_lani1_frame).w,d0			; d0 = current frame
		clr.b	d0
		addq.b	#1,(v_lani1_frame).w			; increment frame counter
		andi.w	#$700,d0						; cap at 7
		beq.s	.untilnextpuff2					; branch if frame 0
		subi.w	#$100,d0						; frame - 1 (range: 0-6)
		adda.w	d0,a0
		move.l	a0,d1							; d1 = transfer source
												; d2 is already set up
		move.w	#$180/2,d3						; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

.untilnextpuff2:
		move.b	#120,(v_lani2_time).w			; time between smoke puffs (2 seconds)
		;bra.s	.clearsky
		move.l	a0,d1							; d1 = transfer source
												; d2 is already set up
		move.w	#$C0/2,d3						; d3 = transfer size (words)
		jsr		(QueueDMATransfer).l

	; reestablish values
		move.l	a0,d1							; d1 = transfer source
		move.w	#(ArtTile_SBZ_Smoke_Puff_2+6)*tile_size,d2	; d2 = next transfer destination
		move.w	#$C0/2,d3						; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l			; load blank tiles for no smoke puff
; ===========================================================================

.end:
		rts	
; ===========================================================================

; --------------------------------------------------------------
; Animated art routines : Ending
; --------------------------------------------------------------

AniArt_Ending:
		add.b	#$20,(v_lani0_time).w
		bcs.s	AniArt_Ending_Flower1

		add.b	#$20,(v_lani1_time).w
		bcs.s	AniArt_Ending_Flower2

		add.b	#$11,(v_lani2_time).w
		bcs.w	AniArt_Ending_Flower3

		add.b	#$15,(v_lani3_time).w
		bcs.w	AniArt_Ending_Flower4
		rts
; ===========================================================================

AniArt_Ending_Flower1:
		eor.b	#2,(v_lani1_frame).w

AniArt_Ending_Flower1_Draw:
		move.w	(v_lani1_frame).w,d0
		clr.b	d0
		move.w	d0,d4									; copy for second use
		lea 	(Art_GhzFlower1).l,a0					; load big flower patterns
		adda.w	d0,a0
		move.l	a0,d1									; d1 = transfer source
		move.w	#ArtTile_GHZ_Sunflower*tile_size,d2		; d2 = VRAM address
		move.w	#$200/2,d3								; d3 = transfer size (words)
		jsr		(QueueDMATransfer).l

		lea		((v_128x128+$1000)&$FFFFFF).l,a0		; load 2nd big flower from RAM
		adda.w	d4,a0
		move.l	a0,d1									; d1 = transfer source
		move.w	#ArtTile_GHZ_Big_Flower_2*tile_size,d2	; d2 = VRAM address
		move.w	#$200/2,d3								; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

AniArt_Ending_Flower2:
		addq.b	#2,(v_lani2_frame).w

AniArt_Ending_Flower2_Draw:
		lea 	(Art_GhzFlower2).l,a0					; load small flower patterns
		moveq	#%1110,d0
		and.b	(v_lani2_frame).w,d0
		add.w	AniArt_Ending_Flower2_FrameOffsets(pc,d0),a0
		move.l	a0,d1									; d1 = transfer source
		move.w	#ArtTile_GHZ_Purple_Flower*tile_size,d2	; d2 = VRAM address
		move.w	#$200/2,d3								; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================

AniArt_Ending_Flower2_FrameOffsets:
		dc.w	$0000, $0000, $0000, $0180
		dc.w	$0300, $0300, $0300, $0180
; ===========================================================================

AniArt_Ending_InitDraw:
		bsr.s	AniArt_Ending_Flower1_Draw
		bsr.s	AniArt_Ending_Flower2_Draw
		bsr.s	AniArt_Ending_Flower4_Draw
		bra.s	AniArt_Ending_Flower3_Draw
; ===========================================================================

AniArt_Ending_Flower3:
		addq.b	#2,(v_lani3_frame).w

AniArt_Ending_Flower3_Draw:
		lea		((v_128x128+$1000+$400)&$FFFFFF).l,a0	; load special flower patterns (from RAM)
		moveq	#%110,d0
		and.b	(v_lani3_frame).w,d0
		add.w	AniArt_Ending_Flower3_FrameOffsets(pc,d0),a0
		move.l	a0,d1								; d1 = transfer source
		move.w	#ArtTile_GHZ_Flower_3*tile_size,d2	; d2 = VRAM address
		move.w	#$200/2,d3							; d3 = transfer size
		jmp		(QueueDMATransfer).l
; ===========================================================================

AniArt_Ending_Flower3_FrameOffsets:
		dc.w	$0000, $0200, $0400, $0200
; ===========================================================================

AniArt_Ending_Flower4:
		addq.b	#2,(v_lani4_frame).w		; frame = [0, 2, 4, 6]

AniArt_Ending_Flower4_Draw:
		lea		((v_128x128+$1000+$A00)&$FFFFFF).l,a0	; load special flower patterns (from RAM)
		moveq	#%110,d0
		and.b	(v_lani4_frame).w,d0
		add.w	AniArt_Ending_Flower3_FrameOffsets(pc,d0),a0
		move.l	a0,d1								; d1 = transfer source
		move.w	#ArtTile_GHZ_Flower_4*tile_size,d2	; d2 = VRAM address
		move.w	#$200/2,d3							; d3 = transfer size (words)
		jmp		(QueueDMATransfer).l
; ===========================================================================