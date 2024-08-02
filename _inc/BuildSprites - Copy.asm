; ===========================================================================
BldSpr_ScrPos:
		dc.l 0				; blank
		dc.l v_screenposx&$FFFFFF	; main screen x-position
		dc.l v_bgscreenposx&$FFFFFF	; background x-position	1
		dc.l v_bg3screenposx&$FFFFFF	; background x-position	2

; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:
		lea		(v_spritetablebuffer).w,a2	; set address for sprite table
		moveq	#0,d5
		moveq	#0,d4						; RetroKoH S2 Rings Manager
	; RetroKoH S2 HUD Manager
		tst.b	(f_levelstarted).w
		beq.s	.noHUD
		bsr.w	BuildHUD					

	.noHUD:
	; S2 HUD Manager End
		lea		(v_spritequeue).w,a4
		moveq	#7,d7

	.priorityLoop:
	; RetroKoH S2 Rings Manager
		cmpi.b	#$07-$02,d7				; Only draw rings at a specific priority.
		bne.s	.cont
		tst.b	(f_levelstarted).w		; Skip drawing rings if flag is not set.
		beq.s	.cont
		movem.l	d7/a4,-(sp)
		jsr		BuildRings
		movem.l	(sp)+,d7/a4

	.cont:
	; S2 Rings Manager End
		tst.w	(a4)			; are there objects left to draw?
		beq.w	.nextPriority	; if not, branch
		moveq	#2,d6

	.objectLoop:
		movea.w	(a4,d6.w),a0	; load object ID
		tst.b	(a0)			; if null, branch
		beq.w	.skipObject
		bclr	#7,obRender(a0)		; set as not visible

		move.b	obRender(a0),d0
		move.b	d0,d4
	; Devon Subsprites
		btst	#6,d0					; is the multi-draw flag set?
		bne.w	BuildSprites_MultiDraw	; if it is, branch
	; Devon Subsprites End
		andi.w	#$C,d0 					; is this to be positioned by screen coordinates?
		beq.s	.screenCoords			; if yes, branch

		movea.l	BldSpr_ScrPos(pc,d0.w),a1
	; check object bounds
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	.skipObject		; left edge out of bounds
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1
		bge.s	.skipObject		; right edge out of bounds
		addi.w	#128,d3			; VDP sprites start at 128px
		btst	#4,d4			; is assume height flag on?
		beq.s	.assumeHeight	; if yes, branch
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	.skipObject		; top edge out of bounds
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	.skipObject
		addi.w	#128,d2			; VDP sprites start at 128px
		bra.s	.drawObject
; ===========================================================================

	.screenCoords:
		move.w	obScreenY(a0),d2	; special variable for screen Y
		move.w	obX(a0),d3
		bra.s	.drawObject
; ===========================================================================

	.assumeHeight:
		move.w	obY(a0),d2
		sub.w	obMap(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		blo.s	.skipObject
		cmpi.w	#$180,d2
		bhs.s	.skipObject

	.drawObject:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4				; is static mappings flag on?
		bne.s	.drawFrame			; if yes, branch
		move.b	obFrame(a0),d1
		add.w	d1,d1				; changed to .w (we want more than 7F sprites) -- MarkeyJester Art Limit Extensions
		adda.w	(a1,d1.w),a1		; get mappings frame address
		moveq	#0,d1				; clear d1 (because of our byte to word change) -- MarkeyJester Art Limit Extensions
		move.b	(a1)+,d1			; number of sprite pieces
		subq.b	#1,d1
		bmi.s	.setVisible

	.drawFrame:
		bsr.w	BuildSpr_Draw		; write data from sprite pieces to buffer

	.setVisible:
		bset	#7,obRender(a0)		; set object as visible

	.skipObject:
		addq.w	#2,d6
		subq.w	#2,(a4)				; number of objects left
		bne.w	.objectLoop

	.nextPriority:
		lea		$80(a4),a4
		dbf		d7,.priorityLoop
		move.b	d5,(v_spritecount).w
		cmpi.b	#$50,d5
		beq.s	.spriteLimit
		clr.l	(a2)
		rts	
; ===========================================================================

	.spriteLimit:
		clr.b	-5(a2)	; set last sprite link
		rts	
; End of function BuildSprites


; Devon Subsprites
BuildSprites_MultiDraw:
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0

		; check if object is within X bounds
		move.b	mainspr_width(a0),d0			; load pixel width
		move.w	obX(a0),d3
		sub.w	(v_screenposx).w,d3
		move.w	d3,d1
		add.w	d0,d1							; is the object's right edge to the left of the screen?
		bmi.w	BuildSprites_MultiDraw_NextObj	; if yes, branch
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1							; is the object's left edge to the right of the screen?
		bge.w	BuildSprites_MultiDraw_NextObj	; if yes, branch
		addi.w	#128,d3

		; check if object is within Y bounds
		btst	#4,d4							; is the accurate Y check flag set?
		beq.s	BuildSpritesMulti_ApproxYCheck	; if not, branch
		moveq	#0,d0
		move.b	mainspr_height(a0),d0			; load pixel height
		sub.w	(v_screenposy).w,d2
		move.w	d2,d1
		add.w	d0,d1							; is the object above the screen?
		bmi.w	BuildSprites_MultiDraw_NextObj	; if yes, branch
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1							; is the object below the screen?
		bge.w	BuildSprites_MultiDraw_NextObj	; if yes, branch
		addi.w	#128,d2
		bra.s	BuildSpritesMulti_DrawSprite

BuildSpritesMulti_ApproxYCheck:
; this doesn't take into account the height of the sprite/object when checking
; if it's onscreen vertically or not.
		move.w	obY(a0),d2
		sub.w	(v_screenposy).w,d2
		addi.w	#128,d2
		andi.w	#$7FF,d2					; Could remove to remain faithful to Sonic 1
		cmpi.w	#-32+128,d2
		blo.s	BuildSprites_MultiDraw_NextObj
		cmpi.w	#32+128+224,d2
		bhs.s	BuildSprites_MultiDraw_NextObj

BuildSpritesMulti_DrawSprite:
		moveq	#0,d1
		move.b	mainspr_mapframe(a0),d1			; get current frame
		beq.s	.noparenttodraw
		add.b	d1,d1
		movea.l	a5,a1							; a5 is obMap(a0), copy to a1
		adda.w	(a1,d1.w),a1
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1							; get number of pieces
		bmi.s	.noparenttodraw					; if there are 0 pieces, branch
		move.w	d4,-(sp)
		bsr.w	ChkDrawSprite					; draw the sprite
		move.w	(sp)+,d4

	.noparenttodraw:
		ori.b	#$80,obRender(a0)				; set onscreen flag
		lea		sub2_x_pos(a0),a6				; address of first child sprite info
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0		; get child sprite count
		subq.w	#1,d0							; if there are 0, go to next object
		bcs.s	BuildSprites_MultiDraw_NextObj

	.drawchildloop:
		swap	d0
		move.w	(a6)+,d3						; get X pos
		sub.w	(v_screenposx).w,d3				; subtract the screen's x position
		addi.w	#128,d3
		move.w	(a6)+,d2						; get Y pos
		sub.w	(v_screenposy).w,d2				; subtract the screen's y position
		addi.w	#128,d2
		andi.w	#$7FF,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1						; get mapping frame
		add.b	d1,d1
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		moveq	#0,d1
		move.b	(a1)+,d1
		subq.b	#1,d1                            ; get number of pieces
		bmi.s	.nochildleft                     ; if there are 0 pieces, branch
		move.w	d4,-(sp)
		bsr.s	ChkDrawSprite
		move.w	(sp)+,d4

.nochildleft:
		swap	d0
		dbf	d0,.drawchildloop					; repeat for number of child sprites

; loc_16804:
BuildSprites_MultiDraw_NextObj:
		bra.w	BuildSprites.skipObject
; End of function BuildSprites_MultiDraw


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Draw: ; sub_D750
		movea.w	obGfx(a0),a3

ChkDrawSprite:		; New label -- Devon Subsprites
		btst	#0,d4
		bne.s	BuildSpr_FlipX
		btst	#1,d4
		bne.w	BuildSpr_FlipY
; End of function BuildSpr_Draw


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Normal:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	.return
		move.b	(a1)+,d0	; get y-offset
		ext.w	d0
		add.w	d2,d0		; add y-position
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,(a2)+	; write sprite size
		addq.b	#1,d5		; increase sprite counter
		move.b	d5,(a2)+	; set as sprite link
		move.b	(a1)+,d0	; get art tile
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0		; add art tile offset
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d0	; get x-offset
		ext.w	d0
		add.w	d3,d0		; add x-position
		andi.w	#$1FF,d0	; keep within 512px
		bne.s	.writeX
		addq.w	#1,d0

	.writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,BuildSpr_Normal	; process next sprite piece

	.return:
		rts	
; End of function BuildSpr_Normal

; ===========================================================================

BuildSpr_FlipX:
		btst	#1,d4		; is object also y-flipped?
		bne.w	BuildSpr_FlipXY	; if yes, branch

	.loop:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	.return
		move.b	(a1)+,d0	; y position
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4	; size
		move.b	d4,(a2)+	
		addq.b	#1,d5		; link
		move.b	d5,(a2)+
		move.b	(a1)+,d0	; art tile
		lsl.w	#8,d0
		move.b	(a1)+,d0	
		add.w	a3,d0
		eori.w	#$800,d0	; toggle flip-x in VDP
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d0	; get x-offset
		ext.w	d0
		neg.w	d0			; negate it
		add.b	d4,d4		; calculate flipped position by size
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0	; keep within 512px
		bne.s	.writeX
		addq.w	#1,d0

	.writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,.loop		; process next sprite piece

	.return:
		rts	
; ===========================================================================

BuildSpr_FlipY:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	.return
		move.b	(a1)+,d0	; get y-offset
		move.b	(a1),d4		; get size
		ext.w	d0
		neg.w	d0		; negate y-offset
		lsl.b	#3,d4	; calculate flip offset
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0	; add y-position
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,(a2)+	; size
		addq.b	#1,d5
		move.b	d5,(a2)+	; link
		move.b	(a1)+,d0	; art tile
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0	; toggle flip-y in VDP
		move.w	d0,(a2)+
		move.b	(a1)+,d0	; x-position
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	.writeX
		addq.w	#1,d0

	.writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,BuildSpr_FlipY	; process next sprite piece

	.return:
		rts	
; ===========================================================================

BuildSpr_FlipXY:
		cmpi.b	#$50,d5		; check sprite limit
		beq.s	.return
		move.b	(a1)+,d0	; calculated flipped y
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d4	; size
		move.b	d4,(a2)+	; link
		addq.b	#1,d5
		move.b	d5,(a2)+	; art tile
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0	; toggle flip-x/y in VDP
		move.w	d0,(a2)+
		move.b	(a1)+,d0	; calculate flipped x
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	.writeX
		addq.w	#1,d0

	.writeX:
		move.w	d0,(a2)+	; write to buffer
		dbf	d1,BuildSpr_FlipXY	; process next sprite piece

	.return:
		rts