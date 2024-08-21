; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

GiantRing:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GRing_Index(pc,d0.w),d1
		jmp		GRing_Index(pc,d1.w)
; ===========================================================================
GRing_Index:	offsetTable
		offsetTableEntry.w GRing_Main
		offsetTableEntry.w GRing_Animate
		offsetTableEntry.w GRing_Collect
		offsetTableEntry.w GRing_Flash		; Formerly the Ring Flash Object ($7C)
		offsetTableEntry.w GRing_Delete
; ===========================================================================

GRing_Main:	; Routine 0
		move.l	#Map_GRing,obMap(a0)
		move.w	#make_art_tile(ArtTile_Giant_Ring,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager - Moved here to fix a bug caused by the new manager
		move.b	#$40,obActWid(a0)
		move.b	#$FF,objoff_3F(a0)			; Added for DPLC frame check
		tst.b	obRender(a0)
		bpl.s	GRing_Animate

	if SpecialStagesWithAllEmeralds=0	; Mercury Special Stages Still Appear With All Emeralds
		cmpi.b	#emldCount,(v_emeralds).w	; do you have all emeralds?
		beq.w	DeleteObject				; if yes, branch
	endif	; Special Stages Still Appear With All Emeralds End

		cmpi.w	#50,(v_rings).w				; do you have at least 50 rings?
		bhs.s	GRing_Okay					; if yes, branch
		rts	
; ===========================================================================

GRing_Okay:
		addq.b	#2,obRoutine(a0)
		move.b	#$52,obColType(a0)

GRing_Animate:	; Routine 2
		move.b	(v_ani1_frame).w,obFrame(a0)
		bsr.w	GRing_LoadGfx					; RetroKoH VRAM Overhaul
		offscreen.w	DeleteObject				; ProjectFM S3K Objects Manager
		jmp		(DisplayAndCollision).l			; S3K TouchResponse
; ===========================================================================

GRing_Collect:	; Routine 4
		addq.b	#2,obRoutine(a0)		; Routine -> GRing_Flash
		move.w	#make_art_tile(ArtTile_Giant_Ring_Flash,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$20,obActWid(a0)

		move.b	#7,obFrame(a0)			; this will be incremented soon
		clr.b	obColType(a0)
		move.w	(v_player+obX).w,d0
		cmp.w	obX(a0),d0				; has Sonic come from the left?
		blo.s	GRing_PlaySnd			; if yes, branch
		bset	#0,obRender(a1)			; reverse flash	object

GRing_PlaySnd:
		move.w	#sfx_GiantRing,d0
		jsr		(PlaySound_Special).w	; play giant ring sound
; ===========================================================================

GRing_Flash:	; Routine 6
		subq.b	#1,obTimeFrame(a0)
		bpl.s	.skip
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#$10,obFrame(a0)		; has animation	finished?
		bhs.s	Flash_End				; if yes, branch
		cmpi.b	#$B,obFrame(a0)			; is 3rd flash frame displayed?
		bne.s	.skip					; if not, branch
		clr.b	(v_player+obAnim).w		; make Sonic invisible
		move.b	#1,(f_bigring).w		; stop Sonic getting bonuses
		andi.b	#~(mask2ndShield+mask2ndInvinc),(v_player+obStatus2nd).w	; Should clear Shield and Invincibility ($FC)

.skip:
		bsr.s	GRing_LoadGfx			; RetroKoH VRAM Overhaul
		offscreen.w	DeleteObject		; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite
; ===========================================================================

Flash_End:
		addq.b	#2,obRoutine(a0)
		clr.w	(v_player).w 			; remove Sonic object (clears both ID and render flags)
	;	addq.l	#4,sp
		rts
; ===========================================================================

GRing_Delete:	; Routine 8
		bra.w	DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Giant Ring dynamic pattern loading subroutine
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

GRing_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		move.b	d0,d1					; copy to d1
		cmp.b	objoff_3F(a0),d0		; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,objoff_3F(a0)		; update frame number for next check
		lea		GRingDynPLC(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5				; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange				; if zero, branch
		move.w	#(ArtTile_Giant_Ring*$20),d4
		cmpi.b	#8,d1					; are we drawing a ring flash?
		blo.s	.readentry				; if not, skip ahead
		move.w	#(ArtTile_Giant_Ring_Flash*$20),d4

.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1				; S3K .b to .w
		move.w	d1,d3					; S3K
		lsr.w	#8,d3					; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_BigRing,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry			; repeat for number of entries

.nochange:
		rts