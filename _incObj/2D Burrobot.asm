; ---------------------------------------------------------------------------
; Object 2D - Burrobot enemy (LZ)
; ---------------------------------------------------------------------------
; OST Constants
obBurro_TurnTime:		equ objoff_30		; 2 bytes | time between direction changes
obBurro_FloorDetect:	equ objoff_32		; 1 byte  | flag set every other frame to detect edge of floor
; ---------------------------------------------------------------------------

Burrobot:
		_move.l	#Burro_Action,obAddr(a0)
		move.w	#$1308,obHeight(a0)			; Height and Width
		move.l	#Map_Burro,obMap(a0)
		move.w	#make_art_tile(ArtTile_Burrobot,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_12x18),obColType(a0)
		move.b	#$C,obDispWid(a0)
		addq.b	#6,obRoutine(a0)			; run "Burro_ChkSonic" routine
		move.b	#2,obAnim(a0)

Burro_Action:	; Routine 2
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BurroAct_Index(pc,d0.w),d1
		jmp		BurroAct_Index(pc,d1.w)
; ===========================================================================

BurroAct_Index:		offsetTable
		offsetTableEntry.w Burro_ChangeDir
		offsetTableEntry.w Burro_Move
		offsetTableEntry.w Burro_Jump
		offsetTableEntry.w Burro_ChkSonic
; ===========================================================================

Burro_ChangeDir:
		subq.w	#1,obBurro_TurnTime(a0)		; decrement timer
		bpl.s	.nochg						; branch if time remains
		addq.b	#2,obRoutine(a0)			; -> Burro_Move
		move.w	#255,obBurro_TurnTime(a0)	; time until turn (4.2-ish seconds)
		move.w	#$80,obVelX(a0)
		move.b	#1,obAnim(a0)
		bchg	#staFlipX,obStatus(a0)		; change direction the Burrobot	is facing
		beq.s	.nochg						; branch if xflip was 0
		neg.w	obVelX(a0)					; change direction the Burrobot	is moving

	.nochg:
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

Burro_Move:
		subq.w	#1,obBurro_TurnTime(a0)		; decrement turning timer
		bmi.s	Burro_Move_Turn				; branch if time runs out

		bsr.w	SpeedToPos
		bchg	#0,obBurro_FloorDetect(a0)	; change floor detection flag
		bne.s	.find_floor					; branch if it was 1
		move.w	obX(a0),d3
		addi.w	#12,d3						; find floor 12px to the right
		btst	#staFlipX,obStatus(a0)		; is burrobot xflipped?
		bne.s	.is_flipped					; if yes, branch
		subi.w	#24,d3						; find floor 12px to the left

	.is_flipped:
		jsr		(ObjFloorDist2).l			; find floor to left or right
		cmpi.w	#12,d1						; is floor 12 or more px away?
		bge.s	Burro_Move_Turn				; if yes, branch
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

	.find_floor:
		jsr		(ObjFloorDist).l
		add.w	d1,obY(a0)					; align to floor
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

Burro_Move_Turn:
		btst	#2,(v_vbla_byte).w			; test bit that changes every 4 frames
		beq.s	.jump_instead				; branch if 0
		subq.b	#2,obRoutine(a0)			; -> Burro_ChangeDir
		move.w	#59,obBurro_TurnTime(a0)	; set timer to 1 second
		clr.w	obVelX(a0)					; stop moving
		clr.b	obAnim(a0)					; walk_1 anim
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState	
; ===========================================================================

	.jump_instead:
		addq.b	#2,obRoutine(a0)			; -> Burro_Jump
		move.w	#-$400,obVelY(a0)			; jump upwards
		move.b	#2,obAnim(a0)				; digging anim
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

Burro_Jump:
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)			; apply gravity
		bmi.s	.exit					; branch if burrobot is moving upwards

		move.b	#3,obAnim(a0)			; falling animation
		jsr		(ObjFloorDist).l
		tst.w	d1						; has burrobot hit the floor?
		bpl.s	.exit					; if not, branch
		add.w	d1,obY(a0)				; align to floor
		clr.w	obVelY(a0)				; stop falling
		move.b	#1,obAnim(a0)			; walk_2 animation
		move.w	#255,obBurro_TurnTime(a0)	; time until turn (4.2-ish seconds)
		subq.b	#2,obRoutine(a0)		; -> Burro_Move
		bsr.s	Burro_ChkDist			; check & update xflip flag

	.exit:
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

Burro_ChkSonic:
		moveq	#96,d2
		bsr.w	Burro_ChkDist			; is Sonic < 96px from burrobot?
		bcc.s	.exit					; if not, branch

	; TO-DO: THIS part is bugged at the end of LZ3
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0
		bcc.s	.exit					; branch is Sonic is right of burrobot
		cmpi.w	#-128,d0
		bcs.s	.exit					; branch if Sonic is more than 128px away
		tst.w	(v_debuguse).w			; is debug mode	on?
		bne.s	.exit					; if yes, branch
		subq.b	#2,obRoutine(a0)		; goto Burro_Jump next
		move.w	d1,obVelX(a0)
		move.w	#-$400,obVelY(a0)		; burrobot jumps

	.exit:
		lea		Ani_Burro(pc),a1
		bsr.w	AnimateSprite
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check Sonic's distance from the burrobot

; input:
;	d2 = distance to compare

; output:
;	d0 = distance between Sonic and burrobot (abs negative value)
;	d1 = speed/direction for burrobot to move
; ---------------------------------------------------------------------------

Burro_ChkDist:
		move.w	#$80,d1
		bset	#staFlipX,obStatus(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.right					; if Sonic is right of burrobot, branch
		neg.w	d0
		neg.w	d1
		bclr	#staFlipX,obStatus(a0)

	.right:
		cmp.w	d2,d0
		rts
; ===========================================================================