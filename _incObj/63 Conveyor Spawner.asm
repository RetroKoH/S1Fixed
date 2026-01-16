; ---------------------------------------------------------------------------
; Object 63 - conveyor platform spawner (LZ/SBZ)
; ---------------------------------------------------------------------------

ConveyorSpawner:
		bsr		ConvSpawn
		offscreen.s	LCon_ChkDel				; PFM S3K OBJ

Conv_Display:
		rts
; ===========================================================================

LCon_ChkDel:
		cmpi.b	#2,(v_act).w				; is this LZ Act 3?
		bne.s	.not_act3					; if not, branch
		cmpi.w	#-$80,d0					; is object to the right?
		bhs.s	Conv_Display				; if yes, branch

	.not_act3:
		move.b	obSubtype(a0),d0			; get original subtype
		lea		(v_conveyactive).w,a2
		bclr	#0,(a2,d0.w)
		bra.w	DeleteObject
; ===========================================================================

ConvSpawn:
		move.b	obSubtype(a0),d0			; load spawner subtype
		lea		(v_conveyactive).w,a2
		bset	#0,(a2,d0.w)				; set this group's respective bit
		beq.s	.not_set
		bra.w	DeleteObject
; ===========================================================================

	.index:
;ObjPosLZPlatform_Index:
		dc.l ObjPos_LZ1pf1, ObjPos_LZ1pf2
		dc.l ObjPos_LZ2pf1, ObjPos_LZ2pf2
		dc.l ObjPos_LZ3pf1, ObjPos_LZ3pf2
		dc.l ObjPos_LZ1pf1, ObjPos_LZ1pf2
;ObjPosSBZPlatform_Index:
		dc.l ObjPos_SBZ1pf1, ObjPos_SBZ1pf2
		dc.l ObjPos_SBZ1pf3, ObjPos_SBZ1pf4
		dc.l ObjPos_SBZ1pf5, ObjPos_SBZ1pf6
		dc.l ObjPos_SBZ1pf1, ObjPos_SBZ1pf2
; ===========================================================================

	.not_set:
		_move.l	#LabyrinthConvey,d3			; LZ Conveyor Platform
		cmpi.b	#id_SBZ,(v_zone).w			; are we in Scrap Brain?
		bne.s	.notsbz
		_move.l	#SpinConvey,d3				; SBZ Spinning Conveyor Platform

	.notsbz:
		add.w	d0,d0						; multiply platform group ID by 2 (use for word AND longword pointers)
		add.w	d0,d0						; multiply platform group ID by 4 (use only for longword pointers)
		andi.w	#$1E,d0						; capped at $10 groups of platforms (0-$F)

	; RetroKoH Object Loading Optimization
		lea		.index(pc),a2				; Next, we load the first pointer in the object layout list pointer index,
		movea.l (a2,d0.w),a2				; Changed from adda.w to movea.l for longword object layout pointers
;		adda.w	(a2,d0.w),a2				; a2 = positioning data for this platform group (use only for word-length pointers)

		move.w	(a2)+,d1					; d1 = number of platforms - 1

	; Here we begin what's replacing FindFreeObj, in order to avoid resetting its d0 every time an object is created.
	; Slight improvement by Malachi
		lea		(v_lvlobjspace-object_size).w,a1
		move.w	#v_lvlobjcount,d2

	.loop:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		dbeq	d2,.loop					; branch correction again.
		bne.s	.endloop

	.makePtfms:
		_move.l	d3,obAddr(a1)				; create platform object
		move.w	(a2)+,obX(a1)				; set x-position
		move.w	(a2)+,obY(a1)				; set y-position
		move.w	(a2)+,d0
		move.b	d0,obSubtype(a1)			; set subtype, discarding upper byte
		dbf		d1,.loop					; repeat for number of platforms

	.endloop:
		rts
; ===========================================================================