; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

TitleSonic:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		TSon_Index(pc,d0.w)
; ; =========================================================================
TSon_Index:
		bra.s	TSon_Main
		bra.s	TSon_Delay
		bra.s	TSon_Move
		bra.s	TSon_Animate
; ===========================================================================

TSon_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$F8,obX(a0)				; RetroKoH Title Screen Adjustment
		move.w	#$DE,obScreenY(a0)			; position is fixed to screen
		move.l	#Map_TSon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Title_Sonic,1,0),obGfx(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#29,obDelayAni(a0)			; set time delay to 0.5 seconds
		move.b	#$FF,objoff_3F(a0)			; Added for DPLC frame check
		lea		Ani_TSon(pc),a1
		bsr.w	AnimateSprite

TSon_Delay:	;Routine 2
		bsr.s	TSon_LoadGfx
		subq.b	#1,obDelayAni(a0)			; subtract 1 from time delay
		bpl.s	.wait						; if time remains, branch
		addq.b	#2,obRoutine(a0)			; go to next routine
		bra.w	DisplaySprite

.wait:
		rts	
; ===========================================================================

TSon_Move:	; Routine 4
		bsr.s	TSon_LoadGfx
		subq.w	#8,obScreenY(a0)	; move Sonic up
		cmpi.w	#$96,obScreenY(a0)	; has Sonic reached final position?
		bne.w	DisplaySprite		; if not, branch
		addq.b	#2,obRoutine(a0)
		bra.w	DisplaySprite
; ===========================================================================

TSon_Animate:	; Routine 6
		lea		Ani_TSon(pc),a1
		bsr.w	AnimateSprite
		bsr.s	TSon_LoadGfx	
		bra.w	DisplaySprite
; ===========================================================================

; ---------------------------------------------------------------------------
; Title Sonic dynamic pattern loading subroutine
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

TSon_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		cmp.b	objoff_3F(a0),d0		; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,objoff_3F(a0)		; update frame number for next check
		lea		TSonDynPLC(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5				; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange				; if zero, branch
		move.w	#(ArtTile_Title_Sonic*$20),d4

.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1	; S3K .b to .w
		move.w	d1,d3		; S3K
		lsr.w	#8,d3		; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_TitleSonic,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry	; repeat for number of entries

.nochange:
		rts