; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber enemy	(GHZ, MZ, SYZ)
; ---------------------------------------------------------------------------
; OST Constants
obBuzz_WaitTime:		equ objoff_30		; 1 byte  | time delay for each action
obBuzz_Mode:			equ objoff_31		; 1 byte  | current action - 0 = flying; 1 = recently fired; 2 = near Sonic
; ---------------------------------------------------------------------------

BuzzBomber:
		_move.l	#Buzz_Move,obAddr(a0)
		move.l	#Map_Buzz,obMap(a0)
		move.w	#make_art_tile(ArtTile_Buzz_Bomber,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_24x12),obColType(a0)
		move.b	#$18,obDispWid(a0)
; ---------------------------------------------------------------------------

Buzz_Move:
		subq.b	#1,obBuzz_WaitTime(a0)	; subtract 1 from time delay
		bpl.w	.animate				; if time remains, branch
		btst	#1,obBuzz_Mode(a0)		; is Buzz Bomber near Sonic?
		bne.s	.fire					; if yes, branch

		obj_addr	#Buzz_ChkDist

		move.b	#127,obBuzz_WaitTime(a0) ; set time delay to just over 2 seconds
		move.w	#$400,obVelX(a0) 		; move Buzz Bomber to the right
		move.b	#1,obAnim(a0)			; use "flying" animation
		btst	#staFlipX,obStatus(a0)	; is Buzz Bomber facing	left?
		bne.s	.animate				; if not, branch
		neg.w	obVelX(a0)				; move Buzz Bomber to the left
		lea		Ani_Buzz(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

	.fire:
		bsr.w	FindFreeObj
		bne.s	.animate
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
		move.b	#14,obMissile_WaitTime(a1)
		move.w	a0,obMissile_Parent(a1)
		move.b	#1,obBuzz_Mode(a0)		; set to "already fired" to prevent refiring
		move.b	#59,obBuzz_WaitTime(a0)
		move.b	#2,obAnim(a0)			; use "firing" animation

	.animate:
		lea		Ani_Buzz(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

Buzz_ChkDist:
		subq.b	#1,obBuzz_WaitTime(a0)	; subtract 1 from time delay
		bmi.s	.chgdirection
		bsr.w	SpeedToPos_XOnly
		tst.b	obBuzz_Mode(a0)
		bne.s	.animate
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bpl.s	.isleft
		neg.w	d0

	.isleft:
		cmpi.w	#96,d0					; is Buzz Bomber within	96 ($60) pixels of Sonic?
		bhs.s	.animate				; if not, branch
		tst.b	obRender(a0)			; is Buzz Bomber visible on-screen?
		bpl.s	.animate				; if not, branch
		move.b	#2,obBuzz_Mode(a0)		; set Buzz Bomber to "near Sonic"
		move.b	#29,obBuzz_WaitTime(a0)	; set time delay to half a second
		bra.s	.stop
; ===========================================================================

	.chgdirection:
		clr.b	obBuzz_Mode(a0)			; set Buzz Bomber to "normal"
		bchg	#staFlipX,obStatus(a0)	; change direction
		move.b	#59,obBuzz_WaitTime(a0)

	.stop:
		obj_addr	#Buzz_Move
		clr.w	obVelX(a0)				; stop Buzz Bomber moving
		clr.b	obAnim(a0)				; use "hovering" animation

	.animate:
		lea		Ani_Buzz(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 22 (sub) - missile that Buzz Bomber throws
; ---------------------------------------------------------------------------
; OST Constants
obMissile_WaitTime:		equ objoff_30		; 1 byte  | time delay
obMissile_Parent:		equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

Missile:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Msl_Index(pc,d0.w),d0
		jmp		Msl_Index(pc,d0.w)
; ===========================================================================
Msl_Index:	offsetTable
		offsetTableEntry.w Msl_Main
		offsetTableEntry.w Msl_Animate
		offsetTableEntry.w Msl_FromBuzz
		offsetTableEntry.w Msl_Delete
		offsetTableEntry.w Msl_FromNewt
; ===========================================================================

Msl_Main:	; Routine 0
		subq.b	#1,obMissile_WaitTime(a0)		; decrement timer
		bpl.s	Msl_ChkCancel					; branch if time remains
		addq.b	#2,obRoutine(a0)				; -> Msl_Animate
		move.l	#Map_Missile,obMap(a0)
		move.w	#make_art_tile(ArtTile_Buzz_Bomber,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		andi.b	#(maskFlipX+maskFlipY),obStatus(a0)
		bset	#shPropReflect,obShieldProp(a0)	; Reflected by Elemental Shields
		tst.b	obSubtype(a0)					; was object created by	a Newtron?
		beq.s	Msl_Animate						; if not, branch

		move.b	#8,obRoutine(a0)				; -> "Msl_FromNewt"
		move.b	#(colHarmful|colSz_6x6),obColType(a0)
		move.b	#1,obAnim(a0)
		bra.s	Msl_Animate2
; ===========================================================================

Msl_Animate:	; Routine 2
		bsr.s	Msl_ChkCancel
		; Clownacy DisplaySprite Fix
		; Msl_ChkCancel can call DeleteObject, so we shouldn't queue
		; this object for display or update the animation state.
		; Failing to account for this results in a null pointer
		; dereference, which is harmless in Sonic 1 but will crash
		; Sonic 2. Fun fact: Sonic 2 REV00 has some leftover debug
		; code in its BuildSprites function for detecting this type
		; of bug.
		beq.s	Msl_ChkCancel.return
		lea		Ani_Missile(pc),a1
		bsr.w	AnimateSprite
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	check if the Buzz Bomber which fired the missile has been
; destroyed, and if it has, then cancel	the missile
; ---------------------------------------------------------------------------

Msl_ChkCancel:
		movea.w	obMissile_Parent(a0),a1

		; has Buzz Bomber been destroyed? (d0 = buzz bomber obAddr)
		cmp_addr	#ExplosionItem,obAddr(a1),d0

		; This adds a return value so that we know if the object has
		; been freed. -- Clownacy DisplaySprite Fix
		bne.s	.return					; if not, branch
		bsr.w	DeleteObject
		moveq	#0,d0

.return:
		rts	
; End of function Msl_ChkCancel
; ===========================================================================

Msl_FromBuzz:	; Routine 4
		btst	#7,obStatus(a0)		; is high bit of status set? (it never is)
		bne.s	.explode			; if yes, branch
		move.b	#(colHarmful|colSz_6x6),obColType(a0)
		move.b	#1,obAnim(a0)
		bsr.w	SpeedToPos
		move.w	(v_limitbtm).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0			; has object moved below the level boundary?
		blo.w	DeleteObject		; if yes, branch
		lea		Ani_Missile(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplayAndCollision	; S3K TouchResponse; Clownacy DisplaySprite Fix
; ===========================================================================

.explode:
		_move.l	#MissileDissolve,obAddr(a0) ; change object to an explosion (Obj24)
		clr.b	obRoutine(a0)
		bra.w	MissileDissolve
; ===========================================================================

Msl_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================

Msl_FromNewt:	; Routine 8
		tst.b	obRender(a0)
		bpl.w	DeleteObject
		bsr.w	SpeedToPos

Msl_Animate2:
		lea		Ani_Missile(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplayAndCollision	; S3K TouchResponse
; ===========================================================================