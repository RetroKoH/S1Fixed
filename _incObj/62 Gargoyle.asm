; ---------------------------------------------------------------------------
; Object 62 - gargoyle head (LZ)
; ---------------------------------------------------------------------------

; ===========================================================================

Gar_SpitRate:
		dc.b 30						; 0 - 0.5 seconds (unused)
		dc.b 60						; 1 - 1 second
		dc.b 90						; 2 - 1.5 seconds
		dc.b 120					; 3 - 2 seconds
		dc.b 150					; 4 - 2.5 seconds
		dc.b 180					; 5 - 3 seconds (unused)
		dc.b 210					; 6 - 3.5 seconds (unused)
		dc.b 240					; 7 - 4 seconds (unused)
		even
; ===========================================================================

Gargoyle:
		_move.l	#Gar_MakeFire,obAddr(a0)
		move.l	#Map_Gar,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Gargoyle,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
		moveq	#$F,d0									; SCE Optimization
		and.b	obSubtype(a0),d0						; get object subtype's low nybble
		move.b	Gar_SpitRate(pc,d0.w),obGar_SpawnTime(a0)	; set fireball spit rate
		move.b	obGar_SpawnTime(a0),obTimeFrame(a0)
; ---------------------------------------------------------------------------

Gar_MakeFire:
		subq.b	#1,obTimeFrame(a0)						; decrement timer
		bne.w	RememberState							; if time remains, branch

		move.b	obGar_SpawnTime(a0),obTimeFrame(a0)		; reset timer
		bsr.w	ChkObjectVisible
		bne.w	RememberState							; branch if off screen
		bsr.w	FindFreeObj								; find free object slot
		bne.w	RememberState							; branch if not found

		_move.l	#Gar_FireBall,obAddr(a1)				; load fireball object
		move.l	#Map_Gar,obMap(a1)
		move.w	#make_art_tile(ArtTile_LZ_Gargoyle,0,0),obGfx(a1)
		ori.b	#4,obRender(a1)
		move.w	#priority4,obPriority(a1)				; RetroKoH/Devon S3K+ Priority Manager
		move.w	#$808,obHeight(a1)						; Height and Width
		move.b	#8,obDispWid(a1)
		move.b	#2,obFrame(a1)

		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addq.w	#8,obY(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obStatus(a0),obStatus(a1)

		move.w	#$200,obVelX(a1)						; move fireball right
		btst	#staFlipX,obStatus(a1)					; is gargoyle facing left?
		bne.s	.noflip									; if not, branch
		neg.w	obVelX(a1)								; move fireball left

	.noflip:
		move.b	#(colHarmful|colSz_4x4),obColType(a1)
		bset	#shPropFlame,obShieldProp(a1)			; Negated by Flame Shield

		move.w	#sfx_Fireball,d0
		jsr		(QueueSound2).w							; play fireball sound

		bra.w	RememberState	
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 62 (sub) - gargoyle head's fireball (LZ)
; ---------------------------------------------------------------------------

Gar_FireBall:
		moveq	#7,d0
		and.b	(v_framebyte).w,d0						; SCE Optimization
		bne.s	.nochg
		bchg	#0,obFrame(a0)							; change every 8 frames

	.nochg:
		bsr.w	SpeedToPos_XOnly

		; check wall (Taken from S1 SCE) This is slightly slower, but makes direct use of the width OST
		; This will allow the user to easily accomodate shorter or wider projectiles
		move.b	obWidth(a0),d3
		ext.w	d3
		btst	#staFlipX,obStatus(a0)					; is fireball moving left?
		bne.s	.isright								; if not, branch
		neg.w	d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.w	DeleteObject							; delete if the	fireball hits a	wall to the left
		bra.w	RememberState
; ===========================================================================

	.isright:
		bsr.w	ObjHitWallRight
		tst.w	d1
		bmi.w	DeleteObject							; delete if the	fireball hits a	wall to the right
		bra.w	RememberState
; ===========================================================================