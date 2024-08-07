; ---------------------------------------------------------------------------
; Object 1D - switch that activates when Sonic touches it
; (this	is not used anywhere in	the game)
; ---------------------------------------------------------------------------

swi_origY = objoff_30		; original y-axis position

MagicSwitch:
	; LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		cmpi.b	#2,d0
		beq.s	Swi_Action
		
		tst.b	d0
		bne.w	DeleteObject
	; Object Routine Optimization End

Swi_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Swi,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	obY(a0),swi_origY(a0)		; save position on y-axis
		move.b	#$10,obActWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

Swi_Action:	; Routine 2
		move.w	swi_origY(a0),obY(a0)		; restore position on y-axis
		move.w	#$10,d1
		bsr.w	Swi_ChkTouch				; check if Sonic touches the switch
		beq.s	Swi_ChkDel					; if not, branch

		addq.w	#2,obY(a0)					; move object 2	pixels
		moveq	#1,d0
		move.w	d0,(f_switch).w				; set switch 0 as "pressed"

Swi_ChkDel:
		offscreen.w	DeleteObject			; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	check if Sonic touches the object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swi_ChkTouch:
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	Swi_NoTouch
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	Swi_NoTouch
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1
		move.w	obY(a0),d0
		subi.w	#$10,d0
		sub.w	d1,d0
		bhi.s	Swi_NoTouch
		cmpi.w	#-$10,d0
		blo.s	Swi_NoTouch
		moveq	#-1,d0		; Sonic has touched it
		rts	
; ===========================================================================

Swi_NoTouch:
		moveq	#0,d0		; Sonic hasn't touched it
		rts	
; End of function Swi_ChkTouch
