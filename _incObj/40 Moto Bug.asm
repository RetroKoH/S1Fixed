; ---------------------------------------------------------------------------
; Object 40 (sub) - Moto Bug smoke
; ---------------------------------------------------------------------------

MotoSmoke:
	; LavaGaming/RetroKoH Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	DeleteObject
	; Object Routine Optimization End

		lea		Ani_Moto(pc),a1
		jsr		(AnimateSprite).w
		bra.w	DisplaySprite
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------
; OST Constants
obMoto_TurnTime:		equ objoff_30		; 2 bytes | time delay before changing direction
obMoto_SmokeDelay:		equ objoff_32		; 1 byte  | time delay between smoke puffs
obMoto_SpeedUpFlag:		equ objoff_33		; 1 byte  | flag used with an upcoming behavior mod
; ---------------------------------------------------------------------------

MotoBug:
		_move.l	#Moto_ChkFloor,obAddr(a0)
		move.w	#$E08,obHeight(a0)			; Height and Width
		move.l	#Map_Moto,obMap(a0)
		move.w	#make_art_tile(ArtTile_Moto_Bug,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$14,obDispWid(a0)
		move.b	#(colEnemy|colSz_20x16),obColType(a0)
		move.w	#-$100,obVelX(a0)			; move object to the left
		btst	#staFlipX,obStatus(a0)
		beq.s	Moto_ChkFloor				; branch if facing left
		neg.w	obVelX(a0)					; moves right
; ---------------------------------------------------------------------------

Moto_ChkFloor:
		bsr.w	ObjectFall_YOnly			; immediately make motobug fall
		bsr.w	ObjFloorDist				; find floor
		tst.w	d1							; has motobug hit floor?
		bpl.s	.floornotfound				; if not, branch (repeat until floor is found)
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop falling
		obj_addr	#Moto_Move

	.floornotfound:
		rts
; ===========================================================================

Moto_Move:
		lea		Ani_Moto(pc),a1
		jsr		(AnimateSprite).w			; call this first so we can end the routine faster
		bsr.w	SpeedToPos_XOnly
		jsr		(ObjFloorDist).l			; d1 = distance to floor
		cmpi.w	#-8,d1
		blt.s	.pause
		cmpi.w	#$C,d1
		bge.s	.pause						; branch if more than 11px above or 8px below floor

		add.w	d1,obY(a0)					; align to floor
		subq.b	#1,obMoto_SmokeDelay(a0)	; decrement time between smoke puffs
		bpl.w	RememberState				; branch if time remains
		move.b	#$F,obMoto_SmokeDelay(a0)	; reset timer
		bsr.w	FindFreeObj
		bne.w	RememberState				; branch if free object slot not found

		_move.l	#MotoSmoke,obAddr(a1)		; load exhaust smoke object (A slight bit more work here, since we will go straight to animating)
		move.l	#Map_Moto,obMap(a1)
		move.w	#make_art_tile(ArtTile_Moto_Bug,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#4,obDispWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#1,obAnim(a1)
		bra.w	RememberState

	.pause:
		obj_addr	#Moto_Wait
		move.w	#59,obMoto_TurnTime(a0)		; set pause time to 1 second
		move.b	#2,obFrame(a0)
		bra.w	RememberState
; ===========================================================================

; Note that we never clear obVelX, because this routine never uses it to move the Moto Bug.
Moto_Wait:
		subq.w	#1,obMoto_TurnTime(a0)		; decrement wait timer
		bpl.w	RememberState				; branch if time remains
		obj_addr	#Moto_Move
		bchg	#staFlipX,obRender(a0)
		bchg	#staFlipX,obStatus(a0)		; change direction
		neg.w	obVelX(a0)					; reverse movement direction
		clr.w	obAniFrame(a0)				; reset animation and frame duration
		bra.w	RememberState
; ===========================================================================