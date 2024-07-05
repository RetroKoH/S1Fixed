; ---------------------------------------------------------------------------
; Object 1F - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------

Crabmeat:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Crab_Index(pc,d0.w),d1
		jmp		Crab_Index(pc,d1.w)
; ===========================================================================
Crab_Index:		offsetTable
ptr_Crab_Main:		offsetTableEntry.w	Crab_Main
ptr_Crab_Action:	offsetTableEntry.w	Crab_Action
ptr_Crab_Delete:	offsetTableEntry.w	Crab_Delete
ptr_Crab_BallMain:	offsetTableEntry.w	Crab_BallMain
ptr_Crab_BallMove:	offsetTableEntry.w	Crab_BallMove

id_Crab_Main = ptr_Crab_Main-Crab_Index	; 0
id_Crab_Action = ptr_Crab_Action-Crab_Index	; 2
id_Crab_Delete = ptr_Crab_Delete-Crab_Index	; 4
id_Crab_BallMain = ptr_Crab_BallMain-Crab_Index	; 6
id_Crab_BallMove = ptr_Crab_BallMove-Crab_Index	; 8

crab_timedelay = objoff_30
crab_mode = objoff_32
; ===========================================================================

Crab_Main:	; Routine 0
		move.b	#$10,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_Crab,obMap(a0)
		move.w	#make_art_tile(ArtTile_Crabmeat,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#6,obColType(a0)
		move.b	#$15,obActWid(a0)
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l	; find floor
		tst.w	d1
		bpl.s	.floornotfound
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)

.floornotfound:
		rts	
; ===========================================================================

Crab_Action:	; Routine 2
	; LavaGaming Object Routine Optimization
		tst.b	ob2ndRout(a0)
		bne.w	.walkonfloor
	; Object Routine Optimization End

.waittofire:
		subq.w	#1,crab_timedelay(a0) ; subtract 1 from time delay
		bpl.s	.dontmove
		tst.b	obRender(a0)
		bpl.s	.movecrab
		bchg	#1,crab_mode(a0)
		bne.s	.fire

.movecrab:
		addq.b	#2,ob2ndRout(a0)
		move.w	#127,crab_timedelay(a0) ; set time delay to approx 2 seconds
		move.w	#$80,obVelX(a0)	; move Crabmeat	to the right
		bsr.w	Crab_SetAni
		addq.b	#3,d0
		move.b	d0,obAnim(a0)
		bchg	#staFlipX,obStatus(a0)
		bne.s	.noflip
		neg.w	obVelX(a0)	; change direction

.dontmove:
.noflip:
		lea		(Ani_Crab).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

.fire:
		move.w	#59,crab_timedelay(a0)
		move.b	#6,obAnim(a0)	; use firing animation
		bsr.w	FindFreeObj
		bne.s	.failleft
		_move.b	#id_Crabmeat,obID(a1) ; load left fireball
		move.b	#id_Crab_BallMain,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		subi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#-$100,obVelX(a1)

.failleft:
		bsr.w	FindFreeObj
		bne.s	.failright
		_move.b	#id_Crabmeat,obID(a1) ; load right fireball
		move.b	#id_Crab_BallMain,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		addi.w	#$10,obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	#$100,obVelX(a1)

.failright:
		lea		(Ani_Crab).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

.walkonfloor:
		subq.w	#1,crab_timedelay(a0)
		bmi.s	loc_966E
		bsr.w	SpeedToPos
		bchg	#0,crab_mode(a0)
		bne.s	loc_9654
		move.w	obX(a0),d3
		addi.w	#$10,d3
		btst	#staFlipX,obStatus(a0)
		beq.s	loc_9640
		subi.w	#$20,d3

loc_9640:
		jsr	(ObjFloorDist2).l
		cmpi.w	#-8,d1
		blt.s	loc_966E
		cmpi.w	#$C,d1
		bge.s	loc_966E
		lea		(Ani_Crab).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

loc_9654:
		jsr		(ObjFloorDist).l
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.s	Crab_SetAni
		addq.b	#3,d0
		move.b	d0,obAnim(a0)
		lea		(Ani_Crab).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

loc_966E:
		subq.b	#2,ob2ndRout(a0)
		move.w	#59,crab_timedelay(a0)
		clr.w	obVelX(a0)
		bsr.s	Crab_SetAni
		move.b	d0,obAnim(a0)
		lea		(Ani_Crab).l,a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ---------------------------------------------------------------------------
; Subroutine to	set the	correct	animation for a	Crabmeat
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Crab_SetAni:
		moveq	#0,d0
		move.b	obAngle(a0),d3
		bmi.s	loc_96A4
		cmpi.b	#6,d3
		blo.s	locret_96A2
		moveq	#1,d0
		btst	#staFlipX,obStatus(a0)
		bne.s	locret_96A2
		moveq	#2,d0

locret_96A2:
		rts	
; ===========================================================================

loc_96A4:
		cmpi.b	#-6,d3
		bhi.s	locret_96B6
		moveq	#2,d0
		btst	#staFlipX,obStatus(a0)
		bne.s	locret_96B6
		moveq	#1,d0

locret_96B6:
		rts	
; End of function Crab_SetAni

; ===========================================================================

Crab_Delete:	; Routine 4
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sub-object - missile that the	Crabmeat throws
; ---------------------------------------------------------------------------

Crab_BallMain:	; Routine 6
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Crab,obMap(a0)
		move.w	#make_art_tile(ArtTile_Crabmeat,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$180,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#$87,obColType(a0)
		move.b	#8,obActWid(a0)
		move.w	#-$400,obVelY(a0)
		move.b	#7,obAnim(a0)
		
		bset	#shPropReflect,obShieldProp(a0)	; Reflected by Elemental Shields

Crab_BallMove:	; Routine 8
		lea	(Ani_Crab).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectFall
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0		; has object moved below the level boundary?
		blo.w	DeleteObject
		bra.w	DisplaySprite	; Clownacy DisplaySprite Fix
