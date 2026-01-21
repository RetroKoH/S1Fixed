; ---------------------------------------------------------------------------
; Object 1F - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------
; OST Constants
obCrab_WaitTime:		equ objoff_30		; 2 bytes | time until crabmeat fires
obCrab_Mode:			equ objoff_32		; 1 byte  | current action - 0/1 = not firing; 2/3 = firing
; ---------------------------------------------------------------------------

Crabmeat:
		move.l	#Crab_ChkFloor,obAddr(a0)
		move.w	#$1008,obHeight(a0)			; Height and Width
		move.l	#Map_Crab,obMap(a0)
		move.w	#make_art_tile(ArtTile_Crabmeat,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_16x16),obColType(a0)
		move.b	#$15,obDispWid(a0)
; ---------------------------------------------------------------------------

Crab_ChkFloor:
		bsr.w	ObjectFall_YOnly			; immediately make crabmeat fall
		jsr		(ObjFloorDist).l			; find floor
		tst.w	d1							; has crabmeat hit floor?
		bpl.s	.floornotfound				; if not, branch (repeat until floor is found)
		add.w	d1,obY(a0)					; align to floor
		move.b	d3,obAngle(a0)				; copy floor angle
		clr.w	obVelY(a0)					; stop falling
		obj_addr	#CrabAct_WaitFire

	.floornotfound:
		rts	
; ===========================================================================

CrabAct_WaitFire:
		subq.w	#1,obCrab_WaitTime(a0)		; decrement timer
		bpl.s	.dontmove					; branch if time remains
		tst.b	obRender(a0)				; is crabmeat on-screen?
		bpl.s	.movecrab					; if not, branch
		bchg	#1,obCrab_Mode(a0)			; set mode to firing
		bne.s	.fire						; branch if previously set

	.movecrab:
		obj_addr	#CrabAct_Walk
		move.w	#127,obCrab_WaitTime(a0)	; set time delay to approx 2 seconds
		move.w	#$80,obVelX(a0)				; move Crabmeat	to the right
		bsr.w	Crab_SetAni					; select animation based on floor angle
		addq.b	#3,d0						; use walking animation
		bsr.w	NewAnim
		bchg	#staFlipX,obStatus(a0)
		bne.s	.noflip
		neg.w	obVelX(a0)					; change direction

	.dontmove:
	.noflip:
		lea		Ani_Crab(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

	.fire:
		move.w	#59,obCrab_WaitTime(a0)
		move.b	#6,obAnim(a0)				; use firing animation

	; RetroKoH Mass Object Load Optimization; Built off of Spirituinsanum's Ring Loss Optimization
	; Here we begin what's replacing FindFreeObj/SingleObjLoad
	; Slight improvement by Malachi
		lea		(v_lvlobjspace-object_size).w,a1	; start address for object RAM
		move.w	#v_lvlobjcount,d0

	.loop:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		dbeq	d0,.loop					; Branch correction again.
		bne.s	.fail						; We're moving this line here.

		_move.l	#Crab_Ball,obAddr(a1)		; load left fireball
		move.w	obX(a0),obX(a1)
		subi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#-$100,obVelX(a1)

	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		dbeq	d0,.loop					; Branch correction again.
		bne.s	.fail						; We're moving this line here.

		_move.l	#Crab_Ball,obAddr(a1)		; load right fireball
		move.w	obX(a0),obX(a1)
		addi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$100,obVelX(a1)

	.fail:
		lea		Ani_Crab(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

CrabAct_Walk:
		subq.w	#1,obCrab_WaitTime(a0)		; decrement timer
		bmi.s	.stop						; branch if -1
		bsr.w	SpeedToPos_XOnly
		bchg	#0,obCrab_Mode(a0)			; set mode to floor check
		bne.s	.findfloor_here				; branch if previously set
		move.w	obX(a0),d3
		addi.w	#16,d3						; find floor 16px to the right
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		subi.w	#32,d3						; find floor 16px to the left

	.noflip:
		jsr		(ObjFloorDist2).l
		cmpi.w	#-8,d1						; is there a wall ahead?
		blt.s	.stop						; if yes, branch
		cmpi.w	#$C,d1						; is there a drop ahead?
		bge.s	.stop						; if yes, branch
		lea		Ani_Crab(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

	.findfloor_here:
		jsr		(ObjFloorDist).l			; find floor at current position
		add.w	d1,obY(a0)					; align to floor
		move.b	d3,obAngle(a0)				; update angle
		bsr.s	Crab_SetAni					; set animation based on angle
		addq.b	#3,d0						; use walking animation
		bsr.w	NewAnim
		lea		Ani_Crab(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

	.stop:
		obj_addr	#CrabAct_WaitFire
		move.w	#59,obCrab_WaitTime(a0)
		clr.w	obVelX(a0)
		bsr.s	Crab_SetAni					; set animation based on angle
		bsr.w	NewAnim						; use standing animation
		lea		Ani_Crab(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	set the	correct	animation for a	Crabmeat
;
; output:
;	d0 = animation id (0 = flat; 1 = slope; 2 = xflip slope)
; ---------------------------------------------------------------------------

Crab_SetAni:
		moveq	#0,d0						; use standing flat animation by default
		move.b	obAngle(a0),d3				; get floor angle
		bmi.s	.slope_up_right				; branch if sloping up-right
		cmpi.b	#6,d3						; is slope at least 6?
		blo.s	.nearly_flat				; if not, branch
		moveq	#1,d0						; use standing up-left slope animation
		btst	#staFlipX,obStatus(a0)
		bne.s	.nearly_flat
		moveq	#2,d0						; use x-flip animation

	.nearly_flat:
		rts	
; ===========================================================================

	.slope_up_right:
		cmpi.b	#-6,d3						; is slope at least 6?
		bhi.s	.nearly_flat2				; if not, branch
		moveq	#2,d0						; use standing up-right slope animation
		btst	#staFlipX,obStatus(a0)
		bne.s	.nearly_flat2
		moveq	#1,d0						; use x-flip animation

	.nearly_flat2:
		rts	
; End of function Crab_SetAni
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 1F (sub) - missile that the Crabmeat throws
; ---------------------------------------------------------------------------

Crab_Ball:
		_move.l	#Crab_BallMove,obAddr(a0)
		move.l	#Map_CrabBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_Crabmeat,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_6x6),obColType(a0)
		move.b	#8,obDispWid(a0)
		move.w	#-$400,obVelY(a0)
		
		bset	#shPropReflect,obShieldProp(a0)	; Reflected by Elemental Shields
; ---------------------------------------------------------------------------

Crab_BallMove:	; Routine 8
		subq.b	#1,obTimeFrame(a0)				; decrement time
		bpl.s	.wait							; branch if time remains
		move.b	#1,obTimeFrame(a0)				; reset time
		bchg	#0,obFrame(a0)					; toggle between sprites every 2 frames

	.wait:
		bsr.w	ObjectFall
		move.w	(v_limitbtm).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0						; has object moved below the level boundary?
		blo.w	DeleteObject
		jmp		(DisplayAndCollision).l			; Clownacy DisplaySprite Fix; S3K TouchResponse
; ===========================================================================