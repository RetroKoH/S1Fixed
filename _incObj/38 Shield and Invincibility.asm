; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

; w/ DPLCs and dynamic pointers -- RetroKoH VRAM Overhaul
obArtLoc	equ	$38
obDPLCLoc	equ	$3C

ShieldItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp		Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:
		dc.w Shi_Main-Shi_Index
		dc.w Shi_Shield-Shi_Index
		dc.w Shi_Stars-Shi_Index
; ===========================================================================

Shi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Shield,obMap(a0)
		move.l	#Art_Shield,obArtLoc(a0)
		move.l	#ShieldDynPLC,obDPLCLoc(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)		; RetroKoH S2 Priority Manager
		move.b	#$10,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)
		tst.b	obAnim(a0)				; is object a shield?
		beq.s	.shield					; if yes, branch
		move.l	#Art_Stars,obArtLoc(a0)
		move.l	#ShieldDynPLC,obDPLCLoc(a0)
		addq.b	#2,obRoutine(a0)		; Stars specific code: goto Shi_Stars next
.shield:
		rts
; ===========================================================================

Shi_Shield:	; Routine 2
		tst.b	(v_invinc).w		; does Sonic have invincibility?
		bne.s	.remove				; if yes, branch
		tst.b	(v_shield).w		; does Sonic have shield?
		beq.s	.delete				; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Shield_LoadGfx		; RetroKoH VRAM Overhaul
		jmp		(DisplaySprite).l

.remove:
		rts	

.delete:
		jmp	(DeleteObject).l
; ===========================================================================

Shi_Stars:	; Routine 4
		tst.b	(v_invinc).w		; does Sonic have invincibility?
		beq.w	Shi_Start_Delete	; if not, branch
		move.w	(v_trackpos).w,d0	; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1

;.trail:
		lsl.b	#3,d1		; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	objoff_30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		blo.s	.a
		moveq	#0,d1

.a:
		move.b	d1,objoff_30(a0)

.b:
		lea		(v_tracksonic).w,a1
		lea		(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Stars_LoadGfx		; RetroKoH VRAM Overhaul
		jmp		(DisplaySprite).l
; ===========================================================================

Shi_Start_Delete:	
		jmp	(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Shield and Stars dynamic pattern loading subroutine
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

Stars_LoadGfx:
		moveq	#0,d0
		move.b	(v_starsobj1+obFrame).w,d0	; load frame number
		bra.s   ShieldPLC_Cont

Shield_LoadGfx:
		moveq	#0,d0
		move.b	(v_shieldobj+obFrame).w,d0	; load frame number

ShieldPLC_Cont:
		movea.l	obDPLCLoc(a0),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5					; read "number of entries" value
		subq.w	#1,d5
		bmi.s	ShieldDPLC_Return			; if zero, branch
		move.w	#(ArtTile_Shield*$20),d4

ShieldPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	obArtLoc(a0),d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,ShieldPLC_ReadEntry		; repeat for number of entries

ShieldDPLC_Return:
		rts
