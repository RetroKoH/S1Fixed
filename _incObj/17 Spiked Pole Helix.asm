; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)
; Adapted an optimized version from S1: Sonic Clean Engine
; ---------------------------------------------------------------------------

Helix:
		moveq	#0,d0
		move.b	mainspr_routine(a0),d0
		move.w	Hel_Index(pc,d0.w),d1
		jmp		Hel_Index(pc,d1.w)
; ===========================================================================
Hel_Index:		offsetTable
		offsetTableEntry.w Hel_Main
		offsetTableEntry.w Hel_Action
		offsetTableEntry.w Hel_Action
		offsetTableEntry.w Hel_Delete
		offsetTableEntry.w Hel_Display

hel_frame = objoff_3E		; start frame (different for each spike)

;		$29-38 are used for child object addresses
; ===========================================================================

Hel_Main:	; Routine 0
		addq.b	#2,mainspr_routine(a0)
		move.l	#Map_Hel,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Spike_Pole,2,0),obGfx(a0)
		move.b	#128,obActWid(a0)
		move.b	#7,obStatus(a0)				; bit 2 is also set... is this used?
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		bset	#6,obRender(a0)				; set subsprites flag

		; create sub objects
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d1
		sub.w	d0,d1						; move spikes back
		moveq	#16,d2						; +16 pixels
		
		; load 8 spike pole spikes (Change to accomodate subtypes, like the bridge)
		move.b	#8,mainspr_childsprites(a0)
		lea		sub2_x_pos(a0),a1
		lea		obY(a0),a2

	; Perform a loop here once subtype is implemented
	rept 7
		move.w	d1,(a1)+					; set xpos
		move.w	(a2),(a1)					; set ypos
		addq.w	#4,a1						; skip frame
		add.w	d2,d1						; +16 pixels
	endr

		; last spike
		move.w	d1,(a1)+					; set xpos
		move.w	(a2),(a1)					; set ypos

Hel_Action:	; Routine 2, 4
		bsr.w	Hel_RotateSpikes
		bra.w	Hel_ChkDel			; Clownacy DisplaySprite Fix

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hel_RotateSpikes:
		moveq	#0,d0
		move.b	(v_ani0_frame).w,d0
		moveq	#7,d1						; max spikes frames

		set	.a,sub2_mapframe

	rept 7
		move.b	d0,.a(a0)					; set frame
		addq.b	#1,d0						; next frame
		and.b	d1,d0						; max spikes frames
		set	.a,.a + next_subspr
	endr

		; last spike
		move.b	d0,.a(a0)					; set frame

		; collision move
		move.b	(v_ani0_frame).w,d2			; spike frame
		neg.b	d2							; change direction of movement
		and.w	d1,d2						; max spikes
		move.w	sub2_x_pos(a0),d0			; get spike pole spikes xpos
		asl.w	#4,d2						; +16 pixels
		add.w	d2,d0						; "
		move.w	d0,obX(a0)					; set collision xpos

locret_7DA6:
		rts	
; End of function Hel_RotateSpikes

; ===========================================================================

Hel_ChkDel:
		offscreen.s	Hel_DelAll		; ProjectFM S3K Objects Manager
		move.w	#priority3,d0			; RetroKoH/Devon S3K+ Priority Manager
		bra.w	DisplaySprite2			; Display sprites
; ===========================================================================

Hel_DelAll:
		moveq	#0,d2
		lea		obSubtype(a0),a2 ; move helix length to a2
		move.b	(a2)+,d2	; move helix length to d2
		subq.b	#2,d2
		bcs.w	DeleteObject

Hel_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a1		; get child address
		bsr.w	DeleteChild	; delete object
		dbf		d2,Hel_DelLoop ; repeat d2 times (helix length)

Hel_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================

Hel_Display:	; Routine 8
		bsr.w	Hel_RotateSpikes
		tst.b	obColType(a0)
		beq.w	DisplaySprite
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)		; Is list full?
		bhs.w	DisplaySprite	; If so, return
		addq.w	#2,(a1)			; Count this new entry
		adda.w	(a1),a1			; Offset into right area of list
		move.w	a0,(a1)			; Store RAM address in list
		bra.w	DisplaySprite
