; ---------------------------------------------------------------------------
; Object 4C - lava geyser / lavafall producer (MZ)
; ---------------------------------------------------------------------------

GeyserMaker:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GMake_Index(pc,d0.w),d1
		jmp		GMake_Index(pc,d1.w)	; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
										; Clownacy DisplaySprite Fix (FixBugs solutions implemented as opposed to stack-meddling)
; ===========================================================================

GMake_Index:	offsetTable
		offsetTableEntry.w GMake_Main
		offsetTableEntry.w GMake_Wait
		offsetTableEntry.w GMake_ChkType
		offsetTableEntry.w GMake_MakeLava
		offsetTableEntry.w GMake_Display
		offsetTableEntry.w GMake_Delete
; ===========================================================================

GMake_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Geyser,obMap(a0)
		move.w	#make_art_tile(ArtTile_MZ_Lava,3,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$38,obDispWid(a0)
		move.w	#120,obGMake_WaitTotal(a0)	; set time delay to 2 seconds

GMake_Wait:	; Routine 2
		subq.w	#1,obGMake_WaitTime(a0)		; decrement timer
		bpl.s	.cancel						; if time remains, branch

		move.w	obGMake_WaitTotal(a0),obGMake_WaitTime(a0)	; reset timer
		move.w	(v_player+obY).w,d0
		move.w	obY(a0),d1
		cmp.w	d1,d0
		bcc.s	.cancel						; branch if Sonic is to the right
		subi.w	#368,d1
		cmp.w	d1,d0
		bcs.s	.cancel						; branch if Sonic is more than 368px to the left
		addq.b	#2,obRoutine(a0)			; if Sonic is within range, goto GMake_ChkType

.cancel:
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		rts	
; ===========================================================================

GMake_MakeLava:	; Routine 6
		addq.b	#2,obRoutine(a0)			; -> GMake_Display
		bsr.w	FindNextFreeObj
		bne.s	.fail						; branch if object slot not found
		_move.l	#LavaGeyser,obAddr(a1)	; load lavafall object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.w	a0,obGeyser_Parent(a1)		; set this object as the new object's parent

	.fail:
		move.b	#1,obAnim(a0)
		tst.b	obSubtype(a0)				; is object type 00 (geyser)?
		beq.s	.isgeyser					; if yes, branch
		move.b	#4,obAnim(a0)
		bra.s	GMake_Display
; ===========================================================================

	.isgeyser:
		movea.w	obGeyser_Parent(a0),a1		; get parent object (maker)'s address
		bset	#staFlipY,obStatus(a1)
		move.w	#-$580,obVelY(a1)
; ---------------------------------------------------------------------------

GMake_Display:	; Routine 8
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		lea		Ani_Geyser(pc),a1
		jsr		(AnimateSprite).w			; animate and goto next routine if specified
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

GMake_ChkType:	; Routine 4
		tst.b	obSubtype(a0)				; is object type 00 (geyser)?
		beq.s	GMake_Display				; if yes, branch
		addq.b	#2,obRoutine(a0)			; -> GMake_MakeLava
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject
		rts	
; ===========================================================================

GMake_Delete:	; Routine $A
		clr.b	obAnim(a0)					; set anim to _bubble1
		move.b	#2,obRoutine(a0)			; -> GMake_Wait
		tst.b	obSubtype(a0)				; is object type 00 (geyser)?
		beq.w	DeleteObject				; if yes, branch and delete
		; FixBugs - Deletion has been changed to eliminate potential double-delete and display-and-delete bugs.
		offscreen.w	DeleteObject			; if not, only delete if offscreen
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Object - lava geyser / lavafall (MZ)
; ---------------------------------------------------------------------------

LavaGeyser:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Geyser_Index(pc,d0.w),d1
		jmp		Geyser_Index(pc,d1.w)			; FixBugs - The call to DisplaySprite has been moved to prevent a display-and-delete bug.
; ===========================================================================

Geyser_Index:	offsetTable
		offsetTableEntry.w Geyser_Main
		offsetTableEntry.w Geyser_Action
		offsetTableEntry.w Geyser_Middle
		offsetTableEntry.w Geyser_Delete
; ===========================================================================

Geyser_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; goto Geyser_Action next
		move.w	obY(a0),obGeyser_StartY(a0)
		move.w	#-$500,obVelY(a0)				; set geyser speed
		tst.b	obSubtype(a0)					; is this a geyser or lavafall?
		beq.s	.isgeyser						; branch if geyser (00)
		subi.w	#$250,obY(a0)					; if lavafall, start from above
		clr.w	obVelY(a0)						; lavafall has no Y speed

	.isgeyser:
		movea.l	a0,a1
		moveq	#1,d1
		bsr.s	.makelava
		bra.s	.activate
; ===========================================================================

	.loop:
		bsr.w	FindNextFreeObj
		bne.s	.fail

.makelava:
		_move.l	#LavaGeyser,obAddr(a1)
		move.l	#Map_Geyser,obMap(a1)
		move.w	#make_art_tile(ArtTile_MZ_Lava,3,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obDispWid(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obSubtype(a0),obSubtype(a1)
		move.w	#priority1,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#5,obAnim(a1)
		tst.b	obSubtype(a0)					; is this a geyser or lavafall?
		beq.s	.fail							; branch if geyser (00)
		move.b	#2,obAnim(a1)					; use different animation for lavafall

	.fail:
		dbf		d1,.loop						; repeat once for middle section
		rts	
; ===========================================================================

.activate:
		addi.w	#96,obY(a1)					; move 2nd object down 96px
		move.w	obGeyser_StartY(a0),obGeyser_StartY(a1)
		addi.w	#96,obGeyser_StartY(a1)
		move.b	#(colHarmful|colSz_32x112),obColType(a1)

		bset	#shPropFlame,obShieldProp(a1)	; Negated by Flame Shield

		move.b	#$80,obHeight(a1)
		bset	#renUseHeight,obRender(a1)		; set height flag, as this is a larger object
		addq.b	#4,obRoutine(a1)				; goto Geyser_Middle next
		move.w	a0,obGeyser_Parent(a1)
		tst.b	obSubtype(a0)					; is this a geyser or lavafall?
		beq.s	.sound							; branch if geyser (00)

		moveq	#0,d1
		bsr.w	.loop							; load one more object
		addq.b	#2,obRoutine(a1)				; goto Geyser_Action next
		bset	#gfxFlipY,obGfx(a1)
		addi.w	#256,obY(a1)
		move.w	#priority0,obPriority(a1)
		move.w	obGeyser_StartY(a0),obGeyser_StartY(a1)
		move.w	obGeyser_Parent(a0),obGeyser_Parent(a1)
		clr.b	obSubtype(a0)

	.sound:
		move.w	#sfx_Burning,d0
		jsr		(QueueSound2).w					; play flame sound

Geyser_Action:	; Routine 2
	; RetroKoH Object Routine Optimization
		addi.w	#$18,obVelY(a0)					; apply gravity
		move.w	obGeyser_StartY(a0),d0
		cmp.w	obY(a0),d0						; is geyser/lavafall back at start position?
		bcc.s	.update							; if not, branch
		addq.b	#4,obRoutine(a0)				; -> Geyser_Delete
		movea.w	obGeyser_Parent(a0),a1
		move.b	#3,obAnim(a1)					; anim _bubble3 (geyser)
		tst.b	obSubtype(a0)					; is this a geyser or lavafall?
		beq.s	.update							; branch if geyser (00)
		move.b	#1,obAnim(a1)					; anim _bubble2 (lavafall)

	.update:
		bsr.w	SpeedToPos_YOnly
		lea		Ani_Geyser(pc),a1
		jsr		(AnimateSprite).w
		offscreen.w	DeleteObject				; ProjectFM S3k OBject Manager
		jmp		(DisplayAndCollision).l			; FixBugs - Moved to prevent a delete-and-display bug.
; ===========================================================================

Geyser_Middle:	; Routine 4
		movea.w	obGeyser_Parent(a0),a1
		cmpi.b	#6,obRoutine(a1)				; is parent set to delete?
		beq.w	DeleteObject					; if yes, branch
		move.w	obY(a1),d0
		addi.w	#96,d0
		move.w	d0,obY(a0)						; set y position 96px below parent
		sub.w	obGeyser_StartY(a0),d0
		neg.w	d0
		moveq	#8,d1
		cmpi.w	#64,d0
		bge.s	.not_short						; branch if object is more than 64px from position
		moveq	#$B,d1

	.not_short:
		cmpi.w	#128,d0
		ble.s	.not_long						; branch if object is less than 128px from position
		moveq	#$E,d1

	.not_long:
		subq.b	#1,obTimeFrame(a0)				; decrement animation timer
		bpl.s	.update_frame					; branch if time remains
		move.b	#7,obTimeFrame(a0)				; reset timer
		addq.b	#1,obAniFrame(a0)				; next frame
		cmpi.b	#2,obAniFrame(a0)
		bcs.s	.update_frame					; branch if valid frame
		clr.b	obAniFrame(a0)					; reset frame to 0 if past max

	.update_frame:
		move.b	obAniFrame(a0),d0
		add.b	d1,d0
		move.b	d0,obFrame(a0)					; set frame based on animation and initial frame (d1)
		offscreen.w	DeleteObject				; ProjectFM S3k OBject Manager
		jmp		(DisplayAndCollision).l			; FixBugs - Moved to prevent a delete-and-display bug.
; ===========================================================================

Geyser_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================