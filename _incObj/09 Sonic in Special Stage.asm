; ---------------------------------------------------------------------------
; Object 09 - Sonic (special stage)
; ---------------------------------------------------------------------------

SonicSpecial:
		tst.w	(v_debuguse).w	; is debug mode	being used?
		beq.s	Obj09_Normal	; if not, branch
		bsr.w	SS_FixCamera
		bra.w	DebugMode
; ===========================================================================

Obj09_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj09_Index(pc,d0.w),d1
		jmp		Obj09_Index(pc,d1.w)
; ===========================================================================
Obj09_Index:	offsetTable
		offsetTableEntry.w	Obj09_Main
		offsetTableEntry.w	Obj09_ChkDebug
		offsetTableEntry.w	Obj09_ExitStage
		offsetTableEntry.w	Obj09_Exit2
; ===========================================================================

Obj09_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#aniID_Roll,obAnim(a0)
		bset	#staSpin,obStatus(a0)
		bset	#staAir,obStatus(a0)

Obj09_ChkDebug:	; Routine 2
		tst.w	(f_debugmode).w			; is debug mode	cheat enabled?
		beq.s	Obj09_NoDebug			; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Obj09_NoDebug			; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring

Obj09_NoDebug:
		clr.b	objoff_30(a0)
	; LavaGaming/RetroKoH Object Routine Optimization
		btst	#staAir,obStatus(a0)	; Use current air state to determine Control Mode
		bne.s	Obj09_InAir
	; Object Routine Optimization End

Obj09_OnWall:
		bclr	#staSSJump,obStatus(a0)	; clear "Sonic has jumped" flag -- Mercury Fixed SS Jumping Physics
		bsr.w	Obj09_Jump
		bsr.w	Obj09_Move
		bsr.w	Obj09_Fall
		bra.s	Obj09_Display
; ===========================================================================

Obj09_InAir:
		bsr.w	Obj09_JumpHeight	; Mercury Fixed SS Jumping Physics
		bsr.w	Obj09_Move
		bsr.w	Obj09_Fall

Obj09_Display:
		bsr.w	Obj09_ChkItems_Nonsolid
		bsr.w	Obj09_ChkItems_Solid
		jsr		(SpeedToPos).l
		bsr.w	SS_FixCamera

	if S4SpecialStages=0
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0
		move.w	d0,(v_ssangle).w
	endif

		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		jmp		(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	move Sonic in the Special Stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Obj09_Move:
		btst	#bitL,(v_jpadhold2).w	; is left being pressed?
		beq.s	Obj09_ChkRight			; if not, branch
		bsr.w	Obj09_MoveLeft

Obj09_ChkRight:
		btst	#bitR,(v_jpadhold2).w	; is right being pressed?
		beq.s	loc_1BA78				; if not, branch
		bsr.w	Obj09_MoveRight

loc_1BA78:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0			; is left/right being pressed?
		bne.s	loc_1BAA8				; if yes, branch
	; Apply friction
		move.w	obInertia(a0),d0
		beq.s	loc_1BAA8				; if inertia == 0
		bmi.s	loc_1BA9A				; if inertia < 0
		subi.w	#$C,d0					; decelerate
		bcc.s	loc_1BA94
		clr.w	d0						; clear to 0 if negative following deceleration

loc_1BA94:
		move.w	d0,obInertia(a0)		; apply change to inertia
		bra.s	loc_1BAA8
; ===========================================================================

loc_1BA9A:
		addi.w	#$C,d0					; decelerate
		bcc.s	loc_1BAA4
		clr.w	d0						; clear to 0 if negative following deceleration

loc_1BAA4:
		move.w	d0,obInertia(a0)		; apply change to inertia

loc_1BAA8:
		move.b	(v_ssangle).w,d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		neg.b	d0
		jsr		(CalcSine).l
		muls.w	obInertia(a0),d1
		add.l	d1,obX(a0)
		muls.w	obInertia(a0),d0
		add.l	d0,obY(a0)
		movem.l	d0-d1,-(sp)
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		bsr.w	sub_1BCE8
		beq.s	loc_1BAF2
		movem.l	(sp)+,d0-d1
		sub.l	d1,obX(a0)
		sub.l	d0,obY(a0)
		clr.w	obInertia(a0)
		rts	
; ===========================================================================

loc_1BAF2:
		movem.l	(sp)+,d0-d1
		rts	
; End of function Obj09_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_MoveLeft:
		bset	#staFacing,obStatus(a0)
	if S4SpecialStages=0
		move.w	obInertia(a0),d0
		beq.s	loc_1BB06
		bpl.s	loc_1BB1A

loc_1BB06:
		subi.w	#$C,d0
		cmpi.w	#-$800,d0
		bgt.s	loc_1BB14
		move.w	#-$800,d0

loc_1BB14:
		move.w	d0,obInertia(a0)
		rts
; ===========================================================================

loc_1BB1A:
		subi.w	#$40,d0
		bcc.s	loc_1BB22
		nop	

loc_1BB22:
		move.w	d0,obInertia(a0)

	else
		move.w	(v_ssangle).w,d0
		sub.w	(v_ssrotate).w,d0
		move.w	d0,(v_ssangle).w
	endif
		rts
; End of function Obj09_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_MoveRight:
		bclr	#staFacing,obStatus(a0)
	if S4SpecialStages=0
		move.w	obInertia(a0),d0
		bmi.s	loc_1BB48
		addi.w	#$C,d0
		cmpi.w	#$800,d0
		blt.s	loc_1BB42
		move.w	#$800,d0

loc_1BB42:
		move.w	d0,obInertia(a0)
		rts
; ===========================================================================

loc_1BB48:
		addi.w	#$40,d0
		bcc.s	loc_1BB50
		nop	

loc_1BB50:
		move.w	d0,obInertia(a0)

	else
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0
		move.w	d0,(v_ssangle).w
	endif
		rts
; End of function Obj09_MoveRight


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0		; is A,	B or C pressed?
		beq.s	Obj09_NoJump	; if not, branch
		move.b	(v_ssangle).w,d0

	if SmoothSpecialStages=0	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0
	endif						; Smooth Special Stages End

		neg.b	d0
		subi.b	#$40,d0
		jsr		(CalcSine).l
		muls.w	#$680,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#$680,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#staAir,obStatus(a0)
		bset	#staSSJump,obStatus(a0)	; set "Sonic has jumped" flag -- Mercury Fixed SS Jumping Physics
		move.w	#sfx_Jump,d0
		jmp		(PlaySound_Special).l	; play jumping sound

Obj09_NoJump:
		rts	
; End of function Obj09_Jump

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to limit Sonic's upward vertical speed when jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_JumpHeight:
	; Mercury Fixed SS Jumping Physics
		move.b	(v_jpadhold2).w,d0		; is the jump button up?
		andi.b	#btnABC,d0
		bne.s	locret_1BBB4			; if not, branch to return
		btst	#staSSJump,obStatus(a0)	; did Sonic jump or is he just falling or hit by a bumper?
		beq.s	locret_1BBB4			; if not, branch to return
		move.b	(v_ssangle).w,d0		; get SS angle

	if SmoothSpecialStages=0	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0
	endif						; Smooth Special Stages End

		neg.b	d0
		subi.b	#$40,d0
		jsr		(CalcSine).l			
		move.w	obVelY(a0),d2		; get Y speed
		muls.w	d2,d0				; multiply Y speed by sin
		asr.l	#8,d0				; find the new Y speed
		move.w	obVelX(a0),d2		; get X speed
		muls.w	d2,d1				; multiply X speed by cos
		asr.l	#8,d1				; find the new X speed
		add.w	d0,d1				; combine the two speeds
		cmpi.w	#$400,d1			; compare the combined speed with the jump release speed
		ble.s	locret_1BBB4		; if it's less, branch to return
		move.b	(v_ssangle).w,d0

	if SmoothSpecialStages=0	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0
	endif						; Smooth Special Stages End

		neg.b	d0
		subi.b	#$40,d0
		jsr		(CalcSine).l
		muls.w	#$400,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#$400,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)			; set the speed to the jump release speed
		bclr	#staSSJump,obStatus(a0)	; clear "Sonic has jumped" flag

locret_1BBB4:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	fix the	camera on Sonic's position (special stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SS_FixCamera:
		move.w	obY(a0),d2
		move.w	obX(a0),d3
		move.w	(v_screenposx).w,d0
		subi.w	#$A0,d3
		bcs.s	loc_1BBCE
		sub.w	d3,d0
		sub.w	d0,(v_screenposx).w

loc_1BBCE:
		move.w	(v_screenposy).w,d0
		subi.w	#$70,d2
		bcs.s	locret_1BBDE
		sub.w	d2,d0
		sub.w	d0,(v_screenposy).w

locret_1BBDE:
		rts	
; End of function SS_FixCamera

; ===========================================================================

Obj09_ExitStage:
		addi.w	#$40,(v_ssrotate).w
		cmpi.w	#$1800,(v_ssrotate).w
		bne.s	loc_1BBF4
		move.b	#id_Level,(v_gamemode).w

loc_1BBF4:
		cmpi.w	#$3000,(v_ssrotate).w
		blt.s	loc_1BC12
		clr.w	(v_ssrotate).w
		move.w	#$4000,(v_ssangle).w
		addq.b	#2,obRoutine(a0)
		move.w	#$3C,objoff_38(a0)

loc_1BC12:
		move.w	(v_ssangle).w,d0
		add.w	(v_ssrotate).w,d0
		move.w	d0,(v_ssangle).w
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		bsr.w	SS_FixCamera
		jmp		(DisplaySprite).l
; ===========================================================================

Obj09_Exit2:
		subq.w	#1,objoff_38(a0)
		bne.s	loc_1BC40
		move.b	#id_Level,(v_gamemode).w

loc_1BC40:
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		bsr.w	SS_FixCamera
		jmp		(DisplaySprite).l

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_Fall:
		move.l	obY(a0),d2
		move.l	obX(a0),d3
		move.b	(v_ssangle).w,d0

	if SmoothSpecialStages=0	; Cinossu Smooth Special Stages
		andi.b	#$FC,d0
	endif						; Smooth Special Stages End

		jsr		(CalcSine).l
		move.w	obVelX(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d0
		add.l	d4,d0
		move.w	obVelY(a0),d4
		ext.l	d4
		asl.l	#8,d4
		muls.w	#$2A,d1
		add.l	d4,d1
		add.l	d0,d3
		bsr.w	sub_1BCE8
		beq.s	loc_1BCB0
		sub.l	d0,d3
		moveq	#0,d0
		move.w	d0,obVelX(a0)
		bclr	#staAir,obStatus(a0)
		add.l	d1,d2
		bsr.w	sub_1BCE8
		beq.s	loc_1BCC6
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_1BCB0:
		add.l	d1,d2
		bsr.w	sub_1BCE8
		beq.s	loc_1BCD4
		sub.l	d1,d2
		moveq	#0,d1
		move.w	d1,obVelY(a0)
		bclr	#staAir,obStatus(a0)

loc_1BCC6:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		rts	
; ===========================================================================

loc_1BCD4:
		asr.l	#8,d0
		asr.l	#8,d1
		move.w	d0,obVelX(a0)
		move.w	d1,obVelY(a0)
		bset	#staAir,obStatus(a0)
		rts	
; End of function Obj09_Fall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1BCE8:
		lea		(v_ssbuffer1&$FFFFFF).l,a1
		moveq	#0,d4
		swap	d2
		move.w	d2,d4
		swap	d2
		addi.w	#$44,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		swap	d3
		move.w	d3,d4
		swap	d3
		addi.w	#$14,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		moveq	#0,d5
		move.b	(a1)+,d4
		bsr.s	Obj09_ChkForSolids
		move.b	(a1)+,d4
		bsr.s	Obj09_ChkForSolids
		adda.w	#$7E,a1
		move.b	(a1)+,d4
		bsr.s	Obj09_ChkForSolids
		move.b	(a1)+,d4
		bsr.s	Obj09_ChkForSolids
		tst.b	d5
		rts	
; End of function sub_1BCE8


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_ChkForSolids: ;sub_1BD30:
		beq.s	.noSolidFound			; if no object detected, branch and exit
		cmpi.b	#SSBlock_1Up,d4			; did Sonic collide w/ a 1-Up icon?
		beq.s	.noSolidFound			; if yes, branch and exit
		cmpi.b	#SSBlock_Ring,d4		; is the object ID < $3A (ring)?
		blo.s	.solidFound				; if yes, this object was solid.
		cmpi.b	#SSBlock_GlassAni1,d4	; is this object animated glass?
		bhs.s	.solidFound				; if yes, this object was solid

.noSolidFound:
		rts	
; ===========================================================================

.solidFound:
		move.b	d4,objoff_30(a0)
		move.l	a1,objoff_32(a0)
		moveq	#-1,d5
		rts	
; End of function Obj09_ChkForSolids


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; See Constants.asm for Special Stage block IDs (Adjusted for SuperMod)

; Rework this in a similar manner to the Monitor Icon (Object 2E)
Obj09_ChkItems_Nonsolid:
		lea		(v_ssbuffer1&$FFFFFF).l,a1
		moveq	#0,d4
		move.w	obY(a0),d4
		addi.w	#$50,d4
		divu.w	#$18,d4
		mulu.w	#$80,d4
		adda.l	d4,a1
		moveq	#0,d4
		move.w	obX(a0),d4
		addi.w	#$20,d4
		divu.w	#$18,d4
		adda.w	d4,a1
		move.b	(a1),d4					; d4 = SS block being collided with.
		bne.s	Obj09_ChkRing			; if d4 != 0, check collisions
		tst.b	objoff_3A(a0)
		bne.w	Obj09_MakeGhostSolid
		moveq	#0,d4
		rts	
; ===========================================================================

Obj09_ChkRing:
		cmpi.b	#SSBlock_Ring,d4	; is the item a	ring?
		bne.s	Obj09_Chk1Up
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_GetCont
		move.b	#1,(a2)
		move.l	a1,4(a2)

Obj09_GetCont:
		jsr		(CollectRing).l
		cmpi.w	#50,(v_rings).w		; check if you have 50 rings
		blo.s	Obj09_NoCont
		bset	#0,(v_lifecount).w
		bne.s	Obj09_NoCont
		addq.b	#1,(v_continues).w	; add 1 to number of continues
		move.w	#sfx_Continue,d0
		jsr		(PlaySound).l		; play extra continue sound

Obj09_NoCont:
		moveq	#0,d4
		rts	
; ===========================================================================

Obj09_Chk1Up:
		cmpi.b	#SSBlock_1Up,d4		; is the item an extra life?
		bne.s	Obj09_ChkEmer
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_Get1Up
		move.b	#3,(a2)
		move.l	a1,4(a2)

Obj09_Get1Up:
	; Mercury Lives Over/Underflow Fix
		cmpi.b	#99,(v_lives).w		; are lives at max?
		beq.s	.playbgm
		addq.b	#1,(v_lives).w		; add 1 to number of lives
		addq.b	#1,(f_lifecount).w	; update the lives counter

.playbgm:
	; Lives Over/Underflow Fix End
		move.w	#bgm_ExtraLife,d0
		jsr		(PlaySound).l		; play extra life music
		moveq	#0,d4
		rts	
; ===========================================================================

Obj09_ChkEmer:
		cmpi.b	#SSBlock_Emld1,d4			; is the item an emerald?
		blo.s	Obj09_ChkGhost
		cmpi.b	#SSBlock_EmldLast,d4
		bhi.s	Obj09_ChkGhost
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_GetEmer
		move.b	#5,(a2)
		move.l	a1,4(a2)

Obj09_GetEmer:
		cmpi.b	#emldCount,(v_emeralds).w	; do you have all the emeralds?
		beq.s	Obj09_NoEmer				; if yes, branch
		subi.b	#$3B,d4
		bset	d4,(v_emldlist).w			; set the appropriate bit in the emerald bitfield
		addq.b	#1,(v_emeralds).w			; add 1 to number of emeralds

Obj09_NoEmer:
		move.w	#bgm_Emerald,d0
		jsr		(PlaySound_Special).l		; play emerald music
		moveq	#0,d4
		rts	
; ===========================================================================

Obj09_ChkGhost:
		cmpi.b	#SSBlock_Ghost,d4			; is the item a	ghost block?
		bne.s	Obj09_ChkGhostTag
		move.b	#1,objoff_3A(a0)			; mark the ghost block as "passed"

Obj09_ChkGhostTag:
		cmpi.b	#SSBlock_GhostSwitch,d4		; is the item a	switch for ghost blocks?
		bne.s	Obj09_NoGhost
		cmpi.b	#1,objoff_3A(a0)			; have the ghost blocks	been passed?
		bne.s	Obj09_NoGhost				; if not, branch
		move.b	#2,objoff_3A(a0)			; mark the ghost blocks	as "solid"

Obj09_NoGhost:
		moveq	#-1,d4
		rts	
; ===========================================================================

Obj09_MakeGhostSolid:
		cmpi.b	#2,objoff_3A(a0)			; is the ghost marked as "solid"?
		bne.s	Obj09_GhostNotSolid			; if not, branch
		lea		(v_ssblockbuffer&$FFFFFF).l,a1
		moveq	#(v_ssblockbuffer_end-v_ssblockbuffer)/$80-1,d1

Obj09_GhostLoop2:
		moveq	#$40-1,d2

Obj09_GhostLoop:
		cmpi.b	#SSBlock_Ghost,(a1)			; is the item a	ghost block?
		bne.s	Obj09_NoReplace				; if not, branch
		move.b	#SSBlock_GhostSolid,(a1)	; replace ghost	block with a solid block

Obj09_NoReplace:
		addq.w	#1,a1
		dbf		d2,Obj09_GhostLoop
		lea		$40(a1),a1
		dbf		d1,Obj09_GhostLoop2

Obj09_GhostNotSolid:
		clr.b	objoff_3A(a0)
		moveq	#0,d4
		rts	
; End of function Obj09_ChkItems_Nonsolid


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj09_ChkItems_Solid:
		move.b	objoff_30(a0),d0	; d0 = SS block being collided with.
		bne.s	Obj09_ChkBumper		; if d0 != 0, check collisions
		subq.b	#1,objoff_36(a0)
		bpl.s	loc_1BEA0
		clr.b	objoff_36(a0)

loc_1BEA0:
		subq.b	#1,objoff_37(a0)
		bpl.s	locret_1BEAC
		clr.b	objoff_37(a0)

locret_1BEAC:
		rts	
; ===========================================================================

Obj09_ChkBumper:
		cmpi.b	#SSBlock_Bumper,d0			; is the item a	bumper?
		bne.s	Obj09_GOAL
		move.l	objoff_32(a0),d1
		subi.l	#$FF0001,d1
		move.w	d1,d2
		andi.w	#$7F,d1
		mulu.w	#$18,d1
		subi.w	#$14,d1
		lsr.w	#7,d2
		andi.w	#$7F,d2
		mulu.w	#$18,d2
		subi.w	#$44,d2
		sub.w	obX(a0),d1
		sub.w	obY(a0),d2
		jsr		(CalcAngle).l
		jsr		(CalcSine).l
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		bset	#staAir,obStatus(a0)
		bclr	#staSSJump,obStatus(a0)		; clear "Sonic has jumped" flag -- Mercury Fixed SS Jumping Physics
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_BumpSnd
		move.b	#2,(a2)
		move.l	objoff_32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

Obj09_BumpSnd:
		move.w	#sfx_Bumper,d0
		jmp		(PlaySound_Special).l		; play bumper sound
; ===========================================================================

Obj09_GOAL:
		cmpi.b	#SSBlock_GOAL,d0			; is the item a	"GOAL"?
		bne.s	Obj09_UPblock
		addq.b	#2,obRoutine(a0)			; run routine "Obj09_ExitStage"
		move.w	#sfx_SSGoal,d0
		jmp		(PlaySound_Special).l		; play "GOAL" sound
; ===========================================================================

Obj09_UPblock:
		cmpi.b	#SSBlock_UP,d0				; is the item an "UP" block?
		bne.s	Obj09_DOWNblock
		tst.b	objoff_36(a0)
		bne.w	Obj09_NoGlass
		move.b	#$1E,objoff_36(a0)
		btst	#6,(v_ssrotate+1).w
		beq.s	Obj09_UPsnd
		asl		(v_ssrotate).w				; increase stage rotation speed
		movea.l	objoff_32(a0),a1
		subq.l	#1,a1
		move.b	#SSBlock_DOWN,(a1)			; change item to a "DOWN" block

Obj09_UPsnd:
		move.w	#sfx_SSItem,d0
		jmp		(PlaySound_Special).l		; play up/down sound
; ===========================================================================

Obj09_DOWNblock:
		cmpi.b	#SSBlock_DOWN,d0			; is the item a	"DOWN" block?
		bne.s	Obj09_Rblock
		tst.b	objoff_36(a0)
		bne.w	Obj09_NoGlass
		move.b	#$1E,objoff_36(a0)
		btst	#6,(v_ssrotate+1).w
		bne.s	Obj09_DOWNsnd
		asr		(v_ssrotate).w				; reduce stage rotation speed
		movea.l	objoff_32(a0),a1
		subq.l	#1,a1
		move.b	#SSBlock_UP,(a1)			; change item to an "UP" block

Obj09_DOWNsnd:
		move.w	#sfx_SSItem,d0
		jmp		(PlaySound_Special).l		; play up/down sound
; ===========================================================================

Obj09_Rblock:
		cmpi.b	#SSBlock_R,d0				; is the item an "R" block?
		bne.s	Obj09_ChkGlass
		tst.b	objoff_37(a0)
		bne.w	Obj09_NoGlass
		move.b	#$1E,objoff_37(a0)
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_RevStage
		move.b	#4,(a2)
		move.l	objoff_32(a0),d0
		subq.l	#1,d0
		move.l	d0,4(a2)

Obj09_RevStage:
		neg.w	(v_ssrotate).w				; reverse stage rotation
		move.w	#sfx_SSItem,d0
		jmp		(PlaySound_Special).l		; play sound
; ===========================================================================

Obj09_ChkGlass:
	; Optimized check (RetroKoH)
		cmpi.b	#SSBlock_Glass1,d0			; is the item a	glass block?
		blo.s	Obj09_NoGlass
		cmpi.b	#SSBlock_Glass4,d0
		bhi.s	Obj09_NoGlass

;Obj09_Glass:
		bsr.w	SS_RemoveCollectedItem
		bne.s	Obj09_GlassSnd
		move.b	#6,(a2)
		movea.l	objoff_32(a0),a1
		subq.l	#1,a1
		move.l	a1,4(a2)
		move.b	(a1),d0
		addq.b	#1,d0					; change glass type when touched
		cmpi.b	#SSBlock_Glass4,d0
		bls.s	Obj09_GlassUpdate		; if glass is still there, branch
		clr.b	d0						; remove the glass block when it's destroyed

Obj09_GlassUpdate:
		move.b	d0,4(a2)				; update the stage layout

Obj09_GlassSnd:
		move.w	#sfx_SSGlass,d0
		jmp		(PlaySound_Special).l	; play glass block sound
; ===========================================================================

Obj09_NoGlass:
		rts	
; End of function Obj09_ChkItems_Solid
