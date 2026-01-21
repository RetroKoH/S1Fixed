; ---------------------------------------------------------------------------
; Object - Test object that tests out sub sprites
; ---------------------------------------------------------------------------
; OST Constants
obTest_ChildObj:		equ objoff_3E		; 2 bytes | address of the child object with the subsprites
; ---------------------------------------------------------------------------

Obj10_Sub:
		move.w	#priority4,d0				; RetroKoH/Devon S3K+ Priority Manager
		jmp		DisplaySprite2				; Display sprites
; ===========================================================================

Obj10:
		_move.l	#OT_Display,obAddr(a0)		; Set as initialized
		jsr		(FindFreeObj).l				; Find a free object slot
		bne.s	OT_NoSubSprs

		move.w	a1,obTest_ChildObj(a0)		; Set as child object
		_move.l	#Obj10_Sub,obAddr(a1)		; Load subsprite object
		move.b	#%01000100,obRender(a1)		; Set to render sub sprites -- %01000100 : Setting bit 6 enables subsprites for this object.
		move.w	#ArtTile_Sonic,obGfx(a1)	; Base tile ID
		move.l	#Map_Sonic,obMap(a1)		; Mappings
		move.w	#$3030,mainspr_height(a1)	; Set main sprite height/width
		move.b	#4,mainspr_childsprites(a1)	; Set number of child sprites
		move.w	obX(a0),obX(a1)				; Set position
		move.w	obY(a0),obY(a1)

OT_Display:
		movea.w	obTest_ChildObj(a0),a1		; Get child object

		move.b	(v_player+obFrame).w,d6		; Get frame to use
		move.b	d6,mainspr_mapframe(a1)		; Set main sprite frame

		moveq	#0,d5
		move.b	mainspr_childsprites(a1),d5	; Get number of sub sprites
		subq.b	#1,d5
		bmi.s	OT_NoSubSprs				; If there are none, branch
		lea		subspr_posdata(a1),a2		; Get sub-sprite position data
		lea		subspr_frames(a1),a3		; Get sub-sprite frame data

OT_SetSubSprs:
		move.b	obAngle(a0),d0				; Get sine and cosine of the current angle
		jsr		(CalcSine).w
		asr.w	#3,d0						; Get Y position
		add.w	obY(a0),d0
		asr.w	#3,d1						; Get X position
		add.w	obX(a0),d1
		move.w	d1,(a2)+					; Set X position
		move.w	d0,(a2)+					; Set Y position
		move.b	d6,(a3)+					; Set map frame
		addi.b	#$40,obAngle(a0)			; Next angle to use
		dbf		d5,OT_SetSubSprs			; Loop until every sub sprite is set

OT_NoSubSprs:
		addq.b	#1,obAngle(a0)				; Increment angle
		rts
; ===========================================================================