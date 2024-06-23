; ----------------------------------------------------------------------------
; Object 07 - Visual Effects (Spin Dash, Skid Dust, Insta-Shield, etc.)
; ----------------------------------------------------------------------------
Effects:
		moveq	#0,d0
		move.b	obRoutine(a0),d0 
		move.w	Effects_Index(pc,d0.w),d1
		jmp		Effects_Index(pc,d1.w)
; ===========================================================================
Effects_Index:
		dc.w 	Effects_Init-Effects_Index
		dc.w 	Effects_Main-Effects_Index
		dc.w 	Effects_Delete-Effects_Index
		dc.w	Effects_ChkSkid-Effects_Index
; ===========================================================================
Effects_Init:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Effects,obMap(a0)
		ori.b	#4,obRender(a0)
		move.b	#1,obPriority(a0)
		move.b	#$10,obActWid(a0)
		clr.b	obAnim(a0)
		move.w	#ArtTile_Dust,obGfx(a0)
		move.w	#$F400,$3C(a0)

Effects_Main:	; Routine 2
		lea		(v_player).w,a2
		moveq	#0,d0
		move.b	obAnim(a0),d0	; use current animation as a secondary routine counter
		add.w	d0,d0
		move.w	Effects_DisplayModes(pc,d0.w),d1
		jmp		Effects_DisplayModes(pc,d1.w)
; ===========================================================================
; off_1DDA4:
Effects_DisplayModes:
		dc.w 	Effects_MdDisplay-Effects_DisplayModes		; 0
		dc.w 	Effects_MdSpindashDust-Effects_DisplayModes	; 2
		dc.w 	Effects_MdDisplay-Effects_DisplayModes		; Effects_MdSkidDust-Effects_DisplayModes	; 4
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
		andi.b	#1,obStatus(a0)
	endif

Effects_MdDisplay:
		lea		(Ani_Effects).l,a1
		jsr		AnimateSprite
		bsr.w	Effects_LoadGfx
		jmp		(DisplaySprite).l

Fx_MdNull:
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
		move.b	#3,objoff_32(a0)
		jsr		(FindFreeObj).l
		bne.s	Effects_LoadGfx
		move.b	obID(a0),obID(a1) ; load obj08
		move.w	obX(a2),obX(a1)
		move.w	obY(a2),obY(a1)
		addi.w	#$10,obY(a1)

		clr.b	obStatus(a1)
		move.b	#2,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	obMap(a0),obMap(a1)
		move.b	obRender(a0),obRender(a1)
		move.w	#$80,obPriority(a1)
		move.b	#4,obActWid(a1)
		move.w	obGfx(a0),obGfx(a1)
;fallthrough
; ===========================================================================
	endif

Effects_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0	; load frame number
		lea		(DynPLC_Effects).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5          ; read "number of entries" value
		subq.w	#1,d5
		bmi.s	EffectsDPLC_Return ; if zero, branch
		move.w	#(ArtTile_Dust*$20),d4

EffectsDPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Effects,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,EffectsDPLC_ReadEntry	; repeat for number of entries

EffectsDPLC_Return:
		rts