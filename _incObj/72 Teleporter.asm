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

tele_movetime = objoff_2E		; timer that counts down while Sonic teleports (2 bytes)
; $30-31 are free
tele_delaytime = objoff_32		; time to wait before starting teleportation (1 byte)
tele_targetx = objoff_36		; target x-position to send Sonic to (2 bytes)
tele_targety = objoff_38		; target y-position to send Sonic to (2 bytes)
tele_passedcoords = objoff_3A	; coords Sonic's already passed through (in bytes) (1 byte)
tele_totalcoords = objoff_3B	; total number of coord pairs in this set (in bytes) (1 byte)
tele_coordaddr = objoff_3C		; address where teleporter's coordinate pairs are located (4 bytes)
; ===========================================================================

Tele_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	obSubtype(a0),d0			; get teleporter number (numbered similarly to how switches are numbered)
		add.w	d0,d0						; multiply teleporter ID by 2
		andi.w	#$1E,d0						; capped at $10 teleporters (0-$F), though only 0-7 are used in Sonic 1
		lea		Tele_Data(pc),a2
		adda.w	(a2,d0.w),a2				; a2 = data for this specific teleporter
		move.w	(a2)+,tele_passedcoords(a0)	; number of bytes in this data set (2 bytes) -- byte count stored in $39(a0). $38(a0) is cleared.
		move.l	a2,tele_coordaddr(a0)		; address of this data set (4 bytes)
		move.w	(a2)+,tele_targetx(a0)		; load next x-coordinate
		move.w	(a2)+,tele_targety(a0)		; load next y-coordinate

Tele_ChkSonic:	; Routine 2
		tst.b	(v_debuguse).w				; is debug mode active?
		bne.w	.dontTeleport				; if yes, braanch and exit
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.notflipped
		addi.w	#$F,d0

.notflipped:
		cmpi.w	#16,d0						; is Sonic within 16 pixels of the teleporter?
		bhs.s	.dontTeleport				; if not, branch and exit
		move.w	obY(a1),d1
		sub.w	obY(a0),d1
		addi.w	#$20,d1
		cmpi.w	#$40,d1						; is Sonic within the teleporter vertically?
		bhs.s	.dontTeleport				; if not, branch and exit
		tst.b	obCtrlLock(a1)				; is Sonic locked in place (possibly already teleporting)
		bne.s	.dontTeleport				; if yes, branch and exit
	
	; Teleporter #7 only works if you have 50 rings or more
		cmpi.b	#7,obSubtype(a0)			; is this teleporter #7?
		bne.s	.not7						; if not, branch ahead
		cmpi.w	#50,(v_rings).w				; does Sonic have 50 rings or more?
		blo.s	.dontTeleport				; if not, this teleporter won't work

.not7:
		addq.b	#2,obRoutine(a0)			; set to next routine, since we are using this teleporter
		move.b	#$81,obCtrlLock(a1)			; lock controls and disable object interaction
		move.b	#aniID_Roll,obAnim(a1)		; use Sonic's rolling animation
		move.w	#$800,obInertia(a1)			; set inertia to 8 (Sonic will teleport w/ this speed)
		clr.w	obVelX(a1)
		clr.w	obVelY(a1)
		bclr	#staSonicPush,obStatus(a0)
		bclr	#staPush,obStatus(a1)
		bset	#staAir,obStatus(a1)
		move.w	obX(a0),obX(a1)				; lock teleporter object's (a0) position to Sonic's (a1)
		move.w	obY(a0),obY(a1)
		clr.b	tele_delaytime(a0)			; clear delay timer
		move.w	#sfx_Roll,d0
		jsr		(PlaySound_Special).w		; play Sonic rolling sound

.dontTeleport:
		rts	
; ===========================================================================

Tele_WaitToMove:	; Routine 4
		lea		(v_player).w,a1
		move.b	tele_delaytime(a0),d0
		addq.b	#2,tele_delaytime(a0)
		jsr		(CalcSine).w				; use current delay timer value as "angle" for Sonic's hovering motion
		asr.w	#5,d0
		move.w	obY(a0),d2
		sub.w	d0,d2
		move.w	d2,obY(a1)					; apply hover effect to Sonic
		cmpi.b	#$80,tele_delaytime(a0)		; is it time to teleport?
		bne.s	.wait						; if not, branch and exit
		bsr.w	Tele_SetMovementTimer		; set movement timer to first coordinates pair
		addq.b	#2,obRoutine(a0)
		move.w	#sfx_Teleport,d0
		jsr		(PlaySound_Special).w		; play teleport sound

.wait:
		rts	
; ===========================================================================

Tele_MoveSonic:	; Routine 6
		addq.l	#4,sp
		lea		(v_player).w,a1
		subq.b	#1,tele_movetime(a0)		; decrement move timer
		bpl.s	.speedtopos					; if time remains, branch
		move.w	tele_targetx(a0),obX(a1)	; snap Sonic to the target location
		move.w	tele_targety(a0),obY(a1)
		moveq	#0,d1
		move.b	tele_passedcoords(a0),d1
		addq.b	#4,d1						; inc by 4 because we reached one set of coordinates
		cmp.b	tele_totalcoords(a0),d1		; have we reached the final set of coordinates?
		blo.s	.getNextCoords				; if not, we aren't finished teleporting. Branch.
		moveq	#0,d1
		bra.s	.finishmoving
; ===========================================================================

.getNextCoords:
		move.b	d1,tele_passedcoords(a0)	; set elapsed coords counter (we'll then use it to pull the next coord pair)
		movea.l	tele_coordaddr(a0),a2		; a2 = address of this teleporter's target coord pairs
		move.w	(a2,d1.w),tele_targetx(a0)	; set next target coordinates
		move.w	2(a2,d1.w),tele_targety(a0)
		bra.w	Tele_SetMovementTimer		; set movement timer to next coordinates pair
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
		rts
; ===========================================================================

.finishmoving:
		andi.w	#$7FF,obY(a1)				; cap y-position
		clr.b	obRoutine(a0)				; reset teleporter
		clr.b	obCtrlLock(a1)				; restore control to Sonic
		clr.w	obVelX(a1)					; clear horizontal movement
		move.w	#$200,obVelY(a1)			; apply vertical movement so Sonic can land
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Tele_SetMovementTimer:
		moveq	#0,d0
		move.w	#$1000,d2
		move.w	tele_targetx(a0),d0
		sub.w	obX(a1),d0
		bge.s	loc_16830
		neg.w	d0
		neg.w	d2

loc_16830:
		moveq	#0,d1
		move.w	#$1000,d3
		move.w	tele_targety(a0),d1
		sub.w	obY(a1),d1
		bge.s	loc_16844
		neg.w	d1
		neg.w	d3

loc_16844:
		cmp.w	d0,d1
		blo.s	loc_1687A
		moveq	#0,d1
		move.w	tele_targety(a0),d1
		sub.w	obY(a1),d1
		swap	d1
		divs.w	d3,d1
		moveq	#0,d0
		move.w	tele_targetx(a0),d0
		sub.w	obX(a1),d0
		beq.s	loc_16866
		swap	d0
		divs.w	d1,d0

loc_16866:
		move.w	d0,obVelX(a1)
		move.w	d3,obVelY(a1)
		tst.w	d1
		bpl.s	loc_16874
		neg.w	d1

loc_16874:
		move.w	d1,tele_movetime(a0)
		rts	
; ===========================================================================

loc_1687A:
		moveq	#0,d0
		move.w	tele_targetx(a0),d0
		sub.w	obX(a1),d0
		swap	d0
		divs.w	d2,d0
		moveq	#0,d1
		move.w	tele_targety(a0),d1
		sub.w	obY(a1),d1
		beq.s	loc_16898
		swap	d1
		divs.w	d0,d1

loc_16898:
		move.w	d1,obVelY(a1)
		move.w	d2,obVelX(a1)
		tst.w	d0
		bpl.s	loc_168A6
		neg.w	d0

loc_168A6:
		move.w	d0,tele_movetime(a0)
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
