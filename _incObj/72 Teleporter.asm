; ---------------------------------------------------------------------------
; Object 72 - teleporter (SBZ)
; ---------------------------------------------------------------------------

Teleport:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Tele_Index(pc,d0.w),d1
		jsr		Tele_Index(pc,d1.w)
		offscreen.s	.delete
		rts	

.delete:
		jmp	(DeleteObject).l
; ===========================================================================
Tele_Index:		offsetTable
		offsetTableEntry.w	Tele_Main
		offsetTableEntry.w	Tele_ChkSonic
		offsetTableEntry.w	Tele_WaitToMove
		offsetTableEntry.w	Tele_MoveSonic
; ===========================================================================

Tele_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> Tele_Action
		move.b	obSubtype(a0),d0				; get teleporter number (numbered similarly to how switches are numbered)
		add.w	d0,d0							; multiply teleporter ID by 2
		andi.w	#$1E,d0							; capped at $10 teleporters (0-$F), though only 0-7 are used in Sonic 1
		lea		Tele_Data(pc),a2
		adda.w	(a2,d0.w),a2					; a2 = data for this specific teleporter
		move.w	(a2)+,obTele_PassedCoords(a0)	; number of bytes in this data set (2 bytes) -- byte count stored in $39(a0). $38(a0) is cleared.
		move.l	a2,obTele_CoordPtr(a0)			; address of this data set (4 bytes)
		move.l	(a2)+,obTele_TargetX(a0)		; load next x/y-coordinates

Tele_ChkSonic:	; Routine 2
		tst.b	(v_debuguse).w					; is debug mode active?
		bne.w	.do_nothing						; if yes, braanch and exit
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.not_flipped
		addi.w	#$F,d0

	.not_flipped:
		cmpi.w	#16,d0						; is Sonic within 16 pixels of the teleporter?
		bhs.s	.do_nothing					; if not, branch and exit
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		addi.w	#$20,d1
		cmpi.w	#64,d1						; is Sonic within 64 pixels of the teleporter vertically?
		bhs.s	.do_nothing					; if not, branch and exit
		tst.b	obCtrlLock(a1)				; is Sonic locked in place (possibly already teleporting)
		bne.s	.do_nothing					; if yes, branch and exit
	
	; Teleporter #7 only works if you have 50 rings or more
		cmpi.b	#7,obSubtype(a0)			; is this teleporter #7?
		bne.s	.not7						; if not, branch ahead
		cmpi.w	#50,(v_rings).w				; does Sonic have 50 rings or more?
		blo.s	.do_nothing					; if not, this teleporter won't work

	.not7:
		addq.b	#2,obRoutine(a0)			; move to Tele_WaitToMove, since we are using this teleporter
		move.b	#$81,obCtrlLock(a1)			; lock controls and disable object interaction
		move.b	#aniID_Roll,obAnim(a1)		; use Sonic's rolling animation
		move.w	#$800,obInertia(a1)			; set inertia to 8 (Sonic will teleport w/ this speed)
		clr.l	obVelX(a1)					; clear X and Y speeds
		bclr	#staSonicPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)
		bset	#staAir,obStatus(a1)
		move.w	obX(a0),obX(a1)				; lock teleporter object's (a0) position to Sonic's (a1)
		move.w	obY(a0),obY(a1)
		clr.b	obTele_DelayTime(a0)		; clear delay timer
		move.w	#sfx_Roll,d0
		jsr		(QueueSound2).w				; play Sonic rolling sound

	.do_nothing:
		rts	
; ===========================================================================

Tele_WaitToMove:	; Routine 4
		lea		(v_player).w,a1
		move.b	obTele_DelayTime(a0),d0
		addq.b	#2,obTele_DelayTime(a0)
		jsr		(CalcSine).w					; use current delay timer value as "angle" for Sonic's hovering motion
		asr.w	#5,d0
		move.w	obY(a0),d2
		sub.w	d0,d2
		move.w	d2,obY(a1)						; apply hover effect to Sonic
		cmpi.b	#$80,obTele_DelayTime(a0)		; is it time to teleport?
		bne.s	.wait							; if not, branch and exit

		bsr.w	Tele_SetMovementTimer			; set speed/direction
		addq.b	#2,obRoutine(a0)				; goto Tele_MoveSonic next
		move.w	#sfx_Teleport,d0
		jsr		(QueueSound2).w					; play teleport sound

	.wait:
		rts	
; ===========================================================================

Tele_MoveSonic:	; Routine 6
		addq.l	#4,sp
		lea		(v_player).w,a1
		subq.b	#1,obTele_MoveTime(a0)			; decrement move timer
		bpl.s	.speedtopos						; if time remains, branch
		move.w	obTele_TargetX(a0),obX(a1)		; snap Sonic to the target location
		move.w	obTele_TargetY(a0),obY(a1)
		moveq	#0,d1
		move.b	obTele_PassedCoords(a0),d1
		addq.b	#4,d1							; inc by 4 because we reached one set of coordinates
		cmp.b	obTele_TotalCoords(a0),d1		; have we reached the final set of coordinates?
		blo.s	.getNextCoords					; if not, we aren't finished teleporting. Branch.
		moveq	#0,d1
		bra.s	.destination
; ===========================================================================

	.getNextCoords:
		move.b	d1,obTele_PassedCoords(a0)		; set elapsed coords counter (we'll then use it to pull the next coord pair)
		movea.l	obTele_CoordPtr(a0),a2			; a2 = address of this teleporter's target coord pairs
		move.w	(a2,d1.w),obTele_TargetX(a0)	; set next target coordinates
		move.w	2(a2,d1.w),obTele_TargetY(a0)
		bra.w	Tele_SetMovementTimer			; set movement timer to next coordinates pair
; ===========================================================================

; Literally a carbon copy of SpeedToPos (except player is a1 instead of a0)
; We can optimize it in an identical manner to how RHS/DeltaW optimized SpeedToPos.
	.speedtopos:
	; RHS/DeltaW Optimized Object Movement
		movem.w	obVelX(a1),d0/d2	; load horizontal speed (d0) and vertical speed (d2)
		lsl.l	#8,d0				; multiply by $100 (combine ext and asl to become lsl)
		add.l	d0,obX(a1)			; apply to x-axis position
		lsl.l	#8,d2				; multiply by $100 (combine ext and asl to become lsl)
		add.l	d2,obY(a1)			; apply to y-axis position

	; RetroKoH Move Shields with Sonic
; NOTE: I don't apply this to invincibiliity for two reasons:
; 1. It'd be a bit too complicated to apply to the main position, AND all of its subsprites.
; 2. With the trailing effect, it's not any sort of noticeable issue to have it lag behind slightly.
		lea		(v_shieldobj).w,a2
		tst.b	obID(a2)
		beq.s	.noShield
		move.w	obX(a1),obX(a2)
		move.w	obY(a1),obY(a2)
	; Move Shields with Sonic End

	.noShield:
		rts
; ===========================================================================

	.destination:
		andi.w	#$7FF,obY(a1)				; wrap y-position
		moveq	#0,d0
		move.b	d0,obRoutine(a0)			; reset teleporter
		move.b	d0,obCtrlLock(a1)			; restore control to Sonic
		move.w	d0,obVelX(a1)				; clear horizontal movement
		move.w	#$200,obVelY(a1)			; apply vertical movement so Sonic can land
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to set Sonic's speed & direction in a teleport pipe
; ---------------------------------------------------------------------------

Tele_SetMovementTimer:
		moveq	#0,d0
		move.w	#$1000,d2
		move.w	obTele_TargetX(a0),d0
		sub.w	obX(a1),d0			; d0 = x distance between Sonic and next target (negative if Sonic is to the right)
		bge.s	.sonic_is_left		; branch if positive
		neg.w	d0
		neg.w	d2

	.sonic_is_left:
		moveq	#0,d1
		move.w	#$1000,d3
		move.w	obTele_TargetY(a0),d1
		sub.w	obY(a1),d1			; d1 = y distance between Sonic and next target (negative if Sonic is below)
		bge.s	.sonic_is_above		; branch if positive
		neg.w	d1
		neg.w	d3

	.sonic_is_above:
		cmp.w	d0,d1				; is x distance > y distance?
		bcs.s	Tele_Move_X			; if yes, branch
; ---------------------------------------------------------------------------

; Tele_Move_X:
		moveq	#0,d1
		move.w	obTele_TargetY(a0),d1
		sub.w	obY(a1),d1			; d1 = y distance between Sonic and next target (negative if Sonic is below)
		swap	d1					; move into high word
		divs.w	d3,d1				; divide by $1000 or -$1000
		moveq	#0,d0
		move.w	obTele_TargetX(a0),d0
		sub.w	obX(a1),d0			; d0 = x distance between Sonic and next target (negative if Sonic is to the right)
		beq.s	.x_match			; branch if 0
		swap	d0					; move into high word
		divs.w	d1,d0				; divide by d1

	.x_match:
		move.w	d0,obVelX(a1)
		move.w	d3,obVelY(a1)
		tst.w	d1
		bpl.s	.positive
		neg.w	d1						; if negative, get absolute value

	.positive:
		move.w	d1,obTele_MoveTime(a0)	; set travel time for current direction
		rts	
; ===========================================================================

Tele_Move_X:
		moveq	#0,d0
		move.w	obTele_TargetX(a0),d0
		sub.w	obX(a1),d0
		swap	d0						; move into high word
		divs.w	d2,d0
		moveq	#0,d1
		move.w	obTele_TargetY(a0),d1
		sub.w	obY(a1),d1
		beq.s	.y_match				; branch if 0
		swap	d1						; move into high word
		divs.w	d0,d1					; divide by d0

	.y_match:
		move.w	d1,obVelY(a1)
		move.w	d2,obVelX(a1)
		tst.w	d0
		bpl.s	.positive
		neg.w	d0						; if negative, get absolute value

	.positive:
		move.w	d0,obTele_MoveTime(a0)	; set travel time for current direction
		rts	
; End of function Tele_SetMovementTimer

; ===========================================================================
Tele_Data:		offsetTable
		offsetTableEntry.w	Teleporter00
		offsetTableEntry.w	Teleporter01
		offsetTableEntry.w	Teleporter02
		offsetTableEntry.w	Teleporter03
		offsetTableEntry.w	Teleporter04
		offsetTableEntry.w	Teleporter05
		offsetTableEntry.w	Teleporter06
		offsetTableEntry.w	Teleporter07
; ===========================================================================

; These data tables work in the following format.
; The first word gives the length of the teleporter's data in # of bytes.
; Every following word-length value is a pair, noting target coordinates.

teleCoordTable:	macro {INTLABEL}
__LABEL__ label *
	dc.w	(__LABEL___End - __LABEL___Begin)
__LABEL___Begin label *
	endm

teleCoords:	macro xpos,ypos
	dc.w	xpos, ypos
	endm

Teleporter00:	teleCoordTable
		teleCoords	$794, $98C
Teleporter00_End

Teleporter01:	teleCoordTable
		teleCoords	$94, $38C
Teleporter01_End

Teleporter02:	teleCoordTable
		teleCoords	$794, $2E8
		teleCoords	$7A4, $2C0
		teleCoords	$7D0, $2AC
		teleCoords	$858, $2AC
		teleCoords	$884, $298
		teleCoords	$894, $270
		teleCoords	$894, $190
Teleporter02_End

Teleporter03:	teleCoordTable
		teleCoords	$894, $690
Teleporter03_End

Teleporter04:	teleCoordTable
		teleCoords	$1194, $470
		teleCoords	$1184, $498
		teleCoords	$1158, $4AC
		teleCoords	$FD0, $4AC
		teleCoords	$FA4, $4C0
		teleCoords	$F94, $4E8
		teleCoords	$F94, $590
Teleporter04_End

Teleporter05:	teleCoordTable
		teleCoords	$1294, $490
Teleporter05_End

Teleporter06:	teleCoordTable
		teleCoords	$1594, $FFE8
		teleCoords	$1584, $FFC0
		teleCoords	$1560, $FFAC
		teleCoords	$14D0, $FFAC
		teleCoords	$14A4, $FF98
		teleCoords	$1494, $FF70
		teleCoords	$1494, $FD90
Teleporter06_End

Teleporter07:	teleCoordTable
		teleCoords	$894, $90
Teleporter07_End
