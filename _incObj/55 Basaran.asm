; ---------------------------------------------------------------------------
; Object 55 - Basaran enemy (MZ)
; ---------------------------------------------------------------------------

Basaran:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Bas_Action
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

Bas_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> Bat_Action
		move.l	#Map_Bas,obMap(a0)
		move.w	#make_art_tile(ArtTile_Basaran,0,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$C,obHeight(a0)
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_8x8),obColType(a0)
		move.b	#$10,obDispWid(a0)
; ---------------------------------------------------------------------------

Bas_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BasAction_Index(pc,d0.w),d1
		jmp		BasAction_Index(pc,d1.w)
; ===========================================================================

BasAction_Index:		offsetTable
		offsetTableEntry.w Bas_DropChk
		offsetTableEntry.w Bas_DropFly
		offsetTableEntry.w Bas_FlapSound
		offsetTableEntry.w Bas_FlyUp
; ===========================================================================

Bas_DropChk:
		move.w	#128,d2
		bsr.w	Bas_ChkDist				; cmp d2 to x dist between Sonic and basaran
		bcc.s	.nodrop					; branch if x dist > 128px
		move.w	(v_player+obY).w,d0
		move.w	d0,obBas_SonicPosY(a0)
		sub.w	obY(a0),d0
		bcs.s	.nodrop					; branch if Sonic is above the basaran
		cmpi.w	#128,d0					; is Sonic < 128 pixels from basaran?
		bhs.s	.nodrop					; if not, branch
		tst.w	(v_debuguse).w			; is debug mode	on?
		bne.s	.nodrop					; if yes, branch

		move.b	(v_vbla_byte).w,d0		; get byte that increments every frame
		add.b	d7,d0					; add object index number (so each basaran updates on a different frame)
		andi.b	#7,d0					; read only bits 0-2
		bne.s	.nodrop					; branch if any are set
		move.b	#1,obAnim(a0)
		addq.b	#2,ob2ndRout(a0)		; -> Bas_DropFly

	.nodrop:
		lea		Ani_Bas(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Bas_DropFly:
		bsr.w	SpeedToPos_YOnly
		addi.w	#$18,obVelY(a0)			; make basaran fall
		move.w	#128,d2
		bsr.w	Bas_ChkDist				; update xflip flag and get direction to fly
		move.w	obBas_SonicPosY(a0),d0
		sub.w	obY(a0),d0
		bcs.s	.chkdel					; branch if Sonic is above the basaran
		cmpi.w	#16,d0					; is basaran close to Sonic vertically?
		bhs.s	.animate				; if not, branch
		move.w	d1,obVelX(a0)			; make basaran fly horizontally
		clr.w	obVelY(a0)				; stop basaran falling
		move.b	#2,obAnim(a0)
		addq.b	#2,ob2ndRout(a0)		; -> Bas_FlapSound

	.animate:
		lea		Ani_Bas(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

	.chkdel:
		tst.b	obRender(a0)			; is basaran onscreen?
		; Clownacy DisplaySprite Fix
		bmi.s	.animate				; if yes, branch
		addq.l	#4,sp
		bra.w	DeleteObject
; ===========================================================================

Bas_FlapSound:
		moveq	#$F,d0
		and.b	(v_vbla_byte).w,d0		; get low nybble of byte that increments every frame
		bne.s	.nosound				; branch if not 0
		move.w	#sfx_Basaran,d0
		jsr		(QueueSound2).w			; play flapping sound every 16th frame

	.nosound:
		bsr.w	SpeedToPos_XOnly
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.sonic_right			; if Sonic is right of basaran, branch
		neg.w	d0						; d0 = x dist between Sonic and basaran

	.sonic_right:
		cmpi.w	#128,d0					; is Sonic within 128 pixels of basaran?
		blo.s	.dontflyup				; if yes, branch
		move.b	(v_vbla_byte).w,d0		; get byte that increments every frame
		add.b	d7,d0					; add OST index number (so each batbrain updates on a different frame)
		andi.b	#7,d0					; read only bits 0-2
		bne.s	.dontflyup				; branch if any are set
		addq.b	#2,ob2ndRout(a0)		; -> Bat_FlyUp

	.dontflyup:
		lea		Ani_Bas(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

Bas_FlyUp:
		bsr.w	SpeedToPos
		subi.w	#$18,obVelY(a0)			; make basaran fly upwards
		bsr.w	ObjHitCeiling
		tst.w	d1						; has basaran hit the ceiling?
		bpl.s	.noceiling				; if not, branch
		sub.w	d1,obY(a0)				; align to ceiling
		andi.w	#$FFF8,obX(a0)			; snap to tile
		moveq	#0,d0
		move.w	d0,obVelX(a0)			; stop basaran moving
		move.w	d0,obVelY(a0)
		move.b	d0,obAnim(a0)
		move.b	d0,ob2ndRout(a0)

	.noceiling:
		lea		Ani_Bas(pc),a1
		jsr		(AnimateSprite).w
		bra.w	RememberState
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to check Sonic's distance from the basaran
;
; input:
;	d2 = distance to compare
;
; output:
;	d0 = distance between Sonic and basaran
;	d1 = speed/direction for basaran to fly
; ---------------------------------------------------------------------------

Bas_ChkDist:
		move.w	#$100,d1
		bset	#staFlipX,obStatus(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcc.s	.right					; if Sonic is right of basaran, branch
		neg.w	d0
		neg.w	d1
		bclr	#staFlipX,obStatus(a0)

	.right:
		cmp.w	d2,d0
		rts
; ===========================================================================