; ---------------------------------------------------------------------------
; Object 28 - animals
; ---------------------------------------------------------------------------
; OST Constants
obAnimal_Direction:		equ objoff_29		; 1 byte  | animal goes left/right
obAnimal_Type:			equ objoff_30		; 1 byte  | type of animal (0-$B)
obAnimal_VelX:			equ objoff_32		; 2 bytes | horizontal speed
obAnimal_VelY:			equ objoff_34		; 2 bytes | vertical speed
obAnimal_PrisonNum:		equ objoff_36		; 2 bytes | id num for animals in prison capsule, lets them jump out 1 at a time
obAnimal_CapsuleAddr:	equ objoff_3C		; 2 bytes | address of prison capsule that spawned this animal (if applicable)
;obEnemy_Combo:			equ objoff_3E		; 2 bytes | number of enemies broken in a row (0-$A) (Shared with the ExplosionItem object)
; ---------------------------------------------------------------------------

Animals:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Anml_Index(pc,d0.w),d1
		jmp		Anml_Index(pc,d1.w)
; ===========================================================================
Anml_Index:		offsetTable
		offsetTableEntry.w Anml_Main
		offsetTableEntry.w Anml_ChkFloor
		offsetTableEntry.w Anml_Type0
		offsetTableEntry.w Anml_Type1
		offsetTableEntry.w Anml_Type0		; $08
		offsetTableEntry.w Anml_Type0
		offsetTableEntry.w Anml_Type0
		offsetTableEntry.w Anml_Type5
		offsetTableEntry.w Anml_Type0		; $10
		offsetTableEntry.w Anml_FromPrison
	; Ending Animals
		offsetTableEntry.w Ending_Flicky	; $14
		offsetTableEntry.w Ending_Flicky	; $16 - Unused
		offsetTableEntry.w Ending_Flicky3	; $18
		offsetTableEntry.w Ending_Rabbit1	; $1A
		offsetTableEntry.w Ending_Rabbit2	; $1C
		offsetTableEntry.w Ending_Penguin1	; $1E
		offsetTableEntry.w Ending_Penguin2	; $20
		offsetTableEntry.w Ending_Seal		; $22
		offsetTableEntry.w Ending_Pig		; $24
		offsetTableEntry.w Ending_Chicken	; $26
		offsetTableEntry.w Ending_Squirrel	; $28

Anml_VarIndex:
		dc.b 0,	5		; Green Hill Zone
		dc.b 2, 3		; Labyrinth Zone
		dc.b 6, 3		; Marble Zone
		dc.b 4, 5		; Star Light Zone
		dc.b 4, 1		; Spring Yard Zone
		dc.b 0, 1		; Scrap Brain Zone

Anml_Variables:
	; horizontal speed, vertical speed
	; mappings address
		dc.w -$200, -$400		; type 0 - GHZ/SBZ
		dc.l Map_Animal1
		dc.w -$200, -$300		; type 1 - SYZ/SBZ
		dc.l Map_Animal2
		dc.w -$180, -$300		; type 2 - LZ
		dc.l Map_Animal1
		dc.w -$140, -$180		; type 3 - MZ/LZ
		dc.l Map_Animal2
		dc.w -$1C0, -$300		; type 4 - SYZ/SLZ
		dc.l Map_Animal3
		dc.w -$300, -$400		; type 5 - GHZ/SLZ
		dc.l Map_Animal2
		dc.w -$280, -$380		; type 6 - MZ
		dc.l Map_Animal3

Anml_EndSpeed:
		dc.w -$440, -$400		; $A
		dc.w -$440, -$400		; $B
		dc.w -$440, -$400		; $C
		dc.w -$300, -$400		; $D
		dc.w -$300, -$400		; $E
		dc.w -$180, -$300		; $F
		dc.w -$180, -$300		; $10
		dc.w -$140, -$180		; $11
		dc.w -$1C0, -$300		; $12
		dc.w -$200, -$300		; $13
		dc.w -$280, -$380		; $14

Anml_EndMap:
		dc.l Map_Animal2		; $A
		dc.l Map_Animal2		; $B - unused
		dc.l Map_Animal2		; $C
		dc.l Map_Animal1		; $D
		dc.l Map_Animal1		; $E
		dc.l Map_Animal1		; $F
		dc.l Map_Animal1		; $10
		dc.l Map_Animal2		; $11
		dc.l Map_Animal3		; $12
		dc.l Map_Animal2		; $13
		dc.l Map_Animal3		; $14

Anml_EndVram:
		dc.w make_art_tile(ArtTile_Ending_Flicky,0,0)		; $A
		dc.w make_art_tile(ArtTile_Ending_Flicky,0,0)		; $B - unused
		dc.w make_art_tile(ArtTile_Ending_Flicky,0,0)		; $C
		dc.w make_art_tile(ArtTile_Ending_Rabbit,0,0)		; $D
		dc.w make_art_tile(ArtTile_Ending_Rabbit,0,0)		; $E
		dc.w make_art_tile(ArtTile_Ending_Penguin,0,0)		; $F
		dc.w make_art_tile(ArtTile_Ending_Penguin,0,0)		; $10
		dc.w make_art_tile(ArtTile_Ending_Seal,0,0)			; $11
		dc.w make_art_tile(ArtTile_Ending_Pig,0,0)			; $12
		dc.w make_art_tile(ArtTile_Ending_Chicken,0,0)		; $13
		dc.w make_art_tile(ArtTile_Ending_Squirrel,0,0)		; $14
; ===========================================================================

Anml_Main:	; Routine 0
		tst.b	obSubtype(a0)				; did animal come from an enemy or prison capsule?
		beq.w	Anml_FromEnemy				; if yes (subtype 00), branch
; ---------------------------------------------------------------------------

	; non-zero subtype indicates an Ending Sequence Enemy
;Anml_Ending:
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; move object type to d0
		add.w	d0,d0						; multiply d0 by 2
		move.b	d0,obRoutine(a0)			; move d0 to routine counter
		subi.w	#$14,d0
		move.w	Anml_EndVram(pc,d0.w),obGfx(a0)
		add.w	d0,d0
		move.l	Anml_EndMap(pc,d0.w),obMap(a0)
		lea		Anml_EndSpeed(pc),a1
		move.l	(a1,d0.w),d1
		move.l	d1,obAnimal_VelX(a0)		; load horizontal speed (obAnimal_VelX and obAnimal_VelY)
		move.l	d1,obVelX(a0) 				; (obVelX and obVelY)
		move.b	#$C,obHeight(a0)
		move.b	#4,obRender(a0)
		bset	#renXFlip,obRender(a0)
		move.w	#priority6,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		move.b	#7,obTimeFrame(a0)
		bra.w	DisplaySprite
; ===========================================================================

Anml_FromEnemy:
		addq.b	#2,obRoutine(a0)			; -> Anml_ChkFloor
		bsr.w	RandomNumber
		andi.w	#1,d0						; d0 = random 0 or 1 (determines which one of 2 possible animals)
		moveq	#0,d1
		move.b	(v_zone).w,d1				; get zone number
		add.w	d1,d1
		add.w	d0,d1						; d1 = (v_zone*2) + random 0 or 1
		lea		Anml_VarIndex(pc),a1
		move.b	(a1,d1.w),d0				; get type from index based on zone + random 0 or 1
		move.l	d0,d2						; copy animal type
		move.b	d2,obAnimal_Type(a0)
		lsl.w	#3,d0						; multiply by 8
		lea		Anml_Variables(pc),a1
		adda.w	d0,a1						; jump to actual variables
		move.l	(a1)+,obAnimal_VelX(a0)		; load horizontal and vertical speeds (obAnimal_VelX and obAnimal_VelY)
		move.l	(a1)+,obMap(a0)							; load mappings
		move.w	#make_art_tile(ArtTile_Animal_1,0,0),d1	; VRAM setting for 1st animal
		btst	#0,d2									; is 1st animal	used? (Using the copy value is faster)
		beq.s	.type_0									; if yes, branch
		move.w	#make_art_tile(ArtTile_Animal_2,0,0),d1	; VRAM setting for 2nd animal

	.type_0:
		move.w	d1,obGfx(a0)
		move.b	#$C,obHeight(a0)
		move.b	#5,obRender(a0)				; set to 4 + x-flip render flag.
		move.w	#priority6,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a0)
		move.b	#7,obTimeFrame(a0)
		move.b	#2,obFrame(a0)				; use "dropping" frame
		move.w	#-$400,obVelY(a0)
		tst.b	(v_bossstatus).w			; has boss been beaten?
		bne.s	.after_boss					; if yes, branch
		bsr.w	FindFreeObj
		bne.w	DisplaySprite
		_move.l	#Points,obAddr(a1)		; load points object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obEnemy_Combo(a0),d0
		lsr.w	#1,d0
		move.b	d0,obFrame(a1)
		bra.w	DisplaySprite
; ===========================================================================

	.after_boss:
		move.b	#$12,obRoutine(a0)			; -> Anml_FromPrison
		clr.w	obVelX(a0)
		bra.w	DisplaySprite
; ===========================================================================

; Animals freed from Badnik enemies and Animal Prisons.
Anml_ChkFloor:		; Routine 2
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	AnimalDelete				; if not, branch
		bsr.w	ObjectFall_YOnly
		tst.w	obVelY(a0)					; is object currently moving upwards?
		bmi.w	DisplaySprite				; if yes, branch

		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.w	DisplaySprite				; if not, branch

		add.w	d1,obY(a0)					; align to floor
		move.l	obAnimal_VelX(a0),obVelX(a0)	; reset speeds (VelX and VelY)
		move.b	#1,obFrame(a0)				; use flap_2 frame
		move.b	obAnimal_Type(a0),d0		; get type
		add.b	d0,d0
		addq.b	#4,d0						; d0 = (type*2) + 4
		move.b	d0,obRoutine(a0)			; goto relevant routine next
		tst.b	(v_bossstatus).w			; has boss been beaten?
		beq.w	DisplaySprite				; if not, branch
		btst	#4,(v_vbla_byte).w			; check bit that changes every 16 frames
		beq.w	DisplaySprite				; branch if 0
		neg.w	obVelX(a0)					; reverse direction
		bchg	#renXFlip,obRender(a0)		; x-flip bit change
		bra.w	DisplaySprite
; ===========================================================================

Anml_Type0:	; Routine 04, 08, 0A, 0C, $10
		bsr.w	ObjectFall
		bsr.w	Anml_End_Update

		tst.b	obSubtype(a0)				; is this an animal from the ending?
		bne.w	Anml_End_ChkDel				; if yes, branch
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	AnimalDelete				; if not, branch
		bra.w	DisplaySprite
; ===========================================================================

Anml_Type1:	; Routine 06, 0E
Anml_Type5
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)				; make object fall downwards
		tst.w	obVelY(a0)					; is object currently moving upwards?
		bmi.s	.animate					; if yes, branch

		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.s	.animate					; if not, branch
		add.w	d1,obY(a0)					; align to floor
		move.w	obAnimal_VelY(a0),obVelY(a0)	; reset y speed
		tst.b	obSubtype(a0)				; is this an animal from the ending?
		beq.s	.animate					; if not, branch

		cmpi.b	#$A,obSubtype(a0)
		beq.s	.animate
		neg.w	obVelX(a0)
		bchg	#renXFlip,obRender(a0)		; x-flip bit change

	.animate:
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bpl.s	.chkdel						; branch if time remains
		move.b	#1,obTimeFrame(a0)			; set timer to 1 frame
		addq.b	#1,obFrame(a0)				; change frame
		andi.b	#1,obFrame(a0)				; limit to 2 frames

	.chkdel:
		tst.b	obSubtype(a0)				; is this an animal from the ending?
		bne.s	Anml_End_ChkDel				; if yes, branch
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	AnimalDelete				; if not, branch
		bra.w	DisplaySprite
; ===========================================================================
; New deletion routine made to optimize the End-of-Level waiting procedure (RetroKoH)

AnimalDelete:
		tst.w	obAnimal_CapsuleAddr(a0)	; did this spawn from a capsule?
		beq.w	DeleteObject				; if not, simply despawn
		movea.w	obAnimal_CapsuleAddr(a0),a2	; a2=capsule
		subq.b	#1,obPrison_AnimalCount(a2)	; decrement capsule's animal count
		bra.w	DeleteObject				; despawn
; ===========================================================================

Anml_End_ChkDel:
		move.w	obX(a0),d0					; d0 = distance between Sonic & object (+ve if Sonic is to the left)
		sub.w	(v_player+obX).w,d0
		bcs.w	DisplaySprite				; branch if Sonic is to the right
		subi.w	#384,d0
		bpl.w	DisplaySprite				; branch if Sonic is > 384px to the left
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	AnimalDelete				; if not, branch
		bra.w	DisplaySprite
; ===========================================================================

Anml_FromPrison:	; Routine $12
		tst.b	obRender(a0)				; is object on-screen?
		bpl.w	AnimalDelete				; if not, branch
		subq.w	#1,obAnimal_PrisonNum(a0)	; decrement prison queue ticket
		bne.w	DisplaySprite				; branch if not 0
		move.b	#2,obRoutine(a0)			; -> Anml_ChkFloor
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		bra.w	DisplaySprite
; ===========================================================================

Ending_Flicky:	; Routine $14 (used), $16 (unused)
		bsr.w	Anml_End_ChkDist
		bcc.w	Anml_End_ChkDel					; branch if Sonic is to the left, or > 184px right
		move.l	obAnimal_VelX(a0),obVelX(a0)	; reset speeds (VelX and VelY)
		move.b	#$E,obRoutine(a0)				; -> Anml_Type1
		bra.w	Anml_Type1						; TO-DO: Should this be Anml_End_ChkDel (Double check s1disasm and other bases)?
; ===========================================================================

Ending_Flicky3:	; Routine $18
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		clr.w	obVelX(a0)
		clr.w	obAnimal_VelX(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
		bsr.w	Anml_End_Update
		bsr.w	Anml_End_ChkDirection
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bpl.w	Anml_End_ChkDel				; branch if time remains
		move.b	#1,obTimeFrame(a0)			; set timer to 1 frame
		addq.b	#1,obFrame(a0)				; change frame
		andi.b	#1,obFrame(a0)				; limit to 2 frames
		bra.w	Anml_End_ChkDel
; ===========================================================================

Ending_Rabbit1:	; Routine $1A
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel					; branch if Sonic is > 184px to the right
		move.l	obAnimal_VelX(a0),obVelX(a0)	; reset speeds (VelX and VelY)
		move.b	#4,obRoutine(a0)				; -> Anml_Type0
		bra.w	Anml_Type0
; ===========================================================================

Ending_Squirrel:	; Routine $28
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)				; flap_2 frame
		tst.w	obVelY(a0)					; is object currently moving upwards?
		bmi.w	Anml_End_ChkDel				; if yes, branch
		clr.b	obFrame(a0)					; flap_1 frame
		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.w	Anml_End_ChkDel				; if not, branch
		not.b	obAnimal_Direction(a0)		; change direction flag
		bne.s	.no_flip					; branch if 1
		neg.w	obVelX(a0)					; reverse direction
		bchg	#renXFlip,obRender(a0)		; x-flip bit change

	.no_flip:
		add.w	d1,obY(a0)					; align to floor
		move.w	obAnimal_VelY(a0),obVelY(a0)	; reset y speed
		bra.w	Anml_End_ChkDel
; ===========================================================================

Ending_Rabbit2:		; Routine $1C
Ending_Penguin2:	; Routine $20
Ending_Pig:			; Routine $24
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		clr.w	obVelX(a0)
		clr.w	obAnimal_VelX(a0)
		bsr.w	ObjectFall
		bsr.w	Anml_End_Update
		bsr.w	Anml_End_ChkDirection
		bra.w	Anml_End_ChkDel
; ===========================================================================

Ending_Penguin1:	; Routine $1E
Ending_Seal:		; Routine $22
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		bsr.w	ObjectFall
		move.b	#1,obFrame(a0)				; flap_2 frame
		tst.w	obVelY(a0)					; is object currently moving upwards?
		bmi.w	Anml_End_ChkDel				; if yes, branch
		clr.b	obFrame(a0)					; flap_1 frame
		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.w	Anml_End_ChkDel				; if not, branch
		neg.w	obVelX(a0)					; reverse direction
		bchg	#renXFlip,obRender(a0)		; x-flip bit change
		add.w	d1,obY(a0)					; align to floor
		move.w	obAnimal_VelY(a0),obVelY(a0)	; reset y speed
		bra.w	Anml_End_ChkDel
; ===========================================================================

Ending_Chicken:	; Routine $26
		bsr.w	Anml_End_ChkDist
		bpl.w	Anml_End_ChkDel				; branch if Sonic is > 184px to the right
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)				; fall
		tst.w	obVelY(a0)					; is object currently moving upwards?
		bmi.s	.chk_anim					; if yes, branch
		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.s	.chk_anim					; if not, branch
		not.b	obAnimal_Direction(a0)		; change direction flag
		bne.s	.no_flip					; branch if 1
		neg.w	obVelX(a0)					; reverse direction
		bchg	#renXFlip,obRender(a0)		; x-flip bit change

	.no_flip:
		add.w	d1,obY(a0)					; align to floor
		move.w	obAnimal_VelY(a0),obVelY(a0)	; reset y speed

	.chk_anim:
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bpl.w	Anml_End_ChkDel				; branch if time remains
		move.b	#1,obTimeFrame(a0)			; set timer to 1 frame
		addq.b	#1,obFrame(a0)				; change frame
		andi.b	#1,obFrame(a0)				; limit to 2 frames
		bra.w	Anml_End_ChkDel
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to animate and bounce on floor
; ---------------------------------------------------------------------------

Anml_End_Update:
		move.b	#1,obFrame(a0)				; flap_2 frame
		tst.w	obVelY(a0)					; is object currently moving upwards?
		bmi.s	.exit						; if yes, branch

		clr.b	obFrame(a0)					; flap_1 frame
		jsr		(ObjFloorDist).l
		tst.w	d1							; has object hit the floor?
		bpl.s	.exit						; if not, branch
		add.w	d1,obY(a0)					; align to floor
		move.w	obAnimal_VelY(a0),obVelY(a0)	; reset y speed

	.exit:
		rts
; End of function Anml_End_Update
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to set/clear xflip bit if Sonic is to the left/right respectively
; ---------------------------------------------------------------------------

Anml_End_ChkDirection:
		bset	#renXFlip,obRender(a0)		; set x-flip bit
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0			; d0 = distance between Sonic & object (-ve if Sonic is to the right)
		bcc.s	.exit						; branch if Sonic is to the left
		bclr	#renXFlip,obRender(a0)		; clear x-flip bit

.exit:
		rts
; End of function Anml_End_ChkDirection
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check if Sonic is more than 184px to the right
;
; output:
;	d0 = positive if true; negative if false
; ---------------------------------------------------------------------------

Anml_End_ChkDist:
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0					; d0 = distance between Sonic & object (-ve if Sonic is to the left)
		subi.w	#184,d0						; d0 is -ve if Sonic is left, or < 184px right
		rts
; End of function Anml_End_ChkDist
; ===========================================================================