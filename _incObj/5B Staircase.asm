; ---------------------------------------------------------------------------
; Object 5B - blocks that form a staircase (SLZ)
; ---------------------------------------------------------------------------

Staircase:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Stair_Index(pc,d0.w),d1
		jsr		Stair_Index(pc,d1.w)
		offscreen.w	DeleteObject,obStair_StartX(a0)	; PFM S3K Obj
		bra.w	DisplaySprite
; ===========================================================================

Stair_Index:	offsetTable
		offsetTableEntry.w Stair_Main
		offsetTableEntry.w Stair_Move
		offsetTableEntry.w Stair_Solid
; ===========================================================================

Stair_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Stair_Move
		moveq	#$38,d3						; id of first stair
		moveq	#1,d4						; value to add to iterate through stairs
		btst	#staFlipX,obStatus(a0)		; is object flipped?
		beq.s	.notflipped					; if not, branch
		moveq	#$3B,d3						; start from final stair
		moveq	#-1,d4						; iterate backwards

.notflipped:
		move.w	obX(a0),d2
		movea.l	a0,a1						; replace current object with first stair
		moveq	#3,d1						; 3 additional stairs
		bra.s	.makeblocks
; ===========================================================================
; TO-DO: Need to optimize this like I did with the other multi-piece objects
.loop:
		bsr.w	FindNextFreeObj
		bne.w	Stair_Move
		move.b	#4,obRoutine(a1)			; -> Stair_Solid

.makeblocks:
		_move.b	#id_Staircase,obID(a1)		; load another stair block object
		move.l	#Map_Stair,obMap(a1)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.w	d2,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obX(a0),obStair_StartX(a1)
		move.w	obY(a1),obStair_StartY(a1)
		addi.w	#32,d2						; next stair is 32px to the right of previous
		move.b	d3,obStair_ChildID(a1)		; values $38-$3B (or $3B-$38 if flipped)
		move.w	a0,obStair_Parent(a1)
		add.b	d4,d3						; next child id
		dbf		d1,.loop					; repeat sequence 3 times
; ---------------------------------------------------------------------------

Stair_Move:	; Routine 2
		moveq	#7,d0						; read only bits 0-2 of subtype
		and.b	obSubtype(a0),d0			; SCE Optimization
		add.w	d0,d0
		move.w	Stair_TypeIndex(pc,d0.w),d1
		jsr		Stair_TypeIndex(pc,d1.w)
; ---------------------------------------------------------------------------

Stair_Solid:	; Routine 4
		movea.w	obStair_Parent(a0),a2		; get address of OST of parent object
		moveq	#0,d0
		move.b	obStair_ChildID(a0),d0		; get current stair id ($38-$3B)
		move.b	(a2,d0.w),d0				; get y distance moved for current stair
		add.w	obStair_StartY(a0),d0		; add to initial y position
		move.w	d0,obY(a0)					; update position
		moveq	#11,d1
		add.b	obDispWid(a0),d1			; width; save 8 cycles
		moveq	#16,d2						; height (jumping); save 4 cycles - Filter
		moveq	#17,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; detect collision
		tst.b	d4							; has Sonic touched top/bottom of stair?
		bpl.s	.not_topbottom				; if not, branch
		move.b	d4,obStair_Flag(a2)			; set collision flag

	.not_topbottom:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the stair?
		beq.s	.exit						; if not, branch
		move.b	#1,obStair_Flag(a2)			; set collision flag

	.exit:
		rts	
; ===========================================================================

Stair_TypeIndex:	offsetTable
		offsetTableEntry.w Stair_Type00		; form staircase when stood on
		offsetTableEntry.w Stair_Type01
		offsetTableEntry.w Stair_Type02		; form staircase when hit from below
		offsetTableEntry.w Stair_Type01
; ===========================================================================

Stair_Type00:
		tst.w	obStair_WaitTime(a0)		; is timer above 0?
		bne.s	.dec_timer					; if yes, branch
		cmpi.b	#1,obStair_Flag(a0)			; has Sonic stood on the stairs?
		bne.s	.exit						; if not, branch
		move.w	#30,obStair_WaitTime(a0)	; set time delay to half a second

	.exit:
		rts	
; ===========================================================================

	.dec_timer:
		subq.w	#1,obStair_WaitTime(a0)		; decrement timer
		bne.s	.exit						; branch if time remains
		addq.b	#1,obSubtype(a0)			; add 1 to type
		rts	
; ===========================================================================

Stair_Type02:
		tst.w	obStair_WaitTime(a0)		; is timer above 0?
		bne.s	.dec_timer					; if yes, branch
		tst.b	obStair_Flag(a0)			; have stairs been hit from below?
		bpl.s	.exit						; if not, branch
		move.w	#$3C,obStair_WaitTime(a0)	; set time delay to 1 second

	.exit:
		rts	
; ===========================================================================

	.dec_timer:
		subq.w	#1,obStair_WaitTime(a0)		; decrement timer
		bne.s	.jiggle						; branch if time remains
		addq.b	#1,obSubtype(a0)			; add 1 to type
		rts	
; ===========================================================================

	.jiggle:
		lea		obStair_YDistList(a0),a1	; address of list of distance moved for each stair
		move.w	obStair_WaitTime(a0),d0		; get value from timer
		lsr.b	#2,d0
		andi.b	#1,d0						; d0 = bit 2 from timer (changes every 8 frames)
		move.b	d0,(a1)+					; set y distance as 0 or 1
		eori.b	#1,d0						; switch between 0 and 1 for each stair
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		rts	
; ===========================================================================

Stair_Type01:
		lea		obStair_YDistList(a0),a1	; address of list of distance moved for each stair
		cmpi.b	#128,(a1)					; has first stair moved 128px?
		beq.s	.exit						; if yes, branch
		addq.b	#1,(a1)						; move first stair down 1px
		moveq	#0,d1
		move.b	(a1)+,d1
		swap	d1
		lsr.l	#1,d1
		move.l	d1,d2
		lsr.l	#1,d1
		move.l	d1,d3
		add.l	d2,d3
		swap	d1
		swap	d2
		swap	d3
		move.b	d3,(a1)+					; move other 3 stairs down smaller amounts
		move.b	d2,(a1)+
		move.b	d1,(a1)+

	.exit:
		rts
; ===========================================================================