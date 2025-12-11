; ---------------------------------------------------------------------------
; Object 6A - ground saws and pizza cutters (SBZ)
; ---------------------------------------------------------------------------

Saws:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Saw_Action
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Saw_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Saw,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Saw,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$20,obDispWid(a0)
		move.w	obX(a0),obSaw_StartX(a0)
		move.w	obY(a0),obSaw_StartY(a0)
		cmpi.b	#3,obSubtype(a0)				; is object a ground saw?
		bhs.s	Saw_Action						; if yes, branch
		move.b	#(colHarmful|colSz_24x24_2),obColType(a0)
; ---------------------------------------------------------------------------

Saw_Action:	; Routine 2
		moveq	#7,d0							; get last digit of subtype (sans bit 3)
		and.b	obSubtype(a0),d0				; SCE optimization
		beq.s	.type00							; skip if subtype 00 (doesn't move; unused)
		add.w	d0,d0
		move.w	Saw_Index-2(pc,d0.w),d1
		jsr		Saw_Index(pc,d1.w)

	.type00:
		offscreen.s	.delete,obSaw_StartX(a0)	; PFM S3K OBJ
		jmp		(DisplayAndCollision).l			; S3K TouchResponse

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================
Saw_Index:		offsetTable
	; pizza cutters
		offsetTableEntry.w	Saw_Pizza_Sideways	; moves side-to-side
		offsetTableEntry.w	Saw_Pizza_UpDown	; moves up and down
	; ground saws
		offsetTableEntry.w	Saw_Ground_Right	; moves right
		offsetTableEntry.w	Saw_Ground_Left		; moves left (unused)
; ===========================================================================

; Type 1
Saw_Pizza_Sideways:
		moveq	#$60,d1
		moveq	#0,d0
		move.b	(v_oscillate+$E).w,d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_flip
		neg.w	d0
		add.w	d1,d0

	.no_flip:
		move.w	obSaw_StartX(a0),d1
		sub.w	d0,d1
		move.w	d1,obX(a0)					; move saw sideways

		; wait
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bpl.s	.same_frame					; if time remains, branch
		addq.b	#2+1,obTimeFrame(a0)		; time between frame changes
		bchg	#0,obFrame(a0)				; change frame

	.same_frame:
		tst.b	obRender(a0)				; is object visible on the screen?
		bpl.s	.return						; if not, branch

		; play sfx
		moveq	#$F,d0
		and.w	(v_framecount).w,d0
		bne.s	.return
		move.w	#sfx_Saw,d0
		jmp		(QueueSound2).w				; play saw sound
; ===========================================================================

	.return:
		rts	
; ===========================================================================

; Type 2
Saw_Pizza_UpDown:
		moveq	#$30,d1
		moveq	#0,d0
		move.b	(v_oscillate+6).w,d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.no_flip
		neg.w	d0
		addi.w	#$80,d0

	.no_flip:
		move.w	obSaw_StartY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)					; move saw vertically

		; wait
		subq.b	#1,obTimeFrame(a0)			; decrement timer
		bpl.s	.same_frame					; if time remains, branch
		addq.b	#2+1,obTimeFrame(a0)		; reset timer to 2 frames
		bchg	#0,obFrame(a0)				; change frame

	.same_frame:
		tst.b	obRender(a0)				; is object visible on the screen?
		bpl.s	.return						; if not, branch

		; play sfx
		cmpi.b	#$18,(v_oscillate+6).w
		bne.s	.return
		move.w	#sfx_Saw,d0
		jmp		(QueueSound2).w				; play saw sound
; ===========================================================================

	.return:
		rts	
; ===========================================================================

; Type 3
Saw_Ground_Right:
		tst.b	obSaw_GroundFlag(a0)		; has the saw appeared already?
		bne.s	.here03						; if yes, branch

		; check
		move.w	(v_player+obX).w,d0
		subi.w	#$C0,d0
		bcs.s	.nosaw03x					; branch if Sonic is within 192px of left edge boundary
		sub.w	obX(a0),d0
		bcs.s	.nosaw03x					; branch if saw is < 192px to Sonic's left
		move.w	(v_player+obY).w,d0
		subi.w	#$80,d0
		cmp.w	obY(a0),d0
		bhs.s	.nosaw03y					; branch if saw is > 128px above Sonic
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bcs.s	.nosaw03y					; branch if saw is > 128px below Sonic

		; set
		move.b	#1,obSaw_GroundFlag(a0)		; flag object as already loaded
		move.w	#$600,obVelX(a0) 			; move object to the right
		move.b	#(colHarmful|colSz_24x24_2),obColType(a0)
		move.b	#2,obFrame(a0)
		move.w	#sfx_Saw,d0
		jsr		(QueueSound2).w				; play saw sound

	.nosaw03x:
		addq.l	#4,sp						; exit from object

	.nosaw03y:
		rts	
; ===========================================================================

	.here03:
		jsr		(SpeedToPos_XOnly).l
		move.w	obX(a0),obSaw_StartX(a0)

		; wait
		subq.b	#1,obTimeFrame(a0)			; decrement frame timer
		bpl.s	.sameframe03				; branch if time remains
		addq.b	#2+1,obTimeFrame(a0)		; reset timer
		bchg	#0,obFrame(a0)				; change frame

	.sameframe03:
		rts	
; ===========================================================================

; Type 4
Saw_Ground_Left:
		tst.b	obSaw_GroundFlag(a0)		; has the saw appeared already?
		bne.s	.here04						; if yes, branch

		; check
		move.w	(v_player+obX).w,d0
		addi.w	#$E0,d0
		sub.w	obX(a0),d0
		bcc.s	.nosaw04x					; branch if saw is > 224px right of Sonic 
		move.w	(v_player+obY).w,d0
		subi.w	#$80,d0
		cmp.w	obY(a0),d0
		bhs.s	.nosaw04y					; branch if saw is > 128px above Sonic
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bcs.s	.nosaw04y					; branch if saw is > 128px below Sonic

		; set
		move.b	#1,obSaw_GroundFlag(a0)		; flag object as already loaded
		move.w	#-$600,obVelX(a0) 			; move object to the left
		move.b	#(colHarmful|colSz_24x24_2),obColType(a0)
		move.b	#2,obFrame(a0)
		move.w	#sfx_Saw,d0
		jsr		(QueueSound2).w				; play saw sound

	.nosaw04x:
		addq.l	#4,sp						; exit from object

	.nosaw04y:
		rts	
; ===========================================================================

	.here04:
		jsr		(SpeedToPos_XOnly).l
		move.w	obX(a0),obSaw_StartX(a0)

		; wait
		subq.b	#1,obTimeFrame(a0)			; decrement frame timer
		bpl.s	.sameframe04				; branch if time remains
		addq.b	#2+1,obTimeFrame(a0)		; reset timer
		bchg	#0,obFrame(a0)				; change frame

	.sameframe04:
		rts
; ===========================================================================