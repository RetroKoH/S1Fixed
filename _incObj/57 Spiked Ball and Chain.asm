; ---------------------------------------------------------------------------
; Object 57 - spiked balls (SYZ, LZ)
; ---------------------------------------------------------------------------

sball_childs = objoff_29	; number of child objects (1 byte)
		; followed by object RAM numbers of childs (1 byte each, up to 8 bytes)
sball_origY = objoff_38		; centre y-axis position (2 bytes)
sball_origX = objoff_3A		; centre x-axis position (2 bytes)
sball_radius = objoff_3C	; radius (1 byte)
sball_speed = objoff_3E		; rate of spin (2 bytes)

sball_angle = objoff_36		; precise rotation angle (2 bytes)
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.

SpikeBall:
	; LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		cmpi.b	#4,d0
		beq.w	SBall_Display
		
		tst.b	d0
		bne.w	SBall_Move
	; Object Routine Optimization End

SBall_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_SBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_SYZ_Spikeball_Chain,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a0)
		move.w	obX(a0),sball_origX(a0)
		move.w	obY(a0),sball_origY(a0)
		move.b	#$98,obColType(a0)		; SYZ specific code (chain hurts Sonic)
		cmpi.b	#id_LZ,(v_zone).w		; check if level is LZ
		bne.s	.notlz

		clr.b	obColType(a0)			; LZ specific code (chain doesn't hurt)
		move.w	#make_art_tile(ArtTile_LZ_Spikeball_Chain,0,0),obGfx(a0)
		move.l	#Map_SBall2,obMap(a0)

.notlz:
		move.b	obSubtype(a0),d1		; get object type
		andi.b	#$F0,d1					; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1					; multiply by 8
		move.w	d1,sball_speed(a0)		; set object twirl speed
	; This needs to be examined
		move.b	obStatus(a0),d0
		ror.b	#2,d0
		andi.b	#$C0,d0
		move.b	d0,obAngle(a0)			; set initial angle
		move.b	d0,sball_angle(a0)		; set initial precise angle
	; is obStatus always 0???
		lea		sball_childs(a0),a2		; a2 = (a0)'s child address array
		move.b	obSubtype(a0),d1		; get object type
		andi.w	#7,d1					; read only the	2nd digit (max: 7)
		clr.b	(a2)+
		move.w	d1,d3
		lsl.w	#4,d3
		move.b	d3,sball_radius(a0)
		subq.w	#1,d1					; set chain length (type-1)
		bcs.w	.fail					; if length of 0, branch ahead
		btst	#3,obSubtype(a0)
		beq.s	.startmaking
		subq.w	#1,d1
		bcs.s	.fail

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
.startmaking
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d0

.loop:
		tst.b	obID(a1)				; is object RAM	slot empty?
		beq.s	.makechain				; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop				; loop through object RAM
		bne.w	.fail					; We're moving this line here.

.makechain:
		;bsr.w	FindNextFreeObj		; Clownacy DisplaySprite Fix
		;bne.s	.fail
		addq.b	#1,sball_childs(a0) ; increment child object counter
		move.w	a1,d5		; get child object RAM address
		subi.w	#v_objspace&$FFFF,d5 ; subtract base address
		lsr.w	#object_size_bits,d5		; divide by $40
		andi.w	#$7F,d5
		move.b	d5,(a2)+	; copy child RAM number
		move.b	#4,obRoutine(a1)
		_move.b	obID(a0),obID(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	obPriority(a0),obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obActWid(a0),obActWid(a1)
		move.b	obColType(a0),obColType(a1)
		subi.b	#$10,d3
		move.b	d3,sball_radius(a1)
		cmpi.b	#id_LZ,(v_zone).w ; check if level is LZ
		bne.s	.notlzagain

		tst.b	d3
		bne.s	.notlzagain
		move.b	#2,obFrame(a1)	; use different frame for LZ chain

.notlzagain:
		dbf		d1,.loop 		; repeat for length of chain

.fail:
		move.w	a0,d5
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		cmpi.b	#id_LZ,(v_zone).w ; check if level is LZ
		bne.s	SBall_Move

		move.b	#$8B,obColType(a0) ; if yes, make last spikeball larger
		move.b	#1,obFrame(a0)	; use different	frame

SBall_Move:	; Routine 2
		bsr.w	.movesub
		bra.w	.chkdel
; ===========================================================================

.movesub:
		move.w	sball_speed(a0),d0
		add.w	d0,sball_angle(a0)
		move.b	sball_angle(a0),obAngle(a0)	; To prevent insta-shield bug.
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		move.w	sball_origY(a0),d2
		move.w	sball_origX(a0),d3
		lea		sball_childs(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

.loop:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	sball_radius(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		dbf		d6,.loop
		rts	
; ===========================================================================

.chkdel:
		offscreen.s	.delete,sball_origX(a0)	; ProjectFM S3K Object Manager
		bra.s	SBall_Display
; ===========================================================================

.delete:
		moveq	#0,d2
		lea		sball_childs(a0),a2
		move.b	(a2)+,d2

.deleteloop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a1
		bsr.w	DeleteChild
		dbf		d2,.deleteloop ; delete all pieces of chain
		rts	
; ===========================================================================

SBall_Display:	; Routine 4 -- S3K TouchResponse
		tst.b	obColType(a0)
		beq.w	DisplaySprite
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)		; Is list full?
		bhs.w	DisplaySprite	; If so, return
		addq.w	#2,(a1)			; Count this new entry
		adda.w	(a1),a1			; Offset into right area of list
		move.w	a0,(a1)			; Store RAM address in list
		bra.w	DisplaySprite
