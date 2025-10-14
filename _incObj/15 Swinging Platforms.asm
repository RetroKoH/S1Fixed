; ---------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
;			- spiked ball on a chain (SBZ)
; ---------------------------------------------------------------------------

SwingingPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Swing_Index(pc,d0.w),d1
		jmp		Swing_Index(pc,d1.w)
; ===========================================================================
Swing_Index:	offsetTable
		offsetTableEntry.w	Swing_Main
		offsetTableEntry.w	Swing_SetSolid
		offsetTableEntry.w	Swing_Action2
		offsetTableEntry.w	Swing_Delete
		offsetTableEntry.w	Swing_Display
		offsetTableEntry.w	Swing_Action

swing_origX = objoff_3A		; original x-axis position
swing_origY = objoff_38		; original y-axis position

swing_angle = $10		; precise rotation angle (2 bytes)
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.
	; Unlike other similar objects, I set this to $10 because the GHZ boss chain
	; uses up much of its scratch RAM, and that object uses this object's movement
	; routines.
; ===========================================================================

Swing_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Swing_GHZ,obMap(a0)	; GHZ and MZ specific code
		move.w	#make_art_tile(ArtTile_GHZ_MZ_Swing,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obActWid(a0)
		move.b	#8,obHeight(a0)
		move.w	obY(a0),swing_origY(a0)
		move.w	obX(a0),swing_origX(a0)
		cmpi.b	#id_SLZ,(v_zone).w			; check if level is SLZ
		bne.s	.notSLZ

		move.l	#Map_Swing_SLZ,obMap(a0)	; SLZ specific code
		move.w	#make_art_tile(ArtTile_SLZ_Swing,2,0),obGfx(a0)
		move.b	#$20,obActWid(a0)
		move.b	#$10,obHeight(a0)
		move.b	#(colHarmful|colSz_32x8),obColType(a0)

.notSLZ:
		cmpi.b	#id_SBZ,(v_zone).w		; check if level is SBZ
		bne.s	.length

		move.l	#Map_BBall,obMap(a0)	; SBZ specific code
		move.w	#make_art_tile(ArtTile_SYZ_Big_Spikeball,0,0),obGfx(a0)
		move.b	#$18,obActWid(a0)
		move.b	#$18,obHeight(a0)
		move.b	#(colHarmful|colSz_16x16),obColType(a0)
		move.b	#$A,obRoutine(a0)		; goto Swing_Action next

.length:
		_move.b	obID(a0),d4			; d4 = object index
		moveq	#0,d1
		lea		obSubtype(a0),a2	; move address of object subtype to a2
		move.b	(a2),d1				; move object subtype to d1
		move.w	d1,-(sp)			; push subtype to stack to retrieve later
		andi.w	#$F,d1				; d1 = number of chain links
		clr.b	(a2)+				; clear out subtype byte in object RAM and increment a2
		move.w	d1,d3				; d3 = number of chain links
		lsl.w	#4,d3				; # of chain links * $10
	; RetroKoH Optimization(?) Edit
		move.b	d3,objoff_3C(a0)	; result stored in $3C(a0)
		addq.b	#8,objoff_3C(a0)	; maybe slightly faster than adding, setting, then subtracting d3
	; Optimization(?) Edit End
		tst.b	obFrame(a0)			; is this the platform?
		beq.s	.startloop			; if yes, branch ahead
		addq.b	#8,d3				; add #8 to d3
		subq.w	#1,d1				; decrement from length

	; RetroKoH Mass Object Load Optimization; Built off of Spirituinsanum's Ring Loss Optimization
	; Instead of calling FindNextFreeObj, we're going to loop directly here.
	; Slight improvement by Malachi
.startloop
		lea		(v_lvlobjspace-object_size).w,a1
		move.w	#v_lvlobjcount,d0

.makechain:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.b	obID(a1)				; is object RAM	slot empty?
		dbeq	d0,.makechain			; Branch correction again.
		bne.s	.fail					; We're moving this line here.

.cont
	; Mass Object Load Optimization End
		addq.b	#1,obSubtype(a0)
		move.w	a1,d5
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+				; store obj slot of child object in parent's SST at (a2)
		move.b	#8,obRoutine(a1)		; goto Swing_Display next
		_move.b	d4,obID(a1)				; load swinging	object
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		bclr	#gfxPalUpper,obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a1)
		move.b	#1,obFrame(a1)
		move.b	d3,objoff_3C(a1)
		subi.b	#$10,d3
		bcc.s	.notanchor
		move.b	#2,obFrame(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		bset	#gfxPalUpper,obGfx(a1)

.notanchor:
		dbf		d1,.makechain			; repeat d1 times (chain length)

.fail:
		move.w	a0,d5
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.w	#$4080,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		move.w	#-$200,objoff_3E(a0)
		move.w	(sp)+,d1
		btst	#4,d1						; is object type $1X ?
		beq.s	.not1X						; if not, branch
		move.l	#Map_GBall,obMap(a0)		; use GHZ ball mappings
		move.w	#make_art_tile(ArtTile_GHZ_Giant_Ball,2,0),obGfx(a0)
		move.b	#1,obFrame(a0)
		move.w	#priority2,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_20x20),obColType(a0)	; make object hurt when touched

.not1X:
		cmpi.b	#id_SBZ,(v_zone).w	; is zone SBZ?
		beq.s	Swing_Action		; if yes, branch

Swing_SetSolid:	; Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		moveq	#0,d3
		move.b	obHeight(a0),d3
		bsr.w	Swing_Solid

Swing_Action:	; Routine $A
		bsr.w	Swing_Move
		bra.w	Swing_ChkDel		; Clownacy DisplaySprite Fix
; ===========================================================================

Swing_Action2:	; Routine 4
		moveq	#0,d1
		move.b	obActWid(a0),d1
		bsr.w	ExitPlatform
		move.w	obX(a0),-(sp)
		bsr.w	Swing_Move
		move.w	(sp)+,d2
		moveq	#0,d3
		move.b	obHeight(a0),d3
		addq.b	#1,d3
		bsr.w	MvSonicOnPtfm
		bra.w	Swing_ChkDel		; Clownacy DisplaySprite Fix
; ===========================================================================


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move:
		move.b	(v_oscillate+$1A).w,d0
		move.w	#$80,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	Swing_Move2
		neg.w	d0
		add.w	d1,d0
		bra.s	Swing_Move2
; End of function Swing_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj48_Move:
		tst.b	objoff_3D(a0)
		bne.s	loc_7B9C
		move.w	objoff_3E(a0),d0
		addq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		cmpi.w	#$200,d0
		bne.s	loc_7BB6
		move.b	#1,objoff_3D(a0)
		bra.s	loc_7BB6
; ===========================================================================

loc_7B9C:
		move.w	objoff_3E(a0),d0
		subq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		cmpi.w	#-$200,d0
		bne.s	loc_7BB6
		clr.b	objoff_3D(a0)

loc_7BB6:
		move.b	obAngle(a0),d0
; End of function Obj48_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move2:
		calcsine_direct

		move.w	swing_origY(a0),d2
		move.w	swing_origX(a0),d3
		lea		obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_7BCE:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	objoff_3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		dbf		d6,loc_7BCE
		rts	
; End of function Swing_Move2

; ===========================================================================

Swing_ChkDel:
		offscreen.s	Swing_DelAll,objoff_3A(a0)	; ProjectFM S3K Objects Manager
		bra.s	Swing_Display					; Clownacy DisplaySprite Fix
; ===========================================================================

Swing_DelAll:
		moveq	#0,d2
		lea		obSubtype(a0),a2
		move.b	(a2)+,d2

Swing_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a1
		bsr.w	DeleteChild
		dbf		d2,Swing_DelLoop ; repeat for length of	chain
		rts	
; ===========================================================================

Swing_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================

Swing_Display:	; Routine $A
		tst.b	obColType(a0)
		beq.w	DisplaySprite

		cmpi.b	#(colHarmful|colSz_20x20),obColType(a0)		; is this the wrecking ball (1X)
		bne.s	.notwreckingball
; The following only applies to the wrecking ball
		moveq	#0,d0
		tst.b	obFrame(a0)				; is ball showing checkered?
		bne.s	.vanish					; if yes, branch to alt frame (frame 0)

	; RetroKoH angled ball mod (Incomplete)
		move.b	(v_oscillate+$1A).w,d0	; fetch chain's current angle; store it in d0
		; no subtraction, as this value already ranges from 0-$80
		lsr.b	#1,d0					; cut range down to 0-$40
		
		lea		(GBall_Angles).l,a2		; a2 = GBall_Angles address
		lea		(a2,d0.w),a2			; a2 = GBall_Angles + angle offset
		move.b	(a2),d0
	; angled ball mod end

.vanish:
		move.b	d0,obFrame(a0)

; The following is used by all swinging hazards
.notwreckingball:
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)		; Is list full?
		bhs.w	DisplaySprite	; If so, return
		addq.w	#2,(a1)			; Count this new entry
		adda.w	(a1),a1			; Offset into right area of list
		move.w	a0,(a1)			; Store RAM address in list
		bra.w	DisplaySprite
; ===========================================================================