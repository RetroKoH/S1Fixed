; ---------------------------------------------------------------------------
; Object 57 - chained spiked balls (LZ)
; I split the SYZ Spikebar from this, because this will use subsprites - KoH
; ---------------------------------------------------------------------------

SpikeBall:
		_move.l	#SBall_Move,obAddr(a0)
		move.l	#Map_SBall2,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Spikeball_Chain,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		move.w	obX(a0),obSBall_CenterX(a0)
		move.w	obY(a0),obSBall_CenterY(a0)
	; chain has no collision
		move.b	obSubtype(a0),d1						; get object type
		andi.b	#$F0,d1									; read only the	high nybble
		ext.w	d1
		asl.w	#3,d1									; multiply by 8
		move.w	d1,obSBall_Speed(a0)					; set object twirl speed
	; This needs to be examined
		move.b	obStatus(a0),d0
		ror.b	#2,d0									; move bits 0-1 into bits 6-7
		andi.b	#$C0,d0									; read only x/y flip bits
		move.b	d0,obAngle(a0)							; set initial angle
		move.b	d0,obSBall_Angle(a0)					; set initial precise angle
	; is obStatus always 0???
		lea		obSBall_ObjCount(a0),a2					; a2 = (a0)'s child address array
		move.b	obSubtype(a0),d1						; get object type
		andi.w	#7,d1									; read only the	2nd digit (max: 7)
		clr.b	(a2)+
		move.w	d1,d3
		lsl.w	#4,d3									; multiply type by $10
		move.b	d3,obSBall_Radius(a0)					; set as radius
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
		addq.b	#1,obSBall_ObjCount(a0)					; increment child object counter
		move.w	a1,d5									; get child object RAM address
		subi.w	#v_objspace&$FFFF,d5					; subtract base address ($D000)
		lsr.w	#object_size_bits,d5					; divide by $40
		andi.w	#$7F,d5									; convert to obj RAM index
		move.b	d5,(a2)+								; add obj RAM index to list of child objects
		_move.l	d2,obAddr(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	obPriority(a0),obPriority(a1)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	obDispWid(a0),obDispWid(a1)
		move.b	obColType(a0),obColType(a1)
		subi.b	#$10,d3									; subtract $10 for radius, each object closer to center
		move.b	d3,obSBall_Radius(a1)
		tst.b	d3
		bne.s	.notcenter								; branch if not the center object
		move.b	#2,obFrame(a1)							; use different frame for LZ chain base

	.notcenter:
		dbf		d1,.loop 								; repeat for length of chain

	.fail:
		move.w	a0,d5									; get parent object RAM address
		subi.w	#v_objspace&$FFFF,d5					; subtract base address ($D000)
		lsr.w	#object_size_bits,d5					; divide by $40
		andi.w	#$7F,d5									; convert to obj RAM index
		move.b	d5,(a2)+								; add to end of list

		move.b	#(colHarmful|colSz_8x8),obColType(a0)	; if yes, make last spikeball larger
		move.b	#1,obFrame(a0)							; use different	frame
; ---------------------------------------------------------------------------

SBall_Move:	; Routine 2
	; branches removed. We just call the code directly.
		move.w	obSBall_Speed(a0),d0					; get rotation speed
		add.w	d0,obSBall_Angle(a0)					; add speed to angle
		move.b	obSBall_Angle(a0),obAngle(a0)			; load high byte here (to prevent insta-shield bug).
		move.b	obAngle(a0),d0							; get updated angle

	; convert to sine/cosine
		calcsine_direct

		move.w	obSBall_CenterY(a0),d2					; get position of chain base
		move.w	obSBall_CenterX(a0),d3
		lea		obSBall_ObjCount(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6								; get number of objects

	.loop:
		moveq	#0,d4
		move.b	(a2)+,d4								; get obj RAM index of object
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4					; convert to RAM address
		movea.l	d4,a1									; point a1 to address
		moveq	#0,d4
		move.b	obSBall_Radius(a1),d4					; get radius for that object
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

		offscreen.s	.delete,obSBall_CenterX(a0)			; ProjectFM S3K Object Manager
		bra.s	SBall_Display							; Display (+ Collision)
; ===========================================================================

	.delete:
		moveq	#0,d2
		lea		obSBall_ObjCount(a0),a2
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

SBall_Display:	; Routine 4 -- S3K TouchResponse
		tst.b	obColType(a0)							; does this piece have collision?
		beq.w	DisplaySprite							; if not, stop here

		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)								; Is list full?
		bhs.w	DisplaySprite							; If so, return
		addq.w	#2,(a1)									; Count this new entry
		adda.w	(a1),a1									; Offset into right area of list
		move.w	a0,(a1)									; Store RAM address in list
		bra.w	DisplaySprite
; ===========================================================================