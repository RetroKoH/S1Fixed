; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------
; OST Constants
obChop_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
; ---------------------------------------------------------------------------

Chopper:
		_move.l	#Chop_Jump,obAddr(a0)
		move.l	#Map_Chop,obMap(a0)
		move.w	#make_art_tile(ArtTile_Chopper,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_12x16),obColType(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#-$700,obVelY(a0)			; set vertical speed
		move.w	obY(a0),obChop_StartY(a0)	; save original position

Chop_Jump:
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)				; apply gravity
		tst.w	obVelY(a0)
		bpl.s	.fall						; branch if falling
		moveq	#3,d1						; use fast animation
		move.w	obChop_StartY(a0),d0
		sub.w	obY(a0),d0					; d0 = distance from start
		subi.w	#192,d0
		bcc.s	.above_192					; branch if > 192px ($C0) above start
		moveq	#7,d1						; use slow animation
		
	.above_192:
		subq.b	#1,obTimeFrame(a0)			; decrement time
		bpl.s	.wait						; if time remains, branch
		move.b	d1,obTimeFrame(a0)			; reset time based on desired animation speed
		bchg	#0,obFrame(a0)				; swap frames to animate

	.wait:
		bra.w	RememberState
; ===========================================================================

	.fall:
	if ChopperAnimationTweak
		bset	#staFlipY,obRender(a0)		; flip Chopper and make it appear over the bridge
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
	endif
		obj_addr	#Chop_Fall
		bra.w	RememberState
; ===========================================================================

Chop_Fall:
		subq.b	#1,obTimeFrame(a0)			; decrement time
		bpl.s	.wait						; if time remains, branch
		move.b	#3,obTimeFrame(a0)			; reset time based on desired animation speed
		bchg	#0,obFrame(a0)				; swap frames to animate

	.wait:
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)				; apply gravity
		move.w	obChop_StartY(a0),d0
		sub.w	obY(a0),d0					; d0 = distance from start
		subi.w	#192,d0
		bcc.w	RememberState				; branch if > 192px above start

		clr.b	obFrame(a0)					; shut mouth frame (no animation)
		obj_addr	#Chop_Fall2
		bra.w	RememberState
; ===========================================================================

Chop_Fall2:
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)				; apply gravity
		move.w	obChop_StartY(a0),d0
		sub.w	obY(a0),d0
		bcc.w	RememberState				; branch if chopper hasn't hit start position

		move.w	obChop_StartY(a0),obY(a0)	; snap to start position
		move.w	#-$700,obVelY(a0)			; reset vertical speed
	if ChopperAnimationTweak
		bclr	#staFlipY,obRender(a0)		; flip Chopper and make it appear behind the bridge
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
	endif
		obj_addr	#Chop_Jump
		bra.w	RememberState
; ===========================================================================