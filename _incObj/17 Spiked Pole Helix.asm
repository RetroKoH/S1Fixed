; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)
; Adapted an optimized version from S1: Sonic Clean Engine
; ---------------------------------------------------------------------------

Helix:
		btst	#6,obRender(a0)		; Is this object set to render sub sprites?
		bne.s	.SubSprs			; If so, branch
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Hel_Index(pc,d0.w),d1
		jmp		Hel_Index(pc,d1.w)
; ===========================================================================
.SubSprs:
	; child sprite objects only need to be drawn
		move.w	#priority3,d0			; RetroKoH/Devon S3K+ Priority Manager
		bra.w	DisplaySprite2			; Display sprites
; ===========================================================================
Hel_Index:		offsetTable
		offsetTableEntry.w Hel_Main
		offsetTableEntry.w Hel_Action
		offsetTableEntry.w Hel_Delete

obHelChild		= objoff_30		; pointer to the helix subsprite object
obOffsetX		= objoff_38		; x-offset amount to ensure proper rendering
obHelOrigX		= objoff_3A		; origin x-position (obX+OffsetX)
; ===========================================================================
; Number of spikes determines our offset.
; These are byte values, but we use words to avoid repeatedly clearing d0
Hel_XOffsets:
		dc.b	8, $10, $18, $20, $28, $30, $38, $40
; ===========================================================================

Hel_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Hel,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Spike_Pole,2,0),obGfx(a0)
		move.b	#$80,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$84,obColType(a0)			; make object harmful
		move.w	obX(a0),obHelOrigX(a0)		; save xpos
		andi.b	#7,obSubtype(a0)			; cap at 8 spikes
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		move.b	Hel_XOffsets(pc,d0.w),d0	; number of spikes determines the x-offset applied
		move.w	d0,obOffsetX(a0)
		addi.w	d0,obHelOrigX(a0)
		
Hel_MakeSubsprite:
		bsr.w	FindFreeObj
		bne.w	.done
		move.b	obID(a0),obID(a1)			; load obj17
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#6,obRender(a1)				; set subsprites flag
		move.b	#$40,mainspr_width(a1)

		; load log spikes, # based on subtype (up to 8)
		moveq	#0,d1
		moveq	#0,d4
		move.b	obSubtype(a0),d1
		move.b	d1,d4						; loop iterator
		addq.b	#1,d1						; subsprite count
		move.b	d1,mainspr_childsprites(a1)
		lea		sub2_x_pos(a1),a2			; starting address for subsprite data
		move.w	obX(a1),d2
		move.w	obY(a1),d3

.loop:
		move.w	d2,(a2)+					; sub?_x_pos
		move.w	d3,(a2)						; sub?_y_pos
		addq.w	#4,a2						; skip frame
		addi.w	#$10,d2						; width of a spike, x_pos for next spike
		dbf		d4,.loop					; repeat for d4 spikes

.done:
		move.w	obOffsetX(a0),d0
		addi.w	d0,obX(a1)					; x-offset from above (still in d0)
		move.l	a1,obHelChild(a0)			; pointer to subsprite object
		
	; Spiked Log Helix is finished

Hel_Action:	; Routine 2
		bsr.w	Hel_RotateSpikes
		bra.w	Hel_ChkDel					; Clownacy DisplaySprite Fix

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hel_RotateSpikes:
		movea.l	obHelChild(a0),a1 ; a1=object
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		moveq	#7,d1						; max spikes frames

		moveq	#0,d2
		move.b	obSubtype(a0),d2			; get number of spikes
		lea		sub2_mapframe(a1),a2		; address for subsprite frames	

	.loop:
		move.b	d0,(a2)						; set frame
		addq.b	#1,d0						; next frame
		and.b	d1,d0						; max spikes frames
		addq.w	#6,a2						; go to next frame address
		dbf		d2,.loop					; repeat for d2 spikes

		; collision move
		move.b	(v_ani0_frame).w,d3			; spike frame
		neg.b	d3							; change direction of movement
		and.w	d1,d3						; max spikes
		move.b	d3,d4
		move.w	sub2_x_pos(a1),d0			; get spike pole spikes xpos
		asl.w	#4,d3						; +16 pixels
		add.w	d3,d0						; "
		move.w	d0,obX(a0)					; set collision xpos

.framecheck:
		move.b	obSubtype(a0),d2			; get number of spikes
		cmp.b	d4,d2						; is the spike log to short to display a "high frame" right now?
		bcs.s	.nocollision				; if yes, branch and don't register any collision

		; set collision IF spike frame is available
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)					; Is list full?
		bhs.s	Hel_ChkDel					; If so, return
		addq.w	#2,(a1)						; Count this new entry
		adda.w	(a1),a1						; Offset into right area of list
		move.w	a0,(a1)						; Store RAM address in list

.nocollision:
		rts	
; End of function Hel_RotateSpikes

; ===========================================================================

Hel_ChkDel:
		offscreen.s	Hel_Delete,obHelOrigX(a0)	; ProjectFM S3K Objects Manager
		rts
; ===========================================================================

Hel_Delete:	; Routine 4
		movea.l	obHelChild(a0),a1 ; a1=object
		bsr.w	DeleteChild
		bra.w	DeleteObject
; ===========================================================================
