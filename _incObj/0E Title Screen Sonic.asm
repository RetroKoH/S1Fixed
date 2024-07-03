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
		move.w	#$F8,obX(a0)		; RetroKoH Title Screen Adjustment
		move.w	#$DE,obScreenY(a0)	; position is fixed to screen
		move.l	#Map_TSon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Title_Sonic,1,0),obGfx(a0)
		move.w	#$80,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#29,obDelayAni(a0)	; set time delay to 0.5 seconds
		lea		(Ani_TSon).l,a1
		bsr.w	AnimateSprite

TSon_Delay:	;Routine 2
		subq.b	#1,obDelayAni(a0)	; subtract 1 from time delay
		bpl.s	.wait				; if time remains, branch
		addq.b	#2,obRoutine(a0)	; go to next routine
		bra.w	DisplaySprite

.wait:
		rts	
; ===========================================================================

TSon_Move:	; Routine 4
		subq.w	#8,obScreenY(a0)	; move Sonic up
		cmpi.w	#$96,obScreenY(a0)	; has Sonic reached final position?
		bne.s	.display			; if not, branch
		addq.b	#2,obRoutine(a0)

.display:
		bra.w	DisplaySprite
; ===========================================================================

TSon_Animate:	; Routine 6
		lea		(Ani_TSon).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
