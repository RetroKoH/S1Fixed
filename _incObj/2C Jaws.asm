; ---------------------------------------------------------------------------
; Object 2C - Jaws enemy (LZ)
; ---------------------------------------------------------------------------

Jaws:
		obj_addr	#Jaws_Move
		move.l	#Map_Jaws,obMap(a0)
		move.w	#make_art_tile(ArtTile_Jaws,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#(colEnemy|colSz_16x12),obColType(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; load object subtype number
		lsl.w	#6,d0						; multiply d0 by 64
		subq.w	#1,d0
		move.w	d0,obJaws_TurnTime(a0)		; set turn delay time
		move.w	d0,obJaws_TimeDelay(a0)

	if JawsBubbleGenerate
		move.w	#$50,obJaws_BubbleTime(a0)	; init bubble timer
	endif

		move.w	#-$40,obVelX(a0)			; move Jaws to the left
		btst	#staFlipX,obStatus(a0)		; is Jaws facing left?
		beq.s	Jaws_Move					; if yes, branch
		neg.w	obVelX(a0)					; move Jaws to the right
; ---------------------------------------------------------------------------

Jaws_Move:
	if JawsBubbleGenerate
		subq.w	#1,obJaws_BubbleTime(a0)
		bne.s	.nobubble					; branch, if timer isn't done counting down
		bsr.s	Jaws_MakeBubble

	.nobubble:
	endif
		subq.w	#1,obJaws_TurnTime(a0)		; subtract 1 from turn delay time
		bpl.s	.dontturn					; if time remains, branch
		move.w	obJaws_TimeDelay(a0),obJaws_TurnTime(a0)	; reset turn delay time
		neg.w	obVelX(a0)					; change speed direction
		bchg	#staFlipX,obStatus(a0)		; change Jaws facing direction
		clr.w	obAniFrame(a0)				; reset animation and frame duration

	.dontturn:
	if JawsBehaviorMod
		tst.w	(v_debuguse).w				; is debug mode	on?
		bne.s	.animate					; if yes, branch

		bsr.s	Jaws_ChkAttack				; check whether or not it should attack

	.animate:
	endif
		lea		Ani_Jaws(pc),a1
		bsr.w	AnimateSprite
		bsr.w	SpeedToPos_XOnly
		bra.w	RememberState
; ===========================================================================

	if JawsBubbleGenerate
; ---------------------------------------------------------------------------
; Subroutine to make the Jaws badnik generate small bubbles from its back
; ---------------------------------------------------------------------------

Jaws_MakeBubble:
		move.w	#$50,obJaws_BubbleTime(a0)	; reset bubble timer

		bsr.w	FindFreeObj
		bne.w	.no_bubble					; branch if free object slot not found

		_move.l	#Bubble,obAddr(a1)			; load bubble object
		move.b	#0,obSubtype(a1)
		move.w	obX(a0),obX(a1)				; align objects horizontally
		moveq	#$12,d0						; load x-offset
		btst	#staFlipX,obRender(a0)		; is object facing left?
		beq.s	.no_flip					; if not, branch
		neg.w	d0							; else mirror offset

	.no_flip:
		add.w	d0,obX(a1)					; add horizontal offset
		move.w	obY(a0),obY(a1)				; align objects vertically

	.no_bubble:
		rts
; ===========================================================================
	endif

	if JawsBehaviorMod
; ---------------------------------------------------------------------------
; Subroutine to check Sonic's distance from the Jaws badnik
; ---------------------------------------------------------------------------

Jaws_ChkAttack:
		move.w	#160,d2						; horizontal distance to compare
		move.w	#$200,d1					; horizontal speed for Jaws to swim

		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0					; d0 = distance between Sonic and Jaws
		bcc.s	.right						; if Sonic is right of Jaws, branch

;	.left:
		neg.w	d0							; if Sonic is to the left, get absolute value of distance
		neg.w	d1							; negate horizontal speed
		btst	#staFlipX,obStatus(a0)		; is Jaws facing left?
		bne.s	.dont_chase					; if not, don't chase Sonic
		cmp.w	d2,d0
		bcc.s	.dont_chase					; if distance is greater than d2, don't chase Sonic.
		bra.s	.chk_y

	.right:
		btst	#staFlipX,obStatus(a0)		; is Jaws facing right?
		beq.s	.dont_chase					; if not, don't chase Sonic
		cmp.w	d2,d0
		bcc.s	.dont_chase					; if distance is greater than d2, don't chase Sonic.
		bra.s	.chk_y

	.dont_chase:
		rts
; ===========================================================================

	.chk_y:
	; TO-DO: THIS part may be bugged at the end of LZ3
		moveq	#32,d2						; vertical distance to compare
		move.w	#$80,d3						; vertical speed for Jaws to swim
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0					; d0 = distance between Sonic and Jaws
		bcc.s	.below						; if Sonic is below Jaws, branch

;	.above:
		neg.w	d0							; if Sonic is above, get absolute value of distance
		neg.w	d3							; negate vertical speed

	.below:
		cmp.w	d2,d0
		bcs.s	.chase						; if distance is greater than d2, don't chase Sonic.
		rts
; ===========================================================================

	.chase:
		obj_addr	#Jaws_Chase
		move.w	d1,obVelX(a0)				; make Jaws dash horizontally
		move.w	d3,obVelY(a0)				; make Jaws dash vertically
		rts
; ===========================================================================

Jaws_Chase:
	if JawsBubbleGenerate
		subq.w	#1,obJaws_BubbleTime(a0)
		bne.s	.nobubble					; branch, if timer isn't done counting down
		bsr.w	Jaws_MakeBubble

	.nobubble:
	endif
		lea		Ani_Jaws(pc),a1
		bsr.w	AnimateSprite
		bsr.w	SpeedToPos
		bra.w	RememberState
	endif
; ===========================================================================