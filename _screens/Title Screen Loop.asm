; ---------------------------------------------------------------------------
; Title Screen Main Loop
; ---------------------------------------------------------------------------

	if ~~SaveProgressMod

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l

	; Kilo sprite line limiter fix
		lea		($FFFFF804).w,a1			; fetch sprite table, starting from tile IDs
		moveq	#0,d0						; this will be our X position
		moveq	#80-1,d6					; iterate through the whole sprite table

	.maskLoop:
		tst.w	(a1)						; does this sprite have tile ID $0000? (Indicates either a mask or nothing)
		bne.s	.nextMask					; if not, then this is a normal sprite do not modify it's X position
		bchg	#0,d0						; change X position to 1 or 0 masks need a non X=0 higher priority sprite to mask
		move.w	d0,2(a1)					; write to X position

	.nextMask:
		addq.w	#8,a1						; go to next sprite
		dbf		d6,.maskLoop				; loop
	; sprite line limiter fix end

		bsr.w	PalCycle_Title
		bsr.w	RunPLC
		move.w	(v_player+obX).w,d0
		if	~~MoveInteractTitle
		move.b	(v_jpadhold1).w,d1    ; Lê os botões pressionados

		btst	#4,d1                ; Botão B pressionado? (bit 4)
		bne.s	.applyMove           ; Se sim, pula o movimento (para o Sonic)

		btst	#3,d1                ; Direita segurada? (bit 3)
		bne.s	.fastRight           ; Se sim, vai para +4
		addq.w	#2,d0                ; Padrão: +2
		bra.s	.checkLeft
.fastRight:
		addq.w	#4,d0                ; Rápido: +4

.checkLeft:
		btst	#2,d1                ; Esquerda segurada? (bit 2)
		beq.s	.applyMove           ; Se não, segue em frente
		subq.w	#4,d0                ; Se sim, subtrai 4 (move para trás)

.applyMove:
		move.w	d0,(v_objspace+obX).w ; Salva a nova posição
		cmpi.w	#$1C00,d0            ; Checa o limite de X
		blo.s	Tit_ChkRegion        ; Se menor que $1C00, continua
.saveX:
		else
		addq.w	#2,d0
		endif
		move.w	d0,(v_player+obX).w			; move Sonic to the right
		cmpi.w	#$1C00,d0					; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_EnterCheat				; if not, branch

		move.b	#id_Sega,(v_gamemode).w		; go to Sega screen
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select code
; ---------------------------------------------------------------------------
LevSelCode:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even
; ===========================================================================

Tit_EnterCheat:
		lea		LevSelCode(pc),a0			; load level select code
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpressed_actual).w,d0			; get button press
		andi.b	#btnDir,d0					; read only UDLR buttons
		cmp.b	(a0),d0						; does button press match the cheat code?
		bne.s	Tit_ResetCheat				; if not, branch
		addq.w	#1,(v_title_dcount).w		; next button press
		tst.b	d0
		bne.s	Tit_CountC
		lea		(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Tit_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Tit_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)				; cheat depends on how many times C is pressed

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat
		move.b	#sfx_Ring,d0
		bsr.w	QueueSound2			; play ring sound when code is entered
		bra.s	Tit_CountC
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0
		beq.s	Tit_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Tit_CountC
		clr.w	(v_title_dcount).w			; reset UDLR counter

Tit_CountC:
		move.b	(v_jpadpressed_actual).w,d0
		andi.b	#btnC,d0					; is C button pressed?
		beq.s	Tit_CheckStartDemo			; if not, branch
		addq.w	#1,(v_title_ccount).w		; increment C counter

Tit_CheckStartDemo:
		tst.w	(v_countdown).w
		beq.w	GotoDemo
		andi.b	#btnStart,(v_jpadpressed_actual).w	; check if Start is pressed
		beq.w	Tit_MainLoop				; if not, branch

Tit_ChkLevSel:
		tst.b	(f_levselcheat).w			; check if level select code is on
		beq.w	PlayLevel					; if not, play level
		btst	#bitA,(v_jpadheld_actual).w		; check if A is pressed
		beq.w	PlayLevel					; if not, play level

	if NewLevelSelect
		move.b	#id_MenuScreen,(v_gamemode).w
		jmp		MainGameLoop
	else
	; fallthrough to Tit_LevSel
	endif

	else	; if SaveProgressMod

Tit_MainLoop:
		move.b	#4,(v_vbla_routine).w
		bsr.w	WaitForVBla
		jsr		(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr		(BuildSprites).l

	; Kilo sprite line limiter fix
		lea		($FFFFF804).w,a1			; fetch sprite table, starting from tile IDs
		moveq	#0,d0						; this will be our X position
		moveq	#80-1,d6					; iterate through the whole sprite table

	.maskLoop:
		tst.w	(a1)						; does this sprite have tile ID $0000? (Indicates either a mask or nothing)
		bne.s	.nextMask					; if not, then this is a normal sprite do not modify it's X position
		bchg	#0,d0						; change X position to 1 or 0 masks need a non X=0 higher priority sprite to mask
		move.w	d0,2(a1)					; write to X position

	.nextMask:
		addq.w	#8,a1						; go to next sprite
		dbf		d6,.maskLoop				; loop
	; sprite line limiter fix end

		bsr.w	PalCycle_Title
		bsr.w	RunPLC
		move.w	(v_player+obX).w,d0
		addq.w	#2,d0
		move.w	d0,(v_player+obX).w			; move Sonic to the right

		; is menu triggered (d1 = obAddr)?
		cmp_addr	#PSB_Menu,(v_pressstart+obAddr).w,d1
		beq.w	Tit_NoDemo					; if yes, branch

		cmpi.w	#$1C00,d0					; has Sonic object passed $1C00 on x-axis?
		blo.s	Tit_EnterCheat				; if not, branch

		move.b	#id_Sega,(v_gamemode).w		; go to Sega screen
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select code
; ---------------------------------------------------------------------------
LevSelCode:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even
; ===========================================================================

Tit_EnterCheat:
		lea		LevSelCode(pc),a0			; load level select code
		move.w	(v_title_dcount).w,d0
		adda.w	d0,a0
		move.b	(v_jpadpressed_actual).w,d0			; get button press
		andi.b	#btnDir,d0					; read only UDLR buttons
		cmp.b	(a0),d0						; does button press match the cheat code?
		bne.s	Tit_ResetCheat				; if not, branch
		addq.w	#1,(v_title_dcount).w		; next button press
		tst.b	d0
		bne.s	Tit_CountC
		lea		(f_levselcheat).w,a0
		move.w	(v_title_ccount).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Tit_PlayRing
		tst.b	(v_megadrive).w
		bpl.s	Tit_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)				; cheat depends on how many times C is pressed

Tit_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat
		move.b	#sfx_Ring,d0
		bsr.w	QueueSound2			; play ring sound when code is entered
		bra.s	Tit_CountC
; ===========================================================================

Tit_ResetCheat:
		tst.b	d0
		beq.s	Tit_CountC
		cmpi.w	#9,(v_title_dcount).w
		beq.s	Tit_CountC
		clr.w	(v_title_dcount).w				; reset UDLR counter

Tit_CountC:
		move.b	(v_jpadpressed_actual).w,d0
		andi.b	#btnC,d0						; is C button pressed?
		beq.s	Tit_CheckStartDemo				; if not, branch
		addq.w	#1,(v_title_ccount).w			; increment C counter

Tit_CheckStartDemo:
		tst.w	(v_countdown).w
		beq.w	GotoDemo

Tit_NoDemo:
		andi.b	#btnStart,(v_jpadpressed_actual).w		; check if Start is pressed
		beq.w	Tit_MainLoop					; if not, branch

Tit_ChkLevSel:
		; is menu triggered (d0 = obAddr)?
		cmp_addr	#PSB_Menu,(v_pressstart+obAddr).w,d0
		beq.s	Tit_MenuChoice					; if yes, Level Select can't be activated
		tst.b	(f_levselcheat).w				; otherwise, check if level select code is on

	if ~~NewLevelSelect
		bne.w	Tit_LevSel						; if yes, activate level select
	else
		beq.s	Tit_NoLevSel
		move.b	#id_MenuScreen,(v_gamemode).w
		jmp		MainGameLoop					; transition to new level select

Tit_NoLevSel:
	endif

		_move.l	#PSB_Menu,(v_pressstart+obAddr).w	; activate NEW/CONTINUE menu
		move.b	#4,(v_pressstart+obFrame).w
		move.b	#sfx_Lamppost,d0
		bsr.w	QueueSound2						; play sfx
		bra.w	Tit_MainLoop

Tit_MenuChoice:
		moveq	#0,d0
		move.b	(v_pressstart+obPSB_MenuOption).w,d0
		bne.w	PlayLevel_Load					; load previous game
		bra.w	PlayLevel						; start new game

	endif
