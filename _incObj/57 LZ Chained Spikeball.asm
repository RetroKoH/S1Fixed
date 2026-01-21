; ---------------------------------------------------------------------------
; Object 57 - chained spiked balls (LZ)
; I split the SYZ Spikebar from this, because this will use subsprites - KoH
; ---------------------------------------------------------------------------
; OST Constants
obSBall_Chain:			equ objoff_30		; 2 bytes | object RAM address of the chain

obSBall_Angle:			equ objoff_36		; 2 bytes | precise rotation angle
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.

obSBall_CenterX:		equ objoff_38		; 2 bytes | center X-axis position
obSBall_CenterY:		equ objoff_3A		; 2 bytes | center Y-axis position
obSBall_Speed:			equ objoff_3E		; 2 bytes | rate of spin
; ---------------------------------------------------------------------------

SBall_Sub:
		move.w	#priority5,d0	; decreased from 4
		bra.w	DisplaySprite2
; ===========================================================================

SpikeBall:
	; init
		_move.l	#SBall_Move,obAddr(a0)
		move.l	#Map_SBall2,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Spikeball_Chain,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$30,obDispWid(a0)
		move.b	#(colHarmful|colSz_8x8),obColType(a0)	; spikeball hitbox
		move.w	obX(a0),obSBall_CenterX(a0)
		move.w	obY(a0),obSBall_CenterY(a0)

	; subtype handling
		moveq	#signextendB($F0),d1					; read only the	high nybble of subtype
		and.b	obSubtype(a0),d1						; SCE Optimization
		ext.w	d1
		asl.w	#3,d1									; multiply by 8
		move.w	d1,obSBall_Speed(a0)					; set object twirl speed
		move.b	obStatus(a0),d0
		ror.b	#2,d0									; move bits 0-1 into bits 6-7
		andi.b	#$C0,d0									; read only x/y flip bits
		move.b	d0,obAngle(a0)							; set initial angle
		move.b	d0,obSBall_Angle(a0)					; set initial precise angle

	; create chain (subsprites)
		bsr.w	FindFreeObj
		bne.w	SBall_Move

		_move.l	#SBall_Sub,obAddr(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#renMultiDraw,obRender(a1)				; set multi-draw flag
		bset	#renUseHeight,obRender(a1)
		move.w	a1,obSBall_Chain(a0)					; save chain address
		move.w	obX(a0),d2
		move.w	d2,obX(a1)
		move.w	obY(a0),d3
		move.w	d3,obY(a1)
		moveq	#$F,d1									; read only the	low nybble of subtype
		and.b	obSubtype(a0),d1						; SCE Optimization
		move.w	d1,d0
		lsl.w	#4,d0									; multiply by $10
		move.b	d0,mainspr_width(a1)					; set width
		move.b	d0,mainspr_height(a1)					; set height
		subq.w	#1,d1
		bcs.w	SBall_Delete
		move.b	d1,mainspr_childsprites(a1)

		lea		subspr_posdata(a1),a2
		lea		subspr_frames(a1),a3

	.loop:
		move.w	d2,(a2)+
		move.w	d3,(a2)+
        move.b	#1,(a3)+                        		; sub?_mapframe
		dbf		d1,.loop
		move.b	#2,mainspr_mapframe(a1)					; set frame for anchor
; ---------------------------------------------------------------------------

SBall_Move:
	; branches removed. We just call the code directly.
		move.w	obSBall_Speed(a0),d0					; get rotation speed
		add.w	d0,obSBall_Angle(a0)					; add speed to precise angle
		move.b	obSBall_Angle(a0),obAngle(a0)			; load high byte here (to prevent insta-shield bug).
		move.b	obAngle(a0),d0							; get updated angle

	; convert to sine/cosine
		calcsine_direct

		move.w	obSBall_CenterY(a0),d2					; get position of chain base
		move.w	obSBall_CenterX(a0),d3
		movea.w	obSBall_Chain(a0),a1					; load chain address into a1
		moveq	#0,d6
		move.b	mainspr_childsprites(a1),d6				; get number of chain links
		subq.w	#1,d6
		blo.s	.display
		swap	d0
		clr.w	d0
		swap	d1
		clr.w	d1
		asr.l	#4,d0
		asr.l	#4,d1
		move.l	d0,d4
		move.l	d1,d5
		lea		subspr_posdata(a1),a2

	.loop:
		movem.l	d4-d5,-(sp)
		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d5,(a2)+								; x_pos
		move.w	d4,(a2)+								; y_pos
		movem.l	(sp)+,d4-d5
		add.l	d0,d4
		add.l	d1,d5
		dbf		d6,.loop								; repeat for all subsprites

	; sonic 1 fix pos
		asr.l	d0
		asr.l	d1
		sub.l	d0,d4
		sub.l	d1,d5

	; TO-DO: Positioning is half a chainlink inaccurate
		swap	d4
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d5,obX(a0)								; update position
		move.w	d4,obY(a0)

	.display:
        move.w	obSBall_CenterX(a0),d0					; get object position
        andi.w	#$FF80,d0								; round down to nearest $80
        move.w	(v_screenposx).w,d1						; get screen position
        subi.w	#$80,d1
        andi.w	#$FF80,d1
        sub.w	d1,d0									; approx distance between object and screen
        cmpi.w	#$280,d0
        bhi.w	SBall_OffScreen

		; draw
		bra.s	SBall_Display							; Display (+ Collision)
; ===========================================================================

SBall_OffScreen:
		move.w	obRespawnAddr(a0),d0					; get address in respawn table
		beq.s	SBall_Delete							; if it's zero, it isn't remembered
		movea.w	d0,a2									; load address into a2
		bclr	#7,(a2)									; turn on the slot

SBall_Delete:
		movea.w	obSBall_Chain(a0),a1					; load chain address into a1
		bsr.w	DeleteChild
		jmp		(DeleteObject).l
; ===========================================================================

SBall_Display:	; + S3K TouchResponse
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)								; Is list full?
		bhs.w	DisplaySprite							; If so, return
		addq.w	#2,(a1)									; Count this new entry
		adda.w	(a1),a1									; Offset into right area of list
		move.w	a0,(a1)									; Store RAM address in list
		bra.w	DisplaySprite
; ===========================================================================