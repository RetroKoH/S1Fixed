; ---------------------------------------------------------------------------
; Object 10 - Test object that tests out sub sprites
; ---------------------------------------------------------------------------

Obj10:
		btst	#6,obRender(a0)				; Is this object set to render sub sprites?
		beq.s	.normal						; If not, branch

		move.w	#priority4,d0				; RetroKoH/Devon S3K+ Priority Manager
		jmp		DisplaySprite2				; Display sprites
; ===========================================================================

	.normal:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	OT_Display
	; Object Routine Optimization End

OT_Main:
		addq.b	#2,obRoutine(a0)			; Set as initialized
		jsr		(FindFreeObj).l				; Find a free object slot
		bne.s	OT_Main

		move.w	a1,obTest_ChildObj(a0)		; Set as child object
		_move.l	obAddr(a0),obAddr(a1)		; Load test object
		move.b	#%01000100,obRender(a1)		; Set to render sub sprites -- %01000100 : Setting bit 6 enables subsprites for this object.
		move.w	#ArtTile_Sonic,obGfx(a1)	; Base tile ID
		move.l	#Map_Sonic,obMap(a1)		; Mappings
		move.b	#$30,mainspr_width(a1)		; Set main sprite width
		move.b	#$30,mainspr_height(a1)		; Set main sprite height
		move.b	#4,mainspr_childsprites(a1)	; Set number of child sprites
		move.w	obX(a0),obX(a1)				; Set position
		move.w	obY(a0),obY(a1)

OT_Display:
		movea.w	obTest_ChildObj(a0),a1		; Get child object

		moveq	#0,d6
		move.b	(v_player+obFrame).w,d6		; Get frame to use
		move.b	d6,mainspr_mapframe(a1)		; Set main sprite frame

		moveq	#0,d5
		move.b	mainspr_childsprites(a1),d5	; Get number of sub sprites
		subq.b	#1,d5
		bmi.s	OT_NoSubSprs				; If there are none, branch
		lea		sub2_x_pos(a1),a2			; Get sub sprite data

OT_SetSubSprs:
		move.b	obAngle(a0),d0				; Get sine and cosine of the current angle
		jsr		(CalcSine).w
		asr.w	#3,d0						; Get Y position
		add.w	obY(a0),d0
		asr.w	#3,d1						; Get X position
		add.w	obX(a0),d1
		move.w	d1,(a2)+					; Set X position
		move.w	d0,(a2)+					; Set Y position
		move.w	d6,(a2)+					; Set map frame
		addi.b	#$40,obAngle(a0)			; Next angle to use
		dbf		d5,OT_SetSubSprs			; Loop until every sub sprite is set

OT_NoSubSprs:
		addq.b	#1,obAngle(a0)				; Increment angle
		rts
; ===========================================================================