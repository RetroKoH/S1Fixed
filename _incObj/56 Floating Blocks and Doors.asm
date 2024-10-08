; ---------------------------------------------------------------------------
; Object 56 - floating blocks (SYZ/SLZ), large doors (LZ)
; ---------------------------------------------------------------------------

fb_origX = objoff_34		; original x-axis position
fb_origY = objoff_30		; original y-axis position
fb_height = objoff_3A		; total object height
fb_type = objoff_3C			; subtype (2nd digit only)

; ===========================================================================
FBlock_Var:	; width/2, height/2
		dc.b  $10, $10	; subtype 0x/8x ($0)
		dc.b  $20, $20	; subtype 1x/9x ($2)
		dc.b  $10, $20	; subtype 2x/Ax ($4)
		dc.b  $20, $1A	; subtype 3x/Bx ($6)
		dc.b  $10, $27	; subtype 4x/Cx ($8)
		dc.b  $10, $10	; subtype 5x/Dx ($A)
		dc.b	8, $20	; subtype 6x/Ex ($C)
		dc.b  $40, $10	; subtype 7x/Fx ($E)
		
	; Giant stairs seem to be formed by subtypes $58, 59, 5A, and 5B placed together
; ===========================================================================

FloatingBlock:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.w	FBlock_Action
	; Object Routine Optimization End

FBlock_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_FBlock,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)		; SYZ/SLZ code
		cmpi.b	#id_LZ,(v_zone).w ; check if level is LZ
		bne.s	.notLZ
		move.w	#make_art_tile(ArtTile_LZ_Door,2,0),obGfx(a0)	; LZ specific code

.notLZ:
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype
		lsr.w	#3,d0
		andi.w	#$E,d0						; Example: Subtype $F8 >> 3 = $1F. $1F & $E = $E.
		lea		FBlock_Var(pc,d0.w),a2		; get size data
		move.b	(a2)+,obActWid(a0)
		move.b	(a2),obHeight(a0)
		lsr.w	#1,d0
		move.b	d0,obFrame(a0)
		move.w	obX(a0),fb_origX(a0)		; store starting positions
		move.w	obY(a0),fb_origY(a0)
		moveq	#0,d0
		move.b	(a2),d0
		add.w	d0,d0
		move.w	d0,fb_height(a0)			; store full height (from top to bottom)
		cmpi.b	#$37,obSubtype(a0)
		bne.s	.dontdelete					; Branch if subtype /= $37
	; Only applies to subtype $37
		cmpi.w	#$1BB8,obX(a0)
		bne.s	.notatpos					; if not in position, branch
		tst.b	(f_obj56).w
		beq.s	.dontdelete					; if delete flag isn't set, branch
		jmp		(DeleteObject).l

.notatpos:
		clr.b	obSubtype(a0)				; clear subtype for obj $5637
		tst.b	(f_obj56).w
		bne.s	.dontdelete
		jmp		(DeleteObject).l

.dontdelete:
		moveq	#0,d0
		cmpi.b	#id_LZ,(v_zone).w			; check if level is LZ
		beq.s	.isLZ
		move.b	obSubtype(a0),d0			; SYZ/SLZ specific code
		andi.w	#$F,d0
		subq.w	#8,d0
		bcs.s	.isLZ
		lsl.w	#2,d0
		lea		(v_oscillate+$2C).w,a2
		lea		(a2,d0.w),a2
		tst.w	(a2)
		bpl.s	.isLZ
		bchg	#staFlipX,obStatus(a0)

.isLZ:
		move.b	obSubtype(a0),d0
		bpl.s	FBlock_Action
		andi.b	#$F,d0
		move.b	d0,fb_type(a0)				; set switch index
		move.b	#5,obSubtype(a0)			; subtype is now $05
		cmpi.b	#7,obFrame(a0)
		bne.s	.chkstate
		move.b	#$C,obSubtype(a0)			; long horizontal doors have subtype of $0C instead
		move.w	#$80,fb_height(a0)

.chkstate:
	; ProjectFM S3K Object Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	FBlock_Action		; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
		btst	#0,(a2)
	; End
		beq.s	FBlock_Action
		addq.b	#1,obSubtype(a0)	; increment to $06 (or $0D for long horizontal doors)
		clr.w	fb_height(a0)

FBlock_Action:	; Routine 2
		move.w	obX(a0),-(sp)
		moveq	#0,d0
		move.b	obSubtype(a0),d0	; get object subtype
		andi.w	#$F,d0				; read only the	2nd digit
		add.w	d0,d0
		move.w	.index(pc,d0.w),d1
		jsr		.index(pc,d1.w)		; move block subroutines
		move.w	(sp)+,d4
		tst.b	obRender(a0)
		bpl.s	.chkdel
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	obHeight(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject

.chkdel:
		offscreen.s	.chkdel2,fb_origX(a0)	; ProjectFM S3K Object Manager

.display:
		bra.w	DisplaySprite

.chkdel2:
		cmpi.b	#$37,obSubtype(a0)
		bne.s	.delete
		tst.b	objoff_38(a0)
		bne.w	DisplaySprite

.delete:
		jmp	(DeleteObject).l
; ===========================================================================
.index:
		dc.w .type00-.index, .type01-.index
		dc.w .type02-.index, .type03-.index
		dc.w .type04-.index, .type05-.index
		dc.w .type06-.index, .type07-.index
		dc.w .type08-.index, .type09-.index
		dc.w .type0A-.index, .type0B-.index
		dc.w .type0C-.index, .type0D-.index
; ===========================================================================

.type01:
; moves side-to-side
		move.w	#$40,d1		; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$A).w,d0
		bra.s	.moveLR
; ===========================================================================

.type02:
; moves side-to-side
		move.w	#$80,d1		; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$1E).w,d0

.moveLR:
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	d0
		add.w	d1,d0

.noflip:
		move.w	fb_origX(a0),d1
		sub.w	d0,d1
		move.w	d1,obX(a0)	; move object horizontally
.type00:
; doesn't move
		rts		
; ===========================================================================

.type03:
; moves up/down
		move.w	#$40,d1		; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$A).w,d0
		bra.s	.moveUD
; ===========================================================================

.type04:
; moves up/down
		move.w	#$80,d1		; set move distance
		moveq	#0,d0
		move.b	(v_oscillate+$1E).w,d0

.moveUD:
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip04
		neg.w	d0
		add.w	d1,d0

.noflip04:
		move.w	fb_origY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)	; move object vertically
		rts	
; ===========================================================================

.type05:
; moves up when a switch is pressed
		tst.b	objoff_38(a0)
		bne.s	.loc_104A4
		cmpi.w	#(id_LZ<<8)+0,(v_zone).w ; is level LZ1 ?
		bne.s	.aaa		; if not, branch
		cmpi.b	#3,fb_type(a0)
		bne.s	.aaa
		clr.b	(f_wtunnelallow).w
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0
		bhs.s	.aaa
		move.b	#1,(f_wtunnelallow).w

.aaa:
		lea	(f_switch).w,a2
		moveq	#0,d0
		move.b	fb_type(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	.loc_104AE
		cmpi.w	#(id_LZ<<8)+0,(v_zone).w ; is level LZ1 ?
		bne.s	.loc_1049E	; if not, branch
		cmpi.b	#3,d0
		bne.s	.loc_1049E
		clr.b	(f_wtunnelallow).w

.loc_1049E:
		move.b	#1,objoff_38(a0)

.loc_104A4:
		tst.w	fb_height(a0)
		beq.s	.loc_104C8
		subq.w	#2,fb_height(a0)

.loc_104AE:
		move.w	fb_height(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.loc_104BC
		neg.w	d0

.loc_104BC:
		move.w	fb_origY(a0),d1
		add.w	d0,d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

.loc_104C8:
		addq.b	#1,obSubtype(a0)
		clr.b	objoff_38(a0)
	; ProjectFM S3K Object Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	.loc_104AE			; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bset	#0,(a2)
	; End
		bra.s	.loc_104AE
; ===========================================================================

.type06:
		tst.b	objoff_38(a0)
		bne.s	.loc_10500
		lea	(f_switch).w,a2
		moveq	#0,d0
		move.b	fb_type(a0),d0
		tst.b	(a2,d0.w)
		bpl.s	.loc_10512
		move.b	#1,objoff_38(a0)

.loc_10500:
		moveq	#0,d0
		move.b	obHeight(a0),d0
		add.w	d0,d0
		cmp.w	fb_height(a0),d0
		beq.s	.loc_1052C
		addq.w	#2,fb_height(a0)

.loc_10512:
		move.w	fb_height(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.loc_10520
		neg.w	d0

.loc_10520:
		move.w	fb_origY(a0),d1
		add.w	d0,d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

.loc_1052C:
		subq.b	#1,obSubtype(a0)
		clr.b	objoff_38(a0)
	; ProjectFM S3K Obj Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	.loc_10512			; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#0,(a2)
	; End
		bra.s	.loc_10512
; ===========================================================================

.type07:
		tst.b	objoff_38(a0)
		bne.s	.loc_1055E
		tst.b	(f_switch+$F).w	; has switch number $F been pressed?
		beq.s	.locret_10578
		move.b	#1,objoff_38(a0)
		clr.w	fb_height(a0)

.loc_1055E:
		addq.w	#1,obX(a0)
		move.w	obX(a0),fb_origX(a0)
		addq.w	#1,fb_height(a0)
		cmpi.w	#$380,fb_height(a0)
		bne.s	.locret_10578
		move.b	#1,(f_obj56).w
		clr.b	objoff_38(a0)
		clr.b	obSubtype(a0)

.locret_10578:
		rts	
; ===========================================================================

.type0C:
		tst.b	objoff_38(a0)
		bne.s	.loc_10598
		lea	(f_switch).w,a2
		moveq	#0,d0
		move.b	fb_type(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	.loc_105A2
		move.b	#1,objoff_38(a0)

.loc_10598:
		tst.w	fb_height(a0)
		beq.s	.loc_105C0
		subq.w	#2,fb_height(a0)

.loc_105A2:
		move.w	fb_height(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.loc_105B4
		neg.w	d0
		addi.w	#$80,d0

.loc_105B4:
		move.w	fb_origX(a0),d1
		add.w	d0,d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================

.loc_105C0:
		addq.b	#1,obSubtype(a0)
		clr.b	objoff_38(a0)
	; ProjectFM S3K Obj Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	.loc_105A2			; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bset	#0,(a2)
	; End
		bra.s	.loc_105A2
; ===========================================================================

.type0D:
		tst.b	objoff_38(a0)
		bne.s	.loc_105F8
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	fb_type(a0),d0
		tst.b	(a2,d0.w)
		bpl.s	.wtf
		move.b	#1,objoff_38(a0)

.loc_105F8:
		move.w	#$80,d0
		cmp.w	fb_height(a0),d0
		beq.s	.loc_10624
		addq.w	#2,fb_height(a0)

.wtf:
		move.w	fb_height(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.loc_10618
		neg.w	d0
		addi.w	#$80,d0

.loc_10618:
		move.w	fb_origX(a0),d1
		add.w	d0,d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================

.loc_10624:
		subq.b	#1,obSubtype(a0)
		clr.b	objoff_38(a0)
	; ProjectFM S3K Obj Manager
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.s	.wtf				; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#0,(a2)
	; End
		bra.s	.wtf
; ===========================================================================

.type08:
		move.w	#$10,d1
		moveq	#0,d0
		move.b	(v_oscillate+$2A).w,d0
		lsr.w	#1,d0
		move.w	(v_oscillate+$2C).w,d3
		bra.s	.square
; ===========================================================================

.type09:
		move.w	#$30,d1
		moveq	#0,d0
		move.b	(v_oscillate+$2E).w,d0
		move.w	(v_oscillate+$30).w,d3
		bra.s	.square
; ===========================================================================

.type0A:
		move.w	#$50,d1
		moveq	#0,d0
		move.b	(v_oscillate+$32).w,d0
		move.w	(v_oscillate+$34).w,d3
		bra.s	.square
; ===========================================================================

.type0B:
		move.w	#$70,d1
		moveq	#0,d0
		move.b	(v_oscillate+$36).w,d0
		move.w	(v_oscillate+$38).w,d3

.square:
		tst.w	d3
		bne.s	.loc_1068E
		addq.b	#1,obStatus(a0)
		andi.b	#(maskFlipX+maskFlipY),obStatus(a0)

.loc_1068E:
		move.b	obStatus(a0),d2
		andi.b	#(maskFlipX+maskFlipY),d2
		bne.s	.loc_106AE
		sub.w	d1,d0
		add.w	fb_origX(a0),d0
		move.w	d0,obX(a0)
		neg.w	d1
		add.w	fb_origY(a0),d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

.loc_106AE:
		subq.b	#1,d2
		bne.s	.loc_106CC
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	fb_origY(a0),d0
		move.w	d0,obY(a0)
		addq.w	#1,d1
		add.w	fb_origX(a0),d1
		move.w	d1,obX(a0)
		rts	
; ===========================================================================

.loc_106CC:
		subq.b	#1,d2
		bne.s	.loc_106EA
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	fb_origX(a0),d0
		move.w	d0,obX(a0)
		addq.w	#1,d1
		add.w	fb_origY(a0),d1
		move.w	d1,obY(a0)
		rts	
; ===========================================================================

.loc_106EA:
		sub.w	d1,d0
		add.w	fb_origY(a0),d0
		move.w	d0,obY(a0)
		neg.w	d1
		add.w	fb_origX(a0),d1
		move.w	d1,obX(a0)
		rts	
