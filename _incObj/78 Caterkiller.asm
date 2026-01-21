; ---------------------------------------------------------------------------
; Object 78 - Caterkiller enemy	(MZ, SBZ)
; ---------------------------------------------------------------------------
; OST Constants
obCat_Inertia:			equ obVelY			; 2 bytes | formerly obInertia. Needed to change after shifting SSTs for the Priority Manager.
										; Caterkiller uses obXVel but doesn't use obYVel (unless broken), and this causes no glitches.

obCat_WaitTime:			equ objoff_2A		; 1 byte  | time to wait between actions
obCat_Mode:				equ objoff_2B		; 1 byte  | bit 4 (+$10) = mouth is open/segment moving up; bit 7 (+$80) = update animation
obCat_FloorMap:			equ objoff_2C		; 16 bytes| height map of floor beneath caterkiller (16 bytes)
obCat_SegmentPos:		equ objoff_3C		; 1 byte  | segment position - starts as 0/4/8/$A, increments as it moves
obCat_Parent:			equ objoff_3E		; 2 bytes | address of OST of parent object (4 bytes - high byte is obCat_segment_pos)
; ---------------------------------------------------------------------------

Caterkiller:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Cat_Index(pc,d0.w),d1
		jmp		Cat_Index(pc,d1.w)
; ===========================================================================
Cat_Index:	offsetTable
		offsetTableEntry.w Cat_Main
		offsetTableEntry.w Cat_Head
		offsetTableEntry.w Cat_BodySeg1
		offsetTableEntry.w Cat_BodySeg2
		offsetTableEntry.w Cat_BodySeg1
		offsetTableEntry.w Cat_Delete
		offsetTableEntry.w Cat_Fragment
; ===========================================================================

Cat_Fall:
		rts	
; ===========================================================================

Cat_Main:	; Routine 0
		move.w	#$708,obHeight(a0)			; Height and Width
		jsr		(ObjectFall_YOnly).l
		jsr		(ObjFloorDist).l
		tst.w	d1							; has caterkiller hit floor?
		bpl.s	Cat_Fall					; if not, branch
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)			; -> Cat_Head
		move.l	#Map_Cat,obMap(a0)
		move.w	#make_art_tile(ArtTile_Caterkiller,1,0),obGfx(a0)	; RetroKoH VRAM Overhaul
		andi.b	#3,obRender(a0)
		ori.b	#4,obRender(a0)
		move.b	obRender(a0),obStatus(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		move.b	#(colEnemy|colSz_8x8),obColType(a0)
		move.w	obX(a0),d2					; head x position
		moveq	#12,d5						; distance between segments 12 ($C) px
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	d5							; negative if xflipped

	.noflip:
		moveq	#4,d6						; routine number
		moveq	#0,d3
		moveq	#4,d4
		movea.l	a0,a2	; Move head's address to a2, as it will be the first body part's parent
		moveq	#2,d1	; create 3 body parts to go along with the head

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		movea.l	a0,a1
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.w	Cat_ChkGone

	.loop:
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		beq.s	.makebody					; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop					; loop through object RAM
		bne.w	Cat_ChkGone					; We're moving this line here.

	.makebody:
		_move.l	#Caterkiller,obAddr(a1)		; load body segment object
		move.b	d6,obRoutine(a1)			; goto Cat_BodySeg1 or Cat_BodySeg2 next
		addq.b	#2,d6						; alternate between the two
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	#priority5,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a1)
		move.b	#(colSpecial|colSz_8x8),obColType(a1)
		add.w	d5,d2
		move.w	d2,obX(a1)					; body segment x pos = previous segment x pos +12
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	obStatus(a0),obRender(a1)
		move.b	#8,obFrame(a1)
		move.w	a2,obCat_Parent(a1)
		move.b	d4,obCat_SegmentPos(a1)
		addq.b	#4,d4
		movea.l	a1,a2						; Move this part's address to a2, as it will be the next body part's parent
		dbf		d1,.loop					; repeat sequence 2 more times

		move.b	#7,obCat_WaitTime(a0)
		clr.b	obCat_SegmentPos(a0)
; ---------------------------------------------------------------------------

Cat_Head:	; Routine 2
		tst.b	obStatus(a0)				; has caterkiller been broken?
		bmi.w	Cat_Head_Break				; if yes, branch
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		jsr		Cat_Index2(pc,d0.w)
		move.b	obCat_Mode(a0),d1			; is animation flag set?
		bpl.s	.display					; if not, branch
		lea		Ani_Cat(pc),a1
		move.b	obAngle(a0),d0
		andi.w	#$7F,d0						; ignore high bit of angle
		addq.b	#4,obAngle(a0)				; increment angle (wraps from $FC to 0)
		move.b	(a1,d0.w),d0				; get byte from animation script, based on angle
		bpl.s	.animate					; branch if not $FF
		bclr	#7,obCat_Mode(a0)			; disable animation
		bra.s	.display

	.animate:
		andi.b	#$10,d1						; read mouth open/closed bit
		add.b	d1,d0						; add to frame (+$10)
		move.b	d0,obFrame(a0)				; set frame

	.display:
		out_of_range.s	Cat_ChkGone
		jmp		(DisplayAndCollision).l		; S3K TouchResponse

Cat_ChkGone:
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.delete						; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again

	.delete:
		move.b	#$A,obRoutine(a0)			; -> Cat_Delete (TO-DO: Could we just delete it directly?)
		rts	
; ===========================================================================

Cat_Delete:	; Routine $A
		jmp		(DeleteObject).l
; ===========================================================================

	; RetroKoH Object Routine Optimization
Cat_Index2:
		bra.s	Cat_Undulate
		bra.s	Cat_Floor
	; Object Routine Optimization End
; ===========================================================================

Cat_Undulate:
		subq.b	#1,obCat_WaitTime(a0)		; decrement timer
		bmi.s	.move						; branch if -1
		rts	
; ===========================================================================

	.move:
		addq.b	#2,ob2ndRout(a0)			; -> Cat_Floor
		move.b	#$10,obCat_WaitTime(a0)		; set timer for movement
		move.w	#-$C0,obVelX(a0)			; move head to the left
		move.w	#$40,obCat_Inertia(a0)
		bchg	#4,obCat_Mode(a0)			; change between mouth open/moving up, and mouth closed/moving down
		bne.s	.is_moving					; branch if mouth open/moving up
		clr.w	obVelX(a0)					; don't move left
		neg.w	obCat_Inertia(a0)

	.is_moving:
		bset	#7,obCat_Mode(a0)			; update animation

Cat_Floor:
		subq.b	#1,obCat_WaitTime(a0)		; decrement timer
		bmi.s	.undulate_next				; branch if -1
		tst.w	obVelX(a0)
		beq.s	.notmoving					; branch if head isn't moving horizontally
		move.l	obX(a0),d2
		move.l	d2,d3						; d3 = x pos before update
		move.w	obVelX(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	d0							; change direction if xflipped (i.e. move right)

	.noflip:
		ext.l	d0
		asl.l	#8,d0						; multiply speed by $100
		add.l	d0,d2						; add to x pos
		move.l	d2,obX(a0)					; update position
		swap	d3
		cmp.w	obX(a0),d3
		beq.s	.notmoving					; branch if head hasn't moved horizontally
		jsr		(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	.turn_around				; branch if > 8px below floor
		cmpi.w	#$C,d1
		bge.s	.turn_around				; branch if > 11px above floor (also detects a ledge)
		add.w	d1,obY(a0)					; align to floor

		moveq	#0,d0
		move.b	obCat_SegmentPos(a0),d0		; get pos counter for head (starts as 0)
		addq.b	#1,obCat_SegmentPos(a0)		; increment pos counter
		andi.b	#$F,obCat_SegmentPos(a0)	; wrap to 0 after $F
		move.b	d1,obCat_FloorMap(a0,d0.w)	; write floor height for current position in array

	.notmoving:
		rts	
; ===========================================================================

	.undulate_next:
		subq.b	#2,ob2ndRout(a0)			; goto Cat_Undulate next
		move.b	#7,obCat_WaitTime(a0)		; set timer for delay
		clr.w	obVelX(a0)					; stop moving
		clr.w	obCat_Inertia(a0)
		rts	
; ===========================================================================

	.turn_around:
		moveq	#0,d0
		move.b	obCat_SegmentPos(a0),d0		; get pos counter for head
		move.b	#$80,obCat_FloorMap(a0,d0.w)	; save stop position in floor map array
		neg.w	obXSub(a0)
		beq.s	.face_left					; branch if x subpixel is 0
		btst	#staFlipX,obStatus(a0)
		beq.s	.face_left					; branch if facing left
		subq.w	#1,obX(a0)
		addq.b	#1,obCat_SegmentPos(a0)		; increment pos counter
		moveq	#0,d0
		move.b	obCat_SegmentPos(a0),d0
		clr.b	obCat_FloorMap(a0,d0.w)

	.face_left:
		bchg	#staFlipX,obStatus(a0)
		move.b	obStatus(a0),obRender(a0)
		addq.b	#1,obCat_SegmentPos(a0)		; increment pos counter
		andi.b	#$F,obCat_SegmentPos(a0)	; wrap to 0 after $F
		rts	
; ===========================================================================

Cat_BodySeg2:	; Routine 6
		movea.w	obCat_Parent(a0),a1			; get OST of 1st body segment
		move.b	obCat_Mode(a1),obCat_Mode(a0)	; copy animation mode flags
		bpl.s	Cat_BodySeg1				; branch if not updating
		lea		Ani_Cat(pc),a1
		move.b	obAngle(a0),d0
		andi.w	#$7F,d0						; ignore high bit of angle
		addq.b	#4,obAngle(a0)				; increment angle (wraps from $FC to 0)
		tst.b	4(a1,d0.w)					; get byte from animation script, based on angle
		bpl.s	.update_frame				; branch if not $FF
		addq.b	#4,obAngle(a0)				; increment angle again

	.update_frame:
		move.b	(a1,d0.w),d0				; get frame id from animation
		addq.b	#8,d0						; skip head frames to body frames
		move.b	d0,obFrame(a0)				; update frame
; ---------------------------------------------------------------------------

Cat_BodySeg1:	; Routine 4, 8
		movea.w	obCat_Parent(a0),a1			; get obj RAM of head/previous body segment
		tst.b	obStatus(a0)
		bmi.w	Cat_Body_Break				; branch if caterkiller is broken
		move.b	obCat_Mode(a1),obCat_Mode(a0)	; copy animation mode flags
		move.b	ob2ndRout(a1),ob2ndRout(a0)
		beq.w	.chk_broken
		move.w	obCat_Inertia(a1),obCat_Inertia(a0)
		move.w	obVelX(a1),d0
		add.w	obCat_Inertia(a0),d0
		move.w	d0,obVelX(a0)				; update x speed
		move.l	obX(a0),d2
		move.l	d2,d3						; d3 = x pos before update
		move.w	obVelX(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	d0							; reverse speed if xflipped

	.noflip:
		ext.l	d0
		asl.l	#8,d0						; multiply speed by $100
		add.l	d0,d2						; add to x pos
		move.l	d2,obX(a0)					; update position
		swap	d3
		cmp.w	obX(a0),d3
		beq.s	.chk_broken					; branch if segment hasn't moved
		moveq	#0,d0
		move.b	obCat_SegmentPos(a0),d0		; get pos counter
		move.b	obCat_FloorMap(a1,d0.w),d1	; get floor height from parent's floor array
		cmpi.b	#$80,d1						; floor height $80 means a wall or drop
		bne.s	.align_to_floor				; branch if not $80
		move.b	d1,obCat_FloorMap(a0,d0.w)
		neg.w	obX+2(a0)
		beq.s	.face_left
		btst	#staFlipX,obStatus(a0)
		beq.s	.face_left					; branch if facing left
		cmpi.w	#-$C0,obVelX(a0)
		bne.s	.face_left					; branch if not moving left
		subq.w	#1,obX(a0)
		addq.b	#1,obCat_SegmentPos(a0)
		moveq	#0,d0
		move.b	obCat_SegmentPos(a0),d0
		clr.b	obCat_FloorMap(a0,d0.w)

	.face_left:
		bchg	#staFlipX,obStatus(a0)		; change direction
		move.b	obStatus(a0),obRender(a0)
		addq.b	#1,obCat_SegmentPos(a0)		; increment pos counter
		andi.b	#$F,obCat_SegmentPos(a0)	; wrap to 0 after $F
		bra.s	.chk_broken
; ===========================================================================

	.align_to_floor:
		ext.w	d1
		add.w	d1,obY(a0)					; align to floor
		addq.b	#1,obCat_SegmentPos(a0)		; increment pos counter
		andi.b	#$F,obCat_SegmentPos(a0)	; wrap to 0 after $F
		move.b	d1,obCat_FloorMap(a0,d0.w)	; write floor height for current position in array

	.chk_broken:
		cmpi.b	#$C,obRoutine(a1)
		beq.s	Cat_Body_Break				; branch if parent is broken body segment

		; Each sub-object deletes itself when it detects that its
		; parent is going to delete itself. This mostly works, but
		; does cause the sub-object to linger for one frame longer
		; than it should, which is why rolling into a Caterkiller
		; at high speed causes Sonic to be hurt.

		; Has the head been destroyed?
		_move.l	obAddr(a1),d0
		and.l	#$FFFFFF,d0
		cmpi.l	#ExplosionItem,d0
		blo.s	.notexplosion
		cmpi.l	#ExItem_Animate,d0
		bls.s	.delete						; branch if parent is broken head

	.notexplosion:
		; Is the parent going to delete itself?
		cmpi.b	#$A,obRoutine(a1)
		bne.s	.display					; branch if parent is set to delete

		; Delete the parent.
		jsr		(DeleteChild).l				; Don't mind this misnomer.

	.delete:
		; Mark self for deletion.
		move.b	#$A,obRoutine(a0)			; -> Cat_Delete

		; Do not queue self for display, since it will be deleted by
		; its child later.
		rts

	.display:
		jmp		(DisplayAndCollision).l		; S3K TouchResponse

; ===========================================================================
Cat_FragSpeed:
		dc.w -$200					; head x speed
		dc.w -$180					; body x speed
		dc.w $180					; body x speed
		dc.w $200					; body x speed
; ===========================================================================

Cat_Body_Break:
		bset	#7,obStatus(a1)				; stop parent despawning

Cat_Head_Break:
		moveq	#0,d0
		move.b	obRoutine(a0),d0			; get routine number (2/4/6/8)
		move.w	Cat_FragSpeed-2(pc,d0.w),d0	; get speed of specified segment
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_xflip
		neg.w	d0							; reverse if xflipped

	.no_xflip:
		move.w	d0,obVelX(a0)				; set x speed
		move.w	#-$400,obVelY(a0)			; bounce
		move.b	#$C,obRoutine(a0)			; -> Cat_Fragment
		andi.b	#$F8,obFrame(a0)			; use first head/body frame
; ---------------------------------------------------------------------------

Cat_Fragment:	; Routine $C
		jsr		(ObjectFall).l
		tst.w	obVelY(a0)
		bmi.s	.nocollide					; branch if moving upwards
		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit floor?
		bpl.s	.nocollide					; if not, branch
		add.w	d1,obY(a0)					; align to floor
		move.w	#-$400,obVelY(a0)			; bounce

	.nocollide:
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	Cat_ChkGone					; if not, branch
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================