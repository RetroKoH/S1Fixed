; ---------------------------------------------------------------------------
; Object 55 - Basaran enemy (MZ)
; ---------------------------------------------------------------------------

Basaran:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Bas_Action
	; Object Routine Optimization End

Bas_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Bas,obMap(a0)
		move.w	#make_art_tile(ArtTile_Basaran,0,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$C,obHeight(a0)
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$B,obColType(a0)
		move.b	#$10,obActWid(a0)

Bas_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	.index(pc,d0.w),d1
		jsr		.index(pc,d1.w)
		lea		Ani_Bas(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================
.index:
		dc.w .dropcheck-.index
		dc.w .dropfly-.index
		dc.w .flapsound-.index
		dc.w .flyup-.index
; ===========================================================================

.dropcheck:
		move.w	#$80,d2
		bsr.w	.chkdistance	; is Sonic < $80 pixels from basaran?
		bcc.s	.nodrop		; if not, branch
		move.w	(v_player+obY).w,d0
		move.w	d0,objoff_36(a0)
		sub.w	obY(a0),d0
		bcs.s	.nodrop
		cmpi.w	#$80,d0		; is Sonic < $80 pixels from basaran?
		bhs.s	.nodrop		; if not, branch
		tst.w	(v_debuguse).w	; is debug mode	on?
		bne.s	.nodrop		; if yes, branch

		move.b	(v_vbla_byte).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	.nodrop
		move.b	#1,obAnim(a0)
		addq.b	#2,ob2ndRout(a0)

.nodrop:
		rts	
; ===========================================================================

.dropfly:
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; make basaran fall
		move.w	#$80,d2
		bsr.w	.chkdistance
		move.w	objoff_36(a0),d0
		sub.w	obY(a0),d0
		bcs.s	.chkdel
		cmpi.w	#$10,d0			; is basaran close to Sonic vertically?
		bhs.s	.return			; if not, branch
		move.w	d1,obVelX(a0)	; make basaran fly horizontally
		clr.w	obVelY(a0)		; stop basaran falling
		move.b	#2,obAnim(a0)
		addq.b	#2,ob2ndRout(a0)

.return:
		rts	

.chkdel:
		tst.b	obRender(a0)
		; Clownacy DisplaySprite Fix
		bmi.s	.return
		addq.l	#4,sp
		bra.w	DeleteObject
; ===========================================================================

.flapsound:
		move.b	(v_vbla_byte).w,d0
		andi.b	#$F,d0
		bne.s	.nosound
		move.w	#sfx_Basaran,d0
		jsr	(PlaySound_Special).w	; play flapping sound every 16th frame

.nosound:
		bsr.w	SpeedToPos
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.isright	; if Sonic is right of basaran, branch
		neg.w	d0

.isright:
		cmpi.w	#$80,d0		; is Sonic within $80 pixels of basaran?
		blo.s	.dontflyup	; if yes, branch
		move.b	(v_vbla_byte).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	.dontflyup
		addq.b	#2,ob2ndRout(a0)

.dontflyup:
		rts	
; ===========================================================================

.flyup:
		bsr.w	SpeedToPos
		subi.w	#$18,obVelY(a0)	; make basaran fly upwards
		bsr.w	ObjHitCeiling
		tst.w	d1		; has basaran hit the ceiling?
		bpl.s	.noceiling	; if not, branch
		sub.w	d1,obY(a0)
		andi.w	#$FFF8,obX(a0)
		clr.w	obVelX(a0)	; stop basaran moving
		clr.w	obVelY(a0)
		clr.b	obAnim(a0)
		clr.b	ob2ndRout(a0)

.noceiling:
		rts	
; ===========================================================================

; Subroutine to check Sonic's distance from the basaran

; input:
;	d2 = distance to compare

; output:
;	d0 = distance between Sonic and basaran
;	d1 = speed/direction for basaran to fly

.chkdistance:
		move.w	#$100,d1
		bset	#staFlipX,obStatus(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.right		; if Sonic is right of basaran, branch
		neg.w	d0
		neg.w	d1
		bclr	#staFlipX,obStatus(a0)

.right:
		cmp.w	d2,d0
		rts
