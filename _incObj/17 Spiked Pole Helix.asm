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

obHelChild		= objoff_30	; pointer to the helix subsprite object
obHelOrigX		= objoff_3A
; ===========================================================================

Hel_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Hel,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Spike_Pole,2,0),obGfx(a0)
		move.b	#$80,obActWid(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$84,obColType(a0)			; make object harmful
		move.w	obX(a0),obHelOrigX(a0)	; save xpos
		
;Hel_MakeSubsprite:
		bsr.w	FindFreeObj
		bne.w	.done
		move.b	obID(a0),obID(a1)			; load obj17
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#6,obRender(a1)				; set subsprites flag
		move.b	#$40,mainspr_width(a1)		; base this on subtype later

		; create subsprites
		moveq	#0,d0
		move.b	#128,d0						; proper width in pixels
		move.w	obX(a1),d1
		sub.w	d0,d1						; move spikes back
		moveq	#16,d2						; +16 pixels
		
		; load 8 spike pole spikes (Change to accomodate subtypes, like the bridge)
	;	move.b	obSubtype(a0),d1
	;	andi.b	#7,d1
	;	addq.b	#1,d1
	;	move.b	d1,mainspr_childsprites(a1)
		move.b	#8,mainspr_childsprites(a1)
		lea		sub2_x_pos(a1),a2			; starting address for subsprite data
		move.w	obY(a1),d3

	; Perform a loop here once subtype is implemented
	rept 7
		move.w	d1,(a2)+					; set xpos
		move.w	d3,(a2)						; set ypos
		addq.w	#4,a2						; skip frame
		add.w	d2,d1						; +16 pixels
	endr

		; last spike
		move.w	d1,(a2)+					; set xpos
		move.w	d3,(a2)						; set ypos

.done:
		move.l	a1,obHelChild(a0)			; pointer to subsprite object

Hel_Action:	; Routine 2
		bsr.w	Hel_RotateSpikes
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)					; Is list full?
		bhs.s	Hel_ChkDel					; If so, return
		addq.w	#2,(a1)						; Count this new entry
		adda.w	(a1),a1						; Offset into right area of list
		move.w	a0,(a1)						; Store RAM address in list
		bra.w	Hel_ChkDel					; Clownacy DisplaySprite Fix

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hel_RotateSpikes:
		movea.l	obHelChild(a0),a1 ; a1=object
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		moveq	#7,d1						; max spikes frames

		set	.a,sub2_mapframe

	rept 7
		move.b	d0,.a(a1)					; set frame
		addq.b	#1,d0						; next frame
		and.b	d1,d0						; max spikes frames
		set	.a,.a + next_subspr
	endr

		; last spike
		move.b	d0,.a(a1)					; set frame

		; collision move
		move.b	(v_ani0_frame).w,d2			; spike frame
		neg.b	d2							; change direction of movement
		and.w	d1,d2						; max spikes
		move.w	sub2_x_pos(a1),d0			; get spike pole spikes xpos
		asl.w	#4,d2						; +16 pixels
		add.w	d2,d0						; "
		move.w	d0,obX(a0)					; set collision xpos

locret_7DA6:
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
