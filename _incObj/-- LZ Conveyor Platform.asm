; ---------------------------------------------------------------------------
; Object - platforms on a conveyor belt (LZ)
; ---------------------------------------------------------------------------

LabyrinthConvey:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LCon_Index(pc,d0.w),d1
		jsr		LCon_Index(pc,d1.w)
		out_of_range.s	LCon_Delete,LCon_CenterX(a0)	; PFM S3K OBJ

LCon_Display:
		jmp		DisplaySprite
; ===========================================================================

LCon_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

LCon_Index:	offsetTable
		offsetTableEntry.w LCon_Main
		offsetTableEntry.w LCon_Platform
		offsetTableEntry.w LCon_OnPlatform
; ===========================================================================

LCon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_LConv,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Conveyor_Ptfm,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

	; Conveyor Wheel is now part of the Scenery Object (Obj1C)

		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get platform subtype assigned by spawner (based on 3rd word in ObjPosLZPlatform_Index)
		move.w	d0,d1						; copy to d1
		lsr.w	#3,d0						; d0 = (platform subtype // 8) floor division. Result will be an even number (0, 2, 4, etc.)
		andi.w	#$1E,d0						; cap d0 to $1E (no odd values) -- Only 0-$A is used
		lea		LCon_Corner_Data(pc),a2
		adda.w	(a2,d0.w),a2				; load corner data based on the platform subtype
		move.w	(a2)+,LCon_CornerNext(a0)	; CornerNext and CornerCount
		move.w	(a2)+,LCon_CenterX(a0)
		move.l	a2,LCon_DataAddr(a0)		; pointer to corner x/y values
		andi.w	#$F,d1						; read low nybble of subtype
		lsl.w	#2,d1						; multiply by 4
		move.b	d1,LCon_CornerNext(a0)		; index of next corner
		move.b	#4,LCon_CornerInc(a0)
		tst.b	(f_conveyrev).w				; have conveyors been reversed?
		beq.s	.no_reverse					; if not, branch

		move.b	#1,LCon_Reverse(a0)			; set platform's local reverse flag
		neg.b	LCon_CornerInc(a0)			; negate this value to -4
		moveq	#0,d1
		move.b	LCon_CornerNext(a0),d1
		add.b	LCon_CornerInc(a0),d1
		cmp.b	LCon_CornerCount(a0),d1		; is next corner valid?
		blo.s	.is_valid					; if yes, branch
		move.b	d1,d0
		moveq	#0,d1						; reset corner counter to 0
		tst.b	d0
		bpl.s	.is_valid
		move.b	LCon_CornerCount(a0),d1
		subq.b	#4,d1

	.is_valid:
		move.b	d1,LCon_CornerNext(a0)		; update corner counter

	.no_reverse:
		move.w	(a2,d1.w),LCon_TargetX(a0)	; set target x-position
		move.w	2(a2,d1.w),LCon_TargetY(a0)	; set target y-position
		bsr.w	LCon_PlatformMove			; begin platform movement
; ---------------------------------------------------------------------------

LCon_Platform:	; Routine 2
		moveq	#0,d1
		move.b	obDispWid(a0),d1			; width
		jsr		(PlatformObject).l			; goto LCon_OnPlatform next if Sonic stands on platform
		bra.w	LCon_PlatformUpdate
; ===========================================================================

LCon_OnPlatform:	; Routine 4
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		jsr		(ExitPlatform).l
		move.w	obX(a0),-(sp)
		bsr.w	LCon_PlatformUpdate
		move.w	(sp)+,d2
		jmp		(MvSonicOnPtfm2).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to get next corner coordinates and update platform position
; ---------------------------------------------------------------------------

LCon_PlatformUpdate:
		tst.b	(f_switch+$E).w			; has switch $E been pressed?
		beq.s	.noreverse				; if not, branch
		tst.b	LCon_Reverse(a0)		; has this platform's movement already been reversed?
		bne.s	.noreverse				; if yes, branch
		move.b	#1,LCon_Reverse(a0)		; reverse movement of this platform
		move.b	#1,(f_conveyrev).w		; reverse conveyor belts
		neg.b	LCon_CornerInc(a0)		; negate this value to -4
		bra.s	.resetplatforms
; ===========================================================================

	.noreverse:
		move.w	obX(a0),d0
		cmp.w	LCon_TargetX(a0),d0		; has platform reached the target x-position?
		bne.s	.apply_speed			; if not, branch to moving
		move.w	obY(a0),d0
		cmp.w	LCon_TargetY(a0),d0		; has platform reached the target y-position?
		bne.s	.apply_speed			; if not, branch to moving

	.resetplatforms:
		moveq	#0,d1
		move.b	LCon_CornerNext(a0),d1
		add.b	LCon_CornerInc(a0),d1
		cmp.b	LCon_CornerCount(a0),d1		; is next corner valid?
		blo.s	.set_target_pos				; if yes, branch
		move.b	d1,d0
		moveq	#0,d1						; reset corner counter to 0
		tst.b	d0
		bpl.s	.set_target_pos
		move.b	LCon_CornerCount(a0),d1
		subq.b	#4,d1

	.set_target_pos:
		move.b	d1,LCon_CornerNext(a0)
		movea.l	LCon_DataAddr(a0),a1
		move.w	(a1,d1.w),LCon_TargetX(a0)	; set next target x-position
		move.w	2(a1,d1.w),LCon_TargetY(a0)	; set next target y-position
		bsr.w	LCon_PlatformMove

	.apply_speed:
		jmp		(SpeedToPos).l
; End of function LCon_PlatformUpdate
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to set direction and speed of platform
; ---------------------------------------------------------------------------

; LCon_ChangeDir:
LCon_PlatformMove:
		moveq	#0,d0
		move.w	#-$100,d2
		move.w	obX(a0),d0
		sub.w	LCon_TargetX(a0),d0		; d0 = x distance between platform & corner
		bcc.s	.is_right				; branch if positive (platform is right of corner)
		neg.w	d0						; make d0 positive
		neg.w	d2						; d2 = $100

	.is_right:
		moveq	#0,d1
		move.w	#-$100,d3
		move.w	obY(a0),d1
		sub.w	LCon_TargetY(a0),d1		; d1 = y distance between platform & corner
		bcc.s	.is_below				; branch if +ve (platform is below corner)
		neg.w	d1						; make d1 positive
		neg.w	d3						; d3 = $100

	.is_below:
		cmp.w	d0,d1					; is platform nearer corner on y axis?
		blo.s	.nearer_y				; if yes, branch
		move.w	obX(a0),d0
		sub.w	LCon_TargetX(a0),d0		; d0 = x distance between platform & corner
		beq.s	.match_x				; branch if 0
		ext.l	d0
		asl.l	#8,d0					; multiply by $100
		divs.w	d1,d0					; divide by y distance
		neg.w	d0

	.match_x:
		move.w	d0,obVelX(a0)
		move.w	d3,obVelY(a0)
		swap	d0
		move.w	d0,obXSub(a0)
		clr.w	obYSub(a0)
		rts	
; ===========================================================================

	.nearer_y:
		move.w	obY(a0),d1
		sub.w	LCon_TargetY(a0),d1
		beq.s	.match_y
		ext.l	d1
		asl.l	#8,d1
		divs.w	d0,d1
		neg.w	d1

	.match_y:
		move.w	d1,obVelY(a0)
		move.w	d2,obVelX(a0)
		swap	d1
		move.w	d1,obYSub(a0)
		clr.w	obXSub(a0)
		rts	
; End of function LCon_PlatformMove
; ===========================================================================

LCon_Corner_Data:	offsetTable
		offsetTableEntry.w	LCon_Corners_LZ1_1
		offsetTableEntry.w	LCon_Corners_LZ1_2
		offsetTableEntry.w	LCon_Corners_LZ2_1
		offsetTableEntry.w	LCon_Corners_LZ2_2
		offsetTableEntry.w	LCon_Corners_LZ3_1
		offsetTableEntry.w	LCon_Corners_LZ3_2

LCon_Corners_LZ1_1:
		dc.w	$18				; # of corners (in bytes)
		dc.w	$1070			; x center
; corners
			; x-pos,	y-pos
		dc.w	$1078,	$21A
		dc.w	$10BE,	$260
		dc.w	$10BE,	$393
		dc.w	$108C,	$3C5
		dc.w	$1022,	$390
		dc.w	$1022,	$244

LCon_Corners_LZ1_2:
		dc.w	$14				; # of corners (in bytes)
		dc.w	$1280			; x center
; corners
			; x-pos,	y-pos
		dc.w	$127E,	$280
		dc.w	$12CE,	$2D0
		dc.w	$12CE,	$46E
		dc.w	$1232,	$420
		dc.w	$1232,	$2CC

LCon_Corners_LZ2_1:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$D68			; x center
; corners
			; x-pos,	y-pos
		dc.w	$D22,	$482
		dc.w	$D22,	$5DE
		dc.w	$DAE,	$5DE
		dc.w	$DAE,	$482

LCon_Corners_LZ2_2:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$DA0			; x center
; corners
			; x-pos,	y-pos
		dc.w	$D62,	$3A2
		dc.w	$DEE,	$3A2
		dc.w	$DEE,	$4DE
		dc.w	$D62,	$4DE

LCon_Corners_LZ3_1:
		dc.w	$14				; # of corners (in bytes)
		dc.w	$D00			; x center
; corners
			; x-pos,	y-pos
		dc.w	$CAC,	$242
		dc.w	$DDE,	$242
		dc.w	$DDE,	$3DE
		dc.w	$C52,	$3DE
		dc.w	$C52,	$29C

LCon_Corners_LZ3_2:
		dc.w	$10				; # of corners (in bytes)
		dc.w	$1300			; x center
; corners
			; x-pos,	y-pos
		dc.w	$1252,	$20A
		dc.w	$13DE,	$20A
		dc.w	$13DE,	$2BE
		dc.w	$1252,	$2BE
; ===========================================================================