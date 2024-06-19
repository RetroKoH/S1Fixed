; ---------------------------------------------------------------------------
; Object 78 - Caterkiller enemy	(MZ, SBZ)
; ---------------------------------------------------------------------------

Caterkiller:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Cat_Index(pc,d0.w),d1
		jmp	Cat_Index(pc,d1.w)
; ===========================================================================
Cat_Index:
		dc.w Cat_Main-Cat_Index
		dc.w Cat_Head-Cat_Index
		dc.w Cat_BodySeg1-Cat_Index
		dc.w Cat_BodySeg2-Cat_Index
		dc.w Cat_BodySeg1-Cat_Index
		dc.w Cat_Delete-Cat_Index
		dc.w loc_16CC0-Cat_Index

; SSTs used
;		0		1		2		3		4		5		6		7		8		9		A		B		C		D		E		F
;0x		ID		REND	GFX1	GFX2	MAP1	MAP2	MAP3	MAP4	XPOS1	XPOS2	XPOS3	XPOS4	YPOS1	YPOS2	YPOS3	YPOS4
;1x		VELX1	VELX2	----	----	AcWID	----	
;2x
;3x


cat_intertia = obVelY		; formerly obInertia. Needed to change after shifting SSTs for the Priority Manager.
							; Caterkiller uses obXVel but doesn't use obYVel, and this causes no glitches.
cat_parent = objoff_3C		; address of parent object
; ===========================================================================

locret_16950:
		rts	
; ===========================================================================

Cat_Main:	; Routine 0
		move.b	#7,obHeight(a0)
		move.b	#8,obWidth(a0)
		jsr		(ObjectFall).l
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_16950
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Cat,obMap(a0)
		move.w	#make_art_tile(ArtTile_Caterkiller,1,0),obGfx(a0)	; RetroKoH VRAM Overhaul
		andi.b	#3,obRender(a0)
		ori.b	#4,obRender(a0)
		move.b	obRender(a0),obStatus(a0)
		move.w	#$200,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#8,obActWid(a0)
		move.b	#$B,obColType(a0)
		move.w	obX(a0),d2
		moveq	#$C,d5
		btst	#0,obStatus(a0)
		beq.s	.noflip
		neg.w	d5

.noflip:
		move.b	#4,d6
		moveq	#0,d3
		moveq	#4,d4
		movea.l	a0,a2	; Move head's address to a2, as it will be the first body part's parent
		moveq	#2,d1	; create 3 body parts to go along with the head

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		lea		(v_lvlobjspace).w,a1
		move.w	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d0

.loop:
		tst.b	obID(a1)				; is object RAM	slot empty?
		beq.s	.makebody				; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop				; loop through object RAM
		bne.w	Cat_ChkGone				; We're moving this line here.

.makebody:
		_move.b	#id_Caterkiller,obID(a1)	; load body segment object
		move.b	d6,obRoutine(a1)			; goto Cat_BodySeg1 or Cat_BodySeg2 next
		addq.b	#2,d6						; alternate between the two
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	#$280,obPriority(a1)		; RetroKoH S2 Priority Manager
		move.b	#8,obActWid(a1)
		move.b	#$CB,obColType(a1)
		add.w	d5,d2
		move.w	d2,obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obStatus(a0),obRender(a1)
		move.b	#8,obFrame(a1)
		move.l	a2,cat_parent(a1)
		move.b	d4,cat_parent(a1)
		addq.b	#4,d4
		movea.l	a1,a2						; Move this part's address to a2, as it will be the next body part's parent
		dbf		d1,.loop					; repeat sequence 2 more times

		move.b	#7,objoff_2A(a0)
		clr.b	cat_parent(a0)

Cat_Head:	; Routine 2
		tst.b	obStatus(a0)
		bmi.w	loc_16C96
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Cat_Index2(pc,d0.w),d1
		jsr		Cat_Index2(pc,d1.w)
		move.b	objoff_2B(a0),d1
		bpl.s	.display
		lea		(Ani_Cat).l,a1
		move.b	obAngle(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,obAngle(a0)
		move.b	(a1,d0.w),d0
		bpl.s	.animate
		bclr	#7,objoff_2B(a0)
		bra.s	.display

.animate:
		andi.b	#$10,d1
		add.b	d1,d0
		move.b	d0,obFrame(a0)

.display:
		out_of_range.s	Cat_ChkGone
		jmp		(DisplaySprite).l

Cat_ChkGone:
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	.delete				; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again

.delete:
		move.b	#$A,obRoutine(a0)	; goto Cat_Delete next
		rts	
; ===========================================================================

Cat_Delete:	; Routine $A
		jmp	(DeleteObject).l
; ===========================================================================
Cat_Index2:	dc.w .wait-Cat_Index2
		dc.w loc_16B02-Cat_Index2
; ===========================================================================

.wait:
		subq.b	#1,objoff_2A(a0)
		bmi.s	.move
		rts	
; ===========================================================================

.move:
		addq.b	#2,ob2ndRout(a0)
		move.b	#$10,objoff_2A(a0)
		move.w	#-$C0,obVelX(a0)
		move.w	#$40,cat_intertia(a0)
		bchg	#4,objoff_2B(a0)
		bne.s	loc_16AFC
		clr.w	obVelX(a0)
		neg.w	cat_intertia(a0)

loc_16AFC:
		bset	#7,objoff_2B(a0)

loc_16B02:
		subq.b	#1,objoff_2A(a0)
		bmi.s	.loc_16B5E
		tst.w	obVelX(a0)
		beq.s	.notmoving
		move.l	obX(a0),d2
		move.l	d2,d3
		move.w	obVelX(a0),d0
		btst	#0,obStatus(a0)
		beq.s	.noflip
		neg.w	d0

.noflip:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,obX(a0)
		swap	d3
		cmp.w	obX(a0),d3
		beq.s	.notmoving
		jsr	(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	.loc_16B70
		cmpi.w	#$C,d1
		bge.s	.loc_16B70
		add.w	d1,obY(a0)
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		move.b	d1,objoff_2C(a0,d0.w)

.notmoving:
		rts	
; ===========================================================================

.loc_16B5E:
		subq.b	#2,ob2ndRout(a0)
		move.b	#7,objoff_2A(a0)
		clr.w	obVelX(a0)
		clr.w	cat_intertia(a0)
		rts	
; ===========================================================================

.loc_16B70:
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		move.b	#$80,objoff_2C(a0,d0.w)
		neg.w	obX+2(a0)
		beq.s	.loc_1730A
		btst	#0,obStatus(a0)
		beq.s	.loc_1730A
		subq.w	#1,obX(a0)
		addq.b	#1,cat_parent(a0)
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		clr.b	objoff_2C(a0,d0.w)
.loc_1730A:
		bchg	#0,obStatus(a0)
		move.b	obStatus(a0),obRender(a0)
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		rts	
; ===========================================================================

Cat_BodySeg2:	; Routine 6
		movea.l	cat_parent(a0),a1
		move.b	objoff_2B(a1),objoff_2B(a0)
		bpl.s	Cat_BodySeg1
		lea	(Ani_Cat).l,a1
		move.b	obAngle(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,obAngle(a0)
		tst.b	4(a1,d0.w)
		bpl.s	Cat_AniBody
		addq.b	#4,obAngle(a0)

Cat_AniBody:
		move.b	(a1,d0.w),d0
		addq.b	#8,d0
		move.b	d0,obFrame(a0)

Cat_BodySeg1:	; Routine 4, 8
		movea.l	cat_parent(a0),a1
		tst.b	obStatus(a0)
		bmi.w	loc_16C90
		move.b	objoff_2B(a1),objoff_2B(a0)
		move.b	ob2ndRout(a1),ob2ndRout(a0)
		beq.w	loc_16C64
		move.w	cat_intertia(a1),cat_intertia(a0)
		move.w	obVelX(a1),d0
		add.w	cat_intertia(a0),d0
		move.w	d0,obVelX(a0)
		move.l	obX(a0),d2
		move.l	d2,d3
		move.w	obVelX(a0),d0
		btst	#0,obStatus(a0)
		beq.s	loc_16C0C
		neg.w	d0

loc_16C0C:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,obX(a0)
		swap	d3
		cmp.w	obX(a0),d3
		beq.s	loc_16C64
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		move.b	objoff_2C(a1,d0.w),d1
		cmpi.b	#$80,d1
		bne.s	loc_16C50
		move.b	d1,objoff_2C(a0,d0.w)
		neg.w	obX+2(a0)
		beq.s	locj_173E4
		btst	#0,obStatus(a0)
		beq.s	locj_173E4
		cmpi.w	#-$C0,obVelX(a0)
		bne.s	locj_173E4
		subq.w	#1,obX(a0)
		addq.b	#1,cat_parent(a0)
		moveq	#0,d0
		move.b	cat_parent(a0),d0
		clr.b	objoff_2C(a0,d0.w)
locj_173E4:
		bchg	#0,obStatus(a0)
		move.b	obStatus(a0),obRender(a0)
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		bra.s	loc_16C64
; ===========================================================================

loc_16C50:
		ext.w	d1
		add.w	d1,obY(a0)
		addq.b	#1,cat_parent(a0)
		andi.b	#$F,cat_parent(a0)
		move.b	d1,objoff_2C(a0,d0.w)

loc_16C64:
		cmpi.b	#$C,obRoutine(a1)
		beq.s	loc_16C90

		; Each sub-object deletes itself when it detects that its
		; parent is going to delete itself. This mostly works, but
		; does cause the sub-object to linger for one frame longer
		; than it should, which is why rolling into a Caterkiller
		; at high speed causes Sonic to be hurt.

		; Has the head been destroyed?
		_cmpi.b	#id_ExplosionItem,obID(a1)
		beq.s	.delete
		; Is the parent going to delete itself?
		cmpi.b	#$A,obRoutine(a1)
		bne.s	.display

	if FixBugs
		; Delete the parent.
		jsr	(DeleteChild).l ; Don't mind this misnomer.
	endif

.delete:
		; Mark self for deletion.
		move.b	#$A,obRoutine(a0)

	if FixBugs
		; Do not queue self for display, since it will be deleted by
		; its child later.
		rts
	endif

.display:
		jmp	(DisplaySprite).l

; ===========================================================================
Cat_FragSpeed:	dc.w -$200, -$180, $180, $200
; ===========================================================================

loc_16C90:
		bset	#7,obStatus(a1)

loc_16C96:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Cat_FragSpeed-2(pc,d0.w),d0
		btst	#0,obStatus(a0)
		beq.s	loc_16CAA
		neg.w	d0

loc_16CAA:
		move.w	d0,obVelX(a0)
		move.w	#-$400,obVelY(a0)
		move.b	#$C,obRoutine(a0)
		move.b	#$98,obColType(a0)	; Mercury Caterkiller Fix
		andi.b	#$F8,obFrame(a0)

loc_16CC0:	; Routine $C
		jsr	(ObjectFall).l
		tst.w	obVelY(a0)
		bmi.s	loc_16CE0
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.s	loc_16CE0
		add.w	d1,obY(a0)
		move.w	#-$400,obVelY(a0)

loc_16CE0:
		tst.b	obRender(a0)
		bpl.w	Cat_ChkGone
		jmp	(DisplaySprite).l
