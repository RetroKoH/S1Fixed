; ----------------------------------------------------------------------------
; Object 07 - Visual Effects (Spin Dash, Skid Dust, Drop Dash Dust)
; ----------------------------------------------------------------------------
Effects:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 
		move.w	Effects_Index(pc,d0.w),d1
		jmp		Effects_Index(pc,d1.w)
; ===========================================================================
Effects_Index:	offsetTable
		offsetTableEntry.w 	Effects_Init
		offsetTableEntry.w 	Effects_Main
		offsetTableEntry.w 	Effects_Delete
		offsetTableEntry.w	Effects_ChkSkid
; ===========================================================================
Effects_Init:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Effects,obMap(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obActWid(a0)
		clr.b	obAnim(a0)
		move.w	#ArtTile_Dust,obGfx(a0)
	;	move.w	#$F400,objoff_3C(a0)	; $34 = address to load art to in DPLC processing
		; Not needed for a single player game, but needed for adding a second player.

Effects_Main:	; Routine 2
		lea		(v_player).w,a2
		moveq	#0,d0
		move.b	obAnim(a0),d0	; use current animation as a secondary routine counter
		add.w	d0,d0
		move.w	Effects_DisplayModes(pc,d0.w),d1
		jmp		Effects_DisplayModes(pc,d1.w)
; ===========================================================================
; off_1DDA4:
Effects_DisplayModes:	offsetTable
		offsetTableEntry.w 	Effects_MdDisplay		; 0
		offsetTableEntry.w 	Effects_MdSpindashDust	; 2
		offsetTableEntry.w 	Effects_MdDisplay		; Effects_MdSkidDust-Effects_DisplayModes	; 4
		offsetTableEntry.w 	Effects_MdDisplay		; 6: DropDash Dust
; ===========================================================================
Effects_MdSpindashDust:
	if SpinDashEnabled=1
		cmpi.b	#4,obRoutine(a2)
		bhs.s	Effects_ResetDisplayMode
		tst.b	obSpinDashFlag(a2)
		beq.s	Effects_ResetDisplayMode
		move.w	obX(a2),obX(a0)				; match Player's position
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)	; match Player's x orientation
		andi.b	#maskFacing,obStatus(a0)	; only retain staFacing (staFlipX)
	endif

Effects_MdDisplay:
		lea		Ani_Effects(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	Effects_LoadGfx
		jmp		(DisplaySprite).l

Effects_MdNull:
		rts
; ===========================================================================
Effects_ResetDisplayMode:
		clr.b	obAnim(a0)
		rts

Effects_Delete:	; Routine 4
		jmp		(DeleteObject).l	; delete when animation	is complete
; ===========================================================================

Effects_ChkSkid:
	if SkidDustEnabled=0
		rts
	else
		lea		(v_player).w,a2
		cmpi.b	#aniID_Stop,obAnim(a2)
		beq.s	Effects_SkidDust
		move.b	#2,obRoutine(a0)
		clr.b	objoff_32(a0)
		rts
; ===========================================================================

Effects_SkidDust:
		subq.b	#1,objoff_32(a0)
		bpl.s	Effects_LoadGfx
		move.b	#3,objoff_32(a0)	; create dust once every 4 frames
		jsr		(FindFreeObj).l
		bne.s	Effects_LoadGfx
		move.b	obID(a0),obID(a1)	; load obj07
		move.w	obX(a2),obX(a1)
		move.w	obY(a2),obY(a1)
		addi.w	#$10,obY(a1)

		clr.b	obStatus(a1)
		move.b	#2,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#4,obActWid(a1)
		move.w	obGfx(a0),obGfx(a1)
;fallthrough
; ===========================================================================
	endif

Effects_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		cmp.b	objoff_3F(a0),d0		; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,objoff_3F(a0)		; update frame number for next check
		lea		DynPLC_Effects(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5			; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange			; if zero, branch
		move.w	#(ArtTile_Dust*$20),d4

.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1	; S3K .b to .w
		move.w	d1,d3		; S3K
		lsr.w	#8,d3		; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Effects,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry	; repeat for number of entries

.nochange:
		rts