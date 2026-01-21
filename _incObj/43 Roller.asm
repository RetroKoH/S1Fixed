; ---------------------------------------------------------------------------
; Object 43 - Roller enemy (SYZ)
; ---------------------------------------------------------------------------
; OST Constants
obRoller_OpenTime:		equ objoff_30		; 2 bytes | time roller stays open for
obRoller_Mode:			equ objoff_32		; 1 byte  | +1 = roller has jumped; +$80 = roller has stopped
; ---------------------------------------------------------------------------

Roller:
		_move.l	#Roll_ChkFloor,obAddr(a0)
		move.w	#$E08,obHeight(a0)			; Height and Width
		move.l	#Map_Roll,obMap(a0)
		move.w	#make_art_tile(ArtTile_Roller,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
; ---------------------------------------------------------------------------

Roll_ChkFloor:
		bsr.w	ObjectFall_YOnly			; immediately make roller fall
		jsr		(ObjFloorDist).l			; find floor
		tst.w	d1							; has roller hit the floor?
		bpl.s	.floornotfound				; if not, branch (repeat until floor is found)
		add.w	d1,obY(a0)					; align to floor
		clr.w	obVelY(a0)					; stop falling
		obj_addr	#Roll_Action

	.floornotfound:
		rts	
; ===========================================================================

Roll_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	RollAct_Index(pc,d0.w),d1
		jsr		RollAct_Index(pc,d1.w)
		lea		Ani_Roll(pc),a1
		jsr		(AnimateSprite).w
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bgt.w	Roll_ChkGone
		bra.w	DisplayAndCollision			; S3K TouchResponse
; ===========================================================================

Roll_ChkGone:
	; ProjectFM S3K Object Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.w	DeleteObject				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
	; S3K Object Manager End
		bra.w	DeleteObject
; ===========================================================================

RollAct_Index:		offsetTable
		offsetTableEntry.w Roll_RollChk
		offsetTableEntry.w Roll_Stopped
		offsetTableEntry.w Roll_ChkJump
		offsetTableEntry.w Roll_JumpLand
; ===========================================================================

Roll_RollChk:
		move.w	(v_player+obX).w,d0
		subi.w	#256,d0						; d0 = Sonic's x position minus 256
		bcs.s	.exit						; branch if Sonic is < 256px from left edge of level
		sub.w	obX(a0),d0					; is Sonic > 256px left of the roller?
		bcs.s	.exit						; if not, branch
		addq.b	#4,ob2ndRout(a0)			; -> Roll_ChkJump
		move.b	#2,obAnim(a0)				; use roller's rolling animation
		move.w	#$700,obVelX(a0)			; move Roller horizontally
		move.b	#(colHarmful|colSz_16x14),obColType(a0) ; make Roller invincible

	.exit:
		addq.l	#4,sp
		rts	
; ===========================================================================

Roll_Stopped:
		cmpi.b	#2,obAnim(a0)				; is roller still rolling?
		beq.s	.is_rolling					; if yes, branch
		subq.w	#1,obRoller_OpenTime(a0)	; decrement timer
		bpl.s	.wait						; branch if time remains
		moveq	#1,d0						; use curling animation
		jsr		(NewAnim).w
		move.w	#$700,obVelX(a0)			; move roller right
		move.b	#(colHarmful|colSz_16x14),obColType(a0) ; make roller invincible

	.wait:
		rts	
; ===========================================================================

	.is_rolling:
		addq.b	#2,ob2ndRout(a0)			; -> Roll_ChkJump
		rts	
; ===========================================================================

Roll_ChkJump:
		bsr.w	Roll_Stop					; stop rolling if it's within range of Sonic
		bsr.w	SpeedToPos
		jsr		(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	Roll_Jump					; branch if more than 8px below floor
		cmpi.w	#$C,d1
		bge.s	Roll_Jump					; branch if more than 11px above floor (also detects a ledge)
		add.w	d1,obY(a0)					; align to floor
		rts	
; ===========================================================================

Roll_Jump:
		addq.b	#2,ob2ndRout(a0)			; -> Roll_JumpLand
		bset	#0,obRoller_Mode(a0)		; set jump flag
		beq.s	.dont_jump					; branch if previously 0 (jumps on next frame instead)
		move.w	#-$600,obVelY(a0)			; move roller upwards

	.dont_jump:
		rts	
; ===========================================================================

Roll_JumpLand:
		bsr.w	ObjectFall
		tst.w	obVelY(a0)
		bmi.s	.exit						; branch if moving upwards
		jsr		(ObjFloorDist).l
		tst.w	d1							; has roller hit the floor?
		bpl.s	.exit						; if not, branch
		add.w	d1,obY(a0)					; align to floor
		subq.b	#2,ob2ndRout(a0)			; -> Roll_ChkJump
		clr.w	obVelY(a0)					; stop falling

.exit:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to stop Roller if it's within range
; ---------------------------------------------------------------------------

Roll_Stop:
		tst.b	obRoller_Mode(a0)			; has roller already stopped?
		bmi.s	.exit						; if yes, branch
		move.w	(v_player+obX).w,d0
		subi.w	#48,d0
		sub.w	obX(a0),d0
		bcc.s	.exit						; branch if Sonic is > 48px left of the roller
		clr.b	obAnim(a0)
		move.b	#(colEnemy|colSz_16x14),obColType(a0)
		clr.w	obVelX(a0)					; stop roller moving
		move.w	#120,obRoller_OpenTime(a0)	; set waiting time to 2	seconds
		move.b	#2,ob2ndRout(a0)			; -> Roll_Stopped
		bset	#7,obRoller_Mode(a0)		; set flag for roller stopped

.exit:
		rts	
; End of function Roll_Stop
; ===========================================================================