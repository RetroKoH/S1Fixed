; ---------------------------------------------------------------------------
; Object - Final Boss
; ---------------------------------------------------------------------------
; OST Constants
obBFZ_CylFlag:			equ objoff_30		; 2 bytes | -1 when cylinders activate; id of cylinder Eggman is in when crushing
obBFZ_PhaseState:		equ objoff_32		; 2 bytes | 1 = crushing; 0 = plasma; -1 = crushing/plasma complete
obBFZ_Mode:				equ objoff_34		; 1 byte  | action being performed, increments of 2
obBFZ_FlashNum:			equ objoff_35		; 1 byte  | number of times to make boss flash when hit
obBFZ_ChildPlasma:		equ objoff_36		; 2 bytes | Obj RAM addresses of plasma object
obBFZ_ChildCylinder:	equ objoff_38		; 8 bytes | Obj RAM addresses of cylinder objects

obBFZ_Parent:			equ objoff_3E		; 2 bytes | address of parent object - children only
; ---------------------------------------------------------------------------

BossFinal_Delete:
		jmp	(DeleteObject).l
; ===========================================================================

BossFinal_ObjData:
		dc.l BossFinal_Eggman, Map_SEgg										; object address, mappings pointer
		dc.w $100, $100, make_art_tile(ArtTile_FZ_Eggman_No_Vehicle,0,0)	; X pos, Y pos,	VRAM setting

		dc.l BossFinal_Panel, Map_EggCyl
		dc.w boss_fz_x+$160, boss_fz_y+$80, make_art_tile(ArtTile_FZ_Boss,0,0)

		dc.l BossFinal_Legs, Map_FZLegs
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_FZ_Eggman_Fleeing,0,0)

		dc.l BossFinal_Cockpit, Map_SEgg
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_FZ_Eggman_No_Vehicle,0,0)

		dc.l BossFinal_EmptyShip, Map_Eggman
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_Eggman,0,0)

BossFinal_ObjData2:
	; 			width,
	;					height
		dc.b	$20,	$19		
		dc.w	priority4
		dc.b	$12,	8		
		dc.w	priority1
		dc.b	0,		0		
		dc.w	priority3
		dc.b	0,		0		
		dc.w	priority3
		dc.b	$20,	$20		
		dc.w	priority3
; ===========================================================================

BossFinal:
		lea		BossFinal_ObjData(pc),a2
		lea		BossFinal_ObjData2(pc),a3
		movea.l	a0,a1					; replace current object with 1st in list (BossFinal_Eggman)
		moveq	#4,d1					; 4 additional objects (BossFinal_Panel, BossFinal_Legs, BossFinal_Cockpit, BossFinal_EmptyShip)
		bra.s	.load_boss
; ===========================================================================

	.loop:
		jsr		(FindNextFreeObj).l
		bne.s	.fail						; branch if not found

	.load_boss:
		_move.l	(a2)+,obAddr(a1)
		move.l	(a2)+,obMap(a1)
		move.w	(a2)+,obX(a1)
		move.w	(a2)+,obY(a1)
		move.w	(a2)+,obGfx(a1)
		move.b	(a3)+,obDispWid(a1)
		move.b	(a3)+,obHeight(a1)
		move.w	(a3)+,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#4,obRender(a1)
		bset	#renVisible,obRender(a0)	; set a0 object as visible (why is this in the loop?)
		move.w	a0,obBFZ_Parent(a1)			; save obj RAM address of parent (BossFinal_Eggman)
		dbf		d1,.loop					; repeat 4 more times
; ---------------------------------------------------------------------------

	.fail:
		lea		obBFZ_ChildPlasma(a0),a2
		jsr		(FindFreeObj).l
		bne.s	.fail2						; branch if not found
		_move.l	#BossPlasma,obAddr(a1)		; load energy ball object
		move.w	a1,(a2)						; save obj address of plasma launcher in parent OST
		move.w	a0,obPlasma_Parent(a1)		; save parent address in plasma OST

		lea		obBFZ_ChildCylinder(a0),a2
		moveq	#0,d2
		moveq	#3,d1						; spawn 4 crushers

	.loop_crushers:
		jsr		(FindNextFreeObj).l
		bne.s	.fail2						; branch if not found
		move.w	a1,(a2)+					; save obj address of crusher in parent OST
		_move.l	#EggmanCylinder,obAddr(a1)	; load crushing cylinder object
		move.w	a0,obECyl_Parent(a1)		; save parent address in crusher OST
		move.b	d2,obSubtype(a1)			; set subtype to 0/2/4/6
		addq.w	#2,d2						; next subtype
		dbf		d1,.loop_crushers			; repeat for all crushers

	.fail2:
		clr.w	obBFZ_Mode(a0)				; -> BFZ_Eggman_Wait (and clear FlashNum)
		move.b	#1,obColProp(a0)			; set number of hits to 8
		move.w	#-1,obBFZ_CylFlag(a0)		; set crushers to activate
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Object (sub) - Eggman (FZ)
; ---------------------------------------------------------------------------

BossFinal_Eggman:
		moveq	#0,d0
		move.b	obBFZ_Mode(a0),d0
		move.w	BFZ_Eggman_Index(pc,d0.w),d0
		jsr		BFZ_Eggman_Index(pc,d0.w)
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

BFZ_Eggman_Index:		offsetTable
		offsetTableEntry.w BossFinal_EggWait
		offsetTableEntry.w BossFinal_EggCrush
		offsetTableEntry.w BossFinal_EggPlasma
		offsetTableEntry.w BossFinal_EggDefeated
		offsetTableEntry.w BossFinal_EggRun
		offsetTableEntry.w BossFinal_EggJump
		offsetTableEntry.w BossFinal_EggShip
		offsetTableEntry.w BossFinal_EggEscape
; ===========================================================================

BossFinal_EggWait:		; Boss Routine 0
		tst.l	(v_plc_buffer).w			; is pattern load cue buffer empty?
		bne.s	.wait						; if not, branch
		cmpi.w	#boss_fz_x,(v_screenposx).w	; has camera reached boss arena?
		blo.s	.wait						; if not, branch
		addq.b	#2,obBFZ_Mode(a0)			; -> BossFinal_EggCrush

	.wait:
		addq.l	#1,(v_random).w				; increment random number
		rts	
; ===========================================================================

BossFinal_EggCrush:		; Boss Routine 2
		tst.w	obBFZ_CylFlag(a0)			; are crushers set to activate?
		bpl.s	.skip_crushers				; if not, branch
		clr.w	obBFZ_CylFlag(a0)
		jsr		(RandomNumber).w			; get random number
		andi.w	#$C,d0						; low word of d0 = 0/4/8/$C (high word is kept)
		move.w	d0,d1
		addq.w	#2,d1						; add 2 to copy in d1
		tst.l	d0
		bpl.s	.d0_is_pos					; branch if high word was positive
		exg		d1,d0						; swap d0 and d1

	.d0_is_pos:
		lea		BFZ_CylPattern(pc),a1
		move.w	(a1,d0.w),d0				; get value for first cylinder (0/2/4/6)
		move.w	(a1,d1.w),d1				; get value for second cylinder (0/2/4/6)
		move.w	d0,obBFZ_CylFlag(a0)
		moveq	#-1,d2
		move.w	obBFZ_ChildCylinder(a0,d0.w),d2
		movea.l	d2,a1						; a1 = OST address for first cylinder
		move.b	#-1,obECyl_ExtendFlag(a1)	; activate that cylinder
		move.w	#-1,obECyl_EggFlag(a1)
		move.w	obBFZ_ChildCylinder(a0,d1.w),d2
		movea.l	d2,a1						; a1 = OST address for second cylinder
		move.b	#1,obECyl_ExtendFlag(a1)	; activate that cylinder
		clr.w	obECyl_EggFlag(a1)
		move.w	#1,obBFZ_PhaseState(a0)
		clr.b	obBFZ_FlashNum(a0)
		move.w	#sfx_Rumbling,d0
		jsr		(QueueSound2).w				; play rumbling sound

	.skip_crushers:
		tst.w	obBFZ_PhaseState(a0)
		bmi.w	.crush_complete				; branch if cylinders have finished crushing process
		bclr	#staFlipX,obStatus(a0)		; Eggman faces left
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	.sonic_is_left				; branch if Sonic is left of Eggman
		bset	#staFlipX,obStatus(a0)		; Eggman faces right

	.sonic_is_left:
		moveq	#43,d1						; width; save 4 cycles -- Filter
		moveq	#20,d2						; height (jumping); save 4 cycles -- Filter
		moveq	#20,d3						; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4					; axis position
		jsr		(SolidObject).l
		tst.w	d4
		bgt.s	.side_collision				; branch if Sonic touches the side of the cylinder with Eggman

	.just_solid:
		tst.b	obBFZ_FlashNum(a0)			; is boss flashing from hit?
		bne.s	.flash						; if yes, branch
		bra.s	.missed
; ===========================================================================

	.side_collision:
		addq.w	#7,(v_random).w
		cmpi.b	#aniID_Roll,(v_player+obAnim).w	; is Sonic rolling/jumping?
		bne.s	.just_solid					; if not, branch
		move.w	#$300,d0					; rebound Sonic right
		btst	#staFlipX,obStatus(a0)		; is Eggman facing right?
		bne.s	.eggman_face_right			; if yes, branch
		neg.w	d0							; rebound Sonic left

	.eggman_face_right:
		move.w	d0,(v_player+obVelX).w		; set rebound speed for Sonic
		tst.b	obBFZ_FlashNum(a0)			; is boss flashing from hit?
		bne.s	.flash						; if yes, branch
	; Mercury FZ Boss Hitcount Fix
		tst.b	obColProp(a0)				; has the boss been defeated?
		beq.s	.animate					; if so, don't let it be hit again.
	; FZ Boss Hitcount Fix End

		subq.b	#1,obColProp(a0)			; decrement hit counter
		move.b	#100,obBFZ_FlashNum(a0)		; flash 100 times
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w				; play boss damage sound

	.flash:
		subq.b	#1,obBFZ_FlashNum(a0)		; decrement flash counter
		beq.s	.missed						; branch if 0
		moveq	#3,d0						; in-cylinder animation
		bra.s	.new_anim					; animate
; ===========================================================================

	.missed:
        ; If eggman is defeated, don't display the "laughing" animation and branch -- Jeor489 fix
        tst.b   obColProp(a0)
        beq.w   .animate

		moveq	#1,d0						; laugh animation

	.new_anim:
		jsr		(NewAnim).w

	.animate:
		lea		Ani_SEgg(pc),a1
		jmp		(AnimateSprite).w
; ===========================================================================

	.crush_complete:
		tst.b	obColProp(a0)				; has boss been beaten?
		beq.s	.beaten						; if yes, branch
		addq.b	#2,obBFZ_Mode(a0)			; -> BossFinal_EggPlasma
		move.w	#-1,obBFZ_CylFlag(a0)
		clr.w	obBFZ_PhaseState(a0)
		rts	
; ===========================================================================

	.beaten:
		moveq	#100,d0
		bsr.w	AddPoints					; give Sonic 1000 points
		move.b	#6,obBFZ_Mode(a0)			; -> BossFinal_EggDefeated
		move.w	#boss_fz_x+$170,obX(a0)
		move.w	#boss_fz_y+$2C,obY(a0)
		move.b	#$14,obHeight(a0)
		rts	
; ===========================================================================

BFZ_CylPattern:
		dc.w cyl_bottom_left, cyl_bottom_right
		dc.w cyl_bottom_right, cyl_top_left
		dc.w cyl_top_left, cyl_top_right
		dc.w cyl_top_right, cyl_bottom_left

cyl_bottom_left:	equ 0
cyl_bottom_right:	equ 2
cyl_top_left:		equ 4
cyl_top_right:		equ 6
; ===========================================================================

BossFinal_EggPlasma:		; Boss Routine 4
		moveq	#-1,d0
		move.w	obBFZ_ChildPlasma(a0),d0
		movea.w	d0,a1						; get RAM address of plasma launcher
		tst.w	obBFZ_CylFlag(a0)			; has crushing process just finished?
		bpl.s	.skip_plasma				; if not, branch
		clr.w	obBFZ_CylFlag(a0)
		move.b	#-1,obPlasma_Enabled(a1)	; activate plasma launcher
		bsr.s	.electric_sound

	.skip_plasma:
		moveq	#$F,d0
		and.w	(v_vbla_word).w,d0			; get word that increments every frame (already optimized)
		bne.s	.skip_sound					; branch if any of bits 0-3 are set
		bsr.s	.electric_sound				; play sound every 16th frame

	.skip_sound:
		tst.w	obBFZ_PhaseState(a0)		; is plasma phase complete?
		beq.s	.wait						; if not, branch
		subq.b	#2,obBFZ_Mode(a0)			; goto BFZ_Eggman_Crush
		move.w	#-1,obBFZ_CylFlag(a0)		; set flag to begin crushing phase
		clr.w	obBFZ_PhaseState(a0)

	.wait:
		rts	
; ===========================================================================

	.electric_sound:
		move.w	#sfx_Electric,d0
		jmp		(QueueSound2).w				; play electricity sound
; ===========================================================================

BossFinal_EggDefeated:		; Boss Routine 6
		move.b	#$30,obDispWid(a0)
		bset	#staFlipX,obStatus(a0)		; Eggman faces right
		jsr		(SpeedToPos).l				; update position
		move.b	#6,obFrame(a0)				; use jumping frame
		addi.w	#$10,obVelY(a0)				; apply gravity
		cmpi.w	#boss_fz_y+$8C,obY(a0)		; has Eggman reached bottom of tube?
		blo.w	BFZ_Eggman_Scroll			; if not, branch
		move.w	#boss_fz_y+$8C,obY(a0)		; align to bottom of tube
		addq.b	#2,obBFZ_Mode(a0)			; goto BFZ_Eggman_Run
		move.b	#$20,obDispWid(a0)
		move.w	#$100,obVelX(a0)			; move right
		move.w	#-$100,obVelY(a0)			; bounce up
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 elsewhere -- Filter Optimized DLE Manager
		bra.w	BFZ_Eggman_Scroll
; ===========================================================================

BossFinal_EggRun:		; Boss Routine 8
		bset	#staFlipX,obStatus(a0)		; Eggman faces right
		moveq	#4,d0						; use running animation
		jsr		(NewAnim).w
		jsr		(SpeedToPos).l
		addi.w	#$10,obVelY(a0)				; apply gravity
		cmpi.w	#boss_fz_y+$93,obY(a0)		; has Eggman hit the floor?
		blo.s	.keep_falling				; if not, branch
		move.w	#-$40,obVelY(a0)			; bounce off floor

	.keep_falling:
		move.w	#$400,obVelX(a0)			; move right
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		bpl.s	.sonic_is_left				; branch if Sonic is left of Eggman
		move.w	#$500,obVelX(a0)			; move right faster
		bra.w	.chk_ship
; ===========================================================================

	.sonic_is_left:
		subi.w	#$70,d0
		bcs.s	.chk_ship
		subi.w	#$100,obVelX(a0)			; slow Eggman down the further Sonic is from him
		subq.w	#8,d0
		bcs.s	.chk_ship
		subi.w	#$100,obVelX(a0)
		subq.w	#8,d0
		bcs.s	.chk_ship
		subi.w	#$80,obVelX(a0)
		subq.w	#8,d0
		bcs.s	.chk_ship
		subi.w	#$80,obVelX(a0)
		subq.w	#8,d0
		bcs.s	.chk_ship
		subi.w	#$80,obVelX(a0)
		subi.w	#$38,d0
		bcs.s	.chk_ship
		clr.w	obVelX(a0)

	.chk_ship:
		cmpi.w	#boss_fz_x+$250,obX(a0)		; has Eggman reached his ship?
		blo.s	BFZ_Eggman_AnimScroll		; if not, branch
		move.w	#boss_fz_x+$250,obX(a0)		; align to position
		move.w	#$240,obVelX(a0)			; move right
		move.w	#-$4C0,obVelY(a0)			; jump up
		addq.b	#2,obBFZ_Mode(a0)			; -> BFZ_Eggman_Jump
		bra.s	BFZ_Eggman_AnimScroll
; ===========================================================================

BossFinal_EggJump:		; Boss Routine $A
		jsr		(SpeedToPos).l
		cmpi.w	#boss_fz_x+$290,obX(a0)		; is Eggman directly above his ship?
		blo.s	.not_above_ship				; if not, branch
		clr.w	obVelX(a0)					; stop moving right (drops vertically instead)

	.not_above_ship:
		addi.w	#$34,obVelY(a0)				; apply gravity
		tst.w	obVelY(a0)
		bmi.s	.not_in_ship				; branch if moving upwards
		cmpi.w	#boss_fz_y+$82,obY(a0)		; is Eggman in his ship?
		blo.s	.not_in_ship				; if not, branch
		move.w	#boss_fz_y+$82,obY(a0)		; align to ship
		clr.w	obVelY(a0)					; stop falling

	.not_in_ship:
		move.w	obVelX(a0),d0
		or.w	obVelY(a0),d0
		bne.s	BFZ_Eggman_AnimScroll		; branch if Eggman is still moving/falling
		addq.b	#2,obBFZ_Mode(a0)			; -> BFZ_Eggman_Ship
		move.w	#-$180,obVelY(a0)			; move Eggman up
		move.b	#1,obColProp(a0)			; give Eggman a single hit point

BFZ_Eggman_AnimScroll:
		lea		Ani_SEgg(pc),a1
		jsr		(AnimateSprite).w

BFZ_Eggman_Scroll:
		cmpi.w	#boss_fz_end,(v_limitright).w	; check for new boundary
		bge.s	.chk_ship
		addq.w	#2,(v_limitright).w			; expand right edge of level boundary

	.chk_ship:
		cmpi.b	#$C,obBFZ_Mode(a0)			; is Eggman in his ship?
		bge.s	.not_solid					; if yes, branch
		moveq	#27,d1						; width; save 4 cycles -- Filter
		moveq	#112,d2						; height (jumping); save 4 cycles -- Filter
		moveq	#113,d3						; height (walking); save 4 cycles -- Filter
		move.w	obX(a0),d4					; axis position
		jmp		(SolidObject).l				; make object solid
; ===========================================================================

	.not_solid:
		rts	
; ===========================================================================

BossFinal_EggShip:		; Boss Routine $C
		move.l	#Map_Eggman,obMap(a0)		; use standard boss ship mappings
		; the cockpit will now utilize the Map_BossFace mappings
		clr.b	obFrame(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		bset	#staFlipX,obStatus(a0)		; ship faces right
		jsr		(SpeedToPos).l
		cmpi.w	#boss_fz_y+$34,obY(a0)		; has ship reached a certain height?
		bhs.w	BFZ_Eggman_Scroll			; if not, branch
		move.w	#$180,obVelX(a0)			; move right
		move.w	#-$18,obVelY(a0)			; move up slowly
		move.b	#(colEnemy|colSz_24x24),obColType(a0)	; enable collision
		addq.b	#2,obBFZ_Mode(a0)			; -> BFZ_Eggman_Escape

		jsr		(FindNextFreeObj).l			; find free OST slot
		bne.s	.keep_rising				; branch if not found
		_move.l	#BossFlame,obAddr(a1)
		move.w	#$180,obBossFlame_Escape(a1)	; set speed at which ship escapes
		move.w	a0,obBossFlame_Parent(a1)		; save address of OST of parent

	.keep_rising:
		bra.w	BFZ_Eggman_Scroll			; scroll screen
; ===========================================================================

BossFinal_EggEscape:		; Boss Routine $E
		bset	#staFlipX,obStatus(a0)		; ship faces right
		jsr		(SpeedToPos).l
		tst.w	obBFZ_CylFlag(a0)			; this flag is repurposed as a timer
		bne.s	.skip_sound					; branch if time remains
		tst.b	obColType(a0)				; has ship been hit?
		bne.s	.chk_sonic					; if not, branch
		move.w	#$1E,obBFZ_CylFlag(a0)		; set timer
		move.w	#sfx_HitBoss,d0
		jsr		(QueueSound2).w				; play boss damage sound every 0.5 seconds

	.skip_sound:
		subq.w	#1,obBFZ_CylFlag(a0)		; decrement timer
		bne.s	.chk_sonic					; branch if time remains
		tst.b	obStatus(a0)				; is ship on-screen?
		bpl.s	.off_screen					; if not, branch
		move.w	#$60,obVelY(a0)				; move ship down
		bra.s	.chk_sonic
; ===========================================================================

	.off_screen:
		move.b	#(colEnemy|colSz_24x24),obColType(a0)

	.chk_sonic:
		cmpi.w	#boss_fz_end+$90,(v_player+obX).w	; is Sonic at ledge?
		blt.s	.not_at_ledge						; if not, branch
		move.b	#1,(f_lockctrl).w					; disable controls 
		clr.w	(v_jpadheld_dup).w					; clear held input
		clr.w	(v_player+obInertia).w				; stop Sonic moving
		tst.w	obVelY(a0)
		bpl.s	.chk_ship							; branch if ship is moving down
		move.w	#btnUp<<8,(v_jpadheld_dup).w		; force Sonic to look up

	.not_at_ledge:
		cmpi.w	#boss_fz_end+$E0,(v_player+obX).w	; is Sonic on the outer edge?
		blt.s	.chk_ship							; if not, branch
		move.w	#boss_fz_end+$E0,(v_player+obX).w	; align to edge (doesn't work if he's jumping)

	.chk_ship:
		cmpi.w	#boss_fz_end+$200,obX(a0)			; has ship moved off the screen?
		blo.w	BFZ_Eggman_Scroll					; if not, branch
		tst.b	obRender(a0)						; is ship on-screen?
		bmi.w	BFZ_Eggman_Scroll					; if not, branch
		move.b	#id_Ending,(v_gamemode).w			; goto ending sequence
		addq.l	#4,sp								; Clownacy DisplaySprite Fix
		bra.w	BossFinal_Delete					; delete ship
; ===========================================================================

BossFinal_Update:
		movea.w	obBFZ_Parent(a0),a1					; get address of parent object (BossFinal_Eggman)
		move.w	obX(a1),obX(a0)						; match position with parent
		move.w	obY(a1),obY(a0)

BossFinal_Update_SkipPos:
		movea.w	obBFZ_Parent(a0),a1					; get address of parent object (BossFinal_Eggman)
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)					; ignore x/yflip bits
		or.b	d0,obRender(a0)						; combine x/yflip bits from status instead
		jmp		(DisplayAndCollision).l				; S3K TouchResponse
; ===========================================================================

; ---------------------------------------------------------------------------
; Object (sub) - Eggman's ship cockpit (FZ)
; ---------------------------------------------------------------------------

BossFinal_Cockpit:
		movea.w	obBFZ_Parent(a0),a1					; get address of parent object (BossFinal_Eggman)
		; has parent been deleted?
		cmp_addr	#BossFinal_Eggman,obAddr(a1),d0
		bne.w	BossFinal_Delete					; if yes, branch
		cmpi.l	#Map_Eggman,obMap(a1)				; is Eggman in his ship?
		beq.s	.chk_hit							; if yes, branch
		move.b	#$A,obFrame(a0)						; use empty cockpit frame
		bra.s	BossFinal_Update_SkipPos
; ===========================================================================

	.chk_hit:
		tst.b	obColProp(a1)						; has ship been hit?
		ble.s	.explode							; if yes, branch
		moveq	#aniID_PanicFace,d0					; sweating panicked expression
		jsr		(NewAnim).w
		move.l	#Map_BossFace,obMap(a0)				; use boss face mappings
		move.w	#make_art_tile(ArtTile_Eggman_Face,0,0),obGfx(a0)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	BossFace_LoadGfx
		bra.w	BossFinal_Update
; ===========================================================================

	.explode:
		tst.b	obRender(a0)						; is object on-screen?
		bpl.w	BossFinal_Delete					; if not, branch
		bsr.w	BossDefeated						; spawn explosions
		move.w	#priority2,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_FZDamaged,obMap(a0)			; use mappings for damaged ship
		move.w	#make_art_tile(ArtTile_FZ_Eggman_Fleeing,0,0),obGfx(a0)
		moveq	#0,d0
		jsr		(NewAnim).w
		lea		Ani_FZEgg(pc),a1
		jsr		(AnimateSprite).w
		bra.w	BossFinal_Update
; ===========================================================================

; ---------------------------------------------------------------------------
; Object (sub) - Eggman's ship's legs (FZ)
; ---------------------------------------------------------------------------

BossFinal_Legs:
		bset	#staFlipX,obStatus(a0)
		movea.w	obBFZ_Parent(a0),a1					; get address of parent object (BossFinal_Eggman)
		cmpi.l	#Map_Eggman,obMap(a1)				; is Eggman in his ship?
		beq.s	.animate							; if yes, branch
		bra.w	BossFinal_Update_SkipPos
; ===========================================================================

	.animate:
		move.w	obX(a1),obX(a0)						; match position to ship
		move.w	obY(a1),obY(a0)
		tst.b	obTimeFrame(a0)
		bne.s	.skip_reset							; branch if time remains for current frame
		move.b	#20,obTimeFrame(a0)					; set timer to 0.3 seconds

	.skip_reset:
		subq.b	#1,obTimeFrame(a0)					; decrement timer
		bgt.w	BossFinal_Update					; branch if time remains
		addq.b	#1,obFrame(a0)						; next frame
		cmpi.b	#2,obFrame(a0)						; was final frame displayed?
		bgt.w	BossFinal_Delete					; if yes, branch
		bra.w	BossFinal_Update
; ===========================================================================

; ---------------------------------------------------------------------------
; Object (sub) - Eggman's metal panel (FZ)
; ---------------------------------------------------------------------------

BossFinal_Panel:
		move.b	#$B,obFrame(a0)						; control panel frame
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	.display							; branch if Sonic is left of the panel
		tst.b	obRender(a0)						; is object on-screen?
		bpl.w	BossFinal_Delete					; if not, branch

	.display:
		jmp		(DisplaySprite).l					; S3K TouchResponse
; ===========================================================================

; ---------------------------------------------------------------------------
; Object (sub) - Eggman's empty ship (FZ)
; ---------------------------------------------------------------------------

BossFinal_EmptyShip:
		clr.b	obFrame(a0)							; empty boss ship frame
		bset	#staFlipX,obStatus(a0)				; face right
		movea.w	obBFZ_Parent(a0),a1					; get address of parent object (BossFinal_Eggman)
		cmpi.b	#$C,obBFZ_Mode(a1)					; is Eggman in his ship? (pre-escaping state: BossFinal_EggShip)
		bne.w	BossFinal_Update_SkipPos			; if not, branch
		cmpi.l	#Map_Eggman,obMap(a1)				; is Eggman in his ship at all?
		beq.w	BossFinal_Delete					; if yes, branch
		bra.w	BossFinal_Update_SkipPos
; ===========================================================================