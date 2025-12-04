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

	if SaveProgressMod
		bra.s	PSB_Menu
	endif

		bra.w	DisplaySprite
; ===========================================================================

PSB_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#$D8,obX(a0)				; RetroKoH Title Screen Adjustment
		move.w	#$130,obScreenY(a0)
		move.l	#Map_PSB,obMap(a0)
		move.w	#make_art_tile(ArtTile_Title_Foreground,0,0),obGfx(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#2,obFrame(a0)				; is object "PRESS START"?
		blo.s	PSB_PrsStart				; if yes, branch

	; Kilo sprite line limiter fix
		clr.w	obGfx(a0)					; Clear out tile ID.
		clr.w	obX(a0)						; Clear X position.
		move.w	#128+152,obScreenY(a0)		; Set Y position.
		move.w	#priority6,obPriority(a0)	; Kilo: Change to #6 -- RetroKoH/Devon S3K+ Priority Manager
	; sprite line limiter fix end

	if SaveProgressMod
		addq.b	#4,obRoutine(a0)			; sprite line limiter and TM routine
	else
		addq.b	#2,obRoutine(a0)			; sprite line limiter and TM routine
	endif

		cmpi.b	#3,obFrame(a0)				; is the object	"TM"?
		bne.w	DisplaySprite				; if not, branch and exit

		move.w	#make_art_tile(ArtTile_Title_Trademark,1,0),obGfx(a0)	; "TM" specific code
		move.w	#$178,obX(a0)				; RetroKoH Title Screen Adjustment
		move.w	#$F8,obScreenY(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		bra.w	DisplaySprite
; ===========================================================================

PSB_PrsStart:	; Routine 2
		lea		Ani_PSBTM(pc),a1
		bsr.w	AnimateSprite				; "PRESS START" is animated
		bra.w	DisplaySprite
; ===========================================================================

	if SaveProgressMod
PSB_Menu:	; Routine 4
		move.b	(v_jpadpressed_actual).w,d0
		andi.b	#btnUp|btnDn,d0
		beq.s	.end
		bchg	#0,obPSB_MenuOption(a0)
		moveq	#0,d2
		move.b	obPSB_MenuOption(a0),d2
		addq.b	#4,d2
		move.b	d2,obFrame(a0)
		move.b	#sfx_Switch,d0				; selection blip sound
		jsr		(QueueSound2).w

	.end:
		bra.w	DisplaySprite
; ===========================================================================
	endif