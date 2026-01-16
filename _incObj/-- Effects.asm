; ----------------------------------------------------------------------------
; Dynamic Object - Dust Effects (Skid, Spin/Drop Dash)
; ----------------------------------------------------------------------------
; OST constants
obEff_DustTimer:		equ objoff_30		; 1 byte  | timer for generating dust
obEff_PrevFrame:		equ objoff_3F		; 1 byte  | stored frame for DPLC handling
; ----------------------------------------------------------------------------

Effects:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 
		move.w	Eff_Index(pc,d0.w),d1
		jmp		Eff_Index(pc,d1.w)
; ===========================================================================

Eff_Index:	offsetTable
		offsetTableEntry.w 	Eff_Init
		offsetTableEntry.w 	Eff_Main
		offsetTableEntry.w 	Eff_Delete
		offsetTableEntry.w	Eff_ChkSkid
; ===========================================================================

Eff_Init:		; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Effects,obMap(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
		clr.b	obAnim(a0)
		move.w	#ArtTile_Dust,obGfx(a0)
	;	move.w	#$F400,obEff_LoadArtLoc(a0)	; address to load art to in DPLC processing
		; Not needed for a single player game, but needed for adding a second player.

Eff_Main:		; Routine 2
		lea		(v_player).w,a2
		moveq	#$7F,d0
		and.b	obAnim(a0),d0				; use current animation as a secondary routine counter
		add.w	d0,d0
		move.w	Eff_DisplayModes(pc,d0.w),d1
		jmp		Eff_DisplayModes(pc,d1.w)
; ===========================================================================

Eff_DisplayModes:	offsetTable
		offsetTableEntry.w 	Eff_MdDisplay		; 0
		offsetTableEntry.w 	Eff_MdSpindashDust	; 2
		offsetTableEntry.w 	Eff_MdDisplay		; Eff_MdSkidDust-Eff_DisplayModes	; 4
		offsetTableEntry.w 	Eff_MdDisplay		; 6: DropDash Dust
; ===========================================================================

Eff_MdSpindashDust:
	if SpinDashEnabled==1
		cmpi.b	#4,obRoutine(a2)
		bhs.s	Eff_ResetDisplayMode
		tst.b	obSpinDashFlag(a2)
		beq.s	Eff_ResetDisplayMode
		move.w	obX(a2),obX(a0)				; match Player's position
		move.w	obY(a2),obY(a0)
		move.b	obStatus(a2),obStatus(a0)	; match Player's x orientation
		andi.b	#maskFacing,obStatus(a0)	; only retain staFacing (staFlipX)
	endif

Eff_MdDisplay:
		lea		Ani_Effects(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	Eff_LoadGfx
		jmp		(DisplaySprite).l
; ===========================================================================

Eff_ResetDisplayMode:
		clr.b	obAnim(a0)
		rts

Eff_Delete:		; Routine 4
		jmp		(DeleteObject).l			; delete when animation	is complete
; ===========================================================================

Eff_ChkSkid:	; Routine 6
	if ~~SkidDustEnabled
		rts
	else
		lea		(v_player).w,a2
		cmpi.b	#aniID_Stop,obAnim(a2)		; is Sonic skidding to a halt?
		beq.s	Eff_SkidDust				; if yes, branch
		move.b	#2,obRoutine(a0)			; otherwise, revert to Routine 2
		clr.b	obEff_DustTimer(a0)			; and clear dust timer
		rts
; ===========================================================================

Eff_SkidDust:
		subq.b	#1,obEff_DustTimer(a0)		; decrement timer
		bpl.s	Eff_LoadGfx					; branch if time remains

		move.b	#3,obEff_DustTimer(a0)		; create dust once every 4 frames
		jsr		(FindFreeObj).l
		bne.s	Eff_LoadGfx
		_move.l	obAddr(a0),obAddr(a1)		; load obj07 (and copy obRender)
		move.w	obX(a2),obX(a1)
		move.w	obY(a2),obY(a1)
		addi.w	#$10,obY(a1)

		clr.b	obStatus(a1)
		move.b	#2,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#priority1,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#4,obDispWid(a1)
		move.w	obGfx(a0),obGfx(a1)
;fallthrough
; ===========================================================================
	endif

Eff_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		cmp.b	obEff_PrevFrame(a0),d0	; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,obEff_PrevFrame(a0)	; update frame number for next check
		lea		DynPLC_Effects(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Dust*tile_size),d4

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
; ===========================================================================