; ---------------------------------------------------------------------------
; Object 1D - switch that activates when Sonic touches it
; (this	is not used anywhere in	the game)
; ---------------------------------------------------------------------------

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
		move.w	obY(a0),obSwi_StartY(a0)	; save position on y-axis
		move.b	#$10,obDispWid(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

Swi_Action:	; Routine 2
		move.w	obSwi_StartY(a0),obY(a0)	; restore position on y-axis
		moveq	#$10,d1						; width
		bsr.w	Swi_ChkTouch				; check if Sonic touches the switch
		beq.s	.display					; if not, branch

		addq.w	#2,obY(a0)					; move object down 2 pixels
		moveq	#1,d0
		move.w	d0,(f_switch).w				; set switch 0 as "pressed"

	.display:
		offscreen.w	DeleteObject			; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix	
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	check if Sonic touches the object
;
; input:
;	d1 = width of object
;
; output:
;	d0 = collision flag: 0 = none; -1 = touched
; ---------------------------------------------------------------------------

Swi_ChkTouch:
		lea	(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	.not_touched	; branch if Sonic is to the left
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	.not_touched
		move.w	obY(a1),d2
		move.b	obHeight(a1),d1
		ext.w	d1
		add.w	d2,d1			; take Sonic's height into account
		move.w	obY(a0),d0
		subi.w	#$10,d0
		sub.w	d1,d0
		bhi.s	.not_touched	; branch if Sonic is above it
		cmpi.w	#-$10,d0
		blo.s	.not_touched	; branch if Sonic is below it
		moveq	#-1,d0			; Sonic has touched it
		rts	
; ===========================================================================

.not_touched:
		moveq	#0,d0			; Sonic hasn't touched it
		rts	
; End of function Swi_ChkTouch
; ===========================================================================