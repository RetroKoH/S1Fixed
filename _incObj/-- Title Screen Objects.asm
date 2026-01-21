; ---------------------------------------------------------------------------
; Dynamic Object - Sonic on the title screen
; ---------------------------------------------------------------------------
; OST constants
obTitlSon_DelayTime:	equ objoff_30		; 1 byte  | delay timer (replacing obDelayAni)
obTitlSon_PrevFrame:	equ objoff_3F		; 1 byte  | stored frame for DPLC handling
; ----------------------------------------------------------------------------

TitleSonic:
		_move.l	#TSon_Delay,obAddr(a0)
		move.w	#$F8,obX(a0)					; RetroKoH Title Screen Adjustment
		move.w	#$DE,obScreenY(a0)				; position is fixed to screen
		move.l	#Map_TSon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Title_Sonic,1,0),obGfx(a0)
		move.w	#priority7,obPriority(a0)		; Kilo: Change to #7 -- RetroKoH/Devon S3K+ Priority Manager
		move.b	#29,obTitlSon_DelayTime(a0)		; set time delay to 0.5 seconds
		move.b	#$FF,obTitlSon_PrevFrame(a0)	; Added for DPLC frame check
		lea		Ani_TSon(pc),a1
		bsr.w	AnimateSprite
; ---------------------------------------------------------------------------

TSon_Delay:
		bsr.s	TSon_LoadGfx
		subq.b	#1,obTitlSon_DelayTime(a0)		; subtract 1 from time delay
		bpl.s	.wait							; if time remains, branch
		_move.l	#TSon_Move,obAddr(a0)
		bra.w	DisplaySprite

	.wait:
		rts	
; ===========================================================================

TSon_Move:	; Routine 4
		bsr.s	TSon_LoadGfx
		subq.w	#8,obScreenY(a0)				; move Sonic up
		cmpi.w	#$96,obScreenY(a0)				; has Sonic reached final position?
		bne.w	DisplaySprite					; if not, branch
		_move.l	#TSon_Animate,obAddr(a0)
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
		move.b	obFrame(a0),d0					; load frame number
		cmp.b	obTitlSon_PrevFrame(a0),d0		; has frame changed?
		beq.s	.nochange						; if not, branch and exit

		move.b	d0,obTitlSon_PrevFrame(a0)		; update frame number for next check
		lea		TSonDynPLC(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5						; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange						; if zero, branch
		move.w	#(ArtTile_Title_Sonic*tile_size),d4

	.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1						; S3K .b to .w
		move.w	d1,d3							; S3K
		lsr.w	#8,d3							; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_TitleSonic,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry					; repeat for number of entries

	.nochange:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Dynamic Object - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------
; OST constants
obPSB_MenuOption:		equ objoff_30		; 1 byte  | option chosen in the menu (For SaveProgressMod)
; ----------------------------------------------------------------------------

PSBTM:
		_move.l	#PSB_PrsStart,obAddr(a0)
		move.w	#$D8,obX(a0)				; RetroKoH Title Screen Adjustment
		move.w	#$130,obScreenY(a0)
		move.l	#Map_PSB,obMap(a0)
		move.w	#make_art_tile(ArtTile_Title_Foreground,0,0),obGfx(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#2,obFrame(a0)				; is object "PRESS START"?
		blo.s	PSB_PrsStart				; if yes, branch
; ---------------------------------------------------------------------------

	; Kilo sprite line limiter fix
		clr.w	obGfx(a0)					; Clear out tile ID.
		clr.w	obX(a0)						; Clear X position.
		move.w	#128+152,obScreenY(a0)		; Set Y position.
		move.w	#priority6,obPriority(a0)	; Kilo: Change to #6 -- RetroKoH/Devon S3K+ Priority Manager
	; sprite line limiter fix end

		_move.l	#DisplaySprite,obAddr(a0)	; sprite line limiter and TM routine

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