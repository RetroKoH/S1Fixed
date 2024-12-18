; ---------------------------------------------------------------------------
; Subroutine to react to obColType(a0)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReactToItem:
		jsr		(Touch_Rings).l					; RetroKoH S3K Rings Manager

	if S3KDoubleJump
		move.b	obStatus2nd(a0),d0				; does the player have a Shield or Invincibility?
		andi.b	#mask2ndChkShield,d0
		bne.s	.noInstaShield					; if yes, branch
; By this point, we're focusing purely on the Insta-Shield
		cmpi.b	#1,obDoubleJumpFlag(a0)			; is the insta-shield active?
		bne.s	.noInstaShield					; if not, branch
		move.b	obStatus2nd(a0),d0
		move.w	d0,-(sp)
		bset	#sta2ndInvinc,obStatus2nd(a0)	; Set invincibility
		moveq	#-24,d2							; subtract width of Insta-Shield
		add.w	obX(a0),d2						; get player's x_pos
		moveq	#-24,d3							; subtract height of Insta-Shield
		add.w	obY(a0),d3						; get player's y_pos
		move.w	#48,d4							; player's width
		move.w	#48,d5							; player's height
		bsr.s	.chkobjecttype					; check collision flags to see if object is negated by insta-shield
		move.w	(sp)+,d0
		btst	#sta2ndInvinc,d0
		bne.s	.skipclr						; if yes, branch
		bclr	#sta2ndInvinc,obStatus2nd(a0)	; otherwise, remove invincibility

.skipclr:
		moveq	#0,d0
		rts

.noInstaShield
	endif
		move.w	obX(a0),d2						; load Sonic's x-axis position
		move.w	obY(a0),d3						; load Sonic's y-axis position
		subq.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5					; load Sonic's height
		subq.b	#3,d5
		sub.w	d5,d3

	; Mercury Ducking Size Fix
	if SpinDashEnabled	; Mercury Spin Dash
		cmpi.b	#aniID_SpinDash,obAnim(a0)		; is player spindashing?
		beq.s	.short							; if not, branch
	endif	; Spin Dash End
		cmpi.b	#aniID_Duck,obAnim(a0)			; is player ducking?
		bne.s	.notducking						; if not, branch
		
.short:
		addi.w	#$C,d3
		moveq	#$A,d5

.notducking:
	; Ducking Size Fix end
		move.w	#16,d4							; player's collision width
		add.w	d5,d5

.chkobjecttype:
		lea		(v_col_response_list).w,a4
		move.w	(a4)+,d6						; Get number of objects queued
		beq.s	.end							; If there are none, return

.loop:
		movea.w	(a4)+,a1						; Get address of first object's RAM
		move.b	obColType(a1),d0				; Get its collision_flags
		bne.s	.proximity						; If it actually has collision, branch

.next:
		subq.w	#2,d6							; Count the object as done
		bne.s	.loop							; If there are still objects left, loop
		moveq	#0,d0
.end
		rts	
; ===========================================================================

; We must load (Touch_Sizes-2) to a2 because the first pair of values must be accessed by
; an index of $01. This is because an obColType value of $00 means no collision whatsoever.
.proximity:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea		Touch_Sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1						; get width value from Touch_Sizes
		move.w	obX(a1),d0						; get object's x-position
		sub.w	d1,d0							; subtract object's width
		sub.w	d2,d0							; subtract player's left collision boundary
		bcc.s	.outsidex						; if player's left side is to the left of the object (not touching), branch
		add.w	d1,d1							; double object's width value
		add.w	d1,d0							; add object's width*2 (now at right of object)
		bcs.s	.withinx						; branch if touching
		bra.s	.next							; if not, loop and check next object
; ===========================================================================

.outsidex:
		cmp.w	d4,d0							; is player's right side to the left of the object?
		bhi.s	.next							; if so, loop and check next object

.withinx:
		moveq	#0,d1
		move.b	(a2)+,d1						; get height value from Touch_Sizes
		move.w	obY(a1),d0						; get object's y_pos
		sub.w	d1,d0							; subtract object's height
		sub.w	d3,d0							; subtract player's bottom collision boundary
		bcc.s	.outsidey						; if bottom of player is under the object, branch
		add.w	d1,d1							; double object's height value
		add.w	d1,d0							; add object's height*2 (now at top of object)
		bcs.s	Touch_ChkValue					; branch if touching
		bra.s	.next							; if not, loop and check next object
; ===========================================================================

.outsidey:
		cmp.w	d5,d0							; is top of player under the object?
		bhi.s	.next							; if so, loop and check next object
		bra.s	Touch_ChkValue
; ===========================================================================

; ---------------------------------------------------------------------------
; collision sizes $00-$3F (width,height)
; $00-$3F	- enemy collision
; $40-$7F	- ring/monitor collision
; $80-$BF	- hurt collision
; $C0-$FF	- special collision
; ---------------------------------------------------------------------------

Touch_Sizes:
		; 		width,	height
		dc.b	20,		20		; $01
		dc.b	12,		20		; $02
		dc.b	20,		12		; $03 (Unused)
		dc.b	4,		16		; $04
		dc.b	12,		18		; $05
		dc.b	16,		16		; $06
		dc.b	6,		6		; $07
		dc.b	24,		12		; $08
		dc.b	12,		16		; $09
		dc.b	16,		12		; $0A
		dc.b	8,		8		; $0B
		dc.b	20,		16		; $0C
		dc.b	20,		8		; $0D
		dc.b	14,		14		; $0E
		dc.b	24,		24		; $0F
		dc.b	40,		16		; $10
		dc.b	16,		24		; $11
		dc.b	8,		16		; $12
		dc.b	32,		112		; $13
		dc.b	64,		32		; $14
		dc.b	128,	32		; $15 (Unused)
		dc.b	32,		32		; $16 (Unused)
		dc.b	8,		8		; $17 (Identical w/ $B)
		dc.b	4,		4		; $18
		dc.b	32,		8		; $19
		dc.b	12,		12		; $1A
		dc.b	8,		4		; $1B (Unused)
		dc.b	24,		4		; $1C (Unused)
		dc.b	40,		4		; $1D (Unused)
		dc.b	4,		8		; $1E (Unused)
		dc.b	4,		24		; $1F (Unused)
		dc.b	4,		40		; $20 (Unused)
		dc.b	4,		32		; $21
		dc.b	24,		24		; $22 (Identical w/ $F)
		dc.b	12,		24		; $23
		dc.b	72,		8		; $24
; ===========================================================================

Touch_ChkValue:
		moveq	#signextendB($C0),d1
		and.b	obColType(a1),d1	; d1 = collision type
		beq.w	React_Enemy			; if $00 ($00-$3F), branch to enemy collision
		cmpi.b	#$C0,d1
		beq.w	React_Special		; if $C0 ($C0-$FF), branch to special collision
		tst.b	d1
		bmi.w	React_ChkHurt		; if $80 ($80-$BF), branch to harmful collision

; if $40 ($40-$7F), fallthrough to ring/monitor collision
;React_Powerup:
		moveq	#$3F,d0
		and.b	obColType(a1),d0	; d1 = collision size
		cmpi.b	#6,d0				; is this a monitor?
		beq.s	React_Monitor		; if yes, branch
	; Otherwise, check if Sonic is able to collect rings
		cmpi.b	#90,obInvuln(a0)	; is Sonic too early in invuln frames to collect rings? -- RetroKoH Sonic SST Compaction
		bhs.s	.invulnerable		; if yes, branch
		addq.b	#2,obRoutine(a1)	; advance the object's routine counter (CollectRing)

.invulnerable:
		rts	
; ===========================================================================

React_Monitor:
		tst.w	obVelY(a0)	; is Sonic moving upwards?
		bpl.s	.movingdown	; if not, branch

		moveq	#-16,d0
		add.w	obY(a0),d0			; get player's y_pos - monitor height
		cmp.w	obY(a1),d0
		blo.s	.donothing			; if new value is lower than monitor's y_pos, return
		neg.w	obVelY(a0)			; reverse Sonic's vertical speed
		move.w	#-$180,obVelY(a1)
		tst.b	ob2ndRout(a1)
		bne.s	.donothing
		addq.b	#4,ob2ndRout(a1)	; advance the monitor's routine counter
		rts	
; ===========================================================================

.movingdown:
	if DropDashEnabled	; RetroKoH Drop Dash
		cmpi.b	#aniID_DropDash,obAnim(a0)	; is Sonic Drop Dashing? -- Fix to allow rebounding
		beq.s	.spinning					; if yes, branch
	endif	; Drop Dash End

		cmpi.b	#aniID_Roll,obAnim(a0)	; is Sonic rolling/jumping?
		bne.s	.donothing				; if not, branch

.spinning:
		neg.w	obVelY(a0)				; reverse Sonic's y-motion
	if ReboundMod	; Mercury Rebound Mod
		tst.b	obJumping(a0)
		bne.s	.isjumping
		move.b	#1,obJumping(a0)
		move.b	#3,obDoubleJumpFlag(a0)	; disable double jumps if we didn't jump

.isjumping:
	endif	; end Rebound Mod
		addq.b	#2,obRoutine(a1)		; advance the monitor's routine counter

.donothing:
		rts	
; ===========================================================================

React_Enemy:
		btst	#sta2ndInvinc,obStatus2nd(a0)	; is Sonic invincible?
		bne.s	.donthurtsonic					; if yes, branch

	if SpinDashEnabled	; Mercury Spin Dash
		cmpi.b	#aniID_SpinDash,obAnim(a0)	; is Sonic Spin Dashing?
		beq.w	.breakenemy					; if yes, branch
	endif	; Spin Dash End
	
	if DropDashEnabled	; RetroKoH Drop Dash
		cmpi.b	#aniID_DropDash,obAnim(a0)	; is Sonic Drop Dashing?
		beq.w	.breakenemy					; if yes, branch
	endif	; Drop Dash End

		cmpi.b	#aniID_Roll,obAnim(a0)		; is Sonic rolling/jumping?
		bne.w	React_ChkHurt				; if not, branch

.donthurtsonic:
		tst.b	obColProp(a1)
		beq.s	.breakenemy

		neg.w	obVelX(a0)					; repel Sonic
		neg.w	obVelY(a0)
		asr		obVelX(a0)
		asr		obVelY(a0)
		clr.b	obColType(a1)
		subq.b	#1,obColProp(a1)
		bne.s	.flagnotclear
		bset	#7,obStatus(a1)

.flagnotclear:
		rts	
; ===========================================================================

.breakenemy:
		bset	#7,obStatus(a1)
		moveq	#0,d0
		move.w	(v_itembonus).w,d0
		addq.w	#2,(v_itembonus).w			; add 2 to item bonus counter
		cmpi.w	#6,d0
		blo.s	.bonusokay
		moveq	#6,d0						; max bonus is lvl6

.bonusokay:
		move.w	d0,objoff_3E(a1)
		move.w	.points(pc,d0.w),d0
		cmpi.w	#(16*2),(v_itembonus).w		; have 16 enemies been destroyed?
		blo.s	.lessthan16					; if not, branch
		move.w	#1000,d0					; fix bonus to 10000
		move.w	#10,objoff_3E(a1)

.lessthan16:
		bsr.w	AddPoints
		_move.b	#id_ExplosionItem,obID(a1) ; change object to explosion
		clr.b	obRoutine(a1)
		tst.w	obVelY(a0)
		bmi.s	.bouncedown
		move.w	obY(a0),d0
		cmp.w	obY(a1),d0
		bhs.s	.bounceup
		neg.w	obVelY(a0)
	if ReboundMod=1	; Mercury Rebound Mod
		tst.b	obJumping(a0)
		bne.s	.isjumping
		move.b	#1,obJumping(a0)
		move.b	#3,obDoubleJumpFlag(a0)	; disable double jumps if we didn't jump

.isjumping:
	endif	; end Rebound Mod
		rts
; ===========================================================================

.bouncedown:
		addi.w	#$100,obVelY(a0)
		rts

.bounceup:
		subi.w	#$100,obVelY(a0)
		rts

.points:	dc.w 10, 20, 50, 100	; points awarded div 10

; ===========================================================================

React_Caterkiller:
	; Mercury Caterkiller Fix
		move.b	#1,d0
		move.w	obInertia(a0),d1
		bmi.s	.skip
		move.b	#0,d0
		
	.skip:
		move.b	obStatus(a1),d1
		andi.b	#maskFlipX,d1
		cmp.b	d0,d1					; are Sonic and the Caterkiller facing the same way?
		bne.s	.hurt					; if not, branch
		btst	#staAir,obStatus(a0)	; is Sonic in the air?
		bne.s	.hurt					; if so, branch
		btst	#staSpin,obStatus(a0)	; is Sonic spinning?
		beq.s	.hurt					; if not, branch
		moveq	#-1,d0					; else, he shouldn't be hurt
		rts				
	
	.hurt:
	; Caterkiller Fix End
		bset	#7,obStatus(a1)

React_ChkHurt:
	if ~~S3KDoubleJump
		btst	#sta2ndInvinc,obStatus2nd(a0)	; is Sonic invincible?
		beq.s	.notinvincible					; if not, branch

.isflashing:
		moveq	#-1,d0
		rts	
; ===========================================================================

.notinvincible:
		nop	
		tst.b	obInvuln(a0)	; is Sonic flashing? -- RetroKoH Sonic SST Compaction
		bne.s	.isflashing		; if yes, branch
		movea.l	a1,a2
; End of function ReactToItem
	else

		move.b	obStatus2nd(a0),d0
		andi.b	#mask2ndChkElement,d0			; does the player have an elemental shield?
		beq.s	.noelemental					; if not, branch
		and.b	obShieldProp(a1),d0				; is the object negated by player's current shield?
		bne.s	.nohurt							; if yes, branch and exit
		bra.s	.checkreflect					; if not, check for reflecting

.noelemental:
		btst	#sta2ndShield,obStatus2nd(a0)	; does Sonic have a Blue Shield?
		bne.s	.chkhurt						; if yes, branch to hurt Sonic
		cmpi.b	#1,obDoubleJumpFlag(a0)			; is instashield active?
		bne.s	.chkhurt						; if not, branch to hurt Sonic

; Elementals and Instashield reflect
.checkreflect:
		move.b	obShieldProp(a1),d1
		btst	#shPropReflect,d1		; is the object supposed to bounce off of shields?
		beq.s	.chkhurt				; if not, branch
		
;Bounce_Projectile:
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr		(CalcAngle).w
		jsr		(CalcSine).w
		move.w	#-$800,d2
		muls.w	d2,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a1)
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,obVelY(a1)
		clr.b	obColType(a1)
.nohurt:
		moveq	#-1,d0
		rts

.chkhurt:
		tst.b	obInvuln(a0)					; is Sonic flashing? -- RetroKoH Sonic SST Compaction
		bne.s	.nohurt							; if yes, branch and exit
		btst	#sta2ndInvinc,obStatus2nd(a0)	; is Sonic invincible?
		bne.s	.nohurt							; if yes, branch and exit

.gotohurt:
		movea.l	a1,a2
		;bra.s	HurtSonic						; if not, branch to standard routine
; End of function ReactToItem
	endif
; continue straight to HurtSonic
; ===========================================================================

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HurtSonic:
	if CoolBonusEnabled
		move.b	(v_hitscount).w,d0
		tst.b	d0
		beq.s	.notcool
		subq.b	#1,d0							; set hits count for next cool bonus
		move.b	d0,(v_hitscount).w

.notcool:
	endif

		btst	#sta2ndShield,obStatus2nd(a0)	; does Sonic have a shield?
		bne.s	.hasshield						; if yes, branch
		tst.w	(v_rings).w						; does Sonic have any rings?
		beq.w	.norings						; if not, branch

		jsr		(FindFreeObj).l
		bne.s	.hasshield
		_move.b	#id_RingLoss,obID(a1)			; load bouncing multi rings object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

.hasshield:
		bclr	#sta2ndShield,obStatus2nd(a0)	; remove shield
		move.b	#4,obRoutine(a0)
		jsr		(Sonic_ResetOnFloor).l
		bset	#staAir,obStatus(a0)
		move.l	#$FE00FC00,obVelX(a0)			; bounce player away (xspd = -$200, yspd = -$400)
		btst	#staWater,obStatus(a0)			; is Sonic underwater?
		beq.s	.isdry							; if not, branch

		move.l	#$FF00FE00,obVelX(a0)			; bounce player away (xspd = -$100, yspd = -$200)

.isdry:
		move.w	obX(a0),d0
		cmp.w	obX(a2),d0
		blo.s	.isleft							; if Sonic is left of the object, branch
		neg.w	obVelX(a0)						; if Sonic is right of the object, reverse

.isleft:
	if SpinDashEnabled
		clr.b	obSpinDashFlag(a0)
	endif
		clr.w	obInertia(a0)
		move.b	#aniID_Hurt,obAnim(a0)
		move.b	#120,obInvuln(a0)		; set temp invincible time to 2 seconds -- RetroKoH Sonic SST Compaction
		move.w	#sfx_Death,d0			; load normal damage sound
		cmpi.b	#id_Spikes,obID(a2)		; was damage caused by spikes?
	; Mercury Spike SFX Fix
		beq.s	.setspikesound			; if so, branch
		cmpi.b	#id_Harpoon,obID(a2)	; was damage caused by LZ harpoon?
		bne.s	.sound					; if not, branch

.setspikesound:
	; Spike SFX Fix End
		move.w	#sfx_HitSpikes,d0		; load spikes damage sound

.sound:
		jsr		(PlaySound_Special).w
		moveq	#-1,d0
		rts	
; ===========================================================================

.norings:
		tst.w	(f_debugmode).w			; is debug mode	cheat on?
		bne.w	.hasshield				; if yes, branch
	; otherwise, fall through to kill Sonic

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KillSonic:
		tst.w	(v_debuguse).w					; is debug mode	active?
		bne.s	.dontdie						; if yes, branch

	if HUDInSpecialStage=1	; Mercury Time Limit In Special Stage
		cmpi.b	#id_SonicSpecial,obID(a0)		; test if it's Special Stage Sonic that's trying to die
		bne.s	.normal
		
		move.b	#4,obRoutine(a0)				; change Sonic to Special Stage dying routine
		
		;move.w	obY(a0),$38(a0)
		
		bset	#staAir,obStatus(a0)
		move.b	#aniID_Shrink,obAnim(a0)
		bset	#7,obGfx(a0)
		move.w	#sfx_Death,d0					; play normal death sound
		jsr		(PlaySound_Special).w
		moveq	#-1,d0
		rts	

	.normal:
	endif	; Time Limit In Special Stage End

	if CoolBonusEnabled
		clr.b	(v_hitscount).w					; clear cool bonus hit counter
	endif

		bclr	#sta2ndInvinc,obStatus2nd(a0)	; remove invincibility
		move.b	#6,obRoutine(a0)
		jsr		(Sonic_ResetOnFloor).l
		bset	#staAir,obStatus(a0)
		move.w	#-$700,obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.b	#aniID_Death,obAnim(a0)
		bset	#7,obGfx(a0)
	; Mercury Spike SFX Fix
		move.w	#sfx_HitSpikes,d0		; play spikes death sound
		cmpi.b	#id_Spikes,obID(a2)		; check	if you were killed by spikes
		beq.s	.sound
		cmpi.b	#id_Harpoon,obID(a2)	; check	if you were killed by a harpoon
		beq.s	.sound
		move.w	#sfx_Death,d0			; play normal death sound
	; Spike SFX Fix End

.sound:
		jsr		(PlaySound_Special).w

.dontdie:
		moveq	#-1,d0
		rts	
; End of function KillSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


React_Special:
		moveq	#$3F,d1
		and.b	obColType(a1),d1	; get collision size
		cmpi.b	#$B,d1				; is collision type $CB	?
		beq.w	React_Caterkiller	; if yes, branch
		cmpi.b	#$C,d1				; is collision type $CC	?
		beq.s	.yadrin				; if yes, branch
		cmpi.b	#$17,d1				; is collision type $D7	?
		beq.s	.D7orE1				; if yes, branch
		cmpi.b	#$21,d1				; is collision type $E1	?
		beq.s	.D7orE1				; if yes, branch
		rts	
; ===========================================================================

.yadrin:
		sub.w	d0,d5
		cmpi.w	#8,d5
		bhs.w	React_Enemy			; .normalenemy
		move.w	obX(a1),d0
		subq.w	#4,d0
		btst	#staFlipX,obStatus(a1)
		beq.s	.noflip
		subi.w	#16,d0

.noflip:
		sub.w	d2,d0
		bcc.s	.loc_1B13C
		addi.w	#24,d0
		bcs.w	React_ChkHurt
		bra.w	React_Enemy			; .normalenemy
; ===========================================================================

.loc_1B13C:
		cmp.w	d4,d0
		bhi.w	React_Enemy			; .normalenemy
		bra.w	React_ChkHurt
; ===========================================================================

.D7orE1:
		addq.b	#1,obColProp(a1)
		rts	
; End of function React_Special
