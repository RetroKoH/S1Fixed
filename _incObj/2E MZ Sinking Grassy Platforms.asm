; ---------------------------------------------------------------------------
; Object 2E - grass-covered platform that sinks into lava (MZ)
; Split from Obj2F by RetroKoH
; ---------------------------------------------------------------------------

SinkingGrass:
		_move.l	#SGrass_Action,obAddr(a0)
		move.l	#Map_LGrass,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),obLGrass_StartY(a0)
		move.w	obX(a0),obLGrass_StartX(a0)

; Removed... use this if you want different heightmaps for different subtypes of this object
;		move.l	#SGrass_Collision,obLGrass_ColPtr(a0)	; get pointer to heightmap data

		move.b	#1,obFrame(a0)				; sinking platform frame
		move.b	#$40,obDispWid(a0)
		andi.b	#$F,obSubtype(a0)			; clear high nybble of subtype
		move.b	#$40,obHeight(a0)
		bset	#renUseHeight,obRender(a0)	; set height flag, as this is a larger object
; ---------------------------------------------------------------------------

SGrass_Action:	; Routine 2
		bsr.w	SGrass_Sinking
		btst	#staSonicOnObj,obStatus(a0)	; is platform being stood on? removed obSolid
		beq.s	SGrass_Solid				; if not, branch
		moveq	#11,d1
		add.b	obDispWid(a0),d1			; width; save 8 cycles
		bsr.w	ExitPlatform				; update flags if Sonic leaves plaform
		btst	#staOnObj,obStatus(a1)		; is Sonic still on the platform?
		bne.w	SGrass_Slope				; if yes, branch
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	SGrass_ChkDel
; ===========================================================================

SGrass_Slope:
		moveq	#11,d1
		add.b	obDispWid(a0),d1		; width; save 8 cycles
		lea		SGrass_Collision(pc),a2	; pointer to heightmap
		move.w	obX(a0),d2				; axis position
		bsr.w	SlopeObject2
		bra.w	SGrass_ChkDel
; ===========================================================================

SGrass_Solid:
		moveq	#11,d1
		add.b	obDispWid(a0),d1		; width; save 8 cycles
		moveq	#32,d2					; height
		lea		SGrass_Collision(pc),a2	; pointer to heightmap
		bsr.w	SolidObject2F			; SolidObject_Heightmap
		bra.w	SGrass_ChkDel			; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update platform position and load burning grass object
; ---------------------------------------------------------------------------

SGrass_Sinking:
		move.b	obLGrass_SinkPixels(a0),d0	; get current sink distance
		btst	#staSonicOnObj,obStatus(a0)	; is platform being stood on? (removed obSolid)
		bne.s	.stood_on					; if yes, branch
		subq.b	#2,d0						; decrement sink distance
		bcc.s	.update_sink				; branch if not < 0
		moveq	#0,d0						; reset to 0
		bra.s	.update_sink
; ===========================================================================

	.stood_on:
		addq.b	#4,d0						; add 4 to sink distance
		cmpi.b	#64,d0						; has it reached 64px?
		blo.s	.update_sink				; if not, branch
		move.b	#64,d0						; max = 64px

	.update_sink:
		move.b	d0,obLGrass_SinkPixels(a0)	; update sink distance
		jsr		(CalcSine).w
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	obLGrass_StartY(a0),d0
		move.w	d0,obY(a0)					; update position
		cmpi.b	#32,obLGrass_SinkPixels(a0)
		bne.s	.skip_fire					; branch if not at 32px
		tst.b	obLGrass_BurnFlag(a0)
		bne.s	.skip_fire					; branch if already burning
		move.b	#1,obLGrass_BurnFlag(a0)	; set burning flag
		bsr.w	FindNextFreeObj
		bne.s	.skip_fire					; branch if object slot not found

		_move.l	#GrassFire,obAddr(a1)	; load sitting flame object (this spreads itself)
		move.w	obX(a0),obX(a1)
		move.w	obLGrass_StartY(a0),obGFire_StartY(a1)
		addq.w	#8,obGFire_StartY(a1)
		subq.w	#3,obGFire_StartY(a1)
		subi.w	#$40,obX(a1)				; start at left side of platform
		move.w	a0,obGFire_Parent(a1)		; save parent OST address
		movea.l	a0,a2
		bsr.s	SGrass_AddChildToList		; save first flame OST index to list in parent OST

	.skip_fire:
		moveq	#0,d2
		lea		obLGrass_Children(a0),a2	; get address of child list
		move.b	(a2)+,d2					; get quantity
		subq.b	#1,d2
		bcs.s	.skip_fire_sink				; branch if 0

	.loop_fire_sink:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.w	#v_objspace&$FFFF,d0		; convert child OST index to address
		movea.w	d0,a1
		move.w	d1,obGFire_SinkPixels(a1)	; copy parent sink distance to child
		dbf		d2,.loop_fire_sink			; repeat for all children

	.skip_fire_sink:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to add child to list in parent OST
;
; input:
;	a1 = address of OST of child fire
;	a2 = address of OST of parent platform
; ---------------------------------------------------------------------------

SGrass_AddChildToList:
		lea		obLGrass_Children(a2),a2	; load list of child objects
		moveq	#0,d0
		move.b	(a2),d0						; get child count
		addq.b	#1,(a2)						; increment child counter
		lea		1(a2,d0.w),a2				; go to end of list
		move.w	a1,d0						; get child object RAM address
		subi.w	#v_objspace&$FFFF,d0
		lsr.w	#object_size_bits,d0
		andi.w	#$7F,d0						; d0 = obj RAM index of child
		move.b	d0,(a2)						; copy d0 to end of list
		rts	
; End of function SGrass_AddChildToList
; ===========================================================================

SGrass_ChkDel:
		tst.b	obLGrass_BurnFlag(a0)		; is platform burning?
		beq.s	.not_burning				; if not, branch
		tst.b	obRender(a0)				; is platform off screen?
		bpl.s	SGrass_DelFlames			; if yes, branch

	.not_burning:
		offscreen.w	DeleteObject,obLGrass_StartX(a0)	; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite						; Clownacy DisplaySprite Fix
; ===========================================================================

SGrass_DelFlames:
		moveq	#0,d2
		lea		obLGrass_Children(a0),a2	; load list of child objects
		move.b	(a2),d2						; get quantity
		clr.b	(a2)+						; clear quantity
		subq.b	#1,d2
		bcs.w	DisplaySprite				; branch if 0

	.loop_del:
		moveq	#0,d0
		move.b	(a2),d0
		clr.b	(a2)+
		lsl.w	#object_size_bits,d0
		addi.w	#v_objspace&$FFFF,d0		; convert child obj index to address
		movea.w	d0,a1
		bsr.w	DeleteChild					; delete child object
		dbf		d2,.loop_del				; repeat for all children
		clr.b	obLGrass_BurnFlag(a0)
		clr.b	obLGrass_SinkPixels(a0)

	.no_fire:
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix
; ===========================================================================