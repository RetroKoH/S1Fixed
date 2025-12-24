; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber enemy	(GHZ, MZ, SYZ)
; ---------------------------------------------------------------------------

BuzzBomber:
	; RetroKoH/LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		subq.b	#2,d0
		beq.s	Buzz_Action
		bpl.w	DeleteObject
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Buzz_Main:		; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Buzz_Action
		move.l	#Map_Buzz,obMap(a0)
		move.w	#make_art_tile(ArtTile_Buzz_Bomber,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_24x12),obColType(a0)
		move.b	#$18,obDispWid(a0)
; ---------------------------------------------------------------------------

Buzz_Action:	; Routine 2
	; LavaGaming Object Routine Optimization		
		tst.b	ob2ndRout(a0)
		bne.w	Buzz_ChkDist
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Buzz_Move:		; Secondary Routine 0
		subq.w	#1,obBuzz_WaitTime(a0)	; subtract 1 from time delay
		bpl.w	Buzz_Animate			; if time remains, branch
		btst	#1,obBuzz_Mode(a0)		; is Buzz Bomber near Sonic?
		bne.s	.fire					; if yes, branch
		addq.b	#2,ob2ndRout(a0)
		move.w	#127,obBuzz_WaitTime(a0) ; set time delay to just over 2 seconds
		move.w	#$400,obVelX(a0) 		; move Buzz Bomber to the right
		move.b	#1,obAnim(a0)			; use "flying" animation
		btst	#staFlipX,obStatus(a0)	; is Buzz Bomber facing	left?
		bne.w	Buzz_Animate			; if not, branch
		neg.w	obVelX(a0)				; move Buzz Bomber to the left
		bra.w	Buzz_Animate
; ===========================================================================

	.fire:
		bsr.w	FindFreeObj
		bne.w	Buzz_Animate
		_move.l	#Missile,obAddr(a1)		; load missile object

		move.l	#$02000200,obVelX(a1)	; move missile downwards (obVelX), to the right (obVelY)

		moveq	#28,d0
		add.w	obY(a0),d0
		move.w	d0,obY(a1)				; set missile Ypos to buzzbomber Ypos + 28

		moveq	#20,d0					; Clownacy positioning fix
		btst	#staFlipX,obStatus(a0)	; is Buzz Bomber facing	left?
		bne.s	.noflip2				; if not, branch
		neg.w	d0
		neg.w	obVelX(a1)				; move missile to the left

	.noflip2:
		add.w	obX(a0),d0
		move.w	d0,obX(a1)				; set missile Xpos to buzzbomber Xpos +/- 20

		move.b	obStatus(a0),obStatus(a1)
		move.w	#14,obBuzz_WaitTime(a1)
		move.w	a0,obMissile_Parent(a1)
		move.b	#1,obBuzz_Mode(a0)		; set to "already fired" to prevent refiring
		move.w	#59,obBuzz_WaitTime(a0)
		move.b	#2,obAnim(a0)			; use "firing" animation
		bra.w	Buzz_Animate
; ===========================================================================

Buzz_ChkDist:	; Secondary Routine 2
		subq.w	#1,obBuzz_WaitTime(a0)	; subtract 1 from time delay
		bmi.s	.chgdirection
		bsr.w	SpeedToPos_XOnly
		tst.b	obBuzz_Mode(a0)
		bne.s	Buzz_Animate
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	.isleft
		neg.w	d0

	.isleft:
		cmpi.w	#96,d0					; is Buzz Bomber within	96 ($60) pixels of Sonic?
		bhs.s	Buzz_Animate			; if not, branch
		tst.b	obRender(a0)			; is Buzz Bomber visible on-screen?
		bpl.s	Buzz_Animate			; if not, branch
		move.b	#2,obBuzz_Mode(a0)		; set Buzz Bomber to "near Sonic"
		move.w	#29,obBuzz_WaitTime(a0)	; set time delay to half a second
		bra.s	.stop
; ===========================================================================

	.chgdirection:
		clr.b	obBuzz_Mode(a0)			; set Buzz Bomber to "normal"
		bchg	#staFlipX,obStatus(a0)	; change direction
		move.w	#59,obBuzz_WaitTime(a0)

	.stop:
		subq.b	#2,ob2ndRout(a0)		; -> Buzz_Move
		clr.w	obVelX(a0)				; stop Buzz Bomber moving
		clr.b	obAnim(a0)				; use "hovering" animation

Buzz_Animate:
		lea		Ani_Buzz(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================