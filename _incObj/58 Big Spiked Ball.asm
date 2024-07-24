; ---------------------------------------------------------------------------
; Object 58 - giant spiked balls (SYZ)
; ---------------------------------------------------------------------------

bball_angle = objoff_36		; precise rotation angle (2 bytes)
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.

bball_origY = objoff_38		; original y-axis position
bball_origX = objoff_3A		; original x-axis position
bball_radius = objoff_3C	; radius of circle
bball_speed = objoff_3E		; speed

BigSpikeBall:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	BBall_Move
	; Object Routine Optimization End

BBall_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_BBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_SYZ_Big_Spikeball,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$18,obActWid(a0)
		move.w	obX(a0),bball_origX(a0)
		move.w	obY(a0),bball_origY(a0)
		move.b	#$86,obColType(a0)
		move.b	obSubtype(a0),d1 ; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1		; multiply by 8
		move.w	d1,bball_speed(a0) ; set object speed
		move.b	obStatus(a0),d0
		ror.b	#2,d0
		andi.b	#$C0,d0
		move.b	d0,obAngle(a0)			; set initial angle
		move.b	d0,bball_angle(a0)		; set initial precise angle
		move.b	#$50,bball_radius(a0)	; set radius of circle motion

BBall_Move:	; Routine 2
		moveq	#0,d0
		move.b	obSubtype(a0),d0 ; get object type
		andi.w	#7,d0		; read only the	2nd digit
		add.w	d0,d0
		move.w	.index(pc,d0.w),d1
		jsr		.index(pc,d1.w)
		offscreen.w	DeleteObject,bball_origX(a0)	; PFM S3K Obj
		bra.w	DisplayAndCollision		; S3K TouchResponse
; ===========================================================================
.index:
		dc.w .type00-.index
		dc.w .type01-.index
		dc.w .type02-.index
		dc.w .type03-.index
; ===========================================================================

.type01:
		move.w	#$60,d1
		moveq	#0,d0
		move.b	(v_oscillate+$E).w,d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip1
		neg.w	d0
		add.w	d1,d0

.noflip1:
		move.w	bball_origX(a0),d1
		sub.w	d0,d1
		move.w	d1,obX(a0)	; move object horizontally

.type00:
		rts
; ===========================================================================

.type02:
		move.w	#$60,d1
		moveq	#0,d0
		move.b	(v_oscillate+$E).w,d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip2
		neg.w	d0
		addi.w	#$80,d0

.noflip2:
		move.w	bball_origY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)	; move object vertically
		rts	
; ===========================================================================

.type03:
		move.w	bball_speed(a0),d0
		add.w	d0,bball_angle(a0)
		move.b	bball_angle(a0),obAngle(a0)	; To prevent insta-shield bug.
		move.b	obAngle(a0),d0
		jsr		(CalcSine).w
		move.w	bball_origY(a0),d2
		move.w	bball_origX(a0),d3
		moveq	#0,d4
		move.b	bball_radius(a0),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a0)	; move object circularly
		move.w	d5,obX(a0)
		rts	
