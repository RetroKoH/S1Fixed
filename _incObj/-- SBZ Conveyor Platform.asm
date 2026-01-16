; ---------------------------------------------------------------------------
; Object - spinning platforms that move around a conveyor belt (SBZ)
; ---------------------------------------------------------------------------

SpinConvey:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	SpinC_Solid
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

SpinC_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> SpinC_Solid
		move.l	#Map_Spin,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Spinning_Platform,0,0),obGfx(a0)
		move.b	#$10,obDispWid(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get platform subtype assigned by spawner (based on 3rd word in ObjPosSBZPlatform_Index)
		move.w	d0,d1						; copy to d1
		lsr.w	#3,d0						; d0 = (platform subtype // 8) floor division. Result will be an even number (0, 2, 4, etc.)
		andi.w	#$1E,d0						; cap d0 to $1E (no odd values) -- Only 0-$A is used
		lea		SpinC_Corner_Data(pc),a2
		adda.w	(a2,d0.w),a2				; load corner data based on the platform subtype
		move.w	(a2)+,SpinCon_CornerNext(a0); CornerNext and CornerCount
		move.w	(a2)+,SpinCon_CenterX(a0)
		move.l	a2,SpinCon_DataAddr(a0)		; pointer to corner x/y values
		andi.w	#$F,d1						; read low nybble of subtype
		lsl.w	#2,d1						; multiply by 4
		move.b	d1,SpinCon_CornerNext(a0)	; index of next corner
		move.b	#4,SpinCon_CornerInc(a0)
		tst.b	(f_conveyrev).w				; have conveyors been reversed?
		beq.s	.no_reverse					; if not, branch

		move.b	#1,SpinCon_Reverse(a0)		; set platform's local reverse flag
		neg.b	SpinCon_CornerInc(a0)		; negate this value to -4
		moveq	#0,d1
		move.b	SpinCon_CornerNext(a0),d1
		add.b	SpinCon_CornerInc(a0),d1
		cmp.b	SpinCon_CornerCount(a0),d1	; is next corner valid?
		blo.s	.is_valid					; if yes, branch
		move.b	d1,d0
		moveq	#0,d1						; reset corner counter to 0
		tst.b	d0
		bpl.s	.is_valid
		move.b	SpinCon_CornerCount(a0),d1
		subq.b	#4,d1

	.is_valid:
		move.b	d1,SpinCon_CornerNext(a0)		; update corner counter

	.no_reverse:
		move.w	(a2,d1.w),SpinCon_TargetX(a0)	; set target x-position
		move.w	2(a2,d1.w),SpinCon_TargetY(a0)	; set target y-position
; ---------------------------------------------------------------------------
; Much of the init code is identical to LCon (Obj63), but this section is
; unique to SpinCon (Obj6F).

		tst.w	d1								; is next corner top left?
		bne.s	.not_top_left					; if not, branch
		move.b	#1,obAnim(a0)					; use still animation

	.not_top_left:
		cmpi.w	#8,d1							; is next corner bottom right?
		bne.s	.not_btm_right					; if not, branch
		clr.b	obAnim(a0)						; use spinning animation

	.not_btm_right:
; ---------------------------------------------------------------------------
		bsr.w	LCon_PlatformMove				; begin platform movement
		bra.w	SpinC_Solid
; ===========================================================================

SpinC_ChkDel:
		cmpi.b	#2,(v_act).w				; check if act is 3
		bne.s	.not_act3					; if not, branch
		cmpi.w	#-$80,d0					; is object to the right?
		bhs.s	SpinC_Display				; if yes, branch

	.not_act3:
		move.b	SpinCon_SpawnerType(a0),d0	; get original subtype
		bpl.s	SpinC_Delete				; branch if not the parent object
		andi.w	#$7F,d0
		lea		(v_conveyactive).w,a2
		bclr	#0,(a2,d0.w)

SpinC_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

SpinC_Solid:	; Routine 2
	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		bsr.s	SpinC_Rout2
		offscreen.s	SpinC_ChkDel,SpinCon_CenterX(a0)

SpinC_Display:	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		jmp		(DisplaySprite).l
; ===========================================================================

SpinC_Rout2:
		lea		Ani_SpinConvey(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)					; is platform on a spinning frame?
		bne.s	.spinning					; if yes, branch
		move.w	obX(a0),SpinCon_PrevX(a0)	; store pre-movement axis position
		bsr.w	SpinC_PlatformUpdate
		moveq	#$1B,d1						; width; save 4 cycles -- Filter
		moveq	#7,d2						; height (jumping); save 4 cycles -- Filter
		moveq	#8,d3						; height (walking); save 4 cycles -- Filter
		move.w	SpinCon_PrevX(a0),d4		; pre-movement axis position
		jmp		(SolidObject).l				; make platform solid on flat frame
; ===========================================================================

	.spinning:
		btst	#staSonicOnObj,obStatus(a0)	; is platform being stood on?
		beq.s	SpinC_PlatformUpdate		; if not, branch
		bclr	#staOnObj,(v_player+obStatus)
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid

; ---------------------------------------------------------------------------
; Subroutine to get next corner coordinates and update platform position
; ---------------------------------------------------------------------------

SpinC_PlatformUpdate:
	; This version does not include the switch check that triggers reversal.
	; It can easily be imported from LCon_PlatformUpdate if desired, like so:
		; tst.b	(f_switch+$E).w				; has switch $E been pressed?
		; beq.s	.noreverse					; if not, branch
		; tst.b	SpinCon_Reverse(a0)			; has this platform's movement already been reversed?
		; bne.s	.noreverse					; if yes, branch
		; move.b	#1,SpinCon_Reverse(a0)	; reverse movement of this platform
		; move.b	#1,(f_conveyrev).w		; reverse conveyor belts
		; neg.b	SpinCon_CornerInc(a0)		; negate this value to -4
		; bra.s	.resetplatforms
; ===========================================================================

;	.noreverse:
		move.w	obX(a0),d0
		cmp.w	SpinCon_TargetX(a0),d0		; has platform reached the target x-position?
		bne.s	.not_at_corner				; if not, branch to moving
		move.w	obY(a0),d0
		cmp.w	SpinCon_TargetY(a0),d0		; has platform reached the target y-position?
		bne.s	.not_at_corner				; if not, branch to moving

;	.resetplatforms:
		moveq	#0,d1
		move.b	SpinCon_CornerNext(a0),d1
		add.b	SpinCon_CornerInc(a0),d1
		cmp.b	SpinCon_CornerCount(a0),d1	; is next corner valid?
		blo.s	.is_valid					; if yes, branch
		move.b	d1,d0
		moveq	#0,d1						; reset corner counter to 0
		tst.b	d0
		bpl.s	.is_valid
		move.b	SpinCon_CornerCount(a0),d1
		subq.b	#4,d1

	.is_valid:
		move.b	d1,SpinCon_CornerNext(a0)
		movea.l	SpinCon_DataAddr(a0),a1
		move.w	(a1,d1.w),SpinCon_TargetX(a0)	; set next target x-position
		move.w	2(a1,d1.w),SpinCon_TargetY(a0)	; set next target y-position
		tst.w	d1								; is next corner top left?
		bne.s	.not_top_left					; if not, branch
		move.b	#1,obAnim(a0)					; use still animation

	.not_top_left:
		cmpi.w	#8,d1							; is next corner bottom right?
		bne.s	.not_btm_right					; if not, branch
		clr.b	obAnim(a0)						; use spinning animation

	.not_btm_right:
		bsr.w	LCon_PlatformMove				; set direction and speed

	.not_at_corner:
		jmp		(SpeedToPos).l
; ===========================================================================

SpinC_Corner_Data:		offsetTable
		offsetTableEntry.w	SpinC_Corners_0
		offsetTableEntry.w	SpinC_Corners_1
		offsetTableEntry.w	SpinC_Corners_2
		offsetTableEntry.w	SpinC_Corners_3
		offsetTableEntry.w	SpinC_Corners_4
		offsetTableEntry.w	SpinC_Corners_5
; ===========================================================================

SpinC_Corners_0:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$E80			; x center
; corners
			; x-pos,	y-pos
		dc.w	$E14, $370
		dc.w	$EEF, $302
		dc.w	$EEF, $340
		dc.w	$E14, $3AE

SpinC_Corners_1:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$F80			; x center
; corners
			; x-pos,	y-pos
		dc.w	$F14, $2E0
		dc.w	$FEF, $272
		dc.w	$FEF, $2B0
		dc.w	$F14, $31E

SpinC_Corners_2:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$1080			; x center
; corners
			; x-pos,	y-pos
		dc.w	$1014, $270
		dc.w	$10EF, $202
		dc.w	$10EF, $240
		dc.w	$1014, $2AE

SpinC_Corners_3:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$F80			; x center
; corners
			; x-pos,	y-pos
		dc.w	$F14, $570
		dc.w	$FEF, $502
		dc.w	$FEF, $540
		dc.w	$F14, $5AE

SpinC_Corners_4:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$1B80			; x center
; corners
			; x-pos,	y-pos
		dc.w	$1B14, $670
		dc.w	$1BEF, $602
		dc.w	$1BEF, $640
		dc.w	$1B14, $6AE

SpinC_Corners_5:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$1C80			; x center
; corners
			; x-pos,	y-pos
		dc.w	$1C14, $5E0
		dc.w	$1CEF, $572
		dc.w	$1CEF, $5B0
		dc.w	$1C14, $61E
; ===========================================================================