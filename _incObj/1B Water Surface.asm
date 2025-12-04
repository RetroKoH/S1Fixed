; ---------------------------------------------------------------------------
; Object 1B - water surface (LZ)
; ---------------------------------------------------------------------------

WaterSurface:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Surf_Action
	; Object Routine Optimization End

Surf_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)					; -> Surf_Action
		move.l	#Map_Surf,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Water_Surface,2,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$80,obDispWid(a0)
		move.w	obX(a0),obSurf_StartX(a0)			; save initial x position ($60 or $120)
; ---------------------------------------------------------------------------

Surf_Action:	; Routine 2
		move.w	(v_screenposx).w,d1					; get camera x position
		andi.w	#$FFE0,d1							; round down to $20
		add.w	obSurf_StartX(a0),d1				; add initial position
	; LuigiXHero Water Surface Fix
		btst	#bitStart,(v_jpadpressed_actual).w	; is Start button pressed?
		bne.s	.even								; if yes, branch
	; Water Surface Fix End
		btst	#0,(v_framebyte).w
		beq.s	.even								; branch on even frames
		addi.w	#$20,d1								; add $20 every other frame to create flicker

	.even:
		move.w	d1,obX(a0)							; match	obj x-position to screen position
		move.w	(v_waterpos_actual).w,d1
		move.w	d1,obY(a0)							; match	obj y-position to water	height
		tst.b	obSurf_Freeze(a0)
		bne.s	.stopped
		btst	#bitStart,(v_jpadpressed_actual).w	; is Start button pressed?
		beq.s	.animate							; if not, branch
		addq.b	#3,obFrame(a0)						; use different	frames
		move.b	#1,obSurf_Freeze(a0)				; stop animation
		bra.w	DisplaySprite
; ===========================================================================

.stopped:
		tst.b	(f_pause).w							; is the game paused?
		bne.w	DisplaySprite						; if yes, branch
		clr.b	obSurf_Freeze(a0)					; resume animation
		subq.b	#3,obFrame(a0)						; use normal frames

.animate:
		subq.b	#1,obTimeFrame(a0)					; decrement animation timer
		bpl.w	DisplaySprite						; branch if time remains
		move.b	#7,obTimeFrame(a0)					; reset timer
		addq.b	#1,obFrame(a0)						; next frame
		cmpi.b	#3,obFrame(a0)
		blo.w	DisplaySprite
		clr.b	obFrame(a0)							; reset to frame 0 when animation finishes
		bra.w	DisplaySprite
; ===========================================================================