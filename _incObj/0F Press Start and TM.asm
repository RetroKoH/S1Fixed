; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------

PSBTM:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		PSB_Index(pc,d0.w)
; ===========================================================================
PSB_Index:
		bra.s	PSB_Main
		bra.s	PSB_PrsStart
		bra.w	DisplaySprite
; ===========================================================================

PSB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$D8,obX(a0)		; RetroKoH Title Screen Adjustment
		move.w	#$130,obScreenY(a0)
		move.l	#Map_PSB,obMap(a0)
		move.w	#make_art_tile(ArtTile_Title_Foreground,0,0),obGfx(a0)
		cmpi.b	#2,obFrame(a0)		; is object "PRESS START"?
		blo.s	PSB_PrsStart		; if yes, branch

		addq.b	#2,obRoutine(a0)
		cmpi.b	#3,obFrame(a0)		; is the object	"TM"?
		bne.w	DisplaySprite		; if not, branch and exit

		move.w	#make_art_tile(ArtTile_Title_Trademark,1,0),obGfx(a0)	; "TM" specific code
		move.w	#$178,obX(a0)		; RetroKoH Title Screen Adjustment
		move.w	#$F8,obScreenY(a0)
		bra.w	DisplaySprite
; ===========================================================================

PSB_PrsStart:	; Routine 2
		lea		(Ani_PSBTM).l,a1
		bsr.w	AnimateSprite		; "PRESS START" is animated
		bra.w	DisplaySprite
; ===========================================================================
