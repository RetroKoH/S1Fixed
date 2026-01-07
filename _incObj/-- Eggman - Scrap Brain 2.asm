; ---------------------------------------------------------------------------
; Object - Eggman (SBZ2)
; ---------------------------------------------------------------------------

ScrapEggman:
		_move.l	#SEgg_Eggman,obAddr(a0)
		move.w	#boss_sbz2_x+$110,obX(a0)
		move.w	#boss_sbz2_y+$94,obY(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_SEgg,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		move.b	#$84,obRender(a0)
		move.b	#$20,obDispWid(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#$10,obColProp(a0)
		bclr	#staFlipX,obStatus(a0)

		jsr		(FindNextFreeObj).l
		bne.s	SEgg_Eggman
		_move.l	#SEgg_Switch,obAddr(a1)	; load switch object
		move.w	#boss_sbz2_x+$E0,obX(a1)
		move.w	#boss_sbz2_y+$AC,obY(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_But,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman_Button,0,0),obGfx(a1)
		move.b	#$84,obRender(a1)
		move.b	#$10,obDispWid(a1)
		move.w	a0,obSEgg_Parent(a1)		; set switch's parent to Eggman object
; ---------------------------------------------------------------------------

SEgg_Eggman:
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		cmpi.w	#128,d0						; is Sonic within 128 px of	Eggman?
		bhs.s	SEgg_Move					; if not, branch
		obj_addr	#SEgg_PreLeap
		move.b	#180,obSEgg_WaitTime(a0)	; set delay to 3 seconds
		move.b	#1,obAnim(a0)

SEgg_Move:
		jsr		(SpeedToPos).l
		lea		Ani_SEgg(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

SEgg_PreLeap:
		subq.b	#1,obSEgg_WaitTime(a0)		; subtract 1 from time delay
		bne.s	.wait						; if time remains, branch
		obj_addr	#SEgg_Leap
		move.b	#2,obAnim(a0)
		addq.w	#4,obY(a0)
		move.b	#15,obSEgg_WaitTime(a0)		; wait quarter of a second before jumping

	.wait:
		jsr		(SpeedToPos).l
		lea		Ani_SEgg(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

SEgg_Leap:
		subq.b	#1,obSEgg_WaitTime(a0)		; decrement timer
		bgt.w	.update_pos
		bne.s	.wait
		move.w	#-$FC,obVelX(a0)			; make Eggman leap
		move.w	#-$3C0,obVelY(a0)

	.wait:
		cmpi.w	#boss_sbz2_x+$E2,obX(a0)	; has Eggman reach the button?
		bgt.s	.not_at_btn					; if not, branch
		clr.w	obVelX(a0)					; stop moving horizontally

	.not_at_btn:
		addi.w	#$24,obVelY(a0)				; apply gravity
		tst.w	obVelY(a0)					; is Eggman moving downwards?
		bmi.s	.find_blocks				; if not, branch
		cmpi.w	#boss_sbz2_y+$85,obY(a0)	; has Eggman passed $595 on y axis?
		blo.s	.find_blocks				; if not, branch
		move.b	#"S",obSubtype(a0)			; set flag for button to change to pressed
		cmpi.w	#boss_sbz2_y+$8B,obY(a0)	; has Eggman passed $59B on y axis?
		blo.s	.find_blocks				; if not, branch
		move.w	#boss_sbz2_y+$8B,obY(a0)	; stop at $59B
		clr.w	obVelY(a0)					; stop falling

	.find_blocks:
		move.w	obVelX(a0),d0
		or.w	obVelY(a0),d0
		bne.s	.update_pos					; branch if Eggman is moving at all

		lea		(v_lvlobjspace-object_size).w,a1	; FixBugs
		moveq	#v_lvlobjcount,d0					; FixBugs - Normally only covered the first half of object RAM.

	.loop:
		lea		object_size(a1),a1			; jump to next object RAM
		; is object a block? (object $83) (d1 = obAddr)?
		cmp_addr	#FalseFloor,obAddr(a1),d1
		dbeq	d0,.loop					; if not, repeat (max $3E times)

		bne.s	.update_pos
		move.b	#"G",obSubtype(a1)			; set block to disintegrate
		obj_addr	#SEgg_Move
		move.b	#1,obAnim(a0)

	.update_pos:
		jsr		(SpeedToPos).l
		lea		Ani_SEgg(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Object (sub) - Eggman's Switch (SBZ2)
; ---------------------------------------------------------------------------

SEgg_Switch:
		movea.w	obSEgg_Parent(a0),a1		; get address of parent object (Eggman)
		cmpi.b	#"S",obSubtype(a1)			; has subtype been changed?
		bne.s	SEgg_BtnDisplay				; if not, branch
		move.b	#1,obFrame(a0)				; use pressed frame
		obj_addr	#DisplaySprite

	if GiantRingsInSBZ	; Mercury Giant Rings In SBZ
		cmpi.w	#50,(v_rings).w	; do you have at least 50 rings?
		blt.s	SEgg_BtnDisplay
		move.w	#boss_sbz2_y+$E0,(v_limitbtm_target).w	; $600 by default
	endif	; Giant Rings In SBZ end
; ---------------------------------------------------------------------------

SEgg_BtnDisplay:
		jmp	(DisplaySprite).l
; ===========================================================================