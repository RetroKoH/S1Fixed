; ---------------------------------------------------------------------------
; Object 14 - fire balls (MZ, SLZ)
;
; spawned by:
;	FireMaker, BossMarble
; ---------------------------------------------------------------------------

; ===========================================================================
FBall_Speeds:
	; Vertical - goes up and falls down
		dc.w -$400									; x0
		dc.w -$500									; x1
		dc.w -$600									; x2
		dc.w -$700									; x3 (unused)

	; Vertical - constant speed
		dc.w -$200									; x4 (unused)
		dc.w $200									; x5

	; Horizontal
		dc.w -$200									; x6
		dc.w $200									; x7
		dc.w 0										; x8 (used only when fireball hits walls)
; ===========================================================================

;LavaBall:
FireBall:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.w	FBall_Action
		bpl.w	DeleteObject
	; Object Routine Optimization End

FBall_Main:		; Routine 0
		addq.b	#2,obRoutine(a0)					; -> FBall_Action
		move.w	#$808,obHeight(a0)					; Height and Width
		move.l	#Map_Fire,obMap(a0)
		move.w	#make_art_tile(ArtTile_Fireball,0,0),obGfx(a0)	; RetroKoH VRAM Overhaul
		move.b	#4,obRender(a0)

	; This allows us to use one less OST byte for this object
		tst.w	obPriority(a0)						; was priority already set (only applies to boss fireballs)
		bne.s	.keep_priority						; if yes, branch
		move.w	#priority3,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager

	.keep_priority:
		move.b	#(colHarmful|colSz_8x8),obColType(a0)
		
		bset	#shPropFlame,obShieldProp(a0)		; Negated by Flame Shield
		
		move.w	obY(a0),obFBall_StartY(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	FBall_Speeds(pc,d0.w),obVelY(a0)	; load movement speed (set to vertical initially)
		move.b	#8,obDispWid(a0)
		cmpi.b	#6,obSubtype(a0)					; is object type below 0-5?
		bcs.s	.sound								; if yes, branch

	; subtypes 06 and 07 use horizontal attributes
		move.b	#$10,obDispWid(a0)
		move.b	#2,obAnim(a0)						; use horizontal animation
		move.w	obVelY(a0),obVelX(a0)				; set horizontal speed
		clr.w	obVelY(a0)							; clear vertical speed

	.sound:
		move.w	#sfx_Fireball,d0
		jsr		(QueueSound2).w						; play fireball sound

FBall_Action:	; Routine 2
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	FBall_TypeIndex(pc,d0.w),d1
		jsr		FBall_TypeIndex(pc,d1.w)			; update speed & check for wall collision
		bsr.w	SpeedToPos
		lea		Ani_Fire(pc),a1
		jsr		(AnimateSprite).w

FBall_ChkDel:
		offscreen.w	DeleteObject					; ProjectFM S3K Object Manager
		jmp	(DisplayAndCollision).l					; Clownacy DisplaySprite Fix; S3K TouchResponse
; ===========================================================================

FBall_TypeIndex:	offsetTable
		offsetTableEntry.w FBall_Type_UpDown		; x0
		offsetTableEntry.w FBall_Type_UpDown		; x1
		offsetTableEntry.w FBall_Type_UpDown		; x2
		offsetTableEntry.w FBall_Type_UpDown		; x3 (unused)
		offsetTableEntry.w FBall_Type_Up			; x4 (unused)
		offsetTableEntry.w FBall_Type_Down			; x5
		offsetTableEntry.w FBall_Type_Left			; x6
		offsetTableEntry.w FBall_Type_Right			; x7
		offsetTableEntry.w FBall_Type_Stop			; x8 (used only when fireball hits walls)
; ===========================================================================
; fireball types 00-03 fly up and fall back down

FBall_Type_UpDown:
		addi.w	#$18,obVelY(a0)						; increase object's downward speed
		move.w	obFBall_StartY(a0),d0
		cmp.w	obY(a0),d0							; has object fallen back to its	original position?
		bhs.s	.keep_falling						; if not, branch
		addq.b	#2,obRoutine(a0)					; -> DeleteObject

	.keep_falling:
		bclr	#staFlipY,obStatus(a0)
		tst.w	obVelY(a0)							; is fireball falling downwards?
		bpl.s	.falling							; if yes, branch
		bset	#staFlipY,obStatus(a0)				; face fireball upwards

	.falling:
		rts	
; ===========================================================================
; fireball type	04 flies up until it hits the ceiling

FBall_Type_Up:
		bset	#staFlipY,obStatus(a0)
		jsr		(ObjHitCeiling).l
		tst.w	d1									; distance to ceiling
		bpl.s	.no_ceiling							; branch if ceiling not found
		move.b	#8,obSubtype(a0)
		move.b	#1,obAnim(a0)
		clr.w	obVelY(a0)							; stop the object when it touches the ceiling

	.no_ceiling:
		rts	
; ===========================================================================
; fireball type	05 falls down until it hits the	floor

FBall_Type_Down:
		bclr	#staFlipY,obStatus(a0)
		jsr		(ObjFloorDist).l
		tst.w	d1									; distance to floor
		bpl.s	.no_floor							; branch if floor not found
		move.b	#8,obSubtype(a0)
		move.b	#1,obAnim(a0)
		clr.w	obVelY(a0)							; stop the object when it touches the floor

	.no_floor:
		rts	
; ===========================================================================
; fireball types 06-07 move sideways until they hit a wall

FBall_Type_Left:
		bset	#staFlipX,obStatus(a0)
		moveq	#-8,d3								; distance from centre to left edge of fireball
		jsr		(ObjHitWallLeft).l
		tst.w	d1									; distance to left wall
		bpl.s	.no_wall							; branch if wall not found
		move.b	#8,obSubtype(a0)
		move.b	#3,obAnim(a0)
		clr.w	obVelX(a0)							; stop object when it touches a	wall

	.no_wall:
		rts	
; ===========================================================================

FBall_Type_Right:
		bclr	#staFlipX,obStatus(a0)
		moveq	#8,d3								; distance from centre to right edge of fireball
		jsr		(ObjHitWallRight).l
		tst.w	d1									; distance to right wall
		bpl.s	.no_wall							; branch if wall not found
		move.b	#8,obSubtype(a0)
		move.b	#3,obAnim(a0)
		clr.w	obVelX(a0)							; stop object when it touches a	wall

	.no_wall:
; ---------------------------------------------------------------------------
; fireball type 08 is triggered when a fireball hits the wall; otherwise unused

FBall_Type_Stop:
		rts	
; ===========================================================================