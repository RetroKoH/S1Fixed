; ---------------------------------------------------------------------------
; Object 13 - fire ball	spawner (MZ, SLZ)
; This will be rewritten later for more functionality
; ---------------------------------------------------------------------------
; OST Constants
obFireM_SpawnTimer:		equ objoff_30		; 1 byte  | spawn timer (replacing obDelayAni)
; ---------------------------------------------------------------------------

; ===========================================================================
; Delay between launching fireballs
FireM_Rates:
		dc.b 30										; 0x - 0.5 seconds (unused)
		dc.b 60										; 1x - 1 seconds (SLZ2)
		dc.b 90										; 2x - 1.5 seconds (MZ3)
		dc.b 120									; 3x - 2 seconds (MZ1/2/3, SLZ1/3)
		dc.b 150									; 4x - 2.5 seconds (MZ1/2/3)
		dc.b 180									; 5x - 3 seconds (MZ3)
	; additional values to prevent errors with erroneous subtypes
		dc.b 210									; 6x - 3.5 seconds
		dc.b 240									; 7x - 4 seconds
; ===========================================================================

FireMaker:
		_move.l	#FireM_MakeFire,obAddr(a0)
		moveq	#$70,d0
		and.b	obSubtype(a0),d0					; get high nybble of subtype (firing rate)
		lsr.w	#4,d0
		move.b	FireM_Rates(pc,d0.w),d0
		move.b	d0,obFireM_SpawnTimer(a0)
		move.b	d0,obTimeFrame(a0)					; set time delay for lava balls
		andi.b	#$F,obSubtype(a0)					; isolate low nybble of subtype (speed/direction)
; ---------------------------------------------------------------------------

FireM_MakeFire:
		subq.b	#1,obTimeFrame(a0)					; decrement timer
		bne.s	.wait								; if time still	remains, branch
		move.b	obFireM_SpawnTimer(a0),obTimeFrame(a0)	; reset time delay
		bsr.w	ChkObjectVisible					; is object on-screen?
		bne.s	.wait								; if not, branch
		bsr.w	FindFreeObj							; find free object RAM slot
		bne.s	.wait								; branch if not found

		_move.l	#FireBall,obAddr(a1)				; load lava ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)			; copy subtype (speed/direction)

	.wait:
		offscreen.w	DeleteObject
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 13 (sub) - fire balls (MZ, SLZ)
; ---------------------------------------------------------------------------
; OST Constants
obFBall_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obFBall_Mode:			equ objoff_32		; 2 bytes | saved action mode based on subtype
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
		_move.l	#FBall_Action,obAddr(a0)
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
		move.w	d0,obFBall_Mode(a0)					; save mode for later use
		move.w	FBall_Speeds(pc,d0.w),obVelY(a0)	; load movement speed (set to vertical initially)
		move.b	#8,obDispWid(a0)
		cmpi.b	#6,obSubtype(a0)					; is object type below $06?
		bcs.s	.sound								; if yes, branch

	; subtypes 06 and 07 use horizontal attributes
		move.b	#$10,obDispWid(a0)
		move.b	#2,obAnim(a0)						; use horizontal animation
		move.w	obVelY(a0),obVelX(a0)				; set horizontal speed
		clr.w	obVelY(a0)							; clear vertical speed

	.sound:
		move.w	#sfx_Fireball,d0
		jsr		(QueueSound2).w						; play fireball sound
; ---------------------------------------------------------------------------

FBall_Action:
		tst.b	obRoutine(a0)
		bne.w	DeleteObject

		moveq	#0,d0
		move.w	obFBall_Mode(a0),d0
		move.w	FBall_TypeIndex(pc,d0.w),d1
		jsr		FBall_TypeIndex(pc,d1.w)			; update speed & check for wall collision
		bsr.w	SpeedToPos
		lea		Ani_Fire(pc),a1
		jsr		(AnimateSprite).w

FBall_ChkDel:
		offscreen.w	DeleteObject					; ProjectFM S3K Object Manager
		jmp		(DisplayAndCollision).l				; Clownacy DisplaySprite Fix; S3K TouchResponse
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
		_move.l	#DeleteObject,obAddr(a0)			; slate object for deletion

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
		move.w	#$10,obFBall_Mode(a0)
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
		move.w	#$10,obFBall_Mode(a0)
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
		move.w	#$10,obFBall_Mode(a0)
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
		move.w	#$10,obFBall_Mode(a0)
		move.b	#3,obAnim(a0)
		clr.w	obVelX(a0)							; stop object when it touches a	wall

	.no_wall:
; ---------------------------------------------------------------------------
; fireball type 08 is triggered when a fireball hits the wall; otherwise unused

FBall_Type_Stop:
		rts
; ===========================================================================