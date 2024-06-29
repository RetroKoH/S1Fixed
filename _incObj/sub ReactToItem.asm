; ---------------------------------------------------------------------------
; Subroutine to react to obColType(a0)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReactToItem:
		nop
		jsr		Touch_Rings						; RetroKoH S2 Rings Manager

	if ShieldsMode>0
		move.b	obStatus2nd(a0),d0				; does the player have a Shield or Invincibility?
		andi.b	#mask2ndChkShield,d0
		bne.s	.noInstaShield					; if yes, branch
; By this point, we're focussing purely on the Insta-Shield
		cmpi.b	#1,obDoubleJumpFlag(a0)			; is the insta-shield active?
		bne.s	.noInstaShield					; if not, branch
		move.b	obStatus2nd(a0),d0
		move.w	d0,-(sp)
		bset	#sta2ndInvinc,obStatus2nd(a0)	; Set invincibility
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#$18,d2
		subi.w	#$18,d3
		move.w	#$30,d4
		move.w	#$30,d5
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
		move.w	obX(a0),d2				; load Sonic's x-axis position
		move.w	obY(a0),d3				; load Sonic's y-axis position
		subq.w	#8,d2
		moveq	#0,d5
		move.b	obHeight(a0),d5			; load Sonic's height
		subq.b	#3,d5
		sub.w	d5,d3

	; Mercury Ducking Size Fix
	if SpinDashEnabled=1	; Mercury Spin Dash
		cmpi.b	#aniID_SpinDash,obAnim(a0)
		beq.s	.short
	endif	; Spin Dash End
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	.notducking
		
.short:
		addi.w	#$C,d3
		moveq	#$A,d5

.notducking:
	; Ducking Size Fix end
		move.w	#$10,d4
		add.w	d5,d5

.chkobjecttype:
		lea		(v_lvlobjspace).w,a1	; set object RAM start address
		move.w	#v_lvlobjcount,d6		; (objRAM / objSize) - 1 ($5F)

.loop:
		tst.b	obRender(a1)
		bpl.s	.next
		move.b	obColType(a1),d0	; load collision type
		bne.s	.proximity			; if nonzero, branch

.next:
		lea		object_size(a1),a1	; next object RAM
		dbf		d6,.loop			; repeat $5F more times

		moveq	#0,d0
		rts	
; ===========================================================================
.sizes:		;   width, height
		dc.b  $14, $14		; $01
		dc.b   $C, $14		; $02
		dc.b  $14,  $C		; $03
		dc.b	4, $10		; $04
		dc.b   $C, $12		; $05
		dc.b  $10, $10		; $06
		dc.b	6,   6		; $07
		dc.b  $18,  $C		; $08
		dc.b   $C, $10		; $09
		dc.b  $10,  $C		; $0A
		dc.b	8,   8		; $0B
		dc.b  $14, $10		; $0C
		dc.b  $14,   8		; $0D
		dc.b   $E,  $E		; $0E
		dc.b  $18, $18		; $0F
		dc.b  $28, $10		; $10
		dc.b  $10, $18		; $11
		dc.b	8, $10		; $12
		dc.b  $20, $70		; $13
		dc.b  $40, $20		; $14
		dc.b  $80, $20		; $15
		dc.b  $20, $20		; $16
		dc.b	8,   8		; $17
		dc.b	4,   4		; $18
		dc.b  $20,   8		; $19
		dc.b   $C,  $C		; $1A
		dc.b	8,   4		; $1B
		dc.b  $18,   4		; $1C
		dc.b  $28,   4		; $1D
		dc.b	4,   8		; $1E
		dc.b	4, $18		; $1F
		dc.b	4, $28		; $20
		dc.b	4, $20		; $21
		dc.b  $18, $18		; $22
		dc.b   $C, $18		; $23
		dc.b  $48,   8		; $24
; ===========================================================================

.proximity:
		andi.w	#$3F,d0
		add.w	d0,d0
		lea		.sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obX(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	.outsidex	; branch if not touching
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	.withinx	; branch if touching
		bra.w	.next
; ===========================================================================

.outsidex:
		cmp.w	d4,d0
		bhi.w	.next

.withinx:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	obY(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	.outsidey	; branch if not touching
		add.w	d1,d1
		add.w	d0,d1
		bcs.s	.withiny	; branch if touching
		bra.w	.next
; ===========================================================================

.outsidey:
		cmp.w	d5,d0
		bhi.w	.next

.withiny:
.chktype:
		move.b	obColType(a1),d1 ; load collision type
		andi.b	#$C0,d1		; is obColType $40 or higher?
		beq.w	React_Enemy	; if not, branch
		cmpi.b	#$C0,d1		; is obColType $C0 or higher?
		beq.w	React_Special	; if yes, branch
		tst.b	d1		; is obColType $80-$BF?
		bmi.w	React_ChkHurt	; if yes, branch

; obColType is $40-$7F (powerups)

		move.b	obColType(a1),d0
		andi.b	#$3F,d0
		cmpi.b	#6,d0				; is collision type $46?
		beq.s	React_Monitor		; if yes, branch
	; Otherwise, check if Sonic is able to collect rings
		cmpi.b	#90,obInvuln(a0)	; is Sonic too early in invuln frames to collect rings? -- RetroKoH Sonic SST Compaction
		bhs.w	.invincible			; if yes, branch
		addq.b	#2,obRoutine(a1)	; advance the object's routine counter (CollectRing)

.invincible:
		rts	
; ===========================================================================

React_Monitor:
		tst.w	obVelY(a0)	; is Sonic moving upwards?
		bpl.s	.movingdown	; if not, branch

		move.w	obY(a0),d0
		subi.w	#$10,d0
		cmp.w	obY(a1),d0
		blo.s	.donothing
		neg.w	obVelY(a0)	; reverse Sonic's vertical speed
		move.w	#-$180,obVelY(a1)
		tst.b	ob2ndRout(a1)
		bne.s	.donothing
		addq.b	#4,ob2ndRout(a1) ; advance the monitor's routine counter
		rts	
; ===========================================================================

.movingdown:
		cmpi.b	#aniID_Roll,obAnim(a0) ; is Sonic rolling/jumping?
		bne.s	.donothing
		neg.w	obVelY(a0)	; reverse Sonic's y-motion
		addq.b	#2,obRoutine(a1) ; advance the monitor's routine counter

.donothing:
		rts	
; ===========================================================================

React_Enemy:
		btst	#sta2ndInvinc,obStatus2nd(a0)	; is Sonic invincible?
		bne.s	.donthurtsonic					; if yes, branch

	if SpinDashEnabled=1	; Mercury Spin Dash
		cmpi.b	#aniID_SpinDash,obAnim(a0)	; is Sonic Spin Dashing?
		beq.w	.breakenemy					; if yes, branch
	endif	; Spin Dash End

		cmpi.b	#aniID_Roll,obAnim(a0)		; is Sonic rolling/jumping?
		bne.w	React_ChkHurt				; if not, branch

.donthurtsonic:
		tst.b	obColProp(a1)
		beq.s	.breakenemy

		neg.w	obVelX(a0)	; repel Sonic
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
		addq.w	#2,(v_itembonus).w ; add 2 to item bonus counter
		cmpi.w	#6,d0
		blo.s	.bonusokay
		moveq	#6,d0		; max bonus is lvl6

.bonusokay:
		move.w	d0,objoff_3E(a1)
		move.w	.points(pc,d0.w),d0
		cmpi.w	#$20,(v_itembonus).w ; have 16 enemies been destroyed?
		blo.s	.lessthan16	; if not, branch
		move.w	#1000,d0	; fix bonus to 10000
		move.w	#$A,objoff_3E(a1)

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
		btst	#shPropReflect,obShieldProp(a1)	; is the object supposed to bounce off of shields?
		beq.s	.chkhurt						; if not, branch
		
;Bounce_Projectile:
		move.w	obX(a0),d1
		move.w	obY(a0),d2
		sub.w	obX(a1),d1
		sub.w	obY(a1),d2
		jsr		(CalcAngle).l
		jsr		(CalcSine).l
		muls.w	#-$800,d1
		asr.l	#8,d1
		move.w	d1,obVelX(a1)
		muls.w	#-$800,d0
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
; continue straight to HurtSonic
; ===========================================================================


; Original Code	
;React_ChkHurt:
;		btst	#sta2ndInvinc,obStatus2nd(a0)	; is Sonic invincible?
;		beq.s	.notinvincible					; if not, branch

;.isflashing:
;		moveq	#-1,d0
;		rts	
; ===========================================================================

;.notinvincible:
;		nop	
;		tst.b	obInvuln(a0)	; is Sonic flashing? -- RetroKoH Sonic SST Compaction
;		bne.s	.isflashing		; if yes, branch
;		movea.l	a1,a2

; End of function ReactToItem
; continue straight to HurtSonic

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HurtSonic:
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
		move.w	#-$400,obVelY(a0)				; make Sonic bounce away from the object
		move.w	#-$200,obVelX(a0)
		btst	#staWater,obStatus(a0)			; is Sonic underwater?
		beq.s	.isdry							; if not, branch

		move.w	#-$200,obVelY(a0)				; slower bounce
		move.w	#-$100,obVelX(a0)

.isdry:
		move.w	obX(a0),d0
		cmp.w	obX(a2),d0
		blo.s	.isleft							; if Sonic is left of the object, branch
		neg.w	obVelX(a0)						; if Sonic is right of the object, reverse

.isleft:
	if SpinDashEnabled=1
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
		jsr		(PlaySound_Special).l
		moveq	#-1,d0
		rts	
; ===========================================================================

.norings:
		tst.w	(f_debugmode).w	; is debug mode	cheat on?
		bne.w	.hasshield	; if yes, branch

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KillSonic:
		tst.w	(v_debuguse).w					; is debug mode	active?
		bne.s	.dontdie						; if yes, branch
		bclr	#sta2ndInvinc,obStatus2nd(a0)	; remove invincibility
		move.b	#6,obRoutine(a0)
		jsr		(Sonic_ResetOnFloor).l
		bset	#staAir,obStatus(a0)
		move.w	#-$700,obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.w	obY(a0),objoff_38(a0)
		move.b	#aniID_Death,obAnim(a0)
		bset	#7,obGfx(a0)
	; Mercury Spike SFX Fix
		move.w	#sfx_HitSpikes,d0 ; play spikes death sound
		cmpi.b	#id_Spikes,obID(a2)	; check	if you were killed by spikes
		beq.s	.sound
		cmpi.b	#id_Harpoon,obID(a2)	; check	if you were killed by a harpoon
		beq.s	.sound
		move.w	#sfx_Death,d0	; play normal death sound
	; Spike SFX Fix End

.sound:
		jsr	(PlaySound_Special).l

.dontdie:
		moveq	#-1,d0
		rts	
; End of function KillSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


React_Special:
		move.b	obColType(a1),d1
		andi.b	#$3F,d1
		cmpi.b	#$B,d1		; is collision type $CB	?
		beq.s	.caterkiller	; if yes, branch
		cmpi.b	#$C,d1		; is collision type $CC	?
		beq.s	.yadrin		; if yes, branch
		cmpi.b	#$17,d1		; is collision type $D7	?
		beq.s	.D7orE1		; if yes, branch
		cmpi.b	#$21,d1		; is collision type $E1	?
		beq.s	.D7orE1		; if yes, branch
		rts	
; ===========================================================================

.caterkiller:
		bra.w	React_Caterkiller
; ===========================================================================

.yadrin:
		sub.w	d0,d5
		cmpi.w	#8,d5
		bhs.s	.normalenemy
		move.w	obX(a1),d0
		subq.w	#4,d0
		btst	#staFlipX,obStatus(a1)
		beq.s	.noflip
		subi.w	#$10,d0

.noflip:
		sub.w	d2,d0
		bcc.s	.loc_1B13C
		addi.w	#$18,d0
		bcs.s	.loc_1B140
		bra.s	.normalenemy
; ===========================================================================

.loc_1B13C:
		cmp.w	d4,d0
		bhi.s	.normalenemy

.loc_1B140:
		bra.w	React_ChkHurt
; ===========================================================================

.normalenemy:
		bra.w	React_Enemy
; ===========================================================================

.D7orE1:
		addq.b	#1,obColProp(a1)
		rts	
; End of function React_Special
