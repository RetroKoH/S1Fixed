; ---------------------------------------------------------------------------
; Object 76 - blocks that Eggman picks up (SYZ)
; ---------------------------------------------------------------------------

BossBlock:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.s	BossBlock_Action
		bpl.w	BossBlock_Frag
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

BossBlock_Main:	; Routine 0
		moveq	#0,d4						; first subtype
		move.w	#boss_syz_x+$10,d5			; first x position
		moveq	#9,d6						; number of blocks (10)
		lea		(a0),a1						; replace current object with first block
		bra.s	.load_block
; ===========================================================================

	; TO-DO: Optimize this like I did with the other multi-piece objects
	.loop:
		jsr		(FindFreeObj).l
		bne.s	.fail

	.load_block:
		move.b	#id_BossBlock,obID(a1)
		move.l	#Map_BossBlock,obMap(a1)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$10,obDispWid(a1)
		move.b	#$10,obHeight(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	d5,obX(a1)					; set x-position
		move.w	#boss_syz_y+$B6,obY(a1)
		move.w	d4,obSubtype(a1)			; blocks have subtypes 0-9
		addi.w	#$101,d4					; increment subtype
		addi.w	#32,d5						; +32px for next x position
		addq.b	#2,obRoutine(a1)			; -> BBlock_Action
		dbf		d6,.loop					; repeat sequence 9 more times

	.fail:
		rts	
; ===========================================================================

BossBlock_Action:	; Routine 2
		move.b	obBossBlock_Mode(a0),d0		; check mode (changed by SYZ boss when lifted)
		cmp.b	obSubtype(a0),d0
		beq.s	.is_solid					; branch if same as subtype
		tst.b	d0
		bmi.s	.lifting					; branch if $FF

	.break_block:
		bsr.w	BossBlock_Break
		jmp		(DisplaySprite).l
; ===========================================================================

	.lifting:
		movea.w	obBossBlock_Parent(a0),a1	; get address of boss object
		tst.b	obColProp(a1)				; has boss been hit 8 times?
		beq.s	.break_block				; if yes, branch

		move.w	obX(a1),obX(a0)				; move with boss
		move.w	obY(a1),obY(a0)
		addi.w	#44,obY(a0)					; block is 44 ($2C) px below boss
		cmpa.w	a0,a1
		blo.s	.display					; branch if boss OST is before block OST in RAM
		move.w	obVelY(a1),d0
		ext.l	d0
		asr.l	#8,d0
		add.w	d0,obY(a0)
		jmp		(DisplaySprite).l
; ===========================================================================

	.is_solid:
		moveq	#27,d1						; width; save 4 cycles -- Filter
		moveq	#16,d2						; height (jumping); save 4 cycles -- Filter
		moveq	#17,d3						; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4					; axis position
		jsr		(SolidObject).l

	.display:
		jmp		(DisplaySprite).l
; ===========================================================================

BossBlock_Frag:	; Routine 4
		tst.b	obRender(a0)				; is object on-screen?
		bpl.s	.delete						; if not, branch
		jsr		(ObjectFall).l
		jmp		(DisplaySprite).l
; ===========================================================================

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to break block into fragments 
; Optimized by RetroKoH (TO-DO: Compare to original and investigate frame flicker)
; ---------------------------------------------------------------------------

BossBlock_Break:
		lea		BossBlock_FragSpeed(pc),a4
		lea		BossBlock_FragPos(pc),a5
		moveq	#1,d4						; first fragment is top left
		moveq	#2,d1						; number of fragments - 2
		moveq	#$38,d2						; set initial gravity speed (copied from SmashObject, but seems unused here)
		addq.b	#2,obRoutine(a0)			; -> BBlock_Frag
		move.b	#8,obDispWid(a0)
		move.b	#8,obHeight(a0)
		lea		(a0),a1						; replace block with first fragment

	; RetroKoH Mass Object Load Optimization; Built off of Spirituinsanum's Ring Loss Optimization
	; Init the first fragment right away (which is already created)
		move.l	(a4)+,obVelX(a1)			; move the data contained in the array to obVelX and obVelY, and increment the address in a4
		move.w	(a5)+,d3
		add.w	d3,obX(a1)					; set x-position
		move.w	(a5)+,d3
		add.w	d3,obY(a1)					; set y-position
		move.b	d4,obFrame(a1)
		addq.w	#1,d4						; increment fragment frame
	; fallthrough to the optimized loop for the other three fragments
; ---------------------------------------------------------------------------

	; Here we begin what's replacing FindFreeObj/SingleObjLoad.
	; Slight improvement by Malachi
		moveq	#0,d5
		lea		(v_lvlobjspace-object_size).w,a1
		move.w	#v_lvlobjcount,d5

	.loop:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.b	obID(a1)				; is object RAM	slot empty?
		dbeq	d5,.loop				; Branch correction again.
		bne.s	.fail					; We're moving this line here.

		lea		(a0),a2						; load block to a2
		lea		(a1),a3						; load fragment to a3
		moveq	#3,d3						; loop counter for data transfer

	.loop_copy:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf		d3,.loop_copy				; repeat 3 more times, to copy $40 bytes

		move.l	(a4)+,obVelX(a1)			; move the data contained in the array to obVelX and obVelY, and increment the address in a4
		move.w	(a5)+,d3
		add.w	d3,obX(a1)					; set x-position
		move.w	(a5)+,d3
		add.w	d3,obY(a1)					; set y-position
		move.b	d4,obFrame(a1)
		addq.w	#1,d4						; increment fragment frame
		dbf		d1,.loop					; repeat sequence 3 more times for 3 more fragments

	.fail:
		move.w	#sfx_WallSmash,d0
		jmp		(QueueSound2).w				; play smashing sound
; End of function BossBlock_Break
; ===========================================================================

BossBlock_FragSpeed:
		dc.w -$180, -$200	; x-speed, y-speed
		dc.w $180, -$200
		dc.w -$100, -$100
		dc.w $100, -$100

BossBlock_FragPos:
		dc.w -8, -8
		dc.w $10, 0
		dc.w 0,	$10
		dc.w $10, $10
; ===========================================================================