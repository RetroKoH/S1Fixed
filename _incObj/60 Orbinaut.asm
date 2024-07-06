; ---------------------------------------------------------------------------
; Object 60 - Orbinaut enemy (LZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

Orbinaut:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Orb_Index(pc,d0.w),d1
		jmp		Orb_Index(pc,d1.w)
; ===========================================================================
Orb_Index:	offsetTable
		offsetTableEntry.w Orb_Main
		offsetTableEntry.w Orb_ChkSonic
		offsetTableEntry.w Orb_Display
		offsetTableEntry.w Orb_MoveOrb
		offsetTableEntry.w Orb_ChkDel2

orb_parent = objoff_3C		; address of parent object
; ===========================================================================

Orb_Main:	; Routine 0
		move.l	#Map_Orb,obMap(a0)
		move.w	#make_art_tile(ArtTile_Orbinaut,0,0),obGfx(a0)	; RetroKoH VRAM Overhaul
		cmpi.b	#id_SLZ,(v_zone).w								; check if level is SLZ
		bne.s	.notSLZ
		bset	#5,obGfx(a0)									; Set to the next palette line -- RetroKoH VRAM Overhaul
.notSLZ
		ori.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#$B,obColType(a0)
		move.b	#$C,obActWid(a0)
		moveq	#0,d2
		lea		objoff_37(a0),a2
		movea.l	a2,a3
		addq.w	#1,a2
		moveq	#3,d1					; create 4 spike objects

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d0

.loop:
		tst.b	obID(a1)				; is object RAM	slot empty?
		beq.s	.makesatellites			; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop				; loop through object RAM
		bne.s	.fail					; We're moving this line here.

.makesatellites:
		addq.b	#1,(a3)
		move.w	a1,d5
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		_move.b	obID(a0),obID(a1)		; load spiked orb object
		move.b	#6,obRoutine(a1)		; use Orb_MoveOrb routine
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		ori.b	#4,obRender(a1)
		move.w	#$200,obPriority(a1)	; RetroKoH S2 Priority Manager
		move.b	#8,obActWid(a1)
		move.b	#3,obFrame(a1)
		move.b	#$98,obColType(a1)
		move.b	d2,obAngle(a1)
		addi.b	#$40,d2
		move.l	a0,orb_parent(a1)
		dbf		d1,.loop				; repeat sequence 3 more times

.fail:
		moveq	#1,d0
		btst	#staFlipX,obStatus(a0)	; is orbinaut facing left?
		beq.s	.noflip			; if not, branch
		neg.w	d0

.noflip:
		move.b	d0,objoff_36(a0)
		move.b	obSubtype(a0),obRoutine(a0) ; if type is 02, skip Orb_ChkSonic
		addq.b	#2,obRoutine(a0)
		move.w	#-$40,obVelX(a0) ; move orbinaut to the left
		btst	#staFlipX,obStatus(a0)	; is orbinaut facing left??
		beq.s	.noflip2	; if not, branch
		neg.w	obVelX(a0)	; move orbinaut	to the right

.noflip2:
		rts	
; ===========================================================================

Orb_ChkSonic:	; Routine 2
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0	; is Sonic to the right of the orbinaut?
		bcc.s	.isright	; if yes, branch
		neg.w	d0

.isright:
		cmpi.w	#$A0,d0		; is Sonic within $A0 pixels of	orbinaut?
		bhs.s	.animate	; if not, branch
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0	; is Sonic above the orbinaut?
		bcc.s	.isabove	; if yes, branch
		neg.w	d0

.isabove:
		cmpi.w	#$50,d0		; is Sonic within $50 pixels of	orbinaut?
		bhs.s	.animate	; if not, branch
		tst.w	(v_debuguse).w	; is debug mode	on?
		bne.s	.animate	; if yes, branch
		move.b	#1,obAnim(a0)	; use "angry" animation

.animate:
		lea		(Ani_Orb).l,a1
		bsr.w	AnimateSprite
		bra.w	Orb_ChkDel
; ===========================================================================

Orb_Display:	; Routine 4
		bsr.w	SpeedToPos

Orb_ChkDel:
		out_of_range.w	.chkgone
		bra.w	DisplayAndCollision	; S3K TouchResponse

.chkgone:
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	loc_11E34			; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again

loc_11E34:
		lea		objoff_37(a0),a2
		moveq	#0,d2
		move.b	(a2)+,d2
		subq.w	#1,d2
		bcs.w	DeleteObject

loc_11E40:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a1
		bsr.w	DeleteChild
		dbf		d2,loc_11E40

Orb_Delete:
		bra.w	DeleteObject
; ===========================================================================

Orb_MoveOrb:	; Routine 6
		movea.l	orb_parent(a0),a1
		_cmpi.b	#id_Orbinaut,obID(a1) ; does parent object still exist?
		bne.w	DeleteObject	; if not, delete
		cmpi.b	#2,obFrame(a1)	; is orbinaut angry?
		bne.s	.circle		; if not, branch
		cmpi.b	#$40,obAngle(a0) ; is spikeorb directly under the orbinaut?
		bne.s	.circle		; if not, branch
		addq.b	#2,obRoutine(a0)
		subq.b	#1,objoff_37(a1)
		bne.s	.fire
		addq.b	#2,obRoutine(a1)

.fire:
		move.w	#-$200,obVelX(a0) ; move orb to the left (quickly)
		btst	#staFlipX,obStatus(a1)
		beq.s	.noflip
		neg.w	obVelX(a0)

.noflip:
		bra.w	DisplayAndCollision	; S3K TouchResponse
; ===========================================================================

.circle:
		move.b	obAngle(a0),d0
		jsr		(CalcSine).l
		asr.w	#4,d1
		add.w	obX(a1),d1
		move.w	d1,obX(a0)
		asr.w	#4,d0
		add.w	obY(a1),d0
		move.w	d0,obY(a0)
		move.b	objoff_36(a1),d0
		add.b	d0,obAngle(a0)
		bra.w	DisplayAndCollision	; S3K TouchResponse
; ===========================================================================

Orb_ChkDel2:	; Routine 8
		bsr.w	SpeedToPos
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bra.w	DisplayAndCollision	; S3K TouchResponse
