; ---------------------------------------------------------------------------
; Object 6F - spinning platforms that move around a conveyor belt (SBZ)
; ---------------------------------------------------------------------------
; OST Constants (Identical to Obj63)
SpinCon_SpawnerType:	equ objoff_2F		; 1 byte  | saved subtype
SpinCon_CenterX:		equ objoff_30		; 2 bytes | approximate X-axis position of center of conveyor
SpinCon_PrevX:			equ objoff_32		; 2 bytes | previous X-axis position (used instead of pushing to the stack)
SpinCon_TargetX:		equ objoff_34		; 2 bytes | target X-axis position to move platform towards
SpinCon_TargetY:		equ objoff_36		; 2 bytes | target Y-axis position to move platform towards
SpinCon_CornerNext:		equ objoff_38		; 1 byte  | index of next corner position
SpinCon_CornerCount:	equ objoff_39		; 1 byte  | total number of corners +1, times 4
SpinCon_CornerInc:		equ objoff_3A		; 1 byte  | amount to add to corner index (4 or -4)
SpinCon_Reverse:		equ objoff_3B		; 1 byte  | 1 = conveyors run in reverse
SpinCon_DataAddr:		equ objoff_3C		; 4 bytes | address where platform's position data is located
; ---------------------------------------------------------------------------

SpinConvey:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	SpinC_Solid
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

SpinC_Main:	; Routine 0
	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		bsr.s	SpinC_Init
		offscreen.s	SpinC_ChkDel,SpinCon_CenterX(a0)	; ProjectFM

SpinC_Display:	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		jmp		(DisplaySprite).l
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

SpinC_Init:
		move.b	obSubtype(a0),d0			; is this the conveyor group spawner?
		bmi.w	SpinC_Spawner				; if yes (subtype >= $80), branch

	; Continue onward for platforms created by the spawner
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
		bra.w	SpinC_Solid						; jump down to routine 2
; ===========================================================================

SpinC_Spawner:
		move.b	d0,SpinCon_SpawnerType(a0)		; move spawner subtype to $2F(a0)
		andi.w	#$7F,d0							; clear upper-most bit of subtype to isolate platform group ID
		lea		(v_conveyactive).w,a2
		bset	#0,(a2,d0.w)					; set this group's respective bit
		beq.s	.not_set
		jmp		(DeleteObject).l				; if it was already set, delete this spawner object, as it's not needed.
; ===========================================================================

	.not_set:
		add.w	d0,d0							; multiply platform group ID by 2 (use for word AND longword pointers)
		add.w	d0,d0							; multiply platform group ID by 4 (use only for longword pointers)
		andi.w	#$1E,d0							; capped at $10 groups of platforms (0-$F)

	; RetroKoH Object Loading Optimization
		lea		(ObjPosSBZPlatform_Index).l,a2	; Next, we load the first pointer in the object layout list pointer index,
		movea.l (a2,d0.w),a2					; Changed from adda.w to movea.l for longword object layout pointers
;		adda.w	(a2,d0.w),a2					; a2 = positioning data for this platform group (use only for word-length pointers)

		move.w	(a2)+,d1						; d1 = number of platforms - 1
		movea.l	a0,a1

	; RetroKoH Mass Object Load Optimization; Built off of Spirituinsanum's Ring Loss Optimization
	; Create the first instance, then loop to create the others afterward.
	.firstPlatform:
		_move.l	#SpinConvey,obAddr(a1)
		move.w	(a2)+,obX(a1)					; set x-position
		move.w	(a2)+,obY(a1)					; set y-position
		move.w	(a2)+,d0
		move.b	d0,obSubtype(a1)				; set subtype, discarding upper byte
		subq	#1,d1							; decrement for the first platform created
		bmi.s	.endloop						; if, somehow, only one platform is needed, skip

	; Here we begin what's replacing FindFreeObj, in order to avoid resetting its d0 every time an object is created.
	; Slight improvement by Malachi
		lea		(v_lvlobjspace-object_size).w,a1
		move.w	#v_lvlobjcount,d2

	.loop:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.l	obAddr(a1)						; is object RAM	slot empty?
		dbeq	d2,.loop						; branch correction again.
		bne.s	.endloop						; we're moving this line here.

	.makePtfms:
		_move.l	#SpinConvey,obAddr(a1)
		move.w	(a2)+,obX(a1)					; set x-position
		move.w	(a2)+,obY(a1)					; set y-position
		move.w	(a2)+,d0
		move.b	d0,obSubtype(a1)				; set subtype, discarding upper byte
		dbf		d1,.loop						; repeat for number of platforms

	.endloop:
		addq.l	#4,sp
		rts	
; ===========================================================================

SpinC_Solid:	; Routine 2
	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		bsr.s	SpinC_Rout2
		offscreen.w	SpinC_ChkDel,SpinCon_CenterX(a0)
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