; ---------------------------------------------------------------------------
; Solid	object subroutine (includes spikes, blocks, rocks etc)
;
; input:
;	d1 = width
;	d2 = height / 2 (when jumping)
;	d3 = height / 2 (when walking)
;	d4 = x-axis position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SolidObject:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the object? -- Removed obSolid
		beq.w	Solid_ChkEnter				; if not, branch
		move.w	d1,d2
		add.w	d2,d2
		lea		(v_player).w,a1
		btst	#staAir,obStatus(a1)		; is Sonic in the air?
		bne.s	.leave						; if yes, branch
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	.leave						; if Sonic moves off the left, branch
		cmp.w	d2,d0						; has Sonic moved off the right?
		blo.s	.stand						; if not, branch

.leave:
		bclr	#staOnObj,obStatus(a1)		; clear Sonic's standing flag
		; Sonic 2 sets Sonic's in-air flag here
		bclr	#staSonicOnObj,obStatus(a0)	; clear object's standing flag -- Removed obSolid
		moveq	#0,d4
		rts	

.stand:
		move.w	d4,d2
		jsr		(MvSonicOnPtfm).l
		moveq	#0,d4
		rts	
; ===========================================================================

SolidObject71:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the object? -- Removed obSolid
		beq.w	loc_FAD0
		move.w	d1,d2
		add.w	d2,d2
		lea		(v_player).w,a1
		btst	#staAir,obStatus(a1)
		bne.s	.leave
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	.leave
		cmp.w	d2,d0
		blo.s	.stand

.leave:
		bclr	#staOnObj,obStatus(a1)		; clear Sonic's standing flag
		; Sonic 2 sets Sonic's in-air flag here
		bclr	#staSonicOnObj,obStatus(a0)	; clear object's standing flag -- Removed obSolid
		moveq	#0,d4
		rts	

.stand:
		move.w	d4,d2
		jsr		MvSonicOnPtfm	; was bsr.w
		moveq	#0,d4
		rts	
; ===========================================================================

SolidObject2F:
		lea	(v_player).w,a1
		tst.b	obRender(a0)
		bpl.w	Solid_Ignore
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Solid_Ignore
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	Solid_Ignore
		move.w	d0,d5
		btst	#0,obRender(a0)	; is object horizontally flipped?
		beq.s	.notflipped	; if not, branch
		not.w	d5
		add.w	d3,d5

.notflipped:
		lsr.w	#1,d5
		moveq	#0,d3
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		move.w	obY(a0),d5
		sub.w	d3,d5
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	Solid_Ignore
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	Solid_Ignore
		bra.w	loc_FB0E
; ===========================================================================

Solid_ChkEnter:
		tst.b	obRender(a0)
		bpl.w	Solid_Ignore

loc_FAD0:
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Solid_Ignore				; if Sonic moves off the left, branch
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0						; has Sonic moved off the right?
		bhi.w	Solid_Ignore				; if yes, branch
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3

	; Mercury Ducking Size Fix
	if SpinDashEnabled=1	; Mercury Spin Dash
		cmpi.b	#aniID_SpinDash,obAnim(a1)
		beq.s	.short
	endif	; Spin Dash End

		cmpi.b	#aniID_Duck,obAnim(a1)
		bne.s	.skip
		
.short:
		subi.w	#5,d2
		addi.w	#5,d3
		
.skip:
	; Ducking Size Fix end

		sub.w	obY(a0),d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	Solid_Ignore		; if Sonic moves above, branch
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3				; has Sonic moved below?
		bhs.w	Solid_Ignore		; if yes, branch

loc_FB0E:
		tst.b	obCtrlLock(a1)		; are object interactions disabled?
		bmi.w	Solid_Ignore		; if yes, branch
		cmpi.b	#6,obRoutine(a1)	; is Sonic dead?
		bcc.w	Solid_Debug			; if yes, branch
		tst.w	(v_debuguse).w		; is debug mode being used?
		bne.w	Solid_Debug			; if yes, branch
		move.w	d0,d5
		cmp.w	d0,d1				; is Sonic right of centre of object?
		bhs.s	.isright			; if yes, branch
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

.isright:
		move.w	d3,d1
		cmp.w	d3,d2		; is Sonic below centre of object?
		bhs.s	.isbelow	; if yes, branch

		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

.isbelow:
		cmp.w	d1,d5
		bhi.w	Solid_TopBottom	; if Sonic hits top or bottom, branch
		cmpi.w	#4,d1
		bls.s	Solid_SideAir
		tst.w	d0		; where is Sonic?
		beq.s	Solid_Centre	; if inside the object, branch
		bmi.s	Solid_Right	; if right of the object, branch
		tst.w	obVelX(a1)	; is Sonic moving left?
		bmi.s	Solid_Centre	; if yes, branch
		bra.s	Solid_Left
; ===========================================================================

Solid_Right:
		tst.w	obVelX(a1)	; is Sonic moving right?
		bpl.s	Solid_Centre	; if yes, branch

Solid_Left:
		clr.w	obInertia(a1)
		clr.w	obVelX(a1)	; stop Sonic moving

Solid_Centre:
		sub.w	d0,obX(a1)					; correct Sonic's position
		btst	#staAir,obStatus(a1)		; is Sonic in the air?
		bne.s	Solid_SideAir				; if yes, branch
		bset	#staPush,obStatus(a1)		; make Sonic push object
		bset	#staSonicPush,obStatus(a0)	; make object be pushed
		moveq	#1,d4						; return side collision
		rts	
; ===========================================================================

Solid_SideAir:
		bsr.s	Solid_NotPushing
		moveq	#1,d4		; return side collision
		rts	
; ===========================================================================

Solid_Ignore:
		btst	#staSonicPush,obStatus(a0)	; is Sonic pushing?
		beq.s	Solid_Debug					; if not, branch
		; Removed line -- Mercury Walking In Air Fix

Solid_NotPushing:
		bclr	#staSonicPush,obStatus(a0)	; clear pushing flag
		bclr	#staPush,obStatus(a1)		; clear Sonic's pushing flag

Solid_Debug:
		moveq	#0,d4		; return no collision
		rts	
; ===========================================================================

Solid_TopBottom:
		tst.w	d3		; is Sonic below the object?
		bmi.s	Solid_Below	; if yes, branch
		cmpi.w	#$10,d3		; has Sonic landed on the object?
		blo.s	Solid_Landed	; if yes, branch
		bra.s	Solid_Ignore
; ===========================================================================

Solid_Below:
		tst.w	obVelY(a1)		; is Sonic moving vertically?
		beq.s	Solid_Squash	; if not, branch
		bpl.s	Solid_TopBtmAir	; if moving downwards, branch
		tst.w	d3				; is Sonic above the object?
		bpl.s	Solid_TopBtmAir	; if yes, branch
		sub.w	d3,obY(a1)		; correct Sonic's position
		clr.w	obVelY(a1)		; stop Sonic moving

Solid_TopBtmAir:
		moveq	#-1,d4
		rts	
; ===========================================================================

Solid_Squash:
		btst	#staAir,obStatus(a1)	; is Sonic in the air?
		bne.s	Solid_TopBtmAir			; if yes, branch
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		(KillSonic).l			; kill Sonic
		movea.l	(sp)+,a0
		moveq	#-1,d4
		rts	
; ===========================================================================

Solid_Landed:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	Solid_Miss					; if Sonic is right of object, branch
		cmp.w	d2,d1						; is Sonic left of object?
		bhs.s	Solid_Miss					; if yes, branch
		tst.w	obVelY(a1)					; is Sonic moving upwards?
		bmi.s	Solid_Miss					; if yes, branch
		sub.w	d3,obY(a1)					; correct Sonic's position
		subq.w	#1,obY(a1)
		bsr.s	Solid_ResetFloor
		bset	#staSonicOnObj,obStatus(a0)	; Removed #2,obSolid(a0)
		moveq	#-1,d4						; return top/bottom collision
		rts	
; ===========================================================================

Solid_Miss:
		moveq	#0,d4
		rts	
; End of function SolidObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Solid_ResetFloor:
		btst	#staOnObj,obStatus(a1)		; is Sonic standing on something?
		beq.s	.notonobj					; if not, branch

		moveq	#0,d0
	; RetroKoH obPlatform SST mod
		movea.w	obPlatformAddr(a1),a2		; get object being stood on
		adda.l	#v_ram_start,a2				; a2 = object being stood upon
	; obPlatform SST mod end
		bclr	#staSonicOnObj,obStatus(a2)	; clear object's standing flags -- Removed obSolid

.notonobj:
		move.w	a0,obPlatformAddr(a1)		; RetroKoH obPlatform SST mod
		clr.b	obAngle(a1)					; clear Sonic's angle
		clr.w	obVelY(a1)					; stop Sonic
		move.w	obVelX(a1),obInertia(a1)
		btst	#staAir,obStatus(a1)		; is Sonic in the air?
		beq.s	.notinair					; if not, branch
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr		(Sonic_ResetOnFloor).l 		; reset Sonic as if on floor
		movea.l	(sp)+,a0

.notinair:
		bset	#staOnObj,obStatus(a1)		; set object standing flag
		bset	#staSonicOnObj,obStatus(a0)	; set Sonic standing on object flag
		rts	
; End of function Solid_ResetFloor
