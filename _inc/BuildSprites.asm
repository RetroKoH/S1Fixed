; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; Ported from S3K by DeltaW
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Init_SpriteTable:
		lea		(v_spritetablebuffer).w,a1
		moveq	#0,d0
		moveq	#1,d1
		moveq	#$4F,d2

.loop:
		move.w	d0,(a1)
		move.b	d1,3(a1)
		addq.w	#1,d1
		addq.w	#8,a1
		dbf		d2,.loop
		move.b	d0,-5(a1)
		rts
; ---------------------------------------------------------------------------


BuildSprites:
		bsr.s	BuildSprites_Objects

BuildSprites_Finish:
		move.w	d7,d6
		bmi.s	loc_1AE18
		moveq	#0,d0

loc_1AE10:
		move.w	d0,(a6)
		addq.w	#8,a6
		dbf		d7,loc_1AE10

loc_1AE18:
		subi.w	#$4F,d6
		neg.w	d6
		move.b	d6,(v_spritecount).w
		rts

BuildSprites_Objects:
		moveq	#$4F,d7
		moveq	#0,d6
		lea		(v_spritetablebuffer).w,a6
		lea		(v_screenposx).w,a3
	; RetroKoH S2 HUD Manager
		tst.b	(f_levelstarted).w
		ble.s	.noHUD						; value is negative during the credits sequence
		bsr.w	BuildHUD					; build during gameplay and demos, not during the credits
	; S2 HUD Manager End

.noHUD:
		lea		(v_spritequeue).w,a5

loc_1AD4A:
	; RetroKoH S3K Rings Manager
		cmpa.l	#priority2,a5				; Only draw rings at a specific priority.
		bne.s	.cont
		tst.b	(f_levelstarted).w			; Skip drawing rings if flag is not set.
		beq.s	.cont
		bsr.w	BuildRings

.cont:
	; S3K Rings Manager End
		tst.w	(a5)
		beq.w	BuildSprites_NextLevel
		lea		2(a5),a4

loc_1AD54:
		movea.w	(a4)+,a0	; a0=object
		tst.l	obAddr(a0)			; is this object slot occupied?
		beq.w	BuildSprites_NextObj	; if not, check next one
		andi.b	#$7F,obRender(a0)	; clear on-screen flag
		move.b	obRender(a0),d6
		move.w	obX(a0),d0
		move.w	obY(a0),d1
		btst	#renMultiDraw,d6		; is the multi-draw flag set?
		bne.w	loc_1AE58	; if it is, branch
		btst	#renRelative,d6		; is this to be positioned by screen coordinates?
		beq.s	BuildDrawScreenY	; if it is, branch
		moveq	#0,d2
		move.b	obDispWid(a0),d2
		sub.w	(a3),d0
		move.w	d0,d3
		add.w	d2,d3		; is the object right edge to the left of the screen?
		bmi.w	BuildSprites_NextObj	; if it is, branch
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3
		bge.s	BuildSprites_NextObj	; right edge out of bounds
		addi.w	#128,d0		; VDP sprites start at 128px
		sub.w	4(a3),d1
		btst	#renUseHeight,d6
		beq.s	BuildAssumeHeight
		move.b	obHeight(a0),d2
		add.w	d2,d1
		move.w	d2,d3
		add.w	d2,d2
		addi.w	#224,d2
		andi.w	#LevelYWrapMask,d1		; wrap vertically (should I use wrap_y_distance macro?)
		cmp.w	d2,d1
		bhs.s	BuildSprites_NextObj	; if the object is below the screen
		addi.w	#128,d1
		sub.w	d3,d1
		bra.s	loc_1ADB2

BuildDrawScreenY:
		move.w	obScreenY(a0),d1
		bra.s	loc_1ADB2

BuildAssumeHeight:
		addi.w	#$80,d1
		andi.w	#LevelYWrapMask,d1		; wrap vertically
		cmpi.w	#$60,d1
		blo.s	BuildSprites_NextObj
		cmpi.w	#$180,d1
		bhs.s	BuildSprites_NextObj

loc_1ADB2:
		ori.b	#$80,obRender(a0)	; set on-screen flag
		tst.w	d7
		bmi.s	BuildSprites_NextObj
		tst.l	obMap(a0)
		beq.w	BuildSprites_NextObj
		movea.l	obMap(a0),a1
		moveq	#0,d4
		btst	#renRawMap,d6		; is the static mappings flag set?
		bne.s	loc_1ADD8	; if it is, branch
		move.b	obFrame(a0),d4
		add.w	d4,d4
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4		; get number of pieces
		bmi.s	BuildSprites_NextObj	; if there are 0 pieces, branch
; ===========================================================================
loc_1ADD8:
		move.w	obGfx(a0),d5
		jsr		sub_1AF6C(pc)

BuildSprites_NextObj:
		subq.w	#2,(a5)		; decrement object count
		bne.w	loc_1AD54	; if there are objects left, repeat

BuildSprites_NextLevel:
		lea		$80(a5),a5	; load next priority level
		cmpa.l	#v_spritequeue+(8*$80),a5
		blo.w	loc_1AD4A
		rts
; ---------------------------------------------------------------------------

loc_1AE58:
		btst	#renRelative,d6		; is this to be positioned by screen coordinates?
		bne.s	loc_1AEA2	; if it is, branch
		moveq	#0,d2

		; check if object is within X bounds
		move.b	mainspr_width(a0),d2
		subi.w	#128,d0
		move.w	d0,d3
		add.w	d2,d3
		bmi.w	BuildSprites_NextObj
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3
		bge.w	BuildSprites_NextObj
		addi.w	#128,d0

		; check if object is within Y bounds
		move.b	mainspr_height(a0),d2
		subi.w	#128,d1
		move.w	d1,d3
		add.w	d2,d3
		bmi.w	BuildSprites_NextObj
		move.w	d1,d3
		sub.w	d2,d3
		cmpi.w	#224,d3
		bge.w	BuildSprites_NextObj
		addi.w	#128,d1
		bra.s	loc_1AEE4
; ---------------------------------------------------------------------------

loc_1AEA2:
		moveq	#0,d2
		move.b	mainspr_width(a0),d2
		sub.w	(a3),d0
		move.w	d0,d3
		add.w	d2,d3
		bmi.w	BuildSprites_NextObj
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#$140,d3
		bge.w	BuildSprites_NextObj
		addi.w	#$80,d0
		sub.w	4(a3),d1
		btst	#renUseHeight,d6
		beq.s	BuildMultiAssumeHeight
		moveq	#0,d2
		move.b	mainspr_height(a0),d2
		add.w	d2,d1
		move.w	d2,d3
		add.w	d2,d2
		addi.w	#$E0,d2
		andi.w	#LevelYWrapMask,d1		; wrap vertically
		cmp.w	d2,d1
		bhs.w	BuildSprites_NextObj
		addi.w	#$80,d1
		sub.w	d3,d1
		bra.s	loc_1AEE4

BuildMultiAssumeHeight:
		addi.w	#$80,d1
		andi.w	#LevelYWrapMask,d1		; wrap vertically
		cmpi.w	#$60,d1
		blo.w	BuildSprites_NextObj
		cmpi.w	#$180,d1
		bhs.w	BuildSprites_NextObj

loc_1AEE4:
		ori.b	#$80,obRender(a0)
		tst.w	d7
		bmi.w	BuildSprites_NextObj
		move.w	obGfx(a0),d5
		tst.l	obMap(a0)
		beq.w	BuildSprites_NextObj
		movea.l	obMap(a0),a2
		moveq	#0,d4
		move.b	mainspr_mapframe(a0),d4
		bmi.s	loc_1AF1C
		add.w	d4,d4
		lea		(a2),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	loc_1AF1C
		move.w	d6,d3
		jsr		sub_1B070(pc)
		move.w	d3,d6
		tst.w	d7
		bmi.w	BuildSprites_NextObj

loc_1AF1C:
		moveq	#0,d3
		move.b	mainspr_childsprites(a0),d3
		subq.w	#1,d3
		bcs.w	BuildSprites_NextObj
		move.l	a4,-(sp)
		lea		subspr_frames(a0),a4
		lea		subspr_posdata(a0),a0

loc_1AF2A:
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		btst	#renRelative,d6
		beq.s	loc_1AF46
		sub.w	(a3),d0
		addi.w	#128,d0
		sub.w	4(a3),d1
		addi.w	#128,d1
		andi.w	#LevelYWrapMask,d1		; wrap vertically

loc_1AF46:
		moveq	#0,d4
		move.b	(a4)+,d4
		add.w	d4,d4
		lea		(a2),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	loc_1AF62
		move.w	d6,-(sp)
		jsr		sub_1B070(pc)

		move.w	(sp)+,d6

loc_1AF62:
		tst.w	d7
		dbmi	d3,loc_1AF2A
		movea.l	(sp)+,a4
		bra.w	BuildSprites_NextObj
; End of function BuildSprites


; =============== S U B R O U T I N E =======================================


sub_1AF6C:
		lsr.b	#1,d6
		blo.s	loc_1AF9E
		lsr.b	#1,d6
		blo.w	loc_1B038

BuildSpr_Normal:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1AF94
		addq.w	#1,d2

loc_1AF94:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,BuildSpr_Normal
		rts
; ---------------------------------------------------------------------------

loc_1AF9E:
		lsr.b	#1,d6
		blo.s	loc_1AFE8

loc_1AFA2:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$800,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1AFD8(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1AFCE
		addq.w	#1,d2

loc_1AFCE:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1AFA2
		rts
; ---------------------------------------------------------------------------
byte_1AFD8:
		dc.b 8, 8, 8, 8
		dc.b 16, 16, 16, 16
		dc.b 24, 24, 24, 24
		dc.b 32, 32, 32, 32
; ---------------------------------------------------------------------------

loc_1AFE8:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1),d6
		move.b	byte_1B028(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1800,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1AFD8(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1B01E
		addq.w	#1,d2

loc_1B01E:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1AFE8
		rts
; ---------------------------------------------------------------------------
byte_1B028:
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
; ---------------------------------------------------------------------------

loc_1B038:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1)+,d6
		move.b	d6,2(a6)
		move.b	byte_1B028(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		move.w	d2,(a6)+
		addq.w	#2,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1000,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1B066
		addq.w	#1,d2

loc_1B066:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B038
		rts
; End of function sub_1AF6C


; =============== S U B R O U T I N E =======================================


sub_1B070:
		lsr.b	#1,d6
		blo.s	loc_1B0C2
		lsr.b	#1,d6
		blo.w	loc_1B19C

loc_1B07A:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B0BA
		cmpi.w	#224+128,d2
		bhs.s	loc_1B0BA
		move.w	d2,(a6)+
		move.b	(a1)+,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B0B2
		cmpi.w	#320+128,d2
		bhs.s	loc_1B0B2
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B07A
		rts
; ---------------------------------------------------------------------------

loc_1B0B2:
		subq.w	#6,a6
		dbf		d4,loc_1B07A
		rts
; ---------------------------------------------------------------------------

loc_1B0BA:
		addq.w	#5,a1
		dbf		d4,loc_1B07A
		rts
; ---------------------------------------------------------------------------

loc_1B0C2:
		lsr.b	#1,d6
		blo.s	loc_1B12C

loc_1B0C6:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B114
		cmpi.w	#224+128,d2
		bhs.s	loc_1B114
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$800,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1B11C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B10C
		cmpi.w	#320+128,d2
		bhs.s	loc_1B10C
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B0C6
		rts
; ---------------------------------------------------------------------------

loc_1B10C:
		subq.w	#6,a6
		dbf		d4,loc_1B0C6
		rts
; ---------------------------------------------------------------------------

loc_1B114:
		addq.w	#5,a1
		dbf		d4,loc_1B0C6
		rts
; ---------------------------------------------------------------------------
byte_1B11C:
		dc.b 8, 8, 8, 8
		dc.b 16, 16, 16, 16
		dc.b 24, 24, 24, 24
		dc.b 32, 32, 32, 32
; ---------------------------------------------------------------------------

loc_1B12C:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1),d6
		move.b	byte_1B18C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B184
		cmpi.w	#224+128,d2
		bhs.s	loc_1B184
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1800,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1B11C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B17C
		cmpi.w	#320+128,d2
		bhs.s	loc_1B17C
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B12C
		rts
; ---------------------------------------------------------------------------

loc_1B17C:
		subq.w	#6,a6
		dbf		d4,loc_1B12C
		rts
; ---------------------------------------------------------------------------

loc_1B184:
		addq.w	#5,a1
		dbf		d4,loc_1B12C
		rts
; ---------------------------------------------------------------------------
byte_1B18C:
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
; ---------------------------------------------------------------------------

loc_1B19C:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1)+,d6
		move.b	d6,2(a6)
		move.b	byte_1B18C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B1EC
		cmpi.w	#224+128,d2
		bhs.s	loc_1B1EC
		move.w	d2,(a6)+
		addq.w	#2,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#$1000,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B1E4
		cmpi.w	#320+128,d2
		bhs.s	loc_1B1E4
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B19C
		rts
; ---------------------------------------------------------------------------

loc_1B1E4:
		subq.w	#6,a6
		dbf		d4,loc_1B19C
		rts
; ---------------------------------------------------------------------------

loc_1B1EC:
		addq.w	#4,a1
		dbf		d4,loc_1B19C
		rts
; End of function sub_1B070
; ===========================================================================
