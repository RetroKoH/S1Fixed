; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

obMon_Falling:	equ ob2ndRout		; named OST for clarity

	if ShieldsMode
monLastID: = $C+RandomMonitors
	else
monLastID: = 9+RandomMonitors
	endif

Monitor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp		Mon_Index(pc,d1.w)
; ===========================================================================

Mon_Index:		offsetTable
		offsetTableEntry.w Mon_Main
		offsetTableEntry.w Mon_ChkFall
		offsetTableEntry.w Mon_BreakOpen
		offsetTableEntry.w Mon_Animate
		offsetTableEntry.w Mon_Display
; ===========================================================================

Mon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$E0E,obHeight(a0)			; Height and Width
		move.l	#Map_Monitor,obMap(a0)
		move.w	#make_art_tile(ArtTile_Monitor,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$F,obDispWid(a0)

	; ProjectFM S3K Objects Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		movea.w	d0,a2						; load address into a2
		;bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)						; has monitor been broken?
	; S3K Objects Manager End

		beq.s	.notbroken					; if not, branch
		move.b	#8,obRoutine(a0)			; run "Mon_Display" routine
		move.b	#monLastID+2-RandomMonitors,obFrame(a0)	; use broken monitor frame
		rts	
; ===========================================================================

	.notbroken:
		move.b	#(colPowerup|colSz_16x16),obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)
	if RandomMonitors
		move.b	#monLastID-1,obAnim(a0)		; use '?' icon
	endif

Mon_ChkFall:	; Routine 2

	if ShieldsMode=1	; RetroKoH Scaling Shields
		move.b	obSubtype(a0),d0
		cmpi.b	#7,d0
		blt.s	.skipcheck				; branch if type < 7 (flame shield)
		cmpi.b	#9,d0
		bgt.s	.skipcheck				; branch if type > 9 (electric shield)

	; if we reached this point, this is an elemental shield...
		move.b	obSubtype(a0),d0
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have a shield?
		bne.s	.setAnim								; if yes, don't change it.
		move.b	#4,d0									; reset to blue shield.
	
	.setAnim:
		bsr.w	NewAnim

	.skipcheck:
	endif	; Scaling Shields End

		tst.b	obMon_Falling(a0)		; is monitor set to fall?
		beq.s	.collide				; if not, branch
	; only when secondary routine isn't 0, make monitor fall
		bsr.w	ObjectFall_YOnly
		jsr		(ObjFloorDist).l
		tst.w	d1						; is monitor in the ground?
		bpl.s	.collide				; if not, branch
		add.w	d1,obY(a0)				; move monitor out of the ground
		clr.w	obVelY(a0)
		clr.b	obMon_Falling(a0)		; stop monitor from falling

	.collide:
		bsr.s	Mon_Solid				; collide even while the monitor is moving

Mon_Animate:	; Routine 6
		lea		Ani_Monitor(pc),a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
		bra.w	RememberState			; ProjectFM S3K Objects Manager
; ===========================================================================
	
Mon_Solid:
		move.w	#$1A,d1					; monitor's width
		move.w	#$F,d2					; monitor's height
		move.w	d2,d3
		addq.w	#1,d3					; height + 1
		move.w	obX(a0),d4				; monitor's x_pos
		lea		(v_player).w,a1
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the monitor?
		beq.s	Mon_SolidSides			; if no, branch
	; Extra rider checks not necessary for right now

	.checkOverEdge:
		move.w	d1,d2
		add.w	d2,d2					; d2 = wider standing range
		btst	#staAir,obStatus(a1)	; is Sonic in the air?
		bne.s	Mon_ClearRider			; if yes, branch
	; check, if character is standing on
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0					; add monitor width
		bmi.s	Mon_ClearRider			; branch, if Sonic is behind the left edge of the monitor
		cmp.w	d2,d0
		blo.s	Mon_StandOn				; branch, if character is not beyond the right edge of the monitor

Mon_ClearRider:
		bclr	#staSonicOnObj,obStatus(a0)	; clear 'on object' bit
		beq.s	.return
		cmpa.w	obPlatformAddr(a1),a0		; is Sonic on this object?
		bne.s	.return						; if not, branch
		clr.w	obPlatformAddr(a1)
		bclr	#staOnObj,obStatus(a1)		; clear Sonic's 'standing on' bit
		beq.s	.return
		bset	#staAir,obStatus(a1)		; set Sonic's 'in air' bit

	.return:
		rts
; ===========================================================================

Mon_StandOn:
		move.w	d4,d2
		jsr		(MvSonicOnPtfm).l
		moveq	#0,d4
		rts
; ===========================================================================

Mon_SolidSides:
		cmpi.b	#aniID_Roll,obAnim(a1)	; is Sonic spinning?
		beq.w	Solid_Ignore			; if yes, branch
	if DropDashEnabled
		cmpi.b	#aniID_DropDash,obAnim(a1)
		beq.w	Solid_Ignore
	endif
; ---------------------------------------------------------------------------

; SolidObject_cont: in s2disasm
		move.w	obX(a1),d0			; load Sonic's X position...
		sub.w	obX(a0),d0			; ...and calculate his x position relative to the object.
		add.w	d1,d0				; Put object's left edge at (0,0). This is also Sonic's distance to the object's left edge.
		bmi.w	Solid_Ignore		; Branch if Sonic is outside the object's left edge
		move.w	d1,d3
		add.w	d3,d3				; Calculate object's width.
		cmp.w	d3,d0
		bhi.w	Solid_Ignore		; Branch if Sonic is outside the object's right edge
		move.b	obHeight(a1),d3		; load Sonic's Y radius
		ext.w	d3
		add.w	d3,d2				; Calculate maximum distance for a top collision
		move.w	obY(a1),d3			; load Sonic's y position...
		sub.w	obY(a0),d3			; ...and calculate his y position relative to the object
		addq.w	#4,d3
		add.w	d2,d3				; Make the highest position where Sonic would still be colliding with the object (0,0)
		bmi.w	Solid_Ignore		; Branch if Sonic is above this point
;		andi.w	#$7FF,d3			; dummied out for now. Related to y-boundary
		move.w	d2,d4	; < extra move (s2)
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	Solid_Ignore		; Branch if Sonic is below this point

		tst.b	obCtrlLock(a1)		; are object interactions disabled?
		bmi.w	Solid_Ignore		; if yes, branch
		cmpi.b	#6,obRoutine(a1)	; is Sonic dead?
		bhs.w	Solid_Debug			; if yes, branch
		tst.w	(v_debuguse).w		; is debug mode being used?
		bne.w	Solid_Debug			; if yes, branch
		move.w	d0,d5	; < extra move (s2)
		cmp.w	d0,d1
		bhs.s	.toTheLeft			; Branch if Sonic is to the object's left

;	.toTheRight:
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5				; calc Sonic's distance to the object's right edge...
		neg.w	d5					; ...and calculate the absolute value

	.toTheLeft:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	.isAbove

;	.isBelow:
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

	.isAbove:
	; Now...
	; 'd0' contains Sonic's distance to the nearest object horizontal edge.
	; 'd5' contains the absolute version of 'd0'.
	; 'd3' contains Sonic's distance to the nearest object vertical edge.
	; 'd1' contains the absolute version of 'd3'.
		cmp.w	d1,d5
		bhi.w	.topBottom

	.side:
		cmpi.w	#4,d1				; let Sonic pass shallow corners
		bls.w	Solid_NotPushing
		tst.w	d0					; where is Sonic?
		beq.s	.alignX				; if at the object's edge, branch
		bmi.s	.onRight			; if in the right side of the object, branch
		tst.w	obVelX(a1)			; is Sonic moving left?
		bmi.s	.alignX				; if yes, branch
		bra.s	.stopX
; ===========================================================================

	.onRight:
		tst.w	obVelX(a1)			; is Sonic moving right?
		bpl.s	.alignX				; if yes, branch

	.stopX:
		clr.w	obInertia(a1)
		clr.w	obVelX(a1)			; stop Sonic moving

	.alignX:
		sub.w	d0,obX(a1)					; correct Sonic's position
		btst	#staAir,obStatus(a1)		; is Sonic in the air?
		bne.w	Solid_NotPushing			; if yes, branch
		bset	#staPush,obStatus(a1)		; make object be pushed
		bset	#staSonicPush,obStatus(a0)	; make Sonic push object
		rts
; ===========================================================================

	.topBottom:
		tst.w	d3					; is Sonic below the object?
		bmi.s	.bottom				; if yes, branch
;	.top:
		cmpi.w	#$10,d3				; has Sonic landed on the object?
		bhs.w	Solid_Ignore		; if not, branch
		bsr.w	Solid_Landed
		lea		(v_player).w,a1		; reset a1 in case of Drop Dash during floor reset
		btst	#staAir,obStatus(a1)	; did a Bubble Bounce happen?
		bne.w	Mon_ClearRider		; if yes, branch
		rts
	
	.bottom:
		tst.w	obVelY(a1)			; is Sonic moving vertically?
		beq.s	.stationaryBelow	; if not, branch
		bpl.s	.return				; if moving downwards, branch
		sub.w	d3,obY(a1)
		clr.w	obVelY(a1)

	.return:
		rts
	
	.stationaryBelow:
		btst	#staAir,obStatus(a1)
		bne.s	.return
		bra.s	.side
; ===========================================================================

Mon_BreakOpen:	; Routine 4
	; Added measures in case Sonic rolls while on a monitor and breaks it
		lea		(v_player).w,a1
		bsr.w	Mon_ClearRider
		bclr	#staSonicPush,obStatus(a0)
		beq.s	.spawnPowerup
		bclr	#staPush,obStatus(a1)
		btst	#staOnObj,obStatus(a1)	; is Sonic standing on another object?
		bne.s	.spawnPowerup
		bset	#staAir,obStatus(a1)

	.spawnPowerup:
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		clr.b	obMon_Falling(a0)
		bsr.w	FindFreeObj
		bne.s	.fail						; if we can't load a powerup, skip trying to load an explosion
		_move.l	#PowerUp,obAddr(a1)			; load monitor contents object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		moveq	#$7F,d1
		and.b	obAnim(a0),d1
		move.b	d1,obAnim(a1)				; set powerup's type properly (TO-DO: Change Obj2E to not use obAnim here)

	; REMOVE FindFreeObj. We can pick up with a1 and d0 where we left off
		tst.b	d0							; have we already checked all object RAM?
		ble.s	.fail						; if yes, skip making an explosion
		lea		object_size(a1),a1			; go to the next object space

	.loop:
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		beq.s	.explode					; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		object_size(a1),a1
		dbf		d0,.loop					; Branch correction again.
		bne.s	.fail						; We're moving this line here.

	.explode:
		_move.l	#ExItem_Main,obAddr(a1)		; load explosion object, but no animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

	.fail:
	; ProjectFM S3K Objects Manager
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		movea.w	d0,a2						; load address into a2
		bset	#0,(a2)
	; S3K Objects Manager End

		move.b	#monLastID,obAnim(a0)		; set monitor type to broken
		bra.w	DisplaySprite
; ===========================================================================
