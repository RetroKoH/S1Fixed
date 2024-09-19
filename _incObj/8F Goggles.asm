; ---------------------------------------------------------------------------
; Object 8F - Goggles
; ---------------------------------------------------------------------------

GogglesItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Goggles_Index(pc,d0.w),d1
		jmp		Goggles_Index(pc,d1.w)
; ===========================================================================
Goggles_Index:		offsetTable
		offsetTableEntry.w	Goggles_Main
		offsetTableEntry.w	Goggles_Display
; ===========================================================================

Goggles_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Goggles,obMap(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Goggles,0,0),obGfx(a0)
		move.b	#1,obFrame(a0)
		rts	
; ===========================================================================

Goggles_Display:	; Routine 2
		btst	#sta2ndGoggles,(v_player+obStatus2nd).w	; does Sonic have Goggles?
		beq.s	.delete									; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)					; Copy first bit, so the Shield is always facing in the same direction as the player.
		bsr.s	Goggles_LoadGfx							; RetroKoH VRAM Overhaul
		jmp		(DisplaySprite).l
; ===========================================================================

; Remove the Goggles (Will be removed upon exiting water)
.delete:
		jmp		(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Goggles dynamic pattern loading subroutine -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

Goggles_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		cmp.b	objoff_3F(a0),d0		; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,objoff_3F(a0)		; update frame number for next check
		lea		GogglesDynPLC(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Goggles*$20),d4

.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1	; S3K .b to .w
		move.w	d1,d3		; S3K
		lsr.w	#8,d3		; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Goggles,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry	; repeat for number of entries

.nochange:
		rts
; ===========================================================================