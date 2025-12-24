; ---------------------------------------------------------------------------
; Object 83 - blocks that disintegrate when Eggman presses a switch (SBZ2)
; ---------------------------------------------------------------------------

FalseFloor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	FFloor_Index(pc,d0.w),d1
		jmp		FFloor_Index(pc,d1.w)
; ===========================================================================
FFloor_Index:	offsetTable
		offsetTableEntry.w FFloor_Main
		offsetTableEntry.w FFloor_ChkBreak
		offsetTableEntry.w FFloor_SetBreak
		offsetTableEntry.w FFloor_DestroyAll
		offsetTableEntry.w FFloor_PanelBlock
		offsetTableEntry.w FFloor_PanelFrag
; ===========================================================================

FFloor_Main:	; Routine 0
		move.w	#boss_sbz2_x+$30,obX(a0)	; $2080
		move.w	#boss_sbz2_y+$C0,obY(a0)	; $5D0
		move.b	#$80,obDispWid(a0)
		move.b	#$84,obRender(a0)			; render_flags = 4; bit 7 also set

	; store values for faster looping
		lea		obFFloor_Children(a0),a2
		_move.l	#FalseFloor,d1
		move.l	#Map_FFloor,d2
		move.w	#make_art_tile(ArtTile_Eggman_Trap_Floor,2,0),d3
		moveq	#$10,d4
		move.b	d4,obHeight(a0)				; might as well set it here
		move.w	#boss_sbz2_x-$40,d5			; initial x position
		moveq	#7,d6						; iterator

	; RetroKoH Mass Object Load Optimization; Built off of Spirituinsanum's Ring Loss Optimization
	; Here we begin what's replacing FindFreeObj/SingleObjLoad
	; Slight improvement by Malachi
		lea		(v_lvlobjspace-object_size).w,a1
		move.w	#v_lvlobjcount,d0

	.loop:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		lea		object_size(a1),a1
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		dbeq	d0,.loop					; Branch correction again.
		bne.s	.endloop					; We're moving this line here.

	.makefloor:
		move.w	a1,(a2)+					; store the new object's address in the controller's memory (obFFloor_Children(a0) onward)
		_move.l	d1,obAddr(a1)					; load block object
		move.l	d2,obMap(a1)
		move.w	d3,obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	d4,obDispWid(a1)
		move.b	d4,obHeight(a1)
		move.w	#priority3,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	d5,obX(a1)					; set X	position
		move.w	#boss_sbz2_y+$C0,obY(a1)
		addi.w	#$20,d5						; add $20 for next X position
		move.b	#8,obRoutine(a1)			; set floor panel's routine (wait to break)
		dbf		d6,.loop					; repeat sequence 7 more times

	.endloop:
		addq.b	#2,obRoutine(a0)			; advance the main object's routine
		rts	
; ===========================================================================

FFloor_ChkBreak:	; Routine 2
		cmpi.b	#"G",obSubtype(a0)			; is object set to disintegrate? (by Eggman object)
		bne.s	FFloor_Solid				; if not, branch
		clr.b	obFrame(a0)
		addq.b	#2,obRoutine(a0)			; -> FFloor_Break

FFloor_Solid:
		moveq	#0,d0
		move.b	obFrame(a0),d0				; get current frame (starts as 0, increments as blocks break)
		neg.b	d0							; make negative
		ext.w	d0
		addq.w	#8,d0						; d0 = 0 to 8
		asl.w	#4,d0						; multiply by 16
		move.w	#boss_sbz2_x+$B0,d4			; initial x position
		sub.w	d0,d4						; move right as the block shrinks
		move.b	d0,obDispWid(a0)
		move.w	d4,obX(a0)					; set x position
		moveq	#11,d1
		add.w	d0,d1						; width
		moveq	#16,d2						; height (jumping) (Unlike elsewhere, the original game uses moveq here)
		moveq	#17,d3						; height (walking) (Unlike elsewhere, the original game uses moveq here)
		jmp		(SolidObject).l
; ===========================================================================

FFloor_SetBreak:	; Routine 4
		subi.b	#$E,obTimeFrame(a0)			; decrement timer
		bcc.s	FFloor_Solid				; branch if time remains (never happens)
		moveq	#-1,d0
		move.b	obFrame(a0),d0				; get current frame (starts as 0, increments as blocks break)
		ext.w	d0
		add.w	d0,d0
		move.w	obFFloor_Children(a0,d0.w),d0	; get address of OST for next child block
		movea.l	d0,a1
		move.b	#"G",obSubtype(a1)			; set object to disintegrate
		addq.b	#1,obFrame(a0)				; next frame
		cmpi.b	#8,obFrame(a0)				; have all 8 floor panels been set to break? (final frame)
		beq.s	FFloor_DestroyAll			; if yes, branch
		bra.s	FFloor_Solid				; otherwise, branch to solidity routine
; ===========================================================================

FFloor_DestroyAll:		; Routine 6
		bclr	#staSonicOnObj,obStatus(a0)	; clear platform flags
		bclr	#staOnObj,(v_player+obStatus).w
		jmp		(DeleteObject).l			; delete object
; ===========================================================================

FFloor_PanelBlock:		; Routine 8
		cmpi.b	#"G",obSubtype(a0)			; is object set to disintegrate?
		beq.s	FFloor_Break				; if yes, branch
		jmp		(DisplaySprite).l
; ===========================================================================

FFloor_PanelFrag:	; Routine $A
		tst.b	obRender(a0)				; is object on-screen?
		bpl.s	.delete						; if not, branch
		jsr		(ObjectFall_YOnly).l
		jmp		(DisplaySprite).l

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

FFloor_Break:
		lea		FFloor_FragSpeed(pc),a4		; y speed data
		lea		FFloor_FragPos(pc),a5		; x/y position data
		moveq	#1,d4						; frame id of first fragment (1)
		moveq	#3,d1						; number of fragments (4)
		moveq	#$38,d2
		addq.b	#2,obRoutine(a0)			; -> FFloor_Frag
		moveq	#8,d0
		move.b	d0,obDispWid(a0)
		move.b	d0,obHeight(a0)

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		movea.l	a0,a1
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	.endloop
		bra.s	.makefrags					; start fragmentation

	.findfreeobj:
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		beq.s	.makefrags					; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.findfreeobj				; loop through object RAM
		bne.s	.endloop					; We're moving this line here.

	.makefrags:
		lea		(a0),a2						; a2 = new object
		lea		(a1),a3						; a3 = THIS object
		moveq	#3,d3						; run the loop 4 times for $40 bytes

	.loop:									; Copy all data to the new object
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf		d3,.loop

		move.w	(a4)+,obVelY(a1)			; get initial y speed from FFloor_FragSpeed
		move.w	(a5)+,d3
		add.w	d3,obX(a1)					; get position from FFloor_FragPos
		move.w	(a5)+,d3
		add.w	d3,obY(a1)
		move.b	d4,obFrame(a1)				; set frame
		addq.w	#1,d4						; next frame
		dbf		d1,.findfreeobj				; repeat sequence 3 more times

	.endloop:
		move.w	#sfx_Collapse,d0			; Should be sfx_WallSmash, but the sound is different
		jsr		(QueueSound2).w				; play smashing sound
		jmp		(DisplaySprite).l
; ===========================================================================

FFloor_FragSpeed:
		dc.w $80
		dc.w 0
		dc.w $120
		dc.w $C0

FFloor_FragPos:
		dc.w -8, -8
		dc.w $10, 0
		dc.w 0,	$10
		dc.w $10, $10
; ===========================================================================