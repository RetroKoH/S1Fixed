; ---------------------------------------------------------------------------
; Object - zone title cards
; ---------------------------------------------------------------------------

TitleCard:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.w	Card_Move
		bpl.w	Card_Wait		; Routines 4/6
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Card_CheckSBZ3:	; Routine 0
		movea.l	a0,a1						; replace current object with 1st item in list
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w	; check if level is SBZ3
		bne.s	.not_sbz3					; if not, branch
		moveq	#5,d0						; load title card number 5 (SBZ)

	.not_sbz3:
		move.w	d0,d2
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w	; check if level is FZ
		bne.s	.load_config				; if not, branch
		moveq	#6,d0						; load title card number 6 (FZ)
		moveq	#$B,d2						; use "FINAL" mappings

	.load_config:
		lea		(Card_ConData).l,a3			; x/y pos data for all items
		lsl.w	#4,d0						; multiply zone by 16
		adda.w	d0,a3						; jump to relevant data
		lea		(Card_ItemData).l,a2		; y pos/routine/frame for each item
		moveq	#3,d1						; there are 4 items (minus 1 for 1st loop)

	.loop:
		_move.l	#TitleCard,obAddr(a1)
		move.w	(a3),obX(a1)				; load start x-position
		move.w	(a3)+,obTCard_FinalX(a1)	; load finish x-position (same as start)
		move.w	(a3)+,obTCard_DisplayX(a1)	; load main x-position
		move.w	(a2)+,obScreenY(a1)			; set y position
		move.b	(a2)+,obRoutine(a1)			; -> Card_Move
		move.b	(a2)+,d0					; get frame number
		bne.s	.act_number					; branch if not 00 (zone name)
		move.b	d2,d0						; use zone number instead (or $B for FZ)

	.act_number:
		cmpi.b	#7,d0						; is sprite the act number?
		bne.s	.make_sprite				; if not, branch
		add.b	(v_act).w,d0				; add act number to frame
		cmpi.b	#3,(v_act).w				; is this act 4? (SBZ3 only)
		bne.s	.make_sprite				; if not, branch
		subq.b	#1,d0						; use act 3 frame if act 4 (for SBZ3)

	.make_sprite:
		move.b	d0,obFrame(a1)				; display frame	number d0
		move.l	#Map_Card,obMap(a1)
		move.w	#make_art_tile(ArtTile_Title_Card,0,1),obGfx(a1)
		move.b	#$78,obDispWid(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#60,obTimeFrame(a1)			; set time delay to 1 second
		lea		object_size(a1),a1			; next object
		dbf		d1,.loop					; repeat sequence another 3 times
; ---------------------------------------------------------------------------

Card_Move:	; Routine 2
		moveq	#$10,d1						; set horizontal speed to 16px right
		move.w	obTCard_DisplayX(a0),d0
		cmp.w	obX(a0),d0					; has item reached the target position?
		beq.s	.at_target					; if yes, branch
		bge.s	.is_left					; branch if item is left of target
		neg.w	d1							; move left instead

	.is_left:
		add.w	d1,obX(a0)					; update position

	.at_target:
		move.w	obX(a0),d0
		bmi.s	.no_display					; branch if item is outside left of screen
		cmpi.w	#$200,d0					; has item moved beyond	$200 on	x-axis?
		bhs.s	.no_display					; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

	.no_display:
		rts	
; ===========================================================================

Card_Wait:	; Routine 4/6
	; title cards are instructed to jump here by GM_Level
		tst.b	obTimeFrame(a0)				; is time remaining zero?
		beq.s	Card_MoveBack				; if yes, branch
		subq.b	#1,obTimeFrame(a0)			; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

Card_MoveBack:
		tst.b	obRender(a0)				; is item on-screen?
		bpl.s	Card_ChangeArt				; if not, branch

		moveq	#32,d1						; set to move 32px right
		move.w	obTCard_FinalX(a0),d0
		cmp.w	obX(a0),d0					; has item reached the finish position?
		beq.s	Card_ChangeArt				; if yes, branch
		bge.s	.is_left					; branch if item is left of target
		neg.w	d1							; move left instead

	.is_left:
		add.w	d1,obX(a0)					; update position
		move.w	obX(a0),d0
		bmi.s	.no_display					; branch if item is outside left of screen
		cmpi.w	#$200,d0					; has item moved beyond	$200 on	x-axis?
		bhs.s	.no_display					; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

	.no_display:
		rts	
; ===========================================================================

Card_ChangeArt:
		cmpi.b	#4,obRoutine(a0)			; is this the main object? (routine 4)
		bne.w	DeleteObject				; if not, branch

		moveq	#plcid_Explode,d0
		jsr		(AddPLC).w					; load explosion patterns
		moveq	#0,d0
		move.b	(v_zone).w,d0
		addi.w	#plcid_GHZAnimals,d0
		jsr		(AddPLC).w					; load animal patterns

Card_Delete:
		bra.w	DeleteObject
; ===========================================================================
Card_ItemData:
	; y-axis position
	; routine number, frame	number (changes)
		dc.w $D0
		dc.b 2,	0		; zone name (frame number changes)
		dc.w $E4
		dc.b 2,	6		; "ZONE"
		dc.w $EA
		dc.b 2,	7		; act number (frame number changes)
		dc.w $E0
		dc.b 2,	$A		; oval
; ---------------------------------------------------------------------------
; Title	card configuration data
; Format:
; 4 bytes per item (AAAA BBBB); AAAA < obX and obTCard_FinalX; BBBB < obTCard_DisplayX
; 4 items per level (GREEN HILL, ZONE, ACT X, oval)
; ---------------------------------------------------------------------------
TitleCardMap:    macro    x
        dc.w	0, $120, $FEB8+x, $F8+x, $3D0+x, $110+x, $1D0+x, $110+x
        endm

Card_ConData:
		TitleCardMap 	$44	;0,	$120, $FEFC, $13C, $414, $154, $214, $154 ; GHZ
		TitleCardMap 	$3C	;0,	$120, $FEF4, $134, $40C, $14C, $20C, $14C ; LZ
		TitleCardMap 	$28	;0,	$120, $FEE0, $120, $3F8, $138, $1F8, $138 ; MZ
		TitleCardMap 	$44	;0,	$120, $FEFC, $13C, $414, $154, $214, $154 ; SLZ

	if ProtoZoneNames
		TitleCardMap 	$3C	;0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; SZ (Sparkling)
		TitleCardMap 	$44	;0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; CWZ (Clock Work)
	else
		TitleCardMap 	$4C	;0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; SYZ
		TitleCardMap 	$4C	;0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; SBZ
	endif

		dc.w	0,	$120, $FEE4, $124, $3EC, $3EC, $1EC, $12C ;TitleCardMap 	$18 (Unused, this causes issues)
; ===========================================================================
