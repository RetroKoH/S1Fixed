; ---------------------------------------------------------------------------
; Object 14 - lava balls (MZ, SLZ)
; ---------------------------------------------------------------------------

LavaBall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LBall_Index(pc,d0.w),d1
		jmp		LBall_Index(pc,d1.w)	; FixBugs: Clownacy DisplaySprite Fix
; ===========================================================================
LBall_Index:
		dc.w LBall_Main-LBall_Index
		dc.w LBall_Action-LBall_Index
		dc.w LBall_Delete-LBall_Index

LBall_Speeds:
		dc.w -$400, -$500, -$600, -$700, -$200
		dc.w $200, -$200, $200,	0
; ===========================================================================

LBall_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#8,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_Fire,obMap(a0)
		move.w	#make_art_tile(ArtTile_Fireball,0,0),obGfx(a0)	; RetroKoH VRAM Overhaul
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)			; RetroKoH S2 Priority Manager
		move.b	#$8B,obColType(a0)
		
		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield
		
		move.w	obY(a0),objoff_30(a0)
		tst.b	objoff_29(a0)
		beq.s	.speed
		addq.b	#1,obPriority(a0)				; Add to upper byte, to add $100 to priority value -- RetroKoH S2 Priority Manager

.speed:
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	LBall_Speeds(pc,d0.w),obVelY(a0) ; load object speed (vertical)
		move.b	#8,obActWid(a0)
		cmpi.b	#6,obSubtype(a0) ; is object type below $6 ?
		blo.s	.sound		; if yes, branch

		move.b	#$10,obActWid(a0)
		move.b	#2,obAnim(a0)	; use horizontal animation
		move.w	obVelY(a0),obVelX(a0) ; set horizontal speed
		clr.w	obVelY(a0)	; delete vertical speed

.sound:
		move.w	#sfx_Fireball,d0
		jsr		(PlaySound_Special).l	; play lava ball sound

LBall_Action:	; Routine 2
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		add.w	d0,d0
		move.w	LBall_TypeIndex(pc,d0.w),d1
		jsr		LBall_TypeIndex(pc,d1.w)
		bsr.w	SpeedToPos
		lea		(Ani_Fire).l,a1
		bsr.w	AnimateSprite

LBall_ChkDel:
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
; ===========================================================================
LBall_TypeIndex:
		dc.w LBall_Type00-LBall_TypeIndex, LBall_Type00-LBall_TypeIndex
		dc.w LBall_Type00-LBall_TypeIndex, LBall_Type00-LBall_TypeIndex
		dc.w LBall_Type04-LBall_TypeIndex, LBall_Type05-LBall_TypeIndex
		dc.w LBall_Type06-LBall_TypeIndex, LBall_Type07-LBall_TypeIndex
		dc.w LBall_Type08-LBall_TypeIndex
; ===========================================================================
; lavaball types 00-03 fly up and fall back down

LBall_Type00:
		addi.w	#$18,obVelY(a0)	; increase object's downward speed
		move.w	objoff_30(a0),d0
		cmp.w	obY(a0),d0	; has object fallen back to its	original position?
		bhs.s	loc_E41E	; if not, branch
		addq.b	#2,obRoutine(a0)	; goto "LBall_Delete" routine

loc_E41E:
		bclr	#staFlipY,obStatus(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_E430
		bset	#staFlipY,obStatus(a0)

locret_E430:
		rts	
; ===========================================================================
; lavaball type	04 flies up until it hits the ceiling

LBall_Type04:
		bset	#staFlipY,obStatus(a0)
		jsr		(ObjHitCeiling).l
		tst.w	d1
		bpl.s	locret_E452
		move.b	#8,obSubtype(a0)
		move.b	#1,obAnim(a0)
		clr.w	obVelY(a0)	; stop the object when it touches the ceiling

locret_E452:
		rts	
; ===========================================================================
; lavaball type	05 falls down until it hits the	floor

LBall_Type05:
		bclr	#staFlipY,obStatus(a0)
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_E474
		move.b	#8,obSubtype(a0)
		move.b	#1,obAnim(a0)
		clr.w	obVelY(a0)	; stop the object when it touches the floor

locret_E474:
		rts	
; ===========================================================================
; lavaball types 06-07 move sideways

LBall_Type06:
		bset	#staFlipX,obStatus(a0)
		moveq	#-8,d3
		jsr		(ObjHitWallLeft).l
		tst.w	d1
		bpl.s	locret_E498
		move.b	#8,obSubtype(a0)
		move.b	#3,obAnim(a0)
		clr.w	obVelX(a0)	; stop object when it touches a	wall

locret_E498:
		rts	
; ===========================================================================

LBall_Type07:
		bclr	#staFlipX,obStatus(a0)
		moveq	#8,d3
		jsr		(ObjHitWallRight).l
		tst.w	d1
		bpl.s	locret_E4BC
		move.b	#8,obSubtype(a0)
		move.b	#3,obAnim(a0)
		clr.w	obVelX(a0)	; stop object when it touches a	wall

locret_E4BC:
		rts	
; ===========================================================================

LBall_Type08:
		rts	
; ===========================================================================

LBall_Delete:
		bra.w	DeleteObject
