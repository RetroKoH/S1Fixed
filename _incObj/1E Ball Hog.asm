; ---------------------------------------------------------------------------
; Object 1E - Ball Hog enemy (SBZ)
; ---------------------------------------------------------------------------
; OST Constants
obHog_TimeMaster:		equ objoff_30		; 2 bytes | timer applied to the cannonball
; ---------------------------------------------------------------------------

BallHog:
		move.l	#Hog_ChkFloor,obAddr(a0)
		move.w	#$1308,obHeight(a0)			; Height and Width
		move.l	#Map_Hog,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ball_Hog,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_12x18),obColType(a0)
		move.b	#$C,obDispWid(a0)

	; Calculate explode time once, instead of every time a cannonball is launched
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; move subtype to d0
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,obHog_TimeMaster(a0)		; store explosion time
; ---------------------------------------------------------------------------

Hog_ChkFloor:
		bsr.w	ObjectFall_YOnly			; immediately make ballhog fall
		jsr		(ObjFloorDist).l			; find floor
		tst.w	d1							; has ballhog hit floor?
		bpl.s	.floornotfound				; if not, branch (repeat until floor is found)
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop falling
		obj_addr	#Hog_Action

	.floornotfound:
		rts	
; ===========================================================================

Hog_Action:
		lea		Ani_Hog(pc),a1
		bsr.w	AnimateSprite
		cmpi.b	#1,obFrame(a0)				; is final frame (01) displayed?
		bne.w	RememberState				; if not, branch
		cmpi.b	#9,obTimeFrame(a0)
		bne.w	RememberState				; branch if not only just on last frame

		bsr.w	FindFreeObj
		bne.w	RememberState
		_move.l	#Cannonball,obAddr(a1)		; load cannonball object ($20)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#$FF000000,obVelX(a1)		; cannonball bounces to the left (-$100) and clear obYVel
		moveq	#-4,d0
		btst	#staFlipX,obStatus(a0)		; is Ball Hog facing right?
		beq.s	.noflip						; if not, branch
		neg.w	d0
		neg.w	obVelX(a1)					; cannonball bounces to	the right

	.noflip:
		add.w	d0,obX(a1)
		addi.w	#$C,obY(a1)
		move.w	obHog_TimeMaster(a0),obCBall_Time(a1)	; copy stored explode time
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 1E (sub) - cannonball that Ball Hog throws (SBZ)
; ---------------------------------------------------------------------------
; OST Constants
obCBall_Time:			equ objoff_30		; 2 bytes | (sub only) time until the cannonball explodes
; ---------------------------------------------------------------------------

Cannonball:
		move.l	#Cbal_Bounce,obAddr(a0)
		move.b	#7,obHeight(a0)
		move.l	#Map_Hog,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ball_Hog,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_6x6),obColType(a0)
		move.b	#8,obDispWid(a0)
		move.b	#4,obFrame(a0)
; ---------------------------------------------------------------------------

Cbal_Bounce:
		jsr		(ObjectFall).l
		tst.w	obVelY(a0)
		bmi.s	.chk_explode
		jsr		(ObjFloorDist).l
		tst.w	d1							; has ball hit the floor?
		bpl.s	.chk_explode				; if not, branch

		add.w	d1,obY(a0)					; align to floor
		move.w	#-$300,obVelY(a0)			; bounce
		tst.b	d3							; test floor angle
		beq.s	.chk_explode				; branch if perfectly flat
		bmi.s	.down_left					; branch if sloping up-right or down-left

	;.down_right:
		tst.w	obVelX(a0)
		bpl.s	.chk_explode				; branch if ball is moving right
		neg.w	obVelX(a0)					; reverse direction (ball hits down-right slope while moving left)
		bra.s	.chk_explode
; ===========================================================================

	.down_left:
		tst.w	obVelX(a0)
		bmi.s	.chk_explode				; branch if ball is moving left
		neg.w	obVelX(a0)					; reverse direction (ball hits down-left slope while moving right)

	.chk_explode:
		subq.w	#1,obCBall_Time(a0)			; subtract 1 from explosion time
		bpl.s	.animate					; if time is > 0, branch

	;.explode:
		_move.l	#ExplosionBomb,obAddr(a0)	; change object	to an explosion	($3F)
		bra.w	ExplosionBomb				; jump to explosion code
; ===========================================================================

	.animate:
		subq.b	#1,obTimeFrame(a0)			; subtract 1 from frame duration
		bpl.s	.display
		move.b	#5,obTimeFrame(a0)			; set frame duration to 5 frames
		bchg	#0,obFrame(a0)				; change frame

	.display:
		move.w	(v_limitbtm).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0					; has object fallen off	the level?
		blo.w	DeleteObject				; if yes, branch
		bra.w	DisplayAndCollision			; Clownacy DisplaySprite Fix
; ===========================================================================