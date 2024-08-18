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
		tst.w	(a4)					; are there objects left to draw?
		beq.w	.nextPriority			; if not, branch
		moveq	#2,d6

	.objectLoop:
		movea.w	(a4,d6.w),a0			; load object ID

	; These are sanity checks to detect invalid objects which should not
	; have been queued for display. They deliberately crash the console
	; if they detect an invalid object.
		tst.b	obID(a0)				; if null, branch
		beq.w	.skipObject				; was .crash
		tst.l	obMap(a0)
		beq.w	.skipObject				; (to be removed) jump to crash if loading a null pointer

		bclr	#7,obRender(a0)			; set as not visible
		move.b	obRender(a0),d0
		move.b	d0,d4
	; Devon Subsprites
		btst	#6,d0					; is the multi-draw flag set?
		bne.w	BuildSprites_MultiDraw	; if it is, branch
	; Devon Subsprites End
		andi.w	#$C,d0 					; is this to be positioned by screen coordinates?
		beq.s	.screenCoords			; if yes, branch

		lea		(v_screenposx).w,a1
	; check object bounds
		moveq	#0,d0
		move.b	obActWid(a0),d0
		move.w	obX(a0),d3
		sub.w	(a1),d3			; d3 = screen x-pos
		move.w	d3,d1
		add.w	d0,d1			; is the object right edge to the left of the screen?
		bmi.w	.skipObject		; if it is, branch
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1			; is the object left edge to the right of the screen?
		bge.s	.skipObject		; if it is, branch
		addi.w	#128,d3			; VDP sprites start at 128px
		btst	#4,d4			; is assume height flag on?
		beq.s	.assumeHeight	; if yes, branch
		moveq	#0,d0
		move.b	obHeight(a0),d0
		move.w	obY(a0),d2
		sub.w	4(a1),d2		; d2 = screen y-pos
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	.skipObject		; if the object is above the screen
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1
		bge.s	.skipObject
		addi.w	#128,d2			; if the object is below the screen
		bra.s	.drawObject
; ===========================================================================

	.screenCoords:
		move.w	obScreenY(a0),d2	; special variable for screen Y
		move.w	obX(a0),d3			; x-pos, without sub-pixels
		bra.s	.drawObject
; ===========================================================================

	.assumeHeight:
		move.w	obY(a0),d2
		sub.w	4(a1),d2		; subtract screen y-pos
		addi.w	#128,d2
	; took out S2 hard-coded y-wrap check
		cmpi.w	#-32+128,d2		; assume height to be 32 pixels
		blo.s	.skipObject
		cmpi.w	#32+128+224,d2
		bhs.s	.skipObject

	.drawObject:
		movea.l	obMap(a0),a1
		moveq	#0,d1
		btst	#5,d4				; is static mappings flag on?
		bne.s	.drawFrame			; if yes, branch
		move.b	obFrame(a0),d1
		add.w	d1,d1				; changed to .w (we want more than 7F sprites) -- MarkeyJester Art Limit Extensions
		adda.w	(a1,d1.w),a1		; get mappings frame address
		move.w	(a1)+,d1			; number of sprite pieces (S2 BuildSprites: loading .w, so no need to clear d1)
		subq.w	#1,d1				; S2 BuildSprites Change .b > .w.
		bmi.s	.setVisible			; if there are 0 pieces, branch

	.drawFrame:
		bsr.w	BuildSpr_Draw		; write data from sprite pieces to buffer

	.setVisible:
		bset	#7,obRender(a0)		; set object as visible

	.skipObject:
		addq.w	#2,d6				; load next object
		subq.w	#2,(a4)				; decrement object count
		bne.w	.objectLoop			; if there are objects left, repeat

	.nextPriority:
		lea		$80(a4),a4				; load next priority level
		dbf		d7,.priorityLoop		; loop
		move.b	d5,(v_spritecount).w	; Terminate the sprite list.
	; If the sprite list is full, then set the link field of the last
	; entry to 0. Otherwise, push the next sprite offscreen and set its
	; link field to 0. You might be thinking why this doesn't just do the
	; first one no matter what. Well, think about what if the sprite list
	; was empty: then it would access data before the start of the list.
		cmpi.b	#80,d5			; was the sprite limit reached (80 sprites)?
		beq.s	.spriteLimit	; if it was, branch
		clr.l	(a2)			; set link field to 0
		rts

	.spriteLimit:
		clr.b	-5(a2)			; set last sprite link
		rts	
; End of function BuildSprites
; ===========================================================================
; To be removed
;.crash:
	; For helping detect when an object tries to display with a blank ID
	; or mappings pointer. The latter is an issue that plagues Sonic 1.
	; Can remove once all delete-and-display bugs are taken care of.
;	move.w	(1).w,d0	; causes a crash because of the word operation at an odd address
;	bra.s	.skipObject
; ===========================================================================

; Devon Subsprites
BuildSprites_MultiDraw:
		move.l	a4,-(sp)
		lea		(v_screenposx).w,a4
		movea.w	obGfx(a0),a3
		movea.l	obMap(a0),a5
		moveq	#0,d0

		; check if object is within X bounds
		move.b	mainspr_width(a0),d0			; load pixel width
		move.w	obX(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1							; is the object's right edge to the left of the screen?
		bmi.w	.skipObject	; if yes, branch
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#320,d1							; is the object's left edge to the right of the screen?
		bge.w	.skipObject	; if yes, branch
		addi.w	#128,d3

		; check if object is within Y bounds
		btst	#4,d4							; is the accurate Y check flag set?
		beq.s	.assumeHeight					; if not, branch
		moveq	#0,d0
		move.b	mainspr_height(a0),d0			; load pixel height
		sub.w	4(a4),d2						; subtract screen y-pos
		move.w	d2,d1
		add.w	d0,d1							; is the object above the screen?
		bmi.w	.skipObject	; if yes, branch
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#224,d1							; is the object below the screen?
		bge.w	.skipObject	; if yes, branch
		addi.w	#128,d2
		bra.s	.drawSprite

.assumeHeight:
; this doesn't take into account the height of the sprite/object when checking
; if it's onscreen vertically or not.
		move.w	obY(a0),d2
		sub.w	4(a4),d2						; subtract screen y-pos
		addi.w	#128,d2
	; took out S2 hard-coded y-wrap check
		cmpi.w	#-32+128,d2
		blo.s	.skipObject
		cmpi.w	#32+128+224,d2
		bhs.s	.skipObject

.drawSprite:
		moveq	#0,d1
		move.b	mainspr_mapframe(a0),d1			; get current frame
		beq.s	.noparenttodraw
		add.w	d1,d1							; S2 BuildSprites Change .b > .w.
		movea.l	a5,a1							; a5 is obMap(a0), copy to a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1						; S2 BuildSprites Change .b > .w.
		subq.w	#1,d1							; get number of pieces ; S2 BuildSprites Change .b > .w.
		bmi.s	.noparenttodraw					; if there are 0 pieces, branch
		move.w	d4,-(sp)
		bsr.w	ChkDrawSprite					; draw the sprite
		move.w	(sp)+,d4

	.noparenttodraw:
		bset	#7,obRender(a0)					; set onscreen flag
		lea		subspr_data(a0),a6				; address of first child sprite info
		moveq	#0,d0
		move.b	mainspr_childsprites(a0),d0		; get child sprite count
		subq.w	#1,d0							; if there are 0, go to next object
		bcs.s	.skipObject

	.drawchildloop:
		swap	d0
		move.w	(a6)+,d3						; get X pos
		sub.w	(a4),d3							; subtract the screen's x position
		addi.w	#128,d3
		move.w	(a6)+,d2						; get Y pos
		sub.w	4(a4),d2						; subtract the screen's y position
		addi.w	#128,d2
	; took out S2 hard-coded y-wrap check
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1						; get mapping frame
		add.w	d1,d1							; S2 BuildSprites Change .b > .w.
		movea.l	a5,a1
		adda.w	(a1,d1.w),a1
		move.w	(a1)+,d1						; S2 BuildSprites Change .b > .w.
		subq.w	#1,d1							; get number of pieces ; S2 BuildSprites Change .b > .w.
		bmi.s	.nochildleft					; if there are 0 pieces, branch
		move.w	d4,-(sp)
		bsr.s	ChkDrawSprite
		move.w	(sp)+,d4

.nochildleft:
		swap	d0
		dbf	d0,.drawchildloop					; repeat for number of child sprites

; loc_16804:
.skipObject:
		movea.l	(sp)+,a4
		bra.w	BuildSprites.skipObject
; End of function BuildSprites_MultiDraw


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Draw: ; sub_D750
		movea.w	obGfx(a0),a3

ChkDrawSprite:		; New label -- Devon Subsprites
		btst	#0,d4			; is the sprite to be X-flipped?
		bne.s	BuildSpr_FlipX	; if yes, branch
		btst	#1,d4			; is the sprite to be Y-flipped?
		bne.w	BuildSpr_FlipY	; if yes, branch
; End of function BuildSpr_Draw


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSpr_Normal:
		cmpi.b	#80,d5		; has the sprite limit been reached?
		bhs.s	.return		; if yes, branch
		move.b	(a1)+,d0	; get y-offset
		ext.w	d0
		add.w	d2,d0		; add y-position
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,(a2)+	; write sprite size
		addq.b	#1,d5		; increase sprite counter
		move.b	d5,(a2)+	; set as sprite link
		move.w	(a1)+,d0	; get art tile ; S2 BuildSprites .b > .w
		add.w	a3,d0		; add art tile offset
		move.w	d0,(a2)+	; set art tile and flags
		addq.w	#2,a1		; S2 BuildSprites Addition
		move.w	(a1)+,d0	; get x-offset ; S2 BuildSprites .b > .w
		add.w	d3,d0		; add x-position
		andi.w	#$1FF,d0	; keep within 512px
		bne.s	.writeX
		addq.w	#1,d0		; avoid activating sprite masking

	.writeX:
		move.w	d0,(a2)+			; write to buffer
		dbf		d1,BuildSpr_Normal	; process next sprite piece

	.return:
		rts	
; End of function BuildSpr_Normal

; ===========================================================================

BuildSpr_FlipX:
		btst	#1,d4		; is object also y-flipped?
		bne.w	BuildSpr_FlipXY	; if yes, branch

	.loop:
		cmpi.b	#80,d5		; check sprite limit
		bhs.s	.return
		move.b	(a1)+,d0	; y position
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4	; size
		move.b	d4,(a2)+	
		addq.b	#1,d5		; link
		move.b	d5,(a2)+
		move.w	(a1)+,d0	; art tile ; S2 BuildSprites .b > .w
		add.w	a3,d0
		eori.w	#$800,d0	; toggle flip-x in VDP
		move.w	d0,(a2)+	; write to buffer
		addq.w	#2,a1
		move.w	(a1)+,d0	; get x-offset ; S2 BuildSprites .b > .w
		neg.w	d0			; negate it
		move.b	CellOffsets_XFlip(pc,d4.w),d4	; Get precooked flipped pos instead of calculating
		sub.w	d4,d0		; subtract sprite size
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
; S2 BuildSprites Addition (Precooked position values instead of calculating on the fly)
; offsets for horizontally mirrored sprite pieces
CellOffsets_XFlip:
	dc.b   8,  8,  8,  8	; 4
	dc.b $10,$10,$10,$10	; 8
	dc.b $18,$18,$18,$18	; 12
	dc.b $20,$20,$20,$20	; 16
; offsets for vertically mirrored sprite pieces
CellOffsets_YFlip:
	dc.b   8,$10,$18,$20	; 4
	dc.b   8,$10,$18,$20	; 8
	dc.b   8,$10,$18,$20	; 12
	dc.b   8,$10,$18,$20	; 16
; ===========================================================================
BuildSpr_FlipY:
		cmpi.b	#80,d5		; check sprite limit
		bhs.s	.return
		move.b	(a1)+,d0	; get y-offset
		move.b	(a1),d4		; get size
		ext.w	d0
		neg.w	d0			; negate y-offset
		move.b	CellOffsets_YFlip(pc,d4.w),d4	; Get precooked flipped pos instead of calculating
		sub.w	d4,d0
		add.w	d2,d0		; add y-position
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,(a2)+	; size
		addq.b	#1,d5
		move.b	d5,(a2)+	; link
		move.w	(a1)+,d0	; art tile S2 BuildSprites Change .b > .w
		add.w	a3,d0
		eori.w	#$1000,d0	; toggle flip-y in VDP
		move.w	d0,(a2)+
		addq.w	#2,a1		; S2 BuildSprites Addition
		move.w	(a1)+,d0	; x-position S2 BuildSprites Change .b > .w
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	.writeX
		addq.w	#1,d0

	.writeX:
		move.w	d0,(a2)+			; write to buffer
		dbf		d1,BuildSpr_FlipY	; process next sprite piece

	.return:
		rts	
; ===========================================================================
; offsets for vertically mirrored sprite pieces
CellOffsets_YFlip2:
	dc.b   8,$10,$18,$20	; 4
	dc.b   8,$10,$18,$20	; 8
	dc.b   8,$10,$18,$20	; 12
	dc.b   8,$10,$18,$20	; 16
; ===========================================================================
BuildSpr_FlipXY:
		cmpi.b	#80,d5		; check sprite limit
		bhs.s	.return
		move.b	(a1)+,d0	; calculated flipped y
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	CellOffsets_YFlip2(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+	; write to buffer
		move.b	(a1)+,d4	; size
		move.b	d4,(a2)+	; link
		addq.b	#1,d5
		move.b	d5,(a2)+	; art tile
		move.w	(a1)+,d0	; S2 BuildSprites Change .b > .w
		add.w	a3,d0
		eori.w	#$1800,d0	; toggle flip-x/y in VDP
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0	; calculate flipped x ; S2 BuildSprites Change .b > .w
		neg.w	d0
		move.b	CellOffsets_XFlip2(pc,d4.w),d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	.writeX
		addq.w	#1,d0

	.writeX:
		move.w	d0,(a2)+			; write to buffer
		dbf		d1,BuildSpr_FlipXY	; process next sprite piece

	.return:
		rts
; End of function DrawSprite

; ===========================================================================
; offsets for horizontally mirrored sprite pieces
CellOffsets_XFlip2:
	dc.b   8,  8,  8,  8	; 4
	dc.b $10,$10,$10,$10	; 8
	dc.b $18,$18,$18,$18	; 12
	dc.b $20,$20,$20,$20	; 16
; ===========================================================================