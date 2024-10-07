; ---------------------------------------------------------------------------
; Subroutine to	animate	level graphics
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateLevelGfx:
		tst.b	(f_pause).w				; is the game paused?
		bne.s	.ispaused				; if yes, branch
		moveq	#0,d0
		move.b	(v_zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	AniArt_Index+2(pc,d0.w),d1
		lea		AniArt_Index(pc,d1.w),a2	; Load animated art data to a2
		move.w	AniArt_Index(pc,d0.w),d0
		jmp		AniArt_Index(pc,d0.w)		; jump to dynamic art routine

.ispaused:
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Offset index for animated art routines and scripts (System ported from Sonic 2)
;
; Each zone gets two entries in this jump table. The first entry points to the
; zone's animation procedure (usually Dynamic_Normal, but some zones may have special
; procedures for complicated animations). The second points to the zone's animation
; script.
;
; Note that Animated_Null is not a valid animation script, so don't pair it up
; with anything except Dynamic_Null, or bad things will happen (for example, a bus error exception).
; ---------------------------------------------------------------------------
; ===========================================================================
AniArt_Index:	offsetTable
		offsetTableEntry.w	Dynamic_GHZ
		offsetTableEntry.w	AniArt_GHZ		; Waterfall/Flowers

		offsetTableEntry.w	Dynamic_LZ		; Write new routine (that takes into account reversing animation)
		offsetTableEntry.w	AniArt_LZ		; Conveyor Wheels (New)

		offsetTableEntry.w	Dynamic_Normal	; Write new routine to oscillate lava flow
		offsetTableEntry.w	AniArt_MZ		; Lava and Background Torches

		offsetTableEntry.w	Dynamic_Null
		offsetTableEntry.w	AniArt_none

		offsetTableEntry.w	Dynamic_Null
		offsetTableEntry.w	AniArt_none

		offsetTableEntry.w	Dynamic_Normal
		offsetTableEntry.w	AniArt_SBZ		; Background Smoke Clouds in Act 1
		zonewarning AniArt_Index,4
		offsetTableEntry.w	Dynamic_Normal
		offsetTableEntry.w	AniArt_Ending
; ===========================================================================

Dynamic_Null:
		rts
; ===========================================================================

; ===========================================================================
Dynamic_Normal:
Dynamic_GHZ:
		lea		(Anim_Counters).w,a3
		move.w	(a2)+,d6			; Get number of scripts in list

.loop:
		subq.b	#1,(a3)				; Decrement frame duration timer
		bpl.s	.nextscript			; If frame isn't over, move on to next script

;.nextframe:
		moveq	#0,d0
		move.b	1(a3),d0			; Get current frame
		cmp.b	6(a2),d0			; Have we processed the last frame in the script?
		bcs.s	.notlastframe
		moveq	#0,d0
		move.b	d0,1(a3)			; If so, reset to first frame

.notlastframe:
		addq.b	#1,1(a3)			; Consider this frame processed; set counter to next frame
		move.b	(a2),(a3)			; Set frame duration to global duration value
		bpl.s	.globalduration
		; If script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)		; Set frame duration to current frame's duration value

.globalduration:
		; Prepare for DMA transfer
		; Get relative address of frame's art
		move.b	8(a2,d0.w),d0		; Get tile ID
		lsl.w	#5,d0				; Turn it into an offset
		; Get VRAM destination address
		move.w	4(a2),d2
		; Get ROM source address
		move.l	(a2),d1				; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1				; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3				; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jsr		(QueueDMATransfer).l

.nextscript:
		move.b	6(a2),d0			; Get total size of frame data
		tst.b	(a2)				; Is per-frame duration data present?
		bpl.s	.globalduration2	; If not, keep the current size; it's correct
		add.b	d0,d0				; Double size to account for the additional frame duration data

.globalduration2:
		addq.b	#1,d0
		andi.w	#$FE,d0				; Round to next even address, if it isn't already
		lea		8(a2,d0.w),a2		; Advance to next script in list
		addq.w	#2,a3				; Advance to next script's slot in a3 (usually Anim_Counters)
		dbf		d6,.loop
		rts
; ===========================================================================

; ===========================================================================
Dynamic_LZ:
		; We don't need Anim_Counters to a3, or a script count because we only use
		; one script. We just need special coding for it.
		moveq	#0,d0
		move.w	(v_framecount).w,d0
		andi.w	#3,d0
		bne.s	.dontchange

		moveq	#0,d0
		move.b	(v_lani0_frame).w,d0
		moveq	#1,d1
		tst.b	(f_conveyrev).w			; have conveyors been reversed?
		beq.s	.notreverse				; if not, branch
		neg.b	d1

.notreverse:
		add.b	d1,d0
		andi.b	#3,d0
		move.b	d0,(v_lani0_frame).w	; update frame

		; Get relative address of frame's art
		move.b	$A(a2,d0.w),d0			; Get tile ID
		lsl.w	#5,d0					; Turn it into an offset
		; Get VRAM destination address
		move.w	#(ArtTile_LZ_Conveyor_Wheel*tile_size),d2
		; Get ROM source address
		move.l	2(a2),d1				; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1					; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#$10,d3					; # of tiles in the frame
		lsl.w	#4,d3					; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jmp		(QueueDMATransfer).l

.dontchange:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Animated pattern scripts - Green Hill
; ---------------------------------------------------------------------------

AniArt_none:
AniArt_Ending:
AniArt_GHZ:	zoneanimstart
	; Waterfalls
	zoneanimdecl 5, Art_GhzWater, ArtTile_GHZ_Waterfall, 2, 8
;		dc.l	Art_GhzWater+$05000000				; Art address + (Fixed duration << 24)
;		dc.w	(ArtTile_GHZ_Waterfall*tile_size)	; VRAM loc
;		dc.b	2									; # of frames
;		dc.b	8									; number of tiles per frame
	; -----------------------------------------------------------
		dc.b	0			; 0 (tile offset 0; 5 frames)
		dc.b	8			; 2 (tile offset 8; 5 frames)
		even
	; ===========================================================
	; Big Flower -- Increase from 2 to 4 frames
	zoneanimdecl 15, Art_GhzFlower1, ArtTile_GHZ_Sunflower, 2, 16
	; -----------------------------------------------------------
		dc.b	0			; 0 (tile offset 0; 15 ($F) frames)
		dc.b	16			; 2 (tile offset 16 ($10); 15 ($F) frames)
		even
	; ===========================================================
	; Smaller Purple Flower -- Increase frames?
	zoneanimdecl $FF, Art_GhzFlower2, ArtTile_GHZ_Purple_Flower, 4, 12
	; $FF denotes a non-fixed frame duration. We must specify duration in each frame below
	; -----------------------------------------------------------
		dc.b	0,$7F		; 0 (tile offset 0; $7F frames)
		dc.b	12,7		; 2 (tile offset 12; 7 frames)
		dc.b	24,$7F		; 4 (tile offset 24; $7F frames)
		dc.b	12,7		; 6 (tile offset 12; 7 frames)
		even
	
	zoneanimend
; ===========================================================================

; ---------------------------------------------------------------------------
; Animated pattern scripts - Labyrinth (NEW)
; ---------------------------------------------------------------------------

AniArt_LZ:	zoneanimstart

	; Conveyor Wheels
	zoneanimdecl 4, Art_LzWheel, ArtTile_LZ_Conveyor_Wheel, 4, $10
	; -----------------------------------------------------------
		dc.b	0			; 0 (tile offset 0; 4 frames)
		dc.b	$10			; 2 (tile offset 16; 4 frames)
		dc.b	$20			; 4 (tile offset 32; 4 frames)
		dc.b	$30			; 6 (tile offset 48; 4 frames)
		even
		
	zoneanimend
; ===========================================================================

; ---------------------------------------------------------------------------
; Animated pattern scripts - Marble
; ---------------------------------------------------------------------------

AniArt_MZ:	zoneanimstart

	; Lava surface
	zoneanimdecl $13, Art_MzLava1, ArtTile_MZ_Animated_Lava, 3, 8
	; -----------------------------------------------------------
		dc.b	0			; 0 (tile offset 0; $13 frames)
		dc.b	8			; 2 (tile offset 8; $13 frames)
		dc.b	16			; 4 (tile offset 16; $13 frames)
		even
	; ===========================================================
	; Magma (Needs new routine to oscillate lave flow)
	zoneanimdecl 1, Art_MzLava2, ArtTile_MZ_Animated_Magma, 13, 16
	; -----------------------------------------------------------
		dc.b	0, 2, 4, 6, 8, 10, 12
		dc.b	14, 16, 18, 20, 22, 24
		even
	; ===========================================================
	; Background Torches
		zoneanimdecl $13, Art_MzTorch, ArtTile_MZ_Torch, 3, 6
	; -----------------------------------------------------------
		dc.b	0			; 0 (tile offset 0; $13 frames)
		dc.b	6			; 2 (tile offset 6; $13 frames)
		dc.b	12			; 4 (tile offset 12; $13 frames)
		dc.b	18			; 6 (tile offset 18; $13 frames)
		even
	
	zoneanimend
; ===========================================================================

; ---------------------------------------------------------------------------
; Animated pattern scripts - Scrap Brain
; ---------------------------------------------------------------------------

AniArt_SBZ:	zoneanimstart
	; Smoke puff 1
	zoneanimdecl 7, Art_SbzSmoke, ArtTile_SBZ_Smoke_Puff_1, 7, 12
	; -----------------------------------------------------------
		dc.b	0
		dc.b	12
		dc.b	24
		dc.b	36
		dc.b	48
		dc.b	60
		dc.b	72
		even

	zoneanimend
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
