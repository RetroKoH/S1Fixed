; ---------------------------------------------------------------------------
; Object 58 - giant spiked balls (SYZ)
; ---------------------------------------------------------------------------

BigSpikeBall:
		move.l	#Map_BBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_SYZ_Big_Spikeball,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obDispWid(a0)
		move.w	obX(a0),obBBall_StartX(a0)
		move.w	obY(a0),obBBall_StartY(a0)
		move.b	#(colHarmful|colSz_16x16),obColType(a0)
		move.b	obSubtype(a0),d1			; get object type
		andi.b	#$F0,d1						; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1						; multiply by 8
		move.w	d1,obBBall_Speed(a0)		; set object speed
		move.b	obStatus(a0),d0
		ror.b	#2,d0
		andi.b	#$C0,d0
		move.b	d0,obAngle(a0)				; set initial angle
		move.b	d0,obBBall_Angle(a0)		; set initial precise angle
		move.b	#$50,obBBall_Radius(a0)		; set radius of circle motion

		moveq	#7,d0
		and.b	obSubtype(a0),d0			; read low nybble of subtype (SCE Optimization)
		add.w	d0,d0
		lea		(BBall_Index).l,a1
		movea.l	(a1,d0.w),a1
		move.l	a1,obAddr(a0)				; load address of movement code for future use
		jmp		(a1)						; run movement code for the first time
; ===========================================================================

BBall_Index:
		dc.l	BBall_Still					; 0
		dc.l	BBall_Sideways				; 2
		dc.l	BBall_UpDown				; 4
		dc.l	BBall_Circle				; 6
; ===========================================================================

BBall_Sideways:
		moveq	#$60,d1
		moveq	#0,d0
		move.b	(v_oscillate+$E).w,d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip
		neg.w	d0							; invert if xflipped
		add.w	d1,d0

	.noflip:
		move.w	obBBall_StartX(a0),d1		; get initial x pos
		sub.w	d0,d1						; subtract difference
		move.w	d1,obX(a0)					; move object horizontally

BBall_Still:
		offscreen.w	DeleteObject,obBBall_StartX(a0)	; PFM S3K Obj
		bra.w	DisplayAndCollision			; S3K TouchResponse
; ===========================================================================

BBall_UpDown:
		moveq	#$60,d1
		moveq	#0,d0
		move.b	(v_oscillate+$E).w,d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip2
		neg.w	d0							; invert if xflipped
		addi.w	#$80,d0

	.noflip2:
		move.w	obBBall_StartY(a0),d1		; get initial y pos
		sub.w	d0,d1						; subtract difference
		move.w	d1,obY(a0)					; move object vertically
		offscreen.w	DeleteObject,obBBall_StartX(a0)	; PFM S3K Obj
		bra.w	DisplayAndCollision			; S3K TouchResponse	
; ===========================================================================

BBall_Circle:
		move.w	obBBall_Speed(a0),d0			; get rotation speed
		add.w	d0,obBBall_Angle(a0)			; add speed to angle
		move.b	obBBall_Angle(a0),obAngle(a0)	; load high byte here (to prevent insta-shield bug).
		move.b	obAngle(a0),d0					; get updated angle

		calcsine_direct

		move.w	obBBall_StartY(a0),d2			; get starting position
		move.w	obBBall_StartX(a0),d3
		moveq	#0,d4
		move.b	obBBall_Radius(a0),d4			; get radius
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a0)						; update position
		move.w	d5,obX(a0)
		offscreen.w	DeleteObject,obBBall_StartX(a0)	; PFM S3K Obj
		bra.w	DisplayAndCollision			; S3K TouchResponse
; ===========================================================================