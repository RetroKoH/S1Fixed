; ---------------------------------------------------------------------------
; Object - Continue screen elements
; ---------------------------------------------------------------------------

ContScrItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		CSI_Index(pc,d0.w)
; ===========================================================================
CSI_Index:
		bra.s	CSI_Main
		bra.s	CSI_Display
		bra.s	CSI_MakeMiniSonic
		bra.w	CSI_ChkDel
; ===========================================================================

CSI_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> CSI_Display
		move.l	#Map_ContScr,obMap(a0)
		move.w	#make_art_tile(ArtTile_Continue_Sonic,0,1),obGfx(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#4,obFrame(a0)
		bne.s	.skip
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

	.skip:
		clr.b	obRender(a0)
		move.b	#$3C,obDispWid(a0)
		move.w	#$120,obX(a0)
		move.w	#$C0,obScreenY(a0)

CSI_Display:	; Routine 2
		jmp		(DisplaySprite).l
; ===========================================================================

CSI_MiniSonicPos:
		dc.w $116, $12A, $102, $13E, $EE, $152, $DA, $166, $C6
		dc.w $17A, $B2,	$18E, $9E, $1A2, $8A
; ===========================================================================

CSI_MakeMiniSonic:	; Routine 4
		movea.l	a0,a1
		lea		CSI_MiniSonicPos(pc),a2
		moveq	#0,d1
		move.b	(v_continues).w,d1
		subq.b	#2,d1
		bcc.s	.more_than_1
		jmp		(DeleteObject).l			; cancel if you have 0-1 continues

	.more_than_1:
		moveq	#1,d3
		cmpi.b	#14,d1						; do you have fewer than 16 continues
		blo.s	.fewer_than_16				; if yes, branch

		moveq	#0,d3
		moveq	#14,d1						; cap at 15 mini-Sonics

	.fewer_than_16:
		move.b	d1,d2
		andi.b	#1,d2
; ---------------------------------------------------------------------------

CSI_MiniSonicLoop:
		_move.l	#ContScrItem,obAddr(a1)		; load mini-Sonic object
		move.w	(a2)+,obX(a1)				; use above data for x-axis position
		tst.b	d2							; do you have an even number of continues?
		beq.s	.is_even					; if yes, branch
		subi.w	#$A,obX(a1)					; shift mini-Sonics slightly to the right

	.is_even:
		move.w	#$D0,obScreenY(a1)
		move.b	#6,obFrame(a1)
		move.b	#6,obRoutine(a1)			; -> CSI_ChkDel
		move.l	#Map_ContScr,obMap(a1)
		move.w	#make_art_tile(ArtTile_Mini_Sonic,0,1),obGfx(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obRender(a1)
		lea		object_size(a1),a1
		dbf		d1,CSI_MiniSonicLoop		; repeat for number of continues

		lea		-object_size(a1),a1
		move.b	d3,obSubtype(a1)
; ---------------------------------------------------------------------------

CSI_ChkDel:		; Routine 6
		tst.b	obSubtype(a0)				; do you have 16 or more continues?
		beq.s	CSI_Animate					; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w	; is Continue Sonic running?
		blo.s	CSI_Animate					; if not, branch
		moveq	#1,d0						; SCE Optimization
		and.b	(v_vbla_byte).w,d0
		bne.s	CSI_Animate
		tst.w	(v_player+obVelX).w			; is Sonic running?
		bne.s	CSI_Delete					; if yes, goto delete
		rts	
; ===========================================================================

CSI_Animate:
		moveq	#$F,d0						; SCE Optimization
		and.b	(v_vbla_byte).w,d0
		bne.s	.no_frame_chg
		bchg	#0,obFrame(a0)				; animate every 16 frames

	.no_frame_chg:
		jmp		(DisplaySprite).l
; ===========================================================================

CSI_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

; ---------------------------------------------------------------------------
; Object - Sonic on the continue screen
; ---------------------------------------------------------------------------

ContSonic:
		_move.l	#CSon_ChkLand,obAddr(a0)
		move.w	#$A0,obX(a0)
		move.w	#$C0,obY(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#aniID_Float3,obAnim(a0)	; use "floating" animation
		move.w	#$400,obVelY(a0)			; make Sonic fall from above
; ---------------------------------------------------------------------------

CSon_ChkLand:
		cmpi.w	#$1A0,obY(a0)				; has Sonic landed yet?
		bne.s	.keep_falling				; if not, branch

		_move.l	#CSon_Animate,obAddr(a0)
		clr.w	obVelY(a0)					; stop Sonic falling
		move.l	#Map_ContScr,obMap(a0)
		move.w	#make_art_tile(ArtTile_Continue_Sonic,0,1),obGfx(a0)
		clr.b	obAnim(a0)
		bra.s	CSon_Animate
; ===========================================================================

	.keep_falling:
		jsr		(SpeedToPos_YOnly).l
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		jmp		(DisplaySprite).l
; ===========================================================================

CSon_Animate:
		tst.b	(v_jpadpressed_actual).w	; is Start button pressed?
		bmi.s	.start_pressed				; if yes, branch
		lea		AniScript_CSon(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l

	.start_pressed:
		_move.l	#CSon_Run,obAddr(a0)
		move.l	#Map_Sonic,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#aniID_Float4,obAnim(a0)	; use "getting up" animation
		clr.w	obInertia(a0)
		subq.w	#8,obY(a0)
		move.b	#bgm_Fade,d0
		bsr.w	QueueSound2					; fade out music
; ---------------------------------------------------------------------------

CSon_Run:
		cmpi.w	#$800,obInertia(a0)			; check Sonic's inertia
		bne.s	.add_inertia				; if too low, branch
		move.w	#$1000,obVelX(a0)			; move Sonic to the right
		bra.s	.show_run
; ===========================================================================

	.add_inertia:
		addi.w	#$20,obInertia(a0)			; increase inertia

	.show_run:
		jsr		(SpeedToPos_XOnly).l
		jsr		(Sonic_Animate).l
		jsr		(Sonic_LoadGfx).l
		jmp		(DisplaySprite).l
; ===========================================================================