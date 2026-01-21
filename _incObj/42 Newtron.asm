; ---------------------------------------------------------------------------
; Object 42 - Newtron enemy (GHZ)
; ---------------------------------------------------------------------------
; OST Constants
obNewt_FireFlag:		equ objoff_32		; 1 byte  | set to 1 after newtron fires a missile
; ---------------------------------------------------------------------------

Newtron:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.s	Newt_Action
		bpl.w	DeleteObject
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Newt_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Newt_Action
		move.l	#Map_Newt,obMap(a0)
		move.w	#make_art_tile(ArtTile_Newtron,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$14,obDispWid(a0)
		move.w	#$1008,obHeight(a0)			; Height and Width

Newt_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	NewtAct_Index(pc,d0.w),d1
		jmp		NewtAct_Index(pc,d1.w)
; ===========================================================================

NewtAct_Index:		offsetTable
		offsetTableEntry.w Newt_ChkDist
		offsetTableEntry.w Newt_Type0
		offsetTableEntry.w Newt_Type0_Floor
		offsetTableEntry.w Newt_Type0_Fly
		offsetTableEntry.w Newt_Type1
; ===========================================================================

Newt_ChkDist:
		bset	#staFlipX,obStatus(a0)		; face right
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.sonicisright				; branch if Sonic is to the right
		neg.w	d0							; if to the left, get absolute value
		bclr	#staFlipX,obStatus(a0)		; face left

	.sonicisright:
		cmpi.w	#128,d0						; is Sonic within 128 pixels of	the newtron?
		bhs.s	.animate					; if not, branch
		addq.b	#2,ob2ndRout(a0)			; -> Newt_Type0
		move.b	#1,obAnim(a0)
		tst.b	obSubtype(a0)				; check	object type
		beq.s	.animate					; if type is 00, branch

		move.w	#make_art_tile(ArtTile_Newtron,1,0),obGfx(a0)
		move.b	#8,ob2ndRout(a0)			; -> Newt_Type1
		move.b	#4,obAnim(a0)				; use different	animation

	.animate:
		lea		Ani_Newt(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Newt_Type0:
		cmpi.b	#4,obFrame(a0)				; has "appearing" animation finished?
		bhs.s	.fall						; is yes, branch
		bset	#staFlipX,obStatus(a0)		; face right
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.sonicisright				; branch if Sonic is to the right
		bclr	#staFlipX,obStatus(a0)		; face left

	.sonicisright:
		lea		Ani_Newt(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

	.fall:
		cmpi.b	#1,obFrame(a0)				; is fully visible upright frame used?
		bne.s	.no_hitbox					; if not, branch
		move.b	#(colEnemy|colSz_20x16),obColType(a0)

	.no_hitbox:
		bsr.w	ObjectFall_YOnly
		jsr		(ObjFloorDist).l
		tst.w	d1							; has newtron hit the floor?
		bpl.s	.animate					; if not, branch

		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop newtron falling
		addq.b	#2,ob2ndRout(a0)			; goto Newt_Type0_Floor next
		move.b	#2,obAnim(a0)
		btst	#gfxPalLower,obGfx(a0)		; is newtron blue?
		beq.s	.is_blue					; if yes, branch
		addq.b	#1,obAnim(a0)				; use different animation for green newtron

	.is_blue:
		move.b	#(colEnemy|colSz_20x8),obColType(a0)
		move.w	#$200,obVelX(a0)			; move newtron horizontally
		btst	#staFlipX,obStatus(a0)
		bne.s	.animate
		neg.w	obVelX(a0)

	.animate:
		lea		Ani_Newt(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Newt_Type0_Floor:
		bsr.w	SpeedToPos_XOnly
		jsr		(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	.nextroutine				; branch if more than 8px below floor
		cmpi.w	#$C,d1
		bge.s	.nextroutine				; branch if more than 11px above floor (also detects a ledge)
		add.w	d1,obY(a0)					; align to floor
		bra.s	.animate
; ===========================================================================

	.nextroutine:
		addq.b	#2,ob2ndRout(a0)			; -> Newt_Type0_Fly

	.animate:
		lea		Ani_Newt(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Newt_Type0_Fly:
		bsr.w	SpeedToPos_XOnly
		lea		Ani_Newt(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Newt_Type1:
	if GreenNewtronReappears		; KoH Green Newtron Reappear Fix
		cmpi.b	#$A,obFrame(a0)
		bne.s	.not_hidden
		clr.b	obColType(a0)
		bra.w	RememberState
; ===========================================================================

	.not_hidden:
	endif
		cmpi.b	#1,obFrame(a0)
		bne.s	.firemissile
		move.b	#(colEnemy|colSz_20x16),obColType(a0)

	.firemissile:
		cmpi.b	#2,obFrame(a0)				; is animation on firing frame?
		bne.s	.fail						; if not, branch
		tst.b	obNewt_FireFlag(a0)			; has newtron already fired?
		bne.s	.fail						; if yes, branch

		move.b	#1,obNewt_FireFlag(a0)		; set fired flag
		bsr.w	FindFreeObj
		bne.s	.fail

		_move.l	#Missile,obAddr(a1)			; load missile object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		subq.w	#8,obY(a1)
		move.w	#$200,obVelX(a1)			; missile goes right
		moveq	#$14,d0
		btst	#staFlipX,obStatus(a0)		; is newtron facing right?
		bne.s	.noflip						; if yes, branch
		neg.w	d0
		neg.w	obVelX(a1)					; missile goes left

	.noflip:
		add.w	d0,obX(a1)
		move.b	obStatus(a0),obStatus(a1)
		move.b	#1,obSubtype(a1)

	.fail:
		lea		Ani_Newt(pc),a1
		jsr		(AnimateSprite).w			; animate (green newtron goto DeleteObject after firing)
		bra.w	RememberState
; ===========================================================================
