; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Rings:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp		Ring_Index(pc,d1.w)
; ===========================================================================
Ring_Index:
ptr_Ring_Main:		dc.w Ring_Main-Ring_Index
ptr_Ring_Animate:	dc.w Ring_Animate-Ring_Index
ptr_Ring_Collect:	dc.w Ring_Collect-Ring_Index
ptr_Ring_Sparkle:	dc.w Ring_Sparkle-Ring_Index
ptr_Ring_Delete:	dc.w Ring_Delete-Ring_Index

id_Ring_Main = ptr_Ring_Main-Ring_Index	; 0
id_Ring_Animate = ptr_Ring_Animate-Ring_Index	; 2
id_Ring_Collect = ptr_Ring_Collect-Ring_Index	; 4
id_Ring_Sparkle = ptr_Ring_Sparkle-Ring_Index	; 6
id_Ring_Delete = ptr_Ring_Delete-Ring_Index	; 8
; ---------------------------------------------------------------------------
; Distances between rings (format: horizontal, vertical)
; ---------------------------------------------------------------------------
Ring_PosData:
		dc.b $10, 0		; horizontal tight
		dc.b $18, 0		; horizontal normal
		dc.b $20, 0		; horizontal wide
		dc.b 0,	$10		; vertical tight
		dc.b 0,	$18		; vertical normal
		dc.b 0,	$20		; vertical wide
		dc.b $10, $10	; diagonal
		dc.b $18, $18
		dc.b $20, $20
		dc.b $F0, $10
		dc.b $E8, $18
		dc.b $E0, $20
		dc.b $10, 8
		dc.b $18, $10
		dc.b $F0, 8
		dc.b $E8, $10
; ===========================================================================

Ring_Main:	; Routine 0
		lea		(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		lea		2(a2,d0.w),a2
		move.b	(a2),d4
		move.b	obSubtype(a0),d1
		move.b	d1,d0
		andi.w	#7,d1
		cmpi.w	#7,d1
		bne.s	loc_9B80
		moveq	#6,d1

loc_9B80:
		swap	d1
		clr.w	d1
		lsr.b	#4,d0
		add.w	d0,d0
		move.b	Ring_PosData(pc,d0.w),d5 ; load ring spacing data
		ext.w	d5
		move.b	Ring_PosData+1(pc,d0.w),d6
		ext.w	d6
		movea.l	a0,a1
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bra.s	loc_9BBA
; ===========================================================================

Ring_MakeRings:
		swap	d1
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bsr.w	FindFreeObj
		bne.s	loc_9C0E

loc_9BBA:
		_move.b	#id_Rings,obID(a1)			; load ring object
		addq.b	#2,obRoutine(a1)
		move.w	d2,obX(a1)					; set x-axis position based on d2
		move.w	obX(a0),objoff_32(a1)
		move.w	d3,obY(a1)					; set y-axis position based on d3
		move.l	#Map_Ring,obMap(a1)
		move.w	#make_art_tile(ArtTile_Ring,1,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$100,obPriority(a1)		; RetroKoH S2 Priority Manager
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.b	obRespawnNo(a0),obRespawnNo(a1)
		move.b	d1,objoff_34(a1)

loc_9C02:
		addq.w	#1,d1
		add.w	d5,d2				; add ring spacing value to d2
		add.w	d6,d3				; add ring spacing value to d3
		swap	d1
		dbf		d1,Ring_MakeRings	; repeat for number of rings

loc_9C0E:
		btst	#0,(a2)
		bne.w	DeleteObject

Ring_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0)		; set frame
		out_of_range.s	Ring_Delete,objoff_32(a0)
		bra.w	DisplaySprite						; Clownacy DisplaySprite Fix
; ===========================================================================

Ring_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		move.w	#$80,obPriority(a0)		; RetroKoH S2 Priority Manager
		bsr.w	CollectRing
		lea		(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		move.b	objoff_34(a0),d1
		bset	d1,2(a2,d0.w)

Ring_Sparkle:	; Routine 6
		lea		(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Ring_Delete:	; Routine 8
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CollectRing:
		addq.w	#1,(v_rings).w		; add 1 to rings
		ori.b	#1,(f_ringcount).w	; update the rings counter
		move.w	#sfx_Ring,d0		; play ring sound
		cmpi.w	#100,(v_rings).w	; do you have < 100 rings?
		blo.s	.playsnd			; if yes, branch
		bset	#1,(v_lifecount).w	; update lives counter
		beq.s	.got100
		cmpi.w	#200,(v_rings).w	; do you have < 200 rings?
		blo.s	.playsnd			; if yes, branch
		bset	#2,(v_lifecount).w	; update lives counter
		bne.s	.playsnd

.got100:
	; Mercury Lives Over/Underflow Fix
		cmpi.b	#99,(v_lives).w		; are lives at max?
		beq.s	.playbgm
		addq.b	#1,(v_lives).w		; add 1 to number of lives
		addq.b	#1,(f_lifecount).w	; update the lives counter
.playbgm:
	; Lives Over/Underflow Fix End
		move.w	#bgm_ExtraLife,d0	; play extra life music

.playsnd:
		jmp	(PlaySound_Special).l
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit
; ---------------------------------------------------------------------------

RingLoss:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	RLoss_Index(pc,d0.w),d1
		jmp		RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:
		dc.w RLoss_Count-RLoss_Index
		dc.w RLoss_Bounce-RLoss_Index
		dc.w RLoss_Collect-RLoss_Index
		dc.w RLoss_Sparkle-RLoss_Index
		dc.w RLoss_Delete-RLoss_Index
; ===========================================================================

RLoss_Count:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d5
		move.w	(v_rings).w,d5			; check number of rings you have
		moveq	#32,d0
	; RHS Ring Loss Speedup
		lea		SpillRingData,a3		; load the address of the array in a3
		lea     (v_player).w,a2			; a2=character
		btst    #6,obStatus(a2)			; is Sonic underwater?
		beq.s   .abovewater				; if not, branch
		lea		SpillRingData_Water,a3	; load the address of the array in a3

.abovewater:
	; Ring Loss Speedup End
		cmp.w	d0,d5					; do you have 32 or more?
		blo.s	.belowmax				; if not, branch
		move.w	d0,d5					; if yes, set d5 to 32

.belowmax:
		subq.w	#1,d5					; decrease the counter the first time, as we are creating the first ring now.

		; Create the first instance, then loop create the others afterward.
		move.b	#id_RingLoss,obID(a1) 	; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.b	#8,obHeight(a1)
		move.b	#8,obWidth(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#make_art_tile(ArtTile_Ring,1,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$180,obPriority(a1)	; RetroKoH S2 Priority Manager
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.w  (a3)+,obVelX(a1)	; move the data contained in the array to the x velocity and increment the address in a3
		move.w  (a3)+,obVelY(a1)	; move the data contained in the array to the y velocity and increment the address in a3
		subq	#1,d5				; decrement for the first ring created
		bmi.s	.resetcounter		; if only one ring is needed, branch and skip EVERYTHING below altogether
		; Here we begin what's replacing SingleObjLoad, in order to avoid resetting its d0 every time an object is created.
		lea		(v_lvlobjspace).w,a1
		move.w	#$5F,d0

.loop:
		; REMOVE FindFreeObj. It's the routine that causes such slowdown
		tst.b	(a1)
		beq.s	.makerings		; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		object_size(a1),a1
		dbf		d0,.loop		; Branch correction again.
		bne.s	.resetcounter	; We're moving this line here.

.makerings:
		_move.b	#id_RingLoss,obID(a1)	; load bouncing ring object
		addq.b	#2,obRoutine(a1)
		move.b	#8,obHeight(a1)
		move.b	#8,obWidth(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#make_art_tile(ArtTile_Ring,1,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#$180,obPriority(a1)	; RetroKoH S2 Priority Manager
		move.b	#$47,obColType(a1)
		move.b	#8,obActWid(a1)
		move.w  (a3)+,obVelX(a1)	; move the data contained in the array to the x velocity and increment the address in a3
		move.w  (a3)+,obVelY(a1)	; move the data contained in the array to the y velocity and increment the address in a3
		dbf		d5,.loop			; repeat for number of rings (max 31)

.resetcounter:
		clr.w	(v_rings).w			; reset number of rings to zero
		move.b	#$80,(f_ringcount).w	; update ring counter
		clr.b	(v_lifecount).w
		; RHS Ring Timers Fix
		moveq   #-1,d0					; Move #-1 to d0
		move.b  d0,obDelayAni(a0)		; Move d0 to new timer
		move.b  d0,(v_ani3_time).w		; Move d0 to old timer (for animated purposes)
		; Ring Timers Fix End
		move.w	#sfx_RingLoss,d0
		jsr		(PlaySound_Special).l	; play ring loss sound


RLoss_Bounce:	; Routine 2
		move.b	(v_ani3_frame).w,obFrame(a0)
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)
	; RHS Underwater Rings Physics Fix
		tst.b	(f_water).w			; Does the level have water?
		beq.s	.skipbounceslow		; If not, branch and skip underwater checks
		move.w	(v_waterpos1).w,d6	; Move water level to d6
		cmp.w	obY(a0),d6			; Is the ring object underneath the water level?
		bgt.s	.skipbounceslow		; If not, branch and skip underwater commands
		subi.w	#$E,obVelY(a0)		; Reduce gravity by $E ($18-$E=$A), giving the underwater effect

.skipbounceslow:
	; Underwater Rings Physics Fix End
		bmi.s	.chkdel
		move.b	(v_vbla_byte).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	.chkdel
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	.chkdel
		add.w	d1,obY(a0)
		move.w	obVelY(a0),d0
		asr.w	#2,d0
		sub.w	d0,obVelY(a0)
		neg.w	obVelY(a0)

.chkdel:
		; RHS Ring Timers Fix
		subq.b	#1,obDelayAni(a0)		; Subtract 1
		beq.w	DeleteObject			; If 0, delete
		; Ring Timers Fix End
		; RHS Accidental Ring Deletion Fix
		cmpi.w	#$FF00,(v_limittop2).w	; is vertical wrapping enabled?
		beq.w	.chkflash				; if so, branch
		; Accidental Ring Deletion Fix End
		move.w	(v_limitbtm2).w,d0
		addi.w	#$E0,d0
		cmp.w	obY(a0),d0				; has object moved below level boundary?
		blo.w	DeleteObject			; if yes, branch
		; Mercury Ring Flashing Effect
.chkflash:
		btst	#0, obDelayAni(a0)		; Test the first bit of the timer, so rings flash every other frame.
		beq.w	DisplaySprite			; If the bit is 0, the ring will appear.
		cmpi.b	#80,obDelayAni(a0)		; Rings will flash during last 80 steps of their life.
		bhi.w	DisplaySprite			; If the timer is higher than 80, obviously the rings will STAY visible.
		rts
		; Ring Flashing Effect End
; ===========================================================================

RLoss_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)
		clr.b	obColType(a0)
		move.w	#$80,obPriority(a0)		; RetroKoH S2 Priority Manager
		bsr.w	CollectRing

RLoss_Sparkle:	; Routine 6
		lea		(Ani_Ring).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject

; ===========================================================================
; ---------------------------------------------------------------------------
; Ring Spawn Array -- RHS Ring Loss Speedup
; ---------------------------------------------------------------------------

SpillRingData:  dc.w    $FF3C,$FC14, $00C4,$FC14, $FDC8,$FCB0, $0238,$FCB0 ; 4
                dc.w    $FCB0,$FDC8, $0350,$FDC8, $FC14,$FF3C, $03EC,$FF3C ; 8
                dc.w    $FC14,$00C4, $03EC,$00C4, $FCB0,$0238, $0350,$0238 ; 12
                dc.w    $FDC8,$0350, $0238,$0350, $FF3C,$03EC, $00C4,$03EC ; 16
                dc.w    $FF9E,$FE0A, $0062,$FE0A, $FEE4,$FE58, $011C,$FE58 ; 20
                dc.w    $FE58,$FEE4, $01A8,$FEE4, $FE0A,$FF9E, $01F6,$FF9E ; 24
                dc.w    $FE0A,$0062, $01F6,$0062, $FE58,$011C, $01A8,$011C ; 28
                dc.w    $FEE4,$01A8, $011C,$01A8, $FF9E,$0156, $0062,$0156 ; 32
                even
; ===========================================================================

; ===========================================================================
; ---------------------------------------------------------------------------
; Ring Spawn Array - Underwater -- RHS Ring Loss Speedup
; ---------------------------------------------------------------------------

SpillRingData_Water:
				dc.w    $FF9C,$FE08, $0064,$FE08, $FEE4,$FE58, $011C,$FE58 ; 4
                dc.w    $FE58,$FEE4, $01A8,$FEE4, $FE08,$FF9C, $01F8,$FF9C ; 8
                dc.w    $FE08,$0060, $01F8,$0060, $FE58,$011C, $01A8,$011C ; 12
                dc.w    $FEE4,$01A8, $011C,$01A8, $FF9C,$01F4, $0064,$01F4 ; 16
                dc.w    $FFCE,$FF04, $0032,$FF04, $FF72,$FF2C, $008E,$FF2C ; 20
                dc.w    $FF2C,$FF72, $00D4,$FF72, $FF04,$FFCE, $00FC,$FFCE ; 24
                dc.w    $FF04,$0030, $00FC,$0030, $FF2C,$008E, $00D4,$008E ; 28
                dc.w    $FF72,$00D4, $008E,$00D4, $FFCE,$00FA, $0032,$00FA ; 32
                even
; ===========================================================================