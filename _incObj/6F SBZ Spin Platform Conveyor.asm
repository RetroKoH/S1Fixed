; ---------------------------------------------------------------------------
; Object 6F - spinning platforms that move around a conveyor belt (SBZ)
; ---------------------------------------------------------------------------

SpinConvey:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	SpinC_Action
	; Object Routine Optimization End
; ===========================================================================

SpinC_Main:	; Routine 0
	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		bsr.s	SpinC_Rout1
		offscreen.s	loc_1629A,lcon_origx(a0)	; ProjectFM
SpinC_Display:	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		jmp		(DisplaySprite).l

loc_1629A:
		cmpi.b	#2,(v_act).w	; check if act is 3
		bne.s	SpinC_Act1or2	; if not, branch
		cmpi.w	#-$80,d0
		bhs.s	SpinC_Display

SpinC_Act1or2:
		move.b	lcon_spawnertype(a0),d0
		bpl.s	SpinC_Delete
		andi.w	#$7F,d0
		lea		(v_conveyactive).w,a2
		bclr	#0,(a2,d0.w)

SpinC_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

SpinC_Rout1:
		move.b	obSubtype(a0),d0			; is this the conveyor group spawner?
		bmi.w	SpinC_Spawner				; if yes (subtype >= $80), branch

	; Continue onward for platforms created by the spawner
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Spin,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Spinning_Platform,0,0),obGfx(a0)
		move.b	#$10,obActWid(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get platform subtype assigned by spawner (based on 3rd word in ObjPosSBZPlatform_Index)
		move.w	d0,d1						; copy to d1
		lsr.w	#3,d0						; d0 = (platform subtype // 8) floor division. Result will be an even number (0, 2, 4, etc.)
		andi.w	#$1E,d0						; cap d0 to $1E (no odd values) -- Only 0-$A is used
		lea		SpinC_Data(pc),a2
		adda.w	(a2,d0.w),a2				; load correct data based on the platform subtype
		move.w	(a2)+,lcon_origy(a0)
		move.w	(a2)+,lcon_origx(a0)
		move.l	a2,lcon_dataaddr(a0)		; address of this data set (4 bytes)
		andi.w	#$F,d1						; get lowest nybble of the platform subtype
		lsl.w	#2,d1						; multiply by 4
		move.b	d1,lcon_origy(a0)			; store this value in $38(a0)
		move.b	#4,lcon_flag(a0)			; $3A(a0) is intialized to #4
		tst.b	(f_conveyrev).w				; have conveyors been reversed?
		beq.s	loc_16356					; if not, branch
		move.b	#1,lcon_flag2(a0)			; set platform's local reverse flag
		neg.b	lcon_flag(a0)				; negate this value to -4
		moveq	#0,d1
		move.b	lcon_origy(a0),d1
		add.b	lcon_flag(a0),d1
		cmp.b	lcon_origy+1(a0),d1
		blo.s	loc_16352
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	loc_16352
		move.b	lcon_origy+1(a0),d1
		subq.b	#4,d1

loc_16352:
		move.b	d1,lcon_origy(a0)

loc_16356:
		move.w	(a2,d1.w),lcon_targetx(a0)	; set target x-position
		move.w	2(a2,d1.w),lcon_targety(a0)	; set target y-position
		tst.w	d1
		bne.s	loc_1636C
		move.b	#1,obAnim(a0)

loc_1636C:
		cmpi.w	#8,d1
		bne.s	loc_16378
		clr.b	obAnim(a0)

loc_16378:
		bsr.w	LCon_SetInMotion
		bra.w	SpinC_Action
; ===========================================================================

SpinC_Spawner:
		move.b	d0,lcon_spawnertype(a0)			; move spawner subtype to $2F(a0)
		andi.w	#$7F,d0							; clear upper-most bit of subtype to isolate platform group ID
		lea		(v_conveyactive).w,a2
		bset	#0,(a2,d0.w)					; set this group's respective bit
		beq.s	loc_1639A
		jmp		(DeleteObject).l				; if it was already set, delete this spawner object, as it's not needed.
; ===========================================================================

loc_1639A:
		add.w	d0,d0							; multiply platform group ID by 2 (use for word AND longword pointers)
		add.w	d0,d0							; multiply platform group ID by 4 (use only for longword pointers)
		andi.w	#$1E,d0							; capped at $10 groups of platforms (0-$F)

	; RetroKoH Object Loading Optimization
		lea		(ObjPosSBZPlatform_Index).l,a2	; Next, we load the first pointer in the object layout list pointer index,
		movea.l (a2,d0.w),a2					; Changed from adda.w to movea.l for longword object layout pointers
;		adda.w	(a2,d0.w),a2					; a2 = positioning data for this platform group (use only for word-length pointers)

		move.w	(a2)+,d1						; d1 = number of platforms minus 1
		movea.l	a0,a1

	; RetroKoH Mass Object Load Optimization (Based on SpirituInsanum's Ring Loss Optimization)
	; Create the first instance, then loop to create the others afterward.
.firstPlatform:
		_move.b	#id_SpinConvey,obID(a1)
		move.w	(a2)+,obX(a1)			; set x-position
		move.w	(a2)+,obY(a1)			; set y-position
		move.w	(a2)+,d0
		move.b	d0,obSubtype(a1)		; set subtype, discarding upper byte
		subq	#1,d1					; decrement for the first platform created
		bmi.s	.endloop				; if, somehow, only one platform is needed, skip

		; Here we begin what's replacing FindFreeObj, in order to avoid resetting its d0 every time an object is created.
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d2

.loop:
		; REMOVE FindFreeObj. It's the routine that causes such slowdown
		tst.b	obID(a1)				; is object RAM	slot empty?
		beq.s	.makePtfms				; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		object_size(a1),a1
		dbf		d2,.loop				; Branch correction again.
		bne.s	.endloop

.makePtfms:
		_move.b	#id_SpinConvey,obID(a1)
		move.w	(a2)+,obX(a1)			; set x-position
		move.w	(a2)+,obY(a1)			; set y-position
		move.w	(a2)+,d0
		move.b	d0,obSubtype(a1)		; set subtype, discarding upper byte
		dbf		d1,.loop				; repeat for number of platforms

.endloop:
		addq.l	#4,sp
		rts	
; ===========================================================================

SpinC_Action:	; Routine 2
	; Clownacy DisplaySprite Fix (Alt Method by RetroKoH)
		bsr.s	SpinC_Rout2
		offscreen.w	loc_1629A,lcon_origx(a0)
		jmp		(DisplaySprite).l

SpinC_Rout2:
		lea		Ani_SpinConvey(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)
		bne.s	loc_16404
		move.w	obX(a0),-(sp)
		bsr.w	loc_16424
		move.w	#$1B,d1
		move.w	#7,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	(sp)+,d4
		jmp		(SolidObject).l
; ===========================================================================

loc_16404:
		btst	#staSonicOnObj,obStatus(a0)
		beq.s	loc_16424
		lea		(v_player).w,a1
		bclr	#staOnObj,obStatus(a1)
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid

loc_16424:
		move.w	obX(a0),d0
		cmp.w	lcon_targetx(a0),d0
		bne.s	loc_16484
		move.w	obY(a0),d0
		cmp.w	lcon_targety(a0),d0
		bne.s	loc_16484
		moveq	#0,d1
		move.b	lcon_origy(a0),d1
		add.b	lcon_flag(a0),d1
		cmp.b	lcon_origy+1(a0),d1
		blo.s	loc_16456
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	loc_16456
		move.b	lcon_origy+1(a0),d1
		subq.b	#4,d1

loc_16456:
		move.b	d1,lcon_origy(a0)
		movea.l	lcon_dataaddr(a0),a1
		move.w	(a1,d1.w),lcon_targetx(a0)
		move.w	2(a1,d1.w),lcon_targety(a0)
		tst.w	d1
		bne.s	loc_16474
		move.b	#1,obAnim(a0)

loc_16474:
		cmpi.w	#8,d1
		bne.s	loc_16480
		clr.b	obAnim(a0)

loc_16480:
		bsr.w	LCon_SetInMotion

loc_16484:
		jmp		(SpeedToPos).l
; ===========================================================================

SpinC_Data:		offsetTable
		offsetTableEntry.w	word_164B2
		offsetTableEntry.w	word_164C6
		offsetTableEntry.w	word_164DA
		offsetTableEntry.w	word_164EE
		offsetTableEntry.w	word_16502
		offsetTableEntry.w	word_16516

word_164B2:
		dc.w	$10, $E80
				; target x
						; target y
		dc.w	$E14, $370
		dc.w	$EEF, $302
		dc.w	$EEF, $340
		dc.w	$E14, $3AE

word_164C6:
		dc.w	$10, $F80
				; target x
						; target y
		dc.w	$F14, $2E0
		dc.w	$FEF, $272
		dc.w	$FEF, $2B0
		dc.w	$F14, $31E

word_164DA:
		dc.w	$10, $1080
				; target x
						; target y
		dc.w	$1014, $270
		dc.w	$10EF, $202
		dc.w	$10EF, $240
		dc.w	$1014, $2AE

word_164EE:
		dc.w	$10, $F80
				; target x
						; target y
		dc.w	$F14, $570
		dc.w	$FEF, $502
		dc.w	$FEF, $540
		dc.w	$F14, $5AE

word_16502:
		dc.w	$10, $1B80
				; target x
						; target y
		dc.w	$1B14, $670
		dc.w	$1BEF, $602
		dc.w	$1BEF, $640
		dc.w	$1B14, $6AE

word_16516:
		dc.w $10, $1C80
				; target x
						; target y
		dc.w	$1C14, $5E0
		dc.w	$1CEF, $572
		dc.w	$1CEF, $5B0
		dc.w	$1C14, $61E
