; ---------------------------------------------------------------------------
; Object 46 - solid blocks and blocks that fall	from the ceiling (MZ)
; ---------------------------------------------------------------------------

MarbleBrick:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Brick_Action
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Brick_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$F0F,obHeight(a0)			; Height and Width
		move.l	#Map_Brick,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
		move.w	obY(a0),obBrick_StartY(a0)
; ---------------------------------------------------------------------------

Brick_Action:	; Routine 2
		tst.b	obRender(a0)
		bpl.s	.chkdel
		moveq	#7,d0						; get last digit of subtype (sans bit 3)
		and.b	obSubtype(a0),d0			; SCE optimization
		beq.s	.solid						; skip if subtype 00
		add.w	d0,d0
		jsr		Brick_Index-2(pc,d0.w)		; SCE optimization
; ---------------------------------------------------------------------------

; Type 00 - doesn't move
.solid:
		moveq	#27,d1						; width; save 4 cycles - Filter
		moveq	#16,d2						; height (jumping); save 4 cycles - Filter
		moveq	#17,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject

.chkdel:
		offscreen.w	DeleteObject			; ProjectFM S3K Object Manager
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix
; ===========================================================================

Brick_Index:
		bra.s	Brick_Wobbles
		bra.s	Brick_Falls
		bra.s	Brick_Falling
; ===========================================================================

; Type 04 - wobbles slowly (it's on the lava now)
Brick_WobbleLava:
		moveq	#0,d0
		move.b	(v_oscillate+$12).w,d0
		lsr.w	#3,d0
		move.w	obBrick_StartY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)					; make the block wobble
		rts	
; ===========================================================================

; Type 02 - wobble and falls
Brick_Falls:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.sonic_is_right				; branch if Sonic is to the right
		neg.w	d0							; if to the left, make this value positive

	.sonic_is_right:
		cmpi.w	#144,d0						; is Sonic within 144 pixels of	the block?
		bhs.s	Brick_Wobbles				; if not, resume wobbling
		move.b	#3,obSubtype(a0)			; if yes, make the block fall
		bra.s	Brick_NoWobble				; adding this branch prevents the weird position popping
; ---------------------------------------------------------------------------

; Type 01 - wobbles up and down
Brick_Wobbles:
		moveq	#0,d0
		move.b	(v_oscillate+$16).w,d0
		btst	#3,obSubtype(a0)			; is subtype 8 or above?
		beq.s	.no_rev						; if not, branch
		neg.w	d0							; wobble the opposite way
		addi.w	#$10,d0

	.no_rev:
		move.w	obBrick_StartY(a0),d1		; get initial position
		sub.w	d0,d1						; apply wobble
		move.w	d1,obY(a0)					; update the block's position to make it wobble

Brick_NoWobble:
		rts	
; ===========================================================================

; Type 03 - falls immediately (triggered by type 02)
Brick_Falling:
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)				; apply gravity
		jsr		(ObjFloorDist).l
		tst.w	d1							; has the block	hit the	floor?
		bpl.w	.exit						; if not, branch
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop the block falling
		move.w	obY(a0),obBrick_StartY(a0)
		move.b	#4,obSubtype(a0)			; final subtype - slow wobble on lava
		move.w	(a1),d0						; get 16x16 tile id the block is sitting on
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0					; is the 16x16 tile it's landed on lava? (REV 01 Change)
		bcc.s	.exit						; if yes, branch
		clr.b	obSubtype(a0)				; don't wobble

.exit:
		rts	
; ===========================================================================