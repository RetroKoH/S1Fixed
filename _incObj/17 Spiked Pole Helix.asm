; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)
; ---------------------------------------------------------------------------

Helix:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
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
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Hel,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Spike_Pole,2,0),obGfx(a0)
		move.b	#7,obStatus(a0)				; bit 2 is also set... is this used?
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a0)
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		_move.b	obID(a0),d4
		lea		obSubtype(a0),a2		; move helix length to a2
		moveq	#0,d1
		move.b	(a2),d1					; move helix length to d1
		clr.b	(a2)+					; clear subtype
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3					; d3 is x-axis position of leftmost spike
		subq.b	#2,d1
		bcs.w	Hel_Action				; skip to action if length is only 1 (The one piece has already been created!)
		moveq	#0,d6

	; RetroKoH Mass Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing SingleObjLoad, in order to avoid resetting its d0 every time an object is created.
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d0

.loop:
		tst.b	obID(a1)	; is object RAM	slot empty?
		beq.s	.makehelix	; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop	; loop through object RAM
		bne.s	Hel_Action	; We're moving this line here.

.makehelix:
		addq.b	#1,obSubtype(a0)
		move.w	a1,d5
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+				; copy child address to parent RAM
		move.b	#8,obRoutine(a1)
		_move.b	d4,obID(a1)
		move.w	d2,obY(a1)
		move.w	d3,obX(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	#make_art_tile(ArtTile_GHZ_Spike_Pole,2,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a1)
		move.b	d6,hel_frame(a1)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		cmp.w	obX(a0),d3				; is this spike in the centre?
		bne.s	.notCentre				; if not, branch

		move.b	d6,hel_frame(a0)		; set parent spike frame
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3					; skip to next spike
		addq.b	#1,obSubtype(a0)

.notCentre:
		dbf		d1,.loop				; repeat d1 times (helix length)

Hel_Action:	; Routine 2, 4
		bsr.w	Hel_RotateSpikes
		bra.w	Hel_ChkDel			; Clownacy DisplaySprite Fix

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hel_RotateSpikes:
		move.b	(v_ani0_frame).w,d0
		clr.b	obColType(a0) ; make object harmless
		add.b	hel_frame(a0),d0
		andi.b	#7,d0
		move.b	d0,obFrame(a0)	; change current frame
		bne.s	locret_7DA6
		move.b	#$84,obColType(a0) ; make object harmful

locret_7DA6:
		rts	
; End of function Hel_RotateSpikes

; ===========================================================================

Hel_ChkDel:
		offscreen.s	Hel_DelAll		; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
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
