; ---------------------------------------------------------------------------
; Object 11 - GHZ bridge - Ported from Sonic 2 (Credit: DeltaWooloo)
; ---------------------------------------------------------------------------
; OST Constants
obBridge_StartY:		equ objoff_30		; 2 bytes | starting Y-axis position
obBridge_BendPixels:	equ objoff_32		; 1 byte  | number of pixels a log has been depressed
obBridge_CurrentLog:	equ objoff_33		; 1 byte  | log Sonic is currently standing on (left to right, starts at 0)
obBridge_ChildObj1:		equ objoff_3C		; 2 bytes | address of the first child object with log subsprites
obBridge_ChildObj2:		equ objoff_3E		; 2 bytes | address of the second child object with log subsprites
; ---------------------------------------------------------------------------

Bridge_Sub:		; child sprite objects only need to be drawn
		move.w	#priority3,d0				; RetroKoH/Devon S3K+ Priority Manager
		bra.w	DisplaySprite2				; display sprites
; ===========================================================================

Bridge:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Bri_Index(pc,d0.w),d1
		jmp		Bri_Index(pc,d1.w)
; ===========================================================================

Bri_Index:	offsetTable
		offsetTableEntry.w	Bri_Main
		offsetTableEntry.w	Bri_Action
		offsetTableEntry.w	Bri_Display	; Only called upon when on the bridge (Platform3:)
; ===========================================================================

Bri_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bri,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Bridge,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$80,obDispWid(a0)
		move.w	obY(a0),d2
		move.w	d2,obBridge_StartY(a0)
		move.w	obX(a0),d3
		moveq	#0,d1
		move.b	obSubtype(a0),d1			; copy subtype (bridge length) to d1
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0						; (d0 div 2) * 16
		sub.w	d0,d3						; d3 = x-position of left half
		swap	d1							; store subtype in high word for later
		move.w	#8,d1						; load #0008 to the low word
		bsr.s	Bri_MakeSegment
		move.w	sub6_x_pos(a1),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)					; center of first subsprite object
		move.w	a1,obBridge_ChildObj1(a0)	; pointer to first subsprite object
		swap	d1							; retrieve subtype
		subq.w	#8,d1
		bls.s	.nomore						; branch, if subtype <= 8 (bridge has no more than 8 logs)
	; else, create a second subsprite object for the rest of the bridge
		move.w	d1,d4
		bsr.s	Bri_MakeSegment
		move.w	a1,obBridge_ChildObj2(a0)	; pointer to second subsprite object
		move.w	d4,d0
		add.w	d0,d0
		add.w	d4,d0						; d0*3
		move.w	sub2_x_pos(a1,d0.w),d0
		subq.w	#8,d0
		move.w	d0,obX(a1)					; center of second subsprite object

.nomore:
		bra.s	Bri_Action					; bridge is finished
; ===========================================================================

Bri_MakeSegment:
		bsr.w	FindFreeObj
		bne.s	.return
		_move.l	#Bridge_Sub,obAddr(a1)		; load subsprite object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#renMultiDraw,obRender(a1)	; multi-draw (sub-sprites) flag
		move.b	#$40,mainspr_width(a1)
		move.b	d1,mainspr_childsprites(a1)
		subq.b	#1,d1
		lea		subspr_posdata(a1),a2		; starting address for subsprite position data
		lea		subspr_frames(a1),a3		; starting address for subsprite frame data

	.loop:
		move.w	d3,(a2)+					; sub?_x_pos
		move.w	d2,(a2)+					; sub?_y_pos
		move.w	#0,(a3)+					; sub?_mapframe
		addi.w	#$10,d3						; width of a log, x_pos for next log
		dbf		d1,.loop					; repeat for d1 logs

		move.b	#-1,mainspr_mapframe(a1)	; don't render the "main frame"

	.return:
		rts
; ===========================================================================

Bri_Action:	; Routine 2
		move.b	obStatus(a0),d0
		andi.b	#maskSonicOnObj,d0
		bne.s	.standing
		tst.b	obBridge_BendPixels(a0)
		beq.s	.solid
		subq.b	#4,obBridge_BendPixels(a0)
		bra.s	.bend
		
.standing:
		cmpi.b	#$40,obBridge_BendPixels(a0)
		beq.s	.bend
		addq.b	#4,obBridge_BendPixels(a0)

.bend:
		bsr.w	Bri_Bend

.solid:	; Similar to the start of the old Bri_Solid.
		moveq	#0,d1
		move.b	obSubtype(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1						; d1 = (half-width of bridge) + 8
		add.w	d2,d2						; d2 = (full width of bridge)
		moveq	#8,d3						; is this used???
		move.w	obX(a0),d4
		bsr.s	Bri_Solid
		bra.w	Bri_ChkDel					; Clownacy DisplaySprite Fix
; ===========================================================================

Bri_Solid:
		lea		(v_player).w,a1
		moveq	#obBridge_CurrentLog,d5
		btst	#staSonicOnObj,obStatus(a0)	; For single player, we don't need to load the standing bit to d6, as there's only one.
		beq.s	loc_F8F0					; Plat_Exit???
		btst	#staAir,obStatus(a1)
		bne.s	.flip
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	.flip
		cmp.w	d2,d0
		blo.s	.inX

	.flip:
		bclr	#staOnObj,obStatus(a1)
		bclr	#staSonicOnObj,obStatus(a0)	; For single player, we don't need to load the standing bit to d6, as there's only one.
		moveq	#0,d4
		rts
; ===========================================================================

	.inX:
		lsr.w	#4,d0						; get index of log that Sonic is standing on
		move.b	d0,(a0,d5.w)				; 	move.b	d0,obBridge_CurrentLog(a0)
		movea.w	obBridge_ChildObj1(a0),a2	; Get child object
		cmpi.w	#8,d0						; is Sonic on logs 0-7?
		blo.s	.firstsubsprite				; if yes, branch

		movea.w	obBridge_ChildObj2(a0),a2	; Get child object
		subq.w	#8,d0						; get actual log ID for the second part of the bridge

	.firstsubsprite:
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0						; multiply by 4 for correct subsprite
		addq.w	#2,d0						; add 2 to get y-pos
		move.w	subspr_posdata(a2,d0.w),d0
		subq.w	#8,d0
		moveq	#0,d1
		move.b	obHeight(a1),d1
		sub.w	d1,d0
		move.w	d0,obY(a1)
		moveq	#0,d4
		rts
; ===========================================================================

loc_F8F0:
		move.w	d1,-(sp)
		bsr.s	PlatformBridge_cont
		move.w	(sp)+,d1
		btst	#staSonicOnObj,obStatus(a0)
		beq.s	.return	; rts
		moveq	#0,d0
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		lsr.w	#4,d0
		move.b	d0,(a0,d5.w)				; 	move.b	d0,obBridge_CurrentLog(a0)

.return:
		rts
; End of function Bri_Solid
; ===========================================================================

PlatformBridge_cont:
		tst.w	obVelY(a1)
		bmi.w	return_19E8E;Plat_Exit
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	return_19E8E;Plat_Exit
		cmp.w	d2,d0
		bhs.w	return_19E8E;Plat_Exit
		bra.w	loc_19DD8;Plat_NoXCheck
; ===========================================================================

Bri_Bend:
		move.b	obBridge_BendPixels(a0),d0
		bsr.w	CalcSine
		move.w	d0,d4
		lea		Obj11_BendData2(pc),a4
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.w	#4,d0
		moveq	#0,d3
		move.b	obBridge_CurrentLog(a0),d3
		move.w	d3,d2
		add.w	d0,d3
		moveq	#0,d5
		lea		Obj11_BendData(pc),a5
		move.b	(a5,d3.w),d5
		andi.w	#$F,d3
		lsl.w	#4,d3
		lea		(a4,d3.w),a3
		movea.w	obBridge_ChildObj1(a0),a1
		lea		sub9_y_pos+next_subspr(a1),a2	;$42
		lea		sub2_y_pos(a1),a1				;$10

.loopafter:
		moveq	#0,d0
		move.b	(a3)+,d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	obBridge_StartY(a0),d0
		move.w	d0,(a1)
		addq.w	#next_subspr,a1
		cmpa.w	a2,a1
		bne.s	.skiploopafter
		movea.w	obBridge_ChildObj2(a0),a1 ; a1=object
		lea		sub2_y_pos(a1),a1

.skiploopafter:
		dbf		d2,.loopafter

		moveq	#0,d0
		move.b	obSubtype(a0),d0
		moveq	#0,d3
		move.b	obBridge_CurrentLog(a0),d3
		addq.b	#1,d3
		sub.b	d0,d3
		neg.b	d3
		bmi.s	.ret
		move.w	d3,d2
		lsl.w	#4,d3
		lea		(a4,d3.w),a3
		adda.w	d2,a3
		subq.w	#1,d2
		bcs.s	.ret

.loopbefore:
		moveq	#0,d0
		move.b	-(a3),d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	obBridge_StartY(a0),d0
		move.w	d0,(a1)
		addq.w	#next_subspr,a1
		cmpa.w	a2,a1
		bne.s	.skiploopbefore
		movea.w	obBridge_ChildObj2(a0),a1 ; a1=object
		lea		sub2_y_pos(a1),a1

.skiploopbefore:
		dbf		d2,.loopbefore

.ret:
		rts	
; End of function Bri_Bend
; ===========================================================================

; ---------------------------------------------------------------------------
; GHZ bridge-bending data
; (Defines how the bridge bends	when Sonic walks across	it)
; ---------------------------------------------------------------------------
Obj11_BendData:	binclude	"misc/ghzbend1.bin"
		even
Obj11_BendData2:binclude	"misc/ghzbend2.bin"
		even
; ===========================================================================

Bri_ChkDel:
		out_of_range.s	Bri_Delete		; ProjectFM S3K Objects Manager

Bri_Display:	; Routine 4
		rts	
; ===========================================================================

Bri_Delete:
		movea.w	obBridge_ChildObj1(a0),a1	; a1=object
		bsr.w	DeleteChild
		cmpi.b	#8,obSubtype(a0)
		bls.s	.delete2nd			; if bridge has more than 8 logs, delete second subsprite object
		movea.w	obBridge_ChildObj2(a0),a1	; a1=object
		bsr.w	DeleteChild

.delete2nd:
		move.w	obRespawnAddr(a0),d0
		beq.w	DeleteObject
		movea.w	d0,a2
		bclr	#7,(a2)
		bra.w	DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to collide Sonic with the top of a bridge
; Ported from Sonic 2 (Credit: DeltaW)
; ---------------------------------------------------------------------------

loc_19DD8:
		move.w	obY(a0),d0
		sub.w	d3,d0
;loc_19DDE:
;PlatformObject_ChkYRange:
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	return_19E8E
		cmpi.w	#-$10,d0
		blo.w	return_19E8E
		tst.b	obCtrlLock(a1)		; Sonic 2 OST obj_control
		bmi.w	return_19E8E
		cmpi.b	#6,obRoutine(a1)	; Sonic death check
		bhs.w	return_19E8E
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,obY(a1)
		
;loc_19E14:
;RideObject_SetRide:
		btst	#staOnObj,obStatus(a1)
		beq.s	loc_19E30
		movea.w	obPlatformAddr(a1),a3	; a3 = object being stood upon (RetroKoH obPlatform SST mod)
		bclr	#staSonicOnObj,obStatus(a3)	; removed obSolid

loc_19E30:
	; RetroKoH obPlatform SST mod
		move.w	a0,obPlatformAddr(a1)
	; obPlatform SST mod end
		clr.b	obAngle(a1)
		clr.w	obVelY(a1)
		move.w	obVelX(a1),obInertia(a1)
	; RetroKoH added check to prevent unwanted rolling
		btst	#staAir,obStatus(a1)	; is Sonic in the air?
		beq.s	RideObject_NotInAir		; if not, branch
		move.l	a0,-(sp)
		movea.l	a1,a0					; a0=character

RideObject_SetOnFloor:	
		jsr		(Sonic_ResetOnFloor).l		
		movea.l	(sp)+,a0				; a0=bridge

RideObject_NotInAir:
		bset	#staOnObj,obStatus(a1)	; set MainCharacter's on object obStatus
		bset	#staSonicOnObj,obStatus(a0)

return_19E8E:
		rts
; ===========================================================================