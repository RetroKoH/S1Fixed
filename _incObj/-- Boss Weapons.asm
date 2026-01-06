; ---------------------------------------------------------------------------
; Sub-Object -- Eggman's weapons during boss fights
; ---------------------------------------------------------------------------

BossWeapon:
		movea.w	obBossWeapon_Parent(a0),a2			; get address of parent object (ship)

	; Devon Boss Object Fix
		tst.l	obAddr(a2)
		beq.s	.delete								; branch if parent has been deleted
	; Boss Object Fix End

		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Weapon_Index(pc,d0.w),d1
		jsr		Weapon_Index(pc,d1.w)

		move.w	obX(a2),obX(a0)
		move.w	obY(a2),obY(a0)
		move.w	obBossWeapon_DiffY(a0),d0
		beq.s	.no_y_diff							; branch if y diff is 0
		asr.w	#2,d0
		add.w	d0,obY(a0)							; extend or retract

	.no_y_diff:
		move.b	obStatus(a2),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		tst.b	obColType(a0)
		bne.s	.collide
		jmp		(DisplaySprite).l

	.collide:
		jmp		(DisplayAndCollision).l
; ===========================================================================

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Weapon_Index:	offsetTable
		offsetTableEntry.w Weapon_Main
		offsetTableEntry.w Weapon_Done
		offsetTableEntry.w Weapon_Spike
; ===========================================================================

Weapon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> Weapon_Done
		move.l	#Map_BossItems,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$20,obDispWid(a0)
		tst.b	obSubtype(a0)
		beq.s	Weapon_Done
		addq.b	#2,obRoutine(a0)				; -> Weapon_Spike	
	; other stuff is set up by the boss itself
; ---------------------------------------------------------------------------

Weapon_Done:	; Routine 2
		rts
; ===========================================================================

Weapon_Spike:	; Routine 4
		cmpi.b	#4,ob2ndRout(a2)				; BossSYZ_ShipSpike?
		bne.s	.exit							; branch if boss isn't attacking
		cmpi.b	#6,obBoss_3rdRout(a2)			; BSYZSpike_BreakingBlock?
		beq.s	.retract						; branch if boss is breaking block
		move.b	#(colHarmful|colSz_4x16),obColType(a0)	; make spike harmful
		cmp.w	#$94,obBossWeapon_DiffY(a0)
		bge.s	.exit							; branch if spike is fully extended
		add.w	#7,obBossWeapon_DiffY(a0)
		
	.exit:
		rts
		
	.retract:
		tst.w	obBoss_DelayTime(a2)
		bpl.s	.exit							; branch if boss is shaking
		tst.w	obBossWeapon_DiffY(a0)
		bmi.s	.gone							; branch if spike is fully retracted
		sub.w	#5,obBossWeapon_DiffY(a0)
		rts
		
	.gone:
		clr.b	obColType(a0)					; make spike harmless
		rts
; ===========================================================================