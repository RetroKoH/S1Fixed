; ---------------------------------------------------------------------------
; Object 51 - smashable	green block (MZ)
; ---------------------------------------------------------------------------

SmashBlock:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.s	Smab_Solid
		bpl.w	Smab_Points
	; Object Routine Optimization End

Smab_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> Smab_Solid
		move.l	#Map_Smab,obMap(a0)
		move.w	#make_art_tile(ArtTile_MZ_Block,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),obFrame(a0)
; ---------------------------------------------------------------------------

Smab_Solid:	; Routine 2

; It seems odd to store these at the start, but we need to save these variables for .smash
		move.w	(v_itembonus).w,obSmab_HitCount(a0)			; load current combo count
		move.b	(v_player+obAnim).w,obSmab_SonicAnim(a0)	; load Sonic's animation number
; SolidObject will reset Sonic if he is on this block, resetting the animation and the combo

		moveq	#27,d1							; width; save 4 cycles - Filter
		moveq	#16,d2							; height (jumping); save 4 cycles - Filter
		moveq	#17,d3							; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4						; axis position
		bsr.w	SolidObject
		btst	#staSonicOnObj,obStatus(a0)		; has Sonic landed on the block?
		bne.s	.smash							; if yes, branch
		bra.w	RememberState	
; ===========================================================================

	.smash:
		cmpi.b	#aniID_Roll,obSmab_SonicAnim(a0)	; is Sonic rolling/jumping?
		bne.w	RememberState					; if not, branch
		move.w	obSmab_HitCount(a0),(v_itembonus).w
		bset	#staSpin,obStatus(a1)
		move.w	#$E07,obHeight(a1)				; Height and Width
		move.b	#aniID_Roll,obAnim(a1)			; make Sonic roll
		move.w	#-$300,obVelY(a1)				; rebound Sonic
		bset	#staAir,obStatus(a1)
		bclr	#staOnObj,obStatus(a1)
		move.b	#2,obRoutine(a1)
		bclr	#staSonicOnObj,obStatus(a0)		; removed obSolid
		move.b	#1,obFrame(a0)
		lea		(Smab_Speeds).l,a4				; load broken fragment speed data
		move.w	#$38,d2							; set initial gravity speed
		bsr.w	SmashObject						; break object into fragments

	; REMOVE FindFreeObj. We can pick up with a1 and d3 where we left off
		tst.b	d3								; have we already checked all object RAM?
		ble.s	Smab_Points						; if yes, skip making points
		lea		object_size(a1),a1				; go to the next object space

	.loop:
		tst.b	obID(a1)						; is object RAM	slot empty?
		beq.s	.loadpts						; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		object_size(a1),a1
		dbf		d3,.loop						; Branch correction again.
		bne.s	Smab_Points						; We're moving this line here.

	.loadpts:
		_move.b	#id_Points,obID(a1)				; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	(v_itembonus).w,d2
		addq.w	#2,(v_itembonus).w				; increment bonus counter
		cmpi.w	#6,d2							; have fewer than 3 blocks broken?
		blo.s	.bonus							; if yes, branch
		moveq	#6,d2							; set cap for points

	.bonus:
		moveq	#0,d0
		move.w	Smab_Scores(pc,d2.w),d0
		cmpi.w	#$20,(v_itembonus).w			; have 16 blocks been smashed?
		blo.s	.givepoints						; if not, branch
		move.w	#1000,d0						; give higher points for 16th block
		moveq	#10,d2

	.givepoints:
		jsr		(AddPoints).l
		lsr.w	#1,d2
		move.b	d2,obFrame(a1)
; ---------------------------------------------------------------------------

Smab_Points:	; Routine 4
		bsr.w	SpeedToPos
		addi.w	#$38,obVelY(a0)					; apply gravity
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bsr.w	DisplaySprite					; Clownacy DisplaySprite Fix
		bra.w	RememberState
; ===========================================================================

Smab_Speeds:
		dc.w -$200, -$200	; x-speed, y-speed
		dc.w -$100, -$100
		dc.w $200, -$200
		dc.w $100, -$100

Smab_Scores:
		dc.w 10				; 100 (block 1)
		dc.w 20				; 200 (block 2)
		dc.w 50				; 500 (block 3)
		dc.w 100			; 1000 (block 4-15)
; ===========================================================================
