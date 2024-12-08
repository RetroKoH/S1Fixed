; ---------------------------------------------------------------------------
; Object 63 - platforms	on a conveyor belt (LZ)
; ---------------------------------------------------------------------------

LabyrinthConvey:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LCon_Index(pc,d0.w),d1
		jsr		LCon_Index(pc,d1.w)
		offscreen.s	loc_1236A,lcon_origx(a0)	; PFM S3K OBJ

LCon_Display:
		bra.w	DisplaySprite
; ===========================================================================

loc_1236A:
		cmpi.b	#2,(v_act).w	; is this LZ Act 3?
		bne.s	loc_12378		; if not, branch
		cmpi.w	#-$80,d0
		bhs.s	LCon_Display

loc_12378:
		move.b	lcon_spawnertype(a0),d0
		bpl.w	DeleteObject
		andi.w	#$7F,d0
		lea		(v_conveyactive).w,a2
		bclr	#0,(a2,d0.w)
		bra.w	DeleteObject
; ===========================================================================
LCon_Index:	offsetTable
		offsetTableEntry.w LCon_Main
		offsetTableEntry.w loc_124B2
		offsetTableEntry.w loc_124C2
		offsetTableEntry.w LCon_Wheel

lcon_spawnertype = objoff_2F	; saved subtype
lcon_origx = objoff_30			; original x-position (2 bytes)
lcon_targetx = objoff_34		; target x-position to move platform towards (2 bytes)
lcon_targety = objoff_36		; target y-position to move platform towards (2 bytes)
lcon_origy = objoff_38			; original y-position (2 bytes)
lcon_flag = objoff_3A			; set to 4 or -4
lcon_flag2 = objoff_3B			; used to check if platform direction has already been reversed if the button is hit.
lcon_dataaddr = objoff_3C		; address where platform's data is located (4 bytes)
; ===========================================================================

LCon_Main:	; Routine 0
		move.b	obSubtype(a0),d0			; is this the conveyor group spawner?
		bmi.w	LCon_Spawner				; if yes (subtype >= $80), branch

	; Continue onward for platforms created by the spawner
		addq.b	#2,obRoutine(a0)
		move.l	#Map_LConv,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Conveyor_Ptfm,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#$7F,obSubtype(a0)			; is this the static conveyor wheel?
		bne.s	LCon_Platform				; if not, branch
		addq.b	#4,obRoutine(a0)			; jump straight to display routine
		move.w	#make_art_tile(ArtTile_LZ_Conveyor_Wheel,0,0),obGfx(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

LCon_Wheel:
		addq.l	#4,sp
		bra.w	RememberState
; ===========================================================================

LCon_Platform:
		move.b	#1,obFrame(a0)				; Platform frame
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get platform subtype assigned by spawner (based on 3rd word in ObjPosLZPlatform_Index)
		move.w	d0,d1						; copy to d1
		lsr.w	#3,d0						; d0 = (platform subtype // 8) floor division. Result will be an even number (0, 2, 4, etc.)
		andi.w	#$1E,d0						; cap d0 to $1E (no odd values) -- Only 0-$A is used
		lea		LCon_Data(pc),a2
		adda.w	(a2,d0.w),a2				; load correct data based on the platform subtype
		move.w	(a2)+,lcon_origy(a0)
		move.w	(a2)+,lcon_origx(a0)
		move.l	a2,lcon_dataaddr(a0)		; address of this data set (4 bytes)
		andi.w	#$F,d1						; get lowest nybble of the platform subtype
		lsl.w	#2,d1						; multiply by 4
		move.b	d1,lcon_origy(a0)			; store this value in $38(a0)
		move.b	#4,lcon_flag(a0)			; $3A(a0) is intialized to #4
		tst.b	(f_conveyrev).w				; have conveyors been reversed?
		beq.s	._1244C						; if not, branch
		move.b	#1,lcon_flag2(a0)			; set platform's local reverse flag
		neg.b	lcon_flag(a0)				; negate this value to -4
		moveq	#0,d1
		move.b	lcon_origy(a0),d1
		add.b	lcon_flag(a0),d1
		cmp.b	lcon_origy+1(a0),d1
		blo.s	._12448
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	._12448
		move.b	lcon_origy+1(a0),d1
		subq.b	#4,d1

._12448:
		move.b	d1,lcon_origy(a0)

._1244C:
		move.w	(a2,d1.w),lcon_targetx(a0)	; set target x-position
		move.w	2(a2,d1.w),lcon_targety(a0)	; set target y-position
		bsr.w	LCon_SetInMotion			; set initial direction and speed
		bra.w	loc_124B2					; jump down to routine 2
; ===========================================================================

LCon_Spawner:
		move.b	d0,lcon_spawnertype(a0)		; move spawner subtype to $2F(a0)
		andi.w	#$7F,d0						; clear upper-most bit of subtype to isolate platform group ID
		lea		(v_conveyactive).w,a2
		bset	#0,(a2,d0.w)				; set this group's respective bit
		bne.s	.delete						; if it was already set, delete this spawner object, as it's not needed.
		add.w	d0,d0						; multiply platform group ID by 2 (use for word AND longword pointers)
		add.w	d0,d0						; multiply platform group ID by 4 (use only for longword pointers)
		andi.w	#$1E,d0						; capped at $10 groups of platforms (0-$F)

	; RetroKoH Object Loading Optimization
		lea		(ObjPosLZPlatform_Index).l,a2	; Next, we load the first pointer in the object layout list pointer index,
		movea.l (a2,d0.w),a2					; Changed from adda.w to movea.l for longword object layout pointers
;		adda.w	(a2,d0.w),a2				; a2 = positioning data for this platform group (use only for word-length pointers)

		move.w	(a2)+,d1					; d1 = number of platforms minus 1
		movea.l	a0,a1
		bra.s	.firstPlatform

		; Avoid returning to LabyrinthConvey to prevent a
		; display-and-delete bug.
.delete:
		addq.l	#4,sp
		bra.w	DeleteObject
; ===========================================================================

	; RetroKoH Mass Object Load Optimization (Based on SpirituInsanum's Ring Loss Optimization)
	; Create the first instance, then loop to create the others afterward.
.firstPlatform:
		_move.b	#id_LabyrinthConvey,obID(a1)
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
		_move.b	#id_LabyrinthConvey,obID(a1)
		move.w	(a2)+,obX(a1)			; set x-position
		move.w	(a2)+,obY(a1)			; set y-position
		move.w	(a2)+,d0
		move.b	d0,obSubtype(a1)		; set subtype, discarding upper byte
		dbf		d1,.loop				; repeat for number of platforms

.endloop:
		addq.l	#4,sp
		rts	
; ===========================================================================

loc_124B2:	; Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		jsr		(PlatformObject).l
		bra.w	LCon_MovePlatforms
; ===========================================================================

loc_124C2:	; Routine 4
		moveq	#0,d1
		move.b	obActWid(a0),d1
		jsr		(ExitPlatform).l
		move.w	obX(a0),-(sp)
		bsr.w	LCon_MovePlatforms
		move.w	(sp)+,d2
		jmp		(MvSonicOnPtfm2).l
; ===========================================================================

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LCon_MovePlatforms:
		tst.b	(f_switch+$E).w			; has switch $E been pressed?
		beq.s	.noreverse				; if not, branch
		tst.b	lcon_flag2(a0)			; has this platform's movement already been reversed?
		bne.s	.noreverse				; if yes, branch
		move.b	#1,lcon_flag2(a0)		; reverse movement of this platform
		move.b	#1,(f_conveyrev).w		; reverse conveyor belts
		neg.b	lcon_flag(a0)			; negate this value to -4
		bra.s	.resetplatforms
; ===========================================================================

.noreverse:
		move.w	obX(a0),d0
		cmp.w	lcon_targetx(a0),d0		; has platform reached the target x-position?
		bne.w	SpeedToPos				; if not, branch to moving
		move.w	obY(a0),d0
		cmp.w	lcon_targety(a0),d0		; has platform reached the target y-position?
		bne.w	SpeedToPos				; if not, branch to moving

.resetplatforms:
		moveq	#0,d1
		move.b	lcon_origy(a0),d1
		add.b	lcon_flag(a0),d1
		cmp.b	lcon_origy+1(a0),d1
		blo.s	.settargetpos
		move.b	d1,d0
		moveq	#0,d1
		tst.b	d0
		bpl.s	.settargetpos
		move.b	lcon_origy+1(a0),d1
		subq.b	#4,d1

.settargetpos:
		move.b	d1,lcon_origy(a0)
		movea.l	lcon_dataaddr(a0),a1
		move.w	(a1,d1.w),lcon_targetx(a0)	; set next target x-position
		move.w	2(a1,d1.w),lcon_targety(a0)	; set next target y-position
		bsr.w	LCon_SetInMotion
		bra.w	SpeedToPos
; End of function LCon_MovePlatforms


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LCon_SetInMotion:	;LCon_ChangeDir:
		moveq	#0,d0
		move.w	#-$100,d2
		move.w	obX(a0),d0
		sub.w	lcon_targetx(a0),d0
		bcc.s	loc_12584
		neg.w	d0
		neg.w	d2

loc_12584:
		moveq	#0,d1
		move.w	#-$100,d3
		move.w	obY(a0),d1
		sub.w	lcon_targety(a0),d1
		bcc.s	loc_12598
		neg.w	d1
		neg.w	d3

loc_12598:
		cmp.w	d0,d1
		blo.s	loc_125C2
		move.w	obX(a0),d0
		sub.w	lcon_targetx(a0),d0
		beq.s	loc_125AE
		ext.l	d0
		asl.l	#8,d0
		divs.w	d1,d0
		neg.w	d0

loc_125AE:
		move.w	d0,obVelX(a0)
		move.w	d3,obVelY(a0)
		swap	d0
		move.w	d0,obX+2(a0)
		clr.w	obY+2(a0)
		rts	
; ===========================================================================

loc_125C2:
		move.w	obY(a0),d1
		sub.w	lcon_targety(a0),d1
		beq.s	loc_125D4
		ext.l	d1
		asl.l	#8,d1
		divs.w	d0,d1
		neg.w	d1

loc_125D4:
		move.w	d1,obVelY(a0)
		move.w	d2,obVelX(a0)
		swap	d1
		move.w	d1,obY+2(a0)
		clr.w	obX+2(a0)
		rts	
; End of function LCon_SetInMotion
; ===========================================================================

LCon_Data:	offsetTable
		offsetTableEntry.w	word_125F4
		offsetTableEntry.w	word_12610
		offsetTableEntry.w	word_12628
		offsetTableEntry.w	word_1263C
		offsetTableEntry.w	word_12650
		offsetTableEntry.w	word_12668

word_125F4:
		dc.w	$18, $1070
				; target x
						; target y
		dc.w	$1078,	$21A
		dc.w	$10BE,	$260
		dc.w	$10BE,	$393
		dc.w	$108C,	$3C5
		dc.w	$1022,	$390
		dc.w	$1022,	$244

word_12610:
		dc.w	$14, $1280
				; target x
						; target y
		dc.w	$127E,	$280
		dc.w	$12CE,	$2D0
		dc.w	$12CE,	$46E
		dc.w	$1232,	$420
		dc.w	$1232,	$2CC

word_12628:
		dc.w	$10, $D68
				; target x
						; target y
		dc.w	$D22,	$482
		dc.w	$D22,	$5DE
		dc.w	$DAE,	$5DE
		dc.w	$DAE,	$482

word_1263C:
		dc.w	$10, $DA0
				; target x
						; target y
		dc.w	$D62,	$3A2
		dc.w	$DEE,	$3A2
		dc.w	$DEE,	$4DE
		dc.w	$D62,	$4DE

word_12650:
		dc.w	$14, $D00
				; target x
						; target y
		dc.w	$CAC,	$242
		dc.w	$DDE,	$242
		dc.w	$DDE,	$3DE
		dc.w	$C52,	$3DE
		dc.w	$C52,	$29C

word_12668:
		dc.w	$10, $1300
				; target x
						; target y
		dc.w	$1252,	$20A
		dc.w	$13DE,	$20A
		dc.w	$13DE,	$2BE
		dc.w	$1252,	$2BE
; ===========================================================================
