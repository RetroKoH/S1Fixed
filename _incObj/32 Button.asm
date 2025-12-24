
; ---------------------------------------------------------------------------
; Object 32 - buttons (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Button:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	But_Pressed
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

But_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_But,obMap(a0)
		move.w	#make_art_tile(ArtTile_Button,0,0),obGfx(a0)
		cmpi.b	#id_MZ,(v_zone).w				; is level Marble Zone?
		bne.s	But_NotMZ						; if not, branch
		bset	#gfxPalUpper,obGfx(a0)			; if MZ, set to pal line 2 -- RetroKoH VRAM Overhaul

But_NotMZ:
		move.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority4,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		addq.w	#3,obY(a0)
; ---------------------------------------------------------------------------

But_Pressed:	; Routine 2
		tst.b	obRender(a0)					; is button on screen?
		bpl.s	But_Display						; if not, branch
		moveq	#27,d1							; width; save 4 cycles - Filter
		moveq	#5,d2							; height (jumping); save 4 cycles - Filter
		moveq	#5,d3							; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4						; axis position
		bsr.w	SolidObject
		bclr	#0,obFrame(a0)					; use "unpressed" frame
		moveq	#$F,d0
		and.b	obSubtype(a0),d0				; get low nybble of subtype; SCE Optimization
		lea		(f_switch).w,a3
		lea		(a3,d0.w),a3					; (a3) = button status
		moveq	#0,d3
		btst	#6,obSubtype(a0)				; is subtype $4x or $Cx? (unused)
		beq.s	.not_secondary					; if not, branch
		moveq	#7,d3							; d3 = bit to set/clear in button status

	.not_secondary:
		tst.b	obSubtype(a0)					; is subtype +$80?
		bpl.s	.subtype_0x						; if not, branch
		bsr.w	But_MZPushBlock					; check collision with MZ pushable block
		bne.s	But_Press						; branch if found

	.subtype_0x:
		btst	#staSonicOnObj,obStatus(a0)		; is Sonic standing on the button? (removed obSolid)
		bne.s	But_Press						; if yes, branch
		bclr	d3,(a3)							; clear button status
		bra.s	But_Flash
; ===========================================================================

But_Press:
		tst.b	(a3)							; is button already pressed?
		bne.s	.already_pressed				; if yes, branch
		move.w	#sfx_Switch,d0
		jsr		(QueueSound2).w					; play switch sound

	.already_pressed:
		bset	d3,(a3)							; set switch byte
		bset	#0,obFrame(a0)					; use "pressed"	frame

But_Flash:
		btst	#5,obSubtype(a0)				; is subtype +$20?
		beq.s	But_Display						; if not, branch
		subq.b	#1,obTimeFrame(a0)				; decrement timer
		bpl.s	But_Display						; branch if time remains
		move.b	#7,obTimeFrame(a0)				; set timer to 7 frames
		bchg	#1,obFrame(a0)					; use frame 2/3

But_Display:
		offscreen.w	DeleteObject				; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite					; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to detect collision with MZ pushable green block
;
; output:
;	d0 = 0 if not found; 1 if found
; ---------------------------------------------------------------------------

But_MZPushBlock:
		move.w	d3,-(sp)
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#$10,d2					; d2 = x pos. of button left edge
		subq.w	#8,d3					; d3 = y pos. of button top edge
		moveq	#$20,d4					; d4 = x detection range
		moveq	#$10,d5					; d5 = y detection range
		lea		(v_lvlobjspace).w,a1	; begin checking object RAM
		move.w	#v_lvlobjcount,d6

	.loop:
		tst.b	obRender(a1)
		bpl.s	.next
		cmpi.l	#PushBlock,obAddr(a1)	; is the object a green MZ block?
		beq.s	.found_block			; if yes, branch

	.next:
		lea		object_size(a1),a1		; check	next object
		dbf		d6,.loop				; repeat $5F times

		move.w	(sp)+,d3
		moveq	#0,d0
		rts	
; ===========================================================================
; TO-DO remove table lookup and load directly
	.sizes:	dc.b $10, $10				; x and y radius of pushable block
; ===========================================================================

	.found_block:
		moveq	#1,d0
		andi.w	#$3F,d0
		add.w	d0,d0					; d0 = 2
		lea	.sizes-2(pc,d0.w),a2
		move.b	(a2)+,d1
		ext.w	d1						; d1 = $10
		move.w	obX(a1),d0				; d0 = x pos. of pblock
		sub.w	d1,d0
		sub.w	d2,d0					; d0 = pblock-button
		bcc.s	.pblock_right			; branch if pblock is right of button
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	.pblock_x_ok			; branch if pblock is within $20 pixels of button
		bra.s	.next
; ===========================================================================

	.pblock_right:
		cmp.w	d4,d0					; are pblock and button within $20 pixels?
		bhi.s	.next					; if not, branch

	.pblock_x_ok:
		move.b	(a2)+,d1
		ext.w	d1						; d1 = $10
		move.w	obY(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	.pblock_above
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	.pblock_y_ok
		bra.s	.next
; ===========================================================================

	.pblock_above:
		cmp.w	d5,d0
		bhi.s	.next

	.pblock_y_ok:
		move.w	(sp)+,d3
		moveq	#1,d0
		rts
; End of function But_MZPushBlock
; ===========================================================================