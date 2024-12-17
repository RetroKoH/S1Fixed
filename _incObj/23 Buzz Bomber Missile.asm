; ---------------------------------------------------------------------------
; Object 23 - missile that Buzz	Bomber throws
; ---------------------------------------------------------------------------

Missile:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Msl_Index(pc,d0.w),d1
		jmp		Msl_Index(pc,d1.w)
; ===========================================================================
Msl_Index:	offsetTable
		offsetTableEntry.w Msl_Main
		offsetTableEntry.w Msl_Animate
		offsetTableEntry.w Msl_FromBuzz
		offsetTableEntry.w Msl_Delete
		offsetTableEntry.w Msl_FromNewt

msl_parent = objoff_3C
; ===========================================================================

Msl_Main:	; Routine 0
		subq.w	#1,objoff_32(a0)
		bpl.s	Msl_ChkCancel
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Missile,obMap(a0)
		move.w	#make_art_tile(ArtTile_Buzz_Bomber,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a0)
		andi.b	#(maskFlipX+maskFlipY),obStatus(a0)
		bset	#shPropReflect,obShieldProp(a0)	; Reflected by Elemental Shields
		tst.b	obSubtype(a0)					; was object created by	a Newtron?
		beq.s	Msl_Animate						; if not, branch

		move.b	#8,obRoutine(a0)				; run "Msl_FromNewt" routine
		move.b	#(colHarmful|$7),obColType(a0)
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

; ---------------------------------------------------------------------------
; Subroutine to	check if the Buzz Bomber which fired the missile has been
; destroyed, and if it has, then cancel	the missile
; ---------------------------------------------------------------------------
; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Msl_ChkCancel:
		movea.l	msl_parent(a0),a1
		_cmpi.b	#id_ExplosionItem,obID(a1) ; has Buzz Bomber been destroyed?
		; This adds a return value so that we know if the object has
		; been freed. -- Clownacy DisplaySprite Fix
		bne.s	.return
		bsr.w	DeleteObject
		moveq	#0,d0

.return:
		rts	
; End of function Msl_ChkCancel

; ===========================================================================

Msl_FromBuzz:	; Routine 4
		btst	#7,obStatus(a0)
		bne.s	.explode
		move.b	#(colHarmful|$7),obColType(a0)
		move.b	#1,obAnim(a0)
		bsr.w	SpeedToPos
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0			; has object moved below the level boundary?
		blo.w	DeleteObject		; if yes, branch
		lea		Ani_Missile(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplayAndCollision	; S3K TouchResponse; Clownacy DisplaySprite Fix
; ===========================================================================

.explode:
		_move.b	#id_MissileDissolve,obID(a0) ; change object to an explosion (Obj24)
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
