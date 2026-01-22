; ---------------------------------------------------------------------------
; Sub-Object -- Eggman's face during boss fights
; ---------------------------------------------------------------------------
; OST Constants
obBossFace_Defeat:		equ objoff_3A		; 1 byte  | routine number that boss is defeated on
obBossFace_PrevFrame:	equ	objoff_3B		; 1 byte  |
obBossFace_Escape:		equ objoff_3C		; 2 bytes | escape speed of ship
obBossFace_Parent:		equ objoff_3E		; 2 bytes | parent address (Eggman's ship)
; ---------------------------------------------------------------------------

BossFace:
		movea.w	obBossFace_Parent(a0),a3			; get address of parent object (ship)

	; Devon Boss Object Fix
		tst.l	obAddr(a3)
		beq.s	.delete								; branch if parent has been deleted
	; Boss Object Fix End

		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Face_Index(pc,d0.w),d1
		jsr		Face_Index(pc,d1.w)
		lea		(Ani_Eggman).l,a1
		jsr		(AnimateSprite).w
		bsr.w	BossFace_LoadGfx
		move.w	obX(a3),obX(a0)
		move.w	obY(a3),obY(a0)
		move.b	obStatus(a3),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		jmp		(DisplaySprite).l
; ===========================================================================

	.delete:
		jmp	DeleteObject
; ===========================================================================

Face_Index:	offsetTable
		offsetTableEntry.w Face_Main
		offsetTableEntry.w Face_Chk
		offsetTableEntry.w Face_Hit
		offsetTableEntry.w Face_Attack
		offsetTableEntry.w Face_Laugh
		offsetTableEntry.w Face_Defeat
		offsetTableEntry.w Face_Panic
		offsetTableEntry.w Face_Lift
; ===========================================================================

Face_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; goto Face_Chk next
		move.l	#Map_BossFace,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Face,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.w	#priority3,obPriority(a0)
		move.b	#aniID_NormalFace1,obAnim(a0)	; use default animation
		bclr	#7,obAnim(a0)
; ---------------------------------------------------------------------------

Face_Chk:	; Routine 2
		tst.b	obBoss_FlashFrames(a3)
		bne.s	Face_Goto_Hit					; branch if boss is flashing
		tst.b	obBoss_AttackFlag(a3)
		bne.s	Face_Goto_Attack				; branch if boss is attacking
		cmpi.b	#4,(v_player+obRoutine).w
		bcc.s	Face_Goto_Laugh					; branch if Sonic is hurt or dead
		move.w	obBossFace_Escape(a0),d0
		cmp.w	obVelX(a3),d0
		beq.s	Face_Goto_Panic					; branch if ship is escaping
		move.b	obBossFace_Defeat(a0),d0
		beq.s	.exit							; branch if no defeat routine is specified
		cmp.b	ob2ndRout(a3),d0
		bls.s	Face_Goto_Defeat				; branch if boss is on specified routine
		tst.b	obSubtype(a0)
		beq.s	.exit							; branch if not in Spring Yard
		cmp.b	#2,obBoss_3rdRout(a3)
		beq.s	Face_Goto_Lift					; branch if boss is lifting a block (SYZ only)

	.exit:
		rts
; ===========================================================================

Face_Goto_Hit:
		move.b	#aniID_HurtFace,obAnim(a0)		; use hit animation
		move.b	#4,obRoutine(a0)				; goto Face_Hit next
		rts
; ===========================================================================

Face_Goto_Default:
		move.b	#aniID_NormalFace1,obAnim(a0)	; use default animation
		move.b	#2,obRoutine(a0)				; goto Face_Chk next
		rts
; ===========================================================================

Face_Goto_Attack:
		move.b	#aniID_LaughFace,obAnim(a0)
		move.b	#6,obRoutine(a0)				; goto Face_Attack next
		rts
; ===========================================================================

Face_Goto_Laugh:
		move.b	#aniID_LaughFace,obAnim(a0)
		move.b	#8,obRoutine(a0)				; goto Face_Laugh next
		rts
; ===========================================================================
		
Face_Goto_Panic:
		move.b	#aniID_PanicFace,obAnim(a0)
		move.b	#$C,obRoutine(a0)				; goto Face_Panic next
		rts

; ===========================================================================
Face_Goto_Lift:
		move.b	#aniID_PanicFace,obAnim(a0)
		move.b	#$E,obRoutine(a0)				; goto Face_Lift next
		rts
; ===========================================================================

Face_Goto_Defeat:
		move.b	#aniID_DefeatFace,obAnim(a0)
		move.b	#$A,obRoutine(a0)				; goto Face_Defeat next
		rts
; ===========================================================================

Face_Hit:	; Routine 4
		tst.b	obBoss_FlashFrames(a3)
		beq.s	Face_Goto_Default				; branch if boss isn't flashing
		rts
; ===========================================================================

Face_Attack:	; Routine 6
		tst.b	obBoss_AttackFlag(a3)
		beq.s	Face_Goto_Default			; branch if boss isn't attacking
		rts
; ===========================================================================
		
Face_Laugh:	; Routine 8
		cmpi.b	#4,(v_player+obRoutine).w
		bcs.s	Face_Goto_Default			; branch if Sonic isn't hurt or dead
		rts
; ===========================================================================
		
Face_Defeat:	; Routine $A
		move.w	obBossFace_Escape(a0),d0
		cmp.w	obVelX(a3),d0
		beq.s	Face_Goto_Panic				; branch if ship is escaping
		rts
; ===========================================================================
		
Face_Panic:	; Routine $C
		rts
; ===========================================================================
		
Face_Lift:	; Routine $E
		tst.b	obBoss_FlashFrames(a3)
		bne.w	Face_Goto_Hit				; branch if boss is flashing
		cmp.b	#2,obBoss_3rdRout(a3)
		bne.w	Face_Goto_Default			; branch if boss isn't lifting a block
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Eggman's Face dynamic pattern loading subroutine -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

BossFace_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0				; load frame number
		cmp.b	obBossFace_PrevFrame(a0),d0	; has frame changed?
		beq.s	.nochange					; if not, branch and exit

		move.b	d0,obBossFace_PrevFrame(a0)	; update frame number for next check
		lea		DynPLC_BossFace(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Eggman_Face*tile_size),d4

	.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1					; S3K .b to .w
		move.w	d1,d3						; S3K
		lsr.w	#8,d3						; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_BossFace,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry				; repeat for number of entries

	.nochange:
		rts
; ===========================================================================