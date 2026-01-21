; ---------------------------------------------------------------------------
; Object 4D - bar of spiked balls (SYZ)
; Split from Obj57 by RetroKoH
; ---------------------------------------------------------------------------
; OST Constants
obSBar_ObjCount:		equ objoff_29		; 1 byte  | number of child objects
obSBar_ChildObjs:		equ objoff_2A		; 8 bytes | object RAM indices of child objects and parent

obSBar_Angle:			equ objoff_36		; 2 bytes | precise rotation angle
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.

obSBar_CenterX:			equ objoff_38		; 2 bytes | center X-axis position
obSBar_CenterY:			equ objoff_3A		; 2 bytes | center Y-axis position
obSBar_Radius:			equ objoff_3C		; 1 byte  | radius
obSBar_Speed:			equ objoff_3E		; 2 bytes | rate of spin
; ---------------------------------------------------------------------------

SpikeBar:
		_move.l	#SBar_Move,obAddr(a0)
		move.l	#Map_SBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_SYZ_Spikeball_Chain,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		move.w	obX(a0),obSBar_CenterX(a0)
		move.w	obY(a0),obSBar_CenterY(a0)
		move.b	#(colHarmful|colSz_4x4),obColType(a0)	; SYZ specific code (chain hurts Sonic)
		move.b	obSubtype(a0),d1						; get object type
		andi.b	#$F0,d1									; read only the	high nybble
		ext.w	d1
		asl.w	#3,d1									; multiply by 8
		move.w	d1,obSBar_Speed(a0)						; set object twirl speed
	; This needs to be examined
		move.b	obStatus(a0),d0
		ror.b	#2,d0									; move bits 0-1 into bits 6-7
		andi.b	#$C0,d0									; read only x/y flip bits
		move.b	d0,obAngle(a0)							; set initial angle
		move.b	d0,obSBar_Angle(a0)						; set initial precise angle
	; is obStatus always 0???
		lea		obSBar_ObjCount(a0),a2					; a2 = (a0)'s child address array
		move.b	obSubtype(a0),d1						; get object type
		andi.w	#7,d1									; read only the	2nd digit (max: 7)
		clr.b	(a2)+									; a2 now points to obSBar_ChildObjs
		move.w	d1,d3
		lsl.w	#4,d3									; multiply type by $10
		move.b	d3,obSBar_Radius(a0)					; set as radius
		subq.w	#1,d1									; set chain length (type-1)
		bcs.w	.fail									; if length of 0, branch ahead (invalid)
		btst	#3,obSubtype(a0)
		beq.s	.startmaking							; branch if bit 3 of subtype isn't set (+8)
		subq.w	#1,d1
		bcs.s	.fail

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
	.startmaking:
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d0
		_move.l	#SBall_Display,d2

	.loop:
		tst.l	obAddr(a1)								; is object RAM	slot empty?
		beq.s	.makechain								; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop								; loop through object RAM
		bne.w	.fail									; We're moving this line here.

	.makechain:
		addq.b	#1,obSBar_ObjCount(a0)					; increment child object counter
		move.w	a1,d5									; get child object RAM address
		subi.w	#v_objspace&$FFFF,d5					; subtract base address ($D000)
		lsr.w	#object_size_bits,d5					; divide by $40
		andi.w	#$7F,d5									; convert to obj RAM index
		move.b	d5,(a2)+								; add obj RAM index to the list (obSBar_ChildObjs)
		_move.l	d2,obAddr(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	obPriority(a0),obPriority(a1)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	obDispWid(a0),obDispWid(a1)
		move.b	obColType(a0),obColType(a1)
		subi.b	#$10,d3									; subtract $10 for radius, each object closer to centre
		move.b	d3,obSBar_Radius(a1)
		dbf		d1,.loop 								; repeat for length of chain

	.fail:
		move.w	a0,d5									; get parent object RAM address
		subi.w	#v_objspace&$FFFF,d5					; subtract base address ($D000)
		lsr.w	#object_size_bits,d5					; divide by $40
		andi.w	#$7F,d5									; convert to obj RAM index
		move.b	d5,(a2)+								; add to end of list (obSBar_ChildObjs)
; ---------------------------------------------------------------------------

SBar_Move:	; Routine 2
	; branches removed. We just call the code directly.
		move.w	obSBar_Speed(a0),d0						; get rotation speed
		add.w	d0,obSBar_Angle(a0)						; add speed to angle
		move.b	obSBar_Angle(a0),obAngle(a0)			; load high byte here (to prevent insta-shield bug).
		move.b	obAngle(a0),d0							; get updated angle

	; convert to sine/cosine
		calcsine_direct

		move.w	obSBar_CenterY(a0),d2					; get position of chain base
		move.w	obSBar_CenterX(a0),d3
		lea		obSBar_ObjCount(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6								; get number of objects

	.loop:
		moveq	#0,d4
		move.b	(a2)+,d4								; get obj RAM index of object
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4					; convert to RAM address
		movea.l	d4,a1									; point a1 to address
		moveq	#0,d4
		move.b	obSBar_Radius(a1),d4					; get radius for that object
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)								; update position
		move.w	d5,obX(a1)
		dbf		d6,.loop								; repeat for all objects

		offscreen.s	.delete,obSBar_CenterX(a0)			; ProjectFM S3K Object Manager
		bra.w	SBall_Display							; Display (+ Collision)
; ===========================================================================

	.delete:
		moveq	#0,d2
		lea		obSBar_ObjCount(a0),a2
		move.b	(a2)+,d2								; get number of objects

	.deleteloop:
		moveq	#0,d0
		move.b	(a2)+,d0								; get obj RAM index of object
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0					; convert to RAM address
		movea.l	d0,a1									; point a1 to address
		bsr.w	DeleteChild
		dbf		d2,.deleteloop							; delete all pieces of the chain
		rts	
; ===========================================================================